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
//   SAR_aihit.sqf
//   last modified: 12.3.2013
// ---------------------------------------------------------------------------------------------------------
//  Parameters:
//  [ _ai (AI unit that was killed, 
//    _aikiller (unit that killed the AI)  
//   ]
// ------------------------------------------------------------------------------------------------------------


private ["_ai","_aikiller","_aikilled_type","_aikilled_name","_aikilled_side","_aikilled_group_side","_aikiller_group_side","_aikiller_type","_aikiller_name","_aikiller_side","_humanity"];

_ai = _this select 0;
_aikiller = _this select 1;

_aikilled_type = typeof _ai;
_aikilled_name = name _ai;
_aikilled_side = side _ai;
_aikilled_group_side = side (group _ai);

_aikiller_type = typeof _aikiller;
_aikiller_name = name _aikiller;
_aikiller_side = side _aikiller;
_aikiller_group_side = side (group _aikiller);

if (SAR_EXTREME_DEBUG && (isServer)) then {
    diag_log format["SAR_EXTREME_DEBUG: AI hit - Type: %1 Name: %2 Side: %3 Group Side: %4",_aikilled_type,_aikilled_name, _aikilled_side,_aikilled_group_side];
    diag_log format["SAR_EXTREME_DEBUG: AI attacker - Type: %1 Name: %2 Side: %3 Group Side: %4",_aikiller_type,_aikiller_name, _aikiller_side,_aikiller_group_side];
};

if(isPlayer _aikiller) then {
    
    if (_aikilled_group_side == west) then {
        if(SAR_EXTREME_DEBUG && isServer)then{diag_log format["SAR_EXTREME_DEBUG: survivor or soldier was hit by %1",_aikiller];};
        _humanity = _aikiller getVariable ["humanity",0];
        _humanity = _humanity - (SAR_surv_kill_value/10);
        _aikiller setVariable["humanity", _humanity,true];
        if((rating _aikiller > -10000) && (!isServer)) then {
            _aikiller addRating -10000;
        };
        {
            _x doTarget _aikiller;
            _x doFire _aikiller;
        } foreach units group _ai;
    };
    if (_aikilled_group_side == east) then {
        if(SAR_EXTREME_DEBUG && isServer)then{diag_log format["SAR_EXTREME_DEBUG: Adjusting humanity for bandit hit by %2 for %1",_aikiller,(SAR_band_kill_value/10)];};
        _humanity = _aikiller getVariable ["humanity",0];
        _humanity = _humanity + (SAR_band_kill_value/10);
        _aikiller setVariable["humanity", _humanity,true];
    };
    
};

