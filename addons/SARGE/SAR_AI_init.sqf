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
//  
// ---------------------------------------------------------------------------------------------------------

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

createCenter civilian;
createCenter west;
createCenter east;

EAST setFriend [WEST, 0]; 
WEST setFriend [EAST, 0];


// time after which units and groups despawn after players have left the area
SAR_DESPAWN_TIMEOUT = 120; // 2 minutes

// time after which dead AI bodies are deleted
SAR_DELETE_TIMEOUT = 120; 

// Shows extra debug info in .rpt
SAR_DEBUG = true;

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

SAR_heli_type="UH1H_DZ";

diag_log format["SAR_AI: Area & Trigger definition Started"];

// Declaring AI monitor array

SAR_AI_monitor = [];

diag_log format["Setting up SAR_AI for : %1",worldName];

// 
// Setup aremarker & trigger grid - DO NOT CHANGE
//

//switch (worldname) do {
//    case "chernarus":
//    {
        
        _startx=2500;
        _starty=2800;
        _gridsize_x=6;
        _gridsize_y=6;
        _gridwidth = 1000;
//    };
//};

SAR_area_ = text format ["SAR_area_%1","x"];

for [{_i=0}, {_i < _gridsize_x}, {_i=_i+1}] do
{
    for [{_ii=0}, {_ii < _gridsize_y}, {_ii=_ii+1}] do
    {
    
        _markername = format["SAR_area_%1_%2",_ii,_i];
        
        _this = createMarker[_markername,[_startx + (_ii * _gridwidth * 2),_starty + (_i * _gridwidth * 2)]];
        _this setMarkerAlpha 1;
        _this setMarkerShape "RECTANGLE";
        _this setMarkerType "Flag";
        _this setMarkerBrush "BORDER";
        _this setMarkerSize [_gridwidth, _gridwidth];
        _this setMarkerText format["%1 - %2",_ii,i];
        
        Call Compile Format ["SAR_area_%1_%2 = _this",_ii,_i]; 
        
        _triggername = format["SAR_trig_%1_%2",_ii,_i];
        
        _this = createTrigger ["EmptyDetector", [_startx + (_ii * _gridwidth * 2),_starty + (_i * _gridwidth * 2)]];
        _this setTriggerArea [_gridwidth, _gridwidth, 0, true];
        _this setTriggerActivation ["ANY", "PRESENT", true];
        
        Call Compile Format ["SAR_trig_%1_%2 = _this",_ii,_i]; 

        _trig_act_stmnt = format["if (SAR_DEBUG) then {diag_log 'trigger on';};[thislist,'%1'] execVM'addons\SARGE\SAR_AI_spawn.sqf';",_triggername];
        _trig_deact_stmnt = format["if (SAR_DEBUG) then {diag_log 'trigger off';};[thislist,thisTrigger,'%1'] execVM'addons\SARGE\SAR_AI_despawn.sqf';",_triggername];
        
        _trig_cond = "{isPlayer _x} count thisList > 0;";
        
        Call Compile Format ["SAR_trig_%1_%2 ",_ii,_i] setTriggerStatements [_trig_cond,_trig_act_stmnt , _trig_deact_stmnt];

        
        // standard definition - maxgroups (ba,so,su) - probability (ba,so,su) - max group members (ba,so,su)
        SAR_AI_monitor set[count SAR_AI_monitor, [_markername,[1,1,1],[50,30,50],[3,5,3],[],[],[]]];

    };
};

// 
// end of Setup aremarker & trigger grid - DO NOT CHANGE
//


//
// adjusting the  AI_monitor for some areas
//
// you can edit these values to your liking
//

