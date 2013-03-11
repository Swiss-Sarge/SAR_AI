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
// SAR_AI_init.sqf - main init and control file of the framework  
// ---------------------------------------------------------------------------------------------------------

private ["_worldname","_startx","_starty","_gridsize_x","_gridsize_y","_gridwidth","_i","_ii","_markername","_triggername","_trig_act_stmnt","_trig_deact_stmnt","_trig_cond","_check"];

if (!isServer) exitWith {}; // only run this on the server

diag_log "----------------------------------------";
diag_log "Starting SAR_AI server init";
diag_log "----------------------------------------";

// preprocessing relevant scripts

SAR_AI_heli                 = compile preprocessFileLineNumbers "addons\SARGE\SAR_setup_AI_patrol_heli.sqf";
SAR_AI                      = compile preprocessFileLineNumbers "addons\SARGE\SAR_setup_AI_patrol.sqf";

// activate functions library

call compile preprocessFileLineNumbers "addons\SARGE\SAR_functions.sqf";

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
//        These Variables should be checked and set as required
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

// side definitions, better NOT change em

//createCenter civilian;
//createCenter west;
createCenter east;

EAST setFriend [WEST, 0]; 
WEST setFriend [EAST, 0];


// time after which units and groups despawn after players have left the area
SAR_DESPAWN_TIMEOUT = 120; // 2 minutes

// time after which dead AI bodies are deleted
SAR_DELETE_TIMEOUT = 120; 

// Shows extra debug info in .rpt
SAR_DEBUG = true;
publicvariable "SAR_DEBUG";

// careful with setting this, this shows a LOT, including the grid properties and definitions for every spawn and despawn event
SAR_EXTREME_DEBUG = false;
publicvariable "SAR_EXTREME_DEBUG";

// type of soldier lists, only allowed DayZ classes listed. adjust if you run rmod or another map that allows different classes

// military AI
SAR_leader_sold_list = ["Rocket_DZ"];
SAR_sniper_sold_list = ["Sniper1_DZ"];
SAR_soldier_sold_list = ["Soldier1_DZ","Camo1_DZ"];

// bandit AI
SAR_bandit_band_list = ["Bandit1_DZ", "BanditW1_DZ"];

// survivor AI
SAR_leader_surv_list = ["Survivor3_DZ"]; 
SAR_sniper_surv_list = ["Sniper1_DZ"];
SAR_soldier_surv_list = ["Survivor2_DZ","SurvivorW2_DZ","Soldier_Crew_PMC"];

// potential weapon list for leaders
SAR_leader_weapon_list = ["M4A1","M4A3_CCO_EP1","AK_47_M"];

//potential weapon list for riflemen
SAR_rifleman_weapon_list = ["M4A1","M16A2","M4A1_Aim","AK_74","LeeEnfield","M1014"];

//potential weapon list for snipers
SAR_sniper_weapon_list = ["M4A1_Aim","SVD_CAMO","Huntingrifle"];

// define the type of heli you want to use here for the heli patrols
SAR_heli_type="UH1H_DZ";


//-----------------------------------------------------------------------------------------------------------------------------------------------
// Only change things below this line if you REALLY know what you are doing
//-----------------------------------------------------------------------------------------------------------------------------------------------

diag_log format["SAR_AI: Area & Trigger definition Started"];

// Declaring AI monitor array

SAR_AI_monitor = [];

_worldname= toLower format["%1",worldName];

diag_log format["Setting up SAR_AI for : %1",_worldname];

// 
// Setup aremarker & trigger grid - DO NOT CHANGE
//

// default gridvalues
_startx=2500;
_starty=2800;
_gridsize_x=6;
_gridsize_y=6;
_gridwidth = 1000;

//
// get grid configuration for the different maps
//

