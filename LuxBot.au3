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


; Range constants for different attack ranges

; Map IDs
Global Const $MAP_ID_FORT_ASPENWOOD_LUXON = 389
Global Const $MAP_ID_CAVALON = 193 ; Cavalon (Luxon capital)

; Difficulty constants
Global Const $DIFFICULTY_NORMAL = 0
Global Const $DIFFICULTY_HARD = 1

; Faction constants
Global Const $DonatePoints = True  ; Set to True to donate faction, False to buy Jade Shards

Global Const $doLoadLoggedChars = True
Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)

GUIRegisterMsg(0x501, "OnPacket")

Opt("ExpandVarStrings", 1)

#Region Declarations
Global $charName  = ""
Global $ProcessID = ""
Global $timer = TimerInit()

Global $BotRunning = False
Global $BotInitialized = False
Global Const $BotTitle = "Tester"

; Custom variables for farming
Global $Deadlocked = False
Global $LastSkillUpdate = TimerInit()
Global $SkillUpdateInterval = 5000 ; Update skills every 5 seconds
Global $LastHealth = 100 ; Track last health to detect death
Global $WasDead = False ; Track if player was dead
Global $CurrentVanquishIndex = 0 ; Track current position in vanquish loop
Global $VanquishInProgress = False ; Track if vanquish is currently running
Global $LastVanquishComplete = TimerInit() ; Track when last vanquish completed

; Custom fighting system variables
Global $CustomFightingOrder
Dim $CustomFightingOrder[20] ; Array to store custom fighting order (skill slot numbers)
Global $CustomFightingCount = 0 ; Number of skills in custom order
Global $CustomFightingEnabled = False ; Whether custom fighting is enabled
Global $CurrentCustomSkillIndex = 0 ; Current position in custom fighting order

; Global array to store skill names mapped to IDs
Global $SkillNameArray[10000] ; Large enough to hold all skill IDs

Global $CameFromTown = False
#EndRegion Declaration

#Region ### START Koda GUI section ### Form=
$MainGui = GUICreate($BotTitle, 800, 600, -1, -1, -1, BitOR($WS_EX_TOPMOST,$WS_EX_WINDOWEDGE))
GUISetBkColor(0xEAEAEA, $MainGui)

; Create tab control
$TabControl = GUICtrlCreateTab(8, 8, 784, 584)

