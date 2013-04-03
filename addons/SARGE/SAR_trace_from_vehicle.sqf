// =========================================================================================================
//  SAR_AI - DayZ AI library
//  Version: 1.1.0 
//  Author: Sarge (sarge@krumeich.ch) 
//
//		Wiki: to come
//		Forum: http://opendayz.net/index.php?threads/sarge-ai-framework-public-release.8391/
//		
// ---------------------------------------------------------------------------------------------------------
//  Required:
//  UPSMon  (special SARGE version)
//  SHK_pos 
//  
// ---------------------------------------------------------------------------------------------------------
//   SAR_trace_from_vehicle.sqf
//   last modified: 1.4.2013
// ---------------------------------------------------------------------------------------------------------

// Traces only from vehicles, so no ZED tracing, should not be used for infantry. Includes refuel and reammo functions for the vehicle

private ["_ai","_entity_array","_humanity","_humanitylimit","_sleeptime","_detectrange","_veh_weapons","_vehicle","_weapons","_tracewhat","_reloadmag","_magazintypes"];

_ai = _this select 0;
_tracewhat = "CAManBase";

_weapons = weapons _ai;

_detectrange = SAR_DETECT_HOSTILE * 2;
_humanitylimit = SAR_HUMANITY_HOSTILE_LIMIT;
_humanity=0;
_sleeptime = SAR_DETECT_INTERVAL/2;
    
while {alive _ai} do {

    if !(isServer) then {
    
        _entity_array = (position _ai) nearEntities [_tracewhat, _detectrange];
        
        {
            if(isPlayer _x) then {

                _humanity= _x getVariable ["humanity",0];
                
                If (_humanity < _humanitylimit && rating _x > -10000) then {
                    if(SAR_EXTREME_DEBUG) then {
                        diag_log format["SAR EXTREME DEBUG: reducing rating (trace_from_vehicle) for player: %1", _x];
                    };

                    _x addrating -10000;
                    // _target = _x;                    
                    // {
                        // _x doTarget _target;
                        // _x doFire _target;
                    // } foreach units group _ai; 

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

        } else { // NPC on foot
            
            // loop through weapons array
            {
                // check if weapon rifle exists on AI
                if([_x,"Rifle"] call SAR_isKindOf_weapon) then {

                    _reloadmag = true;
                    _magazintypes = getArray (configFile >> "CfgWeapons" >> _x >> "magazines");
                    
                    // loop through valid magazines of weapon and check if there is a magazine for that weapon on the AI
                    {
                        if (_x in magazines _ai) then {
                            _reloadmag = false;
                        };
                    } foreach _magazintypes;
                    
                    if ((_ai ammo _x == 0) || (_reloadmag))  then {
                        _ai removeMagazines (_magazintypes select 0);
                        _ai addMagazine (_magazintypes select 0);
                        if (SAR_EXTREME_DEBUG) then {diag_log "SAR_EXTREME_DEBUG: Infantry reloaded a magazine for a rifle.";};
                    };
                };

                if([_x,"Pistol"] call SAR_isKindOf_weapon) then {

                    _reloadmag = true;
                    _magazintypes = getArray (configFile >> "CfgWeapons" >> _x >> "magazines");
                    // loop through valid magazines of weapon and check if there is a magazine for that weapon on the AI
                    {
                        if (_x in magazines _ai) then {
                            _reloadmag = false;
                        };
                    } foreach _magazintypes;
                    
                    if ((_ai ammo _x == 0) || (_reloadmag))  then {
                        _ai removeMagazines (_magazintypes select 0);
                        _ai addMagazine (_magazintypes select 0);
                        if (SAR_EXTREME_DEBUG) then {diag_log "SAR_EXTREME_DEBUG: Infantry reloaded a magazine for a pistol.";};
                    };
                };
                
            } foreach _weapons;
        };
    };
    sleep _sleeptime;
};