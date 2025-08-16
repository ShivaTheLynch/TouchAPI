#cs
;;; BubbleTea's Chestruns

; Author: Bubbletea
#ce

#RequireAdmin
#include "../../API/_GwAu3.au3"
#include "GwAu3_AddOns.au3"

;~ Include Tyrian + EotN Chestruns
#include "Chestruns\Tyrian_EotN_Chestruns\DivinersAscent.au3"
#include "Chestruns\Tyrian_EotN_Chestruns\PeriditionRock.au3"
#include "Chestruns\Tyrian_EotN_Chestruns\VloxenExcavation.au3"
#include "Chestruns\Tyrian_EotN_Chestruns\VultureDrifts.au3"
#include "Chestruns\Tyrian_EotN_Chestruns\WitmansFolly.au3"

;~ Include Canthan Chestruns
#include "Chestruns\Canthan_Chestruns\BukdekByway.au3"
#include "Chestruns\Canthan_Chestruns\GyalaHatchery.au3"
#include "Chestruns\Canthan_Chestruns\MorostavTrail.au3"
#include "Chestruns\Canthan_Chestruns\NahpuiQuarter.au3"
#include "Chestruns\Canthan_Chestruns\PongmeiValleyMaatu.au3"
#include "Chestruns\Canthan_Chestruns\RaisuPalace.au3"
#include "Chestruns\Canthan_Chestruns\RheasCrate.au3"
#include "Chestruns\Canthan_Chestruns\SilentSurf.au3"
#include "Chestruns\Canthan_Chestruns\SunquaVale.au3"

;~ Include Elonian Chestruns
#include "Chestruns\Elonian_Chestruns\DejarinEstate.au3"
#include "Chestruns\Elonian_Chestruns\DomainOfFear.au3"
#include "Chestruns\Elonian_Chestruns\DrakesOnAPlain.au3"
#include "Chestruns\Elonian_Chestruns\GandaraTheMoonFortress.au3"
#include "Chestruns\Elonian_Chestruns\TuraisGateOfDesolationShort.au3"
#include "Chestruns\Elonian_Chestruns\TuraisGateOfDesolationLong.au3"
#include "Chestruns\Elonian_Chestruns\TuraisVentaCemetery.au3"

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

Func MainFarm()

    ;~ Choosing the appropriate Farm based on the Chosen Chestrun
    FarmSwitcher()

    ;~ Bot Loop
    While (CountSlots() > 6)
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
        EndIf
		sleep(2000)
        CombatLoop()
    WEnd

    If (CountSlots() < 7) Then
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


