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
//   SAR_setup_AI_patrol_heli.sqf
//   last modified: 26.2.2013
// ---------------------------------------------------------------------------------------------------------


private ["_riflemenlist","_side","_leader_group","_initstring","_patrol_area_name","_leader_weapon_name","_soldier_weapon_name","_leader_sold","_soldier_sold","_rndpos","_groupheli","_heli","_leaderheli","_man2heli","_man3heli","_leader_magazine_name","_soldier_magazine_name","_argc"];

if(!isServer) exitWith {};

_argc = count _this;

_patrol_area_name = _this select 0;

_tracewhat=[];

// type of soldier list

if (_argc >1) then {

    _grouptype = _this select 1;

    switch (_grouptype) do
    {
        case 1: // military
        {
            _side = west;
            _leader_group = SAR_leader_sold_list call BIS_fnc_selectRandom;
            _riflemenlist = SAR_soldier_sold_list;
            _tracewhat=['Bandit1_DZ', 'BanditW1_DZ'];
            _initstring = format["null = [this,%1] execVM 'addons\SARGE\SAR_trace_from_vehicle.sqf';",_tracewhat];
        };
        case 2: // survivors
        {
            _side = west;
            _leader_group = SAR_leader_surv_list call BIS_fnc_selectRandom;
            _riflemenlist = SAR_soldier_surv_list;
            _tracewhat=['Bandit1_DZ', 'BanditW1_DZ'];
            _initstring = format["null = [this,%1] execVM 'addons\SARGE\SAR_trace_from_vehicle.sqf';",_tracewhat];
        };
        case 3: // bandits
        {
            _side = east;
            _leader_group = SAR_bandit_band_list call BIS_fnc_selectRandom;
            _riflemenlist = SAR_bandit_band_list;
            _tracewhat=['CAManBase'];
            _initstring = format["null = [this,%1] execVM 'addons\SARGE\SAR_trace_from_vehicle.sqf';",_tracewhat];
        };
        default
        {
            _side = west;
            _leader_group = SAR_leader_sold_list call BIS_fnc_selectRandom;
            _riflemenlist = SAR_soldier_sold_list;
            _tracewhat=['Bandit1_DZ', 'BanditW1_DZ'];
            _initstring = format["null = [this,%1] execVM 'addons\SARGE\SAR_trace_from_vehicle.sqf';",_tracewhat];
        };
    };

} else {
    _side = west;
    _leader_group = SAR_leader_sold_list call BIS_fnc_selectRandom;
    _riflemenlist = SAR_soldier_sold_list;
    _tracewhat=['Bandit1_DZ', 'BanditW1_DZ'];
    _initstring = format["null = [this,%1] execVM 'addons\SARGE\SAR_trace_from_vehicle.sqf';",_tracewhat];
};

_leader_weapon_name = SAR_leader_weapon_list call BIS_fnc_selectRandom;
_soldier_weapon_name = SAR_rifleman_weapon_list call BIS_fnc_selectRandom;

_leader_magazine_name = getArray (configFile >> "CfgWeapons" >> _leader_weapon_name >> "magazines") select 0;
_soldier_magazine_name = getArray (configFile >> "CfgWeapons" >> _soldier_weapon_name >> "magazines") select 0;


// get a random starting position that is on land
_rndpos = [_patrol_area_name] call SHK_pos;

_groupheli = createGroup _side;

// create the heli

_heli = createVehicle [SAR_heli_type, [(_rndpos select 0) + 10, _rndpos select 1, 80], [], 0, "FLY"];
_heli setVariable ["Sarge",1,true];
_heli engineon true; 
_heli allowDamage false;
_heli setVehicleAmmo 1;
[_heli] joinSilent _groupheli;

// create ppl in it
_leaderheli = _groupheli createunit [_leader_group, [(_rndpos select 0) + 10, _rndpos select 1, 0], [], 0.5, "NONE"];
_leaderheli addMagazine _leader_magazine_name;
_leaderheli addWeapon _leader_weapon_name;
_leaderheli setVehicleInit _initstring;
_leaderheli addMPEventHandler ["MPkilled", {Null = _this execVM "addons\SARGE\SAR_aikilled.sqf";}]; 

_leaderheli action ["getInPilot", _heli];
[_leaderheli] joinSilent _groupheli;

//Support
_man2heli = _groupheli createunit [_riflemenlist call BIS_fnc_selectRandom, [(_rndpos select 0) - 30, _rndpos select 1, 0], [], 0.5, "NONE"];
_man2heli addMagazine _soldier_magazine_name;
_man2heli addWeapon _soldier_weapon_name;
_man2heli action ["getInTurret", _heli,[0]];
[_man2heli] joinSilent _groupheli;

//Rifleman
_man3heli = _groupheli createunit [_riflemenlist call BIS_fnc_selectRandom, [_rndpos select 0, (_rndpos select 1) + 30, 0], [], 0.5, "NONE"];
_man3heli addMagazine _soldier_magazine_name;
_man3heli addWeapon _soldier_weapon_name;
_man3heli action ["getInTurret", _heli,[1]];
[_man3heli] joinSilent _groupheli;

// initialize upsmon for the group

_leaderheli = leader _groupheli;

null=[_leaderheli,_patrol_area_name,'spawned','nofollow','nowait','aware',"delete:",SAR_DELETE_TIMEOUT] execVM 'addons\UPSMON\scripts\upsmon.sqf';

processInitCommands;

if(SAR_DEBUG) then {
    diag_log format["SAR_DEBUG: static AI Heli patrol spawned in: %1",_patrol_area_name];
};

_groupheli;