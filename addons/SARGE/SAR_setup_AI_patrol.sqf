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
//   SAR_setup_AI_patrol.sqf
//   last modified: 1.4.2013
// ---------------------------------------------------------------------------------------------------------
//  Parameters:
//  [ _patrol_area_name (Markername of area to patrol), 
//    grouptype (numeric -> 1=military, 2=survivor, 3=bandits),  
//    number_of_snipers (numeric),
//    number of riflemen (numeric),
//    behaviour (string -> "patrol", "fortify", "ambush", "noUpsmon") 
//    respawn (boolean, -> true,false)
//   ]
// ------------------------------------------------------------------------------------------------------------


private ["_leadername","_patrol_area_name","_grouptype","_snipers","_riflemen","_action","_side","_leader_group","_riflemenlist","_sniperlist","_rndpos","_group","_leader","_i","_cond","_respawn","_leader_weapon_names","_leader_items","_leader_tools","_soldier_weapon_names","_soldier_items","_soldier_tools","_sniper_weapon_names","_sniper_items","_sniper_tools","_leaderskills","_riflemanskills","_sniperskills","_ups_para_list"];

if(!isServer) exitWith {};

_patrol_area_name = _this select 0;
_grouptype = _this select 1;
_snipers = _this select 2;
_riflemen = _this select 3;
_action = _this select 4;
_respawn = _this select 5;

switch (_grouptype) do
{
    case 1: // military
    {
        _side = SAR_AI_friendly_side;
        _leader_group = SAR_leader_sold_list call BIS_fnc_selectRandom;
        _riflemenlist = SAR_soldier_sold_list;
        _sniperlist = SAR_sniper_sold_list;
        
        _leaderskills = SAR_leader_sold_skills;
        _riflemanskills = SAR_soldier_sold_skills;
        _sniperskills = SAR_sniper_sold_skills;
        
    };
    case 2: // survivors
    {
        _side = SAR_AI_friendly_side;
        _leader_group = SAR_leader_surv_list call BIS_fnc_selectRandom;
        _riflemenlist = SAR_soldier_surv_list;
        _sniperlist = SAR_sniper_surv_list;
        
        _leaderskills = SAR_leader_surv_skills;
        _riflemanskills = SAR_soldier_surv_skills;
        _sniperskills = SAR_sniper_surv_skills;
        
    };
    case 3: // bandits
    {
        _side = SAR_AI_unfriendly_side;
        _leader_group = SAR_leader_band_list call BIS_fnc_selectRandom;
        _riflemenlist = SAR_soldier_band_list;
        _sniperlist = SAR_sniper_band_list;
        
        _leaderskills = SAR_leader_band_skills;
        _riflemanskills = SAR_soldier_band_skills;
        _sniperskills = SAR_sniper_band_skills;
        
    };
};

_leader_weapon_names = ["leader"] call SAR_unit_loadout_weapons;
_leader_items = ["leader"] call SAR_unit_loadout_items;
_leader_tools = ["leader"] call SAR_unit_loadout_tools;

_soldier_weapon_names = ["soldier"] call SAR_unit_loadout_weapons;
_soldier_items = ["soldier"] call SAR_unit_loadout_items;
_soldier_tools = ["soldier"] call SAR_unit_loadout_tools;

_sniper_weapon_names = ["sniper"] call SAR_unit_loadout_weapons;
_sniper_items = ["sniper"] call SAR_unit_loadout_items;
_sniper_tools = ["sniper"] call SAR_unit_loadout_tools;



// get a random starting position that is on land

_rndpos = [_patrol_area_name] call SHK_pos;

_group = createGroup _side;

// protect group from being deleted by DayZ
_group setVariable ["SAR_protect",true,true];

// create leader of the group
_leader = _group createunit [_leader_group, [(_rndpos select 0) + 10, _rndpos select 1, 0], [], 0.5, "FORM"];

[_leader,_leader_weapon_names,_leader_items,_leader_tools] call SAR_unit_loadout;

_leader setVehicleInit "null = [this] execVM 'addons\SARGE\SAR_trace_entities.sqf';this setIdentity 'id_SAR_sold_lead';";
_leader addMPEventHandler ["MPkilled", {Null = _this execVM "addons\SARGE\SAR_aikilled.sqf";}]; 
_leader addMPEventHandler ["MPHit", {Null = _this execVM "addons\SARGE\SAR_aihit.sqf";}];

_leader addEventHandler ["HandleDamage",{if (_this select 1!="") then {_unit=_this select 0;damage _unit+((_this select 2)-damage _unit)*SAR_leader_health_factor}}];

