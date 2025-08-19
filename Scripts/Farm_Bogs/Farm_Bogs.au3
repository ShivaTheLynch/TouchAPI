#cs
;;; Bogroot Growths Farmer - Gold Farming Bot
; You run in Hard Mode
; Possible valuable drops: Bogroot Growths, Gold items

; Author: Bubbletea (Converted from Drazach Thicket)

#ce

#RequireAdmin
#include "C:/Users/touch/OneDrive/Bureaublad/GwAu3-main/API/_GwAu3.au3"
#include "GwAu3_AddOns.au3"

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
    GUICtrlSetState($BogrootBox, $GUI_DISABLE)
    GUICtrlSetState($PconsBox, $GUI_DISABLE)
    
    ; Update window title
    WinSetTitle($mainGui, "", Player_GetCharname() & " - BubbleTea's Bogroot Farmer")
    
    ; Update statistics
    $BogrootCount = 0
    $GoldItemsGained = 0
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
    If $BotRunning = True Then
        MainFarm()
    Else
        Sleep(1000)
    EndIf
WEnd


; --------- Start of Bot --------------
Func MainFarm()

    While (CountSlots() > 4)
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
        FarmBogrootGrowths()
    WEnd

    If (CountSlots() < 5) Then
        If Not $BotRunning Then
            Out("Bot Paused")
            GUICtrlSetState($Button, $GUI_ENABLE)
            GUICtrlSetData($Button, "Resume")
			GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")
            Return
        EndIf

        Inventory()
    EndIf
EndFunc

Func MapP()

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

    ;~ Checks if you are already in Bogroot Growths area -> if not travel there
	    If Map_GetMapID() <> $GC_I_MAP_ID_BOGROOT_GROWTHS_LVL1 Then
        Out("Travelling to Bogroot Growths area")
        RndTravel($GC_I_MAP_ID_BOGROOT_GROWTHS_LVL1)
        Sleep(5000)
    EndIf
	
	;~ HardMode
	If GUICtrlRead($HardmodeCheckbox) = $GUI_CHECKED Then
        Game_SwitchMode($DIFFICULTY_HARD)
    Else
        Game_SwitchMode($DIFFICULTY_NORMAL)
    EndIf
	
EndFunc



; Here, the Magic happens
Func CombatLoop()

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

	Out("Starting Bogroot Growths dungeon run")
	Sleep(1000)
	$RunTimer = TimerInit()

	FarmBogrootGrowths()
	
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
		Resign()
		Sleep(5000)
		Map_ReturnToOutpost()
		Sleep(2000)
		RndTravel($GC_I_MAP_ID_GADDS_ENCAMPMENT)
		Sleep(5000)
	Else
		RndTravel($GC_I_MAP_ID_GADDS_ENCAMPMENT)
        Sleep(5000)
	EndIf
	Memory_Clear()
EndFunc



    





Func GetBlessing()
    If GetisDead(-2) Then Return
    Out("Get the Blessing!")
    MoveTo(-8394.10, -9863.09)
    Local $NPC = GetNearestNPCToAgent(-2, 1320, $GC_I_AGENT_TYPE_LIVING, 1, "NPCFilter")
	MoveTo(Agent_GetAgentInfo($NPC, "X")-20,Agent_GetAgentInfo($NPC, "Y")-20)
    Agent_GoNPC($NPC)
    Sleep(500)
    	If GetPartyDefeated() Then
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


