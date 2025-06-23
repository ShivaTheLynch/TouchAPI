#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <SliderConstants.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>
#include <WindowsConstants.au3>
#include <AVIConstants.au3>
#include <GUIListBox.au3>
#include <GuiListView.au3>
#include <GuiComboBox.au3>
#include <ScrollBarsConstants.au3>
#include <Array.au3>
#Include <WinAPIEx.au3>
#include <GuiEdit.au3>
#include <WinAPIFiles.au3>
#include <GuiSlider.au3>
#include <ColorConstants.au3>
#include <WinAPITheme.au3> ; <<<<<<<<<<<<<<<<<<
#include <WinAPIDiag.au3>
#include "_gwApi.au3"


; Function to check map and start vanquish only once at bot start
Func CheckMapAndStartVanquish()
    If GetMapID() = 200 Then
        Out("Bot started in Mount Qinkai (map 200), continuing vanquish from here!")
        $CameFromTown = False
        $VanquishInProgress = True
        VanquishMountQinkai()
        $VanquishInProgress = False
        $LastVanquishComplete = TimerInit()
    Else
        Out("Bot started in another map, traveling to Fort Aspenwood to start bot from there.")
        SetHardModeForTravel()
        $CameFromTown = True
        RndTravel($MAP_ID_FORT_ASPENWOOD_LUXON)
        WaitMapLoading($MAP_ID_FORT_ASPENWOOD_LUXON, 10000, 2000)
        RndSleep(500)
        ; Set flag to start run after arriving in Fort Aspenwood
        $ReadyToStartRun = True
    EndIf
EndFunc
; Helper function to set Hard Mode before traveling
Func SetHardModeForTravel()
    If GUICtrlRead($GUIHardModeCheckbox) = $GUI_CHECKED Then
        SwitchMode($DIFFICULTY_HARD)
        Out("Hard Mode enabled for next travel.")
    Else
        SwitchMode($DIFFICULTY_NORMAL)
        Out("Normal Mode enabled for next travel.")
    EndIf
EndFunc

; Example usage before every RndTravel or TravelTo call:
; SetHardModeForTravel()
; RndTravel($TargetMapID)

; --- PATCHES ---
; Patch EnsureInFortAspenwoodLuxon
Func EnsureInFortAspenwoodLuxon()
    ; Always travel to Fort Aspenwood and start the process from there
    If GetMapID() <> $MAP_ID_FORT_ASPENWOOD_LUXON Then
        SetHardModeForTravel()
        $CameFromTown = True
        TravelTo($MAP_ID_FORT_ASPENWOOD_LUXON)
    Else
        ; Already in Fort Aspenwood, proceed to next process here
        Out("We are in Fort Aspenwood! LETS ROCK!")
        SetHardModeForTravel()
        LuxonFarmSetup()
    EndIf
    
    ; Check faction every time we return to town
    If GetLuxonFaction() > (GetMaxLuxonFaction() - 10000) Then
        Out('Turning in Luxon faction')
        SetHardModeForTravel()
        RndTravel($MAP_ID_CAVALON)
        WaitMapLoading($MAP_ID_CAVALON, 10000, 2000)
        RndSleep(200)
        GoToNPCNearXY(9076, -1111)

        Out('Donating Luxon faction')
        While GetLuxonFaction() >= 5000
            DonateFaction('Luxon')
            RndSleep(500)
        WEnd
        RndSleep(500)
        
        ; Return to Fort Aspenwood after donating faction
        Out('Returning to Fort Aspenwood')
        SetHardModeForTravel()
        $CameFromTown = True
        RndTravel($MAP_ID_FORT_ASPENWOOD_LUXON)
        WaitMapLoading($MAP_ID_FORT_ASPENWOOD_LUXON, 10000, 2000)
        RndSleep(500)
    EndIf
EndFunc

; Patch Inventory (TouchAddons)
; Before RndTravel($MAP_ID_EYE_OF_THE_NORTH ) and RndTravel($MAP_ID_FORT_ASPENWOOD_LUXON)
; Instruct user to add SetHardModeForTravel() before those calls in TouchAddons.au3 if needed.

