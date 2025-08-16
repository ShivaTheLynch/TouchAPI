#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>
#include <WindowsConstants.au3>

;~ Constantds needed for Gui
Global $SELECT_Chestrun = "Multiple Chestruns|---|Diviners Ascent|Peridition Rock|Vloxen Excavation|Vulture Drifts|Witmans Folly|Bukdek Byway|Gyala Hatchery|Morostav Trail|Nahpui Quarter|Pongmei Valley Maatu|Raisu Palace|Rheas Crate|Silent Surf|Sunqua Vale|Dejarin Estate|Domain of Fear|Drakes on a Plain|Gandara the Moon Fortress|Turais Desolation - Short|Turais Desolation - Long|Turais Venta Cemetery"

Global $RunCount = 0
Global $SuccessCount = 0
Global $FailCount = 0

Global $LockpicksLeft = 0
Global $LockpicksBefore = 0
Global $LockpicksKept = 0
Global $LockpicksBroken = 0

Global $ChestTitle = 0
Global $LuckyTitle = 0
Global $UnluckyTitle = 0

Global $Chestsopened = 0
Global $LuckypointsGained = 0
Global $UnluckypointsGained = 0

Global $TomesPicked = 0
Global $GoldItemsPicked = 0
Global $PurpleItemsPicked = 0

Global $maxQ8GoldGained = 0
Global $maxQ8PurpleGained = 0

Global $SetsChangeRuns = 0

Global $Chosen_Chestrun = ""

;~ Gui for Bubbles Chestruns
;~ by BubbleTea
Global Const $mainGui =             GUICreate("BubbleTea's Chestruns", 467, 580, 190, 136)

Global Const $Tab1 =                GUICtrlCreateTab(0, 0, 465, 577)
                                    GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~ First Tab Sheet for GEneral Options and Statistics and Outputs
Global Const $TabSheet1 =           GUICtrlCreateTabItem("General Options")

; Choose Character
Global Const $Fighter =             GUICtrlCreateLabel("Choose your Fighter", 8, 31, 114, 19)
                                    GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")

Global $Input
    If $doLoadLoggedChars Then
			$Input =	            GUICtrlCreateCombo($charName, 8, 55, 449, 25)
						            GUICtrlSetData(-1, Scanner_GetLoggedCharNames())
                                    GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")
    Else
			$Input =	            GUICtrlCreateInput("Choose your Fighter", 8, 55, 449, 25)
                                    GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")
    EndIf

; Choose Chestrun
Global Const $ChestRunLabel =       GUICtrlCreateLabel("Choose your Chestrun", 8, 87, 125, 19)
                                    GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")
Global $Chestrun =                  GUICtrlCreateCombo("", 8, 111, 449, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL,$WS_VSCROLL))
                                    GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($Chestrun, "GuiButtonHandler")
                                    GUICtrlSetData($Chestrun, $SELECT_Chestrun, "---")
                                    GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")

; Run Options
Global Const $HardmodeLabel =       GUICtrlCreateLabel("Run in Hardmode?", 8, 146, 103, 19)
                                    GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")
Global Const $HardMODECheckbox =    GUICtrlCreateCheckbox("", 113, 146, 17, 17)

Global Const $Button =              GUICtrlCreateButton("Start", 321, 146, 137, 25)
                                    GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($Button, "GuiButtonHandler")

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Start Group Statistics ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Global Const $Group1 =              GUICtrlCreateGroup("Statistics", 8, 177, 449, 167)
                                    GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")
Global Const $RunsLabel =           GUICtrlCreateLabel("Runs: " & $RunCount, 16, 201, 140, 18)
                                    GUICtrlSetFont(-1, 8, 800, 0, "Times New Roman")
Global Const $SuccessLabel =        GUICtrlCreateLabel("Success: " & $SuccessCount, 168, 201, 140, 18)
                                    GUICtrlSetFont(-1, 8, 800, 0, "Times New Roman")
                                    GUICtrlSetColor(-1, 0x006400)    
Global Const $FailsLabel =          GUICtrlCreateLabel("Fails: " & $FailCount, 320, 201, 140, 18)
                                    GUICtrlSetFont(-1, 8, 800, 0, "Times New Roman")
                                    GUICtrlSetColor(-1, 0x8B0000) 

Global Const $LockpickLabel =       GUICtrlCreateLabel("Lockpicks: " & $LockpicksLeft, 16, 225, 140, 18)
                                    GUICtrlSetFont(-1, 8, 800, 0, "Times New Roman") 
Global Const $LockpickKeptLabel =   GUICtrlCreateLabel("Lockpicks kept: " & $LockpicksKept, 168, 225, 140, 18)
                                    GUICtrlSetFont(-1, 8, 800, 0, "Times New Roman")
                                    GUICtrlSetColor(-1, 0x7CCD7C)      
Global Const $LockpickBrokenLabel = GUICtrlCreateLabel("Lockpicks broken: " & $LockpicksBroken, 320, 225, 140, 18)
                                    GUICtrlSetFont(-1, 8, 800, 0, "Times New Roman")
                                    GUICtrlSetColor(-1, 0xFF7F7F)

Global Const $ChestTitleLabel =     GUICtrlCreateLabel("Chest Title: " & $ChestTitle, 16, 249, 140, 18)
                                    GUICtrlSetFont(-1, 8, 800, 0, "Times New Roman")
Global Const $LuckyTitleLabel =     GUICtrlCreateLabel("Lucky Title: " & $LuckyTitle, 168, 249, 140, 18)
                                    GUICtrlSetFont(-1, 8, 800, 0, "Times New Roman")
                                    GUICtrlSetColor(-1, 0x7CCD7C)
Global Const $UnluckyTitleLabel =   GUICtrlCreateLabel("Unlucky Title: " & $UnluckyTitle, 320, 249, 140, 18)
                                    GUICtrlSetFont(-1, 8, 800, 0, "Times New Roman")
                                    GUICtrlSetColor(-1, 0xFF7F7F)

Global Const $ChestsLabel =         GUICtrlCreateLabel("Chests opened: " & $Chestsopened, 16, 273, 140, 18)
                                    GUICtrlSetFont(-1, 8, 800, 0, "Times New Roman")
Global Const $LuckyGainedLabel =    GUICtrlCreateLabel("Points gained: " & $LuckypointsGained, 168, 273, 140, 18)
                                    GUICtrlSetFont(-1, 8, 800, 0, "Times New Roman")
                                    GUICtrlSetColor(-1, 0x7CCD7C)
Global Const $UnluckyGainedLabel =  GUICtrlCreateLabel("Points gained: " & $UnluckypointsGained, 320, 273, 140, 18)
                                    GUICtrlSetFont(-1, 8, 800, 0, "Times New Roman")
                                    GUICtrlSetColor(-1, 0xFF7F7F) 

Global Const $TomesLabel =          GUICtrlCreateLabel("Tomes: " & $TomesPicked, 16, 297, 140, 18)
                                    GUICtrlSetFont(-1, 8, 800, 0, "Times New Roman")
Global Const $GoldItemsLabel =      GUICtrlCreateLabel("Gold Items: " & $GoldItemsPicked, 168, 297, 140, 18)
                                    GUICtrlSetFont(-1, 8, 800, 0, "Times New Roman")
                                    GUICtrlSetColor(-1, 0xDAA520)
Global Const $PurpleItemsLabel =    GUICtrlCreateLabel("Purple Items: " & $PurpleItemsPicked, 320, 297, 140, 18)
                                    GUICtrlSetFont(-1, 8, 800, 0, "Times New Roman")
                                    GUICtrlSetColor(-1, 0x800080)

Global Const $Q8MaxGoldLabel =      GUICtrlCreateLabel("max. Req8: " & $maxQ8GoldGained, 168, 321, 140, 18)
                                    GUICtrlSetFont(-1, 8, 800, 0, "Times New Roman")
                                    GUICtrlSetColor(-1, 0xDAA520)
Global Const $Q8MaxPurpleLabel =    GUICtrlCreateLabel("max. Req8: " & $maxQ8PurpleGained, 320, 321, 140, 18)
                                    GUICtrlSetFont(-1, 8, 800, 0, "Times New Roman")
                                    GUICtrlSetColor(-1, 0x800080)
                                 
                                    GUICtrlCreateGroup("", -99, -99, 1, 1) ; Closing group
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~End Group Statistics ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   

; other options
Global Const $Rendering =           GUICtrlCreateCheckbox("Rendering?", 8, 550, 81, 18)
                                    GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")
                                    GUICtrlSetState(-1, $gui_unchecked)
								    GUICtrlSetOnEvent(-1, "ToggleRendering")

