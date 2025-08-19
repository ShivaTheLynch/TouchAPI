;;; Peridition Rock Chestrunner
Func PeriditionRock()

	; Go To Outpost
	MapP()

	; Check, if Gatetrick should be done or not
	If GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $runcounter = 1 Then
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $inventorytrigger = 1 Then
		$inventorytrigger = 0
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_UNCHECKED Then
		MoveTo(3714.20, -10109.67)
	EndIf

	Out("Exiting Outpost")
	Map_Move(3900, -8600)
	Map_WaitMapLoading($MAP_ID_Farm, 1)

	If Not $RenderingEnabled Then Memory_Clear()

	Sleep(1000)

	Out("Moving to First Chest")
	MoveChestRunning(6991.92, -7615.11, 150)
	MoveChestRunning(10272.25, -9611.25, 150)
	MoveChestRunning(13845.34, -10043.58, 150)
	MoveChestRunning(15414.71, -9318.02, 150)
	MoveChestRunning(16149.94, -7856.99, 150)
	Chesti()

	Out("Moving to Second Chest")
	MoveChestRunning(16998.13, -5569.30, 150)
	Chesti()

	Out("Moving to Third Chest")
	MoveChestRunning(21130.87, -4836.46, 150)
	MoveChestRunning(24980.70, -4675.71, 150)
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