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
//  Sar_functions - generic functions library
//   last modified: 1.4.2013
// ---------------------------------------------------------------------------------------------------------
SAR_circle = {
//
//
//

    
private ["_center","_defend","_veh","_angle","_dir","_newpos","_forEachIndex","_leader","_action","_grp","_leadername","_pos","_units","_count"];

    _leader = _this select 0;
    _action = _this select 1;

    _grp = group _leader;
    _defend = false;
    
    _leadername = _leader getVariable ["SAR_leader_name",false];

    // suspend UPSMON
    call compile format ["KRON_UPS_%1=2",_leadername];

    _pos = getposASL _leader; 
    //diag_log _pos;

    _pos = (_leader) modelToWorld[0,0,0];
    //diag_log _pos;
    
    if(_action == "defend") then {
        _center = _leader;
        _defend = true;
    };
    
    if(_action == "campfire") then {
        _veh = createvehicle["Land_Campfire_burning",_pos,[],0,"NONE"];
        _center = _veh;
    };
    

    _units = units _grp;
    _count = count _units;
    
    if(_defend) then {
        _angle = 360/(_count-1);
    }else{
        _angle = 360/(_count);
    };
    
    SAR_circle_radius = 10;

    {
        if(_x != _leader || {_x == _leader && !_defend}) then { 
            
            _newpos = (_center modelToWorld [(sin (_forEachIndex * _angle))*SAR_circle_radius, (cos (_forEachIndex *_angle))*SAR_circle_radius, 0]);
            
//            diag_log format["Newpos %1: %2",_foreachindex,_newpos];    

            _x moveTo _newpos;
            _x doMove _newpos;
            while{(_newpos distance (getpos _x)) > 1} do {}; 
           
            //_x doWatch (_veh modelToWorld [(sin (_foreachindex * _angle))*SAR_sit_radius, (cos (_foreachindex * _angle))*SAR_sit_radius, 0]);
            //_x doWatch _veh;

            if(_defend) then {
                _dir = 0;
            }else{
                _dir = 180;
            };
        
            _x setDir ((_foreachIndex * _angle)+ _dir); 

            if(!_defend) then {
                _x playActionNow "SitDown";
                sleep 1;
            };

            _x disableAI "MOVE";
            
        };

    } foreach _units;

    // wait for medic animation to end
    if(_defend) then {
        sleep 10;
    };
    // wait for random campfire time
    if(_action =="campfire") then {
        sleep 60;
        //cleanup campfire        
        deletevehicle _veh;
    };

    {
        _x enableAI "MOVE";
    } foreach _units;
    
    // resume UPSMON
    call compile format ["KRON_UPS_%1=1",_leadername];

};

SAR_fnc_selectRandom = {
    
    private ["_ret"];

    _ret = count _this;           //number of elements in the array
    _ret = floor (random _ret);   //floor it first 
    _ret = _this select _ret;     //get the element, return it
    _ret;
    
};

SAR_isKindOf_weapon = {
// 
// own function because the BiS one does only search vehicle config
//
//
// parameters: 
//              _weapon = the weapon for which we search the parent class
//              _class = class to search for
//
//              return value: true if found, otherwise false
//

    private ["_class","_weapon","_cfg_entry","_found","_search_class"];

    _weapon = _this select 0;
    _class = _this select 1;
    
    _cfg_entry = configFile >> "CfgWeapons" >> _weapon;
    _search_class = configFile >> "CfgWeapons" >> _class;

    _found = false;
    while {isClass _cfg_entry} do
    {
        if (_cfg_entry == _search_class) exitWith { _found = true; };

        _cfg_entry = inheritsFrom _cfg_entry;
    };

    _found;

};


