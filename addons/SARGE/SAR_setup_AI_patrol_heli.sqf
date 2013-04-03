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
//   SAR_setup_AI_patrol_heli.sqf
//   last modified: 1.4.2013
// ---------------------------------------------------------------------------------------------------------


private ["_riflemenlist","_side","_leader_group","_initstring","_patrol_area_name","_rndpos","_groupheli","_heli","_leaderheli","_man2heli","_man3heli","_argc","_tracewhat","_grouptype","_respawn","_leader_weapon_names","_leader_items","_leader_tools","_soldier_weapon_names","_soldier_items","_soldier_tools","_leaderskills","_sniperskills","_ups_para_list"];

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
            _side = SAR_AI_friendly_side;
            _leader_group = SAR_leader_sold_list call BIS_fnc_selectRandom;
            _riflemenlist = SAR_soldier_sold_list;
            _tracewhat = ['CAManBase'];
            _initstring = format["null = [this,%1] execVM 'addons\SARGE\SAR_trace_from_vehicle.sqf';this setIdentity 'id_SAR_sold_man';",_tracewhat];
            
            _leaderskills = SAR_leader_sold_skills;
            _sniperskills = SAR_sniper_sold_skills;

        };
        case 2: // survivors
        {
            _side = SAR_AI_friendly_side;
            _leader_group = SAR_leader_surv_list call BIS_fnc_selectRandom;
            _riflemenlist = SAR_soldier_surv_list;
            _tracewhat = ['CAManBase'];
            _initstring = format["null = [this,%1] execVM 'addons\SARGE\SAR_trace_from_vehicle.sqf';this setIdentity 'id_SAR_surv_lead';",_tracewhat];
            
            _leaderskills = SAR_leader_surv_skills;
            _sniperskills = SAR_sniper_surv_skills;

        };
        case 3: // bandits
        {
            _side = SAR_AI_unfriendly_side;
            _leader_group = SAR_leader_band_list call BIS_fnc_selectRandom;
            _riflemenlist = SAR_soldier_band_list;
            _tracewhat=['CAManBase'];
            _initstring = format["null = [this,%1] execVM 'addons\SARGE\SAR_trace_from_vehicle.sqf';this setIdentity 'id_SAR_band';",_tracewhat];

            _leaderskills = SAR_leader_band_skills;
            _sniperskills = SAR_sniper_band_skills;
            
        };
        default
        {
            _side = SAR_AI_friendly_side;
            _leader_group = SAR_leader_sold_list call BIS_fnc_selectRandom;
            _riflemenlist = SAR_soldier_sold_list;
            _tracewhat = ['CAManBase'];
            _initstring = format["null = [this,%1] execVM 'addons\SARGE\SAR_trace_from_vehicle.sqf';this setIdentity 'id_SAR_band';",_tracewhat];

            _leaderskills = SAR_leader_sold_skills;
            _sniperskills = SAR_sniper_sold_skills;

        };
    };

} else {
    _side = SAR_AI_friendly_side;
    _leader_group = SAR_leader_sold_list call BIS_fnc_selectRandom;
    _riflemenlist = SAR_soldier_sold_list;
    _tracewhat = ['CAManBase'];
    _initstring = format["null = [this,%1] execVM 'addons\SARGE\SAR_trace_from_vehicle.sqf';this setIdentity 'id_SAR_band';",_tracewhat];

    _leaderskills = SAR_leader_sold_skills;
    _sniperskills = SAR_sniper_sold_skills;

};

if (_argc >2) then {
    _respawn = _this select 2;
} else {
    _respawn = false;
};

_leader_weapon_names = ["leader"] call SAR_unit_loadout_weapons;
_leader_items = ["leader"] call SAR_unit_loadout_items;
_leader_tools = ["leader"] call SAR_unit_loadout_tools;

_soldier_weapon_names = ["soldier"] call SAR_unit_loadout_weapons;
_soldier_items = ["soldier"] call SAR_unit_loadout_items;
_soldier_tools = ["soldier"] call SAR_unit_loadout_tools;

// get a random starting position that is on land
_rndpos = [_patrol_area_name] call SHK_pos;

_groupheli = createGroup _side;

// protect group from being deleted by DayZ
_groupheli setVariable ["SAR_protect",true,true];

// create the vehicle
_heli = createVehicle [(SAR_heli_type call BIS_fnc_selectRandom), [(_rndpos select 0) + 10, _rndpos select 1, 80], [], 0, "FLY"];
_heli setFuel 1;

_heli setVariable ["Sarge",1,true];
_heli engineon true; 
//_heli allowDamage false;
_heli setVehicleAmmo 1;

//_heli addEventHandler ["HandleDamage", {returnvalue = _this execVM "addons\SARGE\SAR_ai_vehicle_hit.sqf";}];  
_heli addMPEventHandler ["MPHit", {Null = _this execVM "addons\SARGE\SAR_aihit.sqf";}];  

[_heli] joinSilent _groupheli;

//
// Get turret config ... this is mega buggy from a BI side - might use it later if we generalize the vehicles used
//

