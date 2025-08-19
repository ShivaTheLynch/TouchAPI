#cs
;;; Mount Qinkai Vanquisher - Luxon Points Farmer
; You run in Hard Mode
; Possible valuable drops: Gold q9 Luxon drops

; Author: Bubbletea

#ce

#RequireAdmin
#include "../../API/_GwAu3.au3"
#include "GwAu3_AddOns.au3"

; Map IDs used in this farm script
Global Const $FARM_MAPS[4] = [$MAP_ID_MountQinkai, $Town_ID_AspenwoodgateLuxon, $Town_ID_Great_Temple_of_Balthazar, $Town_ID_Cavalon]

Global Const $doLoadLoggedChars = True
Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)
Opt("ExpandVarStrings", 1)

#Region Declarations
Global $charName  = ""
Global $ProcessID = ""
Global $timer = TimerInit()
Global $BotRunning = False
Global $Bot_Core_Initialized = False
Global $g_bAutoStart = False  ; Flag for auto-start
#EndRegion Declaration

; Process command line arguments
For $i = 1 To $CmdLine[0]
    If $CmdLine[$i] = "-character" And $i < $CmdLine[0] Then
        $charName = $CmdLine[$i + 1]
        $g_bAutoStart = True
        ExitLoop
    EndIf
Next

; ------------- GUI --------------
#include "Gui.au3"

; Auto-start if character was provided via command line
If $g_bAutoStart And $charName <> "" Then
    Out("Auto-starting for character: " & $charName)
    
    ; Initialize the core with the character name
    If Core_Initialize($charName, True) = 0 Then
        Out("Error: Could not initialize core for character '" & $charName & "'")
        _Exit()
    EndIf
    
    ; Press Enter on character selection screen to select the character
    Out("Pressing Enter to select character on selection screen...")
    ControlSend(Scanner_GetWindowHandle(), "", "", "{Enter}")
    Sleep(2000) ; Wait for character to be selected and loaded
    
    ; Set the bot as running and initialized
    $BotRunning = True
    $Bot_Core_Initialized = True
    
    ; Update GUI to reflect the auto-start state
    GUICtrlSetData($Input, $charName)
    GUICtrlSetState($Input, $GUI_DISABLE)
    GUICtrlSetData($Button, "Pause")
    GUICtrlSetFont($Button, 10, 400, 0, "Times New Roman")
    GUICtrlSetState($RenderingBox, $GUI_ENABLE)
    GUICtrlSetState($HardmodeCheckbox, $GUI_DISABLE)
    GUICtrlSetState($Builds, $GUI_DISABLE)
    GUICtrlSetState($ResignGateTrickBox, $GUI_DISABLE)
    GUICtrlSetState($DonateBox, $GUI_DISABLE)
    GUICtrlSetState($PconsBox, $GUI_DISABLE)
    
    ; Update window title
    WinSetTitle($mainGui, "", Player_GetCharname() & " - BubbleTea's Luxon Farmer")
    
    ; Update statistics
    $LuxonTitle = GetLuxonTitle()
    Global Const $LuxonPointsStart = GetLuxonTitlePoints()
    $LuxonPointsGained = GetLuxonTitlePoints() - $LuxonPointsStart
    UpdateStatistics()
    
    Out("Auto-start completed for character: " & $charName)
Else
    ; If not auto-starting, ensure the character combo box shows the character name if provided
    If $charName <> "" Then
        ; Wait a bit for GUI to be fully created
        Sleep(100)
        ; Set the combo box to show the character name
        GUICtrlSetData($Input, $charName)
        Out("Character set to: " & $charName)
    EndIf
EndIf

While Not $BotRunning
	Sleep(100)
WEnd

While True
    ; Check for disconnection in main loop
    If CheckForDisconnectAndRestart() Then
        Out("Disconnect detected in main loop, stopping bot...")
        ExitLoop
    EndIf

    If $BotRunning = True Then
        MainFarm()
    Else
        Sleep(1000)
    EndIf
WEnd