; Patch DonateFactionManual
Func DonateFactionManual()
    ; Check if bot is initialized
    If Not $BotInitialized Then
        Out("Please initialize the bot first by clicking Start")
        Return
    EndIf
    
    ; Check current faction
    Local $currentFaction = GetLuxonFaction()
    Out("Current Luxon faction: " & $currentFaction)
    
    If $currentFaction < 5000 Then
        Out("Faction is below 5000, no donation needed")
        Return
    EndIf
    
    Out("Traveling to Cavalon to donate faction")
    SetHardModeForTravel()
    RndTravel($MAP_ID_CAVALON)
    WaitMapLoading($MAP_ID_CAVALON, 10000, 2000)
    RndSleep(200)
    
    ; Find and interact with faction NPC
    GoToNPCNearXY(9076, -1111)
    
    Out("Donating Luxon faction")
    Local $donations = 0
    While GetLuxonFaction() >= 5000
        DonateFaction('Luxon')
        RndSleep(500)
        $donations += 1
        Out("Donation " & $donations & " completed. Current faction: " & GetLuxonFaction())
        ; Update Luxon faction stats after each donation
        $Stat_LuxonFaction = GetLuxonFaction()
        $Stat_LuxonFactionMax = GetMaxLuxonFaction()
        UpdateStatisticsDisplay()
    WEnd
    
    Out("Faction donation complete! Total donations: " & $donations)
    Out("Final faction: " & GetLuxonFaction())
    
    ; Return to Fort Aspenwood
    Out("Returning to Fort Aspenwood")
    SetHardModeForTravel()
    RndTravel($MAP_ID_FORT_ASPENWOOD_LUXON)
    WaitMapLoading($MAP_ID_FORT_ASPENWOOD_LUXON, 10000, 2000)
    RndSleep(500)
    
    Out("Manual faction donation finished")
    ; Update Luxon faction stats after donation process
    $Stat_LuxonFaction = GetLuxonFaction()
    $Stat_LuxonFactionMax = GetMaxLuxonFaction()
    UpdateStatisticsDisplay()
EndFunc

Func RndTravel($aMapID)
	Local $UseDistricts = 7 ; 7=eu, 8=eu+int, 11=all(incl. asia)
	; Region/Language order: eu-en, eu-fr, eu-ge, eu-it, eu-sp, eu-po, eu-ru, int, asia-ko, asia-ch, asia-ja
	Local $Region[11]   = [2, 2, 2, 2, 2, 2, 2, -2, 1, 3, 4]
	Local $Language[11] = [0, 2, 3, 4, 5, 9, 10, 0, 0, 0, 0]
	Local $Random = Random(0, $UseDistricts - 1, 1)
 	MoveMap($aMapID, $Region[$Random], 0, $Language[$Random])
;~	MoveMap($aMapID, $Region[$Random], 0, $Language[4])
;~ 	WaitMapLoading($aMapID, 30000)
	WaitMapLoadingEx($aMapID, 0)
	Sleep(3000)
EndFunc   ;==>RndTravel



While Not $BotRunning
    Sleep(100)
WEnd

; Call CheckMapAndStartVanquish() ONCE before entering the main bot loop
CheckMapAndStartVanquish()

; Always run LuxonFarmSetup at startup to handle inventory and setup
LuxonFarmSetup()

While $BotRunning
    Sleep(100) ; Reduced from 500ms to 100ms for more responsive updates
    ; Auto-update skillbar if enabled
    If GUICtrlRead($GUIAutoUpdateCheckbox) = $GUI_CHECKED And TimerDiff($LastSkillUpdate) > $SkillUpdateInterval Then
        UpdateSkillbarDisplay()
        $LastSkillUpdate = TimerInit()
    EndIf
    ; Live update for Extra tab statistics (coordinates) - more frequent updates
    If TimerDiff($ExtraStatsUpdateTimer) > 100 Then ; Reduced from 200ms to 100ms
        UpdateExtraStatisticsDisplay()
        $ExtraStatsUpdateTimer = TimerInit()
    EndIf
    
    ; Check if we're ready to start a new run and in Fort Aspenwood
    If $ReadyToStartRun And GetMapID() = $MAP_ID_FORT_ASPENWOOD_LUXON Then
        Out("Ready to start new vanquish run from Fort Aspenwood!")
        $ReadyToStartRun = False
        $VanquishInProgress = True
        
        ; Travel to Mount Qinkai first
        Out("Traveling to Mount Qinkai to start vanquish...")
        SetHardModeForTravel()
        MoveOut() ; This function travels to Mount Qinkai and starts vanquish
        
        $VanquishInProgress = False
        $LastVanquishComplete = TimerInit()
        ; Set flag to start next run after this one completes
        $ReadyToStartRun = True
        Out("Vanquish run completed, ready for next run!")
    EndIf
    
    ; Removed the 5-second sleep that was blocking updates
