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
//   SAR_aihit.sqf
//   last modified: 1.4.2013
// ---------------------------------------------------------------------------------------------------------
//  Parameters:
//  [ _ai (AI unit that was killed, 
//    _aikiller (unit that killed the AI)  
//   ]
// ------------------------------------------------------------------------------------------------------------


private ["_ai","_aikiller","_aikilled_type","_aikilled_side","_aikilled_group_side","_aikiller_group_side","_aikiller_type","_aikiller_name","_aikiller_side","_humanity"];

_ai = _this select 0;
_aikiller = _this select 1;

_aikilled_type = typeof _ai;
_aikilled_side = side _ai;
_aikilled_group_side = side (group _ai);

_aikiller_type = typeof _aikiller;
_aikiller_name = name _aikiller;
_aikiller_side = side _aikiller;
_aikiller_group_side = side (group _aikiller);

if (SAR_HITKILL_DEBUG && (isServer)) then {
    diag_log format["SAR_HITKILL_DEBUG: AI hit - Type: %1 Side: %3 Group Side: %4",_aikilled_type,_aikilled_side,_aikilled_group_side];
    diag_log format["SAR_HITKILL_DEBUG: AI attacker - Type: %1 Name: %2 Side: %3 Group Side: %4",_aikiller_type,_aikiller_name, _aikiller_side,_aikiller_group_side];
};

if(isPlayer _aikiller) then {
    
    if (_aikilled_group_side == SAR_AI_friendly_side) then {
        if(SAR_HITKILL_DEBUG && isServer)then{diag_log format["SAR_HITKILL_DEBUG: survivor or soldier was hit by %1",_aikiller];};
        _humanity = _aikiller getVariable ["humanity",0];
        _humanity = _humanity - (SAR_surv_kill_value/10);
        _aikiller setVariable["humanity", _humanity,true];
        if((rating _aikiller > -10000) && (!isServer) && side _aikiller != resistance) then {
            _aikiller addRating -10000;
        };
        {
            _x doTarget _aikiller;
            _x doFire _aikiller;
        } foreach units group _ai;
    };
    if (_aikilled_group_side == SAR_AI_unfriendly_side) then {
        if(SAR_HITKILL_DEBUG && isServer)then{diag_log format["SAR_HITKILL_DEBUG: Adjusting humanity for bandit hit by %2 for %1",_aikiller,(SAR_band_kill_value/10)];};
        _humanity = _aikiller getVariable ["humanity",0];
        _humanity = _humanity + (SAR_band_kill_value/10);
        _aikiller setVariable["humanity", _humanity,true];
    };
};