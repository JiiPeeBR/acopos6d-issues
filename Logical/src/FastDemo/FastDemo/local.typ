
TYPE
	FastDemoFbType : 	STRUCT 
		MpRecipeRegPar_settings : BOOL;
		TrafficControl : MpTrafficControl;
		TrafficMonitor : MpTrafficMonitor;
		rtStateComplete : R_TRIG;
		R_TRIG_Abort : R_TRIG;
		TON_RecoverTimeout : TON;
	END_STRUCT;
	FastDemoLocalType : 	STRUCT 
		lastState : DINT;
		lastSubState : DINT;
		lastStateInfo : STRING[80];
		allStationsDeactivated : BOOL;
	END_STRUCT;
	FastDemoActionsStateType : 	STRUCT 
		error_reset : BOOL;
		activate_stations : BOOL;
	END_STRUCT;
	FastDemoActionsSubstateType : 	STRUCT 
		traffic_activate_recipe : BOOL; (*Task actions are not automatically reset*)
		traffic_deactivate_recipe : BOOL; (*Task actions are not automatically reset*)
		traffic_halt : BOOL;
		traffic_recover : BOOL;
		traffic_resume : BOOL;
		traffic_stop : BOOL;
	END_STRUCT;
	FastDemoHmiType : 	STRUCT 
		isRunning : BOOL;
	END_STRUCT;
END_TYPE

(*Insert your comment here.*)

TYPE
	Issue1Type : 	STRUCT 
		state : USINT;
	END_STRUCT;
	Issue2Type : 	STRUCT 
		state : USINT;
		MoveInPlane : MC_BR_MoveInPlane_Acp6D;
		WaitCommandLabel : MC_BR_ShWaitCmdLb_Acp6D;
	END_STRUCT;
END_TYPE
