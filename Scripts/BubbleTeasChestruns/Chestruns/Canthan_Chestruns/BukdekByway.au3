;;; Bukdek Byway Chestrunner
; WOC needs to be off if you are looking for Plaguenorn items
; DEACTIVATE THE FOLLOWING QUESTS:
; Chasing Zenmai, Closer to the Stars, The Drunken Master
; Eliminate the AmFah, Eliminate the Jade Brotherhood
; Finding the Oracle, Missing Daughter
; The Afflicted Guard, Welcome to Cantha
Func BukdekByway()

	; Go To Outpost
	MapP()

	; Check, if Gatetrick should be done or not
	If GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $runcounter = 1 Then
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $inventorytrigger = 1 Then
		$inventorytrigger = 0
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_UNCHECKED Then
		If CheckAreaRange(3189.00, -1545.00,500) Then
			MoveTo(2999.06, -2333.54)
			MoveTo(2784.30, -3921.87)
		ElseIf CheckAreaRange(-855.00, -1548.00,500) Then
			MoveTo(-777.14, -3342.00)
			MoveTo(1155.73, -3667.72)
			MoveTo(2382.53, -3906.60)
		ElseIf CheckAreaRange(2786.00, 652.00,500) Then
			MoveTo(2990.44, -230.84)
			MoveTo(3109.95, -1491.40)
			MoveTo(2999.06, -2333.54)
			MoveTo(2784.30, -3921.87)
		EndIf
		MoveTo(2681, -4305)
	EndIf

	Out("Exiting Outpost")
	Map_Move(3310.25, -4815.32)
	Map_WaitMapLoading($MAP_ID_Farm, 1)

	If Not $RenderingEnabled Then Memory_Clear()

	Sleep(1000)


	Out("Moving to First Chest")
	MoveTo(-5908, 18067)
	MoveTo(-3488, 16224)
	MoveTo(7, 16777)
	MoveTo(2461, 17069)
	MoveChestRunning(3512, 15378, 150)
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
