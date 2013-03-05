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
//   SAR_aikilled.sqf
//   last modified: 26.2.2013
// ---------------------------------------------------------------------------------------------------------
//  Parameters:
//  [ _ai (AI unit that was killed, 
//    _aikiller (unit that killed the AI)  
//   ]
// ------------------------------------------------------------------------------------------------------------


private ["_ai","_aikiller","_aikilled_type","_aikilled_name","_aikilled_side","_aikilled_group_side","_aikiller_group_side","_aikiller_type","_aikiller_name","_aikiller_side","_humanity"];

if (!isServer) exitWith {}; // only run this on the server

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

if(isPlayer _aikiller) then {
    
    if (_aikilled_side == west) then {
        if(SAR_DEBUG)then{diag_log format["Reducing humanity for: %1",_aikiller];};
        _humanity = _aikiller getVariable ["humanity",0];
        _humanity = _humanity - 250;
        _aikiller setVariable["humanity", _humanity,true];
    };
    
};

if (SAR_DEBUG) then {
    diag_log format["AI killed - Type: %1 Name: %2 Side: %3 Group Side: %4",_aikilled_type,_aikilled_name, _aikilled_side,_aikilled_group_side];
    diag_log format["AI Killer - Type: %1 Name: %2 Side: %3 Group Side: %4",_aikiller_type,_aikiller_name, _aikiller_side,_aikiller_group_side];
};