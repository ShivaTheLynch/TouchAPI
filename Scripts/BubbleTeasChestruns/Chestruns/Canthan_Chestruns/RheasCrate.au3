;;; Rheas Crate Chestrunner
; No Resurrection Skills allowed -> you need to die and get resurrected from shrine
; Need more Points of opposing faction of Seafarers Rest
Func RheasCrate()

	; Go To Outpost
	MapP()

	; Check, if Gatetrick should be done or not
	If GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $runcounter = 1 Then
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $inventorytrigger = 1 Then
		$inventorytrigger = 0
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_UNCHECKED Then
		MoveTo(-11517.93, -20599.38)
		MoveTo(-11772.14, -19926.49)
	EndIf

	Out("Exiting Outpost")
	Map_Move(-11050, -18300)
	Map_WaitMapLoading($MAP_ID_Farm, 1)

	If Not $RenderingEnabled Then Memory_Clear()

	Sleep(1000)

	Out("Going to die")
	Party_CommandAll(-11084.60, -17369.06)
	MoveTo(-8094.61, -19418.06)
	Do
		Sleep(250)
	Until GetIsDead(-2) = True

	Out("Waiting for Resurrection")
	Do
		Sleep(250)
	Until GetIsDead(-2) = False

	Party_CancelAll()
	sleep(1000)

	Out("Moving to First Chest")
	MoveChestRunning(-1826.94, 1132.47, 150)
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