SAR_AI
======

SAR AI framework for DayZ 

Version 1.1.0 - This is a MAJOR update!

Changelog:

- Moved all the SAR AI configurations into a single cfg file for easier editing
- Static and dynamic groups can respawn (configurable), weapon and item loadouts are applied
- Items and Tools loadout for every single AI class
- Health of units can be adjusted - get that nearly undestroyable bandit
- Med action added to friendly leaders
- different actions for groups (patrol, ambush, fortify)
- implemented skill system
- included many more configuration options

- FIXED the enemies travelling in the same vehicle issue (that was a badass!)

- included a monitor to check for number of groups and warn if too many AI have been spawned
- dynamic spawning can be enabled/disabled
- use of UPSMON can be enabled/disabled
- groups stealing vehicles can be enabled/disabled

- rewrote the reammo and refuel scripts
- fixed the AI talking in sidechat when being shot at


To update your installation:

- make a backup of your current /addons folder from your missions.pbo!
- copy the new complete addons folder to your mission.pbo
- adjust the server_cleanup.fsm as described below

- check and adjust SAR_config.cfg
- check and adjust your grps_cfg file. 
- The format for heli patrols has changed to:

        [SAR_marker_DEBUG1,1,false] call SAR_AI_heli;
        
- make sure to pay attantion to the "false parameter", this one controls the respawn (true = respawn, false = dont respawn)

- The format for AI infantry patrols has changed to:

        [SAR_marker_DEBUG1,1,0,2,"patrol",false] call SAR_AI;
        
- "patrol" is the action for the group (use "patrol", "fortify" and "ambush"), "false" is the respawn parameter

Version 1.0.3

- Fully configurable logging of bandit or survivor AI kills
- Optimized aggro from friendly fire - one hit is now sufficient to aggro the AI
- Reworked AI heli turret issue - you should no longer see the error message with 2 elements expected, 3 given
- Fixed heli spawn bug
- included functions to query cfg files for turrets (not used atm)
- Included hit Eventhandler for heli - this will only work if you do a decent amount of damage, with a normal weapon this EH will not trigger

Version 1.0.2

Latest changes:

- fixed bug with respawning units in the grids
- implemented configurable humanity system
- some minor fixes for debugging
- implemented version number to track issues reported
- got rid of the AI communication and warning about friendly fire (CHECK INSTALL down below, there was an addition!)


Version 1.0.0

Latest changes:

- moved all the map specific configuration into a seperate folder and corresponding config files. 
- The config files for the grids for Chernarus, Taviana and Namalsk, Lingor and Panthera are adjusted, if you want to run another map, you will need to adjust these values to suit your map.
- The config files for the AI spawns (static and automatic) are empty for all maps except Namalsk, Taviana, Lingor, Panthera and Chernarus. You will need to configure them yourself.

-----------------

quick installation notes:

1) UnPBO your missions.pbo

2) create a folder named ADDONS in there

3) copy SHK_POS, SARGE and UPSMON into that directory

A)
check out the init.sqf file as an example, you will need to add to the end of your init.sqf file the following lines:


       // UPSMON
       call compile preprocessFileLineNumbers "addons\UPSMON\scripts\Init_UPSMON.sqf";

       // SHK 
       call compile preprocessfile "addons\SHK_pos\shk_pos_init.sqf";

       // run SAR_AI
       [] execVM "addons\SARGE\SAR_AI_init.sqf";

A1)
Adjust your description.ext, add the following line at the end:

       #include "addons\SARGE\SAR_define.hpp"
       
A2) Adjust your server_cleanup.fsm file for group cleanups

Check out the server_cleanup.fsm file that is part of this repository. Take it as an EXAMPLE (might differ based on server package that you use)how to adjust yours.

Look for (around line 290)

       "	if ((count units _x==0) ) then {" \n
       "		diag_log (""CLEANUP: DELETING A GROUP: "" + str(_x));" \n

and change the FIRST line to to:

       "	if ((count units _x==0) && !(_x getVariable[""SAR_protect"",false])) then {" \n
       "		diag_log (""CLEANUP: DELETING A GROUP: "" + str(_x));" \n


A2) Adjust your server_cleanup.fsm file for "Killed a hacker" fix


Depends which DayZ version you are running.

The line you are looking for is either:

       "    if  (!(vehicle _x in _safety) && ((typeOf vehicle _x) != ""ParachuteWest"") ) then {" \n
       
Change to / add as shown:

       "    if  (!(vehicle _x in _safety) && ((typeOf vehicle _x) != ""ParachuteWest"") && (vehicle _x getVariable [""Sarge"",0] != 1) ) then {" \n

Or the line looks like

       if(vehicle _x != _x  && !(vehicle _x in _safety) && (typeOf vehicle _x) != ""ParachuteWest"") then {" \n
       
Change that to

       if(vehicle _x != _x && (vehicle _x getVariable [""Sarge"",0] != 1) && !(vehicle _x in _safety) && (typeOf vehicle _x) != ""ParachuteWest"") then {" \n
    
       
B)
While debugging and testing, set

       // Shows extra debug info in .rpt
       SAR_DEBUG = true;

       SAR_EXTREME_DEBUG = true;

       //1=Enable or 0=disable debug. In debug could see a mark positioning de leader and another mark of the destination of movement, very useful for editing mission
       KRON_UPS_Debug = 1;
       
in SAR_config.sqf.

SWITCH ALL OF THESE OFF WHEN YOU GO LIVE!

C)
Test WITHOUT battleeye enabled!
If you are confident that your tests were ok, locate the following lines in your scripts.txt file:

       1 setFuel !"\"setFuel\"," !"z\addons\dayz_code\compile\local_setFuel.sqf" !"\"dayzSetFuel\"" !"if (_fuel >= 1.0) then { _fuel = 1.0; };\n\n_target setFuel _fuel;" !

change this to

       1 setFuel !"\"setFuel\"," !"z\addons\dayz_code\compile\local_setFuel.sqf" !"\"dayzSetFuel\"" !"if (_fuel >= 1.0) then { _fuel = 1.0; };\n\n_target setFuel _fuel;" !"_vehicle setFuel 1;\nif (SAR_EXTREME_DEBUG) then {diag_log "SAR_EXTREME_DEBUG: Vehicle refueled";};"

locate this line:

       5 setVehicleAmmo !"\"setVehicleAmmo\"," 

change to

       5 setVehicleAmmo !"\"setVehicleAmmo\"," !"_vehicle setVehicleAmmo 1;\nif (SAR_EXTREME_DEBUG) then {diag_log "SAR EXTREME DEBUG: Vehicle new ammo";};"

this might vary with your DayzMap and might get updated by Battleye, i recommend to UNDERSTAND how battleeye filters work,
so in case you need to adjust them, you are able to.

       
       
       
