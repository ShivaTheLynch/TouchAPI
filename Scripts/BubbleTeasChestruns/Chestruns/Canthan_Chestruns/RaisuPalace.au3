;;; Raisu palace Chestrunner
Func RaisuPalace()

	; Go To Outpost
	MapP()

	; Check, if Gatetrick should be done or not
	If GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $runcounter = 1 Then
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $inventorytrigger = 1 Then
		$inventorytrigger = 0
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_UNCHECKED Then
		MoveTo(-10649.69, 1429.27)
		MoveTo(-9600.88, 2222.37)
	Else
		MoveTo(-9600.88, 2222.37)
	EndIf

	Out("Exiting Outpost")
	MoveTo(-9600.88, 2222.37)
	Map_Move(-9600, 2800)
	Map_WaitMapLoading($MAP_ID_Farm, 1)

	If Not $RenderingEnabled Then Memory_Clear()

	Sleep(1000)

	Out("Moving to First Chest")
	MoveTo(24105.58, 5437.72)
	MoveTo(17361.66, 5392.17)
	MoveTo(16557.01, 4392.97)
	MoveChestRunning(13924.84, 4467.73, 150)
	Chesti()
	MoveChestRunning(13924.84, 4467.73, 150)

	Out("Moving to Second Chest")
	MoveChestRunning(14902.34, 6457.39, 150)
	MoveChestRunning(14192.92, 8031.49, 150)
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