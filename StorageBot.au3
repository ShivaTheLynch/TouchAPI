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


; --- REMOVE VANQUISH, MOVEMENT, AND FORT ASPENWOOD FUNCTIONS ---
; Deleted: CheckMapAndStartVanquish
; Deleted: SetHardModeForTravel
; Deleted: EnsureInFortAspenwoodLuxon
; Deleted: RndTravel
; Deleted: LuxonFarmSetup
; Deleted: MoveOut
; Deleted: VanquishMountQinkai

While Not $BotRunning
    Sleep(100)
WEnd

; Call Inventory() ONCE before entering the main bot loop
Inventory()

While $BotRunning
    Sleep(100)
    ; GUI and statistics updates can remain if needed
    If GUICtrlRead($GUIAutoUpdateCheckbox) = $GUI_CHECKED And TimerDiff($LastSkillUpdate) > $SkillUpdateInterval Then
        UpdateSkillbarDisplay()
        $LastSkillUpdate = TimerInit()
    EndIf
    If TimerDiff($ExtraStatsUpdateTimer) > 100 Then
        UpdateExtraStatisticsDisplay()
        $ExtraStatsUpdateTimer = TimerInit()
    EndIf
WEnd

Func _Exit()
    Exit
EndFunc



