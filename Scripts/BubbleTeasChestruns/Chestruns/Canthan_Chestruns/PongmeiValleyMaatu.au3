;;; Pongmei Valley Chestrunner
Func PongmeiValleyMaatu()

	; Go To Outpost
	MapP()

	; Check, if Gatetrick should be done or not
	If GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $runcounter = 1 Then
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $inventorytrigger = 1 Then
		$inventorytrigger = 0
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_UNCHECKED Then
		MoveTo(-13296.45, 11821.20)
	EndIf

	Out("Exiting Outpost")
	Map_Move(-13350, 11350)
	Map_WaitMapLoading($MAP_ID_Farm, 1)

	If Not $RenderingEnabled Then Memory_Clear()

	Sleep(1000)

	Out("Moving to First Chest")
	MoveChestRunning(-12529.30, 380.60, 150)
	Chesti()

	Out("Moving to Second Chest")
	MoveChestRunning(-6576.30, 250.94, 150)
	Chesti()

	Out("Moving to Third Chest")
	MoveChestRunning(-4640.75, -1109.55, 150)
	MoveChestRunning(-1927.92, -506.08, 150)
	Chesti()

	Out("Moving to Fourth Chest")
	MoveChestRunning(-383.40, 2419.55, 150)
	MoveChestRunning(-942.53, 5764.20, 150)
	Chesti()

	Out("Moving to Fifth Chest")
	MoveChestRunning(4463.03, 5611.61, 150)
	MoveChestRunning(6986.71, 2235.84, 150)
	MoveChestRunning(8983.32, -182.43, 150)
	Chesti()

	Out("Moving to Sixth Chest")
	MoveChestRunning(12225.77, 703.96, 150)
	MoveChestRunning(11954.12, 5828.85, 150)
	Chesti()

	Out("Moving to Seventh Chest")
	MoveChestRunning(14140.11, 3045.75, 150)
	MoveChestRunning(13403.77, -1254.65, 150)
	MoveChestRunning(16097.21, -3239.54, 150)
	Chesti()

	Out("Moving to Eighth Chest")
	MoveChestRunning(17725.88, 517.08, 150)
	MoveChestRunning(19317.02, 2483.98, 150)
	Chesti()

	Out("Moving to Ninth Chest")
	MoveChestRunning(21408.31, 4911.76, 150)
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