;;; Silent Surf Chestrunner
Func SilentSurf()

	; Go To Outpost
	MapP()

	; Check, if Gatetrick should be done or not
	If GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $runcounter = 1 Then
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $inventorytrigger = 1 Then
		$inventorytrigger = 0
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_UNCHECKED Then
		MoveTo(-11641.05, -20077.12)
		MoveTo(-13455.22, -19615.02)
	EndIf

	Out("Exiting Outpost")
	MoveTo(-13455.22, -19615.02)
	Map_Move(-13900, -20000)
	Map_WaitMapLoading($MAP_ID_Farm, 1)

	If Not $RenderingEnabled Then Memory_Clear()

	Sleep(1000)

	Out("Moving to First Chest")
	MoveTo(12475.11, -182.42)
	MoveTo(9997.63, 789.47)
	MoveChestRunning(7189.77, 4103.46, 150)
	MoveChestRunning(6142.82, 8462.02, 150)
	Chesti()

	Out("Moving to Second Chest")
	MoveChestRunning(2383.54, 10804.03, 150)
	MoveChestRunning(1761.57, 13589.35, 150)
	Chesti()

	Out("Moving to Third Chest")
	MoveChestRunning(-3499.33, 13087.67, 150)
	Chesti()

	Out("Moving to Fourth Chest")
	MoveChestRunning(-4146.84, 9342.29, 150)
	Chesti()

	Out("Moving to Fifth Chest")
	MoveChestRunning(-2702.00, 5254.20, 150)
	Chesti()
	
	Out("Moving to Sixth Chest")
	MoveChestRunning(-2287.42, -895.66, 150)
	Chesti()
	
	Out("Moving to Seventh Chest")
	MoveChestRunning(516.58, -4562.35, 150)
	MoveChestRunning(-3186.89, -7285.65, 15)
	Chesti()
	
	Out("Moving to Eigth Chest")
	MoveChestRunning(-1280.91, -11321.03, 150)
	MoveChestRunning(1287.68, -15351.85, 150)
	Chesti()
	
	Out("Moving to Ninth Chest")
	MoveChestRunning(3636.06, -14666.66, 150)
	MoveChestRunning(8492.75, -16051.75, 150)
	Chesti()
	
	Out("Moving to Tenth Chest")
	MoveChestRunning(7327.14, -11568.19, 150)
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