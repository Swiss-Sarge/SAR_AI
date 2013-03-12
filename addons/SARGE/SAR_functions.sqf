// =========================================================================================================
//  SAR_AI - DayZ AI library
//  Version: 1.0.2 
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
//  Sar_functions - generic functions library
// ---------------------------------------------------------------------------------------------------------

SAR_AI_mon_upd = {

// Parameters:
// _typearray (possible values = "max_grps", "rnd_grps", "max_p_grp", "grps_band","grps_sold","grps_surv")
// _valuearray (must be an array)
// _gridname (is the areaname of the grid for this change)

    private ["_typearray","_valuearray","_gridname","_path","_success"];

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

        //diag_log _path;
        
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