Func FarmSwitcher()
    ; Read the Chosen Chestrun
    If $Chosen_Chestrun = "Multiple Chestruns" Then
        $currentMultRun = $multRunAr[$multRunLoopCounter]
        
        Switch $currentMultRun
            ; Tyrian + Eotn
            Case "Diviners Ascent"
                $Town_ID_Farm = 118
                $MAP_ID_Farm = 110
                $TownString = "Elona Reach"
            Case "Peridition Rock"
                $Town_ID_Farm = 35
                $MAP_ID_Farm = 121
                $TownString = "Ember Light Camp"
             Case "Vloxen Excavation"
                $Town_ID_Farm = 624
                $MAP_ID_Farm = 604
                $TownString = "Vlox's Falls"
            Case "Vulture Drifts"
                $Town_ID_Farm = 116
                $MAP_ID_Farm = 111
                $TownString = "Dunes of Despair"
            Case "Witmans Folly"
                $Town_ID_Farm = 158
                $MAP_ID_Farm = 95
                $TownString = "Port Sledge"
           
            ; Canthan
            Case "Bukdek Byway"
                $Town_ID_Farm = 194
                $MAP_ID_Farm = 240
                $TownString = "Kaineng Center"
            Case "Gyala Hatchery"
                $Town_ID_Farm = 279
                $MAP_ID_Farm = 144
                $TownString = "Leviathan Pits"
            Case "Morostav Trail"
                $Town_ID_Farm = 130
                $MAP_ID_Farm = 205
                $TownString = "Vasburg Armory" 
            Case "Nahpui Quarter"
                $Town_ID_Farm = 51
                $MAP_ID_Farm = 265
                $TownString = "Senjis Corner"
            Case "Pongmei Valley Maatu"
                $Town_ID_Farm = 283
                $MAP_ID_Farm = 211
                $TownString = "Maatu Keep"
            Case "Raisu Palace"
                $Town_ID_Farm = 226
                $MAP_ID_Farm = 233
                $TownString = "Imperial Sanctum"
            Case "Rheas Crate"
                $Town_ID_Farm = 289
                $MAP_ID_Farm = 202
                $TownString = "Seafarers Rest"
            Case "Silent Surf"
                $Town_ID_Farm = 289
                $MAP_ID_Farm = 203
                $TownString = "Seafarers Rest"
            Case "Sunqua Vale"
                $Town_ID_Farm = 214
                $MAP_ID_Farm = 238
                $TownString = "Minister Chos Estate"           

            ; Elonian
            Case "Dejarin Estate"
                $Town_ID_Farm = 426
                $MAP_ID_Farm = 379
                $TownString = "Pogahn Passage"
            Case "Domain of Fear"
                $Town_ID_Farm = 469
                $MAP_ID_Farm = 468
                $TownString = "Gate of Fear"
            Case "Drakes on a Plain"
                $Town_ID_Farm = 425
                $MAP_ID_Farm = 384
                $TownString = "Rilohn Refuge"
            Case "Gandara the Moon Fortress"
                $Town_ID_Farm = 426
                $MAP_ID_Farm = 382
                $TownString = "Pogahn Passage"
            Case "Turais Gate of Desolation Short"
                $Town_ID_Farm = 478
                $MAP_ID_Farm = 386
                $TownString = "Gate of Desolation"
            Case "Turais Gate of Desolation Long"
                $Town_ID_Farm = 478
                $MAP_ID_Farm = 386
                $TownString = "Gate of Desolation"
            Case "Turais Venta Cemetery"
                $Town_ID_Farm = 421
                $MAP_ID_Farm = 387
                $TownString = "Venta Cemetery"
        EndSwitch
        
    Else

        Switch $Chosen_Chestrun
            ; Tyrian + Eotn
            Case "Diviners Ascent"
                $Town_ID_Farm = 118
                $MAP_ID_Farm = 110
                $TownString = "Elona Reach"
            Case "Peridition Rock"
                $Town_ID_Farm = 35
                $MAP_ID_Farm = 121
                $TownString = "Ember Light Camp"
             Case "Vloxen Excavation"
                $Town_ID_Farm = 624
                $MAP_ID_Farm = 604
                $TownString = "Vlox's Falls"
            Case "Vulture Drifts"
                $Town_ID_Farm = 116
                $MAP_ID_Farm = 111
                $TownString = "Dunes of Despair"
            Case "Witmans Folly"
                $Town_ID_Farm = 158
                $MAP_ID_Farm = 95
                $TownString = "Port Sledge"
           
            ; Canthan
            Case "Bukdek Byway"
                $Town_ID_Farm = 194
                $MAP_ID_Farm = 240
                $TownString = "Kaineng Center"
            Case "Gyala Hatchery"
                $Town_ID_Farm = 279
                $MAP_ID_Farm = 144
                $TownString = "Leviathan Pits"
            Case "Morostav Trail"
                $Town_ID_Farm = 130
                $MAP_ID_Farm = 205
                $TownString = "Vasburg Armory" 
            Case "Nahpui Quarter"
                $Town_ID_Farm = 51
                $MAP_ID_Farm = 265
                $TownString = "Senjis Corner"
            Case "Pongmei Valley Maatu"
                $Town_ID_Farm = 283
                $MAP_ID_Farm = 211
                $TownString = "Maatu Keep"
            Case "Raisu Palace"
                $Town_ID_Farm = 226
                $MAP_ID_Farm = 233
                $TownString = "Imperial Sanctum"
            Case "Rheas Crate"
                $Town_ID_Farm = 289
                $MAP_ID_Farm = 202
                $TownString = "Seafarers Rest"
            Case "Silent Surf"
                $Town_ID_Farm = 289
                $MAP_ID_Farm = 203
                $TownString = "Seafarers Rest"
            Case "Sunqua Vale"
                $Town_ID_Farm = 214
                $MAP_ID_Farm = 238
                $TownString = "Minister Chos Estate"           

            ; Elonian
            Case "Dejarin Estate"
                $Town_ID_Farm = 426
                $MAP_ID_Farm = 379
                $TownString = "Pogahn Passage"
            Case "Domain of Fear"
                $Town_ID_Farm = 469
                $MAP_ID_Farm = 468
                $TownString = "Gate of Fear"
            Case "Drakes on a Plain"
                $Town_ID_Farm = 425
                $MAP_ID_Farm = 384
                $TownString = "Rilohn Refuge"
            Case "Gandara the Moon Fortress"
                $Town_ID_Farm = 426
                $MAP_ID_Farm = 382
                $TownString = "Pogahn Passage"
            Case "Turais Gate of Desolation Short"
                $Town_ID_Farm = 478
                $MAP_ID_Farm = 386
                $TownString = "Gate of Desolation"
            Case "Turais Gate of Desolation Long"
                $Town_ID_Farm = 478
                $MAP_ID_Farm = 386
                $TownString = "Gate of Desolation"
            Case "Turais Venta Cemetery"
                $Town_ID_Farm = 421
                $MAP_ID_Farm = 387
                $TownString = "Venta Cemetery"
        EndSwitch
    EndIf
