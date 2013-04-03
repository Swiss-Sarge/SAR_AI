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
//  UPSMon  
//  SHK_pos 
//  
// ---------------------------------------------------------------------------------------------------------
//   SAR_ai_vehicle_hit.sqf
//   last modified: 1.4.2013
//   not used yet, some issues with the eventhandler
// ---------------------------------------------------------------------------------------------------------
//  Parameters:
//  [ _ai_veh (AI vehicle that was hit, 
//      _ai_veh_selName (AI vehicle selection that was damaged - NOT USED)
//      _ai_veh_dmg (vehicle damage - NOT USED)
//    _ai_veh_hitsource (unit that hit the AI vehicle)  
//   ]
// ------------------------------------------------------------------------------------------------------------


private ["_ai_veh","_ai_veh_hitsource","_ai_veh_type","_ai_veh_name","_ai_veh_side","_ai_veh_group_side","_ai_veh_hitsource_group_side","_ai_veh_hitsource_type","_ai_veh_hitsource_name","_ai_veh_hitsource_side"];

diag_log "Vehicle Damage Handler activated";

_ai_veh = _this select 0;
_ai_veh_hitsource = _this select 3;

_ai_veh_type = typeof _ai_veh;
_ai_veh_name = name _ai_veh;
_ai_veh_side = side _ai_veh;
_ai_veh_group_side = side (group _ai_veh);

_ai_veh_hitsource_type = typeof _ai_veh_hitsource;
_ai_veh_hitsource_name = name _ai_veh_hitsource;
_ai_veh_hitsource_side = side _ai_veh_hitsource;
_ai_veh_hitsource_group_side = side (group _ai_veh_hitsource);

if (SAR_HITKILL_DEBUG && (isServer)) then {
    diag_log format["SAR_HITKILL_DEBUG: AI vehicle hit - Type: %1 Name: %2 Side: %3 Group Side: %4",_ai_veh_type,_ai_veh_name, _ai_veh_side,_ai_veh_group_side];
    diag_log format["SAR_HITKILL_DEBUG: AI vehicle attacker - Type: %1 Name: %2 Side: %3 Group Side: %4",_ai_veh_hitsource_type,_ai_veh_hitsource_name, _ai_veh_hitsource_side,_ai_veh_hitsource_group_side];
};

if(isPlayer _ai_veh_hitsource) then {
    
    if (_ai_veh_group_side == SAR_AI_friendly_side) then {
        if(SAR_HITKILL_DEBUG && isServer)then{diag_log format["SAR_HITKILL_DEBUG: survivor or soldier vehicle was hit by %1",_ai_veh_hitsource];};
        if((rating _ai_veh_hitsource > -10000) && (!isServer)) then {
            _ai_veh_hitsource addRating -10000;
            if(SAR_HITKILL_DEBUG) then {
                diag_log format["SAR EXTREME DEBUG: reducing rating (shot a friendly vehicle) for player: %1", _ai_veh_hitsource];
            };

        };
        {
            _x doTarget _ai_veh_hitsource;
            _x doFire _ai_veh_hitsource;
        } foreach units group _ai_veh;
    };
};

_this select 2;