; --------- Start of Bot --------------
Func MainFarm()

    ; Check for disconnection before starting
    If CheckForDisconnectAndRestart() Then
        Out("Disconnect detected, stopping bot...")
        Return
    EndIf

    If GetLuxonFaction() >= (GetMaxLuxonFaction() - 15000) Then DonateDemPoints()

    While (CountSlots() > 4)
        ; Check for disconnection in farm loop
        If CheckForDisconnectAndRestart() Then
            Out("Disconnect detected in farm loop, stopping...")
            Return
        EndIf

        If Not $BotRunning Then
            Out("Bot Paused")
            GUICtrlSetState($Button, $GUI_ENABLE)
            GUICtrlSetData($Button, "Resume")
			GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")
            Return
        EndIf

        If $Deadlocked Then
            $Deadlocked = False
            Inventory()
            Return
        EndIf
		sleep(2000)
        
        ; Check if character is stuck (periodic check)
        PeriodicStuckCheck()
        
        CombatLoop()
        If GetLuxonFaction() >= (GetMaxLuxonFaction() - 15000) Then DonateDemPoints()
    WEnd

    If (CountSlots() < 5) Then
        ; Check for disconnection before inventory management
        If CheckForDisconnectAndRestart() Then
            Out("Disconnect detected before inventory, stopping...")
            Return
        EndIf

        If Not $BotRunning Then
            Out("Bot Paused")
            GUICtrlSetState($Button, $GUI_ENABLE)
            GUICtrlSetData($Button, "Resume")
			GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")
            Return
        EndIf

        Inventory()
        If GetLuxonFaction() >= (GetMaxLuxonFaction() - 15000) Then DonateDemPoints()
    EndIf
EndFunc

; New function to check for disconnect and restart client if needed
Func CheckForDisconnectAndRestart()
    If Core_GetDisconnected() Then
        Out("Disconnect detected! Attempting to restart client...")
        
        ; Close the current Guild Wars process
        Local $l_h_GWWindow = Core_GetGuildWarsWindow()
        If $l_h_GWWindow <> 0 Then
            WinClose($l_h_GWWindow)
            Sleep(2000)
        EndIf
        
        ; Force close any remaining gw.exe processes
        Local $l_h_ProcessList = ProcessList("gw.exe")
        For $i = 1 To $l_h_ProcessList[0][0]
            ProcessClose($l_h_ProcessList[$i][1])
        Next
        Sleep(2000)
        
        ; Try to find and restart Guild Wars with common installation paths
        Local $l_s_GwPaths[4] = ["C:\Program Files\Guild Wars\Gw.exe", "C:\Program Files (x86)\Guild Wars\Gw.exe", "D:\Program Files\Guild Wars\Gw.exe", "D:\Program Files (x86)\Guild Wars\Gw.exe"]
        Local $l_h_PID = 0
        Local $l_s_UsedPath = ""
        
        For $i = 0 To UBound($l_s_GwPaths) - 1
            If FileExists($l_s_GwPaths[$i]) Then
                Out("Found Guild Wars at: " & $l_s_GwPaths[$i])
                $l_h_PID = Run($l_s_GwPaths[$i], "", @SW_SHOW)
                If $l_h_PID <> 0 Then
                    $l_s_UsedPath = $l_s_GwPaths[$i]
                    ExitLoop
                EndIf
            EndIf
        Next
        
        If $l_h_PID = 0 Then
            Out("Failed to restart Guild Wars. Please restart manually.")
            Out("Tried paths: " & _ArrayToString($l_s_GwPaths, ", "))
            Return True
        EndIf
        
        ; Wait for client to start and reconnect
        Out("Restarting Guild Wars from: " & $l_s_UsedPath)
        Out("Waiting for client to reconnect...")
        Sleep(10000) ; Wait 10 seconds for client to start
        
        ; Try to reinitialize the core
        Local $l_i_attempts = 0
        Local $l_i_maxAttempts = 30
        While $l_i_attempts < $l_i_maxAttempts
            Sleep(2000)
            If Core_Initialize($charName, True) <> 0 Then
                Out("Successfully reconnected and reinitialized!")
                Return False ; No disconnect, continue
            EndIf
            $l_i_attempts += 1
            Out("Reconnection attempt " & $l_i_attempts & "/" & $l_i_maxAttempts)
        WEnd
        
        Out("Failed to reconnect after " & $l_i_maxAttempts & " attempts. Stopping bot.")
        Return True ; Disconnect still exists, stop bot
    EndIf
    
    Return False ; No disconnect
