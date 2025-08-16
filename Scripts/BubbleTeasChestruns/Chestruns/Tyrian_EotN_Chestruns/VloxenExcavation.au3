;;; Vloxen Excavation Chestrunner
Func VloxenExcavation()

	; Go To Outpost
	MapP()

	; Check, if Gatetrick should be done or not
	If GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $runcounter = 1 Then
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $inventorytrigger = 1 Then
		$inventorytrigger = 0
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_UNCHECKED Then
		MoveTo(19411.82, 19168.73)
	EndIf

    Out("Exiting Outpost")
	MoveTo(19411.82, 19168.73)
    Map_Move(19750, 19600)
	Map_WaitMapLoading($MAP_ID_Farm, 1)

	If Not $RenderingEnabled Then Memory_Clear()

	Sleep(1000)

	Out("Moving to First Chest")
	MoveChestRunning(-13348, -10239, 200)
	MoveChestRunning(-9202, -10419, 200)
	MoveChestRunning(-6660, -10867, 200)
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