SAR_AI_veh_trig_on_static = {
//
// 
//

    private ["_unit_list","_unitlist","_trigger","_triggername","_player_joined","_player_left","_trig_unitlist","_units_leaving","_player_rating","_clientmachine","_trigger_activator","_forEachIndex"];

    if(!isServer) exitWith {};
    
    if(SAR_EXTREME_DEBUG) then {diag_log "SAR_EXTREME_DEBUG: ----------------------------------Trigger activated, Script started ...------------------------------------------------------- > ";};    
    
    _unit_list = _this select 0;
    _trigger = _this select 1;
    _triggername = _this select 2;
    _unitlist=[];
    _trigger_activator = "";
    
    if(SAR_EXTREME_DEBUG) then {
        {
            if(isPlayer _x) then {
                _trigger_activator = _unit_list select _forEachIndex;
            };
        } foreach _unit_list;
        
        diag_log format["SAR_EXTREME_DEBUG: Trigger -> %1 at %2 was activated by %3!",_triggername,getpos _trigger,_trigger_activator];
    };
    
    
    // remove non players from the trigger unitlist
    {
        if (isPlayer _x) then {
            _unitlist set[count _unitlist,_x]; 
        };
    } foreach _unit_list;
    
    if(SAR_EXTREME_DEBUG) then {[_unitlist] call SAR_debug_array;};
    
    // get the units stored in the trigger variable
    _trig_unitlist = _trigger getVariable["unitlist",[]];
    
    
    // check if a unit left or joined the trigger
    // joined
    if(count _unitlist > count _trig_unitlist) then {

        if(SAR_EXTREME_DEBUG) then {diag_log "SAR_EXTREME_DEBUG: ------------------------------------ Trigger entry start ---------------------------------------------------------------- >";};
        
        //figure out the player that joined
        _player_joined = _unitlist select ((count _unitlist) -1);
        
        if(SAR_EXTREME_DEBUG) then {diag_log format["SAR_EXTREME_DEBUG: Trigger DEBUG: Unit joined, name of joining unit is: %1",_player_joined];};
    
        // if player has negative addrating, store it on player and set to 0
        
        _player_rating = rating _player_joined;

        
        if (_player_rating < 0) then {
        
            // store old rating on the player
            _player_joined setVariable ["SAR_rating",_player_rating,true];
            
            //define global variable
            adjustrating = [_player_joined,(0 - _player_rating)];
            
            // get the players machine ID
            _clientmachine = owner _player_joined;
            
            // transmit the global variable to this client machine
            _clientmachine publicVariableClient "adjustrating";
            
        };

        // add joining player to the trigger list
        _trig_unitlist set [count _trig_unitlist, _player_joined];
        _trigger setVariable ["unitlist",_trig_unitlist,true];
        
        if(SAR_EXTREME_DEBUG) then {diag_log "SAR_EXTREME_DEBUG: ------------------------------------ Trigger entry stop ---------------------------------------------------------------- >";}; 
    
    } else { //  a player left the trigger area

        if(SAR_EXTREME_DEBUG) then {diag_log "SAR_EXTREME_DEBUG: ------------------------------------ Trigger exit start ---------------------------------------------------------------- >";}; 
        
        // figure out which unit left by comparing _unitlist with _trig_unitlist
        _units_leaving =  _trig_unitlist - _unitlist;
        
        _player_left = _units_leaving select 0;
        
        if(SAR_EXTREME_DEBUG) then {diag_log format["SAR_EXTREME_DEBUG: Trigger DEBUG: Unit left, name of leaving unit is: %1",_player_left];};

        // remove the leaving unit from the trigger list by overwriting it with the real triggerlist contents
        if (count _unitlist == 0) then {
            _trigger setVariable ["unitlist",[],true]; 
        } else {
          _trigger setVariable ["unitlist",_unitlist,true]; 
        };
        
        // restore unit rating

        // get old rating from the player
        _player_rating = _player_left getVariable ["SAR_rating",0];
        
        //define global variable
        adjustrating = [_player_left,(0 + _player_rating)];
        
        // get the players machine ID
        _clientmachine = owner _player_left;
        
        // transmit the global variable to this client machine
        _clientmachine publicVariableClient "adjustrating";
        
        if(SAR_EXTREME_DEBUG) then {diag_log "SAR_EXTREME_DEBUG: ------------------------------------ Trigger exit stop ---------------------------------------------------------------- >";};     
    };

    
    if(SAR_EXTREME_DEBUG) then {diag_log "SAR_EXTREME_DEBUG: --------------------------------Trigger activated, Script finished----------------------------------------------------- > ";};    
    
};
SAR_AI_veh_trig_on_static_backup = {
//
// 
//

    private ["_unit_list","_unitlist","_trigger","_triggername","_player_joined","_player_left","_trig_unitlist","_units_leaving","_player_rating","_player_humanity","_bandits_in_trigger","_player_orig_group","_clientmachine","_trigger_activator","_forEachIndex","_dummy"];

    if(!isServer) exitWith {};
    
    if(SAR_EXTREME_DEBUG) then {diag_log "SAR_EXTREME_DEBUG: ----------------------------------Trigger activated, Script started ...------------------------------------------------------- > ";};    
    
    _unit_list = _this select 0;
    _trigger = _this select 1;
    _triggername = _this select 2;
    _unitlist=[];
    _trigger_activator = "";
    
    if(SAR_EXTREME_DEBUG) then {
        {
            if(isPlayer _x) then {
                _trigger_activator = _unit_list select _forEachIndex;
            };
        } foreach _unit_list;
        
        diag_log format["SAR_EXTREME_DEBUG: Trigger -> %1 at %2 was activated by %3!",_triggername,getpos _trigger,_trigger_activator];
        //diag_log format["SAR_EXTREME_DEBUG: count thislist = %1, count getvariable unitlist = %2",{(isPlayer _x) && (vehicle _x == _x) } count _unit_list, count (_trigger getVariable['unitlist',[]])];
    };
    
    
    // remove non players from the trigger unitlist
    {
        if (isPlayer _x) then {
            _unitlist set[count _unitlist,_x]; 
        };
    } foreach _unit_list;
    
    if(SAR_EXTREME_DEBUG) then {[_unitlist] call SAR_debug_array;};
    
    // get the units stored in the trigger variable
    _trig_unitlist = _trigger getVariable["unitlist",[]];
    
    
    // check if a unit left or joined the trigger
    // joined
    if(count _unitlist > count _trig_unitlist) then {

        if(SAR_EXTREME_DEBUG) then {diag_log "SAR_EXTREME_DEBUG: ------------------------------------ Trigger entry start ---------------------------------------------------------------- >";};
        
        //figure out the player that joined
        _player_joined = _unitlist select ((count _unitlist) -1);
        
        if(SAR_EXTREME_DEBUG) then {diag_log format["SAR_EXTREME_DEBUG: Trigger DEBUG: Unit joined, name of joining unit is: %1",_player_joined];};
    
        // if player has negative addrating, store it on player and set to 0
        
        _player_rating = rating _player_joined;

        
        if (_player_rating < 0) then {
        
            // store old rating on the player
            _player_joined setVariable ["SAR_rating",_player_rating,true];
            
            //define global variable
            adjustrating = [_player_joined,(0 - _player_rating)];
            
            // get the players machine ID
            _clientmachine = owner _player_joined;
            
            // transmit the global variable to this client machine
            _clientmachine publicVariableClient "adjustrating";
            
        };

        // save and protect the old groupdata
        // save old group to player
        _player_joined setVariable ["SAR_player_group",group _player_joined,true];
        
        // add a dummy unit into the group to keep it alive
        _dummy = (group _player_joined) createunit ["Rocket_DZ", [2500, 13100, 0], [],0, "FORM"];

        [nil, _dummy, "per", rhideObject, true] call RE;
        [nil, _dummy, "per", rallowDamage, false] call RE;
        _dummy disableAI "FSM";
        _dummy disableAI "ANIM";
        _dummy disableAI "MOVE";
        _dummy disableAI "TARGET";
        _dummy disableAI "AUTOTARGET";
        _dummy setVehicleInit "this setIdentity 'id_SAR';this hideObject true;this allowDamage false;";
        [_dummy] joinSilent (group _player_joined);
        
        diag_log "Joined a dummy unit to the original player group";
        
        
        // set variable to group so it doesnt get cleaned up
        (group _player_joined) setVariable ["SAR_protect",true,true];
        
        // if bandit (humanity check) then switch the activating player and everyone in/close to the vehicle to resistance
        _player_humanity = _player_joined getVariable ["humanity",0];

        if (_player_humanity < SAR_HUMANITY_HOSTILE_LIMIT) then { // player is a bandit
        
            if(count _trig_unitlist > 0) then{ // there are already units in the trigger

                _bandits_in_trigger = [_trig_unitlist] call SAR_AI_is_unfriendly_group;

                if (!_bandits_in_trigger) then { // there are no bandits in the trigger list yet, create the group and add all units in the trigger list to the global resistance group

                    // join all units in the trigger list to that group
                    
                    _trig_unitlist joinSilent SAR_grp_unfriendly;
                     
                    if(SAR_EXTREME_DEBUG) then {diag_log "||||||||||||   A bandit joining created an unfriendly group and switched survivors in the trigger to the global unfriendly group!";};
                
                };

                // join player to global resistance group
                [_player_joined] joinSilent SAR_grp_unfriendly;
                
            } else { // bandit player is the first at the vehicle

                diag_log format["Tried to join %1 to unfriendly group: %2",_player_joined,SAR_grp_unfriendly];
                // join player to global resistance group
                [_player_joined] joinSilent grpNull;
                sleep .5;
                [_player_joined] joinSilent SAR_grp_unfriendly;
                sleep .5;
                diag_log format["Player is now %1, part of group: %2",_player_joined,group _player_joined];

                
            };
        
        } else { // player is a survivor
        
            if(count _trig_unitlist > 1) then{ // there are already units in the trigger
            
                _bandits_in_trigger = [_trig_unitlist] call SAR_AI_is_unfriendly_group;

                if (_bandits_in_trigger) then { // there are bandits in the trigger list, add survivor to the global resistance group

                    // join player to global unfriendly group
                    [_player_joined] joinSilent SAR_grp_unfriendly;
                    
                } else { // the existing group is a survivor group

                    // join player to global friendly group
                    [_player_joined] joinSilent SAR_grp_friendly;
                
                };
            } else { // the survivor is the first at the vehicle

                // join player to global friendly group
                [_player_joined] joinSilent SAR_grp_friendly;
            };
        };

        // add joining player to the trigger list
        _trig_unitlist set [count _trig_unitlist, _player_joined];
        _trigger setVariable ["unitlist",_trig_unitlist,true];
        
        if(SAR_EXTREME_DEBUG) then {diag_log "SAR_EXTREME_DEBUG: ------------------------------------ Trigger entry stop ---------------------------------------------------------------- >";}; 
    
    } else { //  a player left the trigger area

        if(SAR_EXTREME_DEBUG) then {diag_log "SAR_EXTREME_DEBUG: ------------------------------------ Trigger exit start ---------------------------------------------------------------- >";}; 
        
        // figure out which unit left by comparing _unitlist with _trig_unitlist
        _units_leaving =  _trig_unitlist - _unitlist;
        
        _player_left = _units_leaving select 0;
        
        if(SAR_EXTREME_DEBUG) then {diag_log format["SAR_EXTREME_DEBUG: Trigger DEBUG: Unit left, name of leaving unit is: %1",_player_left];};

        // remove the leaving unit from the trigger list by overwriting it with the real triggerlist contents
        if (count _unitlist == 0) then {
            _trigger setVariable ["unitlist",[],true]; 
        } else {
          _trigger setVariable ["unitlist",_unitlist,true]; 
        };

        // if bandit, need to recheck the trigger group if still bandits in there, if not, remove all units from the resistance group
        
        _player_humanity = _player_left getVariable ["humanity",0];

        // restore old group of leaving player
        // load old group from player
        _player_orig_group = _player_left getVariable "SAR_player_group";
        
        // join exiting player to his old group
        [_player_left] joinSilent _player_orig_group;
        
        // remove dummy unit fom group
        {
            if !(isPlayer _x) then {
                deletevehicle _x;
            }
        } foreach units _player_orig_group;

        // remove anti cleanup variable from player group
        _player_orig_group setVariable ["SAR_protect",nil,true];

        
        if (_player_humanity < SAR_HUMANITY_HOSTILE_LIMIT) then { // player is a bandit
            
            if(count _unitlist > 0) then{ // there are still units in the trigger

                // check if there are no bandits anymore in the trigger list
                _bandits_in_trigger = [_unitlist] call SAR_AI_is_unfriendly_group;

                if (!_bandits_in_trigger) then { // no more bandits in the group, remove all of the remaining units from the resistance group and delete the group
                    
                    // move all group members to the global friendly group
                    _unitlist joinSilent SAR_grp_friendly;

                    diag_log "||||||||||||   A leaving bandit switched a trigger unfriendly group to friendly status";
                    
                };
            };
        };
        
        // restore unit rating

        // get old rating from the player
        _player_rating = _player_left getVariable ["SAR_rating",0];
        
        //define global variable
        adjustrating = [_player_left,(0 + _player_rating)];
        
        // get the players machine ID
        _clientmachine = owner _player_left;
        
        // transmit the global variable to this client machine
        _clientmachine publicVariableClient "adjustrating";
        
        if(SAR_EXTREME_DEBUG) then {diag_log "SAR_EXTREME_DEBUG: ------------------------------------ Trigger exit stop ---------------------------------------------------------------- >";};     
    };

    
    if(SAR_EXTREME_DEBUG) then {diag_log "SAR_EXTREME_DEBUG: --------------------------------Trigger activated, Script finished----------------------------------------------------- > ";};    
    
};

