SAR_AI
======

SAR AI framework for DayZ

quick notes:

UnPBO your missions.pbo
create a folder named ADDONS in there
copy SHK_POS, SARGE and UPSMON into that directory

A)
check out the init.sqf file as an example, you will need to add to the end of your init.sqf file the following lines:

// UPSMON
call compile preprocessFileLineNumbers "addons\UPSMON\scripts\Init_UPSMON.sqf";
// SHK 
call compile preprocessfile "addons\SHK_pos\shk_pos_init.sqf";
// run SAR_AI
[] execVM "addons\SARGE\SAR_AI_init.sqf";


B)
While debugging and testing, set

// Shows extra debug info in .rpt
SAR_DEBUG = true;

in SAR_AI_init.sqf, and

//1=Enable or 0=disable debug. In debug could see a mark positioning de leader and another mark of the destination of movement, very useful for editing mission
KRON_UPS_Debug = 1;

in Init_UPSMON.sqf

C)
Test WITHOUT battleeye enabled!
If you are confident that your tests were ok, locate the following lines in your scripts.txt file:

1 setFuel !"\"setFuel\"," !"z\addons\dayz_code\compile\local_setFuel.sqf" !"\"dayzSetFuel\"" !"if (_fuel >= 1.0) then { _fuel = 1.0; };\n\n_target setFuel _fuel;" !

change this to

1 setFuel !"\"setFuel\"," !"z\addons\dayz_code\compile\local_setFuel.sqf" !"\"dayzSetFuel\"" !"if (_fuel >= 1.0) then { _fuel = 1.0; };\n\n_target setFuel _fuel;" !"_vehicle setFuel 1;\nif (SAR_DEBUG) then {diag_log \"Vehicle refueled\";};"

locate this line:

5 setVehicleAmmo !"\"setVehicleAmmo\"," 

change to

5 setVehicleAmmo !"\"setVehicleAmmo\"," !"_vehicle setVehicleAmmo 1;\nif (SAR_DEBUG) then {diag_log \"Vehicle new ammo\";};"

this might vary with your DayzMap and might get updated by Battleye, i recommend to UNDERSTAND how battleeye filters work,
so in case you need to adjust them, you are able to.