EndFunc

Func MapP($aMapID = $Town_ID_Farm, $aTownString = $TownString)

    ;~ Checks if you are already in the correct town
    If Map_GetMapID() <> $aMapID Then
        Out("Travelling to " & $aTownString)
        RndTravel($aMapID)
    EndIf
    
    If $Chosen_Chestrun = "Multiple Chestruns" Then
        If $multRunHMAr[$multRunLoopCounter] = $DIFFICULTY_HARD Then
            Ui_SetDifficulty($DIFFICULTY_HARD)
        Else
            Ui_SetDifficulty($DIFFICULTY_NORMAL)
        EndIf

    Else
        If GUICtrlRead($HardMODECheckbox) = $GUI_CHECKED Then
            Ui_SetDifficulty($DIFFICULTY_HARD)
        Else
            Ui_SetDifficulty($DIFFICULTY_NORMAL)
        EndIf
    EndIf   

    If GUICtrlRead($Builds) = $GUI_CHECKED Then
        Local $herocount = Party_GetMyPartyInfo("ArrayHeroPartyMemberSize")
        Local $maxpartysize = Map_GetCurrentAreaInfo("MaxPartySize")
        If $herocount <> $maxpartysize-1 Then
            If $herocount = 3 Then
                If $maxpartysize = 6 Then
                    Party_AddHero($HERO_ID_Morgahn)
                    Sleep(500)
                    Party_AddHero($HERO_ID_Hayda)
                    Sleep(500)
                Else
                    Party_AddHero($HERO_ID_Morgahn)
                    Sleep(500)
                    Party_AddHero($HERO_ID_Hayda)
                    Sleep(500)
                    Party_AddHero($HERO_ID_Koss)
                    Sleep(500)
                    Party_AddHero($HERO_ID_Jora)
                    Sleep(500)
                EndIf
            Else
                Party_AddHero($HERO_ID_Koss)
                Sleep(500)
                Party_AddHero($HERO_ID_Jora)
                Sleep(500)
            EndIf
        EndIf
    EndIf        
EndFunc

