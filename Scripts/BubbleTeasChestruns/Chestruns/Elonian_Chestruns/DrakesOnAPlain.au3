;;; Drakes on A Plain Chestrunner
Func DrakesOnAPlain()
	
	; Go To Outpost
	MapP()

	; Check, if Gatetrick should be done or not
	If GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $runcounter = 1 Then
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $inventorytrigger = 1 Then
		$inventorytrigger = 0
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_UNCHECKED Then
		MoveTo(-15658.72, 9592.68)
	EndIf

	Out("Exiting Outpost")
	MoveTo(-15658.72, 9592.68)
	Map_Move(-15100, 8950)
	Map_WaitMapLoading($MAP_ID_Farm, 1)

	If Not $RenderingEnabled Then Memory_Clear()

	Sleep(1000)

	Out("Moving to First Chest")
	MoveTo(-14286.53, 7992.65)
	MoveChestRunning(-11928.36, 9910.87,150)
	MoveChestRunning(-8679.77, 12026.01, 150)
	MoveChestRunning(-7065.16, 12285.43, 150)
	MoveChestRunning(-4039.85, 15060.82, 150)
	MoveChestRunning(-1873.41, 14060.86, 150)
	MoveChestRunning(-546.80, 12962.23, 150)
	Chesti()

	Out("Moving to Second Chest")
	MoveChestRunning(2749.33, 14798.70, 150)
	Chesti()

	Out("Moving to Third Chest")
	MoveChestRunning(5637.75, 15874.90, 150)
	MoveChestRunning(7493.40, 15645.57, 150)
	MoveChestRunning(8767.18, 14123.64, 150)
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
		ReturnToOutpost()
		Sleep(2000)
		WaitMapLoading($Town_ID_Farm)
 		;sleep(3000)
	Else
		RndTravel($Town_ID_Farm)
	EndIf
	ClearMemory()
EndFunc