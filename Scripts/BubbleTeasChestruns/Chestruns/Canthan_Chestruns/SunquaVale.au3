;;; Sunqua Vale Chestrunner
Func SunquaVale()

	; Go To Outpost
	MapP()

	; Check, if Gatetrick should be done or not
	If GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $runcounter = 1 Then
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $inventorytrigger = 1 Then
		$inventorytrigger = 0
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_UNCHECKED Then
		MoveTo(7608.57, -10486.09)
		MoveTo(7153.65, -11060.53)
	EndIf

	Out("Chestrun")
	Map_Move(6950, -11350)
	Map_WaitMapLoading($MAP_ID_Farm, 1)

	If Not $RenderingEnabled Then Memory_Clear()

	Sleep(1000)

	MoveTo(8353.52, 13467.87)
	MoveTo(9352.69, 14057.94)
	MoveTo(13107.26, 13361.19)
	MoveTo(15776.50, 14598.38)
	MoveTo(19231.09, 16088.97)
	MoveTo(21452.07, 15675.11)
	Chesti()
	MoveTo(20066.43, 13899.01)
	MoveTo(21398.15, 12074.62)
	Chesti()
	MoveTo(22531.78, 9377.32)
	MoveTo(21002.93, 8584.08)
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