EndFunc

Func MapP()

	; Check for disconnection before traveling
	If CheckForDisconnectAndRestart() Then
		Out("Disconnect detected, stopping travel...")
		Return
	EndIf

	; Load builds, if it is the first run
	If GUICtrlRead($Builds) = $GUI_CHECKED and $RunCount = 0 Then
		; When Option is chosen and we are at the first Run, then we will load the Hero_Builds
        ; Therefore we will go to a 8man Area, so all 7 Herobuilds will be loaded
        Out("Travelling to Great Temple of Balthazar")
        RndTravel($Town_ID_Great_Temple_of_Balthazar)
        Sleep(5000)

		;~ Loading Skilltemplates
		Party_KickAllHeroes()
		Sleep(250)
		Out("Load my Skills")
		Attribute_LoadSkillTemplate($SkillBarTemplate)
		Sleep(250)
		Out("Player skillbar loaded")
		Out("Add Heroes")

		Party_AddHero($HERO_ID_Gwen)
		Sleep(250)
		Out("Load Gwen's Skillbar")
		Attribute_LoadSkillTemplate("OQlkAkC8QZizJIHM9wpmuMQNeHD", 1)
		Sleep(250)
        Party_SetHeroAggression(1, 0) ; 0 = Aggressive
		Sleep(500)
		Out("Gwen ready!")

		Party_AddHero($HERO_ID_Sousuke)
		Sleep(250)
		Out("Load Sousuke's Skillbar")
		Attribute_LoadSkillTemplate("OgVCIMzzJY6lDuAyAc6QgWA", 2)
		Sleep(250)
        Party_SetHeroAggression(2, 0) ; 0 = Aggressive
		Sleep(500)
		Out("Sousuke ready!")

        Party_AddHero($HERO_ID_Livia)
		Sleep(250)
		Out("Load Livia's Skillbar")
		Attribute_LoadSkillTemplate("OAhjUwGaISyBTB4BbhVVKgRTDTA", 3)
		Sleep(250)
        Party_SetHeroAggression(3, 1) ; 1 = Guard
		Sleep(500)
		Out("Livia ready!")

        Party_AddHero($HERO_ID_Vekk)
		Sleep(250)
		Out("Load Vekk's Skillbar")
		Attribute_LoadSkillTemplate("OgdUgW1yw/MHRaBuosOLQH5QcHA", 4)
		Sleep(250)
        Party_SetHeroAggression(4, 0) ; 0 = Aggressive
		Sleep(500)
		Out("Vekk ready!")

		Party_AddHero($HERO_ID_Xandra)
		Sleep(250)
		Out("Load Xandra's Skillbar")
		Attribute_LoadSkillTemplate("OACjAyhDJPYTrX48xBNdmI3LGA", 5)
		Sleep(250)
        Party_SetHeroAggression(5, 1) ; 1 = Guard
		Sleep(500)
		Out("Xandra ready!")

		Party_AddHero($HERO_ID_Master)
		Sleep(250)
		Out("Load Master of Whisper's Skillbar")
		Attribute_LoadSkillTemplate("OAhjQoGYIP3hqazeYK8kmTuxJA", 6)
		Sleep(250)
        Party_SetHeroAggression(6, 1) ; 1 = Guard
		Sleep(500)
		Out("Master of Whisper ready!")

		Party_AddHero($HERO_ID_Ogden)
		Sleep(250)
		Out("Load Ogden's Skillbar")
		Attribute_LoadSkillTemplate("Owkk0wPHEaiEDxdV9Ad1GRDYN2OG", 7)
		Sleep(250)
        Party_SetHeroAggression(7, 1) ; 1 = Guard
		Sleep(500)
		Out("Ogden ready!")
	EndIf

    ; Cache, what heroes have a rez skill
    If $RunCount = 0 then CacheHeroesWithRez()

    ;~ Checks if you are already in Aspenwood Gate (Luxon) -> if not travel there
	If Map_GetMapID() <> $Town_ID_AspenwoodgateLuxon Then
		Out("Travelling to Aspenwood Gate (Luxon)")
		RndTravel($Town_ID_AspenwoodgateLuxon)
		Sleep(5000)
	EndIf
	
	;~ HardMode
	If GUICtrlRead($HardmodeCheckbox) = $GUI_CHECKED Then
        Game_SwitchMode($DIFFICULTY_HARD)
    Else
        Game_SwitchMode($DIFFICULTY_NORMAL)
    EndIf
	
