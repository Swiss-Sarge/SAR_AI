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
//  SAR_AI_trigger.sqf - handle triggers activated on the clients
// ---------------------------------------------------------------------------------------------------------

diag_log "Do i ever get here";

if (!isServer) exitWith {}; // only run this on the server

private["_pos","_ai","_aikiller","_player_or_ai","_aikiller_type","_aikiller_name", "_aikiller_side"];

_triggerlist = _this;

_player = _triggerlist select 0;

diag_log["Value: %1",_triggerlist];
diag_log["Side player: %1",side _player]; 
diag_log["Isplayer: %1",isPlayer _player];
