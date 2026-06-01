PROGRAM _INIT
	
    // Access the task interface
    task ACCESS ADR(gFastDemo);

    // Register module config interface for common setup/parametrization functionality
    //fb.MpRecipeRegPar_settings(MpLink := ADR(gSystemSettings), Enable := TRUE , PVName := ADR('gFastDemo.settings'), Category := ADR('FastDemo'));

    // Check for simulator
    //task.IsSimulated := DiagCpuIsSimulated();
  
    // PackML setup
    // =================================================================================================================
    em.Setup.Name := 'FastDemo';
	em.Setup.ParentName := 'Main';
	
END_PROGRAM
	
PROGRAM _CYCLIC
	
    // Access task interface
    // =================================================================================================================
    task ACCESS ADR(gFastDemo);

    // Inputs
    // =================================================================================================================
    IF NOT task.Input.Force THEN

	END_IF
	
	// Issue 1: Multiple recovery points do not work correctly
	// =================================================================================================================
	CASE issue1.state OF
		1:
			fb.TrafficControl.Recover := TRUE;
			IF fb.TrafficControl.RecoverDone THEN
				fb.TrafficControl.Recover := FALSE;
				issue1.state := 2;
			END_IF;
		2:
			fb.TrafficControl.ActivateRecipe := TRUE;
			IF fb.TrafficControl.ActivateRecipeDone THEN
				fb.TrafficControl.ActivateRecipe := FALSE;
				issue1.state := 3;
			END_IF;
		ELSE
			fb.TrafficControl.Recover := FALSE;
			fb.TrafficControl.ActivateRecipe := FALSE;
	END_CASE;
	
	// Issue 2: Wait for command label command does not work correctly
	// =================================================================================================================
	CASE issue2.state OF
		1:
			// Set so that shuttle ID 1 waits for shuttle ID 2 to start its movement with label 255
			issue2.WaitCommandLabel.Execute := TRUE;
			issue2.WaitCommandLabel.Shuttle := ADR(gShuttles.Shuttle[0].Ref);
			issue2.WaitCommandLabel.TriggerXID := gShuttles.Shuttle[1].ID; // Wait for Xbot ID 2
			issue2.WaitCommandLabel.TriggerCmdLb := 255; // Wait for command label number 255
			IF issue2.WaitCommandLabel.Acknowledge THEN
				issue2.WaitCommandLabel.Execute := FALSE;
	  			issue2.state := 10;
			END_IF;
		
		2:
			// Set so that shuttle ID 1 waits for shuttle ID 2 to start its movement with label 255
			issue2.WaitCommandLabel.Execute := TRUE;
			issue2.WaitCommandLabel.Shuttle := ADR(gShuttles.Shuttle[0].Ref);
			issue2.WaitCommandLabel.TriggerXID := gShuttles.Shuttle[1].ID; // Wait for Xbot ID 2
			issue2.WaitCommandLabel.TriggerCmdLb := 256; // Wait for command label number 256
			IF issue2.WaitCommandLabel.Acknowledge THEN
				issue2.WaitCommandLabel.Execute := FALSE;
				issue2.state := 10;
			END_IF;
		
		10:
			// Queue move command for the shuttler ID 1
			issue2.MoveInPlane.Execute := TRUE;
			issue2.MoveInPlane.Shuttle := ADR(gShuttles.Shuttle[0].Ref);
			IF issue2.MoveInPlane.Acknowledge THEN
				issue2.MoveInPlane.Execute := FALSE;
				issue2.state := 11;
			END_IF;
		
		11:
			// Issue move command for the shuttler ID 2 with command label that matches the wait command
			issue2.MoveInPlane.Execute := TRUE;
			issue2.MoveInPlane.CommandLabel := issue2.WaitCommandLabel.TriggerCmdLb;
			issue2.MoveInPlane.Shuttle := ADR(gShuttles.Shuttle[1].Ref);
			IF issue2.MoveInPlane.Acknowledge THEN
				issue2.MoveInPlane.Execute := FALSE;
				issue2.state := 12;
			END_IF;
		ELSE
			issue2.MoveInPlane.Execute := FALSE;
			issue2.WaitCommandLabel.Execute := FALSE;
	END_CASE;
	
	issue2.MoveInPlane.Parameters.Acceleration := 10;
	issue2.MoveInPlane.Parameters.Velocity := 0.1;
	issue2.MoveInPlane.Parameters.Mode := 1; // Relative
	issue2.MoveInPlane.Parameters.Path := 0; // Direct
	issue2.MoveInPlane.Parameters.Position.X := 0;
	issue2.MoveInPlane.Parameters.Position.Y := -0.360;
	issue2.MoveInPlane();
			
	issue2.WaitCommandLabel.LabelType := 0;
	issue2.WaitCommandLabel.TriggerType := 0;
	issue2.WaitCommandLabel();
			
	// Issue 3: Move Async error after group rotate stop
	// =================================================================================================================	
	
	
	// Task state machine
	// =================================================================================================================
	// PackML state machine execution  
	PackML_state_machine;
	
	// Detect state change events
	// =================================================================================================================
	// Record information which state caused abort
	fb.R_TRIG_Abort(CLK := em.Command.Abort);
	
	IF fb.R_TRIG_Abort.Q THEN
		task.Error.State := em.StateCurrent;
		task.Error.SubState := em.SubState;
		task.Error.Description := em.StateInfo; 
	END_IF;
	
	// State change event
	fb.rtStateComplete(CLK := em.Command.StateComplete);
	
	IF fb.rtStateComplete.Q THEN
		em.StateInfo := '';
		brsmemset(ADR(actions_state), 0, SIZEOF(actions_state));
		
		// Record information which state caused abort
		IF em.StateCurrent = STATE_ABORTING THEN
			task.Error.State := local.lastState;
			task.Error.SubState := local.lastSubState;
			task.Error.Description := local.lastStateInfo;
		END_IF;
	END_IF;
		
	// Substate changed event
	IF em.SubState <> local.lastSubState THEN
		em.StateInfo := '';
		brsmemset(ADR(actions_substate), 0, SIZEOF(actions_substate));
		local.lastSubState := em.SubState;
	END_IF;
	
	
	// PackML equipment module
	// =================================================================================================================
	em();

	// Function calls
    // =================================================================================================================
	fb.TrafficControl.Enable := TRUE;
	fb.TrafficControl.MpLink := ADR(TrafficManager_x6d_1); 