SAR_AI_veh_trig_off = {
};

SAR_AI_is_unfriendly_group = {
// parameters
//
// _trig_player_list = list of players in the trigger array

    private ["_trig_player_list","_bandits_in_trigger","_player_humanity"];

    _trig_player_list = _this select 0;

    _bandits_in_trigger = false;
    {
        _player_humanity = _x getVariable ["humanity",0];
    
        if(_player_humanity < SAR_HUMANITY_HOSTILE_LIMIT) then {
            _bandits_in_trigger = true;
        };
    } foreach _trig_player_list;

    _bandits_in_trigger;
};

SAR_debug_array = {

    private ["_array","_foreachIndex"];
    
    _array = _this select 0;

    diag_log " ";    
    diag_log "SAR_DEBUG: Array contents ---------- start -----------";
    diag_log " ";
    
    {
    
        diag_log format["        %1. entry:  %2",_foreachIndex,_x];
    
    } foreach _array;
    
    diag_log " ";
    diag_log "SAR_DEBUG: Array contents ----------- end   ----------";
    diag_log " ";    
};
    
SAR_log = {

    private ["_loglevel","_values","_descs","_logstring","_resultstring","_forEachIndex","_percstring","_finalstring","_resultstring"];
    
    _loglevel = _this select 0;
    _descs = _this select 1;
    _values = _this select 2;

    
    switch (_loglevel) do {
    
        case 0:
        {
            _logstring = "SAR_DEBUG: ";
        };
        case 1:
        {
            _logstring = "SAR_EXTREME_DEBUG: ";
        };
    };
    
    {
        _logstring = _logstring + _descs select _forEachIndex;

        if(_forEachIndex < (count _values) - 1) then {_logstring = _logstring + "|";};        
        
        _resultstring = _resultstring + _values select _forEachIndex;
        
        _percstring = _percstring + "%" + str(_forEachIndex + 1) + " ";
     
        if(_forEachIndex < (count _values) - 1) then {_resultstring = _resultstring + ",";};
    
    } foreach _values;

    _finalstring = "diag_log format[" + _logstring + _percstring +"," + _resultstring + "];";
    
    Call Compile Format ["%1",_finalstring];
};
    

