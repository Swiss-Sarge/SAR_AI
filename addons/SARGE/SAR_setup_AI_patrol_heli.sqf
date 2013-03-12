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
//   SAR_setup_AI_patrol_heli.sqf
//   last modified: 26.2.2013
// ---------------------------------------------------------------------------------------------------------


private ["_riflemenlist","_side","_leader_group","_initstring","_patrol_area_name","_leader_weapon_name","_soldier_weapon_name","_rndpos","_groupheli","_heli","_leaderheli","_man2heli","_man3heli","_leader_magazine_name","_soldier_magazine_name","_argc","_tracewhat","_grouptype","_out","_stp","_weaps","_mt","_st","_stc","_mtc","_cfg","_tc"];

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
            _initstring = format["null = [this,%1] execVM 'addons\SARGE\SAR_trace_from_vehicle.sqf';this setIdentity 'id_SAR_sold_man';",_tracewhat];
        };
        case 2: // survivors
        {
            _side = west;
            _leader_group = SAR_leader_surv_list call BIS_fnc_selectRandom;
            _riflemenlist = SAR_soldier_surv_list;
            _tracewhat=['Bandit1_DZ', 'BanditW1_DZ'];
            _initstring = format["null = [this,%1] execVM 'addons\SARGE\SAR_trace_from_vehicle.sqf';this setIdentity 'id_SAR_surv_lead';",_tracewhat];
        };
        case 3: // bandits
        {
            _side = east;
            _leader_group = SAR_bandit_band_list call BIS_fnc_selectRandom;
            _riflemenlist = SAR_bandit_band_list;
            _tracewhat=['CAManBase'];
            _initstring = format["null = [this,%1] execVM 'addons\SARGE\SAR_trace_from_vehicle.sqf';this setIdentity 'id_SAR_band';",_tracewhat];
        };
        default
        {
            _side = west;
            _leader_group = SAR_leader_sold_list call BIS_fnc_selectRandom;
            _riflemenlist = SAR_soldier_sold_list;
            _tracewhat=['Bandit1_DZ', 'BanditW1_DZ'];
            _initstring = format["null = [this,%1] execVM 'addons\SARGE\SAR_trace_from_vehicle.sqf';this setIdentity 'id_SAR_band';",_tracewhat];
        };
    };

} else {
    _side = west;
    _leader_group = SAR_leader_sold_list call BIS_fnc_selectRandom;
    _riflemenlist = SAR_soldier_sold_list;
    _tracewhat=['Bandit1_DZ', 'BanditW1_DZ'];
    _initstring = format["null = [this,%1] execVM 'addons\SARGE\SAR_trace_from_vehicle.sqf';this setIdentity 'id_SAR_band';",_tracewhat];
};

_leader_weapon_name = SAR_leader_weapon_list call BIS_fnc_selectRandom;
_soldier_weapon_name = SAR_rifleman_weapon_list call BIS_fnc_selectRandom;

_leader_magazine_name = getArray (configFile >> "CfgWeapons" >> _leader_weapon_name >> "magazines") select 0;
_soldier_magazine_name = getArray (configFile >> "CfgWeapons" >> _soldier_weapon_name >> "magazines") select 0;


// get a random starting position that is on land
_rndpos = [_patrol_area_name] call SHK_pos;

_groupheli = createGroup _side;

// create the vehicle

_heli = createVehicle [SAR_heli_type, [(_rndpos select 0) + 10, _rndpos select 1, 80], [], 0, "FLY"];
_heli setFuel 1;

_heli setVariable ["Sarge",1,true];
_heli engineon true; 
_heli allowDamage false;
_heli setVehicleAmmo 1;

//_heli addEventHandler ["HandleDamage", {returnvalue = _this execVM "addons\SARGE\SAR_ai_vehicle_hit.sqf";}];  
_heli addMPEventHandler ["MPHit", {Null = _this execVM "addons\SARGE\SAR_aihit.sqf";}];  

[_heli] joinSilent _groupheli;

//
// Get turret config ... this is mega buggy from a BI side
//

//diag_log typeof _heli;

//_cfg = [configFile >> "CfgVehicles" >> typeOf _heli >> "turrets"] call SAR_fnc_returnVehicleTurrets;

//_cfg = getArray (configFile >> "CfgVehicles" >> typeof _heli >> "Turrets");
//_tc = count _cfg;