/* diag_log typeof _heli;

_cfg = [configFile >> "CfgVehicles" >> typeOf _heli >> "turrets"] call SAR_fnc_returnVehicleTurrets;

_cfg = getArray (configFile >> "CfgVehicles" >> typeof _heli >> "Turrets");
_tc = count _cfg;

{ diag_log format["SAR_DEBUG: %1",_cfg select _forEachIndex];}foreach _cfg;

diag_log "_____________";

for [{_i=0}, {_i < _tc}, {_i=_i+1}] do
{
    diag_log format["SAR_DEBUG: Array %1: %2",_i, _cfg select _i];
};

if (_tc>0) then {
    _mtc = count _cfg; // number of main turrets
    _out = _out + format["Main Turrets: %1\n",count _cfg];
    
    for "_mti" from 0 to _mtc-1 do {
        _mt = (_cfg select _mti);
        _st = _mt >> "turrets";
        _stc = count _st; // sub-turrets in current main one
        _out = _out + format["Turret #%1, %2: [%1]\n",_mti,configName(_mt)];
        _weaps = getArray(_mt >> "weapons");
        _out = _out + format[" Weapons:\n"];
        {_out = _out + format["  %1\n",_x]}forEach _weaps;
        for "_sti" from 0 to _stc-1 do {
            _stp = (_st select _sti);
            _out = _out + format["Turret #%1, %2: [%1,%3]\n",_mti,configName(_stp),_sti];
            _weaps = getArray(_stp >> "weapons");
            _out = _out + format[" Weapons:\n"];
            {_out = _out + format["  %1\n",_x]}forEach _weaps;
        };
    };
} else {
    _out = "SAR_DEBUG: Turret config not found";
};

diag_log format["SAR_DEBUG: Turrets: %1, _tc=%2",_out,_tc];
 */
//
//
//


// create ppl in it
_leaderheli = _groupheli createunit [_leader_group, [(_rndpos select 0) + 10, _rndpos select 1, 0], [], 0.5, "NONE"];

[_leaderheli,_leader_weapon_names,_leader_items,_leader_tools] call SAR_unit_loadout;

_leaderheli setVehicleInit _initstring;
_leaderheli addMPEventHandler ["MPkilled", {Null = _this execVM "addons\SARGE\SAR_aikilled.sqf";}];
_leaderheli addMPEventHandler ["MPHit", {Null = _this execVM "addons\SARGE\SAR_aihit.sqf";}];  
_leaderheli addEventHandler ["HandleDamage",{if (_this select 1!="") then {_unit=_this select 0;damage _unit+((_this select 2)-damage _unit)*SAR_leader_health_factor}}];

_leaderheli action ["getInPilot", _heli];
[_leaderheli] joinSilent _groupheli;

// set skills of the leader
{
    _leaderheli setskill [_x select 0,(_x select 1 +(floor(random 2) * (_x select 2)))];
} foreach _leaderskills;



// SARGE - include loop for available turret positions

//Support
_man2heli = _groupheli createunit [_riflemenlist call BIS_fnc_selectRandom, [(_rndpos select 0) - 30, _rndpos select 1, 0], [], 0.5, "NONE"];

[_man2heli,_soldier_weapon_names,_soldier_items,_soldier_tools] call SAR_unit_loadout;

//_man2heli action ["getInTurret", _heli,[0]];
_man2heli moveInTurret [_heli,[0]];

_man2heli setVehicleInit _initstring;
_man2heli addMPEventHandler ["MPkilled", {Null = _this execVM "addons\SARGE\SAR_aikilled.sqf";}];
_man2heli addMPEventHandler ["MPHit", {Null = _this execVM "addons\SARGE\SAR_aihit.sqf";}];  
[_man2heli] joinSilent _groupheli;

// set skills 
{
    _man2heli setskill [_x select 0,(_x select 1 +(floor(random 2) * (_x select 2)))];
} foreach _sniperskills;


//Rifleman
_man3heli = _groupheli createunit [_riflemenlist call BIS_fnc_selectRandom, [_rndpos select 0, (_rndpos select 1) + 30, 0], [], 0.5, "NONE"];

[_man3heli,_soldier_weapon_names,_soldier_items,_soldier_tools] call SAR_unit_loadout;

_man3heli setVehicleInit _initstring;

//_man3heli action ["getInTurret", _heli,[1]];
_man3heli moveInTurret [_heli,[1]];

_man3heli addMPEventHandler ["MPkilled", {Null = _this execVM "addons\SARGE\SAR_aikilled.sqf";}];
_man3heli addMPEventHandler ["MPHit", {Null = _this execVM "addons\SARGE\SAR_aihit.sqf";}];  
[_man3heli] joinSilent _groupheli;

// set skills 
{
    _man3heli setskill [_x select 0,(_x select 1 +(floor(random 2) * (_x select 2)))];
} foreach _sniperskills;

// initialize upsmon for the group

_leaderheli = leader _groupheli;

_ups_para_list = [_leaderheli,_patrol_area_name,'nowait','nofollow','aware','showmarker','delete:',SAR_DELETE_TIMEOUT];

if (_respawn) then {
    _ups_para_list = _ups_para_list + ['respawn'];
};

_ups_para_list execVM 'addons\UPSMON\scripts\upsmon.sqf';

processInitCommands;

if(SAR_EXTREME_DEBUG) then {
    diag_log format["SAR_EXTREME_DEBUG: AI Heli patrol spawned in: %1",_patrol_area_name];
};

_groupheli;