KRON_StrToArray = {
	private ["_in","_arr","_out"];
	_in=_this select 0;
	_arr = toArray(_in);
	_out=[];
	for "_i" from 0 to (count _arr)-1 do {
		_out=_out+[toString([_arr select _i])];
	};
	_out
};

KRON_StrLeft = {
	private["_in","_len","_arr","_out"];
	_in=_this select 0;
	_len=(_this select 1)-1;
	_arr=[_in] call KRON_StrToArray;
	_out="";
	if (_len>=(count _arr)) then {
		_out=_in;
	} else {
		for "_i" from 0 to _len do {
			_out=_out + (_arr select _i);
		};
	};
	_out
};


SAR_unit_loadout_tools = {
// Parameters:
// _unittype (leader, soldier, sniper)
//
// return value: tools array 
//

    private ["_unittype","_unit_tools_list","_unit_tools","_tool","_probability","_chance"];

    _unittype = _this select 0;

    switch (_unittype) do {

        case "leader" :
        {
            _unit_tools_list = SAR_leader_tools;
        };
        case "soldier" :
        {
            _unit_tools_list = SAR_rifleman_tools;
        };
        case "sniper" :
        {
            _unit_tools_list = SAR_sniper_tools;
        };

    };

    _unit_tools = [];
    {
        _tool = _x select 0;
        _probability = _x select 1;
        _chance = (random 100);
        if(_chance < _probability) then {
            _unit_tools set [count _unit_tools, _tool];
        };
    } foreach _unit_tools_list;

    _unit_tools;

};

