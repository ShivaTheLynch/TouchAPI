#cs
;;; Drazach Thicket Vanquisher - Kurzick Points Farmer
; You run in Hard Mode
; Possible valuable drops: Gold q9 Echovald Forest drops

; Author: Bubbletea

#ce

#RequireAdmin
#include "../../API/_GwAu3.au3"
#include "GwAu3_AddOns.au3"

; Map IDs used in this farm script
Global Const $FARM_MAPS[4] = [$MAP_ID_DrazachThicket, $Town_ID_EternalGrove, $Town_ID_Great_Temple_of_Balthazar, $Town_ID_HouseZuHeltzer]

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
    Out("Auto-start requested for character: " & $charName)
    
    ; Set the character in the GUI combo box
    Sleep(100) ; Wait for GUI to be fully created
    GUICtrlSetData($Input, $charName)
    Out("Character set to: " & $charName)
    
    ; Set the global variables that Core_AutoStart() needs
    $g_s_MainCharName = $charName
    $g_bAutoStart = True
    
    ; Initialize the core with the character name
    Out("Initializing core for character: " & $charName)
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
    GUICtrlSetState($Input, $GUI_DISABLE)
    GUICtrlSetData($Button, "Pause")
    GUICtrlSetState($RenderingBox, $GUI_ENABLE)
    GUICtrlSetState($HardmodeCheckbox, $GUI_DISABLE)
    GUICtrlSetState($Builds, $GUI_DISABLE)
    GUICtrlSetState($ResignGateTrickBox, $GUI_DISABLE)
    GUICtrlSetState($DonateBox, $GUI_DISABLE)
    GUICtrlSetState($PconsBox, $GUI_DISABLE)
    
    ; Update window title
    WinSetTitle($mainGui, "", Player_GetCharname() & " - BubbleTea's Kurzick Farmer")
    
    ; Update statistics
    $KurzickTitle = GetKurzickTitle()
    Global Const $KurzickPointsStart = GetKurzickTitlePoints()
    $KurzickPointsGained = GetKurzickTitlePoints() - $KurzickPointsStart
    UpdateStatistics()
    
    Out("Auto-start completed for character: " & $charName)
    Out("Character selected and bot is now running!")
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
    If CheckForDisconnect() Then
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
    If CheckForDisconnect() Then
        Out("Disconnect detected, stopping bot...")
        Return
    EndIf

    If GetKurzickFaction() >= (GetMaxKurzickFaction() - 25000) Then DonateDemPoints()

    While (CountSlots() > 4)
        ; Check for disconnection in farm loop
        If CheckForDisconnect() Then
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
        CombatLoop()
        If GetKurzickFaction() >= (GetMaxKurzickFaction() - 25000) Then DonateDemPoints()
    WEnd

    If (CountSlots() < 5) Then
        ; Check for disconnection before inventory management
        If CheckForDisconnect() Then
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
        If GetKurzickFaction() >= (GetMaxKurzickFaction() - 25000) Then DonateDemPoints()
    EndIf
EndFunc

Func MapP()

	; Check for disconnection before traveling
	If CheckForDisconnect() Then
		Out("Disconnect detected, stopping travel...")
		Return
	EndIf

	; Load builds, if it is the first run
	If GUICtrlRead($Builds) = $GUI_CHECKED and $RunCount = 0 Then
		; When Option is chosen and we are at the first Run, then we load the Hero_Builds
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

    ;~ Checks if you are already in Eternal Grove -> if not travel there
	If Map_GetMapID() <> $Town_ID_EternalGrove Then
		Out("Travelling to Eternal Grove")
		RndTravel($Town_ID_EternalGrove)
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
	If CheckForDisconnect() Then
		Out("Disconnect detected, stopping gate trick...")
		Return False
	EndIf

	Out("You have chosen the gate trick option.")
    Out("What a wise fella you are!")
    Out("Now take you legs and run to the gate!!!")

	MoveTo(-5928.21, 14269.09)
	Map_Move(-6550, 14550)
	Map_WaitMapLoading($MAP_ID_DrazachThicket, 1)
	Sleep(2000)

    MoveTo(-3718.32, -16473.64)
	Map_Move(-3000, -16850)
	Map_WaitMapLoading($Town_ID_EternalGrove, 0)
	Sleep(2000)
	Return True