//switch (worldname) do {
//    case "chernarus":
//    {

        // Kamenka, 0 bandit groups, 0 soldier groups, 2 survivor groups - spawn probability ba,so,su - maximum group members ba,so,su
        _check = [["max_grps","rnd_grps","max_p_grp"],[[0,1,2],[0,75,100],[0,4,3]],"SAR_area_0_0"] call SAR_AI_mon_upd; 

        // Balota, 1 bandit groups, 0 soldier groups, 2 survivor groups - spawn probability ba,so,su - maximum group members ba,so,su
        _check = [["max_grps","rnd_grps","max_p_grp"],[[1,0,2],[80,0,80],[2,0,3]],"SAR_area_1_0"] call SAR_AI_mon_upd; 

        // Cherno, 2 bandit groups, 0 soldier groups, 3 survivor groups - spawn probability ba,so,su - maximum group members ba,so,su
        _check = [["max_grps","rnd_grps","max_p_grp"],[[2,0,3],[75,0,75],[4,0,4]],"SAR_area_2_0"] call SAR_AI_mon_upd; 

        // Prido, 1 bandit groups, 0 soldier groups, 3 survivor groups - spawn probability ba,so,su - maximum group members ba,so,su
        _check = [["max_grps","rnd_grps","max_p_grp"],[[1,0,3],[50,0,50],[4,0,2]],"SAR_area_3_0"] call SAR_AI_mon_upd; 

        // Elektro, 2 bandit groups, 0 soldier groups, 3 survivor groups - spawn probability ba,so,su - maximum group members ba,so,su
        _check = [["max_grps","rnd_grps","max_p_grp"],[[2,0,3],[50,0,50],[4,0,4]],"SAR_area_4_0"] call SAR_AI_mon_upd; 

        // Kamyshovo, 0 bandit groups, 0 soldier groups, 1 survivor groups - spawn probability ba,so,su - maximum group members ba,so,su
        _check = [["max_grps","rnd_grps","max_p_grp"],[[0,0,1],[0,0,80],[0,0,3]],"SAR_area_5_0"] call SAR_AI_mon_upd; 

        // Tulga, 0 bandit groups, 0 soldier groups, 1 survivor groups - spawn probability ba,so,su - maximum group members ba,so,su
        _check = [["max_grps","rnd_grps","max_p_grp"],[[0,0,1],[0,0,80],[0,0,3]],"SAR_area_5_1"] call SAR_AI_mon_upd; 

        // Solni, 1 bandit groups, 0 soldier groups, 0 survivor groups - spawn probability ba,so,su - maximum group members ba,so,su
        _check = [["max_grps","rnd_grps","max_p_grp"],[[1,0,0],[80,0,0],[2,0,0]],"SAR_area_5_2"] call SAR_AI_mon_upd; 

        // Berezino, 0 bandit groups, 0 soldier groups, 3 survivor groups - spawn probability ba,so,su - maximum group members ba,so,su
        _check = [["max_grps","rnd_grps","max_p_grp"],[[0,0,3],[0,0,75],[0,0,3]],"SAR_area_5_3"] call SAR_AI_mon_upd; 

        // Khelm, 1 bandit groups, 0 soldier groups, 1 survivor groups - spawn probability ba,so,su - maximum group members ba,so,su
        _check = [["max_grps","rnd_grps","max_p_grp"],[[1,0,1],[75,0,75],[3,0,3]],"SAR_area_5_4"] call SAR_AI_mon_upd; 

        // NEAF, 0 bandit groups, 3 soldier groups, 1 survivor groups - spawn probability ba,so,su - maximum group members ba,so,su
        _check = [["max_grps","rnd_grps","max_p_grp"],[[0,3,1],[0,50,75],[0,2,4]],"SAR_area_5_5"] call SAR_AI_mon_upd; 

        // NWAF, 0 bandit groups, 2 soldier groups, 1 survivor groups - spawn probability ba,so,su - maximum group members ba,so,su
        _check = [["max_grps","rnd_grps","max_p_grp"],[[0,2,1],[0,50,75],[0,2,4]],"SAR_area_1_4"] call SAR_AI_mon_upd; 

        // Stary, 3 bandit groups, 0 soldier groups, 3 survivor groups - spawn probability ba,so,su - maximum group members ba,so,su
        _check = [["max_grps","rnd_grps","max_p_grp"],[[3,0,3],[50,0,50],[3,0,3]],"SAR_area_2_2"] call SAR_AI_mon_upd; 

        // Devils Castle, 2 bandit groups, 0 soldier groups, 0 survivor groups - spawn probability ba,so,su - maximum group members ba,so,su
        _check = [["max_grps","rnd_grps","max_p_grp"],[[2,0,0],[75,0,0],[3,0,0]],"SAR_area_2_4"] call SAR_AI_mon_upd; 

        // Skalka, 1 bandit groups, 0 soldier groups, 0 survivor groups - spawn probability ba,so,su - maximum group members ba,so,su
        _check = [["max_grps","rnd_grps","max_p_grp"],[[1,0,0],[75,0,0],[3,0,0]],"SAR_area_0_5"] call SAR_AI_mon_upd; 

        // Petrovka1, 2 bandit groups, 0 soldier groups, 0 survivor groups - spawn probability ba,so,su - maximum group members ba,so,su
        _check = [["max_grps","rnd_grps","max_p_grp"],[[2,0,0],[75,0,0],[3,0,0]],"SAR_area_1_5"] call SAR_AI_mon_upd; 

        // Petrovka2, 2 bandit groups, 0 soldier groups, 0 survivor groups - spawn probability ba,so,su - maximum group members ba,so,su
        _check = [["max_grps","rnd_grps","max_p_grp"],[[2,0,0],[75,0,0],[3,0,0]],"SAR_area_2_5"] call SAR_AI_mon_upd; 

        // Pobeda, 2 bandit groups, 0 soldier groups, 0 survivor groups - spawn probability ba,so,su - maximum group members ba,so,su
        _check = [["max_grps","rnd_grps","max_p_grp"],[[2,0,0],[75,0,0],[3,0,0]],"SAR_area_3_5"] call SAR_AI_mon_upd; 

        // Krasno, 0 bandit groups, 1 soldier groups, 1 survivor groups - spawn probability ba,so,su - maximum group members ba,so,su
        _check = [["max_grps","rnd_grps","max_p_grp"],[[0,1,1],[0,75,75],[0,4,2]],"SAR_area_4_5"] call SAR_AI_mon_upd; 
