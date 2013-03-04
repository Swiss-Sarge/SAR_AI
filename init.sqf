// Mission Initialization
startLoadingScreen ["", "RscDisplayLoadCustom"];
cutText ["", "BLACK OUT"];
enableSaving [false, false];

// Variable Initialization
dayZ_instance = 1;
hiveInUse = true;
dayzHiveRequest = [];
initialized = false;
dayz_previousID = 0;

// Settings
player setVariable ["BIS_noCoreConversations", true]; 	// Disable greeting menu
enableRadio false; 									// Disable global chat radio messages

// Compile and call important functions
call compile preprocessFileLineNumbers "\z\addons\dayz_code\init\variables.sqf";
progressLoadingScreen 0.1;
call compile preprocessFileLineNumbers "\z\addons\dayz_code\init\publicEH.sqf";
progressLoadingScreen 0.2;
call compile preprocessFileLineNumbers "\z\addons\dayz_code\medical\setup_functions_med.sqf";
progressLoadingScreen 0.4;
call compile preprocessFileLineNumbers "\z\addons\dayz_code\init\compiles.sqf";
progressLoadingScreen 1.0;

// Set Tonemapping
"Filmic" setToneMappingParams [0.153, 0.357, 0.231, 0.1573, 0.011, 3.750, 6, 4];
setToneMapping "Filmic";

// Run the server monitor
if (isServer) then {
	_serverMonitor = [] execVM "\z\addons\dayz_server\system\server_monitor.sqf";
};

if (!isServer && isNull player) then {
	waitUntil { !isNull player };
	waitUntil { time > 3 };
};

if (!isServer && player != player) then {
	waitUntil { player == player };
	waitUntil { time > 3 };
};

// Run the player monitor
if (!isDedicated) then {
	0 fadeSound 0;
	waitUntil { !isNil "dayz_loadScreenMsg" };
	dayz_loadScreenMsg = (localize "STR_AUTHENTICATING");

	_id = player addEventHandler ["Respawn", { _id = [] spawn player_death; }];
	_playerMonitor = [] execVM "\z\addons\dayz_code\system\player_monitor.sqf";
	
	// #include "gcam\gcam_config.hpp"
	// #include "gcam\gcam_functions.sqf"

	// #ifdef GCAM
		// waitUntil { alive Player };
		// waituntil { !(IsNull (findDisplay 46)) };

		// if (serverCommandAvailable "#kick") then { (findDisplay 46) displayAddEventHandler ["keyDown", "_this call fnc_keyDown"]; };
	// #endif
	
	_null = [] execVM "addons\kh\kh_actions.sqf";
    
    [] execVM "addons\proving_Ground\init.sqf";    
};

[] execVM "addons\R3F_ARTY_AND_LOG\init.sqf";

// UPSMON
call compile preprocessFileLineNumbers "addons\UPSMON\scripts\Init_UPSMON.sqf";
// SHK 
call compile preprocessfile "addons\SHK_pos\shk_pos_init.sqf";
// run SAR_AI
[] execVM "addons\SARGE\SAR_AI_init.sqf";


