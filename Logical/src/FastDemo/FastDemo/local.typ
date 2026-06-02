
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
	Issue3Type : 	STRUCT 
		state : USINT;
		DoNotRotateBack : BOOL;
		MoveInPlaneAsync : MC_BR_MoveInPlaneAsync_Acp6D;
		MoveInPlane : MC_BR_MoveInPlane_Acp6D;
		GroupCreate : MC_BR_ShGroupCreate_Acp6D;
		GroupDelete : MC_BR_ShGroupDelete_Acp6D;
		GroupAddShuttle : MC_BR_ShGroupAddShuttle_Acp6D;
		GroupCoupleCtrl : MC_BR_ShGroupCoupleCtrl_Acp6D;
		MoveStop : MC_BR_AsmStop_Acp6D;
		MoveShortAxis : MC_BR_MoveShortAxis_Acp6D;
		ShuttleGroup : Mc6DShuttleGroupType;
	END_STRUCT;
END_TYPE