//    };
//};
// areas

//switch (worldname) do {
//    case "chernarus":
//    {
        // soutcoast, heli patrol area
        _this = createMarker ["SAR_patrol_soutcoast", [7997.2837, 2687.6707]];
        _this setMarkerShape "RECTANGLE";
        _this setMarkeralpha 0;
        _this setMarkerType "Flag";
        _this setMarkerBrush "Solid";
        _this setMarkerSize [6500, 1200];
        SAR_marker_helipatrol_southcoast = _this;

        // eastcoast, heli patrol area
        _this = createMarker ["SAR_patrol_eastcoast", [13304.196, 8220.9795]];
        _this setMarkerShape "RECTANGLE";
        _this setMarkeralpha 0;
        _this setMarkerType "Flag";
        _this setMarkerBrush "Solid";
        _this setMarkerSize [1200, 6000];
        SAR_marker_helipatrol_eastcoast = _this;

        // NWAF, heli patrol area
        _this = createMarker ["SAR_patrol_NWAF", [4525.3335, 10292.299]];
        _this setMarkerShape "RECTANGLE";
        _this setMarkeralpha 0;
        _this setMarkerType "Flag";
        _this setMarkerBrush "Solid";
        _this setMarkerSize [1500, 500];
        _this setMarkerDir 59.354115;
        SAR_marker_helipatrol_nwaf = _this;

        // NEAF, heli patrol area
        _this = createMarker ["SAR_AREA_NEAF", [12034.16, 12725.376, 0]];
        _this setMarkerShape "RECTANGLE";
        _this setMarkeralpha 0;
        _this setMarkerType "Flag";
        _this setMarkerBrush "Solid";
        _this setMarkerSize [1000, 600];
        SAR_marker_helipatrol_neaf = _this;


        // SAR DEBUG AREA - at NWAF
        _this = createMarker ["SAR_area_DEBUG", [4525.3335, 10292.299]];
        _this setMarkerShape "RECTANGLE";
        _this setMarkeralpha 0;
        _this setMarkerType "Flag";
        _this setMarkerBrush "Solid";
        _this setMarkerSize [50, 50];
        _this setMarkerDir 59.354115;
        SAR_area_DEBUG = _this;
//    };
//};

diag_log format["SAR_AI: Area & Trigger definition finalized"];


//
// Static, predefined heli patrol areas with friendly military units
//
diag_log format["SAR_AI: Static Spawning for Helicopter patrols started"];

//switch (worldname) do {
//    case "chernarus":
//    {
        //Heli Patrol NWAF
        [SAR_marker_helipatrol_nwaf] call SAR_AI_heli;

        //Heli Patrol NEAF
        [SAR_marker_helipatrol_neaf] call SAR_AI_heli;

        // Heli patrol south coast
        [SAR_marker_helipatrol_southcoast] call SAR_AI_heli;
        [SAR_marker_helipatrol_southcoast] call SAR_AI_heli;

        // heli patrol east coast
        [SAR_marker_helipatrol_eastcoast] call SAR_AI_heli;
        [SAR_marker_helipatrol_eastcoast] call SAR_AI_heli;
//    };
//};

diag_log format["SAR_AI: Static Spawning for Helicopter patrols finished"];


// static spawning of infantry AI

//switch (worldname) do {
//    case "chernarus":
//    {
        // SARGE DEBUG - Debug group
        // military, 0 snipers, 4 riflemen, patrol
        //[SAR_area_DEBUG,1,0,1,""] call SAR_AI;

        // military, 2 snipers, 4 riflemen, patrol
        //[SAR_area_DEBUG,1,0,4,""] call SAR_AI;

        // survivors, 1 snipers, 3 riflemen, patrol
        //[SAR_marker_helipatrol_nwaf,2,1,3,""] call SAR_AI;

        // bandits, 5 snipers, 2 riflemen, patrol
        //[SAR_marker_helipatrol_nwaf,3,5,2,""] call SAR_AI;
//    };
//};

diag_log format["SAR_AI: Static Spawning for infantry patrols finished"];

if(true) exitWith {}; 