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
Global Const $ID_Gadds_Camp = 638
Global Const $ID_Sparkfly_Swamp = 558
Global Const $ID_Bogroot_lvl1 = 615
Global Const $ID_Bogroot_lvl2 = 616
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
		MoveToKill(-4559, -14406, 'I majored in pain, with a minor in suffering', $aggroRange)
		MoveToKill(-5204, -9831, 'Youre dumb! Youll die, and youll leave a dumb corpse!', $aggroRange)
		MoveToKill(-928, -8699, 'I am fire! I am war! What are you?', $aggroRange)
		MoveToKill(4200, -4897, 'Praise Joko!', $aggroRange)
		MoveToKill(4671, 7094, 'I can outrun a centaur', $aggroRange)
		If FroggyIsFailure() Then Return 1
	WEnd

	While $FroggyDeathsCount < 6 And Not FroggyIsInRange (12280, 22585, 1250)
		MoveToKill(11025, 11710, 'Wow. Thats quality armor.', $aggroRange)
		MoveToKill(14624, 19314, 'By Ogdens Hammer, what savings!', $aggroRange)
		MoveToKill(14650, 19417, 'More violets I say. Less violence', $aggroRange)
		MoveToKill(12280, 22585, 'Guild wars 2 is actually great, you know?', $aggroRange)
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

	; Waiting to be alive before retrying
	While Not IsGroupAlive()
		Sleep(2000)
	WEnd
	Out('------------------------------------')
	Out('First floor')
	UseConset()

	While $FroggyDeathsCount < 6 And Not FroggyIsInRange (6078, 4483, 1250)
		UseMoraleConsumableIfNeeded()
		MoveToKill(17619, 2687, 'Moving near duo', $aggroRange)
		MoveToKill(18168, 4788, 'Killing one from duo', $aggroRange)
		MoveToKill(18880, 7749, 'Triggering beacon 1', $aggroRange)

		Out('Getting blessing')
		MoveTo(19063, 7875)
		GoToNPCNearXY(19058, 7952)
		RndSleep(250)
		Dialog(0x84)
		RndSleep(250)

		MoveToKill(13080, 7822, 'Moving towards nettles cave', $aggroRange)
		MoveToKill(9946, 6963, 'Nettles cave', $aggroRange)
		MoveToKill(6078, 4483, 'Nettles cave exit group', $aggroRange)
	WEnd

	While $FroggyDeathsCount < 6 And Not FroggyIsInRange (-1501, -8590, 1250)
		UseMoraleConsumableIfNeeded()
		MoveToKill(4960, 1984, 'Triggering beacon 2', $aggroRange)
		MoveToKill(3567, -278, 'Massive frog cave', $aggroRange)
		MoveToKill(1763, -607, 'Im getting buried here!', $aggroRange)
		MoveToKill(224, -2238, 'Massive frog cave exit', $aggroRange)
		MoveToKill(-1175, -4994, 'Moving through poison jets', $aggroRange)
		MoveToKill(-115, -8569, 'Ragna-rock n roll!', $aggroRange)
		MoveToKill(-1501, -8590, 'Triggering beacon 3', $aggroRange)
	WEnd

	While $FroggyDeathsCount < 6 And Not FroggyIsInRange (7171, -17934, 1250)
		UseMoraleConsumableIfNeeded()
		MoveToKill(-115, -8569, 'You played two hours and died like this?!', $aggroRange)
		MoveToKill(1966, -11018, 'Last cave entrance', $aggroRange)
		MoveToKill(5775, -12761, 'Youre interrupting my calculations', $aggroRange)
		MoveToKill(6125, -15820, 'Commander, a word...', $aggroRange)
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
		MoveToKill(-10931, -4584, 'Moving in cave', $aggroRange)
		MoveToKill(-10121, -3175, 'Moving near river ', $aggroRange)
		MoveToKill(-9646, -1005, 'Going through river ', $aggroRange)
		MoveToKill(-8548, 601, 'Moving to incubus cave', $aggroRange)
		MoveToKill(-7217, 3353, 'Incubus cave entrance', $aggroRange)
		MoveToKill(-8229, 5519, 'Wololo', $aggroRange)
		MoveToKill(-9434, 8479, 'Help! The crusaders are attacking our trade routes!', $aggroRange)
		MoveToKill(-8182, 10187, 'La Hire wishes to kill something', $aggroRange)
		MoveToKill(-6440, 11526, 'The blood on La Hires sword is almost dry!', $aggroRange)
		MoveToKill(-3963, 10050, 'It is a good day for La Hire to die... ', $aggroRange)
		MoveToKill(-1992, 11950, 'Ill be back, Saracen dogs!', $aggroRange)
		MoveToKill(-719, 11140, 'Triggering incubus cave exit beacon', $aggroRange)
	WEnd

	While $FroggyDeathsCount < 6 And Not FroggyIsInRange (8398, 4358, 1250)
		UseMoraleConsumableIfNeeded()
		MoveToKill(3130, 12731, 'Beetle zone', $aggroRange)
		MoveToKill(3535, 13860, 'Aiur will be restored', $aggroRange)
		MoveToKill(5717, 13357, 'Eternal obedience', $aggroRange)
		MoveToKill(6945, 9820, 'Beetle zone exit', $aggroRange)
		MoveToKill(8117, 7465, 'Gokir fight', $aggroRange)
		MoveToKill(8398, 4358, 'Triggering beacon 2', $aggroRange)
	WEnd

	While $FroggyDeathsCount < 6 And Not FroggyIsInRange (19597, -11553, 1250)
		UseMoraleConsumableIfNeeded()
		MoveToKill(9829, -1175, 'The Death Fleet descends', $aggroRange)
		MoveToKill(10932, -5203, 'I hear and obey', $aggroRange)
		MoveToKill(13305, -6475, 'Target in range.', $aggroRange)
		MoveToKill(16841, -5619, 'Keyboss', $aggroRange)

		RndSleep(500)
		PickUpItems()

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

		MoveToKill(18363, -8696, 'Going to boss area', $aggroRange)
		MoveToKill(16631, -11655, 'I will do all that must be done', $aggroRange)
		MoveToKill(19122, -12284, 'Glory to the Firstborn', $aggroRange)
		MoveToKill(19597, -11553, 'Triggering boss beacon', $aggroRange)
	WEnd

	Local $aggroRange = $RANGE_SPELLCAST + 300

	Local $questState = 1
	While $FroggyDeathsCount < 6 And $questState <> 3
		Out('------------------------------------')
		Out('Boss area')
		UseMoraleConsumableIfNeeded()
		MoveToKill(17494, -14149, 'Our enemies will be undone', $aggroRange)
		MoveToKill(14641, -15081, 'I live to serve.', $aggroRange)
		MoveToKill(13934, -17384, 'The mission is in peril!', $aggroRange)
		MoveToKill(14365, -17681, 'Boss fight', $aggroRange)
		MoveToKill(15286, -17662, 'All hail! King of the losers!', $aggroRange)
		MoveToKill(15804, -19107, 'Oh fuck its huge', $aggroRange)

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
	TargetNearestItem()
	ActionInteract()
	RndSleep(2500)
	PickUpItems()
	; Doubled to secure the looting
	MoveTo(15590, -18853)
	MoveTo(15027, -19102)
	RndSleep(5000)
	TargetNearestItem()
	ActionInteract()
	RndSleep(2500)
	PickUpItems()

	AdlibUnRegister('FroggyGroupIsAlive')
	Out('Chest looted')
	Out('Waiting for timer end + some more')
	Sleep(190000)
	While Not WaitMapLoading($ID_Sparkfly_Swamp)
		Sleep(500)
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



