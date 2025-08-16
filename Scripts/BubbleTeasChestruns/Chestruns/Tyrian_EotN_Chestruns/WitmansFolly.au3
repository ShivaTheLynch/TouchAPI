;;; Witmans Folly Chestrunner
Func WitmansFolly()

	; Go To Outpost
	MapP()

	; Check, if Gatetrick should be done or not
	If GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $runcounter = 1 Then
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $inventorytrigger = 1 Then
		$inventorytrigger = 0
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_UNCHECKED Then
		MoveTo(-7677.35, -4244.82)
		MoveTo(-7448.93, -3142.09)
	EndIf

	Out("Exiting Outpost")
	Map_Move(-7300, -2850)
	Map_WaitMapLoading($MAP_ID_Farm, 1)

	If Not $RenderingEnabled Then Memory_Clear()

	Sleep(1000)	
	
	Out("Moving to First Chest")
	MoveTo(-7059.98, -879.58)
	MoveTo(-4166.59, -331.34)
	MoveTo(-965.44, -943.22)
	MoveChestRunning(2116.98, -3379.03, 150)
	Chesti()

	Out("Moving to Second Chest")
	MoveChestRunning(5691.05, -4668.78, 150)
	MoveChestRunning(8284.40, -3032.31, 150)
	Chesti()

	Out("Moving to Third Chest")
	MoveChestRunning(11210.82, -3691.83, 150)
	MoveChestRunning(13099.51, -2892.30, 150)
	Chesti()
	
	Out("Moving to Fourth Chest")
	MoveChestRunning(15266.50, 79.68, 150)
	Chesti()
	
	Out("Moving to Fifth Chest")
	MoveChestRunning(13275.65, 1424.33)
	MoveChestRunning(9970.30, 358.91, 150)
	MoveChestRunning(7170.44, -388.45, 150)
	MoveChestRunning(5189.41, 2117.26, 150)
	Chesti()
	
	Out("Moving to Sixth Chest")
	MoveChestRunning(5382.09, 5065.80, 150)
	MoveChestRunning(4079.98, 8138.49, 150)
	Chesti()
	
	Out("Moving to Seventh Chest")
	MoveChestRunning(976.62, 7936.79, 150)
	MoveChestRunning(-3054.99, 9505.67, 150)
	Chesti()
	
	If GetIsDead(-2) = True then
		$FailCount += 1
		GUICtrlSetData($FailsLabel, "Fails: " & $FailCount)
	Else
		$SuccessCount += 1
		GUICtrlSetData($SuccessLabel, "Success: " & $SuccessCount)
	EndIf

	$RunCount += 1
	GUICtrlSetData($RunsLabel, "Runs: " & $RunCount)

	$runcounter += 1

	If GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED Then
		Resign()
		Sleep(5000)
		Map_ReturnToOutpost()
		Sleep(2000)
		Map_WaitMapLoading($Town_ID_Farm, 0)
 		;sleep(3000)
	Else
		RndTravel($Town_ID_Farm)
	EndIf
	Memory_Clear()
EndFunc