SAR_unit_loadout_items = {
// Parameters:
// _unittype (leader, soldier, sniper)
//
// return value: items array 
//

    private ["_unittype","_unit_items_list","_unit_items","_item","_probability","_chance"];

    _unittype = _this select 0;

    switch (_unittype) do {

        case "leader" :
        {
            _unit_items_list = SAR_leader_items;
        };
        case "soldier" :
        {
            _unit_items_list = SAR_rifleman_items;
        };
        case "sniper" :
        {
            _unit_items_list = SAR_sniper_items;
        };

    };

    _unit_items = [];
    {
        _item = _x select 0;
        _probability = _x select 1;
        _chance = (random 100);
        if(_chance < _probability) then {
            _unit_items set [count _unit_items, _item];
        };
    } foreach _unit_items_list;

    _unit_items;

};
SAR_unit_loadout_weapons = {
// Parameters:
// _unittype (leader, soldier, sniper)
//
// return value: weapons array 
//

    private ["_unittype","_unit_weapon_list","_unit_pistol_list","_unit_pistol_name","_unit_weapon_name","_unit_weapon_names"];

    _unittype = _this select 0;

    switch (_unittype) do {

        case "leader" :
        {
            _unit_weapon_list = SAR_leader_weapon_list;
            _unit_pistol_list = SAR_leader_pistol_list;
        };
        case "soldier" :
        {
            _unit_weapon_list = SAR_rifleman_weapon_list;
            _unit_pistol_list = SAR_rifleman_pistol_list;
        };
        case "sniper" :
        {
            _unit_weapon_list = SAR_sniper_weapon_list;
            _unit_pistol_list = SAR_sniper_pistol_list;
        };

    };

    // TODO: changed, test
    
    _unit_weapon_names = [];
    _unit_weapon_name = _unit_weapon_list select (floor(random (count _unit_weapon_list)));
    _unit_pistol_name = _unit_pistol_list select (floor(random (count _unit_pistol_list)));
    _unit_weapon_names set [0, _unit_weapon_name];
    _unit_weapon_names set [1, _unit_pistol_name];

    _unit_weapon_names;

};