EndFunc

Func FastWayOut()
	; Check for disconnection before using gate trick
	If CheckForDisconnectAndRestart() Then
		Out("Disconnect detected, stopping gate trick...")
		Return False
	EndIf

	Out("You have chosen the gate trick option.")
    Out("What a wise fella you are!")
    Out("Now take you legs and run to the gate!!!")

	MoveTo(-5096.79, 12933.94)
	Map_Move(-5700, 13900)
	Map_WaitMapLoading($MAP_ID_MountQinkai, 1)
	Sleep(2000)

    MoveTo(-8710.48, -10694.13)
	Map_Move(-8200, -11250)
	Map_WaitMapLoading($Town_ID_AspenwoodgateLuxon, 0)
	Sleep(2000)
	Return True
EndFunc ;==>FastWayOut

; Here, the Magic happens
Func CombatLoop()

	; Check for disconnection before starting combat
	If CheckForDisconnectAndRestart() Then
		Out("Disconnect detected, stopping combat...")
		Return
	EndIf

	; Go To Outpost
	MapP()

	; Check, if Gatetrick should be done or not
	If GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $RunCount = 0 Then
		FastWayOut()
	ElseIf GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED and $inventorytrigger = 1 Then
		$inventorytrigger = 0
		FastWayOut()
	EndIf

    If GetGoldCharacter() < 500 Then
        If GetGoldStorage() < 1000 Then
            Out("What a poor bastard you are!!!")
            Out("Get money elsewhere!!!")
            Out("I will automatically close in 5")
            Sleep(1000)
            Out("4")
            Sleep(1000)
            Out("3")
            Sleep(1000)
            Out("2")
            Sleep(1000)
            Out("1")
            Sleep(1000)
            Exit
        Else
            Item_WithdrawGold(1000)
		    Sleep(1000)
        EndIf
    EndIf

	; Check for disconnection before starting farm
	If CheckForDisconnectAndRestart() Then
		Out("Disconnect detected, stopping farm...")
		Return
	EndIf

	Out("Exiting Outpost")
	MoveTo(-5096.79, 12933.94)
	Map_Move(-5700, 13900)
	Map_WaitMapLoading($MAP_ID_MountQinkai, 1)

	Sleep(1000)
	$RunTimer = TimerInit()

	FarmMountQinkai()
	
	If GetIsDead(-2) = True then
		$FailCount += 1
	Else
		$SuccessCount += 1
        $RunTime = TimerDiff($RunTimer)

        $RunTimeCalc = Round($RunTime / 1000)
        Redim $AvgTime[UBound($AvgTime)+1]
        $AvgTime[UBound($AvgTime)-1] = $RunTimeCalc

        CalculateFastestTime()
        CalculateAverageTime()
	EndIf
	$RunCount += 1

	UpdateStatistics()

	If GUICtrlRead($ResignGateTrickBox) = $GUI_CHECKED Then
		; Check for disconnection before resigning
		If CheckForDisconnectAndRestart() Then
			Out("Disconnect detected before resign, stopping...")
			Return
		EndIf

		Resign()
		Sleep(5000)
		Map_ReturnToOutpost()
		Sleep(2000)
		Map_WaitMapLoading($Town_ID_AspenwoodgateLuxon, 0)
		Sleep(5000)
	Else
		; Check for disconnection before traveling
		If CheckForDisconnectAndRestart() Then
			Out("Disconnect detected before travel, stopping...")
			Return
		EndIf

		RndTravel($Town_ID_AspenwoodgateLuxon)
        Sleep(5000)
	EndIf
	Memory_Clear()
EndFunc


