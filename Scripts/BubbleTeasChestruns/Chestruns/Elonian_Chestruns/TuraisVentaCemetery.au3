;;; Turais Procession Chestrunner from Venta Cemetery
Func TuraisVenta()

	; Go To Outpost
	MapP()

	; Check, if Gatetrick should be done or not
	If GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $runcounter = 1 Then
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $inventorytrigger = 1 Then
		$inventorytrigger = 0
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_UNCHECKED Then
		MoveTo(26291.60, 16019.00)
	EndIf

	Out("Exiting Outpost")
    Map_Move(26300, 16750)
	Map_WaitMapLoading($MAP_ID_Farm, 1)

	If Not $RenderingEnabled Then Memory_Clear()

	Sleep(1000)
	
	Out("Moving to First Chest")
	MoveChestRunning(-11925.88, -24281.43, 150)
	MoveChestRunning(-9190.21, -22009.89, 150)
	MoveChestRunning(-7789.55, -18896.45, 150)
	MoveChestRunning(-6350.75, -15118.29, 150)
	Chesti()

	Out("Moving to Second Chest")
	MoveChestRunning(-9861.19, -10600.70, 150)
	Chesti()

	Out("Moving to Third Chest")
	MoveChestRunning(-4728.81, -7261.65, 150)
	Chesti()

	Out("Moving to Fourth Chest")
	MoveChestRunning(-2534.67, -1115.70, 150)
	MoveChestRunning(3565.30, -1914.41, 150)
	Chesti()

	Out("Moving to Fifth Chest")
	MoveChestRunning(6577.69, 433.26, 150)
	MoveChestRunning(11686.39, 365.62, 150)
	Chesti()

	Out("Moving to Sixth Chest")
	MoveChestRunning(10282.33, 2284.14, 150)
	MoveChestRunning(9812.82, 5450.91, 150)
	MoveChestRunning(8231.64, 7479.98, 150)
	MoveChestRunning(8868.26, 10480.53, 150)
	MoveChestRunning(5910.14, 11123.42, 150)
	MoveChestRunning(1149.74, 9195.33, 150)
	Chesti()

	Out("Moving to Seventh Chest")
	MoveChestRunning(1991.56, 11649.73, 150)
	MoveChestRunning(3359.96, 15216.14, 150)
	Chesti()

	Out("Moving to Eights Chest")
	MoveChestRunning(4774.10, 21373.19, 150)
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