SAR_unit_loadout = {
// Parameters:
// _unit (Unit to apply the loadout to)
// _weapons (array with weapons for the loadout) 
// _items (array with items for the loadout)
// _tools (array with tools for the loadout)

private ["_unit","_weapons","_weapon","_items","_unit_magazine_name","_item","_tool","_tools","_forEachIndex"];

    _unit = _this select 0;
    _weapons = _this select 1;
    _items = _this select 2;
    _tools = _this select 3;

    removeAllWeapons _unit;
    
    // the above doesnt remove the tools, need this as well
    _unit removeweapon "ItemMap";
    _unit removeweapon "ItemCompass";
    _unit removeweapon "ItemRadio";    

    {
        _weapon = _weapons select _forEachIndex;

        if (_weapon !="") then
        {
            _unit_magazine_name = getArray (configFile >> "CfgWeapons" >> _weapon >> "magazines") select 0;
            _unit addMagazine _unit_magazine_name;
            _unit addWeapon _weapon;
        };
        
    } foreach _weapons;

    {
        _item = _items select _forEachIndex;
        _unit addMagazine _item;
    } foreach _items;

    {
        _tool = _tools select _forEachIndex;
        _unit addWeapon _tool;
    } foreach _tools;

};

SAR_AI_mon_upd = {

// Parameters:
// _typearray (possible values = "max_grps", "rnd_grps", "max_p_grp", "grps_band","grps_sold","grps_surv")
// _valuearray (must be an array)
// _gridname (is the areaname of the grid for this change)

    private ["_typearray","_valuearray","_gridname","_path","_success","_forEachIndex"];

    _typearray = _this select 0;
    _valuearray =_this select 1;
    _gridname = _this select 2;

    _path = [SAR_AI_monitor, _gridname] call BIS_fnc_findNestedElement;

    {

        switch (_x) do 
        {
            case "max_grps":
            {
                _path set [1,1];
            };
            case "rnd_grps":
            {
                _path set [1,2];
            };
            case "max_p_grp":
            {
                _path set [1,3];
            };
            case "grps_band":
            {
                _path set [1,4];
            };
            case "grps_sold":
            {
                _path set [1,5];
            };
            case "grps_surv":
            {
                _path set [1,6];
            };
            
        };
        
        _success = [SAR_AI_monitor, _path, _valuearray select _forEachIndex] call BIS_fnc_setNestedElement;

    }foreach _typearray;

    _success;

    
};
SAR_AI_mon_read = {

// Parameters:
// _typearray (possible values = "max_grps", "rnd_grps", "max_p_grp", "grps_band","grps_sold","grps_surv")
// _gridname (is the areaname of the grid for this change)

    private ["_typearray","_gridname","_path","_resultarray"];

    _typearray = _this select 0;
    _gridname = _this select 1;
    _resultarray=[];

    _path = [SAR_AI_monitor, _gridname] call BIS_fnc_findNestedElement;

    {

        switch (_x) do 
        {
            case "max_grps":
            {
                _path set [1,1];
            };
            case "rnd_grps":
            {
                _path set [1,2];
            };
            case "max_p_grp":
            {
                _path set [1,3];
            };
            case "grps_band":
            {
                _path set [1,4];
            };
            case "grps_sold":
            {
                _path set [1,5];
            };
            case "grps_surv":
            {
                _path set [1,6];
            };
            
        };

        _resultarray set[count _resultarray,[SAR_AI_monitor, _path ] call BIS_fnc_returnNestedElement];

    }foreach _typearray;

    _resultarray;
    
};

