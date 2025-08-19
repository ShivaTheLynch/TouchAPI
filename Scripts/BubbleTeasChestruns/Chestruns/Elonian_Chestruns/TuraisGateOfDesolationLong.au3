;;; Turais Procession Chestrunner
Func TuraisDesoL()

	; Go To Outpost
	MapP()

	; Check, if Gatetrick should be done or not
	If GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $runcounter = 1 Then
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $inventorytrigger = 1 Then
		$inventorytrigger = 0
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_UNCHECKED Then
		MoveTo(1682.36, -2521.67)
        MoveTo(3792.56, -4543.15)
	EndIf

	Out("Exiting Outpost")
	MoveTo(3792.56, -4543.15)
	Map_Move(4800, -5050)
	Map_WaitMapLoading($MAP_ID_Farm, 1)

	If Not $RenderingEnabled Then Memory_Clear()

	Sleep(1000)
	
	Out("Moving to First Chest")
	MoveTo(-12222.70, 22577.54)
	MoveChestRunning(-8768.81, 17268.65, 150)
	MoveChestRunning(-5364.13, 12601.22, 150)
	MoveChestRunning(-1155.05, 10409.19, 150)
	Chesti()

	Out("Moving to Second Chest")
	MoveChestRunning(3895.60, 13869.20, 150)
	Chesti()

	Out("Moving to Third Chest")
	MoveChestRunning(2304.61, 18883.60, 150)
	Chesti()

	Out("Moving to Fourth Chest")
	MoveChestRunning(4663.67, 21326.66, 150)
	Chesti()

	Out("Moving to Fifth Chest")
	MoveChestRunning(10725.02, 21225.60, 150)
	Chesti()

	Out("Moving to Sixth Chest")
	MoveChestRunning(10144.14, 19056.63, 150)
	MoveChestRunning(13622.30, 10227.56, 150)
	Chesti()

	Out("Moving to Seventh Chest")
	MoveChestRunning(14787.16, 9491.88, 150)
	MoveChestRunning(13020.30, 275.58, 150)
	Chesti()

	Out("Moving to Eights Chest")
	MoveChestRunning(7097.31, 1117.24, 150)
	Chesti()

	Out("Moving to Ninth Chest")
	MoveChestRunning(5387.28, 506.08, 150)
	MoveChestRunning(-4501.85, -8028.09, 150)
	Chesti()

	Out("Moving to Tenth Chest")
	MoveChestRunning(-9648.18, -9361.41, 150)
	Chesti()

	Out("Moving to Eleventh Chest")
	MoveChestRunning(-4532.20, -15266.68, 150)
	MoveChestRunning(3886.56, -13822.86, 150)
	Chesti()

	Out("Moving to Twelveth Chest")
	MoveChestRunning(6021.69, -17717.69, 150)
	Chesti()
	
	Out("Moving to Thirteenth Chest")
	MoveChestRunning(11629.96, -10711.52, 150)
	Chesti()
	
	Out("Moving to Fourteenth Chest")
	MoveChestRunning(7360.51, -4672.73, 150)
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