Func FarmBogrootGrowths()
    Out("Starting Bogroot Growths dungeon run...")
    
    ; Travel to Gadd's Camp first
    If Map_GetMapID() <> $GC_I_MAP_ID_GADDS_ENCAMPMENT Then
        Out("Travelling to Gadd's Camp")
        RndTravel($GC_I_MAP_ID_GADDS_ENCAMPMENT)
        Sleep(5000)
    EndIf
    
    ; Switch to Hard Mode if enabled
    If GUICtrlRead($HardmodeCheckbox) = $GUI_CHECKED Then
        Game_SwitchMode($DIFFICULTY_HARD)
        Out("Hard Mode enabled")
    Else
        Game_SwitchMode($DIFFICULTY_NORMAL)
        Out("Normal Mode enabled")
    EndIf
    
    ; Make way to portal
    Out("Making way to portal")
    MoveTo(-10018, -21892)
    MoveTo(-9550, -20400)
    MoveTo(-9451, -19766)
    Sleep(2000)
    
    ; Wait for Sparkfly Swamp to load
    Out("Waiting for Sparkfly Swamp to load...")
    Map_WaitMapLoading($GC_I_MAP_ID_SPARKFLY_SWAMP)
    Sleep(2000)
    
    ; Make way to Bogroot dungeon entrance (use AggroMoveToEx to fight while moving)
    Out("Making way to Bogroot dungeon")
    AggroMoveToEx(-4559, -14406, 150)
    AggroMoveToEx(-5204, -9831, 150)
    AggroMoveToEx(-928, -8699, 150)
    AggroMoveToEx(4200, -4897, 150)
    AggroMoveToEx(4671, 7094, 150)
    
    ; Continue to dungeon entrance (use AggroMoveToEx to fight while moving)
    AggroMoveToEx(11025, 11710, 150)
    AggroMoveToEx(14624, 19314, 150)
    AggroMoveToEx(14650, 19417, 150)
    AggroMoveToEx(12280, 22585, 150)
    
    ; Enter the dungeon
    Out("Entering Bogroot Growths dungeon")
    MoveTo(12228, 22677)
    MoveTo(12470, 25036)
    $mapLoaded = False
    While Not $mapLoaded
        MoveTo(12968, 26219)
        		MoveTo(13097, 26393)
        Sleep(2000)
        $mapLoaded = Map_WaitMapLoading($GC_I_MAP_ID_BOGROOT_GROWTHS_LVL1)
    WEnd
    
    ; Clear first floor
    Out("Clearing first floor...")
    ClearBogrootFloor1()
    
    ; Clear second floor
    Out("Clearing second floor...")
    ClearBogrootFloor2()
    
    ; Exit and collect rewards
    Out("Exiting dungeon to collect rewards")
    MoveTo(14876, 632)
    		MoveTo(14700, 450)
    Sleep(2000)
            $mapLoaded = Map_WaitMapLoading($GC_I_MAP_ID_SPARKFLY_SWAMP)
    
    ; Get quest reward
    Out("Collecting quest reward")
    MoveTo(12061, 22485)
    Local $NPC = GetNearestNPCToAgent(-2, 1320, $GC_I_AGENT_TYPE_LIVING, 1, "NPCFilter")
    Agent_GoNPC($NPC)
    Sleep(1000)
    Ui_Dialog(0x833907)  ; Get reward
    
    Out("Bogroot Growths dungeon run completed!")
    $RunCount += 1
    $SuccessCount += 1
    UpdateStatistics()
    Return
EndFunc ;==> FarmBogrootGrowths

; Clear first floor of Bogroot Growths dungeon
Func ClearBogrootFloor1()
    Out("------------------------------------")
    Out("First floor")
    
    ; Use conset if Hard Mode is enabled
    If GUICtrlRead($HardmodeCheckbox) = $GUI_CHECKED Then
        UseConset()
    EndIf
    
    ; First section - move to duo area
    AggroMoveToEx(17619, 2687, 150)
    AggroMoveToEx(18168, 4788, 150)
    AggroMoveToEx(18880, 7749, 150)
    
    ; Get blessing
    Out("Getting blessing")
    MoveTo(19063, 7875)
    Local $NPC = GetNearestNPCToAgent(-2, 1320, $GC_I_AGENT_TYPE_LIVING, 1, "NPCFilter")
    Agent_GoNPC($NPC)
    Sleep(250)
    Ui_Dialog(0x84)
    Sleep(250)
    
    AggroMoveToEx(13080, 7822, 150)
    AggroMoveToEx(9946, 6963, 150)
    AggroMoveToEx(6078, 4483, 150)
    
    ; Second section - massive frog cave
    AggroMoveToEx(4960, 1984, 150)
    AggroMoveToEx(3567, -278, 150)
    AggroMoveToEx(1763, -607, 150)
    AggroMoveToEx(224, -2238, 150)
    AggroMoveToEx(-1175, -4994, 150)
    AggroMoveToEx(-115, -8569, 150)
    AggroMoveToEx(-1501, -8590, 150)
    
    ; Third section - last cave
    AggroMoveToEx(-115, -8569, 150)
    AggroMoveToEx(1966, -11018, 150)
    AggroMoveToEx(5775, -12761, 150)
    AggroMoveToEx(6125, -15820, 150)
    Out("Last cave exit")
    MoveTo(7171, -17934)
    
    ; Go through portal to second floor
    Out("Going through portal")
    MoveTo(7171, -17934)
    		MoveTo(7600, -19100)
    Sleep(2000)
    Local $mapLoaded = Map_WaitMapLoading($GC_I_MAP_ID_BOGROOT_GROWTHS_LVL2)
EndFunc