EndFunc ;==>FastWayOut

; Here, the Magic happens
Func CombatLoop()

	; Check for disconnection before starting combat
	If CheckForDisconnect() Then
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
	If CheckForDisconnect() Then
		Out("Disconnect detected, stopping farm...")
		Return
	EndIf

	Out("Exiting Outpost")
	MoveTo(-5928.21, 14269.09)
	Map_Move(-6450, 14550)
	Map_WaitMapLoading($MAP_ID_DrazachThicket, 1)

	Sleep(1000)
	$RunTimer = TimerInit()

	FarmDrazachThicket()
	
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
		If CheckForDisconnect() Then
			Out("Disconnect detected before resign, stopping...")
			Return
		EndIf

		Resign()
		Sleep(5000)
		Map_ReturnToOutpost()
		Sleep(5000)
		Map_WaitMapLoading($Town_ID_EternalGrove, 0)
		Sleep(5000)
	Else
		; Check for disconnection before traveling
		If CheckForDisconnect() Then
			Out("Disconnect detected before travel, stopping...")
			Return
		EndIf

		RndTravel($Town_ID_EternalGrove)
        Sleep(5000)
	EndIf
	Memory_Clear()
EndFunc


Func FarmDrazachThicket()

    ; Check for disconnection before starting farm
    If CheckForDisconnect() Then
        Out("Disconnect detected, stopping farm...")
        Return
    EndIf

    If GetPartyDead() Then Return
    GetBlessing()
    $RezShrine = 1
    
    Out("Now let's Farm some Kurzick Points")
    If GetPartyDefeated() then Return
    Do
        ; Check for disconnection in first farm loop
        If CheckForDisconnect() Then
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
        If CheckForDisconnect() Then
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
        If CheckForDisconnect() Then
            Out("Disconnect detected in third farm loop, stopping...")
            Return
        EndIf

        If GetPartyDefeated() then ExitLoop
        UseRunEnhancers() ; Consets and stuff like that
        FarmToFourthShrine()
    Until $RezShrine = 4 or GetPartyDefeated()

    If GetPartyDefeated() then Return
    Do
        ; Check for disconnection in fourth farm loop
        If CheckForDisconnect() Then
            Out("Disconnect detected in fourth farm loop, stopping...")
            Return
        EndIf

        If GetPartyDefeated() then ExitLoop
        UseRunEnhancers() ; Consets and stuff like that
        FarmToFifthShrine()
    Until $RezShrine = 5 or GetPartyDefeated()
    
    If GetPartyDefeated() then Return
    Do
        ; Check for disconnection in final farm loop
        If CheckForDisconnect() Then
            Out("Disconnect detected in final farm loop, stopping...")
            Return
        EndIf

        If GetPartyDefeated() then ExitLoop
        UseRunEnhancers() ; Consets and stuff like that
        FarmToEnd()
    Until $RezShrine = 0 or GetPartyDefeated()

EndFunc ;==> FarmDrazachThicket