WEnd

Func LuxonFarmSetup()
	; Inventory management loop during farming
	While (CountSlots() > 6)
		If Not $BotRunning Then
			Out("Bot Paused")
			GUICtrlSetState($GUIStartBotButton, $GUI_ENABLE)
			GUICtrlSetData($GUIStartBotButton, "Resume")
			GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")
			Return
		EndIf

		If $Deadlocked Then
			$Deadlocked = False
			Inventory()
		EndIf
		Sleep(2000)
		MoveOut()
	WEnd

	If (CountSlots() < 7) Then
		If Not $BotRunning Then
			Out("Bot Paused")
			GUICtrlSetState($GUIStartBotButton, $GUI_ENABLE)
			GUICtrlSetData($GUIStartBotButton, "Resume")
			GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")
			Return
		EndIf
		Inventory()
	EndIf
EndFunc


Func MoveOut()
	Move(-4268, 11628)
	Move(-5300, 13300)
	Move(-5493, 13712)
	RndSleep(1000)
	WaitMapLoading(200, 10000, 2000)
	VanquishMountQinkai()
EndFunc

Func _Exit()
    Exit
EndFunc

;~ Vanquish the map

Func VanquishMountQinkai()
	; Track run start time
	Local $runStartTime = TimerInit()
	; Define all vanquish locations with their descriptions
	Local $vanquishLocations[][3] = [ _
		[-11400, -9000, 'Yetis'], _
		[-13500, -10000, 'Yeti 1'], _
		[-15000, -8000, 'Yeti 2'], _
		[-17500, -10500, 'Yeti Ranger Boss'], _
		[-12000, -4500, 'Rot Wallows'], _
		[-12500, -3000, 'Yeti 3'], _
		[-14000, -2500, 'Yeti Ritualist Boss'], _
		[-12000, -3000, 'Leftovers'], _
		[-10500, -500, 'Rot Wallow 1'], _
		[-11000, 5000, 'Yeti 4'], _
		[-10000, 7000, 'Yeti 5'], _
		[-8500, 8000, 'Yeti Monk Boss'], _
		[-5000, 6500, 'Yeti 6'], _
		[-3000, 8000, 'Yeti 7'], _
		[-5000, 4000, 'Yeti 8'], _
		[-7000, 1000, 'Leftovers'], _
		[-9000, -1500, 'Leftovers'], _
		[-6500, -4500, 'Rot Wallow 2'], _
		[-7000, -7500, 'Rot Wallow 3'], _
		[-4000, -7500, 'Leftovers'], _
		[0, -9500, 'Rot Wallow 4'], _
		[5000, -7000, 'Oni 1'], _
		[6500, -8500, 'Oni 2'], _
		[6100, -8708, 'Oni 2 Helper'], _
		[5000, -3500, 'Leftovers'], _
		[500, -2000, 'Leftovers'], _
		[-1500, -3000, 'Naga 1'], _
		[1000, 1000, 'Rot Wallow 5'], _
		[6500, 1000, 'Rot Wallow 6'], _
		[5500, 5000, 'Leftovers'], _
		[4000, 5500, 'Rot Wallow 7'], _
		[6500, 7500, 'Rot Wallow 8'], _
		[8000, 6000, 'Naga 2'], _
		[9500, 7000, 'Naga 3'], _
		[10500, 8000, 'Naga 4'], _
		[12000, 7500, 'Naga 5'], _
		[16000, 7000, 'Naga 6'], _
		[15500, 4500, 'Leftovers'], _
		[18000, 3000, 'Oni 3'], _
		[16500, 1000, 'Leftovers'], _
		[13500, -1500, 'Naga 7'], _
        [12133, 1307, 'Naga 7 Extra'], _
		[12500, -3500, 'Naga 8'], _
        [12442, -7820, 'Naga 8 Extra'], _
		[14000, -6000, 'Outcast Warrior Boss'], _
        [15094, -8081, 'Outcast Warrior Boss Extra'], _
		[13000, -6000, 'Leftovers'] _
	]
	
	; Define ranges for each location (most use default, some use spirit range)
	Local $ranges[] = [$RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT]
	
	; Check if we're starting in Mount Qinkai and need to find the closest starting point
	Local $startingInMountQinkai = (GetMapID() = 200)
	
	Out("Current map ID: " & GetMapID() & " (200 = Mount Qinkai)")
	
	; Check if we're near the spawn point and need to get blessing first (regardless of how we got here)
	Local $distanceFromSpawn = GetDistanceToXY(-8394, -9801, -2)
	Out("Distance from spawn point: " & Round($distanceFromSpawn))
	
	If $distanceFromSpawn < 2000 Then
		Out("Near spawn point, getting blessing first!")
		$CameFromTown = True ; Mark that we came from town
		Move(-8394, -9801) ; Move to blessing coordinates
		RndSleep(2000)
		
		; Try multiple times to get the blessing
		Local $blessingTaken = False
		For $blessingAttempt = 1 To 3
			Out("Blessing attempt " & $blessingAttempt)
			
			; Find NPC near blessing coordinates
			Local $npc = GetNearestNPCPtrToXY(-8394, -9801)
			If $npc Then
				Local $lDistance = GetDistanceToXY(-8394, -9801, $npc)
				Out("NPC found at distance: " & Round($lDistance))
				
				If $lDistance <= 1500 Then ; Increased range slightly
					; Move closer to NPC
					Move(X($npc)-30, Y($npc)-30)
					RndSleep(1500)
					
					; Try to interact with NPC
					GoNPC($npc)
					RndSleep(3000)
					
					; Try different dialog sequences
					If $blessingAttempt = 1 Then
						; First attempt: standard sequence
						Dialog(0x85)
						RndSleep(2000)
						Dialog(0x86)
						RndSleep(2000)
					ElseIf $blessingAttempt = 2 Then
						; Second attempt: try different dialog options
						Dialog(0x85)
						RndSleep(2000)
						Dialog(0x87)
						RndSleep(2000)
					Else
						; Third attempt: try direct blessing dialog
						Dialog(0x86)
						RndSleep(2000)
					EndIf
					
					; Check if we got the blessing by looking for blessing effect
					RndSleep(2000)
					Out("Blessing dialog completed")
					$blessingTaken = True
					ExitLoop
				Else
					Out("NPC found but outside range! Distance: " & Round($lDistance))
				EndIf
			Else
				Out("No NPC found near blessing coordinates on attempt " & $blessingAttempt)
				; Try moving around a bit to find the NPC
				Move(-8394 + Random(-100, 100), -9801 + Random(-100, 100))
				RndSleep(2000)
			EndIf
			
			RndSleep(2000)
		Next
		
		If $blessingTaken Then
			Out("Blessing taken successfully!")
		Else
			Out("Failed to take blessing after 3 attempts, continuing anyway...")
		EndIf
		
		RndSleep(2000)
	EndIf
	
	; Determine starting index for vanquish loop
	Local $startIndex = 0
	
	If $CameFromTown Then
		; If we came from town (got blessing), start from index 0
		Out("Came from town with blessing, starting vanquish from index 0")
		$startIndex = 0
		$CurrentVanquishIndex = 0
		Out("Reset CurrentVanquishIndex to 0 for fresh vanquish start")
	Else
		; If we didn't come from town, find the closest point to start from
		Out("Already in Mount Qinkai away from spawn, finding closest starting point...")
		
		; Find the closest target from current position from ALL locations
		Local $nearestDistance = 999999
		Local $nearestIndex = 0
		
		For $j = 0 To UBound($vanquishLocations) - 1
			Local $testDistance = GetDistanceToXY($vanquishLocations[$j][0], $vanquishLocations[$j][1], -2)
			If $testDistance < $nearestDistance Then
				$nearestDistance = $testDistance
				$nearestIndex = $j
			EndIf
		Next
		
		Out("Closest vanquish point: " & $vanquishLocations[$nearestIndex][2] & " at (" & $vanquishLocations[$nearestIndex][0] & ", " & $vanquishLocations[$nearestIndex][1] & ") - Distance: " & Round($nearestDistance))
		Out("Starting vanquish loop from index " & $nearestIndex)
		
		$startIndex = $nearestIndex
		$CurrentVanquishIndex = $nearestIndex
		Out("Set CurrentVanquishIndex to " & $nearestIndex & " (closest point)")
	EndIf
	
	; SINGLE vanquish loop - process all locations from start index to end
	For $i = $startIndex To UBound($vanquishLocations) - 1
		Local $targetX = $vanquishLocations[$i][0]
		Local $targetY = $vanquishLocations[$i][1]
		Local $description = $vanquishLocations[$i][2]
		Local $range = $ranges[$i]
		
		; Debug output to show current progress
		Out("Processing vanquish location " & $i & "/" & (UBound($vanquishLocations) - 1) & ": " & $description)
		
		; Check for death and resurrection
		Local $currentHealth = GetHealth(-2)
		Local $distanceFromSpawn = GetDistanceToXY(-8394, -9801, -2)
		
		; Detect if player was dead and is now resurrected
		If $LastHealth <= 0 And $currentHealth > 0 And $distanceFromSpawn < 1000 Then
			Out("Detected resurrection after death, finding route back to vanquish position " & $CurrentVanquishIndex)
			$WasDead = True
			
			; Get current position after resurrection
			Local $resurrectX = X(-2)
			Local $resurrectY = Y(-2)
			Out("Resurrected at position: (" & $resurrectX & ", " & $resurrectY & ")")
			
			; Find the best route from current resurrection point to target vanquish position
			Local $targetIndex = $CurrentVanquishIndex
			Local $routeFound = False
			Local $bestRouteIndex = -1
			Local $shortestDistance = 999999
			
			; First, find the closest vanquish location to our resurrection point
			For $routeCheck = 0 To $targetIndex
				Local $routeX = $vanquishLocations[$routeCheck][0]
				Local $routeY = $vanquishLocations[$routeCheck][1]
				Local $routeDistance = GetDistanceToXY($routeX, $routeY, -2)
				
				If $routeDistance < $shortestDistance And $routeDistance < 8000 Then ; Within reasonable distance
					$shortestDistance = $routeDistance
					$bestRouteIndex = $routeCheck
				EndIf
			Next
			
			; If we found a reachable point, start from there
			If $bestRouteIndex >= 0 Then
				Out("Found best route starting point: " & $vanquishLocations[$bestRouteIndex][2] & " at distance " & Round($shortestDistance))
				
				; Move to the best starting point
				Local $startX = $vanquishLocations[$bestRouteIndex][0]
				Local $startY = $vanquishLocations[$bestRouteIndex][1]
				Local $startDesc = $vanquishLocations[$bestRouteIndex][2]
				Local $startRange = $ranges[$bestRouteIndex]
				
				Local $startResult = MoveToKill($startX, $startY, $startDesc, $startRange)
				If $startResult Then
					Out("Successfully reached starting point: " & $startDesc)
					$routeFound = True
					
					; Now continue from this point to the target
					For $continueIndex = $bestRouteIndex + 1 To $targetIndex
						Local $continueX = $vanquishLocations[$continueIndex][0]
						Local $continueY = $vanquishLocations[$continueIndex][1]
						Local $continueDesc = $vanquishLocations[$continueIndex][2]
						Local $continueRange = $ranges[$continueIndex]
						
						Out("Continuing route to: " & $continueDesc)
						Local $continueResult = MoveToKill($continueX, $continueY, $continueDesc, $continueRange)
						If Not $continueResult Then
							Out("Failed to reach " & $continueDesc & ", stopping route")
							ExitLoop
						EndIf
					Next
					
					; If we successfully reached the target, we're good
					If $continueIndex > $targetIndex Then
						Out("Successfully reached target position: " & $vanquishLocations[$targetIndex][2])
					EndIf
				Else
					Out("Failed to reach starting point: " & $startDesc)
				EndIf
			EndIf
			
			; If no good route found, try alternative approach - find any reachable point
			If Not $routeFound Then
				Out("No optimal route found, trying alternative approach")
				
				; Look for any vanquish location that's reachable from current position
				For $altCheck = 0 To UBound($vanquishLocations) - 1
					Local $altX = $vanquishLocations[$altCheck][0]
					Local $altY = $vanquishLocations[$altCheck][1]
					Local $altDesc = $vanquishLocations[$altCheck][2]
					Local $altRange = $ranges[$altCheck]
					Local $altDistance = GetDistanceToXY($altX, $altY, -2)
					
					If $altDistance < 10000 Then ; Try a larger range
						Out("Trying alternative route to: " & $altDesc & " at distance " & Round($altDistance))
						
						Local $altResult = MoveToKill($altX, $altY, $altDesc, $altRange)
						If $altResult Then
							Out("Successfully reached alternative point: " & $altDesc)
							$routeFound = True
							
							; If this point is before our target, continue from here
							If $altCheck <= $targetIndex Then
								For $altContinue = $altCheck + 1 To $targetIndex
									Local $altContinueX = $vanquishLocations[$altContinue][0]
									Local $altContinueY = $vanquishLocations[$altContinue][1]
									Local $altContinueDesc = $vanquishLocations[$altContinue][2]
									Local $altContinueRange = $ranges[$altContinue]
									
									Out("Continuing from alternative to: " & $altContinueDesc)
									Local $altContinueResult = MoveToKill($altContinueX, $altContinueY, $altContinueDesc, $altContinueRange)
									If Not $altContinueResult Then
										Out("Failed to reach " & $altContinueDesc & ", stopping")
										ExitLoop
									EndIf
								Next
							EndIf
							ExitLoop
						EndIf
					EndIf
				Next
			EndIf
			
			If Not $routeFound Then
				Out("Could not find any safe route back, continuing from current position")
			EndIf
			
			; Continue from the current vanquish position, not the closest point
			; The current position is already tracked in $CurrentVanquishIndex
			Out("Continuing vanquish from: " & $vanquishLocations[$CurrentVanquishIndex][2] & " at (" & $vanquishLocations[$CurrentVanquishIndex][0] & ", " & $vanquishLocations[$CurrentVanquishIndex][1] & ")")
			
			; No need to change the loop index, continue from current position
		EndIf
		
		; Update health tracking
		$LastHealth = $currentHealth
		
		; Attempt to move to and clear the target location
		Local $result = MoveToKill($targetX, $targetY, $description, $range)
		
		; If MoveToKill failed (likely due to death), wait for resurrection and continue
		If Not $result Then
			Out("MoveToKill failed for " & $description & ", waiting for resurrection...")
			RndSleep(3000) ; Wait for resurrection
			
			; Don't break the loop, continue with next target
		EndIf
		
		; Update current vanquish position
		$CurrentVanquishIndex = $i
		
		; Small delay between locations
		RndSleep(1000)
	Next
	
	; Check if area is vanquished at the end
	If Not GetAreaVanquished() Then
		Out("Area not fully vanquished, but vanquish loop completed")
        EnsureInFortAspenwoodLuxon()
	EndIf
	
	Out('Area vanquished successfully!')
	
	; ALWAYS travel back to Fort Aspenwood after vanquish attempt - ONLY ONCE at the very end
	Out("Vanquish complete! Traveling back to Fort Aspenwood to restart...")
    EnsureInFortAspenwoodLuxon()
	RndSleep(2000)
	$LastVanquishComplete = TimerInit()
	Out("Successfully returned to Fort Aspenwood. Vanquish run complete. Waiting for next run...")
	; Update run statistics
	Local $runDuration = Int(TimerDiff($runStartTime) / 1000) ; in seconds
	$Stat_TotalRuns += 1
	$Stat_TotalRunTime += $runDuration
	If $Stat_TotalRuns > 0 Then
		$Stat_AvgRunTime = Int($Stat_TotalRunTime / $Stat_TotalRuns)
	EndIf
	UpdateStatisticsDisplay()
	; Set flag to continue the loop
	$ReadyToStartRun = True
	Return 0
EndFunc