; Tab 1: Character Selection
GUICtrlCreateTabItem("Character")
$Group1 = GUICtrlCreateGroup("Select Your Character", 16, 40, 760, 120)
Global $GUINameCombo
If $doLoadLoggedChars Then
    $GUINameCombo = GUICtrlCreateCombo($charName, 32, 64, 200, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
    GUICtrlSetData(-1, GetLoggedCharNames())
Else
    $GUINameCombo = GUICtrlCreateInput("Character name", 32, 64, 200, 25)
EndIf
$GUIRefreshButton = GUICtrlCreateButton("Refresh", 240, 66, 51, 17)
GUICtrlSetOnEvent($GUIRefreshButton, "GuiButtonHandler")
$GUIStartButton = GUICtrlCreateButton("Start", 32, 104, 75, 25)
GUICtrlSetOnEvent($GUIStartButton, "GuiButtonHandler")
$GUIDonateFactionButton = GUICtrlCreateButton("DONATE FACTION", 120, 104, 120, 25)
GUICtrlSetOnEvent($GUIDonateFactionButton, "GuiButtonHandler")
GUICtrlSetBkColor($GUIDonateFactionButton, 0xFF0000) ; Red background
GUICtrlSetColor($GUIDonateFactionButton, 0xFFFFFF) ; White text
$gOnTopCheckbox = GUICtrlCreateCheckbox("On Top", 250, 103, 81, 24)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlCreateGroup("", -99, -99, 1, 1)

; Tab 2: Skillbar and Combat
GUICtrlCreateTabItem("Combat")
$Group2 = GUICtrlCreateGroup("Skillbar & Combat Settings", 16, 40, 760, 520)

; Skill slots section
$SkillGroup = GUICtrlCreateGroup("Skill Slots", 32, 64, 720, 160)
; Create labels for each skill slot
Global $SkillLabels[8]
Global $SkillCheckboxes[8]
Global $SkillPriorityCheckboxes[8]
For $i = 0 To 7
    ; Skill icon (larger)
    $SkillLabels[$i] = GUICtrlCreateLabel("Slot " & ($i + 1), 48 + ($i * 85), 108, 60, 60, $SS_CENTER)
    GUICtrlSetBkColor($SkillLabels[$i], 0xCCCCCC)
    GUICtrlSetColor($SkillLabels[$i], 0x000000)
    
    ; Use checkbox (larger, positioned above skill icon)
    $SkillCheckboxes[$i] = GUICtrlCreateCheckbox("Use", 48 + ($i * 85), 88, 60, 20)
    GUICtrlSetState($SkillCheckboxes[$i], $GUI_CHECKED) ; Default to checked
    
    ; Priority checkbox (larger, positioned below skill icon)
    $SkillPriorityCheckboxes[$i] = GUICtrlCreateCheckbox("Priority", 48 + ($i * 85), 173, 60, 20)
    GUICtrlSetFont($SkillPriorityCheckboxes[$i], 8, 400, 0, "Arial")
    GUICtrlSetColor($SkillPriorityCheckboxes[$i], 0xFF0000) ; Red text for priority
Next
; Skill names below priority checkboxes
Global $SkillNames[8]
For $i = 0 To 7
    $SkillNames[$i] = GUICtrlCreateLabel("", 48 + ($i * 85), 198, 60, 40, $SS_CENTER)
    GUICtrlSetFont($SkillNames[$i], 7, 400, 0, "Arial")
    GUICtrlSetColor($SkillNames[$i], 0x000000)
Next
GUICtrlCreateGroup("", -99, -99, 1, 1)

; Skill controls section
$SkillControlsGroup = GUICtrlCreateGroup("Skill Controls", 32, 240, 350, 120)
$GUIUpdateSkillsButton = GUICtrlCreateButton("Update Skills", 48, 264, 80, 25)
GUICtrlSetOnEvent($GUIUpdateSkillsButton, "GuiButtonHandler")
$GUIAutoUpdateCheckbox = GUICtrlCreateCheckbox("Auto Update", 140, 266, 80, 20)
GUICtrlSetState(-1, $GUI_CHECKED)
$GUIUseAllSkillsButton = GUICtrlCreateButton("Use All", 48, 294, 60, 20)
GUICtrlSetOnEvent($GUIUseAllSkillsButton, "GuiButtonHandler")
$GUIUseNoneSkillsButton = GUICtrlCreateButton("Use None", 112, 294, 60, 20)
GUICtrlSetOnEvent($GUIUseNoneSkillsButton, "GuiButtonHandler")
$GUITestSkillsButton = GUICtrlCreateButton("Test Skills", 176, 294, 60, 20)
GUICtrlSetOnEvent($GUITestSkillsButton, "GuiButtonHandler")
GUICtrlCreateGroup("", -99, -99, 1, 1)

; Custom Fighting Order Section
$CustomFightingGroup = GUICtrlCreateGroup("Custom Fighting Order", 400, 240, 350, 320)
$GUICustomFightingCheckbox = GUICtrlCreateCheckbox("Enable Custom Fighting Order", 416, 264, 200, 20)
GUICtrlSetOnEvent($GUICustomFightingCheckbox, "GuiButtonHandler")

; Custom fighting order list (up to 20 skills)
$GUICustomFightingList = GUICtrlCreateList("", 416, 288, 320, 180)
GUICtrlSetOnEvent($GUICustomFightingList, "GuiButtonHandler")

; Input field for skill slot number
GUICtrlCreateLabel("Skill Slot (1-8):", 416, 476, 80, 20)
$GUISkillSlotInput = GUICtrlCreateInput("1", 500, 474, 40, 20)
GUICtrlSetLimit($GUISkillSlotInput, 1) ; Limit to 1 character

; Buttons for custom fighting order
$GUIAddToCustomButton = GUICtrlCreateButton("Add Skill", 416, 496, 60, 20)
GUICtrlSetOnEvent($GUIAddToCustomButton, "GuiButtonHandler")
$GUIRemoveFromCustomButton = GUICtrlCreateButton("Remove", 480, 496, 60, 20)
GUICtrlSetOnEvent($GUIRemoveFromCustomButton, "GuiButtonHandler")
$GUIClearCustomButton = GUICtrlCreateButton("Clear All", 544, 496, 60, 20)
GUICtrlSetOnEvent($GUIClearCustomButton, "GuiButtonHandler")
GUICtrlCreateGroup("", -99, -99, 1, 1)

GUICtrlCreateGroup("", -99, -99, 1, 1)

; Tab 3: Actions Log
GUICtrlCreateTabItem("Log")
$Group3 = GUICtrlCreateGroup("Actions Log", 16, 40, 760, 520)
$GUIActionsEditExtended = GUICtrlCreateEdit("", 32, 64, 728, 480)
GUICtrlSetData(-1, "")
GUICtrlSetColor(-1, 0x99B2FF)
GUICtrlSetBkColor(-1, 0x23272A)
GUICtrlCreateGroup("", -99, -99, 1, 1)

; Tab 4: Run Options & Loot
GUICtrlCreateTabItem("Settings")
$Group4 = GUICtrlCreateGroup("Run Options", 16, 40, 380, 120)

; Hard Mode toggle
$GUIHardModeCheckbox = GUICtrlCreateCheckbox("Hard Mode (HM)", 32, 64, 150, 20)
GUICtrlSetState($GUIHardModeCheckbox, $GUI_CHECKED) ; Default to enabled
GUICtrlSetOnEvent($GUIHardModeCheckbox, "GuiButtonHandler")

; Additional run options can be added here
$GUIAutoSellCheckbox = GUICtrlCreateCheckbox("Auto Sell Items", 32, 88, 150, 20)
GUICtrlSetState($GUIAutoSellCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIAutoSellCheckbox, "GuiButtonHandler")

$GUIAutoSalvageCheckbox = GUICtrlCreateCheckbox("Auto Salvage Materials", 32, 112, 180, 20)
GUICtrlSetState($GUIAutoSalvageCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIAutoSalvageCheckbox, "GuiButtonHandler")

$GUIAutoStoreCheckbox = GUICtrlCreateCheckbox("Auto Store Rares", 200, 64, 150, 20)
GUICtrlSetState($GUIAutoStoreCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIAutoStoreCheckbox, "GuiButtonHandler")

$GUIAutoDropCheckbox = GUICtrlCreateCheckbox("Auto Drop Whites", 200, 88, 150, 20)
GUICtrlSetState($GUIAutoDropCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIAutoDropCheckbox, "GuiButtonHandler")

GUICtrlCreateGroup("", -99, -99, 1, 1)

; Loot Options Group
$Group5 = GUICtrlCreateGroup("Loot Filter Options", 16, 180, 760, 380)

; Rarity filters
$LootRarityGroup = GUICtrlCreateGroup("Item Rarity", 32, 204, 350, 120)
$GUIPickupGoldCheckbox = GUICtrlCreateCheckbox("Gold Items (Legendary)", 48, 228, 150, 20)
GUICtrlSetState($GUIPickupGoldCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupGoldCheckbox, "GuiButtonHandler")

$GUIPickupPurpleCheckbox = GUICtrlCreateCheckbox("Purple Items (Unique)", 48, 252, 150, 20)
GUICtrlSetState($GUIPickupPurpleCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupPurpleCheckbox, "GuiButtonHandler")

$GUIPickupBlueCheckbox = GUICtrlCreateCheckbox("Blue Items (Rare)", 48, 276, 150, 20)
GUICtrlSetState($GUIPickupBlueCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupBlueCheckbox, "GuiButtonHandler")

$GUIPickupGreenCheckbox = GUICtrlCreateCheckbox("Green Items (Uncommon)", 48, 300, 150, 20)
GUICtrlSetState($GUIPickupGreenCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupGreenCheckbox, "GuiButtonHandler")

$GUIPickupWhiteCheckbox = GUICtrlCreateCheckbox("White Items (Common)", 48, 324, 150, 20)
GUICtrlSetState($GUIPickupWhiteCheckbox, $GUI_UNCHECKED) ; Default to unchecked
GUICtrlSetOnEvent($GUIPickupWhiteCheckbox, "GuiButtonHandler")

$GUIPickupGrayCheckbox = GUICtrlCreateCheckbox("Gray Items (Junk)", 220, 228, 150, 20)
GUICtrlSetState($GUIPickupGrayCheckbox, $GUI_UNCHECKED) ; Default to unchecked
GUICtrlSetOnEvent($GUIPickupGrayCheckbox, "GuiButtonHandler")

GUICtrlCreateGroup("", -99, -99, 1, 1)

; Special item filters
$SpecialItemsGroup = GUICtrlCreateGroup("Special Items", 400, 204, 350, 120)
$GUIPickupMaterialsCheckbox = GUICtrlCreateCheckbox("Materials (Wood, Cloth, etc.)", 416, 228, 200, 20)
GUICtrlSetState($GUIPickupMaterialsCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupMaterialsCheckbox, "GuiButtonHandler")

$GUIPickupDyesCheckbox = GUICtrlCreateCheckbox("Dyes", 416, 252, 150, 20)
GUICtrlSetState($GUIPickupDyesCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupDyesCheckbox, "GuiButtonHandler")

$GUIPickupKeysCheckbox = GUICtrlCreateCheckbox("Keys", 416, 276, 150, 20)
GUICtrlSetState($GUIPickupKeysCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupKeysCheckbox, "GuiButtonHandler")

$GUIPickupScrollsCheckbox = GUICtrlCreateCheckbox("Scrolls", 416, 300, 150, 20)
GUICtrlSetState($GUIPickupScrollsCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupScrollsCheckbox, "GuiButtonHandler")

$GUIPickupConsumablesCheckbox = GUICtrlCreateCheckbox("Consumables", 416, 324, 150, 20)
GUICtrlSetState($GUIPickupConsumablesCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupConsumablesCheckbox, "GuiButtonHandler")

GUICtrlCreateGroup("", -99, -99, 1, 1)

; Weapon type filters
$WeaponTypeGroup = GUICtrlCreateGroup("Weapon Types", 32, 340, 350, 120)
$GUIPickupSwordsCheckbox = GUICtrlCreateCheckbox("Swords", 48, 364, 100, 20)
GUICtrlSetState($GUIPickupSwordsCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupSwordsCheckbox, "GuiButtonHandler")

$GUIPickupAxesCheckbox = GUICtrlCreateCheckbox("Axes", 48, 388, 100, 20)
GUICtrlSetState($GUIPickupAxesCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupAxesCheckbox, "GuiButtonHandler")

$GUIPickupHammersCheckbox = GUICtrlCreateCheckbox("Hammers", 48, 412, 100, 20)
GUICtrlSetState($GUIPickupHammersCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupHammersCheckbox, "GuiButtonHandler")

$GUIPickupDaggersCheckbox = GUICtrlCreateCheckbox("Daggers", 48, 436, 100, 20)
GUICtrlSetState($GUIPickupDaggersCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupDaggersCheckbox, "GuiButtonHandler")

$GUIPickupScythesCheckbox = GUICtrlCreateCheckbox("Scythes", 48, 460, 100, 20)
GUICtrlSetState($GUIPickupScythesCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupScythesCheckbox, "GuiButtonHandler")

$GUIPickupBowsCheckbox = GUICtrlCreateCheckbox("Bows", 160, 364, 100, 20)
GUICtrlSetState($GUIPickupBowsCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupBowsCheckbox, "GuiButtonHandler")

$GUIPickupWandsCheckbox = GUICtrlCreateCheckbox("Wands", 160, 388, 100, 20)
GUICtrlSetState($GUIPickupWandsCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupWandsCheckbox, "GuiButtonHandler")

$GUIPickupStavesCheckbox = GUICtrlCreateCheckbox("Staves", 160, 412, 100, 20)
GUICtrlSetState($GUIPickupStavesCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupStavesCheckbox, "GuiButtonHandler")

$GUIPickupShieldsCheckbox = GUICtrlCreateCheckbox("Shields", 160, 436, 100, 20)
GUICtrlSetState($GUIPickupShieldsCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupShieldsCheckbox, "GuiButtonHandler")

$GUIPickupFocusItemsCheckbox = GUICtrlCreateCheckbox("Focus Items", 160, 460, 100, 20)
GUICtrlSetState($GUIPickupFocusItemsCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupFocusItemsCheckbox, "GuiButtonHandler")

$GUIPickupArmorCheckbox = GUICtrlCreateCheckbox("Armor", 272, 364, 100, 20)
GUICtrlSetState($GUIPickupArmorCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupArmorCheckbox, "GuiButtonHandler")

$GUIPickupRunesCheckbox = GUICtrlCreateCheckbox("Runes", 272, 388, 100, 20)
GUICtrlSetState($GUIPickupRunesCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupRunesCheckbox, "GuiButtonHandler")

$GUIPickupInsigniasCheckbox = GUICtrlCreateCheckbox("Insignias", 272, 412, 100, 20)
GUICtrlSetState($GUIPickupInsigniasCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupInsigniasCheckbox, "GuiButtonHandler")

GUICtrlCreateGroup("", -99, -99, 1, 1)

; Quick selection buttons
$QuickSelectionGroup = GUICtrlCreateGroup("Quick Selection", 400, 340, 350, 120)
$GUIAllLootButton = GUICtrlCreateButton("Select All Loot", 416, 364, 100, 25)
GUICtrlSetOnEvent($GUIAllLootButton, "GuiButtonHandler")

$GUINoLootButton = GUICtrlCreateButton("Deselect All Loot", 416, 394, 100, 25)
GUICtrlSetOnEvent($GUINoLootButton, "GuiButtonHandler")

$GUIRareOnlyButton = GUICtrlCreateButton("Rare+ Only", 416, 424, 100, 25)
GUICtrlSetOnEvent($GUIRareOnlyButton, "GuiButtonHandler")

$GUIWeaponsOnlyButton = GUICtrlCreateButton("Weapons Only", 530, 364, 100, 25)
GUICtrlSetOnEvent($GUIWeaponsOnlyButton, "GuiButtonHandler")

$GUIMaterialsOnlyButton = GUICtrlCreateButton("Materials Only", 530, 394, 100, 25)
GUICtrlSetOnEvent($GUIMaterialsOnlyButton, "GuiButtonHandler")

$GUISpecialOnlyButton = GUICtrlCreateButton("Special Only", 530, 424, 100, 25)
GUICtrlSetOnEvent($GUISpecialOnlyButton, "GuiButtonHandler")

GUICtrlCreateGroup("", -99, -99, 1, 1)

GUICtrlCreateGroup("", -99, -99, 1, 1)

; Tab 5: Salvage
GUICtrlCreateTabItem("Salvage")
$GroupSalvage = GUICtrlCreateGroup("Salvage Items", 16, 40, 760, 520)

; Salvage Item Rarity
$SalvageRarityGroup = GUICtrlCreateGroup("Item Rarity", 32, 64, 350, 120)
$GUISalvageGoldCheckbox = GUICtrlCreateCheckbox("Gold Items (Legendary)", 48, 88, 150, 20)
$GUISalvagePurpleCheckbox = GUICtrlCreateCheckbox("Purple Items (Unique)", 48, 112, 150, 20)
$GUISalvageBlueCheckbox = GUICtrlCreateCheckbox("Blue Items (Rare)", 48, 136, 150, 20)
$GUISalvageGreenCheckbox = GUICtrlCreateCheckbox("Green Items (Uncommon)", 48, 160, 150, 20)
$GUISalvageWhiteCheckbox = GUICtrlCreateCheckbox("White Items (Common)", 220, 88, 150, 20)
$GUISalvageGrayCheckbox = GUICtrlCreateCheckbox("Gray Items (Junk)", 220, 112, 150, 20)
GUICtrlCreateGroup("", -99, -99, 1, 1)

; Salvage Weapon Types (excluding Runes and Insignias)
$SalvageWeaponTypeGroup = GUICtrlCreateGroup("Weapon Types", 32, 200, 350, 180)
$GUISalvageSwordsCheckbox = GUICtrlCreateCheckbox("Swords", 48, 224, 100, 20)
$GUISalvageAxesCheckbox = GUICtrlCreateCheckbox("Axes", 48, 248, 100, 20)
$GUISalvageHammersCheckbox = GUICtrlCreateCheckbox("Hammers", 48, 272, 100, 20)
$GUISalvageDaggersCheckbox = GUICtrlCreateCheckbox("Daggers", 48, 296, 100, 20)
$GUISalvageScythesCheckbox = GUICtrlCreateCheckbox("Scythes", 48, 320, 100, 20)
$GUISalvageBowsCheckbox = GUICtrlCreateCheckbox("Bows", 160, 224, 100, 20)
$GUISalvageWandsCheckbox = GUICtrlCreateCheckbox("Wands", 160, 248, 100, 20)
$GUISalvageStavesCheckbox = GUICtrlCreateCheckbox("Staves", 160, 272, 100, 20)
$GUISalvageShieldsCheckbox = GUICtrlCreateCheckbox("Shields", 160, 296, 100, 20)
$GUISalvageFocusItemsCheckbox = GUICtrlCreateCheckbox("Focus Items", 160, 320, 100, 20)
$GUISalvageArmorCheckbox = GUICtrlCreateCheckbox("Armor", 272, 224, 100, 20)
GUICtrlCreateGroup("", -99, -99, 1, 1)

GUICtrlCreateGroup("", -99, -99, 1, 1)

; Tab 6: Sell
GUICtrlCreateTabItem("Sell")
$GroupSell = GUICtrlCreateGroup("Sell Items", 16, 40, 760, 520)

; Sell Item Rarity
$SellRarityGroup = GUICtrlCreateGroup("Item Rarity", 32, 64, 350, 120)
$GUISellGoldCheckbox = GUICtrlCreateCheckbox("Gold Items (Legendary)", 48, 88, 150, 20)
$GUISellPurpleCheckbox = GUICtrlCreateCheckbox("Purple Items (Unique)", 48, 112, 150, 20)
$GUISellBlueCheckbox = GUICtrlCreateCheckbox("Blue Items (Rare)", 48, 136, 150, 20)
$GUISellGreenCheckbox = GUICtrlCreateCheckbox("Green Items (Uncommon)", 48, 160, 150, 20)
$GUISellWhiteCheckbox = GUICtrlCreateCheckbox("White Items (Common)", 220, 88, 150, 20)
$GUISellGrayCheckbox = GUICtrlCreateCheckbox("Gray Items (Junk)", 220, 112, 150, 20)
GUICtrlCreateGroup("", -99, -99, 1, 1)

; Sell Weapon Types
$SellWeaponTypeGroup = GUICtrlCreateGroup("Weapon Types", 32, 200, 350, 180)
$GUISellSwordsCheckbox = GUICtrlCreateCheckbox("Swords", 48, 224, 100, 20)
$GUISellAxesCheckbox = GUICtrlCreateCheckbox("Axes", 48, 248, 100, 20)
$GUISellHammersCheckbox = GUICtrlCreateCheckbox("Hammers", 48, 272, 100, 20)
$GUISellDaggersCheckbox = GUICtrlCreateCheckbox("Daggers", 48, 296, 100, 20)
$GUISellScythesCheckbox = GUICtrlCreateCheckbox("Scythes", 48, 320, 100, 20)
$GUISellBowsCheckbox = GUICtrlCreateCheckbox("Bows", 160, 224, 100, 20)
$GUISellWandsCheckbox = GUICtrlCreateCheckbox("Wands", 160, 248, 100, 20)
$GUISellStavesCheckbox = GUICtrlCreateCheckbox("Staves", 160, 272, 100, 20)
$GUISellShieldsCheckbox = GUICtrlCreateCheckbox("Shields", 160, 296, 100, 20)
$GUISellFocusItemsCheckbox = GUICtrlCreateCheckbox("Focus Items", 160, 320, 100, 20)
$GUISellArmorCheckbox = GUICtrlCreateCheckbox("Armor", 272, 224, 100, 20)
$GUISellRunesCheckbox = GUICtrlCreateCheckbox("Runes", 272, 248, 100, 20)
$GUISellInsigniasCheckbox = GUICtrlCreateCheckbox("Insignias", 272, 272, 100, 20)
GUICtrlCreateGroup("", -99, -99, 1, 1)

; Sell Special Items
$SellSpecialItemsGroup = GUICtrlCreateGroup("Special Items", 400, 64, 320, 180)
$GUISellMaterialsCheckbox = GUICtrlCreateCheckbox("Materials (Wood, Cloth, etc.)", 416, 88, 200, 20)
$GUISellDyesCheckbox = GUICtrlCreateCheckbox("Dyes", 416, 112, 150, 20)
$GUISellKeysCheckbox = GUICtrlCreateCheckbox("Keys", 416, 136, 150, 20)
$GUISellScrollsCheckbox = GUICtrlCreateCheckbox("Scrolls", 416, 160, 150, 20)
$GUISellConsumablesCheckbox = GUICtrlCreateCheckbox("Consumables", 416, 184, 150, 20)
GUICtrlCreateGroup("", -99, -99, 1, 1)

GUICtrlCreateGroup("", -99, -99, 1, 1)

GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")
GUISetState(@SW_SHOW)

; Initialize skill names with placeholders
InitializeSkillNames()

#EndRegion ### END Koda GUI section ###

Func GuiButtonHandler()
    Switch @GUI_CtrlId
        Case $GUIStartButton
            Out("Initializing")
            Local $charName = GUICtrlRead($GUINameCombo)
            If $charName=="" Then
                If Initialize(ProcessExists("gw.exe"), True, False, False) = 0 Then
                    MsgBox(0, "Error", "Guild Wars is not running.")
                    _Exit()
                EndIf
            ElseIf $ProcessID Then
                $proc_id_int = Number($ProcessID, 2)
                If Initialize($proc_id_int, True, False, False) = 0 Then
                    MsgBox(0, "Error", "Could not Find a ProcessID or somewhat '"&$proc_id_int&"'  "&VarGetType($proc_id_int)&"'")
                    _Exit()
                    If ProcessExists($proc_id_int) Then
                        ProcessClose($proc_id_int)
                    EndIf
                    Exit
                EndIf
            Else
                If Initialize($CharName, True, False, False) = 0 Then
                    MsgBox(0, "Error", "Could not Find a Guild Wars client with a Character named '"&$CharName&"'")
                    _Exit()
                EndIf
            EndIf
            GUICtrlSetState($GUIStartButton, $GUI_Disable)
			GUICtrlSetState($GUIRefreshButton, $GUI_Disable)
            GUICtrlSetState($GUINameCombo, $GUI_Disable)
            WinSetTitle($MainGui, "", GetCharname() & " - Bot for test")
            $BotRunning = True
            $BotInitialized = True
            
            ; Update skillbar display after initialization
            UpdateSkillbarDisplay()

        Case $GUIDonateFactionButton
            Out("Manual faction donation requested")
            ; Initialize bot if not already initialized
            If Not $BotInitialized Then
                Out("Initializing bot for faction donation...")
                Local $charName = GUICtrlRead($GUINameCombo)
                If $charName=="" Then
                    If Initialize(ProcessExists("gw.exe"), True, False, False) = 0 Then
                        MsgBox(0, "Error", "Guild Wars is not running.")
                        Return
                    EndIf
                ElseIf $ProcessID Then
                    $proc_id_int = Number($ProcessID, 2)
                    If Initialize($proc_id_int, True, False, False) = 0 Then
                        MsgBox(0, "Error", "Could not Find a ProcessID or somewhat '"&$proc_id_int&"'  "&VarGetType($proc_id_int)&"'")
                        Return
                    EndIf
                Else
                    If Initialize($CharName, True, False, False) = 0 Then
                        MsgBox(0, "Error", "Could not Find a Guild Wars client with a Character named '"&$CharName&"'")
                        Return
                    EndIf
                EndIf
                $BotInitialized = True
                Out("Bot initialized successfully for faction donation")
            EndIf
            DonateFactionManual()

        Case $GUIUpdateSkillsButton
            UpdateSkillbarDisplay()

        Case $GUIUseAllSkillsButton
            ; Check all skill checkboxes
            For $i = 0 To 7
                GUICtrlSetState($SkillCheckboxes[$i], $GUI_CHECKED)
            Next
            Out("All skills enabled for combat")

        Case $GUIUseNoneSkillsButton
            ; Uncheck all skill checkboxes
            For $i = 0 To 7
                GUICtrlSetState($SkillCheckboxes[$i], $GUI_UNCHECKED)
            Next
            Out("All skills disabled for combat")

        Case $GUITestSkillsButton
            ; Test skill usage manually
            If Not $BotInitialized Then
                Out("Please initialize the bot first to test skills")
                Return
            EndIf
            
            Out("Testing skill usage...")
            For $i = 1 To 8
                Local $skillEnabled = GUICtrlRead($SkillCheckboxes[$i-1]) = $GUI_CHECKED
                Local $skillPriority = GUICtrlRead($SkillPriorityCheckboxes[$i-1]) = $GUI_CHECKED
                Local $skillID = GetSkillbarSkillID($i)
                Out("Skill " & $i & ": ID=" & $skillID & ", Enabled=" & $skillEnabled & ", Priority=" & $skillPriority & ", Recharged=" & IsRecharged($i) & ", Energy=" & GetEnergy(-2) & "/" & GetEnergyReq($skillID))
            Next

        Case $GUICustomFightingCheckbox
            $CustomFightingEnabled = (GUICtrlRead($GUICustomFightingCheckbox) = $GUI_CHECKED)
            If $CustomFightingEnabled Then
                Out("Custom fighting order enabled")
            Else
                Out("Custom fighting order disabled")
            EndIf

        Case $GUIAddToCustomButton
            ; Add selected skill to custom fighting order
            If $CustomFightingCount < 20 Then
                ; Read skill slot from input field
                Local $skillSlot = GUICtrlRead($GUISkillSlotInput)
                ; Convert to number and validate
                Local $skillSlotNum = Number($skillSlot)
                Out("Input received: '" & $skillSlot & "' converted to: " & $skillSlotNum)
                
                If $skillSlotNum >= 1 And $skillSlotNum <= 8 Then
                    $CustomFightingOrder[$CustomFightingCount] = $skillSlotNum
                    $CustomFightingCount += 1
                    UpdateCustomFightingList()
                    Out("Added skill slot " & $skillSlotNum & " to custom fighting order")
                    ; Clear the input field after successful addition
                    GUICtrlSetData($GUISkillSlotInput, "1")
                Else
                    Out("Invalid skill slot number. Please enter 1-8. (Received: " & $skillSlotNum & ")")
                EndIf
            Else
                Out("Custom fighting order is full (max 20 skills)")
            EndIf

        Case $GUIRemoveFromCustomButton
            ; Remove selected skill from custom fighting order
            Local $selectedIndex = _GUICtrlListBox_GetCurSel($GUICustomFightingList)
            If $selectedIndex >= 0 And $selectedIndex < $CustomFightingCount Then
                ; Remove the skill at selected index
                For $i = $selectedIndex To $CustomFightingCount - 2
                    $CustomFightingOrder[$i] = $CustomFightingOrder[$i + 1]
                Next
                $CustomFightingCount -= 1
                UpdateCustomFightingList()
                Out("Removed skill from custom fighting order")
            Else
                Out("Please select a skill to remove")
            EndIf

        Case $GUIClearCustomButton
            ; Clear all skills from custom fighting order
            $CustomFightingCount = 0
            UpdateCustomFightingList()
            Out("Cleared custom fighting order")

        Case $GUIRefreshButton
            GUICtrlSetData($GUINameCombo, "")
            GUICtrlSetData($GUINameCombo, GetLoggedCharNames())

        Case $gOnTopCheckbox
            If GUICtrlRead($gOnTopCheckbox) = $GUI_CHECKED Then
                WinSetOnTop($BotTitle, "", 1)
            Else
                WinSetOnTop($BotTitle, "", 0)
            EndIf

        Case $GUI_EVENT_CLOSE
            Exit

        ; Run Options Handlers
        Case $GUIHardModeCheckbox
            If GUICtrlRead($GUIHardModeCheckbox) = $GUI_CHECKED Then
                Out("Hard Mode enabled")
                ; Add HM toggle logic here
            Else
                Out("Hard Mode disabled")
                ; Add HM toggle logic here
            EndIf

        Case $GUIAutoSellCheckbox
            If GUICtrlRead($GUIAutoSellCheckbox) = $GUI_CHECKED Then
                Out("Auto Sell enabled")
            Else
                Out("Auto Sell disabled")
            EndIf

        Case $GUIAutoSalvageCheckbox
            If GUICtrlRead($GUIAutoSalvageCheckbox) = $GUI_CHECKED Then
                Out("Auto Salvage enabled")
            Else
                Out("Auto Salvage disabled")
            EndIf

        Case $GUIAutoStoreCheckbox
            If GUICtrlRead($GUIAutoStoreCheckbox) = $GUI_CHECKED Then
                Out("Auto Store Rares enabled")
            Else
                Out("Auto Store Rares disabled")
            EndIf

        Case $GUIAutoDropCheckbox
            If GUICtrlRead($GUIAutoDropCheckbox) = $GUI_CHECKED Then
                Out("Auto Drop Whites enabled")
            Else
                Out("Auto Drop Whites disabled")
            EndIf

        ; Loot Filter Handlers
        Case $GUIPickupGoldCheckbox
            If GUICtrlRead($GUIPickupGoldCheckbox) = $GUI_CHECKED Then
                Out("Gold items pickup enabled")
            Else
                Out("Gold items pickup disabled")
            EndIf

        Case $GUIPickupPurpleCheckbox
            If GUICtrlRead($GUIPickupPurpleCheckbox) = $GUI_CHECKED Then
                Out("Purple items pickup enabled")
            Else
                Out("Purple items pickup disabled")
            EndIf

        Case $GUIPickupBlueCheckbox
            If GUICtrlRead($GUIPickupBlueCheckbox) = $GUI_CHECKED Then
                Out("Blue items pickup enabled")
            Else
                Out("Blue items pickup disabled")
            EndIf

        Case $GUIPickupGreenCheckbox
            If GUICtrlRead($GUIPickupGreenCheckbox) = $GUI_CHECKED Then
                Out("Green items pickup enabled")
            Else
                Out("Green items pickup disabled")
            EndIf

        Case $GUIPickupWhiteCheckbox
            If GUICtrlRead($GUIPickupWhiteCheckbox) = $GUI_CHECKED Then
                Out("White items pickup enabled")
            Else
                Out("White items pickup disabled")
            EndIf

        Case $GUIPickupGrayCheckbox
            If GUICtrlRead($GUIPickupGrayCheckbox) = $GUI_CHECKED Then
                Out("Gray items pickup enabled")
            Else
                Out("Gray items pickup disabled")
            EndIf

        ; Special Items Handlers
        Case $GUIPickupMaterialsCheckbox
            If GUICtrlRead($GUIPickupMaterialsCheckbox) = $GUI_CHECKED Then
                Out("Materials pickup enabled")
            Else
                Out("Materials pickup disabled")
            EndIf

        Case $GUIPickupDyesCheckbox
            If GUICtrlRead($GUIPickupDyesCheckbox) = $GUI_CHECKED Then
                Out("Dyes pickup enabled")
            Else
                Out("Dyes pickup disabled")
            EndIf

        Case $GUIPickupKeysCheckbox
            If GUICtrlRead($GUIPickupKeysCheckbox) = $GUI_CHECKED Then
                Out("Keys pickup enabled")
            Else
                Out("Keys pickup disabled")
            EndIf

        Case $GUIPickupScrollsCheckbox
            If GUICtrlRead($GUIPickupScrollsCheckbox) = $GUI_CHECKED Then
                Out("Scrolls pickup enabled")
            Else
                Out("Scrolls pickup disabled")
            EndIf

        Case $GUIPickupConsumablesCheckbox
            If GUICtrlRead($GUIPickupConsumablesCheckbox) = $GUI_CHECKED Then
                Out("Consumables pickup enabled")
            Else
                Out("Consumables pickup disabled")
            EndIf

        ; Weapon Type Handlers
        Case $GUIPickupSwordsCheckbox
            If GUICtrlRead($GUIPickupSwordsCheckbox) = $GUI_CHECKED Then
                Out("Swords pickup enabled")
            Else
                Out("Swords pickup disabled")
            EndIf

        Case $GUIPickupAxesCheckbox
            If GUICtrlRead($GUIPickupAxesCheckbox) = $GUI_CHECKED Then
                Out("Axes pickup enabled")
            Else
                Out("Axes pickup disabled")
            EndIf

        Case $GUIPickupHammersCheckbox
            If GUICtrlRead($GUIPickupHammersCheckbox) = $GUI_CHECKED Then
                Out("Hammers pickup enabled")
            Else
                Out("Hammers pickup disabled")
            EndIf

        Case $GUIPickupDaggersCheckbox
            If GUICtrlRead($GUIPickupDaggersCheckbox) = $GUI_CHECKED Then
                Out("Daggers pickup enabled")
            Else
                Out("Daggers pickup disabled")
            EndIf

        Case $GUIPickupScythesCheckbox
            If GUICtrlRead($GUIPickupScythesCheckbox) = $GUI_CHECKED Then
                Out("Scythes pickup enabled")
            Else
                Out("Scythes pickup disabled")
            EndIf

        Case $GUIPickupBowsCheckbox
            If GUICtrlRead($GUIPickupBowsCheckbox) = $GUI_CHECKED Then
                Out("Bows pickup enabled")
            Else
                Out("Bows pickup disabled")
            EndIf

        Case $GUIPickupWandsCheckbox
            If GUICtrlRead($GUIPickupWandsCheckbox) = $GUI_CHECKED Then
                Out("Wands pickup enabled")
            Else
                Out("Wands pickup disabled")
            EndIf

        Case $GUIPickupStavesCheckbox
            If GUICtrlRead($GUIPickupStavesCheckbox) = $GUI_CHECKED Then
                Out("Staves pickup enabled")
            Else
                Out("Staves pickup disabled")
            EndIf

        Case $GUIPickupShieldsCheckbox
            If GUICtrlRead($GUIPickupShieldsCheckbox) = $GUI_CHECKED Then
                Out("Shields pickup enabled")
            Else
                Out("Shields pickup disabled")
            EndIf

        Case $GUIPickupFocusItemsCheckbox
            If GUICtrlRead($GUIPickupFocusItemsCheckbox) = $GUI_CHECKED Then
                Out("Focus items pickup enabled")
            Else
                Out("Focus items pickup disabled")
            EndIf

        Case $GUIPickupArmorCheckbox
            If GUICtrlRead($GUIPickupArmorCheckbox) = $GUI_CHECKED Then
                Out("Armor pickup enabled")
            Else
                Out("Armor pickup disabled")
            EndIf

        Case $GUIPickupRunesCheckbox
            If GUICtrlRead($GUIPickupRunesCheckbox) = $GUI_CHECKED Then
                Out("Runes pickup enabled")
            Else
                Out("Runes pickup disabled")
            EndIf

        Case $GUIPickupInsigniasCheckbox
            If GUICtrlRead($GUIPickupInsigniasCheckbox) = $GUI_CHECKED Then
                Out("Insignias pickup enabled")
            Else
                Out("Insignias pickup disabled")
            EndIf

        ; Quick Selection Button Handlers
        Case $GUIAllLootButton
            ; Select all loot checkboxes
            GUICtrlSetState($GUIPickupGoldCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupPurpleCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupBlueCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupGreenCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupWhiteCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupGrayCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupMaterialsCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupDyesCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupKeysCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupScrollsCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupConsumablesCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupSwordsCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupAxesCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupHammersCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupDaggersCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupScythesCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupBowsCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupWandsCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupStavesCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupShieldsCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupFocusItemsCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupArmorCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupRunesCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupInsigniasCheckbox, $GUI_CHECKED)
            Out("All loot types selected")

        Case $GUINoLootButton
            ; Deselect all loot checkboxes
            GUICtrlSetState($GUIPickupGoldCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupPurpleCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupBlueCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupGreenCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupWhiteCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupGrayCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupMaterialsCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupDyesCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupKeysCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupScrollsCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupConsumablesCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupSwordsCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupAxesCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupHammersCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupDaggersCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupScythesCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupBowsCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupWandsCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupStavesCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupShieldsCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupFocusItemsCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupArmorCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupRunesCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupInsigniasCheckbox, $GUI_UNCHECKED)
            Out("All loot types deselected")

        Case $GUIRareOnlyButton
            ; Select only rare+ items
            GUICtrlSetState($GUIPickupGoldCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupPurpleCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupBlueCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupGreenCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupWhiteCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupGrayCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupMaterialsCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupDyesCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupKeysCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupScrollsCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupConsumablesCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupSwordsCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupAxesCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupHammersCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupDaggersCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupScythesCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupBowsCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupWandsCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupStavesCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupShieldsCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupFocusItemsCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupArmorCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupRunesCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupInsigniasCheckbox, $GUI_CHECKED)
            Out("Rare+ items and materials selected")

        Case $GUIWeaponsOnlyButton
            ; Select only weapon types
            GUICtrlSetState($GUIPickupGoldCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupPurpleCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupBlueCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupGreenCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupWhiteCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupGrayCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupMaterialsCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupDyesCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupKeysCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupScrollsCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupConsumablesCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupSwordsCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupAxesCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupHammersCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupDaggersCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupScythesCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupBowsCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupWandsCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupStavesCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupShieldsCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupFocusItemsCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupArmorCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupRunesCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupInsigniasCheckbox, $GUI_UNCHECKED)
            Out("Weapon types selected")

        Case $GUIMaterialsOnlyButton
            ; Select only materials and special items
            GUICtrlSetState($GUIPickupGoldCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupPurpleCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupBlueCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupGreenCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupWhiteCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupGrayCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupMaterialsCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupDyesCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupKeysCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupScrollsCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupConsumablesCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupSwordsCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupAxesCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupHammersCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupDaggersCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupScythesCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupBowsCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupWandsCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupStavesCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupShieldsCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupFocusItemsCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupArmorCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupRunesCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupInsigniasCheckbox, $GUI_UNCHECKED)
            Out("Materials and special items selected")

        Case $GUISpecialOnlyButton
            ; Select only special items (no weapons/armor)
            GUICtrlSetState($GUIPickupGoldCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupPurpleCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupBlueCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupGreenCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupWhiteCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupGrayCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupMaterialsCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupDyesCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupKeysCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupScrollsCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupConsumablesCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupSwordsCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupAxesCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupHammersCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupDaggersCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupScythesCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupBowsCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupWandsCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupStavesCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupShieldsCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupFocusItemsCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupArmorCheckbox, $GUI_UNCHECKED)
            GUICtrlSetState($GUIPickupRunesCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupInsigniasCheckbox, $GUI_CHECKED)
            Out("Special items only selected")

    EndSwitch
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
    ; Check if we're already in Mount Qinkai (map 200)
    If GetMapID() = 200 Then
        If $CameFromTown Then
            Out("Arrived in Mount Qinkai from town, starting vanquish from index 0!")
            $CameFromTown = False
            $VanquishInProgress = True
            $CurrentVanquishIndex = 0 ; Always start from 0 when from town
            VanquishMountQinkai()
            $VanquishInProgress = False
            $LastVanquishComplete = TimerInit()
            Return
        ElseIf Not $VanquishInProgress Then
            Out("Already in Mount Qinkai (map 200), starting vanquish!")
            $VanquishInProgress = True
            VanquishMountQinkai()
            $VanquishInProgress = False
            $LastVanquishComplete = TimerInit()
            Return
        Else
            Out("Vanquish already in progress, waiting...")
            Return
        EndIf
    EndIf
    
    ; Check if we recently completed a vanquish (prevent immediate restart)
    If TimerDiff($LastVanquishComplete) < 10000 Then ; Wait 10 seconds after vanquish completion
        Out("Recently completed vanquish, waiting before restart...")
        Return
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
    
    If $currentFaction < 3000 Then
        Out("Faction is below 3000, no donation needed")
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
    While GetLuxonFaction() >= 3000
        DonateFaction('Luxon')
        RndSleep(500)
        $donations += 1
        Out("Donation " & $donations & " completed. Current faction: " & GetLuxonFaction())
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
Func LuxonFarmSetup()
	; Inventory management loop during farming
	While (CountSlots() > 6)
		If Not $BotRunning Then
			Out("Bot Paused")
			GUICtrlSetState($GUIStartButton, $GUI_ENABLE)
			GUICtrlSetData($GUIStartButton, "Resume")
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
			GUICtrlSetState($GUIStartButton, $GUI_ENABLE)
			GUICtrlSetData($GUIStartButton, "Resume")
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

While $BotRunning
	Sleep(500)
	
	; Auto-update skillbar if enabled
	If GUICtrlRead($GUIAutoUpdateCheckbox) = $GUI_CHECKED And TimerDiff($LastSkillUpdate) > $SkillUpdateInterval Then
		UpdateSkillbarDisplay()
		$LastSkillUpdate = TimerInit()
	EndIf
	
	EnsureInFortAspenwoodLuxon()
	Sleep(5000)
WEnd

Func Out($TEXT)
    Local $TIME = "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] - "
    Local $TEXTLEN = StringLen($TEXT)
    Local $CONSOLELEN = _GUICtrlEdit_GetTextLen($GUIActionsEditExtended)
    If $TEXTLEN + $CONSOLELEN > 30000 Then GUICtrlSetData($GUIActionsEditExtended, StringRight(_GUICtrlEdit_GetText($GUIActionsEditExtended), 30000 - $TEXTLEN - 1000))
    _GUICtrlEdit_AppendText($GUIActionsEditExtended, @CRLF & $TIME & $TEXT)
    _GUICtrlEdit_Scroll($GUIActionsEditExtended, 1)
EndFunc

Func _Exit()
    Exit
EndFunc

; Function to get a random game joke
Func GetRandomGameJoke()
    Local $jokes[] = [ _
        "Why did the gamer go broke? Because he was spending too much time on his console! 😄", _
        "What do you call a gamer who's always late? A lag-ger! 🎮", _
        "Why don't skeletons fight each other? They don't have the guts! 💀", _
        "What's a gamer's favorite type of music? Heavy metal! 🤘", _
        "Why did the programmer quit his job? Because he didn't get arrays! 😂", _
        "What do you call a bear with no teeth? A gummy bear! 🐻", _
        "Why did the scarecrow win an award? Because he was outstanding in his field! 🌾", _
        "What do you call a fake noodle? An impasta! 🍝", _
        "Why don't eggs tell jokes? They'd crack each other up! 🥚", _
        "What do you call a can opener that doesn't work? A can't opener! 🥫", _
        "Why did the math book look so sad? Because it had too many problems! 📚", _
        "What do you call a bear with no ears? B! 🐻", _
        "Why did the cookie go to the doctor? Because it was feeling crumbly! 🍪", _
        "What do you call a fish wearing a bowtie? So-fish-ticated! 🐟", _
        "Why don't scientists trust atoms? Because they make up everything! ⚛️", _
        "What do you call a dinosaur that crashes his car? Tyrannosaurus wrecks! 🦖", _
        "Why did the golfer bring two pairs of pants? In case he got a hole in one! ⛳", _
        "What do you call a sleeping bull? A bulldozer! 🐂", _
        "Why did the scarecrow win an award? Because he was outstanding in his field! 🌾", _
        "What do you call a bear with no teeth? A gummy bear! 🐻", _
        "Why don't eggs tell jokes? They'd crack each other up! 🥚", _
        "What do you call a fake noodle? An impasta! 🍝", _
        "Why did the math book look so sad? Because it had too many problems! 📚", _
        "What do you call a can opener that doesn't work? A can't opener! 🥫", _
        "Why did the cookie go to the doctor? Because it was feeling crumbly! 🍪", _
        "What do you call a fish wearing a bowtie? So-fish-ticated! 🐟", _
        "Why don't scientists trust atoms? Because they make up everything! ⚛️", _
        "What do you call a dinosaur that crashes his car? Tyrannosaurus wrecks! 🦖", _
        "Why did the golfer bring two pairs of pants? In case he got a hole in one! ⛳", _
        "What do you call a sleeping bull? A bulldozer! 🐂", _
        "Why did the scarecrow win an award? Because he was outstanding in his field! 🌾", _
        "What do you call a bear with no teeth? A gummy bear! 🐻", _
        "Why don't eggs tell jokes? They'd crack each other up! 🥚", _
        "What do you call a fake noodle? An impasta! 🍝", _
        "Why did the math book look so sad? Because it had too many problems! 📚", _
        "What do you call a can opener that doesn't work? A can't opener! 🥫", _
        "Why did the cookie go to the doctor? Because it was feeling crumbly! 🍪", _
        "What do you call a fish wearing a bowtie? So-fish-ticated! 🐟", _
        "Why don't scientists trust atoms? Because they make up everything! ⚛️", _
        "What do you call a dinosaur that crashes his car? Tyrannosaurus wrecks! 🦖", _
        "Why did the golfer bring two pairs of pants? In case he got a hole in one! ⛳", _
        "What do you call a sleeping bull? A bulldozer! 🐂" _
    ]
    
    Local $randomIndex = Random(0, UBound($jokes) - 1, 1)
    Return $jokes[$randomIndex]
EndFunc

;~ Description: Move to coordinates and kill all enemies in range
;~ Parameters: $aX, $aY = Target coordinates, $aDescription = Description for logging, $aRange = Attack range (default: $RANGE_SPELLCAST)
Func MoveToKill($aX, $aY, $aDescription = "", $aRange = $RANGE_SPELLCAST)
	Local $lDeadlock = TimerInit()
	Local $lMe = GetAgentPtr(-2)
	Local $lTarget = 0
	Local $lEnemyCount = 0
	Local $lDestinationReached = False
	Local $lInCombat = False
	
	; Log the action
	If $aDescription <> "" Then
		Out("Moving to kill: " & $aDescription & " at (" & $aX & ", " & $aY & ")")
	Else
		Out("Moving to kill enemies at (" & $aX & ", " & $aY & ")")
	EndIf
	
	; Start moving to target location
	MoveTo($aX, $aY, 50)
	
	; Main movement and combat loop
	Do
		; Check if we're dead
		If GetIsDead($lMe) Then
			Out("Player is dead, stopping combat")
			Return False
		EndIf
		
		; Check if we've reached the destination
		If GetDistanceToXY($aX, $aY, $lMe) < 100 Then
			$lDestinationReached = True
		EndIf
		
		; Get number of enemies in range
		$lEnemyCount = GetNumberOfEnemiesNearAgent(-2, $aRange) ; Use normal range for detection
		
		; PRIORITY: If enemies are found, fight them immediately (don't wait to reach coordinates)
		If $lEnemyCount > 0 Then
			If Not $lInCombat Then
				Out("Found " & $lEnemyCount & " enemies, engaging combat immediately!")
				$lInCombat = True
			EndIf
			
			; Combat loop for current enemies - NO TIMEOUT, fight until all enemies are dead
			Do
				; Check if we're dead
				If GetIsDead($lMe) Then
					Out("Player is dead during combat")
					Return False
				EndIf
				
				; Get current enemy count
				$lEnemyCount = GetNumberOfEnemiesNearAgent(-2, $aRange) ; Use normal range for detection
				
				; If no more enemies, break combat loop
				If $lEnemyCount = 0 Then
					Out("Combat complete, continuing movement to target")
					$lInCombat = False
					ExitLoop
				EndIf
				
				; Get nearest enemy
				$lTarget = GetNearestEnemyPtrToAgent(-2)
				
				; If we have a valid target
				If $lTarget <> 0 And Not GetIsDead($lTarget) Then
					; Change target to the enemy
					ChangeTarget($lTarget)
					RndSleep(100)
					
					; Attack the target (auto-attack)
					Attack($lTarget)
					RndSleep(100)
					
					; Use skills with priority and custom fighting order
					UseSkillsWithPriorityAndCustomOrder($lTarget)
					
					; Wait a bit before next iteration
					RndSleep(500)
				Else
					; No valid target, wait a bit
					RndSleep(500)
				EndIf
				
			Until False
			
			; Pick up loot after combat is complete
			PickUpLoot()
			
			; Check for dead party members and resurrect them
			Out("Checking for dead party members after combat...")
			CheckAndResurrectPartyMembers()
			
			; After combat, continue moving if we haven't reached destination
			If Not $lDestinationReached Then
				Out("Resuming movement to target coordinates")
				MoveTo($aX, $aY, 50)
			EndIf
		Else
			; No enemies in range, continue movement if not at destination
			If Not $lDestinationReached Then
				; Only move if we're not in combat and not at destination
				If Not $lInCombat Then
					MoveTo($aX, $aY, 50)
				EndIf
			EndIf
		EndIf
		
		; Check for overall timeout (60 seconds)
		If TimerDiff($lDeadlock) > 60000 Then
			Out("Movement timeout reached")
			Return False
		EndIf
		
		
		; Small delay to prevent excessive CPU usage
		RndSleep(200)
		
	Until $lDestinationReached
	
	Out("Reached destination at (" & $aX & ", " & $aY & ")")
	
	; Add a random game joke after successful completion
	Out("🎮 " & GetRandomGameJoke())
	
	Return True
EndFunc

;~ Vanquish the map

Func VanquishMountQinkai()
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
		[12500, -3500, 'Naga 8'], _
		[14000, -6000, 'Outcast Warrior Boss'], _
		[13000, -6000, 'Leftovers'] _
	]
	
	; Define ranges for each location (most use default, some use spirit range)
	Local $ranges[] = [$RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT]
	
	; Check if we're starting in Mount Qinkai and need to find the closest starting point
	Local $startingInMountQinkai = (GetMapID() = 200)
	Local $cameFromTown = False
	
	Out("Current map ID: " & GetMapID() & " (200 = Mount Qinkai)")
	
	; Check if we're near the spawn point and need to get blessing first (regardless of how we got here)
	Local $distanceFromSpawn = GetDistanceToXY(-8394, -9801, -2)
	Out("Distance from spawn point: " & Round($distanceFromSpawn))
	
	If $distanceFromSpawn < 2000 Then
		Out("Near spawn point, getting blessing first!")
		$cameFromTown = True ; Mark that we came from town
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
	
	; If we came from town (got blessing), start from index 0
	; Otherwise, find the closest point to start from
	If $cameFromTown Then
		Out("Came from town with blessing, starting vanquish from index 0")
		; Reset vanquish index to 0 for fresh start
		$CurrentVanquishIndex = 0
		Out("Reset CurrentVanquishIndex to 0 for fresh vanquish start")
		
		; Start the loop from the beginning (index 0)
		For $i = 0 To UBound($vanquishLocations) - 1
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
	EndIf
	
	; If we didn't come from town, find the closest point to start from
	If Not $cameFromTown Then
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
		
		; Reset vanquish index to the nearest index for this scenario
		$CurrentVanquishIndex = $nearestIndex
		Out("Set CurrentVanquishIndex to " & $nearestIndex & " (closest point)")
		
		; Start the loop from the closest point
		For $i = $nearestIndex To UBound($vanquishLocations) - 1
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
	EndIf
	
	Move(-8394, -9801) ; Move to blessing coordinates
	RndSleep(2000)
		; Normal vanquish flow (starting from town)
		Out('Taking blessing')
		RndSleep(1000)
		
		; Reset vanquish index to 0 for normal vanquish flow from town
		$CurrentVanquishIndex = 0
		Out("Reset CurrentVanquishIndex to 0 for normal vanquish flow from town")

		; Process each location
		For $i = 0 To UBound($vanquishLocations) - 1
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
			Out("Vanquish complete! Traveling back to Fort Aspenwood to restart...")
	RndTravel($MAP_ID_FORT_ASPENWOOD_LUXON)
	WaitMapLoading($MAP_ID_FORT_ASPENWOOD_LUXON, 10000, 2000)
	RndSleep(2000)
		Return 1

	EndIf
	
	Out('Area vanquished successfully!')
	
	; Force travel back to Fort Aspenwood (map 389) after vanquish completion
	Out("Vanquish complete! Traveling back to Fort Aspenwood to restart...")
	RndTravel($MAP_ID_FORT_ASPENWOOD_LUXON)
	WaitMapLoading($MAP_ID_FORT_ASPENWOOD_LUXON, 10000, 2000)
	RndSleep(2000)
	
	Out("Successfully returned to Fort Aspenwood. Restarting vanquish process...")
	Return 0
EndFunc

; Function to build skill name array from constants
Func BuildSkillNameArray()
    Out("Building comprehensive skill name array from constants...")
    
    ; Clear the array first
    For $i = 0 To UBound($SkillNameArray) - 1
        $SkillNameArray[$i] = ""
    Next
    
    Out("Skill name array built with " & UBound($SkillNameArray) & " entries")
EndFunc

; Function to get skill name from ID using the array
Func GetSkillNameFromArray($skillID)
    If $skillID >= 0 And $skillID < UBound($SkillNameArray) Then
        If $SkillNameArray[$skillID] <> "" Then
            Return $SkillNameArray[$skillID]
        EndIf
    EndIf
    Return "Unknown Skill (" & $skillID & ")"
EndFunc

Func UpdateSkillbarDisplay()
    If Not $BotInitialized Then
        Out("Bot not initialized, showing placeholder skill names")
        ; Show placeholder names when bot is not initialized
        For $i = 0 To 7
            GUICtrlSetData($SkillNames[$i], "Slot " & ($i + 1))
        Next
        Return
    EndIf
    
    Out("Updating skillbar display...")
    For $i = 0 To 7
        Local $skillID = GetSkillbarSkillID($i + 1)
        Local $skillName = GetSkillNameFromArray($skillID)
        
        ; Show skill name from array
        GUICtrlSetData($SkillNames[$i], $skillName)
        
        ; Debug output to help identify issues
        Out("Skill " & ($i + 1) & ": ID=" & $skillID & ", Name='" & $skillName & "'")
    Next
    Out("Skillbar updated successfully")
EndFunc

; Function to initialize skill names when GUI is first created
Func InitializeSkillNames()
    Out("Initializing skill names display...")
    
    ; Build the skill name array first
    BuildSkillNameArray()
    
    ; Set placeholder names
    For $i = 0 To 7
        GUICtrlSetData($SkillNames[$i], "Slot " & ($i + 1))
    Next
    Out("Skill names initialized with placeholders")
EndFunc

Func UpdateCustomFightingList()
    ; Clear the list
    GUICtrlSetData($GUICustomFightingList, "")
    
    ; Add skills in custom order (with safety check)
    If $CustomFightingCount > 0 Then
        For $i = 0 To $CustomFightingCount - 1
            Local $skillSlot = $CustomFightingOrder[$i]
            Local $skillID = GetSkillbarSkillID($skillSlot)
            Local $skillName = GetSkillNameFromArray($skillID)
            Local $listItem = $skillSlot & ": " & $skillName
            GUICtrlSetData($GUICustomFightingList, $listItem)
        Next
    EndIf
EndFunc

Func UseSkillsWithPriorityAndCustomOrder($lTarget)
    ; If custom fighting is enabled, use custom order
    If $CustomFightingEnabled And $CustomFightingCount > 0 Then
        UseCustomFightingOrder($lTarget)
    Else
        ; Use normal priority-based skill usage
        UsePrioritySkills($lTarget)
    EndIf
EndFunc

Func UseCustomFightingOrder($lTarget)
    ; Check if we have any skills in custom order
    If $CustomFightingCount <= 0 Then
        Out("No skills in custom fighting order")
        ; Still attack even if no skills available
        Attack($lTarget)
        Return
    EndIf
    
    ; Use skills in the custom fighting order
    Local $skillSlot = $CustomFightingOrder[$CurrentCustomSkillIndex]
    Local $skillEnabled = GUICtrlRead($SkillCheckboxes[$skillSlot - 1]) = $GUI_CHECKED
    Local $skillRecharged = IsRecharged($skillSlot)
    Local $skillEnergy = GetEnergy(-2)
    Local $skillEnergyReq = GetEnergyReq(GetSkillbarSkillID($skillSlot))
    
    If $skillEnabled And $skillRecharged And $skillEnergy >= $skillEnergyReq Then
        ; Use the skill
        Local $skillID = GetSkillbarSkillID($skillSlot)
        Local $skillName = GetSkillNameFromArray($skillID)
        Out("Using custom skill " & $skillSlot & ": " & $skillName & " (ID: " & $skillID & ")")
        UseSkillEx($skillSlot, $lTarget, 3000, True)
        RndSleep(200)
        
        ; Move to next skill in custom order (with safety check)
        $CurrentCustomSkillIndex += 1
        If $CurrentCustomSkillIndex >= $CustomFightingCount Then
            $CurrentCustomSkillIndex = 0 ; Reset to beginning
        EndIf
    Else
        ; Skip this skill and move to next (with safety check)
        $CurrentCustomSkillIndex += 1
        If $CurrentCustomSkillIndex >= $CustomFightingCount Then
            $CurrentCustomSkillIndex = 0 ; Reset to beginning
        EndIf
        
        ; Debug output for why skill wasn't used
        Local $skillID = GetSkillbarSkillID($skillSlot)
        Local $skillName = GetSkillNameFromArray($skillID)
        If Not $skillEnabled Then
            Out("Custom skill " & $skillSlot & " (" & $skillName & ") disabled")
        ElseIf Not $skillRecharged Then
            Out("Custom skill " & $skillSlot & " (" & $skillName & ") not recharged")
        ElseIf $skillEnergy < $skillEnergyReq Then
            Out("Custom skill " & $skillSlot & " (" & $skillName & ") not enough energy (" & $skillEnergy & "/" & $skillEnergyReq & ")")
        EndIf
    EndIf
    
    ; Always attack the target (auto-attack) even if skills aren't available
    Attack($lTarget)
EndFunc

Func UsePrioritySkills($lTarget)
    ; First, try to use priority skills
    For $i = 1 To 8
        Local $skillEnabled = GUICtrlRead($SkillCheckboxes[$i-1]) = $GUI_CHECKED
        Local $skillPriority = GUICtrlRead($SkillPriorityCheckboxes[$i-1]) = $GUI_CHECKED
        Local $skillRecharged = IsRecharged($i)
        Local $skillEnergy = GetEnergy(-2)
        Local $skillEnergyReq = GetEnergyReq(GetSkillbarSkillID($i))
        
        ; If it's a priority skill and can be used, use it
        If $skillPriority And $skillEnabled And $skillRecharged And $skillEnergy >= $skillEnergyReq Then
            Local $skillID = GetSkillbarSkillID($i)
            Local $skillName = GetSkillNameFromArray($skillID)
            Out("Using priority skill " & $i & ": " & $skillName & " (ID: " & $skillID & ")")
            UseSkillEx($i, $lTarget, 3000, True)
            RndSleep(200)
            ; Attack the target after using priority skill
            Attack($lTarget)
            Return ; Exit after using one priority skill
        EndIf
    Next
    
    ; If no priority skills available, use normal skills
    For $i = 1 To 8
        Local $skillEnabled = GUICtrlRead($SkillCheckboxes[$i-1]) = $GUI_CHECKED
        Local $skillPriority = GUICtrlRead($SkillPriorityCheckboxes[$i-1]) = $GUI_CHECKED
        Local $skillRecharged = IsRecharged($i)
        Local $skillEnergy = GetEnergy(-2)
        Local $skillEnergyReq = GetEnergyReq(GetSkillbarSkillID($i))
        
        ; Use non-priority skills that are enabled and ready
        If $skillEnabled And Not $skillPriority And $skillRecharged And $skillEnergy >= $skillEnergyReq Then
            Local $skillID = GetSkillbarSkillID($i)
            Local $skillName = GetSkillNameFromArray($skillID)
            Out("Using normal skill " & $i & ": " & $skillName & " (ID: " & $skillID & ")")
            UseSkillEx($i, $lTarget, 3000, True)
            RndSleep(200)
            ; Attack the target after using normal skill
            Attack($lTarget)
            Return ; Exit after using one skill
        EndIf
    Next
    
    ; If no skills are available, still attack the target
    Out("No skills available, using auto-attack only")
    Attack($lTarget)
EndFunc

; Function to check for dead party members and wait for them to be resurrected
Func CheckAndResurrectPartyMembers()
	Local $deadMembers = 0
	Local $deadPartyMembers[1] = [0] ; Array to store dead member agent IDs
	
	; Check all party members for dead status
	Local $partySize = GetPartySize()
	
	; Check heroes (party members 1 to party size)
	For $i = 1 To $partySize
		Local $memberAgentID = 0
		
		 ; Get agent ID for this party member
		If $i = 1 Then
			; Player character
			$memberAgentID = GetMyID()
		Else
			; Hero (party member number - 1 for hero array)
			$memberAgentID = GetMyPartyHeroInfo($i - 1, "AgentID")
		EndIf
		
		; Check if this member is dead
		If $memberAgentID <> 0 And GetIsDead($memberAgentID) Then
			$deadMembers += 1
			ReDim $deadPartyMembers[$deadMembers + 1]
			$deadPartyMembers[$deadMembers] = $memberAgentID
			
			Local $memberName = "Unknown"
			If $i = 1 Then
				$memberName = GetPlayerName($memberAgentID)
			Else
				; For heroes, we can get the hero name if needed
				$memberName = "Hero " & ($i - 1)
			EndIf
			
			Out("Found dead party member: " & $memberName & " (Agent ID: " & $memberAgentID & ")")
		EndIf
	Next
	
	; If we have dead members, wait for them to be resurrected
	If $deadMembers > 0 Then
		Out("Found " & $deadMembers & " dead party member(s), waiting for resurrection by other party members...")
		
		; Wait for all dead members to be resurrected
		Local $resurrectionTimer = TimerInit()
		Local $allResurrected = False
		
		Do
			; Check if all members are now alive
			$allResurrected = True
			For $i = 1 To $deadMembers
				If GetIsDead($deadPartyMembers[$i]) Then
					$allResurrected = False
					ExitLoop
				EndIf
			Next
			
			; If all are resurrected, break the loop
			If $allResurrected Then
				Out("All party members have been resurrected!")
				ExitLoop
			EndIf
			
			; Wait a bit before checking again
			RndSleep(2000)
			
			; Check for timeout (2 minutes)
			If TimerDiff($resurrectionTimer) > 120000 Then
				Out("Warning: Timeout reached waiting for resurrection. Continuing anyway...")
				ExitLoop
			EndIf
			
		Until False
		
		; Final status report
		Local $stillDead = 0
		For $i = 1 To $deadMembers
			If GetIsDead($deadPartyMembers[$i]) Then
				$stillDead += 1
			EndIf
		Next
		
		If $stillDead > 0 Then
			Out("Warning: " & $stillDead & " party member(s) still dead after waiting period")
		Else
			Out("All party members successfully resurrected by other party members!")
		EndIf
		
		Return True
	EndIf
	
	Return True ; No dead members found
EndFunc