Func GetBlessing()
    ; Check for disconnection before getting blessing
    If CheckForDisconnect() Then
        Out("Disconnect detected, stopping blessing...")
        Return
    EndIf

    If GetisDead(-2) Then Return
    Out("Get the Blessing!")
    MoveTo(-4927.36, -16385.35)
    MoveTo(-5621.25, -16367.59)
    Local $NPC = GetNearestNPCToAgent(-2, 1320, $GC_I_AGENT_TYPE_LIVING, 1, "NPCFilter")
	MoveTo(Agent_GetAgentInfo($NPC, "X")-20,Agent_GetAgentInfo($NPC, "Y")-20)
    Agent_GoNPC($NPC)
    Sleep(500)
    If GetLuxonFaction() > GetKurzickFaction() Then
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
    ; Check for disconnection before donating
    If CheckForDisconnect() Then
        Out("Disconnect detected, stopping donation...")
        Return
    EndIf

    Out("Travel to House zu Heltzer - Donating Points")
    RndTravel($Town_ID_HouseZuHeltzer)
    Sleep(8000)
    $inventorytrigger = 1

    Out("Go to Kurzick Bureaucrat")
    MoveTo(5367.48, 1539.73, 0)
    Local $NPC = GetNearestNPCToAgent(-2, 1320, $GC_I_AGENT_TYPE_LIVING, 1, "NPCFilter")
    Agent_GoNPC($NPC)
    Sleep(1000)
    If GUICtrlRead($DonateBox) = $GUI_CHECKED Then
        Out("Donate the Points")
    Else
        Out("Buy Chunks of Amber")
    EndIf
    While GetKurzickFaction() >= 5000
        If GUICtrlRead($DonateBox) = $GUI_CHECKED Then
            Ui_Dialog(0x87)
            sleep(1000)
            Game_DonateFaction("kurzick")
            sleep(1000)
        Else
            Ui_Dialog(0x84)
            sleep(1000)
            Ui_Dialog(0x800101)
            Sleep(1000)
        EndIf
    WEnd

    $KurzPointsGained = GetKurzickTitlePoints() - $KurzPointsStart
    $KurzTitle = GetKurzickTitle()

	UpdateStatistics()
    Return
EndFunc ;==> DonateDemPoints

Func UseRunEnhancers()
    ; Check for disconnection before using enhancers
    If CheckForDisconnect() Then
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
    If CheckForDisconnect() Then
        Out("Disconnect detected, stopping farm to second shrine...")
        Return
    EndIf

    AggroMoveToEx(-6506, -16099, 150)
    AggroMoveToEx(-8581, -15354, 150)

    If Not GetPartyDead() then Out("Clear the first big batch of Enemies")
    AggroMoveToEx(-8627, -13151, 150)
    AggroMoveToEx(-6128.70, -11242.96, 150)
    AggroMoveToEx(-5173.57, -10858.66, 150)
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
    If Not GetPartyDead() then Party_CommandHero(4, -6370.24, -9117.06)
    If Not GetPartyDead() then Sleep(6000)
    If Not GetPartyDead() then Party_CancelHero(4)

    If Not GetPartyDead() then Out("Kill the Mesmer Boss")
    AggroMoveToEx(-6368.70, -9313.60, 150)
    AggroMoveToEx(-7827.89, -9681.69, 150)

    If Not GetPartyDead() then Out("Kill smaller groups")
    AggroMoveToEx(-6021, -8358, 150)
    AggroMoveToEx(-5184, -6307, 150)
    AggroMoveToEx(-4643, -5336, 150)
    AggroMoveToEx(-7368, -6043, 150)
    AggroMoveToEx(-9514, -6539, 150)
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
    If Not GetPartyDead() then Party_CommandHero(4, -10833.20, -7569.52)
    If Not GetPartyDead() then Sleep(6000)
    If Not GetPartyDead() then Party_CancelHero(4)

    If Not GetPartyDead() then Out("Kill the Necro Boss")
    AggroMoveToEx(-10988, -8177, 150)
    AggroMoveToEx(-11388, -7827, 150)

    If Not GetPartyDead() then Out("Kill small groups north")
    AggroMoveToEx(-11291, -5987, 150)
    AggroMoveToEx(-11380, -3787, 150)
    AggroMoveToEx(-10641, -1714, 150)

    If Not GetPartyDead() then Out("Oni spawn point")
    AggroMoveToEx(-8659.20, -2268.30, 150)

    If Not GetPartyDead() then Out("Undergrowth Group")
    AggroMoveToEx(-7019.81, -976.18, 150)
    AggroMoveToEx(-4464.77, 780.87, 150)

    If Not GetPartyDead() then Out("Move To Shrine")
    AggroMoveToEx(-1355.74, -914.94, 150)
    If Not GetPartyDead() then Sleep(3000)

    If GetPartyDead() Then
        If GetPartyDefeated() Then Return 
        Out("Damn son, you are a disappointment")
        Out("Restart from the first Shrine")      
        Do
            Sleep(250)
        Until GetPartyDead() = False
    Else
        $RezShrine = 2
    EndIf