SAR_DEBUG_mon = {

    diag_log "--------------------Start of AI monitor values -------------------------";
    {
        diag_log format["SAR EXTREME DEBUG: %1",_x];
    }foreach SAR_AI_monitor;
    
    diag_log "--------------------End of AI monitor values   -------------------------";
};


SAR_fnc_returnConfigEntry = {

	private ["_config", "_entryName","_entry", "_value"];

	_config = _this select 0;
	_entryName = _this select 1;
	_entry = _config >> _entryName;

	//If the entry is not found and we are not yet at the config root, explore the class' parent.
	if (((configName (_config >> _entryName)) == "") && {!((configName _config) in ["CfgVehicles", "CfgWeapons", ""])}) then {
		[inheritsFrom _config, _entryName] call SAR_fnc_returnConfigEntry;
	}
	else { if (isNumber _entry) then { _value = getNumber _entry; } else { if (isText _entry) then { _value = getText _entry; }; }; };
	//Make sure returning 'nil' works.
	if (isNil "_value") exitWith {nil};

	_value;
};

// *WARNING* BIS FUNCTION RIPOFF - Taken from fn_fnc_returnVehicleTurrets and shortened a bit
SAR_fnc_returnVehicleTurrets = {

	private ["_entry","_turrets","_turretIndex"];

	_entry = _this select 0;
	_turrets = [];
	_turretIndex = 0;

	//Explore all turrets and sub-turrets recursively.
	for "_i" from 0 to ((count _entry) - 1) do {
		private ["_subEntry"];
		_subEntry = _entry select _i;
		if (isClass _subEntry) then {
			private ["_hasGunner"];
			_hasGunner = [_subEntry, "hasGunner"] call SAR_fnc_returnConfigEntry;
			//Make sure the entry was found.
			if (!(isNil "_hasGunner")) then {
				if (_hasGunner == 1) then {
					_turrets = _turrets + [_turretIndex];
					//Include sub-turrets, if present.
					if (isClass (_subEntry >> "Turrets")) then { _turrets = _turrets + [[_subEntry >> "Turrets"] call SAR_fnc_returnVehicleTurrets]; }
					else { _turrets = _turrets + [[]]; };
				};
			};
			_turretIndex = _turretIndex + 1;
		};
		sleep 0.01;
	};
	_turrets;
};
