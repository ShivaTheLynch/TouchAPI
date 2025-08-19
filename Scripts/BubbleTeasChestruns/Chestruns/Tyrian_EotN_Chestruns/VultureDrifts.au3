;;; Vulture Drifts Chestrunner
Func VultureDrifts()

	; Go To Outpost
	MapP()

	; Check, if Gatetrick should be done or not
	If GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $runcounter = 1 Then
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $inventorytrigger = 1 Then
		$inventorytrigger = 0
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_UNCHECKED Then
		MoveTo(10970.89, 7051.34)
	EndIf

	Out("Exiting Outpost")
	Map_Move(10550, 5950)
	Map_WaitMapLoading($MAP_ID_Farm, 1)

	If Not $RenderingEnabled Then Memory_Clear()

	Sleep(1000)

	Out("Moving to First Chest")
	MoveChestRunning(-4481.77, -13588.10, 150)
	MoveChestRunning(-3932.54, -14450.17, 150)
	MoveChestRunning(-2016.85, -14063.14, 150)
	MoveChestRunning(692.10, -10787.57, 150)
	MoveChestRunning(758.98, -7909.04, 150)
	MoveChestRunning(-1411.78, -7140.69, 150)
	MoveChestRunning(-3409.01, -4632.19, 150)
	MoveChestRunning(1672.77, -5209.68, 150)
	MoveChestRunning(3727.48, -3590.20, 150)
	Chesti()

	Out("Moving to Second Chest")
	MoveChestRunning(233.02, -1021.68, 150)
	Chesti()

	Out("Moving to Third Chest")
	MoveChestRunning(869.44, 3066.57, 150)
	Chesti()

	Out("Moving to Fourth Chest")
	MoveChestRunning(4618.20, 10094.88, 150)
	Chesti()

	Out("Moving to Fifth Chest")
	MoveChestRunning(138.79, 9544.01, 150)
	MoveChestRunning(-2329.99, 8458.53, 150)
	Chesti()

	Out("Moving to Sixth Chest")
	MoveChestRunning(-4477.46, 11204.79, 150)
	Chesti()

	Out("Moving to Seventh Chest")
	MoveChestRunning(-5925.90, 8904.14, 150)
	MoveChestRunning(-9530.39, 9506.81, 150)
	MoveChestRunning(-10500, 9506.81, 150)
	Chesti()

	Out("Moving to Eights Chest")
	MoveChestRunning(-14686.75, 9669.45, 150)
	Chesti()

	Out("Moving to Ninths Chest")
	MoveChestRunning(-16968.33, 7645.15, 150)
	MoveChestRunning(-19075.90, 10298.95, 150)
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