; Clear second floor of Bogroot Growths dungeon
Func ClearBogrootFloor2()
    Out("------------------------------------")
    Out("Second floor")
    
    ; Use conset if Hard Mode is enabled
    If GUICtrlRead($HardmodeCheckbox) = $GUI_CHECKED Then
        UseConset()
    EndIf
    
    ; First section - get blessing and move through caves
    ; Get blessing
    Out("Getting blessing")
    MoveTo(-11072, -5522)
    Local $NPC = GetNearestNPCToAgent(-2, 1320, $GC_I_AGENT_TYPE_LIVING, 1, "NPCFilter")
    Agent_GoNPC($NPC)
    Sleep(250)
    Ui_Dialog(0x84)
    Sleep(250)
    
    AggroMoveToEx(-10931, -4584, 150)
    AggroMoveToEx(-10121, -3175, 150)
    AggroMoveToEx(-9646, -1005, 150)
    AggroMoveToEx(-8548, 601, 150)
    AggroMoveToEx(-7217, 3353, 150)
    AggroMoveToEx(-8229, 5519, 150)
    AggroMoveToEx(-9434, 8479, 150)
    AggroMoveToEx(-8182, 10187, 150)
    AggroMoveToEx(-6440, 11526, 150)
    AggroMoveToEx(-3963, 10050, 150)
    AggroMoveToEx(-1992, 11950, 150)
    AggroMoveToEx(-719, 11140, 150)
    
    ; Second section - beetle zone
    AggroMoveToEx(3130, 12731, 150)
    AggroMoveToEx(3535, 13860, 150)
    AggroMoveToEx(5717, 13357, 150)
    AggroMoveToEx(6945, 9820, 150)
    AggroMoveToEx(8117, 7465, 150)
    AggroMoveToEx(8398, 4358, 150)
    
    ; Third section - keyboss and final area
    AggroMoveToEx(9829, -1175, 150)
    AggroMoveToEx(10932, -5203, 150)
    AggroMoveToEx(13305, -6475, 150)
    AggroMoveToEx(16841, -5619, 150)
    
    ; Pick up items
    Sleep(500)
    PickUpItems()
    
    ; Open dungeon door
    ClearTarget()
    For $i = 1 To 3
        MoveTo(17888, -6243)
        Sleep(GetPing() + 500)
        TargetNearestItem()
        ActionInteract()
        Sleep(GetPing() + 500)
        TargetNearestItem()
        ActionInteract()
        Sleep(GetPing() + 500)
    Next
    
    AggroMoveToEx(18363, -8696, 150)
    AggroMoveToEx(16631, -11655, 150)
    AggroMoveToEx(19122, -12284, 150)
    AggroMoveToEx(19597, -11553, 150)
    
    ; Boss area
    Out("------------------------------------")
    Out("Boss area")
    Local $largeAggroRange = 300
    
    While Not GetPartyDead()
        AggroMoveToEx(17494, -14149, $largeAggroRange)
        AggroMoveToEx(14641, -15081, $largeAggroRange)
        AggroMoveToEx(13934, -17384, $largeAggroRange)
        AggroMoveToEx(14365, -17681, $largeAggroRange)
        AggroMoveToEx(15286, -17662, $largeAggroRange)
        AggroMoveToEx(15804, -19107, $largeAggroRange)
        
        ; Check if boss is defeated
        If CheckAreaRange(15910, -19134, 1250) Then
            ExitLoop
        EndIf
    WEnd
    
    ; Open chest
    MoveTo(15910, -19134)
    MoveTo(15329, -18948)
    MoveTo(15086, -19132)
    Out("Opening chest")
    
    ; Loot chest
    For $i = 1 To 2
        TargetNearestItem()
        ActionInteract()
        Sleep(2500)
        PickUpItems()
        Sleep(5000)
    Next
EndFunc

Func UseRunEnhancers()
    If GUICtrlRead($PconsBox) = $GUI_CHECKED Then
        Out("Eat some juicy Snacks.")
        If GetPartyDefeated() Then Return
        If FindConset() = True Then UseConset()
        If FindSummoningStone() = True Then UseSummoningStone()
    EndIf
EndFunc ;==> UseRunEnhancers

Func FarmToSecondShrine()
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
            Sleep(250)
        Until GetPartyDead() = False
    Else
        $RezShrine = 2
    EndIf
EndFunc ;==> FarmToSecondShrine

Func FarmToThirdShrine()
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
            Sleep(250)
        Until GetPartyDead() = False
    Else
        $RezShrine = 3
    EndIf
EndFunc ;==> FarmToThirdShrine

Func FarmToFourthShrine()
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
            Sleep(250)
        Until GetPartyDead() = False
    Else
        $RezShrine = 4
    EndIf
EndFunc ;==> FarmToFourthShrine

Func FarmToEnd()
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
            Sleep(250)
        Until GetPartyDead() = False
    Else
        $RezShrine = 0
    EndIf
EndFunc ;==> FarmToEnd
