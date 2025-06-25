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
#include <WinAPITheme.au3>
#include <WinAPIDiag.au3>
#include "_gwApi.au3"

; ==== Map IDs ====
Local Const $aggroRange = 1200
; ==== Constants ====
Global Const $FroggyFarmerSkillbar = ''
Global Const $FroggyFarmInformations = 'For best results, dont cheap out on heroes' & @CRLF _
	& 'Testing was done with a ROJ monk and an adapted mesmerway (1 E-surge replaced by a ROJ, ineptitude replaced by blinding surge)' & @CRLF _
	& 'I recommend using a range build to avoid pulling extra groups in crowded rooms' & @CRLF _
	& '32mn average in NM' & @CRLF _
	& '41mn  average in HM with consets (automatically used if HM is on)'

Global $FROGGY_FARM_SETUP = False
Global $FroggyDeathsCount = 0
Global Const $ID_Froggy_Quest = 0x339

; ==== Main Bot Loop ====
While Not $BotRunning
    Sleep(100)
WEnd

; Call FroggyFarm() when Start is pressed
FroggyFarm('RUNNING')

While $BotRunning
    Sleep(100)
    ; GUI and statistics updates
    If GUICtrlRead($GUIAutoUpdateCheckbox) = $GUI_CHECKED And TimerDiff($LastSkillUpdate) > $SkillUpdateInterval Then
        UpdateSkillbarDisplay()
        $LastSkillUpdate = TimerInit()
    EndIf
    If TimerDiff($ExtraStatsUpdateTimer) > 100 Then
        UpdateExtraStatisticsDisplay()
        $ExtraStatsUpdateTimer = TimerInit()
    EndIf
WEnd

;~ Main method to farm Froggy
Func FroggyFarm($STATUS)
	If Not $FROGGY_FARM_SETUP Then
		SetupFroggyFarm()
		$FROGGY_FARM_SETUP = True
	EndIf

	If $STATUS <> 'RUNNING' Then Return 2

	Return FroggyFarmLoop()
EndFunc

;~ Froggy farm setup
Func SetupFroggyFarm()
	Out('Setting up farm')
	; Need to be done here in case bot comes back from inventory management
	If GetMapID() <> $ID_Gadds_Camp Then RndTravel($ID_Gadds_Camp)
	$FroggyDeathsCount = 0
	Out('Making way to portal')
		; Check GUI Hard Mode setting and switch mode before starting the run
If GUICtrlRead($GUIHardModeCheckbox) = $GUI_CHECKED Then
    Out('Hard Mode enabled in GUI - switching to Hard Mode')
    SwitchMode(1)
    RndSleep(1000)
Else
    Out('Hard Mode disabled in GUI - switching to Normal Mode')
    SwitchMode(0)
    RndSleep(1000)
EndIf
	MoveTo(-10018, -21892)
	MoveTo(-9550, -20400)
	Move(-9451, -19766)
	RndSleep(2000)
	While Not WaitMapLoading($ID_Sparkfly_Swamp)
		Sleep(500)
		MoveTo(-9550, -20400)
		Move(-9451, -19766)
	WEnd
	AdlibRegister('FroggyGroupIsAlive', 10000)

	Local $aggroRange = $RANGE_SPELLCAST + 100
	Out('Making way to Bogroot')
	While $FroggyDeathsCount < 6 And Not FroggyIsInRange (4671, 7094, 1250)
		MoveToKill(-4559, -14406, 'Zone 1 - Step 1', $aggroRange)
		MoveToKill(-5204, -9831, 'Zone 1 - Step 2', $aggroRange)
		MoveToKill(-928, -8699, 'Zone 1 - Step 3', $aggroRange)
		MoveToKill(4200, -4897, 'Zone 1 - Step 4', $aggroRange)
		MoveToKill(4671, 7094, 'Zone 1 - Step 5', $aggroRange)
		If FroggyIsFailure() Then Return 1
	WEnd

	While $FroggyDeathsCount < 6 And Not FroggyIsInRange (12280, 22585, 1250)
		MoveToKill(11025, 11710, 'Zone 2 - Step 1', $aggroRange)
		MoveToKill(14624, 19314, 'Zone 2 - Step 2', $aggroRange)
		MoveToKill(14650, 19417, 'Zone 2 - Step 3', $aggroRange)
		MoveToKill(12280, 22585, 'Zone 2 - Step 4', $aggroRange)
		If FroggyIsFailure() Then Return 1
	WEnd
	AdlibUnRegister('FroggyGroupIsAlive')
	Out('Preparations complete')
