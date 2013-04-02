// =========================================================================================================
//  SAR_AI - DayZ AI library
//  Version: 1.1.0
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
//   SAR_define.hpp
//   last modified: 15.3.2013
// ---------------------------------------------------------------------------------------------------------
//  
//  Include file to define the identity class that doesnt talk 
//  
//  Sadly no female faces available in Arma
// ------------------------------------------------------------------------------------------------------------
 
 class CfgIdentities {
	class id_SAR {
		name = "Rincewind";
		face = "Face85"; 
		glasses = "None";
		speaker = "NoVoice"; 
		pitch = 1.00;
	};
	class id_SAR_band : id_SAR {
		name = "Cohen the Barbarian";
		face = "Face101"; 
	};
	class id_SAR_sold_lead : id_SAR {
		name = "Sarge";
		face = "Face89"; 
        glasses = "BlackSun";
	};
	class id_SAR_sold_man : id_SAR {
		face = "Face66"; 
	};
	class id_SAR_surv_lead : id_SAR {
		name = "Max Hero";
		face = "Face04_baf";
        glasses = "Sunglasses";        
	};
	class id_SAR_surv_man : id_SAR {
		name = "John Bambi";
		face = "Face02"; 
	};
};