// =========================================================================================================
//  SAR_AI - DayZ AI library
//  Version: 1.0.3 
//  Author: Sarge (sarge@krumeich.ch) 
//
//		Wiki: to come
//		Forum: to come
//		
// ---------------------------------------------------------------------------------------------------------
//  Required:
//  UPSMon  
//  SHK_pos 
//  
// ---------------------------------------------------------------------------------------------------------
//   SAR_trace_from_vehicle.sqf
//   last modified: 6.3.2013
// ---------------------------------------------------------------------------------------------------------

// SARGE DEBUG - TODO - eventually adjust the sleep timer
//
// Traces only from vehicles, so no ZED tracing, should not be used for infantry. Inlcudes refuel and reammo functions for the vehicle

private ["_ai","_magazintype","_entity_array","_humanity","_humanitylimit","_sleeptime","_detectrange","_tagged","_veh_weapons","_vehicle","_weapons","_weapon","_tracewhat"];

_ai = _this select 0;
_tracewhat = _this select 1;

_weapons = weapons _ai;
_weapon = _weapons select 0;
_magazintype= getArray (configFile >> "CfgWeapons" >> _weapon >> "magazines") select 0;

_detectrange=300;
_humanitylimit=-2000;
_humanity=0;
_sleeptime=20;
    
while {alive _ai} do {

    //diag_log "heartbeat";

    if !(isServer) then {
    
        _entity_array = (position _ai) nearEntities [_tracewhat, _detectrange];
        
        {

            if(vehicle _ai != _ai) then { // NPC in a vehicle

                if(isPlayer _x) then {
                    _humanity= _x getVariable ["humanity",0];
                    _tagged = _x getVariable ["tagged",false];
                    
                    If (_humanity < _humanitylimit && rating _x > -10000 && !_tagged) then {
                        if(SAR_EXTREME_DEBUG) then {
                            diag_log format["SAR EXTREME DEBUG: reducing rating (trace_from_vehicle - vehicle) for player: %1", _x];
                        };
                        _x setVariable["tagged",true,true];
                        _x addrating -10000;
                        
                    };
                };
            
            } else { //NPC on foot

                if(isPlayer _x) then {
                    _humanity= _x getVariable ["humanity",0];

                    If (_humanity < _humanitylimit && rating _x > -10000) then {
                        if(SAR_EXTREME_DEBUG) then {
                            diag_log format["SAR EXTREME DEBUG: reducing rating (trace_from_vehicle - foot) for player: %1", _x];
                        };
                        _x addrating -10000;
                    };
                };
            };

            
        } forEach _entity_array;
    };
    // refresh ammo & fuel
    
    if (isServer) then {
    
        _vehicle = vehicle _ai;
    
        if(_vehicle != _ai) then { // NPC in vehicle, we are only reloading vehicle ammo
        
            // check if low on ammo & fuel
            _veh_weapons = weapons _vehicle;
            
            if(_vehicle ammo (_veh_weapons select 0) < 11) then {
                _vehicle setVehicleAmmo 1;
                if (SAR_EXTREME_DEBUG) then {diag_log "SAR EXTREME DEBUG: Vehicle new ammo";};
            };
            
            if(fuel _vehicle < 0.2) then {
                _vehicle setFuel 1;
                if (SAR_EXTREME_DEBUG) then {diag_log "SAR_EXTREME_DEBUG: Vehicle refueled";};
            };

        } else {
            
            if ((_ai ammo _weapon == 0) || ((count magazines _ai) < 1))  then {
                {_ai removeMagazine _x} forEach magazines _ai;
                _ai addMagazine _magazintype;
                if (SAR_EXTREME_DEBUG) then {diag_log "SAR_EXTREME_DEBUG: Infantry reloaded";};
            };
        };

    };
    
    sleep _sleeptime;
    
};