Func LoadBubblesBuild()    
        ; When Option is chosen and we are at the first Run, then we load the Hero_Builds
        ; Therefore we will go to a 8man Area, so all 7 Herobuilds will be loaded
        Out("Travelling to Great Temple of Balthazar")
        RndTravel($Town_ID_Great_Temple_of_Balthazar)
        Sleep(1000)

        Out("Getting Bubble's Teamsetup")
        Party_KickAllHeroes()
        Sleep(500)
        Out("Add Heroes")

        Party_AddHero($HERO_ID_Melonni)
        Sleep(500)
        Out("Load Melonnis Skillbar")
        Attribute_LoadSkillTemplate("OgmjYyqM7M84d891Hnjrx0bSMA", 1)
        Sleep(500)
        Party_SetHeroAggression(1,2)
        Sleep(500)
        Out("Melonni ready!")

        Party_AddHero($HERO_ID_Mox)
        Sleep(500)
        Out("Load M.O.X.'s Skillbar")
        Attribute_LoadSkillTemplate("OgmjYyqM7M84d891Hnjrx0bSMA", 2)
        Sleep(500)
        Party_SetHeroAggression(2,2)
        Sleep(500)
        Out("M.O.X. ready!")

        Party_AddHero($HERO_ID_Kahmu)
        Sleep(500)
        Out("Load Kahmu's Skillbar")
        Attribute_LoadSkillTemplate("OgmjYyqM7M84d891Hnjrx0bSMA", 3)
        Sleep(500)
        Party_SetHeroAggression(3,2)
        Sleep(500)
        Out("Kahmu ready!")

        Party_AddHero($HERO_ID_Morgahn)
        Sleep(500)
        Out("Load General Morgahn's Skillbar")
        Attribute_LoadSkillTemplate("OQqjYyojKP84d891Hnjrx0bTMA", 4)
        Sleep(500)
        Party_SetHeroAggression(4,2)
        Sleep(500)
        Party_ChangeHeroSkillSlotState(4,8)
		Sleep(500)
        Out("General Morgahn ready!")

        Party_AddHero($HERO_ID_Hayda)
        Sleep(500)
        Out("Load Hayda's Skillbar")
        Attribute_LoadSkillTemplate("OQqjYynjKP84d891Hnjrx0bVMA", 5)
        Sleep(500)
        Party_SetHeroAggression(5,2)
        Sleep(500)
        Out("Hayda ready!")

        Party_AddHero($HERO_ID_Koss)
        Sleep(500)
        Out("Load Koss's Skillbar")
        Attribute_LoadSkillTemplate("OQojENVsKPsl3y9FAAAAAAAAAA", 6)
        Sleep(500)
        Party_SetHeroAggression(6,2)
        Sleep(500)
        Out("Koss ready!")

        Party_AddHero($HERO_ID_Jora)
        Sleep(500)
        Out("Load Jora's Skillbar")
        Attribute_LoadSkillTemplate("OQojENVsKPsl3y9FAAAAAAAAAA", 7)
        Sleep(500)
        Party_SetHeroAggression(7,2)
        Sleep(500)
        Out("Jora ready!")

        Sleep(1000)
        Out("Teamsetup is finished!")
EndFunc 

