;;; Dejarin Estate Chestrunner
Func DejarinEstate()

	; Go To Outpost
	MapP()

	; Check, if Gatetrick should be done or not
	If GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $runcounter = 1 Then
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $inventorytrigger = 1 Then
		$inventorytrigger = 0
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_UNCHECKED Then
		MoveTo(4323.24, 3304.75)
	EndIf

	Out("Exiting Outpost")
	MoveTo(4323.24, 3304.75)
	Map_Move(4650, 3800)
	Map_WaitMapLoading($MAP_ID_Farm, 1)

	If Not $RenderingEnabled Then Memory_Clear()

	Sleep(1000)

	Out("Moving to First Chest")
	MoveTo(-17173.38, -16685.23)
	MoveTo(-14785.15, -14005.95)
	MoveChestRunning(-10732.70, -13169.56, 150)
	Chesti()

	Out("Moving to Second Chest")
	MoveChestRunning(-6884.44, -15912.12, 150)
	Chesti()
	MoveChestRunning(-6784.44, -15950.12, 150)

	Out("Moving to Third Chest")
	MoveTo(-5897.15, -16033.99)
	MoveTo(-4597.15, -16033.99)
	MoveTo(-3097.15, -15933.99)
	MoveTo(-1785.08, -15852.48)
	MoveTo(-865.13, -15775.43)
	MoveChestRunning(229.57, -13949.55, 150)
	Chesti()

	Out("Moving to Fourth Chest")
	MoveChestRunning(5889.46, -13879.40, 150)
	Chesti()

	Out("Moving to Fifth Chest")
	MoveChestRunning(8845.96, -14498.63, 150)
	MoveChestRunning(11681.63, -13660.46, 150)
	Chesti()

	Out("Moving to Sixth Chest")
	MoveChestRunning(10740.84, -10236.13, 150)
	MoveChestRunning(8051.12, -8376.07, 150)
	Chesti()

	Out("Moving to Seventh Chest")
	MoveChestRunning(12853.96, -8991.12, 150)
	Chesti()

	Out("Moving to Eights Chest")
	MoveChestRunning(15821.97, -4882.87, 150)
	Chesti()

	Out("Moving to Ninth Chest")
	MoveChestRunning(16477.94, -1776.03, 150)
	MoveChestRunning(16607.71, 2039.86, 150)
	MoveChestRunning(15357.58, 3524.99, 150)
	MoveChestRunning(13233.71, 2815.38, 150)
	Chesti()

	Out("Moving to Tenth Chest")
	MoveChestRunning(13468.27, 5675.79, 150)
	Chesti()

	Out("Moving to Eleventh Chest")
	MoveChestRunning(16830.62, 6162.88, 150)
	Chesti()

	Out("Moving to Twelveth Chest")
	MoveChestRunning(16555.27, 9962.48, 150)
	MoveChestRunning(15657.72, 13820.45, 150)
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