switch (_worldname) do {
    case "chernarus":
    {
        #include "map_config\SAR_cfg_grid_chernarus.sqf"
    };
    case "tavi":
    {
        #include "map_config\SAR_cfg_grid_tavi.sqf"
    };
    case "namalsk":
    {
        #include "map_config\SAR_cfg_grid_namalsk.sqf"
    };
    case "lingor":
    {
        #include "map_config\SAR_cfg_grid_lingor.sqf"
    };
    case "mbg_celle2":
    {
        #include "map_config\SAR_cfg_grid_mbg_celle2.sqf"
    };
    case "takistan":
    {
        #include "map_config\SAR_cfg_grid_takistan.sqf"
    };
    case "fallujah":
    {
        #include "map_config\SAR_cfg_grid_fallujah.sqf"
    };
    case "panthera":
    {
        #include "map_config\SAR_cfg_grid_panthera.sqf"
    };

};

SAR_area_ = text format ["SAR_area_%1","x"];

for [{_i=0}, {_i < _gridsize_y}, {_i=_i+1}] do
{
    for [{_ii=0}, {_ii < _gridsize_x}, {_ii=_ii+1}] do
    {
    
        _markername = format["SAR_area_%1_%2",_ii,_i];
        
        _this = createMarker[_markername,[_startx + (_ii * _gridwidth * 2),_starty + (_i * _gridwidth * 2)]];
        if(SAR_DEBUG || SAR_EXTREME_DEBUG) then {
            _this setMarkerAlpha 1;
        } else {
            _this setMarkerAlpha 0;
        };
        _this setMarkerShape "RECTANGLE";
        _this setMarkerType "Flag";
        _this setMarkerBrush "BORDER";
        _this setMarkerSize [_gridwidth, _gridwidth];
                
        Call Compile Format ["SAR_area_%1_%2 = _this",_ii,_i]; 
        
        _triggername = format["SAR_trig_%1_%2",_ii,_i];
        
        _this = createTrigger ["EmptyDetector", [_startx + (_ii * _gridwidth * 2),_starty + (_i * _gridwidth * 2)]];
        _this setTriggerArea [_gridwidth, _gridwidth, 0, true];
        _this setTriggerActivation ["ANY", "PRESENT", true];
        
        Call Compile Format ["SAR_trig_%1_%2 = _this",_ii,_i]; 

        _trig_act_stmnt = format["if (SAR_DEBUG) then {diag_log 'SAR DEBUG: trigger on in %1';};[thislist,'%1'] execVM'addons\SARGE\SAR_AI_spawn.sqf';",_triggername];
        _trig_deact_stmnt = format["if (SAR_DEBUG) then {diag_log 'SAR DEBUG: trigger off in %1';};[thislist,thisTrigger,'%1'] execVM'addons\SARGE\SAR_AI_despawn.sqf';",_triggername];
        
        _trig_cond = "{isPlayer _x} count thisList > 0;";
        
        Call Compile Format ["SAR_trig_%1_%2 ",_ii,_i] setTriggerStatements [_trig_cond,_trig_act_stmnt , _trig_deact_stmnt];

        // standard definition - maxgroups (ba,so,su) - probability (ba,so,su) - max group members (ba,so,su)
        SAR_AI_monitor set[count SAR_AI_monitor, [_markername,[1,1,1],[50,30,50],[3,5,3],[],[],[]]];

    };
};

// ----------------------------------------------------------------------------
// end of Setup aremarker & trigger grid - DO NOT CHANGE
// ----------------------------------------------------------------------------

//
// include group & spawn definitions for automatic & static svehicle and infantry pawns
//

switch (_worldname) do {
    case "chernarus":
    {
        #include "map_config\SAR_cfg_grps_chernarus.sqf"
    };
    case "tavi":
    {
        #include "map_config\SAR_cfg_grps_tavi.sqf"
    };
    case "namalsk":
    {
        #include "map_config\SAR_cfg_grps_namalsk.sqf"
    };
    case "lingor":
    {
        #include "map_config\SAR_cfg_grps_lingor.sqf"
    };
    case "mbg_celle2":
    {
        #include "map_config\SAR_cfg_grps_mbg_celle2.sqf"
    };
    case "takistan":
    {
        #include "map_config\SAR_cfg_grps_takistan.sqf"
    };
    case "fallujah":
    {
        #include "map_config\SAR_cfg_grps_fallujah.sqf"
    };
    case "panthera":
    {
        #include "map_config\SAR_cfg_grps_panthera.sqf"
    };
    
};

