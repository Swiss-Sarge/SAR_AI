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
//   SAR_setup_AI_patrol.sqf
//   last modified: 26.2.2013
// ---------------------------------------------------------------------------------------------------------
//  Parameters:
//  [ _patrol_area_name (Markername of area to patrol), 
//    grouptype (numeric -> 1=military, 2=survivor, 3=bandits),  
//    number_of_snipers (numeric),
//    number of riflemen (numeric),
//    behaviour (string -> "patrol", "defend") -> not yet implemented
//   ]
// ------------------------------------------------------------------------------------------------------------


private ["_patrol_area_name","_grouptype","_snipers","_riflemen","_action","_side","_leader_group","_riflemenlist","_sniperlist","_leader_weapon_name","_soldier_weapon_name","_sniper_weapon_name","_leader_magazine_name","_soldier_magazine_name","_sniper_magazin_name","_rndpos","_group","_leader","_i"];

if(!isServer) exitWith {};

_patrol_area_name = _this select 0;
_grouptype = _this select 1;
_snipers = _this select 2;
_riflemen = _this select 3;
_action = _this select 4;

switch (_grouptype) do
{
    case 1: // military
    {
        _side = west;
        _leader_group = SAR_leader_sold_list call BIS_fnc_selectRandom;
        _riflemenlist = SAR_soldier_sold_list;
        _sniperlist = SAR_sniper_sold_list;
    };
    case 2: // survivors
    {
        _side = west;
        _leader_group = SAR_leader_surv_list call BIS_fnc_selectRandom;
        _riflemenlist = SAR_soldier_surv_list;
        _sniperlist = SAR_sniper_surv_list;
    };
    case 3: // bandits
    {
        _side = east;
        _leader_group = SAR_bandit_band_list call BIS_fnc_selectRandom;
        _riflemenlist = SAR_bandit_band_list;
        _sniperlist = SAR_bandit_band_list;
    };
};

_leader_weapon_name = SAR_leader_weapon_list call BIS_fnc_selectRandom;
_soldier_weapon_name = SAR_rifleman_weapon_list call BIS_fnc_selectRandom;
_sniper_weapon_name = SAR_sniper_weapon_list call BIS_fnc_selectRandom;

_leader_magazine_name = getArray (configFile >> "CfgWeapons" >> _leader_weapon_name >> "magazines") select 0;
_soldier_magazine_name = getArray (configFile >> "CfgWeapons" >> _soldier_weapon_name >> "magazines") select 0;
_sniper_magazin_name = getArray (configFile >> "CfgWeapons" >> _sniper_weapon_name >> "magazines") select 0;

// get a random starting position that is on land

_rndpos = [_patrol_area_name] call SHK_pos;

_group = createGroup _side;

// create leader of the group
_leader = _group createunit [_leader_group, [(_rndpos select 0) + 10, _rndpos select 1, 0], [], 0.5, "FORM"];
removeAllWeapons _leader;
_leader addMagazine _leader_magazine_name;
_leader addWeapon _leader_weapon_name;
_leader setVehicleInit "null = [this] execVM 'addons\SARGE\SAR_trace_entities.sqf';";
_leader addMPEventHandler ["MPkilled", {Null = _this execVM "addons\SARGE\SAR_aikilled.sqf";}]; 
[_leader] joinSilent _group;

// create crew

for [{_i=0}, {_i < _snipers}, {_i=_i+1}] do
{
    _this = _group createunit [_sniperlist call BIS_fnc_selectRandom, [(_rndpos select 0) - 30, _rndpos select 1, 0], [], 0.5, "FORM"];
    removeAllWeapons _this;
    _this addMagazine _sniper_magazin_name;
    _this addWeapon _sniper_weapon_name;
    _this setVehicleInit "null = [this] execVM 'addons\SARGE\SAR_trace_entities.sqf';";
    _this addMPEventHandler ["MPkilled", {Null = _this execVM "addons\SARGE\SAR_aikilled.sqf";}]; 
    [_this] joinSilent _group;
};

for [{_i=0}, {_i < _riflemen}, {_i=_i+1}] do
{
    _this = _group createunit [_riflemenlist call BIS_fnc_selectRandom, [(_rndpos select 0) + 30, _rndpos select 1, 0], [], 0.5, "FORM"];
    removeAllWeapons _this;
    _this addMagazine _soldier_magazine_name;
    _this addWeapon _soldier_weapon_name;
    _this setVehicleInit "null = [this] execVM 'addons\SARGE\SAR_trace_entities.sqf';";    
    _this addMPEventHandler ["MPkilled", {Null = _this execVM "addons\SARGE\SAR_aikilled.sqf";}]; 
    [_this] joinSilent _group;
};


// initialize upsmon for the group

_leader = leader _group;

null=[_leader,_patrol_area_name,'spawned','nofollow','nowait','aware','delete:',SAR_DELETE_TIMEOUT] execVM 'addons\UPSMON\scripts\upsmon.sqf';

processInitCommands;

if(SAR_DEBUG) then {
    diag_log format["SAR_DEBUG: static Infantry patrol spawned in: %1",_patrol_area_name];
};
_group;