Global Const $Builds =              GUICtrlCreateCheckbox("Bubble's Builds?", 150, 550, 150, 18)
                                    GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")
                                    GUICtrlSetState(-1, $gui_unchecked)

Global Const $BubbleLabel =         GUICtrlCreateLabel("by BubbleTea", 368, 550, 85, 25)
                                    GUICtrlSetFont(-1, 10, 400, 0, "Viner Hand ITC")

Global Const $GatetrickLabel =      GUICtrlCreateLabel("Resign Gate Trick?", 160, 146, 104, 18)
                                    GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")
Global Const $ResignGateTrickBox =  GUICtrlCreateCheckbox("", 264, 146, 17, 17)

Global $GLOGBOX =                   GUICtrlCreateEdit("", 8, 359, 449, 179)
                                    GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")
                                    GUICtrlSetState($GLOGBOX, $GUI_ONTOP)

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~ Second Tab Sheet for Multiple Chestrun Options                                    
Global Const $TabSheet2 =           GUICtrlCreateTabItem("Multiple Chestrun Options")

Global Const $Label2ndTab =         GUICtrlCreateLabel("Click the Chestruns you want to combine", 8, 32, 223, 19)
                                    GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")


Global Const $Group2 =              GUICtrlCreateGroup("Tyrian + EotN Chestruns", 8, 56, 447, 120) ; Open Group Tyrian
                                    GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ First Column Start ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~                                    
