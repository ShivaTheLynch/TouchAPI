;;; Nahpui Quarter Chestrunner
Func NahpuiQuarter()

	; Go To Outpost
	MapP()

	; Check, if Gatetrick should be done or not
	If GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $runcounter = 1 Then
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $inventorytrigger = 1 Then
		$inventorytrigger = 0
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_UNCHECKED Then
		MoveTo(9321.39, -15972.73)
		MoveTo(7588.52, -16424.37)
	EndIf

	Out("Exiting Outpost")
	Map_Move(7500, -17200)
	Map_WaitMapLoading($MAP_ID_Farm, 1)

	If Not $RenderingEnabled Then Memory_Clear()

	Sleep(1000)

	Out("Moving to First Chest")
	MoveTo(11052, 11325)
	MoveTo(15698, 9808)
	MoveTo(18937, 6206)
	MoveTo(19188, 5566)
	MoveTo(18635, 2862)
	MoveTo(15743, 2664)
	MoveChestRunning(14787, -3667, 150)
	Chesti()

	Out("Moving to Second Chest")
	MoveChestRunning(13212, -7562, 150)
	MoveChestRunning(12095.14, -10147.38, 150)
	Chesti()

	Out("Moving to Third Chest")
	MoveChestRunning(12571.03, -9803.94, 150)
	MoveChestRunning(13732, -11222, 150)
	Chesti()

	Out("Moving to Fourth Chest")
	MoveChestRunning(17575, -10989, 150)
	Chesti()

	Out("Moving to Fifth Chest")
	MoveChestRunning(20215, -9743, 150)
	MoveChestRunning(19521.98, -6481.84, 150)
	MoveChestRunning(17992.18, -5292.33, 150)
	MoveChestRunning(16450.07, -5795.75, 150)
	MoveChestRunning(16112.64, -3459.31, 150)
	Chesti()

	Out("Moving to Sixth Chest")
	MoveChestRunning(16820.99, -866.09, 150)
	MoveChestRunning(19790.46, 464.61, 150)
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