EndFunc

;~ Farm loop
Func FroggyFarmLoop()
	$FroggyDeathsCount = 0

	AdlibRegister('FroggyGroupIsAlive', 10000)

	Local $aggroRange = $RANGE_SPELLCAST + 100

	Out('Get quest reward')
	MoveTo(12061, 22485)
	GoToNPCNearXY(12500, 22648)
	RndSleep(250)
	Dialog(0x833907)
	RndSleep(500)
	; Quest validation doubled to secure bot
	GoToNPCNearXY(12500, 22648)
	RndSleep(250)
	Dialog(0x833907)
	RndSleep(500)

	Out('Get in dungeon to reset quest')
	MoveTo(12228, 22677)
	RndSleep(500)
	MoveTo(12470, 25036)
	RndSleep(500)
	MoveTo(12968, 26219)
	RndSleep(500)
	Move(13097, 26393)
	RndSleep(2000)
	While Not WaitMapLoading($ID_Bogroot_lvl1)
		Sleep(500)
		MoveTo(12968, 26219)
		Move(13097, 26393)
	WEnd
	RndSleep(2000)

	Out('Get out of dungeon to reset quest')
	RndSleep(2000)
	MoveTo(14876, 632)
	RndSleep(500)
	Move(14700, 450)
	RndSleep(2000)
	While Not WaitMapLoading($ID_Sparkfly_Swamp)
		Out('Stuck, retrying')
		Sleep(500)
		MoveTo(14876, 632)
		Move(14700, 450)
	WEnd
	RndSleep(2000)

	Out('Get quest')
	MoveTo(12061, 22485)
	GoToNPCNearXY(12500, 22648)
	RndSleep(250)
	Dialog(0x833901)
	RndSleep(500)
	; Quest pickup doubled to secure bot
	GoToNPCNearXY(12500, 22648)
	RndSleep(250)
	Dialog(0x833901)
	RndSleep(500)
	Out('Talk to Tekk if already had quest')
	GoToNPCNearXY(12500, 22648)
	RndSleep(250)
	Dialog(0x833905)
	RndSleep(500)
	; Quest pickup doubled to secure bot
	GoToNPCNearXY(12500, 22648)
	RndSleep(250)
	Dialog(0x833905)
	RndSleep(500)

	Out('Get back in')
	MoveTo(12228, 22677)
	RndSleep(500)
	MoveTo(12470, 25036)
	RndSleep(500)
	MoveTo(12968, 26219)
	RndSleep(500)
	Move(13097, 26393)
	RndSleep(2000)
	While Not WaitMapLoading($ID_Bogroot_lvl1)
		Sleep(500)
		MoveTo(12968, 26219)
		Move(13097, 26393)
	WEnd
	RndSleep(2000)

	; Check GUI Hard Mode setting and switch mode before starting the run
	Out('Checking Hard Mode setting...')
	If GUICtrlRead($GUIHardModeCheckbox) = $GUI_CHECKED Then
		Out('Hard Mode enabled in GUI - switching to Hard Mode')
		SwitchMode($hardmode)
		RndSleep(1000)
	Else
		Out('Hard Mode disabled in GUI - staying in Normal Mode')
		SwitchMode($normalmode)
		RndSleep(1000)
	EndIf

	; Waiting to be alive before retrying
	While Not IsGroupAlive()
		Sleep(2000)
	WEnd
	Out('------------------------------------')
	Out('First floor')
	UseConset()

	While $FroggyDeathsCount < 6 And Not FroggyIsInRange (6078, 4483, 1250)
		UseMoraleConsumableIfNeeded()
		MoveToKill(17619, 2687, 'Floor 1 - Zone 1 - Step 1', $aggroRange)
		MoveToKill(18168, 4788, 'Floor 1 - Zone 1 - Step 2', $aggroRange)
		MoveToKill(18880, 7749, 'Floor 1 - Zone 1 - Step 3', $aggroRange)

		Out('Getting blessing')
		MoveTo(19063, 7875)
		GoToNPCNearXY(19058, 7952)
		RndSleep(250)
		Dialog(0x84)
		RndSleep(250)

		MoveToKill(13080, 7822, 'Floor 1 - Zone 1 - Step 4', $aggroRange)
		MoveToKill(9946, 6963, 'Floor 1 - Zone 1 - Step 5', $aggroRange)
		MoveToKill(6078, 4483, 'Floor 1 - Zone 1 - Step 6', $aggroRange)
	WEnd

	While $FroggyDeathsCount < 6 And Not FroggyIsInRange (-1501, -8590, 1250)
		UseMoraleConsumableIfNeeded()
		MoveToKill(4960, 1984, 'Floor 1 - Zone 2 - Step 1', $aggroRange)
		MoveToKill(3567, -278, 'Floor 1 - Zone 2 - Step 2', $aggroRange)
		MoveToKill(1763, -607, 'Floor 1 - Zone 2 - Step 3', $aggroRange)
		MoveToKill(224, -2238, 'Floor 1 - Zone 2 - Step 4', $aggroRange)
		MoveToKill(-1175, -4994, 'Floor 1 - Zone 2 - Step 5', $aggroRange)
		MoveToKill(-115, -8569, 'Floor 1 - Zone 2 - Step 6', $aggroRange)
		MoveToKill(-1501, -8590, 'Floor 1 - Zone 2 - Step 7', $aggroRange)
	WEnd

	While $FroggyDeathsCount < 6 And Not FroggyIsInRange (7171, -17934, 1250)
		UseMoraleConsumableIfNeeded()
		MoveToKill(-115, -8569, 'Floor 1 - Zone 3 - Step 1', $aggroRange)
		MoveToKill(1966, -11018, 'Floor 1 - Zone 3 - Step 2', $aggroRange)
		MoveToKill(5775, -12761, 'Floor 1 - Zone 3 - Step 3', $aggroRange)
		MoveToKill(6125, -15820, 'Floor 1 - Zone 3 - Step 4', $aggroRange)
		Out('Last cave exit')
		MoveTo(7171, -17934)
	WEnd

	Out('Going through portal')
	Move(7600, -19100)
	RndSleep(2000)
	While Not WaitMapLoading($ID_Bogroot_lvl2)
		MoveTo(7171, -17934)
		Move(7600, -19100)
		Sleep(500)
	WEnd
	RndSleep(2000)

	Out('------------------------------------')
	Out('Second floor')
	UseConset()

	While $FroggyDeathsCount < 6 And Not FroggyIsInRange (-719, 11140, 1250)
		Out('Getting blessing')
		MoveTo(-11072, -5522)
		GoToNPCNearXY(-11055, -5533)
		RndSleep(250)
		Dialog(0x84)
		RndSleep(250)

		UseMoraleConsumableIfNeeded()
		MoveToKill(-10931, -4584, 'Floor 2 - Zone 1 - Step 1', $aggroRange)
		MoveToKill(-10121, -3175, 'Floor 2 - Zone 1 - Step 2', $aggroRange)
		MoveToKill(-9646, -1005, 'Floor 2 - Zone 1 - Step 3', $aggroRange)
		MoveToKill(-8548, 601, 'Floor 2 - Zone 1 - Step 4', $aggroRange)
		MoveToKill(-7217, 3353, 'Floor 2 - Zone 1 - Step 5', $aggroRange)
		MoveToKill(-8229, 5519, 'Floor 2 - Zone 1 - Step 6', $aggroRange)
		MoveToKill(-9434, 8479, 'Floor 2 - Zone 1 - Step 7', $aggroRange)
		MoveToKill(-8182, 10187, 'Floor 2 - Zone 1 - Step 8', $aggroRange)
		MoveToKill(-6440, 11526, 'Floor 2 - Zone 1 - Step 9', $aggroRange)
		MoveToKill(-3963, 10050, 'Floor 2 - Zone 1 - Step 10', $aggroRange)
		MoveToKill(-1992, 11950, 'Floor 2 - Zone 1 - Step 11', $aggroRange)
		MoveToKill(-719, 11140, 'Floor 2 - Zone 1 - Step 12', $aggroRange)
	WEnd

	While $FroggyDeathsCount < 6 And Not FroggyIsInRange (8398, 4358, 1250)
		UseMoraleConsumableIfNeeded()
		MoveToKill(3130, 12731, 'Floor 2 - Zone 2 - Step 1', $aggroRange)
		MoveToKill(3535, 13860, 'Floor 2 - Zone 2 - Step 2', $aggroRange)
		MoveToKill(5717, 13357, 'Floor 2 - Zone 2 - Step 3', $aggroRange)
		MoveToKill(6945, 9820, 'Floor 2 - Zone 2 - Step 4', $aggroRange)
		MoveToKill(8117, 7465, 'Floor 2 - Zone 2 - Step 5', $aggroRange)
		MoveToKill(8398, 4358, 'Floor 2 - Zone 2 - Step 6', $aggroRange)
	WEnd

	While $FroggyDeathsCount < 6 And Not FroggyIsInRange (19597, -11553, 1250)
		UseMoraleConsumableIfNeeded()
		MoveToKill(9829, -1175, 'Floor 2 - Zone 3 - Step 1', $aggroRange)
		MoveToKill(10932, -5203, 'Floor 2 - Zone 3 - Step 2', $aggroRange)
		MoveToKill(13305, -6475, 'Floor 2 - Zone 3 - Step 3', $aggroRange)
		MoveToKill(16841, -5619, 'Floor 2 - Zone 3 - Step 4', $aggroRange)

		RndSleep(500)
		PickUpAllKeysOnGround()

		Out('Open dungeon door')
		ClearTarget()
		Sleep(GetPing() + 500)
		Moveto(17888, -6243)
		ActionInteract()
		Sleep(GetPing() + 500)
		ActionInteract()
		Sleep(GetPing() + 500)
		Moveto(17888, -6243)
		Sleep(GetPing() + 500)
		ActionInteract()
		Sleep(GetPing() + 500)
		ActionInteract()
		Sleep(GetPing() + 500)
		Moveto(17888, -6243)
		Sleep(GetPing() + 500)
		ActionInteract()
		Sleep(GetPing() + 500)
		ActionInteract()

		MoveToKill(18363, -8696, 'Floor 2 - Zone 3 - Step 5', $aggroRange)
		MoveToKill(16631, -11655, 'Floor 2 - Zone 3 - Step 6', $aggroRange)
		MoveToKill(19122, -12284, 'Floor 2 - Zone 3 - Step 7', $aggroRange)
		MoveToKill(19597, -11553, 'Floor 2 - Zone 3 - Step 8', $aggroRange)
	WEnd

	Local $aggroRange = $RANGE_SPELLCAST + 300

	Local $questState = 1
	While $FroggyDeathsCount < 6 And $questState <> 3
		Out('------------------------------------')
		Out('Boss area')
		UseMoraleConsumableIfNeeded()
		MoveToKill(17494, -14149, 'Boss - Step 1', $aggroRange)
		MoveToKill(14641, -15081, 'Boss - Step 2', $aggroRange)
		MoveToKill(13934, -17384, 'Boss - Step 3', $aggroRange)
		MoveToKill(14365, -17681, 'Boss - Step 4', $aggroRange)
		MoveToKill(15286, -17662, 'Boss - Step 5', $aggroRange)
		MoveToKill(15804, -19107, 'Boss - Step 6', $aggroRange)

		$questState = DllStructGetData(GetQuestByID($ID_Froggy_Quest), 'LogState')
		Sleep(1000)
	WEnd
	If FroggyIsFailure() Then Return 1

	; Chest
	MoveTo(15910, -19134)
	MoveTo(15329, -18948)
	MoveTo(15086, -19132)
	Out('Opening chest')
	RndSleep(5000)
	ActionInteract()
	RndSleep(2500)
	PickUpLoot()
	; Doubled to secure the looting
	MoveTo(15590, -18853)
	MoveTo(15027, -19102)
	RndSleep(5000)
	
	ActionInteract()
	RndSleep(2500)
	PickUpLoot()

	AdlibUnRegister('FroggyGroupIsAlive')
	Out('Chest looted')
	Out('Waiting for timer end + some more')
	While GetMapID() = $ID_Bogroot_lvl2
		Sleep(1000)
	WEnd
	Out('Finished Run')

	Return 0
EndFunc

;~ Did run fail ?
Func FroggyIsFailure()
	If ($FroggyDeathsCount > 5) Then
		AdlibUnregister('FroggyGroupIsAlive')
		Return True
	EndIf
	Return False
EndFunc

;~ Updates the groupIsAlive variable, this function is run on a fixed timer
Func FroggyGroupIsAlive()
	$FroggyDeathsCount += IsGroupAlive() ? 0 : 1
EndFunc

;~ Is in range of coordinates
Func FroggyIsInRange($X, $Y, $range)
	Local $myX = X(-2)
	Local $myY = Y(-2)

	If ($myX < $X + $range) And ($myX > $X - $range) And ($myY < $Y + $range) And ($myY > $Y - $range) Then
		Return True
	EndIf
	Return False
EndFunc

Func _Exit()
    Exit
EndFunc

Func ActionInteract()
	Return PerformAction(0x80, 0x1E)
EndFunc