Func FarmMountQinkai()

    ; Check for disconnection before starting farm
    If CheckForDisconnectAndRestart() Then
        Out("Disconnect detected, stopping farm...")
        Return
    EndIf

    If GetPartyDead() Then Return
    GetBlessing()
    $RezShrine = 1
    
    Out("Now let's Farm some Luxon Points")
    If GetPartyDefeated() then Return
    Do
        ; Check for disconnection in first farm loop
        If CheckForDisconnectAndRestart() Then
            Out("Disconnect detected in first farm loop, stopping...")
            Return
        EndIf

        If GetPartyDefeated() then ExitLoop
        UseRunEnhancers() ; Consets and stuff like that
        FarmToSecondShrine()
    Until $RezShrine = 2 or GetPartyDefeated()

    If GetPartyDefeated() then Return
    Do
        ; Check for disconnection in second farm loop
        If CheckForDisconnectAndRestart() Then
            Out("Disconnect detected in second farm loop, stopping...")
            Return
        EndIf

        If GetPartyDefeated() then ExitLoop
        UseRunEnhancers() ; Consets and stuff like that
        FarmToThirdShrine()
    Until $RezShrine = 3 or GetPartyDefeated()

    If GetPartyDefeated() then Return
    Do
        ; Check for disconnection in third farm loop
        If CheckForDisconnectAndRestart() Then
            Out("Disconnect detected in third farm loop, stopping...")
            Return
        EndIf

        If GetPartyDefeated() then ExitLoop
        UseRunEnhancers() ; Consets and stuff like that
        FarmToFourthShrine()
    Until $RezShrine = 4 or GetPartyDefeated()
    
    If GetPartyDefeated() then Return
    Do
        ; Check for disconnection in final farm loop
        If CheckForDisconnectAndRestart() Then
            Out("Disconnect detected in final farm loop, stopping...")
            Return
        EndIf

        If GetPartyDefeated() then ExitLoop
        UseRunEnhancers() ; Consets and stuff like that
        FarmToEnd()
    Until $RezShrine = 0 or GetPartyDefeated()

EndFunc ;==> FarmMountQinkai


Func GetBlessing()
    ; Check for disconnection before getting blessing
    If CheckForDisconnectAndRestart() Then
        Out("Disconnect detected, stopping blessing...")
        Return
    EndIf

    If GetisDead(-2) Then Return
    Out("Get the Blessing!")
    MoveTo(-8394.10, -9863.09)
    Local $NPC = GetNearestNPCToAgent(-2, 1320, $GC_I_AGENT_TYPE_LIVING, 1, "NPCFilter")
	MoveTo(Agent_GetAgentInfo($NPC, "X")-20,Agent_GetAgentInfo($NPC, "Y")-20)
    Agent_GoNPC($NPC)
    Sleep(500)
    If GetKurzickFaction() > GetLuxonFaction() Then
        Out("Bribe the Golddigger!")
        Ui_Dialog(0x81)
        sleep(1000)
        Ui_Dialog(0x2)
        sleep(1000)
        Ui_Dialog(0x84)
        sleep(1000)
        Ui_Dialog(0x86)
        sleep(1000)
    Else
        Out("He is on our side!")
        Ui_Dialog(0x85)
        sleep(1000)
        Ui_Dialog(0x86)
        sleep(1000)
    EndIf
EndFunc ;==> GetBlessing


Func DonateDemPoints()

    Out("Travel to Cavalon - Donating Points")
    RndTravel($Town_ID_Cavalon)
    Sleep(7000)
    $inventorytrigger = 1

    Out("Go to Luxon Scavanger")
    If CheckAreaRange(5439.88, 1441.83, 500) Then
        MoveTo(5378.04, 1093.01)
        MoveTo(7561.78, -1139.63)
    EndIF
    MoveTo(9050.54, -1120.91, 0)
    Local $NPC = GetNearestNPCToAgent(-2, 1320, $GC_I_AGENT_TYPE_LIVING, 1, "NPCFilter")
    Agent_GoNPC($NPC)
    Sleep(1000)
    If GUICtrlRead($DonateBox) = $GUI_CHECKED Then
        Out("Donate the Points")
    Else
        Out("Buy Jadeite Shards")
    EndIf
    While GetLuxonFaction() >= 5000
        ; Check for disconnection in donation loop
        If CheckForDisconnectAndRestart() Then
            Out("Disconnect detected in donation loop, stopping...")
            Return
        EndIf

        If GUICtrlRead($DonateBox) = $GUI_CHECKED Then
            Ui_Dialog(0x87)
            sleep(1000)
            Game_DonateFaction("luxon")
            sleep(1000)
        Else
            Ui_Dialog(0x84)
            sleep(1000)
            Ui_Dialog(0x800101)
            Sleep(1000)
        EndIf
    WEnd

    $LuxonPointsGained = GetLuxonTitlePoints() - $LuxonPointsStart
    $LuxonTitle = GetLuxonTitle()

	UpdateStatistics()
    Return
