;;; Turais Procession Chestrunner
Func TuraisDesoS()

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
	MoveChestRunning(-1652.92, 12811.41, 150)
	MoveChestRunning(-1685.64, 15297.69, 150)
	Chesti()

	Out("Moving to Second Chest")
	MoveChestRunning(-1150.91, 20215.07, 150)
	MoveChestRunning(2768.71, 18891.67, 150)
	MoveChestRunning(3732.39, 22764.50, 150)
	Chesti()

	Out("Moving to Third Chest")
	MoveChestRunning(7934.12, 23519.37, 150)
	Chesti()

	Out("Moving to Fourth Chest")
	MoveChestRunning(9786.38, 20457.26, 150)
	Chesti()

	Out("Moving to Fifth Chest")
	MoveChestRunning(13386.29, 22962.19, 150)
	Chesti()

	Out("Moving to Sixth Chest")
	MoveChestRunning(15418.39, 17860.92, 150)
	MoveChestRunning(16078.44, 15558.31, 150)
	Chesti()

	Out("Moving to Seventh Chest")
	MoveChestRunning(14673.49, 10193.36, 150)
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