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
//  UPSMon  (specific SARGE version)
//  SHK_pos 
//  
// ---------------------------------------------------------------------------------------------------------
//   SAR_vehicle_fix.sqf
//   last modified: 1.4.2013
// ---------------------------------------------------------------------------------------------------------

    private ["_i","_gridwidth","_markername","_triggername","_trig_act_stmnt","_trig_deact_stmnt","_trig_cond","_emptyarr","_pos"];

    if (!isServer) exitWith {}; // only run this on the server
    
    
    // wait until the server has spawned all the vehicles ... might take a while
    // how to figure out IF theae have all been spawned ?
    sleep 15;

    if(SAR_DEBUG) then {diag_log "SAR_DEBUG: Initialized fix for faction vehicle issue.";};

    //[dayz_serverObjectMonitor] call SAR_debug_array;
    
    _i=0;
    _gridwidth = 10;
    _emptyarr = [];
     
    {
    
        if (_x isKindOf "AllVehicles") then { // just do this for vehicles, not other objects like tents
        
            _triggername = format["SAR_veh_trig_%1",_i];

            _this = createTrigger ["EmptyDetector", [0,0]];
            _this setTriggerArea [_gridwidth,_gridwidth, 0, false];
            _this setTriggerActivation ["ANY", "PRESENT", true];
            _this setVariable ["unitlist",[],true];

            Call Compile Format ["SAR_veh_trig_%1 = _this",_i]; 
            
            _trig_act_stmnt = format["[thislist,thisTrigger,'%1'] spawn SAR_AI_veh_trig_on_static;",_triggername];
            _trig_deact_stmnt = format["[thislist,thisTrigger,'%1'] spawn SAR_AI_veh_trig_off;",_triggername];

            _trig_cond = "{(isPlayer _x) && (vehicle _x == _x) } count thisList != count (thisTrigger getVariable['unitlist',[]]);";

            Call Compile Format ["SAR_veh_trig_%1",_i] setTriggerStatements [_trig_cond,_trig_act_stmnt , _trig_deact_stmnt];

            Call Compile Format ["SAR_veh_name_%1 = _x",_i]; 
            Call Compile Format ["SAR_veh_trig_%1",_i] attachTo [Call Compile Format ["SAR_veh_name_%1",_i],[0,0,0]];


            if(SAR_EXTREME_DEBUG) then { // show areamarkers around vehicles

                _markername = format["SAR_mar_trig_%1",_i];

                _pos = getPosASL _x;
                _this = createMarker[_markername,_pos];

                _this setMarkerAlpha 1;
                if (_x isKindOf "Air") then {
                    _this setMarkerShape "ELLIPSE";
                } else {
                    _this setMarkerShape "RECTANGLE";
                };
                _this setMarkerType "Flag";
                _this setMarkerBrush "BORDER";
                _this setMarkerSize [_gridwidth, _gridwidth];
                        
                Call Compile Format ["SAR_testarea_%1 = _this",_i]; 

            };
            
            _i = _i + 1;
        
        };
    
    } foreach dayz_serverObjectMonitor;
    