; Here, the Magic happens
Func CombatLoop()

    ; If Lockpicks are left gogogo
    $LockpicksLeft = GetNumberOfLockpicks()
    if $LockpicksLeft > 0 Then
        
        ; rearrange the arrays for saving already opened chests
        Redim $xChestOldAr[1]
        Redim $yChestOldAr[1]
        $xChestOldAr[0] = 0
        $yChestOldAr[0] = 0

        ; look at what chestrun is to do
        If $Chosen_Chestrun = "Multiple Chestruns" Then
            If $runcounter > $SetsChangeRuns Then
                $runcounter = 1
                $multRunLoopCounter += 1
                If $multRunLoopCounter = $multRunLoop Then
                    $multRunLoopCounter = 0
                EndIf
                $currentMultRun = $multRunAr[$multRunLoopCounter]
                Out("Changing to next Chestrun: " & $currentMultRun)
            EndIf
            
            ; if a new chestrun is on its way, switch to the new one
            If $runcounter = 1 Then FarmSwitcher()
            
            ; Load Bubbles Builds, if chosen for Heroes
            If GUICtrlRead($Builds) = $GUI_CHECKED and $RunCount = 0 Then LoadBubblesBuild() 
                
            ; The personal running build will always be loaded
            If $RunCount = 0 or $runcounter = 1 Then
                Out("Load my own Skills")
                Attribute_LoadSkillTemplate($SkillBarTemplate)
                Out("Player skillbar loaded")
                Sleep(500)
            EndIf

            Out("You are on run #" & $runcounter & " of " & $SetsChangeRuns & " runs before switching to the next Chestrun.")
            Out("You still have " & $LockpicksLeft & " Lockpicks left!!!")
            Out("You better start using those legs you have and make yourself useful!")

            Switch $currentMultRun
                ; Tyrian + EotN
                Case "Diviners Ascent"
                    DivinersAscent()
                Case "Peridition Rock"
                    PeriditionRock()
                Case "Vloxen Excavation"
                    VloxenExcavation()
                Case "Vulture Drifts"
                    VultureDrifts()
                Case "Witmans Folly"
                    WitmansFolly()              
                
                ; Canthan
                Case "Bukdek Byway"
                    BukdekByway()
                Case "Gyala Hatchery"
                    GyalaHatchery()
                Case "Morostav Trail"
                    MorostavTrail()
                Case "Nahpui Quarter"
                    NahpuiQuarter()
                Case "Pongmei Valley Maatu"
                    PongmeiValleyMaatu()
                Case "Raisu Palace"
                    RaisuPalace()
                Case "Rheas Crate"
                    RheasCrate()
                Case "Silent Surf"
                    SilentSurf()
                Case "Sunqua Vale"
                    SunquaVale()   
                
                ; Elonian
                Case "Dejarin Estate"
                    DejarinEstate()
                Case "Domain of Fear"
                    DomainOfFear()
                Case "Drakes on a Plain"
                    DrakesOnAPlain()
                Case "Gandara the Moon Fortress"
                    GandaraTheMoonFortress()
                Case "Turais Gate of Desolation Short"
                    TuraisDesoS()
                Case "Turais Gate of Desolation Long"
                    TuraisDesoL()
                Case "Turais Venta Cemetery"
                    TuraisVenta()
            EndSwitch

        Else
            ; If you are just running one Chestrun, this is where the code leads you :)
            If GUICtrlRead($Builds) = $GUI_CHECKED and $RunCount = 0 Then LoadBubblesBuild()

            ; The personal running build will always be loaded
            If $RunCount = 0 Then
                Out("Load my own Skills")
                Attribute_LoadSkillTemplate($SkillBarTemplate)
                Sleep(500)
                Out("Player skillbar loaded")
                Sleep(500)
            EndIf
                
            Switch $Chosen_Chestrun
                Case "---"
                    Out("Funny not choosing a real Chestrun.")
                    Sleep(2000)
                    Out("Too bad, I am allmighty :)")
                    Sleep(1000)
                    Out("Cheers")
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

                ; Tyrian + EotN
                Case "Diviners Ascent"
                    DivinersAscent()
                Case "Peridition Rock"
                    PeriditionRock()
                Case "Vloxen Excavation"
                    VloxenExcavation()
                Case "Vulture Drifts"
                    VultureDrifts()
                Case "Witmans Folly"
                    WitmansFolly()              
                
                ; Canthan
                Case "Bukdek Byway"
                    BukdekByway()
                Case "Gyala Hatchery"
                    GyalaHatchery()
                Case "Morostav Trail"
                    MorostavTrail()
                Case "Nahpui Quarter"
                    NahpuiQuarter()
                Case "Pongmei Valley Maatu"
                    PongmeiValleyMaatu()
                Case "Raisu Palace"
                    RaisuPalace()
                Case "Rheas Crate"
                    RheasCrate()
                Case "Silent Surf"
                    SilentSurf()
                Case "Sunqua Vale"
                    SunquaVale()   
                
                ; Elonian
                Case "Dejarin Estate"
                    DejarinEstate()
                Case "Domain of Fear"
                    DomainOfFear()
                Case "Drakes on a Plain"
                    DrakesOnAPlain()
                Case "Gandara the Moon Fortress"
                    GandaraTheMoonFortress()
                Case "Turais Gate of Desolation Short"
                    TuraisDesoS()
                Case "Turais Gate of Desolation Long"
                    TuraisDesoL()
                Case "Turais Venta Cemetery"
                    TuraisVenta()
            EndSwitch
        EndIf
    Else
        ;~ If you have no Lockpicks left, the bot will close
        Out("My job here is done!")
        Out("Buy new Lockpicks and start again.")
        Out("Cheers")
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
    EndIf
EndFunc