EndFunc ;==> DonateDemPoints

Func UseRunEnhancers()
    ; Check for disconnection before using enhancers
    If CheckForDisconnectAndRestart() Then
        Out("Disconnect detected, stopping enhancer usage...")
        Return
    EndIf

    If GUICtrlRead($PconsBox) = $GUI_CHECKED Then
        Out("Eat some juicy Snacks.")
        If GetPartyDefeated() Then Return
        If FindConset() = True Then UseConset()
        If FindSummoningStone() = True Then UseSummoningStone()
    EndIf
EndFunc ;==> UseRunEnhancers

Func FarmToSecondShrine()
    ; Check for disconnection before farming to second shrine
    If CheckForDisconnectAndRestart() Then
        Out("Disconnect detected, stopping farm to second shrine...")
        Return
    EndIf

    If Not GetPartyDead() then Out("Kill some Yetis")
    AggroMoveToEx(-11345.94, -9236.53, 150)
    AggroMoveToEx(-13374.57, -8792.12, 150)
    AggroMoveToEx(-15136.31, -8014.83, 150)

    If Not GetPartyDead() then Out("Kill the Ranger Boss")
    AggroMoveToEx(-17681.92, -10434.07, 150)

    If Not GetPartyDead() then Out("Kill Rot Wallow")
    AggroMoveToEx(-15480.86, -8330.52, 150)
    AggroMoveToEx(-13927.14, -5273.81, 150)
    AggroMoveToEx(-11642.35, -3830.33, 150)

    If Not GetPartyDead() then Out("Kill the Ritualist Boss")
    AggroMoveToEx(-12145.45, -3141.13, 150)
    If Not GetPartyDead() and GUICtrlRead($Builds) = $GUI_CHECKED Then
        If Not GetPartyDead() then Out("Precast Defensive Spirits if possible")
        If Not GetPartyDead() and IsRecharged($sos) then UseSkillEx($sos, -2) 
        If Not GetPartyDead() and Skill_GetSkillbarInfo(2, "IsRecharged" ,5) Then Skill_UseHeroSkill(5,2,-2)
        If Not GetPartyDead() and IsRecharged($pain) then UseSkillEx($pain, -2)     
        If Not GetPartyDead() then Sleep(1500)
        If Not GetPartyDead() and Skill_GetSkillbarInfo(3, "IsRecharged" ,5) Then Skill_UseHeroSkill(5,3,-2)
        If Not GetPartyDead() then Sleep(1500)
        If Not GetPartyDead() and IsRecharged($bs) then UseSkillEx($bs, -2) 
        If Not GetPartyDead() and Skill_GetSkillbarInfo(4, "IsRecharged" ,5) Then Skill_UseHeroSkill(5,4,-2)
        If Not GetPartyDead() and IsRecharged($vamp) then UseSkillEx($vamp, -2) 
        If Not GetPartyDead() and Skill_GetSkillbarInfo(3, "IsRecharged" ,7) then Skill_UseHeroSkill(7,3,Party_GetMyPartyHeroInfo(4, "AgentID"))
    EndIf
    If Not GetPartyDead() then Party_CommandHero(4, -13947.86, -2250.88)
    If Not GetPartyDead() then Sleep(6000)
    If Not GetPartyDead() then Party_CancelHero(4)
    AggroMoveToEx(-14437.85, -2362.25, 150)
    AggroMoveToEx(-13967.48, -1656.00, 150)

    If Not GetPartyDead() then Out("Oni Spawn Point")
    AggroMoveToEx(-11999.42, -4100.08, 150)
    AggroMoveToEx(-11014.63, -6204.00, 150)

    If Not GetPartyDead() then Out("Kill Rot Wallow")
    AggroMoveToEx(-8446.23, -5402.07, 150)
    AggroMoveToEx(-6917.16, -4646.15, 150)
    AggroMoveToEx(-5230.77, -4663.20, 150)
    AggroMoveToEx(-7164.92, -7365.83, 150)
    AggroMoveToEx(-3134.56, -7523.34, 150)
    AggroMoveToEx(97.45, -9296.17, 150)

    If Not GetPartyDead() then Out("Oni Spawn Point")
    AggroMoveToEx(2102.55, -8464.81, 150)
    AggroMoveToEx(4912.55, -7074.77, 150)
    AggroMoveToEx(6431.07, -8751.93, 150)

    If Not GetPartyDead() then Out("Kill Rot Wallow")
    AggroMoveToEx(5095.10, -6959.62, 150)
    AggroMoveToEx(5656.60, -3676.80, 150)
    AggroMoveToEx(6753.56, 222.45, 150)
    AggroMoveToEx(3763.82, 1040.80, 150)
    AggroMoveToEx(1708.60, 1520.75, 150)
    AggroMoveToEx(561.35, 591.78, 150)

    If Not GetPartyDead() then Out("Move To Shrine")
    AggroMoveToEx(-477.48, -1325.30, 150)
    If Not GetPartyDead() then Sleep(3000)

    If GetPartyDead() Then
        If GetPartyDefeated() Then Return 
        Out("Damn son, you are a disappointment")
        Out("Restart from the first Shrine")      
        Do
            ; Check for disconnection while waiting for resurrection
            If CheckForDisconnectAndRestart() Then
                Out("Disconnect detected while waiting for resurrection, stopping...")
                Return
            EndIf

            Sleep(250)
        Until GetPartyDead() = False
    Else
        $RezShrine = 2
    EndIf