//	fb.TrafficControl.ActivateRecipe := actions_substate.traffic_activate_recipe;
//	fb.TrafficControl.DeactivateRecipe := actions_substate.traffic_deactivate_recipe;
//	fb.TrafficControl.ErrorReset := actions_state.error_reset;
//	fb.TrafficControl.Halt := actions_substate.traffic_halt;
//	fb.TrafficControl.Recover := actions_substate.traffic_recover;
//	fb.TrafficControl.Resume := actions_substate.traffic_resume;
//	fb.TrafficControl.Stop := actions_substate.traffic_stop;
	fb.TrafficControl();
	
	fb.TON_RecoverTimeout.IN := fb.TrafficControl.RecoverBuffered;
	fb.TON_RecoverTimeout.PT := T#5s;
	fb.TON_RecoverTimeout();
	
	fb.TrafficMonitor.Enable := TRUE;
	fb.TrafficMonitor.MpLink := ADR(TrafficManager_x6d_1);
	fb.TrafficMonitor();
	
	// Station logic calls
	FOR station_num := 0 TO STATION_COUNT DO
		station ACCESS ADR(stations[station_num]);
		
		station.Enable := actions_state.activate_stations;
		station.Parameters.StationNumber := station_num;
		station.Assembly := ADR(gAssembly6D_Big);
		station.TrafficManager := ADR(TrafficManager_x6d_1);
		station();
	END_FOR
		
	// Task outputs
	// =================================================================================================================
    
	
	// Task diagnostics
	// =================================================================================================================
	gTasks.FastDemo.State := em.StateCurrent;
	gTasks.FastDemo.SubState := em.SubState;
	gTasks.FastDemo.Mode := em.ModeID;
	gTasks.FastDemo.StateComplete := em.Command.StateComplete;
	gTasks.FastDemo.StateInfo := em.StateInfo;
	gTasks.FastDemo.WaitingForTask := em.Info.WaitingFor.Name;
	gTasks.FastDemo.Error := task.Error;

END_PROGRAM
	
PROGRAM _EXIT
	
END_PROGRAM