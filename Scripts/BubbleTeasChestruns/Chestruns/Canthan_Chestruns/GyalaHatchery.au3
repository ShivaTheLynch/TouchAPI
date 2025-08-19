;;; Gyala Hatchery Chestrunner
Func GyalaHatchery()

	; Go To Outpost
	MapP()

	; Check, if Gatetrick should be done or not
	If GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $runcounter = 1 Then
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $inventorytrigger = 1 Then
		$inventorytrigger = 0
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_UNCHECKED Then
		MoveTo(8896.11, -20213.41)
	EndIf

	Out("Exiting Outpost")
	Map_Move(8500, -19900)
	Map_WaitMapLoading($MAP_ID_Farm, 1)

	If Not $RenderingEnabled Then Memory_Clear()

	Sleep(1000)

	Out("Moving to First Chest")
	MoveChestRunning(5149.70, -16478.36,150)
	MoveChestRunning(2520.72, -15238.02,150)
	MoveChestRunning(-1060.12, -18869.66,150)
	MoveChestRunning(-2517.38, -15673.38, 150)
	MoveChestRunning(-3076.21, -13510.19, 150)
	Chesti()
	
	Out("Moving to Second Chest")
	MoveChestRunning(-4181.92, -17489.43, 150)
	MoveChestRunning(-6328.93, -17484.08, 150)
	Chesti()
		
	Out("Moving to Third Chest")
	MoveChestRunning(-8739.32, -17103.43, 150)
	MoveChestRunning(-8721.46, -14157.12, 150)
	Chesti()

	Out("Moving to Fourth Chest")
	MoveChestRunning(-6781.42, -9363.07, 150)
	Chesti()

	Out("Moving to Fifth Chest")
	MoveChestRunning(-2111.21, -7865.76, 150)
	Chesti()

	Out("Moving to Sixth Chest")
	MoveChestRunning(3166.38, -2340.72, 150)
	Chesti()
	
	Out("Moving to Seventh Chest")
	MoveChestRunning(-2147.05, 1850.40, 150)
	Chesti()
	
	Out("Moving to Eigth Chest")
	MoveChestRunning(-3451.65, 5862.10, 150)
	MoveChestRunning(-3838.32, 9336.52, 150)
	Chesti()
	
	Out("Moving to Ninth Chest")
	MoveChestRunning(-7103.60, 12893.18, 150)
	MoveChestRunning(-7223.50, 18384.97, 150)
	Chesti()
	
	Out("Moving to Tenth Chest")
	MoveChestRunning(-2866.04, 17213.13, 150)
	MoveChestRunning(-100.58, 16099.58, 150)
	MoveChestRunning(1914.58, 12920.24, 150)
	MoveChestRunning(5010.02, 13188.72, 150)
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