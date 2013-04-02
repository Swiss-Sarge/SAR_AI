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
//   SAR_group_monitor.sqf
//   last modified: 1.4.2013
// ---------------------------------------------------------------------------------------------------------


private ["_allgroups","_running","_sleeptime","_usedgroups","_count_friendly_groups","_count_unfriendly_groups"];

if (!isServer) exitWith {}; // only run this on the server

_running = true;
_sleeptime = 60;
_usedgroups = [];

while {_running} do {

    _allgroups = allgroups;

    _count_friendly_groups = {side _x == SAR_AI_friendly_side} count _allgroups;
    _count_unfriendly_groups = {side _x == SAR_AI_unfriendly_side} count _allgroups;

    if(_count_friendly_groups > 120) then {

        diag_log format["SARGE AI: WARNING - more than 120 friendly AI groups active. Consider decreasing your configured AI survivor and soldier groups. Number of active groups: %1.",_count_friendly_groups];
        SAR_MAX_GRP_WEST_SPAWN = true;
    } else {
        SAR_MAX_GRP_WEST_SPAWN = false;
    };

    if(_count_unfriendly_groups > 120) then {
    
        diag_log format["SARGE AI: WARNING - more than 120 unfriendly AI groups active. Consider decreasing your configured AI bandit groups. Number of active groups: %1.",_count_unfriendly_groups];
        SAR_MAX_GRP_EAST_SPAWN = true;
        
    } else {
        SAR_MAX_GRP_EAST_SPAWN = false;    
    };
    
    
    
    {
        if (side _x == west) then{
        
            if (_x getVariable["SAR_protect",false]) then {
            
                _tmpgrp = _x;
                _delete_group=true;
            
                // query player array, and get used groups
                {
                    if (str(_x getVariable["SAR_player_group",""]) == str(_tmpgrp)) then {
                        _delete_group=false;
                    };
                
                } foreach dayz_players;

                if (_delete_group) then {
                    //group has no owner anymore, remove the locking variable and let Rockets cleanup do the rest
                    _x setVariable ["SAR_protect",nil,true];
                    diag_log format["SARGE AI: marked an orphaned group for deletion: %1",_x];
                };
                
            };

        };
    
    } foreach _allgroups;

    sleep _sleeptime;

};