EndFunc ;==> FarmToSecondShrine

Func FarmToThirdShrine()
    ; Check for disconnection before farming to third shrine
    If CheckForDisconnectAndRestart() Then
        Out("Disconnect detected, stopping farm to third shrine...")
        Return
    EndIf

    If Not GetPartyDead() then Out("Kill Nagas")
    AggroMoveToEx(68.80, -2812.41, 150)

    If Not GetPartyDead() then Out("Kill Rot Wallow")
    AggroMoveToEx(-1975.36, -2447.14, 150)
    AggroMoveToEx(-2743.20, -718.23, 150)
    AggroMoveToEx(-6319.35, -3363.90, 150)
    AggroMoveToEx(-8786.40, 252.08, 150)

    If Not GetPartyDead() then Out("Kill Yetis before cave")
    AggroMoveToEx(-10728.21, 1438.67, 150)
    AggroMoveToEx(-10846.09, 5862.79, 150)

    If Not GetPartyDead() then Out("Kill the Monk Boss")
    AggroMoveToEx(-8582.28, 8468.58, 150)

    If Not GetPartyDead() then Out("Kill Yetis after cave")
    AggroMoveToEx(-6679.04, 7025.30, 150)
    AggroMoveToEx(-4679.15, 7633.20, 150)
    AggroMoveToEx(-2548.89, 8731.90, 150)
    AggroMoveToEx(-4619.15, 6394.57, 150)
    AggroMoveToEx(-5406.97, 3420.06, 150)

    If Not GetPartyDead() then Out("Move close to the same Shrine as before")
    AggroMoveToEx(-6323.47, 622.15, 150)
    AggroMoveToEx(-2498.45, 1072.42, 150)
    AggroMoveToEx(30.04, 960.86, 150)

    If GetPartyDead() Then
        If GetPartyDefeated() Then Return  
        Out("Seriously? Disgraceful!!!")
        Out("Restart from the second Shrine")     
        Do
            ; Check for disconnection while waiting for resurrection
            If CheckForDisconnectAndRestart() Then
                Out("Disconnect detected while waiting for resurrection, stopping...")
                Return
            EndIf

            Sleep(250)
        Until GetPartyDead() = False
    Else
        $RezShrine = 3
    EndIf
EndFunc ;==> FarmToThirdShrine