_cond="(side _this == west) && (side _target == resistance) && ('ItemBloodbag' in magazines _this)";

[nil,_leader,rADDACTION,"Give me a blood transfusion!", "addons\SARGE\SAR_interact.sqf","",1,true,true,"",_cond] call RE;
 
[_leader] joinSilent _group;

// set skills of the leader
{
    _leader setskill [_x select 0,(_x select 1 +(floor(random 2) * (_x select 2)))];
} foreach _leaderskills;

SAR_leader_number = SAR_leader_number + 1;

_leadername = format["SAR_leader_%1",SAR_leader_number];

_leader setVehicleVarname _leadername;

// SARGE - do i need this name on the clientside ???

// create global variable for this group
call compile format ["KRON_UPS_%1=1",_leadername];

// if needed broadcast to the clients
//_leader Call Compile Format ["%1=_This ; PublicVariable ""%1""",_leadername];

// create crew
for [{_i=0}, {_i < _snipers}, {_i=_i+1}] do
{
    _this = _group createunit [_sniperlist call BIS_fnc_selectRandom, [(_rndpos select 0) - 30, _rndpos select 1, 0], [], 0.5, "FORM"];
    
    [_this,_sniper_weapon_names,_sniper_items,_sniper_tools] call SAR_unit_loadout;
    
    _this setVehicleInit "null = [this] execVM 'addons\SARGE\SAR_trace_entities.sqf';this setIdentity 'id_SAR';";
    _this addMPEventHandler ["MPkilled", {Null = _this execVM "addons\SARGE\SAR_aikilled.sqf";}]; 
    _this addMPEventHandler ["MPHit", {Null = _this execVM "addons\SARGE\SAR_aihit.sqf";}]; 
    [_this] joinSilent _group;
    // set skills 
    {
        _this setskill [_x select 0,(_x select 1 +(floor(random 2) * (_x select 2)))];
    } foreach _sniperskills;

};

for [{_i=0}, {_i < _riflemen}, {_i=_i+1}] do
{
    _this = _group createunit [_riflemenlist call BIS_fnc_selectRandom, [(_rndpos select 0) + 30, _rndpos select 1, 0], [], 0.5, "FORM"];
    
    [_this,_soldier_weapon_names,_soldier_items,_soldier_tools] call SAR_unit_loadout;
    
    _this setVehicleInit "null = [this] execVM 'addons\SARGE\SAR_trace_entities.sqf';this setIdentity 'id_SAR_sold_man';";    
    _this addMPEventHandler ["MPkilled", {Null = _this execVM "addons\SARGE\SAR_aikilled.sqf";}]; 
    _this addMPEventHandler ["MPHit", {Null = _this execVM "addons\SARGE\SAR_aihit.sqf";}];     
    [_this] joinSilent _group;

    // set skills 
    {
        _this setskill [_x select 0,(_x select 1 +(floor(random 2) * (_x select 2)))];
    } foreach _riflemanskills;
    
};

_leader = leader _group;

// initialize upsmon for the group

_ups_para_list = [_leader,_patrol_area_name,'nowait','nofollow','aware','showmarker','delete:',SAR_DELETE_TIMEOUT];

if (_respawn) then {
    _ups_para_list = _ups_para_list + ['respawn'];
};

if(!SAR_AI_STEAL_VEHICLE) then {
    _ups_para_list = _ups_para_list + ['noveh'];
};

if(SAR_AI_disable_UPSMON_AI) then {
    _ups_para_list = _ups_para_list + ['noai'];
};


if(_action == "") then {_action = "patrol";};

switch (_action) do {

    case "noupsmon":
    {
    };
    case "fortify":
    {
        _ups_para_list = _ups_para_list + ['fortify'];
        _ups_para_list execVM 'addons\UPSMON\scripts\upsmon.sqf';
    };
    case "fortify2":
    {
        _ups_para_list = _ups_para_list + ['fortify2'];
        _ups_para_list execVM 'addons\UPSMON\scripts\upsmon.sqf';
    };
    case "patrol":
    {
        _ups_para_list execVM 'addons\UPSMON\scripts\upsmon.sqf';
    };
    case "ambush":
    {
        _ups_para_list = _ups_para_list + ['ambush'];
        _ups_para_list execVM 'addons\UPSMON\scripts\upsmon.sqf';
    };
};
    
    
processInitCommands;

if(SAR_EXTREME_DEBUG) then {
    diag_log format["SAR_EXTREME_DEBUG: Infantry group spawned in: %1 with action: %2",_patrol_area_name,_action];
};
_group;