Global Const $DivinersAscentBox =   GUICtrlCreateCheckbox("Diviners Ascent", 16, 80, 89, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($DivinersAscentBox, "GuiButtonHandler")
                                    GUICtrlSetState($DivinersAscentBox, $GUI_DISABLE)
Global Const $DivinersHMBox =       GUICtrlCreateCheckbox("HM", 120, 80, 33, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($DivinersHMBox, $GUI_DISABLE)
Global Const $GrenthFootprintBox =  GUICtrlCreateCheckbox("Grenth Footprint", 16, 104, 90, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($GrenthFootprintBox, "GuiButtonHandler")
                                    GUICtrlSetState($GrenthFootprintBox, $GUI_DISABLE)
Global Const $GrenthHMBox =         GUICtrlCreateCheckbox("HM", 120, 104, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($GrenthHMBox, $GUI_DISABLE)
Global Const $HellsPrecipiceBox =   GUICtrlCreateCheckbox("Hell's Precipice", 16, 128, 90, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($HellsPrecipiceBox, "GuiButtonHandler")
                                    GUICtrlSetState($HellsPrecipiceBox, $GUI_DISABLE)
Global Const $HellsHMBox =          GUICtrlCreateCheckbox("HM", 120, 128, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($HellsHMBox, $GUI_DISABLE)
Global Const $IceFloeBox =          GUICtrlCreateCheckbox("Ice Floe", 16, 152, 90, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($IceFloeBox, "GuiButtonHandler")
                                    GUICtrlSetState($IceFloeBox, $GUI_DISABLE)
Global Const $IceFloeHMBox =        GUICtrlCreateCheckbox("HM", 120, 152, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($IceFloeHMBox, $GUI_DISABLE)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ First Column End ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Global Const $Label26 =             GUICtrlCreateLabel("", 163, 64, 1, 111)
                                    GUICtrlSetBkColor(-1, 0xC8C8C8)

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Second Column Start ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  
Global Const $PeriditionRockBox =   GUICtrlCreateCheckbox("Peridition Rock", 168, 80, 89, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($PeriditionRockBox, "GuiButtonHandler")
                                    GUICtrlSetState($PeriditionRockBox, $GUI_DISABLE)
Global Const $PeriditionHMBox =     GUICtrlCreateCheckbox("HM", 264, 80, 33, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($PeriditionHMBox, $GUI_DISABLE)                                                                     
Global Const $ReedBogBox =          GUICtrlCreateCheckbox("Reed Bog", 168, 104, 81, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($ReedBogBox, "GuiButtonHandler")
                                    GUICtrlSetState($ReedBogBox, $GUI_DISABLE)
Global Const $ReedBogHMBox =        GUICtrlCreateCheckbox("HM", 264, 104, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($ReedBogHMBox, $GUI_DISABLE)
Global Const $SpearheadPeakBox =    GUICtrlCreateCheckbox("Spearhead Peak", 168, 128, 89, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($SpearheadPeakBox, "GuiButtonHandler")
                                    GUICtrlSetState($SpearheadPeakBox, $GUI_DISABLE)
Global Const $SpearheadHMBox =      GUICtrlCreateCheckbox("HM", 264, 128, 33, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($SpearheadHMBox, $GUI_DISABLE)
Global Const $TascasDemiseBox =     GUICtrlCreateCheckbox("Tascas Demise", 168, 152, 89, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($TascasDemiseBox, "GuiButtonHandler")
                                    GUICtrlSetState($TascasDemiseBox, $GUI_DISABLE)
Global Const $TascasHMBox =         GUICtrlCreateCheckbox("HM", 264, 152, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($TascasHMBox, $GUI_DISABLE)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Second Column End ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Global Const $Label22 =             GUICtrlCreateLabel("", 308, 64, 1, 111)
                                    GUICtrlSetBkColor(-1, 0xC8C8C8)

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Third Column Start ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  
Global Const $VloxenExcavationsBox = GUICtrlCreateCheckbox("Vloxens Cave", 312, 80, 81, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($VloxenExcavationsBox, "GuiButtonHandler")
                                    GUICtrlSetState($VloxenExcavationsBox, $GUI_DISABLE)
Global Const $VloxenHMBox =         GUICtrlCreateCheckbox("HM", 408, 80, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($VloxenHMBox, $GUI_DISABLE)                                  
Global Const $VultureDriftsBox =    GUICtrlCreateCheckbox("Vulture Drifts", 312, 104, 81, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($VultureDriftsBox, "GuiButtonHandler")
                                    GUICtrlSetState($VultureDriftsBox, $GUI_DISABLE)
Global Const $VultureHMBox =        GUICtrlCreateCheckbox("HM", 408, 104, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($VultureHMBox, $GUI_DISABLE)
Global Const $WitmansFollyBox =     GUICtrlCreateCheckbox("Witmans Folly", 312, 128, 89, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($WitmansFollyBox, "GuiButtonHandler")
                                    GUICtrlSetState($WitmansFollyBox, $GUI_DISABLE)
Global Const $WitmansHMBox =        GUICtrlCreateCheckbox("HM", 408, 128, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($WitmansHMBox, $GUI_DISABLE)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Third Column End ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                                    GUICtrlCreateGroup("", -99, -99, 1, 1) ; Closing group Tyrian

Global Const $Group3 =              GUICtrlCreateGroup("Canthan Chestruns", 8, 187, 447, 192) ; Open Group Canthan
                                    GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ First Column Start ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~                                    
Global Const $ArborstoneBox =       GUICtrlCreateCheckbox("Arborstone", 16, 211, 89, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($ArborstoneBox, "GuiButtonHandler")
                                    GUICtrlSetState($ArborstoneBox, $GUI_DISABLE)
Global Const $ArborstoneHMBox =     GUICtrlCreateCheckbox("HM", 120, 211, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($ArborstoneHMBox, $GUI_DISABLE)
Global Const $BukdekBywayBox =      GUICtrlCreateCheckbox("Bukdek Byway", 16, 235, 89, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($BukdekBywayBox, "GuiButtonHandler")
                                    GUICtrlSetState($BukdekBywayBox, $GUI_DISABLE)
Global Const $BukdekHMBox =         GUICtrlCreateCheckbox("HM", 120, 235, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($BukdekHMBox, $GUI_DISABLE)
Global Const $EternalGroveBox =     GUICtrlCreateCheckbox("Eternal Grove", 16, 259, 89, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($EternalGroveBox, "GuiButtonHandler")
                                    GUICtrlSetState($EternalGroveBox, $GUI_DISABLE)
Global Const $EternalHMBox =        GUICtrlCreateCheckbox("HM", 120, 259, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($EternalHMBox, $GUI_DISABLE)
Global Const $GyalaHatcheryBox =    GUICtrlCreateCheckbox("Gyala Hatchery", 16, 283, 97, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($GyalaHatcheryBox, "GuiButtonHandler")
                                    GUICtrlSetState($GyalaHatcheryBox, $GUI_DISABLE)
Global Const $GyalaHMBox =          GUICtrlCreateCheckbox("HM", 120, 283, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($GyalaHMBox, $GUI_DISABLE)
Global Const $MorostavTrailBox =    GUICtrlCreateCheckbox("Morostav Trail", 16, 307, 97, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($MorostavTrailBox, "GuiButtonHandler")
                                    GUICtrlSetState($MorostavTrailBox, $GUI_DISABLE)
Global Const $MorostavHMBox =       GUICtrlCreateCheckbox("HM", 120, 307, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($MorostavHMBox, $GUI_DISABLE)
Global Const $MourningVeilBox =     GUICtrlCreateCheckbox("Mourning Veil", 16, 331, 97, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($MourningVeilBox, "GuiButtonHandler")
                                    GUICtrlSetState($MourningVeilBox, $GUI_DISABLE)
Global Const $MourningHMBox =       GUICtrlCreateCheckbox("HM", 120, 331, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($MourningHMBox, $GUI_DISABLE)
Global Const $NahpuiQuarterBox =    GUICtrlCreateCheckbox("Nahpui Quarter", 16, 355, 89, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($NahpuiQuarterBox, "GuiButtonHandler")
                                    GUICtrlSetState($NahpuiQuarterBox, $GUI_DISABLE)
Global Const $NahpuiHMBox =         GUICtrlCreateCheckbox("HM", 120, 355, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($NahpuiHMBox, $GUI_DISABLE)                                    
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ First Column End ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

Global Const $Label23 =             GUICtrlCreateLabel("", 163, 195, 1, 183)
                                    GUICtrlSetBkColor(-1, 0xC8C8C8)

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Second Column Start ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~                                    
Global Const $PongmeiValleyBorBox = GUICtrlCreateCheckbox("Pongmei Valley B.", 168, 211, 95, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($PongmeiValleyBorBox, "GuiButtonHandler")
                                    GUICtrlSetState($PongmeiValleyBorBox, $GUI_DISABLE)
Global Const $PongmeiBorHMBox =     GUICtrlCreateCheckbox("HM", 264, 211, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($PongmeiBorHMBox, $GUI_DISABLE)
Global Const $PongmeiValleyBox =    GUICtrlCreateCheckbox("Pongmei Valley M.", 168, 235, 95, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($PongmeiValleyBox, "GuiButtonHandler")
                                    GUICtrlSetState($PongmeiValleyBox, $GUI_DISABLE)
Global Const $PongmeiHMBox =        GUICtrlCreateCheckbox("HM", 264, 235, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($PongmeiHMBox, $GUI_DISABLE)
Global Const $RaisuPalaceBox =      GUICtrlCreateCheckbox("Raisu Palace", 168, 259, 81, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($RaisuPalaceBox, "GuiButtonHandler")
                                    GUICtrlSetState($RaisuPalaceBox, $GUI_DISABLE)
Global Const $RaisuHMBox =          GUICtrlCreateCheckbox("HM", 264, 259, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($RaisuHMBox, $GUI_DISABLE)
Global Const $RheasCrateBox =       GUICtrlCreateCheckbox("Rheas Crate", 168, 283, 73, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($RheasCrateBox, "GuiButtonHandler")
                                    GUICtrlSetState($RheasCrateBox, $GUI_DISABLE)
Global Const $RheasHMBox =          GUICtrlCreateCheckbox("HM", 264, 283, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($RheasHMBox, $GUI_DISABLE)
Global Const $ShadowsPassageBox =   GUICtrlCreateCheckbox("Shadow's Passage", 168, 307, 90, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($ShadowsPassageBox, "GuiButtonHandler")
                                    GUICtrlSetState($ShadowsPassageBox, $GUI_DISABLE)
Global Const $ShadowsHMBox =        GUICtrlCreateCheckbox("HM", 264, 307, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($ShadowsHMBox, $GUI_DISABLE)
Global Const $ShenzunTunnelBox =    GUICtrlCreateCheckbox("Shenzun Tunnel", 168, 331, 90, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($ShenzunTunnelBox, "GuiButtonHandler")
                                    GUICtrlSetState($ShenzunTunnelBox, $GUI_DISABLE)
Global Const $ShenzunHMBox =        GUICtrlCreateCheckbox("HM", 264, 331, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($ShenzunHMBox, $GUI_DISABLE)
Global Const $SilentSurfBox =       GUICtrlCreateCheckbox("Silent Surf ", 168, 355, 90, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($SilentSurfBox, "GuiButtonHandler")
                                    GUICtrlSetState($SilentSurfBox, $GUI_DISABLE)
Global Const $SilentHMBox =         GUICtrlCreateCheckbox("HM", 264, 355, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($SilentHMBox, $GUI_DISABLE)                                    
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Second Column End ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   

Global Const $Label24 =             GUICtrlCreateLabel("", 308, 195, 1, 183)
                                    GUICtrlSetBkColor(-1, 0xC8C8C8)

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Third Column Start ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~                                    
Global Const $SunjiangDistrictBox = GUICtrlCreateCheckbox("Sunjiang District", 312, 211, 95, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($SunjiangDistrictBox, "GuiButtonHandler")
                                    GUICtrlSetState($SunjiangDistrictBox, $GUI_DISABLE)
Global Const $SunjiangHMBox =       GUICtrlCreateCheckbox("HM", 408, 211, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($SunjiangHMBox, $GUI_DISABLE)
Global Const $SunquaValeBox =       GUICtrlCreateCheckbox("Sunqua Vale", 312, 235, 73, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($SunquaValeBox, "GuiButtonHandler")
                                    GUICtrlSetState($SunquaValeBox, $GUI_DISABLE)
Global Const $SunquaHMBox =         GUICtrlCreateCheckbox("HM", 408, 235, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($SunquaHMBox, $GUI_DISABLE)
Global Const $TahnnakaiTempleBox =  GUICtrlCreateCheckbox("Tahnnakai Temple", 312, 259, 95, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($TahnnakaiTempleBox, "GuiButtonHandler")
                                    GUICtrlSetState($TahnnakaiTempleBox, $GUI_DISABLE)
Global Const $TahnnakaiHMBox =      GUICtrlCreateCheckbox("HM", 408, 259, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($TahnnakaiHMBox, $GUI_DISABLE)
Global Const $UndercityBox =        GUICtrlCreateCheckbox("Undercity", 312, 283, 81, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($UndercityBox, "GuiButtonHandler")
                                    GUICtrlSetState($UndercityBox, $GUI_DISABLE)
Global Const $UndercityHMBox =      GUICtrlCreateCheckbox("HM", 408, 283, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($UndercityHMBox, $GUI_DISABLE)
Global Const $UrgozWarrenBox =      GUICtrlCreateCheckbox("Urgoz's Warren", 312, 307, 81, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($UrgozWarrenBox, "GuiButtonHandler")
                                    GUICtrlSetState($UrgozWarrenBox, $GUI_DISABLE)
Global Const $UrgozHMBox =          GUICtrlCreateCheckbox("HM", 408, 307, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($UrgozHMBox, $GUI_DISABLE)                                    
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Third Column End ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~      

                                    GUICtrlCreateGroup("", -99, -99, 1, 1) ; Closing group Canthan

                                    ; Explanation for Shortcuts
Global Const $Label31 =             GUICtrlCreateLabel("Explanation: B. - Boreas Seabed, M. - Maatu Keep", 8, 381, 400, 12)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")


Global Const $Group4 =              GUICtrlCreateGroup("Elonian Chestruns", 8, 404, 447, 120) ; Open Group Elona
                                    GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ First Column Start ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~                                    
Global Const $BarbarousShoreBox =   GUICtrlCreateCheckbox("Barbarous Shore", 16, 428, 97, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($BarbarousShoreBox, "GuiButtonHandler")
                                    GUICtrlSetState($BarbarousShoreBox, $GUI_DISABLE)
Global Const $BarbarousHMBox =      GUICtrlCreateCheckbox("HM", 120, 428, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($BarbarousHMBox, $GUI_DISABLE)
Global Const $DejarinEstateBox =    GUICtrlCreateCheckbox("Dejarin Estate", 16, 452, 97, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($DejarinEstateBox, "GuiButtonHandler")
                                    GUICtrlSetState($DejarinEstateBox, $GUI_DISABLE)
Global Const $DejarinHMBox =        GUICtrlCreateCheckbox("HM", 120, 452, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($DejarinHMBox, $GUI_DISABLE)
Global Const $DomainOfFearBox =     GUICtrlCreateCheckbox("Domain of Fear", 16, 476, 89, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($DomainOfFearBox, "GuiButtonHandler")
                                    GUICtrlSetState($DomainOfFearBox, $GUI_DISABLE)
Global Const $DomainHMBox =         GUICtrlCreateCheckbox("HM", 120, 476, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($DomainHMBox, $GUI_DISABLE)
Global Const $DrakesOnAPlainBox =   GUICtrlCreateCheckbox("Drakes on a Plain", 16, 500, 100, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($DrakesOnAPlainBox, "GuiButtonHandler")
                                    GUICtrlSetState($DrakesOnAPlainBox, $GUI_DISABLE)
Global Const $DrakesHMBox =         GUICtrlCreateCheckbox("HM", 120, 500, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($DrakesHMBox, $GUI_DISABLE)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ First Column End ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

Global Const $Label25 =             GUICtrlCreateLabel("", 163, 412, 1, 111)
                                    GUICtrlSetBkColor(-1, 0xC8C8C8)

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Second Column Start ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~                                    
Global Const $FloodplainBox =       GUICtrlCreateCheckbox("Floodplain of M.", 168, 428, 95, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($FloodplainBox, "GuiButtonHandler")
                                    GUICtrlSetState($FloodplainBox, $GUI_DISABLE)
Global Const $FloodplainHMBox =     GUICtrlCreateCheckbox("HM", 264, 428, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($FloodplainHMBox, $GUI_DISABLE)                                    
Global Const $GandaraTheMoonFortressBox =GUICtrlCreateCheckbox("Gandara", 168, 452, 89, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($GandaraTheMoonFortressBox, "GuiButtonHandler")
                                    GUICtrlSetState($GandaraTheMoonFortressBox, $GUI_DISABLE)
Global Const $GandaraHMBox =        GUICtrlCreateCheckbox("HM", 264, 452, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($GandaraHMBox, $GUI_DISABLE)
Global Const $SunwardMarchesBox =   GUICtrlCreateCheckbox("Sunward Marches", 168, 476, 95, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($SunwardMarchesBox, "GuiButtonHandler")
                                    GUICtrlSetState($SunwardMarchesBox, $GUI_DISABLE)
Global Const $SunwardHMBox =        GUICtrlCreateCheckbox("HM", 264, 476, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($SunwardHMBox, $GUI_DISABLE)                                    
Global Const $TuraisDesolationShortBox =GUICtrlCreateCheckbox("Turais Deso - S", 168, 500, 81, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($TuraisDesolationShortBox, "GuiButtonHandler")
                                    GUICtrlSetState($TuraisDesolationShortBox, $GUI_DISABLE)
Global Const $TuraisDesoSHMBox =    GUICtrlCreateCheckbox("HM", 264, 500, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($TuraisDesoSHMBox, $GUI_DISABLE)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Second Column End ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~     

Global Const $Label29 =             GUICtrlCreateLabel("", 308, 412, 1, 111)
                                    GUICtrlSetBkColor(-1, 0xC8C8C8)

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Third Column Start ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~                                    
Global Const $TuraisDesolationLongBox =GUICtrlCreateCheckbox("Turais Deso - L", 312, 428, 89, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($TuraisDesolationLongBox, "GuiButtonHandler")
                                    GUICtrlSetState($TuraisDesolationLongBox, $GUI_DISABLE)
Global Const $TuraisDesoLHMBox =    GUICtrlCreateCheckbox("HM", 408, 428, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($TuraisDesoLHMBox, $GUI_DISABLE)
Global Const $TuraisVentaBox =      GUICtrlCreateCheckbox("Turais Venta", 312, 452, 89, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetOnEvent($TuraisVentaBox, "GuiButtonHandler")
                                    GUICtrlSetState($TuraisVentaBox, $GUI_DISABLE)
Global Const $TuraisVentaHMBox =    GUICtrlCreateCheckbox("HM", 408, 452, 41, 17)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
                                    GUICtrlSetState($TuraisVentaHMBox, $GUI_DISABLE)
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Third Column End ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

                                    GUICtrlCreateGroup("", -99, -99, 1, 1) ; Closing group Elona

                                    ; Explanation Shortcuts and the dirty rest
Global Const $Label19 =             GUICtrlCreateLabel("How many Runs should be done per Chestrun before it changes the area?", 8, 550, 396, 19)
                                    GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")                                    
Global $InputChangeRuns =           GUICtrlCreateInput($SetsChangeRuns, 408, 548, 49, 23, BitOR($GUI_SS_DEFAULT_INPUT,$ES_CENTER))
                                    GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")
                                    GUICtrlSetState($InputChangeRuns, $GUI_DISABLE)
Global Const $Label27 =             GUICtrlCreateLabel("Explanation: Deso - Desolation, Venta - Venta Cemetery, S - Short, L - Long, M. - Mahnkelon", 8, 526, 400, 12)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")
Global Const $Label28 =             GUICtrlCreateLabel("", 8, 524, 361, 18)
                                    GUICtrlSetFont(-1, 8, 400, 0, "Times New Roman")

                                    GUICtrlCreateTabItem("")


                                    GUISetState(@SW_SHOW)
                                    GUISetOnEvent($GUI_EVENT_CLOSE, "GuiButtonHandler")


;~ Description: Handles the button presses
Func GuiButtonHandler()
    Switch @GUI_CtrlId

        ; Startbutton Press
        Case $Button
            If $BotRunning Then
				GUICtrlSetData($Button, "Will pause after this run")
                GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")
				GUICtrlSetState($Button, $GUI_DISABLE)
				$BotRunning = False
			ElseIf $Bot_Core_Initialized Then
				GUICtrlSetData($Button, "Pause")
                GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")
				$BotRunning = True
			Else
				Out("Initializing")
				Local $CharName = GUICtrlRead($Input)
				If $CharName=="" Then
					If Core_Initialize(ProcessExists("gw.exe"), True) = 0 Then
						MsgBox(0, "Error", "Guild Wars is not running.")
						_Exit()
					EndIf
                ElseIf $ProcessID Then
					$proc_id_int = Number($ProcessID, 2)
					If Core_Initialize($proc_id_int, True) = 0 Then
						MsgBox(0, "Error", "Could not Find a ProcessID or somewhat '"&$proc_id_int&"'  "&VarGetType($proc_id_int)&"'")
						_Exit()
						If ProcessExists($proc_id_int) Then
							ProcessClose($proc_id_int)
						EndIf
						Exit
					EndIf
				Else
					If Core_Initialize($CharName, True) = 0 Then
						MsgBox(0, "Error", "Could not Find a Guild Wars client with a Character named '"&$CharName&"'")
						_Exit()
					EndIf
				EndIf

                ; When Start is first clicked this will happen
                ; Disable and Enable Certain Features and Buttons on the Gui
				GUICtrlSetState($Rendering, $GUI_ENABLE) ; can change the rendering checkbox
				GUICtrlSetState($Input, $GUI_DISABLE)   ; can't change the Character Name
                GUICtrlSetState($Chestrun, $GUI_DISABLE)   ; can't change the chosen Chestrun
                GUICtrlSetState($InputChangeRuns, $GUI_DISABLE)   ; can't change the Sets per Run
                GUICtrlSetState($HardMODECheckbox, $GUI_DISABLE)  ; can't change Hard- or Normalmode
                GUICtrlSetState($ResignGateTrickBox, $GUI_DISABLE)  ; can't change Gate Trick or not
                GUICtrlSetState($Builds, $GUI_DISABLE)  ; can't change the Option for using Bubbles Builds
                ; Can't change any Checkbox on the second tab,
                ; Tyrian Group
                GUICtrlSetState($DivinersAscentBox, $GUI_DISABLE)
                GUICtrlSetState($DivinersHMBox, $GUI_DISABLE)
                GUICtrlSetState($GrenthFootprintBox, $GUI_DISABLE)
                GUICtrlSetState($GrenthHMBox, $GUI_DISABLE)
                GUICtrlSetState($HellsPrecipiceBox, $GUI_DISABLE)
                GUICtrlSetState($HellsHMBox, $GUI_DISABLE)
                GUICtrlSetState($IceFloeBox, $GUI_DISABLE)
                GUICtrlSetState($IceFloeHMBox, $GUI_DISABLE)
                GUICtrlSetState($PeriditionRockBox, $GUI_DISABLE)
                GUICtrlSetState($PeriditionHMBox, $GUI_DISABLE)
                GUICtrlSetState($ReedBogBox, $GUI_DISABLE)
                GUICtrlSetState($ReedBogHMBox, $GUI_DISABLE)
                GUICtrlSetState($SpearheadPeakBox, $GUI_DISABLE)
                GUICtrlSetState($SpearheadHMBox, $GUI_DISABLE)
                GUICtrlSetState($TascasDemiseBox, $GUI_DISABLE)
                GUICtrlSetState($TascasHMBox, $GUI_DISABLE)
                GUICtrlSetState($VloxenExcavationsBox, $GUI_DISABLE)
                GUICtrlSetState($VloxenHMBox, $GUI_DISABLE)
                GUICtrlSetState($VultureDriftsBox, $GUI_DISABLE)
                GUICtrlSetState($VultureHMBox, $GUI_DISABLE)
                GUICtrlSetState($WitmansFollyBox, $GUI_DISABLE)
                GUICtrlSetState($WitmansHMBox, $GUI_DISABLE)                
                
                ; Canthan Group
                GUICtrlSetState($ArborstoneBox, $GUI_DISABLE)
                GUICtrlSetState($ArborstoneHMBox, $GUI_DISABLE)
                GUICtrlSetState($BukdekBywayBox, $GUI_DISABLE)
                GUICtrlSetState($BukdekHMBox, $GUI_DISABLE)
                GUICtrlSetState($EternalGroveBox, $GUI_DISABLE)
                GUICtrlSetState($EternalHMBox, $GUI_DISABLE)
                GUICtrlSetState($GyalaHatcheryBox, $GUI_DISABLE)
                GUICtrlSetState($GyalaHMBox, $GUI_DISABLE)
                GUICtrlSetState($MorostavTrailBox, $GUI_DISABLE)
                GUICtrlSetState($MorostavHMBox, $GUI_DISABLE)
                GUICtrlSetState($MourningVeilBox, $GUI_DISABLE)
                GUICtrlSetState($MourningHMBox, $GUI_DISABLE)
                GUICtrlSetState($NahpuiQuarterBox, $GUI_DISABLE)
                GUICtrlSetState($NahpuiHMBox, $GUI_DISABLE)
                GUICtrlSetState($PongmeiValleyBorBox, $GUI_DISABLE)
                GUICtrlSetState($PongmeiBorHMBox, $GUI_DISABLE)
                GUICtrlSetState($PongmeiValleyBox, $GUI_DISABLE)
                GUICtrlSetState($PongmeiHMBox, $GUI_DISABLE)
                GUICtrlSetState($RaisuPalaceBox, $GUI_DISABLE)
                GUICtrlSetState($RaisuHMBox, $GUI_DISABLE)
                GUICtrlSetState($RheasCrateBox, $GUI_DISABLE)
                GUICtrlSetState($RheasHMBox, $GUI_DISABLE)
                GUICtrlSetState($ShadowsPassageBox, $GUI_DISABLE)
                GUICtrlSetState($ShadowsHMBox, $GUI_DISABLE)
                GUICtrlSetState($ShenzunTunnelBox, $GUI_DISABLE)
                GUICtrlSetState($ShenzunHMBox, $GUI_DISABLE)
                GUICtrlSetState($SilentSurfBox, $GUI_DISABLE)
                GUICtrlSetState($SilentHMBox, $GUI_DISABLE)
                GUICtrlSetState($SunjiangDistrictBox, $GUI_DISABLE)
                GUICtrlSetState($SunjiangHMBox, $GUI_DISABLE)
                GUICtrlSetState($SunquaValeBox, $GUI_DISABLE)
                GUICtrlSetState($SunquaHMBox, $GUI_DISABLE)         
                GUICtrlSetState($TahnnakaiTempleBox, $GUI_DISABLE)
                GUICtrlSetState($TahnnakaiHMBox, $GUI_DISABLE)       
                GUICtrlSetState($UndercityBox, $GUI_DISABLE)
                GUICtrlSetState($UndercityHMBox, $GUI_DISABLE)
                GUICtrlSetState($UrgozWarrenBox, $GUI_DISABLE)
                GUICtrlSetState($UrgozHMBox, $GUI_DISABLE)
                
                ; Elonian Group
                GUICtrlSetState($BarbarousShoreBox, $GUI_DISABLE)
                GUICtrlSetState($BarbarousHMBox, $GUI_DISABLE)
                GUICtrlSetState($DejarinEstateBox, $GUI_DISABLE)
                GUICtrlSetState($DejarinHMBox, $GUI_DISABLE)
                GUICtrlSetState($DomainOfFearBox, $GUI_DISABLE)
                GUICtrlSetState($DomainHMBox, $GUI_DISABLE)
                GUICtrlSetState($DrakesOnAPlainBox, $GUI_DISABLE)
                GUICtrlSetState($DrakesHMBox, $GUI_DISABLE)
                GUICtrlSetState($FloodplainBox, $GUI_DISABLE)
                GUICtrlSetState($FloodplainHMBox, $GUI_DISABLE)
                GUICtrlSetState($GandaraTheMoonFortressBox, $GUI_DISABLE)
                GUICtrlSetState($GandaraHMBox, $GUI_DISABLE)
                GUICtrlSetState($SunwardMarchesBox, $GUI_DISABLE)
                GUICtrlSetState($SunwardHMBox, $GUI_DISABLE)
                GUICtrlSetState($TuraisDesolationShortBox, $GUI_DISABLE)
                GUICtrlSetState($TuraisDesoSHMBox, $GUI_DISABLE)
                GUICtrlSetState($TuraisDesolationLongBox, $GUI_DISABLE)
                GUICtrlSetState($TuraisDesoLHMBox, $GUI_DISABLE)
                GUICtrlSetState($TuraisVentaBox, $GUI_DISABLE)
                GUICtrlSetState($TuraisVentaHMBox, $GUI_DISABLE)
                
                
				GUICtrlSetData($Button, "Pause")        ; Start Button is showing "Pause" now
                GUICtrlSetFont(-1, 10, 400, 0, "Times New Roman")

                ; Set the Window Title to the Character Name
				WinSetTitle($mainGui, "", Player_GetCharname() & " - BubbleTea's Chestruns")   ; Bot Window has the Character Name now

                ; Update the Numbers for Statistics on the first Page of the Gui
                $ChestTitle = GetChesttitle()
                $LuckyTitle = GetLuckytitle()
                $UnluckyTitle = GetUnluckytitle()
                $LockpicksLeft = GetNumberOfLockpicks()
                $LockpicksBefore = $LockpicksLeft
                UpdateStatistics()

                Global Const $LuckyPointsStart = Title_GetTitleInfo($GC_E_TITLEID_LUCKY, "CurrentPoints")
                Sleep(100)
                Global Const $UnluckyPointsStart = Title_GetTitleInfo($GC_E_TITLEID_UNLUCKY, "CurrentPoints")
                Sleep(100)

                ; Choosing the appropriate Farm based on the chosen Chestrun
                $Chosen_Chestrun = GUICtrlRead($Chestrun)
                
                ; Get Input Value, when multiple Runs are selected
                If $Chosen_Chestrun = "Multiple Chestruns" Then
                    $SetsChangeRuns = GUICtrlRead($InputChangeRuns)

                    ; Read all activated farms and store them in an array as well as the chosen difficulty
                    ; Tyria + EotN Group
                    If GUICtrlRead($DivinersAscentBox) = $GUI_Checked Then
                        Redim $multRunAr[UBound($multRunAr) + 1]
                        Redim $multRunHMAr[UBound($multRunHMAr) + 1]
                        $multRunAr[UBound($multRunAr) - 1] = "Diviners Ascent"
                        If GUICtrlRead($DivinersHMBox) = $GUI_Checked Then
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_HARD
                        Else
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_NORMAL
                        EndIf
                    EndIf
                    If GUICtrlRead($PeriditionRockBox) = $GUI_Checked Then
                        Redim $multRunAr[UBound($multRunAr) + 1]
                        Redim $multRunHMAr[UBound($multRunHMAr) + 1]
                        $multRunAr[UBound($multRunAr) - 1] = "Peridition Rock"
                        If GUICtrlRead($PeriditionHMBox) = $GUI_Checked Then
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_HARD
                        Else
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_NORMAL
                        EndIf
                    EndIf
                    If GUICtrlRead($VloxenExcavationsBox) = $GUI_Checked Then
                        Redim $multRunAr[UBound($multRunAr) + 1]
                        Redim $multRunHMAr[UBound($multRunHMAr) + 1]
                        $multRunAr[UBound($multRunAr) - 1] = "Vloxens Cave"
                        If GUICtrlRead($VloxenHMBox) = $GUI_Checked Then
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_HARD
                        Else
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_NORMAL
                        EndIf
                    EndIf
                    If GUICtrlRead($VultureDriftsBox) = $GUI_Checked Then
                        Redim $multRunAr[UBound($multRunAr) + 1]
                        Redim $multRunHMAr[UBound($multRunHMAr) + 1]
                        $multRunAr[UBound($multRunAr) - 1] = "Vulture Drifts"
                        If GUICtrlRead($VultureHMBox) = $GUI_Checked Then
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_HARD
                        Else
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_NORMAL
                        EndIf
                    EndIf
                    If GUICtrlRead($WitmansFollyBox) = $GUI_Checked Then
                        Redim $multRunAr[UBound($multRunAr) + 1]
                        Redim $multRunHMAr[UBound($multRunHMAr) + 1]
                        $multRunAr[UBound($multRunAr) - 1] = "Witmans Folly"
                        If GUICtrlRead($WitmansHMBox) = $GUI_Checked Then
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_HARD
                        Else
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_NORMAL
                        EndIf
                    EndIf      

                    ; Canthan Group
                    If GUICtrlRead($BukdekBywayBox) = $GUI_Checked Then
                        Redim $multRunAr[UBound($multRunAr) + 1]
                        Redim $multRunHMAr[UBound($multRunHMAr) + 1]
                        $multRunAr[UBound($multRunAr) - 1] = "Bukdek Byway"
                        If GUICtrlRead($BukdekHMBox) = $GUI_Checked Then
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_HARD
                        Else
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_NORMAL
                        EndIf
                    EndIf
                    If GUICtrlRead($GyalaHatcheryBox) = $GUI_Checked Then
                        Redim $multRunAr[UBound($multRunAr) + 1]
                        Redim $multRunHMAr[UBound($multRunHMAr) + 1]
                        $multRunAr[UBound($multRunAr) - 1] = "Gyala Hatchery"
                        If GUICtrlRead($GyalaHMBox) = $GUI_Checked Then
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_HARD
                        Else
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_NORMAL
                        EndIf
                    EndIf
                    If GUICtrlRead($MorostavTrailBox) = $GUI_Checked Then
                        Redim $multRunAr[UBound($multRunAr) + 1]
                        Redim $multRunHMAr[UBound($multRunHMAr) + 1]
                        $multRunAr[UBound($multRunAr) - 1] = "Morostav Trail"
                        If GUICtrlRead($MorostavHMBox) = $GUI_Checked Then
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_HARD
                        Else
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_NORMAL
                        EndIf
                    EndIf
                    If GUICtrlRead($NahpuiQuarterBox) = $GUI_Checked Then
                        Redim $multRunAr[UBound($multRunAr) + 1]
                        Redim $multRunHMAr[UBound($multRunHMAr) + 1]
                        $multRunAr[UBound($multRunAr) - 1] = "Nahpui Quarter"
                        If GUICtrlRead($NahpuiHMBox) = $GUI_Checked Then
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_HARD
                        Else
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_NORMAL
                        EndIf
                    EndIf
                    If GUICtrlRead($PongmeiValleyBox) = $GUI_Checked Then
                        Redim $multRunAr[UBound($multRunAr) + 1]
                        Redim $multRunHMAr[UBound($multRunHMAr) + 1]
                        $multRunAr[UBound($multRunAr) - 1] = "Pongmei Valley Maatu"
                        If GUICtrlRead($PongmeiHMBox) = $GUI_Checked Then
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_HARD
                        Else
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_NORMAL
                        EndIf
                    EndIf
                    If GUICtrlRead($RaisuPalaceBox) = $GUI_Checked Then
                        Redim $multRunAr[UBound($multRunAr) + 1]
                        Redim $multRunHMAr[UBound($multRunHMAr) + 1]
                        $multRunAr[UBound($multRunAr) - 1] = "Raisu Palace"
                        If GUICtrlRead($RaisuHMBox) = $GUI_Checked Then
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_HARD
                        Else
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_NORMAL
                        EndIf
                    EndIf
                    If GUICtrlRead($RheasCrateBox) = $GUI_Checked Then
                        Redim $multRunAr[UBound($multRunAr) + 1]
                        Redim $multRunHMAr[UBound($multRunHMAr) + 1]
                        $multRunAr[UBound($multRunAr) - 1] = "Rheas Crate"
                        If GUICtrlRead($RheasHMBox) = $GUI_Checked Then
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_HARD
                        Else
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_NORMAL
                        EndIf
                    EndIf
                    If GUICtrlRead($SilentSurfBox) = $GUI_Checked Then
                        Redim $multRunAr[UBound($multRunAr) + 1]
                        Redim $multRunHMAr[UBound($multRunHMAr) + 1]
                        $multRunAr[UBound($multRunAr) - 1] = "Silent Surf"
                        If GUICtrlRead($SilentHMBox) = $GUI_Checked Then
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_HARD
                        Else
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_NORMAL
                        EndIf
                    EndIf
                    If GUICtrlRead($SunquaValeBox) = $GUI_Checked Then
                        Redim $multRunAr[UBound($multRunAr) + 1]
                        Redim $multRunHMAr[UBound($multRunHMAr) + 1]
                        $multRunAr[UBound($multRunAr) - 1] = "Sunqua Vale"
                        If GUICtrlRead($SunquaHMBox) = $GUI_Checked Then
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_HARD
                        Else
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_NORMAL
                        EndIf
                    EndIf       

                    ; Elonian Group
                    If GUICtrlRead($DejarinEstateBox) = $GUI_Checked Then
                        Redim $multRunAr[UBound($multRunAr) + 1]
                        Redim $multRunHMAr[UBound($multRunHMAr) + 1]
                        $multRunAr[UBound($multRunAr) - 1] = "Dejarin Estate"
                        If GUICtrlRead($DejarinHMBox) = $GUI_Checked Then
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_HARD
                        Else
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_NORMAL
                        EndIf
                    EndIf
                    If GUICtrlRead($DomainOfFearBox) = $GUI_Checked Then
                        Redim $multRunAr[UBound($multRunAr) + 1]
                        Redim $multRunHMAr[UBound($multRunHMAr) + 1]
                        $multRunAr[UBound($multRunAr) - 1] = "Domain of Fear"
                        If GUICtrlRead($DomainHMBox) = $GUI_Checked Then
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_HARD
                        Else
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_NORMAL
                        EndIf
                    EndIf
                    If GUICtrlRead($DrakesOnAPlainBox) = $GUI_Checked Then
                        Redim $multRunAr[UBound($multRunAr) + 1]
                        Redim $multRunHMAr[UBound($multRunHMAr) + 1]
                        $multRunAr[UBound($multRunAr) - 1] = "Drakes on a Plain"
                        If GUICtrlRead($DrakesHMBox) = $GUI_Checked Then
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_HARD
                        Else
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_NORMAL
                        EndIf
                    EndIf
                    If GUICtrlRead($GandaraTheMoonFortressBox) = $GUI_Checked Then
                        Redim $multRunAr[UBound($multRunAr) + 1]
                        Redim $multRunHMAr[UBound($multRunHMAr) + 1]
                        $multRunAr[UBound($multRunAr) - 1] = "Gandara the Moon Fortress"
                        If GUICtrlRead($GandaraHMBox) = $GUI_Checked Then
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_HARD
                        Else
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_NORMAL
                        EndIf
                    EndIf
                    If GUICtrlRead($TuraisDesolationShortBox) = $GUI_Checked Then
                        Redim $multRunAr[UBound($multRunAr) + 1]
                        Redim $multRunHMAr[UBound($multRunHMAr) + 1]
                        $multRunAr[UBound($multRunAr) - 1] = "Turais Desolation - Short"
                        If GUICtrlRead($TuraisDesoSHMBox) = $GUI_Checked Then
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_HARD
                        Else
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_NORMAL
                        EndIf
                    EndIf
                    If GUICtrlRead($TuraisDesolationLongBox) = $GUI_Checked Then
                        Redim $multRunAr[UBound($multRunAr) + 1]
                        Redim $multRunHMAr[UBound($multRunHMAr) + 1]
                        $multRunAr[UBound($multRunAr) - 1] = "Turais Desolation - Long"
                        If GUICtrlRead($TuraisDesoLHMBox) = $GUI_Checked Then
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_HARD
                        Else
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_NORMAL
                        EndIf
                    EndIf
                    If GUICtrlRead($TuraisVentaBox) = $GUI_Checked Then
                        Redim $multRunAr[UBound($multRunAr) + 1]
                        Redim $multRunHMAr[UBound($multRunHMAr) + 1]
                        $multRunAr[UBound($multRunAr) - 1] = "Turais Venta Cemetery"
                        If GUICtrlRead($TuraisVentaHMBox) = $GUI_Checked Then
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_HARD
                        Else
                            $multRunHMAr[UBound($multRunHMAr) - 1] = $DIFFICULTY_NORMAL
                        EndIf
                    EndIf                                     

                    ; Number of Multiple Runs to do, so if you clicked on 6 chestruns the array length is 6
                    $multRunLoop = UBound($multRunAr)
                EndIF

				$BotRunning = True
				$BotInitialized = True
			EndIf

        ; This will be executed, when you switch different things in the Dropdown Menue for Chestruns
        Case $Chestrun
            If GUICtrlRead($Chestrun) = "Multiple Chestruns" Then
                GUICtrlSetState($InputChangeRuns, $GUI_ENABLE)
                GUICtrlSetState($HardMODECheckbox, $GUI_DISABLE)

                ; Only Enable the Checkboxes for the Farms not for the HM switch - those will be later activated only for the chosen farms
                ; Tyrian Group
                GUICtrlSetState($DivinersAscentBox, $GUI_ENABLE)
                GUICtrlSetState($DivinersHMBox, $GUI_DISABLE)
                GUICtrlSetState($PeriditionRockBox, $GUI_ENABLE)
                GUICtrlSetState($PeriditionHMBox, $GUI_DISABLE)
                GUICtrlSetState($VloxenExcavationsBox, $GUI_ENABLE)
                GUICtrlSetState($VloxenHMBox, $GUI_DISABLE)
                GUICtrlSetState($VultureDriftsBox, $GUI_ENABLE)
                GUICtrlSetState($VultureHMBox, $GUI_DISABLE)
                GUICtrlSetState($WitmansFollyBox, $GUI_ENABLE)
                GUICtrlSetState($WitmansHMBox, $GUI_DISABLE)
                
                ; Canthan Group
                GUICtrlSetState($BukdekBywayBox, $GUI_ENABLE)
                GUICtrlSetState($BukdekHMBox, $GUI_DISABLE)
                GUICtrlSetState($GyalaHatcheryBox, $GUI_ENABLE)
                GUICtrlSetState($GyalaHMBox, $GUI_DISABLE)
                GUICtrlSetState($MorostavTrailBox, $GUI_ENABLE)
                GUICtrlSetState($MorostavHMBox, $GUI_DISABLE)
                GUICtrlSetState($NahpuiQuarterBox, $GUI_ENABLE)
                GUICtrlSetState($NahpuiHMBox, $GUI_DISABLE)
                GUICtrlSetState($PongmeiValleyBox, $GUI_ENABLE)
                GUICtrlSetState($PongmeiHMBox, $GUI_DISABLE)
                GUICtrlSetState($RaisuPalaceBox, $GUI_ENABLE)
                GUICtrlSetState($RaisuHMBox, $GUI_DISABLE)
                GUICtrlSetState($RheasCrateBox, $GUI_ENABLE)
                GUICtrlSetState($RheasHMBox, $GUI_DISABLE)
                GUICtrlSetState($SilentSurfBox, $GUI_ENABLE)
                GUICtrlSetState($SilentHMBox, $GUI_DISABLE)
                GUICtrlSetState($SunquaValeBox, $GUI_ENABLE)
                GUICtrlSetState($SunquaHMBox, $GUI_DISABLE)
                
                ; Elonian Group
                GUICtrlSetState($DejarinEstateBox, $GUI_ENABLE)
                GUICtrlSetState($DejarinHMBox, $GUI_DISABLE)
                GUICtrlSetState($DomainOfFearBox, $GUI_ENABLE)
                GUICtrlSetState($DomainHMBox, $GUI_DISABLE)
                GUICtrlSetState($DrakesOnAPlainBox, $GUI_ENABLE)
                GUICtrlSetState($DrakesHMBox, $GUI_DISABLE)
                GUICtrlSetState($GandaraTheMoonFortressBox, $GUI_ENABLE)
                GUICtrlSetState($GandaraHMBox, $GUI_DISABLE)
                GUICtrlSetState($TuraisDesolationShortBox, $GUI_ENABLE)
                GUICtrlSetState($TuraisDesoSHMBox, $GUI_DISABLE)
                GUICtrlSetState($TuraisDesolationLongBox, $GUI_ENABLE)
                GUICtrlSetState($TuraisDesoLHMBox, $GUI_DISABLE)
                GUICtrlSetState($TuraisVentaBox, $GUI_ENABLE)
                GUICtrlSetState($TuraisVentaHMBox, $GUI_DISABLE)
                
            Else
                ; If not the Multiple Chestrun option was chosen, disable the second tab
                GUICtrlSetState($InputChangeRuns, $GUI_DISABLE)
                GUICtrlSetState($HardMODECheckbox, $GUI_ENABLE)
                ; Tyrian Group
                GUICtrlSetState($DivinersAscentBox, $GUI_DISABLE)
                GUICtrlSetState($DivinersHMBox, $GUI_DISABLE)
                GUICtrlSetState($PeriditionRockBox, $GUI_DISABLE)
                GUICtrlSetState($PeriditionHMBox, $GUI_DISABLE)
                GUICtrlSetState($VloxenExcavationsBox, $GUI_DISABLE)
                GUICtrlSetState($VloxenHMBox, $GUI_DISABLE)
                GUICtrlSetState($VultureDriftsBox, $GUI_DISABLE)
                GUICtrlSetState($VultureHMBox, $GUI_DISABLE)
                GUICtrlSetState($WitmansFollyBox, $GUI_DISABLE)
                GUICtrlSetState($WitmansHMBox, $GUI_DISABLE)
                 
                ; Canthan Group
                GUICtrlSetState($BukdekBywayBox, $GUI_DISABLE)
                GUICtrlSetState($BukdekHMBox, $GUI_DISABLE)
                GUICtrlSetState($GyalaHatcheryBox, $GUI_DISABLE)
                GUICtrlSetState($GyalaHMBox, $GUI_DISABLE)
                GUICtrlSetState($MorostavTrailBox, $GUI_DISABLE)
                GUICtrlSetState($MorostavHMBox, $GUI_DISABLE)
                GUICtrlSetState($NahpuiQuarterBox, $GUI_DISABLE)
                GUICtrlSetState($NahpuiHMBox, $GUI_DISABLE)
                GUICtrlSetState($PongmeiValleyBox, $GUI_DISABLE)
                GUICtrlSetState($PongmeiHMBox, $GUI_DISABLE)
                GUICtrlSetState($RaisuPalaceBox, $GUI_DISABLE)
                GUICtrlSetState($RaisuHMBox, $GUI_DISABLE)
                GUICtrlSetState($RheasCrateBox, $GUI_DISABLE)
                GUICtrlSetState($RheasHMBox, $GUI_DISABLE)
                GUICtrlSetState($SilentSurfBox, $GUI_DISABLE)
                GUICtrlSetState($SilentHMBox, $GUI_DISABLE)
                GUICtrlSetState($SunquaValeBox, $GUI_DISABLE)
                GUICtrlSetState($SunquaHMBox, $GUI_DISABLE)
                              
                ; Elonian Group
                GUICtrlSetState($DejarinEstateBox, $GUI_DISABLE)
                GUICtrlSetState($DejarinHMBox, $GUI_DISABLE)
                GUICtrlSetState($DomainOfFearBox, $GUI_DISABLE)
                GUICtrlSetState($DomainHMBox, $GUI_DISABLE)
                GUICtrlSetState($DrakesOnAPlainBox, $GUI_DISABLE)
                GUICtrlSetState($DrakesHMBox, $GUI_DISABLE)
                GUICtrlSetState($GandaraTheMoonFortressBox, $GUI_DISABLE)
                GUICtrlSetState($GandaraHMBox, $GUI_DISABLE)
                GUICtrlSetState($TuraisDesolationShortBox, $GUI_DISABLE)
                GUICtrlSetState($TuraisDesoSHMBox, $GUI_DISABLE)
                GUICtrlSetState($TuraisDesolationLongBox, $GUI_DISABLE)
                GUICtrlSetState($TuraisDesoLHMBox, $GUI_DISABLE)
                GUICtrlSetState($TuraisVentaBox, $GUI_DISABLE)
                GUICtrlSetState($TuraisVentaHMBox, $GUI_DISABLE)
                
            EndIf
        
        ; The next cases are for every farm in the Multiple Chestrun Tab - when the Checkbox is clicked, you can also chose the option for Hardmode
        ; Tyrian + EotN Group
        Case $DivinersAscentBox
            If GUICtrlRead($DivinersAscentBox) = $GUI_Checked Then
                GUICtrlSetState($DivinersHMBox, $GUI_ENABLE)
            Else
                GUICtrlSetState($DivinersHMBox, $GUI_DISABLE)
            EndIf
        Case $PeriditionRockBox
            If GUICtrlRead($PeriditionRockBox) = $GUI_Checked Then
                GUICtrlSetState($PeriditionHMBox, $GUI_ENABLE)
            Else
                GUICtrlSetState($PeriditionHMBox, $GUI_DISABLE)
            EndIf
        Case $VloxenExcavationsBox
            If GUICtrlRead($VloxenExcavationsBox) = $GUI_Checked Then
                GUICtrlSetState($VloxenHMBox, $GUI_ENABLE)
            Else
                GUICtrlSetState($VloxenHMBox, $GUI_DISABLE)
            EndIf
        Case $VultureDriftsBox
            If GUICtrlRead($VultureDriftsBox) = $GUI_Checked Then
                GUICtrlSetState($VultureHMBox, $GUI_ENABLE)
            Else
                GUICtrlSetState($VultureHMBox, $GUI_DISABLE)
            EndIf
        Case $WitmansFollyBox
            If GUICtrlRead($WitmansFollyBox) = $GUI_Checked Then
                GUICtrlSetState($WitmansHMBox, $GUI_ENABLE)
            Else
                GUICtrlSetState($WitmansHMBox, $GUI_DISABLE)
            EndIf
               
        ; Canthan Group
        Case $BukdekBywayBox
            If GUICtrlRead($BukdekBywayBox) = $GUI_Checked Then
                GUICtrlSetState($BukdekHMBox, $GUI_ENABLE)
            Else
                GUICtrlSetState($BukdekHMBox, $GUI_DISABLE)
            EndIf
        Case $GyalaHatcheryBox
            If GUICtrlRead($GyalaHatcheryBox) = $GUI_Checked Then
                GUICtrlSetState($GyalaHMBox, $GUI_ENABLE)
            Else
                GUICtrlSetState($GyalaHMBox, $GUI_DISABLE)
            EndIf
        Case $MorostavTrailBox
            If GUICtrlRead($MorostavTrailBox) = $GUI_Checked Then
                GUICtrlSetState($MorostavHMBox, $GUI_ENABLE)
            Else
                GUICtrlSetState($MorostavHMBox, $GUI_DISABLE)
            EndIf
        Case $NahpuiQuarterBox
            If GUICtrlRead($NahpuiQuarterBox) = $GUI_Checked Then
                GUICtrlSetState($NahpuiHMBox, $GUI_ENABLE)
            Else
                GUICtrlSetState($NahpuiHMBox, $GUI_DISABLE)
            EndIf
        Case $PongmeiValleyBox
            If GUICtrlRead($PongmeiValleyBox) = $GUI_Checked Then
                GUICtrlSetState($PongmeiHMBox, $GUI_ENABLE)
            Else
                GUICtrlSetState($PongmeiHMBox, $GUI_DISABLE)
            EndIf
        Case $RaisuPalaceBox
            If GUICtrlRead($RaisuPalaceBox) = $GUI_Checked Then
                GUICtrlSetState($RaisuHMBox, $GUI_ENABLE)
            Else
                GUICtrlSetState($RaisuHMBox, $GUI_DISABLE)
            EndIf
        Case $RheasCrateBox
            If GUICtrlRead($RheasCrateBox) = $GUI_Checked Then
                GUICtrlSetState($RheasHMBox, $GUI_ENABLE)
            Else
                GUICtrlSetState($RheasHMBox, $GUI_DISABLE)
            EndIf
        Case $SilentSurfBox
            If GUICtrlRead($SilentSurfBox) = $GUI_Checked Then
                GUICtrlSetState($SilentHMBox, $GUI_ENABLE)
            Else
                GUICtrlSetState($SilentHMBox, $GUI_DISABLE)
            EndIf
        Case $SunquaValeBox
            If GUICtrlRead($SunquaValeBox) = $GUI_Checked Then
                GUICtrlSetState($SunquaHMBox, $GUI_ENABLE)
            Else
                GUICtrlSetState($SunquaHMBox, $GUI_DISABLE)
            EndIf

        ; Elonian Group
        Case $DejarinEstateBox
            If GUICtrlRead($DejarinEstateBox) = $GUI_Checked Then
                GUICtrlSetState($DejarinHMBox, $GUI_ENABLE)
            Else
                GUICtrlSetState($DejarinHMBox, $GUI_DISABLE)
            EndIf
        Case $DomainOfFearBox
            If GUICtrlRead($DomainOfFearBox) = $GUI_Checked Then
                GUICtrlSetState($DomainHMBox, $GUI_ENABLE)
            Else
                GUICtrlSetState($DomainHMBox, $GUI_DISABLE)
            EndIf
        Case $DrakesOnAPlainBox
            If GUICtrlRead($DrakesOnAPlainBox) = $GUI_Checked Then
                GUICtrlSetState($DrakesHMBox, $GUI_ENABLE)
            Else
                GUICtrlSetState($DrakesHMBox, $GUI_DISABLE)
            EndIf
        Case $GandaraTheMoonFortressBox
            If GUICtrlRead($GandaraTheMoonFortressBox) = $GUI_Checked Then
                GUICtrlSetState($GandaraHMBox, $GUI_ENABLE)
            Else
                GUICtrlSetState($GandaraHMBox, $GUI_DISABLE)
            EndIf
        Case $TuraisDesolationShortBox
            If GUICtrlRead($TuraisDesolationShortBox) = $GUI_Checked Then
                GUICtrlSetState($TuraisDesoSHMBox, $GUI_ENABLE)
            Else
                GUICtrlSetState($TuraisDesoSHMBox, $GUI_DISABLE)
            EndIf
        Case $TuraisDesolationLongBox
            If GUICtrlRead($TuraisDesolationLongBox) = $GUI_Checked Then
                GUICtrlSetState($TuraisDesoLHMBox, $GUI_ENABLE)
            Else
                GUICtrlSetState($TuraisDesoLHMBox, $GUI_DISABLE)
            EndIf
        Case $TuraisVentaBox
            If GUICtrlRead($TuraisVentaBox) = $GUI_Checked Then
                GUICtrlSetState($TuraisVentaHMBox, $GUI_ENABLE)
            Else
                GUICtrlSetState($TuraisVentaHMBox, $GUI_DISABLE)
            EndIf
        
        Case $GUI_EVENT_CLOSE
            If Not $Rendering Then Ui_ToggleRendering()
            Exit
    EndSwitch
EndFunc

Func UpdateStatistics()
    ; Update the Statistics on the first Page of the Gui
    GUICtrlSetData($RunsLabel, "Runs: " & $RunCount)
    GUICtrlSetData($SuccessLabel, "Success: " & $SuccessCount)
    GUICtrlSetData($FailsLabel, "Fails: " & $FailCount)

    GUICtrlSetData($LockpickLabel, "Lockpicks: " & $LockpicksLeft)
    GUICtrlSetData($LockpickKeptLabel, "Lockpicks kept: " & $LockpicksKept)
    GUICtrlSetData($LockpickBrokenLabel, "Lockpicks broken: " & $LockpicksBroken)

    GUICtrlSetData($ChestTitleLabel, "Chest Title: " & $ChestTitle)
    GUICtrlSetData($LuckyTitleLabel, "Lucky Title: " & $LuckyTitle)
    GUICtrlSetData($UnluckyTitleLabel, "Unlucky Title: " & $UnluckyTitle)

    GUICtrlSetData($ChestsLabel, "Chests opened: " & $Chestsopened)
    GUICtrlSetData($LuckyGainedLabel, "Points gained: " & $LuckypointsGained)
    GUICtrlSetData($UnluckyGainedLabel, "Points gained: " & $UnluckypointsGained)

    GUICtrlSetData($TomesLabel, "Tomes: " & $TomesPicked)
    GUICtrlSetData($GoldItemsLabel, "Gold Items: " & $GoldItemsPicked)
    GUICtrlSetData($PurpleItemsLabel, "Purple Items: " & $PurpleItemsPicked)
    
    GUICtrlSetData($Q8MaxGoldLabel, "max. Req8: " & $maxQ8GoldGained)
    GUICtrlSetData($Q8MaxPurpleLabel, "max. Req8: " & $maxQ8PurpleGained)         
EndFunc
