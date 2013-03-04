// =========================================================================================================
//  SAR_AI - DayZ AI library
//  Version: 1.0.0 
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
//   SAR_trace_banditsonly.sqf
//   last modified: 26.2.2013
// ---------------------------------------------------------------------------------------------------------

// SARGE DEBUG - TODO - eventually adjust the sleep timer
//
// Traces only bandits

private["_ai","_magazintype","_entity_array","_humanity","_humanitylimit","_sleeptime","_detectrange"];

_ai = _this select 0;

_weapons = weapons _ai;
_weapon = _weapons select 0;
_magazintype= getArray (configFile >> "CfgWeapons" >> _weapon >> "magazines") select 0;

_detectrange=300;
_humanitylimit=0;
_humanity=0;
_sleeptime=5;

    
while {alive _ai} do {

    //diag_log "heartbeat";

    if !(isServer) then {
    
        _entity_array = (position _ai) nearEntities [["Bandit1_DZ", "BanditW1_DZ"],_detectrange];
        
        {

            if(vehicle _ai != _ai) then { // NPC in a vehicle

                if(isPlayer _x) then {
                    _humanity= _x getVariable ["humanity",0];
                    _tagged = _x getVariable ["tagged",false];
                    
                    If (_humanity < _humanitylimit && rating _x > -10000 && !_tagged) then {
                        //diag_log format["reducing rating (trace_bandits - vehicle) for player: %1", _x];
                        _x setVariable["tagged",true,true];
                        _x addrating -10000;
                        
                    };
                };
            
            } else { //NPC on foot

                if(isPlayer _x) then {
                    _humanity= _x getVariable ["humanity",0];

                    If (_humanity < _humanitylimit && rating _x > -10000) then {
                        //diag_log format["reducing rating (trace_bandits - foot) for player: %1", _x];
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
            
            if(_vehicle ammo (_veh_weapons select 0) < 51) then {
                _vehicle setVehicleAmmo 1;
                if (SAR_DEBUG) then {diag_log "Vehicle new ammo";};
            };
            
            if(fuel _vehicle < 0.8) then {
                _vehicle setFuel 1;
                if (SAR_DEBUG) then {diag_log "Vehicle refueled";};
            };

        } else {
            
            if ((_ai ammo _weapon == 0) || ((count magazines _ai) < 1))  then {
                {_ai removeMagazine _x} forEach magazines _ai;
                _ai addMagazine _magazintype;
                if (SAR_DEBUG) then {diag_log "Infantry reloaded";};
            };
        };

    };
    
    sleep _sleeptime;
    
};