//{ diag_log format["SAR_DEBUG: %1",_cfg select _forEachIndex];}foreach _cfg;

// diag_log "_____________";

// for [{_i=0}, {_i < _tc}, {_i=_i+1}] do
// {
    // diag_log format["SAR_DEBUG: Array %1: %2",_i, _cfg select _i];
// };

// if (_tc>0) then {
    // _mtc = count _cfg; // number of main turrets
    // _out = _out + format["Main Turrets: %1\n",count _cfg];
    
    // for "_mti" from 0 to _mtc-1 do {
        // _mt = (_cfg select _mti);
        // _st = _mt >> "turrets";
        // _stc = count _st; // sub-turrets in current main one
        // _out = _out + format["Turret #%1, %2: [%1]\n",_mti,configName(_mt)];
        // _weaps = getArray(_mt >> "weapons");
        // _out = _out + format[" Weapons:\n"];
        // {_out = _out + format["  %1\n",_x]}forEach _weaps;
        // for "_sti" from 0 to _stc-1 do {
            // _stp = (_st select _sti);
            // _out = _out + format["Turret #%1, %2: [%1,%3]\n",_mti,configName(_stp),_sti];
            // _weaps = getArray(_stp >> "weapons");
            // _out = _out + format[" Weapons:\n"];
            // {_out = _out + format["  %1\n",_x]}forEach _weaps;
        // };
    // };
// } else {
    // _out = "SAR_DEBUG: Turret config not found";
// };

//diag_log format["SAR_DEBUG: Turrets: %1, _tc=%2",_out,_tc];

//
//
//


// create ppl in it
_leaderheli = _groupheli createunit [_leader_group, [(_rndpos select 0) + 10, _rndpos select 1, 0], [], 0.5, "NONE"];
_leaderheli addMagazine _leader_magazine_name;
_leaderheli addWeapon _leader_weapon_name;
_leaderheli setVehicleInit _initstring;
_leaderheli addMPEventHandler ["MPkilled", {Null = _this execVM "addons\SARGE\SAR_aikilled.sqf";}];
_leaderheli addMPEventHandler ["MPHit", {Null = _this execVM "addons\SARGE\SAR_aihit.sqf";}];  

_leaderheli action ["getInPilot", _heli];
[_leaderheli] joinSilent _groupheli;

//Support
_man2heli = _groupheli createunit [_riflemenlist call BIS_fnc_selectRandom, [(_rndpos select 0) - 30, _rndpos select 1, 0], [], 0.5, "NONE"];
_man2heli addMagazine _soldier_magazine_name;
_man2heli addWeapon _soldier_weapon_name;

//_man2heli action ["getInTurret", _heli,[0]];
_man2heli moveInTurret [_heli,[0]];

_man2heli setVehicleInit _initstring;
_man2heli addMPEventHandler ["MPkilled", {Null = _this execVM "addons\SARGE\SAR_aikilled.sqf";}];
_man2heli addMPEventHandler ["MPHit", {Null = _this execVM "addons\SARGE\SAR_aihit.sqf";}];  
[_man2heli] joinSilent _groupheli;

//Rifleman
_man3heli = _groupheli createunit [_riflemenlist call BIS_fnc_selectRandom, [_rndpos select 0, (_rndpos select 1) + 30, 0], [], 0.5, "NONE"];
_man3heli addMagazine _soldier_magazine_name;
_man3heli addWeapon _soldier_weapon_name;
_man3heli setVehicleInit _initstring;

//_man3heli action ["getInTurret", _heli,[1]];
_man3heli moveInTurret [_heli,[1]];

_man3heli addMPEventHandler ["MPkilled", {Null = _this execVM "addons\SARGE\SAR_aikilled.sqf";}];
_man3heli addMPEventHandler ["MPHit", {Null = _this execVM "addons\SARGE\SAR_aihit.sqf";}];  
[_man3heli] joinSilent _groupheli;

// initialize upsmon for the group

_leaderheli = leader _groupheli;

if(_argc < 3) then {
    null=[_leaderheli,_patrol_area_name,'spawned','nofollow','nowait','aware',"delete:",SAR_DELETE_TIMEOUT] execVM 'addons\UPSMON\scripts\upsmon.sqf';
};

processInitCommands;

if(SAR_DEBUG) then {
    diag_log format["SAR_DEBUG: static AI Heli patrol spawned in: %1",_patrol_area_name];
};

_groupheli;