Func FarmToFourthShrine()
    ; Check for disconnection before farming to fourth shrine
    If CheckForDisconnectAndRestart() Then
        Out("Disconnect detected, stopping farm to fourth shrine...")
        Return
    EndIf

    If Not GetPartyDead() then Out("Kill Rot Wallow")
    AggroMoveToEx(1967.51, 3169.33, 150)
    AggroMoveToEx(4816.43, 5845.84, 150)
    AggroMoveToEx(6774.16, 7644.99, 150)

    If Not GetPartyDead() then Out("Kill Nagas")
    AggroMoveToEx(8587.53, 6622.35, 150)
    AggroMoveToEx(10557.92, 6783.90, 150)
    AggroMoveToEx(10919.80, 9021.05, 150)

    If Not GetPartyDead() then Out("Move to Shrine")
    AggroMoveToEx(13768.36, 7637.01, 150)
    AggroMoveToEx(14666.68, 9607.33, 150)
    If Not GetPartyDead() then Sleep(3000)

    If GetPartyDead() Then
        If GetPartyDefeated() Then Return   
        Out("This is somewhat embarrassing!")
        Out("Restart from the third Shrine")    
        Do
            ; Check for disconnection while waiting for resurrection
            If CheckForDisconnectAndRestart() Then
                Out("Disconnect detected while waiting for resurrection, stopping...")
                Return
            EndIf

            Sleep(250)
        Until GetPartyDead() = False
    Else
        $RezShrine = 4
    EndIf
EndFunc ;==> FarmToFourthShrine

Func FarmToEnd()
    ; Check for disconnection before farming to end
    If CheckForDisconnectAndRestart() Then
        Out("Disconnect detected, stopping farm to end...")
        Return
    EndIf

    If Not GetPartyDead() then Out("Oni Spawn Point")
    AggroMoveToEx(15533.14, 6853.51, 150)
    AggroMoveToEx(15695.05, 4637.03, 150)
    AggroMoveToEx(13542.48, 2297.27, 150)

    If Not GetPartyDead() then Out("Kill Nagas")
    AggroMoveToEx(13171.07, 39.77, 150)
    AggroMoveToEx(11701.90, -3727.37, 150)
    AggroMoveToEx(11770.87, -7040.32, 150)

    If Not GetPartyDead() then Out("Kill Outcasts")
    If World_GetWorldInfo("FoesToKill") > 0 then AggroMoveToEx(14650.99, -9058.19, 150)
    If World_GetWorldInfo("FoesToKill") > 0 then AggroMoveToEx(14872.70, -5791.33, 150)

    If Not GetPartyDead() and World_GetWorldInfo("FoesToKill") > 0 Then
        If Not GetPartyDead() then Out("Looks like we missed a patrol")
        If Not GetPartyDead() then Out("!!!Go get them!!!")
        If World_GetWorldInfo("FoesToKill") > 0 then AggroMoveToEx(11385.53, -7817.82, 150)
        If World_GetWorldInfo("FoesToKill") > 0 then AggroMoveToEx(7756.05, -7611.91, 150)
        If World_GetWorldInfo("FoesToKill") > 0 then AggroMoveToEx(5039.12, -7104.21, 150)
        If World_GetWorldInfo("FoesToKill") > 0 then AggroMoveToEx(5410.23, -3772.06, 150)
        If World_GetWorldInfo("FoesToKill") > 0 then AggroMoveToEx(1190.87, -1992.54, 150)
        If World_GetWorldInfo("FoesToKill") > 0 then AggroMoveToEx(2043.36, 1272.71, 150)
        If World_GetWorldInfo("FoesToKill") > 0 then AggroMoveToEx(6404.70, 766.38, 150)
        If World_GetWorldInfo("FoesToKill") > 0 then AggroMoveToEx(6089.76, -2339.20, 150)       
    EndIf  

    If GetPartyDead() Then
        If GetPartyDefeated() Then Return   
        Out("Boy oh boy ... ")
        Out("Restart from the fifth Shrine")    
        Do
            ; Check for disconnection while waiting for resurrection
            If CheckForDisconnectAndRestart() Then
                Out("Disconnect detected while waiting for resurrection, stopping...")
                Return
            EndIf

            Sleep(250)
        Until GetPartyDead() = False
    Else
        $RezShrine = 0
    EndIf
EndFunc ;==> FarmToEnd