EndFunc ;==> FarmToSecondShrine

Func FarmToThirdShrine()
    ; Check for disconnection before farming to third shrine
    If CheckForDisconnect() Then
        Out("Disconnect detected, stopping farm to third shrine...")
        Return
    EndIf

    If Not GetPartyDead() then Out("Move back to next groups North West")
    AggroMoveToEx(-4464.77, 780.87, 150)
    AggroMoveToEx(-7019.81, -976.18, 150)
    AggroMoveToEx(-10575, 489, 150)
    AggroMoveToEx(-11266, 2581, 150)
    AggroMoveToEx(-10444, 4234, 150)
    AggroMoveToEx(-12820, 4153, 150)

    If Not GetPartyDead() then Out("Oni Spawn Point")
    AggroMoveToEx(-12804, 6357, 150)

    If Not GetPartyDead() then Out("Kill Mantis")
    AggroMoveToEx(-12074, 8448, 150)
    AggroMoveToEx(-10212.96, 10309.16, 150)
    AggroMoveToEx(-8211.33, 11407.54, 150)

    If Not GetPartyDead() then Out("Oni Spawn Point")
    AggroMoveToEx(-7754.69, 9436.11, 150)

    If Not GetPartyDead() then Out("Kill Wardens")
    AggroMoveToEx(-6167.01, 9447.13, 150)
    AggroMoveToEx(-4815.21, 10528.07, 150)
    AggroMoveToEx(-5479.61, 7343.60, 150)
    AggroMoveToEx(-5289.82, 4998.54, 150)
    AggroMoveToEx(-2484.76, 7233.19, 150)
    AggroMoveToEx(-3367.10, 9928.76, 150)

    If Not GetPartyDead() then Out("Kill the Ranger Boss")
    AggroMoveToEx(-3394.30, 11746.05, 150)
    AggroMoveToEx(-4869.57, 12948.64, 150)
    AggroMoveToEx(-5932.44, 13806.47, 150)

    If Not GetPartyDead() then Out("Kill Wardens and Dragon Moss")
    AggroMoveToEx(-4848.12, 15585.97, 150)

    If Not GetPartyDead() then Out("Move to Shrine")
    AggroMoveToEx(-8019.13, 18330.92, 150)
    If Not GetPartyDead() then Sleep(3000)

    If GetPartyDead() Then
        If GetPartyDefeated() Then Return  
        Out("Seriously? Disgraceful!!!")
        Out("Restart from the second Shrine")     
        Do
            ; Check for disconnection while waiting for resurrection
            If CheckForDisconnect() Then
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
    If CheckForDisconnect() Then
        Out("Disconnect detected, stopping farm to fourth shrine...")
        Return
    EndIf

    If Not GetPartyDead() then Out("Move back to next Wardens")
    AggroMoveToEx(-5701.15, 16202.36, 150)
    AggroMoveToEx(-3141.18, 16025.75, 150)
    AggroMoveToEx(-787.45, 15014.48, 150)
    AggroMoveToEx(1462.83, 15520.20, 150)

    If Not GetPartyDead() then Out("Oni Spawn Point")
    AggroMoveToEx(4282.75, 14447.79, 150)

    If Not GetPartyDead() then Out("Kill more Wardens")
    AggroMoveToEx(4605.17, 12623.42, 150)
    AggroMoveToEx(2966.67, 11883.08, 150)
    AggroMoveToEx(1147.05, 9904.27, 150)
    AggroMoveToEx(-1241.19, 8426.36, 150)
    AggroMoveToEx(1612.73, 10091.67, 150)
    AggroMoveToEx(3292.36, 10628.14, 150)
    AggroMoveToEx(4957.04, 8302.28, 150)
    AggroMoveToEx(7123.86, 5813.80, 150)
    AggroMoveToEx(8363.76, 9446.83, 150)
    AggroMoveToEx(8723.25, 11237.47, 150)
    AggroMoveToEx(7363.71, 13697.35, 150)
    AggroMoveToEx(10668.76, 11515.62, 150)
    AggroMoveToEx(13930.39, 10779.55, 150)

    If Not GetPartyDead() then Out("Move to Shrine")
    AggroMoveToEx(15884.81, 9224.07, 150)
    If Not GetPartyDead() then Sleep(3000)

    If GetPartyDead() Then
        If GetPartyDefeated() Then Return   
        Out("This is somewhat embarrassing!")
        Out("Restart from the third Shrine")    
        Do
            ; Check for disconnection while waiting for resurrection
            If CheckForDisconnect() Then
                Out("Disconnect detected while waiting for resurrection, stopping...")
                Return
            EndIf

            Sleep(250)
        Until GetPartyDead() = False
    Else
        $RezShrine = 4
    EndIf
