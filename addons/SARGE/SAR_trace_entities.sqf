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
//  UPSMon  (specific SARGE version)
//  SHK_pos 
//  
// ---------------------------------------------------------------------------------------------------------
//   SAR_trace_entities.sqf
//   last modified: 1.4.2013
// ---------------------------------------------------------------------------------------------------------

private ["_ai","_entity_array","_humanity","_humanitylimit","_sleeptime","_detectrange","_weapons","_reloadmag","_magazintypes"];

_ai = _this select 0;

_weapons = weapons _ai;
_magazintypes =[];
_reloadmag = false;
_detectrange = SAR_DETECT_HOSTILE;
_humanitylimit=SAR_HUMANITY_HOSTILE_LIMIT;
_humanity=0;
_sleeptime = SAR_DETECT_INTERVAL;
    
while {alive _ai} do {

    if !(isServer) then {
        
        _entity_array = (position _ai) nearEntities ["CAManBase",_detectrange];
        {
            if(vehicle _ai == _ai) then { // AI is not in a vehicle, so we trace Zeds

                if (_x isKindof "zZombie_Base") then {
            
                    if(rating _x > -10000) then {
                        _x addrating -10000;
                        if(SAR_EXTREME_DEBUG) then {
                            diag_log "SAR EXTREME DEBUG: Zombie rated down";
                        };
                    };
                };
            };
            if(isPlayer _x) then {
                
                _humanity= _x getVariable ["humanity",0];

                If (_humanity < _humanitylimit && rating _x > -10000 && side _x != resistance) then {
                    if(SAR_EXTREME_DEBUG) then {
                        diag_log format["SAR EXTREME DEBUG: reducing rating (trace_entities) for player: %1", _x];
                    };
                    _x addrating -10000;
                };
            };
        
        } forEach _entity_array;
    };

    // refresh ammo
    
    if (isServer) then {
        
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
    sleep _sleeptime;
};