Func FastWayOut()
    Out("You have chosen the gate trick option.")
    Out("What a wise fella you are!")
    Out("Now take you legs and run to the gate!!!")

    If $Chosen_Chestrun = "Multiple Chestruns" Then
        $currentMultRun = $multRunAr[$multRunLoopCounter]

        Switch $currentMultRun
            ; Tyrian + EotN
            Case "Diviners Ascent"
                MoveTo(16419.89, 6899.07)
                Map_Move(17150, 6900)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(-6785.37,3618.82)
                Map_Move(-7700, 3750)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Peridition Rock"
                MoveTo(3714.20, -10109.67)
                Map_Move(3900, -8600)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(3791.77, -8207.33)
                Map_Move(3784, -8750)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Vloxen Excavation"
                MoveTo(19411.82, 19168.73)
                Map_Move(19750, 19600)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(-19275.54, -11865.76)
                Map_Move(-19850, -11950)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Vulture Drifts"
                MoveTo(10970.89, 7051.34)
                Map_Move(10550, 5950)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(-4887.46, -12588.08)
                Map_Move(-4550, -12000)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Witmans Folly"
                MoveTo(-7677.35, -4244.82)
                MoveTo(-7448.93, -3142.09)
                Map_Move(-7300, -2850)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(-7324.05, -2517.68)
                Map_Move(-7400, -2950)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)
        
            ; Canthan
            Case "Bukdek Byway"
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
                Map_Move(3310.25, -4815.32)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(-6299.50, 19972.59)
                Map_Move(-6750, 20450)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Gyala Hatchery"
                MoveTo(8896.11, -20213.41)
                Map_Move(8500, -19900)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(8464.78, -19627.23)
                Map_Move(8850, -20200)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Morostav Trail"
                MoveTo(21921.05, 7514.47)
                MoveTo(22978.27, 7306.71)
                Map_Move(23750, 7300)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(-21971.67, 7269.26)
                Map_Move(-22750, 7223)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Nahpui Quarter"
                MoveTo(9321.39, -15972.73)
                MoveTo(7588.52, -16424.37)
                Map_Move(7500, -17200)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(10432.45, 13194.85)
                Map_Move(10400, 13800)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Pongmei Valley Maatu"
                MoveTo(-13296.45, 11821.20)
                Map_Move(-13350, 11350)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(-13353.43, 10729.05)
                Map_Move(-13355, 11500)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Raisu Palace"
                MoveTo(-10649.69, 1429.27)
                MoveTo(-9600.88, 2222.37)
                Map_Move(-9600, 2800)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(24221.30, 171.73)
                Map_Move(24210, -750)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Rheas Crate"
                MoveTo(-11517.93, -20599.38)
                MoveTo(-11772.14, -19926.49)
                Map_Move(-11050, -18300)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(-10927.53, -17897.21)
                Map_Move(-11250, -18600)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Silent Surf"
                MoveTo(-11641.05, -20077.12)
                MoveTo(-13455.22, -19615.02)
                Map_Move(-13900, -20000)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(13540.62, 1333.77)
                Map_Move(14300, 2100)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Sunqua Vale"
                MoveTo(7608.57, -10486.09)
                MoveTo(7153.65, -11060.53)
                Map_Move(6950, -11350)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(6753.25, 15658.36)
                Map_Move(7000, 16450)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)


            ; Elonian            
            Case "Dejarin Estate"
                MoveTo(4323.24, 3304.75)
                Map_Move(4650, 3800)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(-19376.90, -19916.70)
                Map_Move(-19740, -20650)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Domain of Fear"
                MoveTo(8743.08, 19387.99)
                Map_Move(8100, 18900)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(9915.98, 4716.20)
                Map_Move(9916, 3950)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Drakes on a Plain"
                MoveTo(-15658.72, 9592.68)
                Map_Move(-15100, 8950)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(-15102.36, 8728.13)
                Map_Move(-15450, 9250)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Gandara the Moon Fortress"
                MoveTo(4083.84, -2857.98)
                MoveTo(3001.61, -4388.27)
                Map_Move(2300, -5200)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                Map_Move(8850, 16750)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Turais Gate of Desolation Short"
                MoveTo(1682.36, -2521.67)
                MoveTo(3792.56, -4543.15)
                Map_Move(4800, -5050)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(-13415.42, 25644.87)
                Map_Move(-14300, 26100)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Turais Gate of Desolation Long"
                MoveTo(1682.36, -2521.67)
                MoveTo(3792.56, -4543.15)
                Map_Move(4800, -5050)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(-13415.42, 25644.87)
                Map_Move(-14300, 26100)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Turais Venta Cemetery"
                MoveTo(26291.60, 16019.00)
                Map_Move(26300, 16750)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(-13691.97, -25781.57)
                Map_Move(-13691, -26500)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)
        EndSwitch 
    Else

        Switch $Chosen_Chestrun
            ; Tyrian + EotN
            Case "Diviners Ascent"
                MoveTo(16419.89, 6899.07)
                Map_Move(17150, 6900)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(-6785.37,3618.82)
                Map_Move(-7700, 3750)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Peridition Rock"
                MoveTo(3714.20, -10109.67)
                Map_Move(3900, -8600)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(3791.77, -8207.33)
                Map_Move(3784, -8750)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Vloxen Excavation"
                MoveTo(19411.82, 19168.73)
                Map_Move(19750, 19600)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(-19275.54, -11865.76)
                Map_Move(-19850, -11950)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Vulture Drifts"
                MoveTo(10970.89, 7051.34)
                Map_Move(10550, 5950)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(-4887.46, -12588.08)
                Map_Move(-4550, -12000)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Witmans Folly"
                MoveTo(-7677.35, -4244.82)
                MoveTo(-7448.93, -3142.09)
                Map_Move(-7300, -2850)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(-7324.05, -2517.68)
                Map_Move(-7400, -2950)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)
        
            ; Canthan
            Case "Bukdek Byway"
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
                Map_Move(3310.25, -4815.32)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(-6299.50, 19972.59)
                Map_Move(-6750, 20450)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Gyala Hatchery"
                MoveTo(8896.11, -20213.41)
                Map_Move(8500, -19900)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(8464.78, -19627.23)
                Map_Move(8850, -20200)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Morostav Trail"
                MoveTo(21921.05, 7514.47)
                MoveTo(22978.27, 7306.71)
                Map_Move(23750, 7300)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(-21971.67, 7269.26)
                Map_Move(-22750, 7223)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Nahpui Quarter"
                MoveTo(9321.39, -15972.73)
                MoveTo(7588.52, -16424.37)
                Map_Move(7500, -17200)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(10432.45, 13194.85)
                Map_Move(10400, 13800)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Pongmei Valley Maatu"
                MoveTo(-13296.45, 11821.20)
                Map_Move(-13350, 11350)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(-13353.43, 10729.05)
                Map_Move(-13355, 11500)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Raisu Palace"
                MoveTo(-10649.69, 1429.27)
                MoveTo(-9600.88, 2222.37)
                Map_Move(-9600, 2800)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(24221.30, 171.73)
                Map_Move(24210, -750)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Rheas Crate"
                MoveTo(-11517.93, -20599.38)
                MoveTo(-11772.14, -19926.49)
                Map_Move(-11050, -18300)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(-10927.53, -17897.21)
                Map_Move(-11250, -18600)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Silent Surf"
                MoveTo(-11641.05, -20077.12)
                MoveTo(-13455.22, -19615.02)
                Map_Move(-13900, -20000)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(13540.62, 1333.77)
                Map_Move(14300, 2100)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Sunqua Vale"
                MoveTo(7608.57, -10486.09)
                MoveTo(7153.65, -11060.53)
                Map_Move(6950, -11350)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(6753.25, 15658.36)
                Map_Move(7000, 16450)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)


            ; Elonian            
            Case "Dejarin Estate"
                MoveTo(4323.24, 3304.75)
                Map_Move(4650, 3800)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(-19376.90, -19916.70)
                Map_Move(-19740, -20650)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Domain of Fear"
                MoveTo(8743.08, 19387.99)
                Map_Move(8100, 18900)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(9915.98, 4716.20)
                Map_Move(9916, 3950)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Drakes on a Plain"
                MoveTo(-15658.72, 9592.68)
                Map_Move(-15100, 8950)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(-15102.36, 8728.13)
                Map_Move(-15450, 9250)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Gandara the Moon Fortress"
                MoveTo(4083.84, -2857.98)
                MoveTo(3001.61, -4388.27)
                Map_Move(2300, -5200)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                Map_Move(8850, 16750)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Turais Gate of Desolation Short"
                MoveTo(1682.36, -2521.67)
                MoveTo(3792.56, -4543.15)
                Map_Move(4800, -5050)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(-13415.42, 25644.87)
                Map_Move(-14300, 26100)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Turais Gate of Desolation Long"
                MoveTo(1682.36, -2521.67)
                MoveTo(3792.56, -4543.15)
                Map_Move(4800, -5050)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(-13415.42, 25644.87)
                Map_Move(-14300, 26100)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)

            Case "Turais Venta Cemetery"
                MoveTo(26291.60, 16019.00)
                Map_Move(26300, 16750)
                Map_WaitMapLoading($MAP_ID_Farm, 1)
                Sleep(1000)

                MoveTo(-13691.97, -25781.57)
                Map_Move(-13691, -26500)
                Map_WaitMapLoading($Town_ID_Farm, 0)
                Sleep(1000)
        EndSwitch 
    EndIf
EndFunc