EndFunc ;==> FarmToFourthShrine

Func FarmToFifthShrine()
    ; Check for disconnection before farming to fifth shrine
    If CheckForDisconnect() Then
        Out("Disconnect detected, stopping farm to fifth shrine...")
        Return
    EndIf

    If Not GetPartyDead() then Out("Move to next Wardens")
    AggroMoveToEx(14685.91, 7077.44, 150)
    AggroMoveToEx(11869.74, 5679.88, 150)
    AggroMoveToEx(8744.54, 4192.64, 150)
    AggroMoveToEx(6187.57, 6313.87, 150)
    AggroMoveToEx(9159.87, 3654.00, 150)
    AggroMoveToEx(11257.36, 338.60, 150)

    If Not GetPartyDead() then Out("Kill Undergrowth Groups")
    AggroMoveToEx(8844.41, 303.82, 150)
    AggroMoveToEx(5613.70, 296.42, 150)
    AggroMoveToEx(2832.80, 3850.74, 150)

    If Not GetPartyDead() then Out("Kill more Warden")
    AggroMoveToEx(4588.24, 5461.12, 150)
    AggroMoveToEx(-599.41, 3401.40, 150)

    AggroMoveToEx(-1528.55, 5116.05, 150)
    AggroMoveToEx(-1292.70, 2307.54, 150)

    If Not GetPartyDead() then Out("Move to Shrine")
    AggroMoveToEx(-1257.87, -1004.89, 150)
    If Not GetPartyDead() then Sleep(3000)

    If GetPartyDead() Then
        If GetPartyDefeated() Then Return  
        Out("Failing at this point? I got no words for you!")
        Out("Restart from the fourth Shrine")     
        Do
            ; Check for disconnection while waiting for resurrection
            If CheckForDisconnect() Then
                Out("Disconnect detected while waiting for resurrection, stopping...")
                Return
            EndIf

            Sleep(250)
        Until GetPartyDead() = False
    Else
        $RezShrine = 5
    EndIf
EndFunc ;==> FarmToFifthShrine

Func FarmToEnd()
    ; Check for disconnection before farming to end
    If CheckForDisconnect() Then
        Out("Disconnect detected, stopping farm to end...")
        Return
    EndIf

    If Not GetPartyDead() then Out("Now let's go to the last Enemies")
    AggroMoveToEx(-2693.82, -4748.93, 150)
    AggroMoveToEx(-454.99, -4876.88, 150)
    AggroMoveToEx(1888.65, -4833.90, 150)
    AggroMoveToEx(4022.13, -5717.67, 150)
    AggroMoveToEx(3528.05, -7154.28, 150)
    AggroMoveToEx(1103.53, -6744.78, 150)
    AggroMoveToEx(455.56, -9067.87, 150)

    If Not GetPartyDead() then Out("Kill the Ritualist Bosses")
    AggroMoveToEx(2772.91, -9397.36, 150)

    If GetPartyDead() Then
        If GetPartyDefeated() Then Return   
        Out("Boy oh boy ... ")
        Out("Restart from the fifth Shrine")    
        Do
            ; Check for disconnection while waiting for resurrection
            If CheckForDisconnect() Then
                Out("Disconnect detected while waiting for resurrection, stopping...")
                Return
            EndIf

            Sleep(250)
        Until GetPartyDead() = False
    Else
        $RezShrine = 0
    EndIf
EndFunc ;==> FarmToEnd
