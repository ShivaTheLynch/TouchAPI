;;; Diviners Ascent Chestrunner

Func DivinersAscent()

	; Go To Outpost
	MapP()

	; Check, if Gatetrick should be done or not
	If GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $runcounter = 1 Then
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $inventorytrigger = 1 Then
		$inventorytrigger = 0
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_UNCHECKED Then
		MoveTo(16419.89, 6899.07)
	EndIf

	Out("Exiting Outpost")	
	Map_Move(17150, 6900)
	Map_WaitMapLoading($MAP_ID_Farm, 1)

	If Not $RenderingEnabled Then Memory_Clear()

	Sleep(1000)

	Out("Moving to First Chest")
	MoveChestRunning(-4491.34, 5411.49, 150)
	MoveChestRunning(-1943.97, 6759.21, 150)
	MoveChestRunning(795.77, 9587.64, 150)
	Chesti()
	
	Out("Moving to Second Chest")
	MoveChestRunning(1422.05, 12789.95, 150)
	MoveChestRunning(2259.45, 15246.39, 150)
	Chesti()
	
	Out("Moving to Third Chest")
	MoveChestRunning(5908.77, 14511.10, 150)
	MoveChestRunning(8427.39, 12488.84, 150)
	Chesti()
	
	Out("Moving to Fourth Chest")
	MoveChestRunning(14050.67, 8954.54, 150)
	Chesti()
	
	Out("Moving to Fifth Chest")
	MoveChestRunning(16248.08, 7441.82, 150)
	Chesti()

	Out("Moving to Sixth Chest")
	MoveChestRunning(14777.55, 4526.17, 150)
	MoveChestRunning(13837.93, 2976.12, 150)
	Chesti()

	Out("Moving to Seventh Chest")
	MoveChestRunning(9802.72, 1131.69, 150)
	MoveChestRunning(7298.45, 253.40, 150)
	Chesti()

	Out("Moving to Eigth Chest")
	MoveChestRunning(10745.39, -4966.42, 150)
	MoveChestRunning(15547.09, -7798.31, 150)
	Chesti()

	Out("Moving to Ninth Chest")
	MoveChestRunning(12713.16, -8773.57, 150)
	MoveChestRunning(9759.91, -9604.83, 150)
	Chesti()

	Out("Moving to Tenth Chest")
	MoveChestRunning(4950.75, -12005.04, 150)
	Chesti()

	Out("Moving to Eleventh Chest")
	MoveChestRunning(2578.01, -6418.29, 150)
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