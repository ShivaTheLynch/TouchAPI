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
#include "TouchApi/complete_skill_names.au3"

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
Global $ReturningToTown = False ; Prevent vanquish restart before returning to town
Global $ReadyToStartRun = False ; Flag to track when bot is ready to start a new run

; Custom fighting system variables
Global $CustomFightingOrder
Dim $CustomFightingOrder[20] ; Array to store custom fighting order (skill slot numbers)
Global $CustomFightingCount = 0 ; Number of skills in custom order
Global $CustomFightingEnabled = False ; Whether custom fighting is enabled
Global $CurrentCustomSkillIndex = 0 ; Current position in custom fighting order

; Global array to store skill names mapped to IDs
; Global $SkillNameArray[10000] ; Large enough to hold all skill IDs

Global $CameFromTown = False

; --- Statistics variables ---
Global $Stat_Deaths = 0
Global $Stat_TotalRuns = 0
Global $Stat_TotalRunTime = 0 ; in seconds
Global $Stat_AvgRunTime = 0
Global $Stat_Golds = 0
Global $Stat_Purples = 0
Global $Stat_Blues = 0
Global $Stat_Whites = 0
Global $Stat_LuxonFaction = 0
Global $Stat_LuxonFactionMax = 0
Global $Stat_LuxonDonated = 0
Global $Stat_CurrentGold = 0
Global $Stat_GoldPickedUp = 0

; --- Statistics label variables ---
Global $StatDeathsLabel, $StatTotalRunsLabel, $StatTotalRunTimeLabel, $StatAvgRunTimeLabel
Global $StatGoldsLabel, $StatPurplesLabel, $StatBluesLabel, $StatWhitesLabel
Global $StatLuxonFactionLabel, $StatLuxonDonatedLabel
Global $StatCurrentGoldLabel, $StatGoldPickedUpLabel

; Add a timer-based update for live coordinates in Extra tab
Global $ExtraStatsUpdateTimer = TimerInit()
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
$GUIInitializeButton = GUICtrlCreateButton("Initialize", 32, 104, 75, 25)
GUICtrlSetOnEvent($GUIInitializeButton, "GuiButtonHandler")
$GUIStartBotButton = GUICtrlCreateButton("Start Bot", 120, 104, 75, 25)
GUICtrlSetOnEvent($GUIStartBotButton, "GuiButtonHandler")
GUICtrlSetState($GUIStartBotButton, $GUI_DISABLE) ; Disabled until initialized
$GUIDonateFactionButton = GUICtrlCreateButton("DONATE FACTION", 200, 104, 120, 25)
GUICtrlSetOnEvent($GUIDonateFactionButton, "GuiButtonHandler")
GUICtrlSetBkColor($GUIDonateFactionButton, 0xFF0000) ; Red background
GUICtrlSetColor($GUIDonateFactionButton, 0xFFFFFF) ; White text
$gOnTopCheckbox = GUICtrlCreateCheckbox("On Top", 250, 103, 81, 24)
GUICtrlSetState(-1, $GUI_CHECKED)

; Statistics group (moved inside Character tab only)
$GroupStats = GUICtrlCreateGroup("Statistics", 400, 40, 360, 160)
$StatDeathsLabel = GUICtrlCreateLabel("Deaths: 0", 420, 60, 150, 20)
$StatTotalRunsLabel = GUICtrlCreateLabel("Total Runs: 0", 420, 80, 150, 20)
$StatTotalRunTimeLabel = GUICtrlCreateLabel("Total Run Time: 0s", 420, 100, 150, 20)
$StatAvgRunTimeLabel = GUICtrlCreateLabel("Avg Run Time: 0s", 420, 120, 150, 20)
$StatGoldsLabel = GUICtrlCreateLabel("Golds picked up: 0", 600, 60, 150, 20)
$StatPurplesLabel = GUICtrlCreateLabel("Purples picked up: 0", 600, 80, 150, 20)
$StatBluesLabel = GUICtrlCreateLabel("Blues picked up: 0", 600, 100, 150, 20)
$StatWhitesLabel = GUICtrlCreateLabel("Whites picked up: 0", 600, 120, 150, 20)
$StatLuxonFactionLabel = GUICtrlCreateLabel("Luxon Faction: 0 / 0", 420, 140, 200, 20)
$StatLuxonDonatedLabel = GUICtrlCreateLabel("Luxon Donated: 0", 600, 140, 150, 20)
$StatCurrentGoldLabel = GUICtrlCreateLabel("Current Gold: 0", 420, 160, 150, 20)
$StatGoldPickedUpLabel = GUICtrlCreateLabel("Gold Picked Up: 0", 600, 160, 150, 20)
GUICtrlCreateGroup("", -99, -99, 1, 1)

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

; Tab 4: Extra Log
GUICtrlCreateTabItem("Extra")
$GroupExtraLog = GUICtrlCreateGroup("Extra Log", 16, 40, 360, 520)
$GUIExtraEdit = GUICtrlCreateEdit("", 32, 64, 328, 480)
GUICtrlSetData(-1, "")
GUICtrlSetColor(-1, 0xFFB266)
GUICtrlSetBkColor(-1, 0x23272A)
GUICtrlCreateGroup("", -99, -99, 1, 1)

; Extra statistics group (styled like Character tab)
$GroupExtraStats = GUICtrlCreateGroup("Statistics", 400, 40, 360, 180)
$ExtraStatCoordsLabel = GUICtrlCreateLabel("Coords: (0, 0)", 420, 60, 300, 20)
$ExtraStatDeathsLabel = GUICtrlCreateLabel("Deaths: 0", 420, 80, 150, 20)
$ExtraStatTotalRunsLabel = GUICtrlCreateLabel("Total Runs: 0", 420, 100, 150, 20)
$ExtraStatTotalRunTimeLabel = GUICtrlCreateLabel("Total Run Time: 0s", 420, 120, 150, 20)
$ExtraStatAvgRunTimeLabel = GUICtrlCreateLabel("Avg Run Time: 0s", 420, 140, 150, 20)
$ExtraStatGoldsLabel = GUICtrlCreateLabel("Golds picked up: 0", 600, 60, 150, 20)
$ExtraStatPurplesLabel = GUICtrlCreateLabel("Purples picked up: 0", 600, 80, 150, 20)
$ExtraStatBluesLabel = GUICtrlCreateLabel("Blues picked up: 0", 600, 100, 150, 20)
$ExtraStatWhitesLabel = GUICtrlCreateLabel("Whites picked up: 0", 600, 120, 150, 20)
$ExtraStatLuxonFactionLabel = GUICtrlCreateLabel("Luxon Faction: " & $Stat_LuxonFaction & " / " & $Stat_LuxonFactionMax, 420, 160, 200, 20)
$ExtraStatLuxonDonatedLabel = GUICtrlCreateLabel("Luxon Donated: " & $Stat_LuxonDonated, 600, 140, 150, 20)
$ExtraStatCurrentGoldLabel = GUICtrlCreateLabel("Current Gold: " & $Stat_CurrentGold, 420, 180, 150, 20)
$ExtraStatGoldPickedUpLabel = GUICtrlCreateLabel("Gold Picked Up: " & $Stat_GoldPickedUp, 600, 160, 150, 20)
GUICtrlCreateGroup("", -99, -99, 1, 1)

; Tab 5: Run Options & Loot
GUICtrlCreateTabItem("Settings")
$Group4 = GUICtrlCreateGroup("Run Options", 16, 40, 370, 140)

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

; Loot Options Group (move down for more space)
$Group5 = GUICtrlCreateGroup("Loot Filter Options", 16, 190, 370, 370)

; Rarity filters (move down)
$LootRarityGroup = GUICtrlCreateGroup("Item Rarity", 32, 214, 160, 160)
$GUIPickupGoldCheckbox = GUICtrlCreateCheckbox("Gold Items (Legendary)", 40, 234, 140, 20)
GUICtrlSetState($GUIPickupGoldCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupGoldCheckbox, "GuiButtonHandler")

$GUIPickupPurpleCheckbox = GUICtrlCreateCheckbox("Purple Items (Unique)", 40, 254, 140, 20)
GUICtrlSetState($GUIPickupPurpleCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupPurpleCheckbox, "GuiButtonHandler")

$GUIPickupBlueCheckbox = GUICtrlCreateCheckbox("Blue Items (Rare)", 40, 274, 140, 20)
GUICtrlSetState($GUIPickupBlueCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupBlueCheckbox, "GuiButtonHandler")

$GUIPickupGreenCheckbox = GUICtrlCreateCheckbox("Green Items (Uncommon)", 40, 294, 140, 20)
GUICtrlSetState($GUIPickupGreenCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupGreenCheckbox, "GuiButtonHandler")

$GUIPickupWhiteCheckbox = GUICtrlCreateCheckbox("White Items (Common)", 40, 314, 140, 20)
GUICtrlSetState($GUIPickupWhiteCheckbox, $GUI_UNCHECKED) ; Default to unchecked
GUICtrlSetOnEvent($GUIPickupWhiteCheckbox, "GuiButtonHandler")
GUICtrlCreateGroup("", -99, -99, 1, 1)

; Special item filters (move right)
$SpecialItemsGroup = GUICtrlCreateGroup("Special Items", 200, 214, 170, 160)
$GUIPickupMaterialsCheckbox = GUICtrlCreateCheckbox("Materials (Wood, Cloth, etc.)", 210, 234, 150, 20)
GUICtrlSetState($GUIPickupMaterialsCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupMaterialsCheckbox, "GuiButtonHandler")

$GUIPickupDyesCheckbox = GUICtrlCreateCheckbox("Dyes", 210, 254, 140, 20)
GUICtrlSetState($GUIPickupDyesCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupDyesCheckbox, "GuiButtonHandler")

$GUIPickupKeysCheckbox = GUICtrlCreateCheckbox("Keys", 210, 274, 140, 20)
GUICtrlSetState($GUIPickupKeysCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupKeysCheckbox, "GuiButtonHandler")

$GUIPickupScrollsCheckbox = GUICtrlCreateCheckbox("Scrolls", 210, 294, 140, 20)
GUICtrlSetState($GUIPickupScrollsCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupScrollsCheckbox, "GuiButtonHandler")

$GUIPickupConsumablesCheckbox = GUICtrlCreateCheckbox("Consumables", 210, 314, 140, 20)
GUICtrlSetState($GUIPickupConsumablesCheckbox, $GUI_CHECKED)
GUICtrlSetOnEvent($GUIPickupConsumablesCheckbox, "GuiButtonHandler")
GUICtrlCreateGroup("", -99, -99, 1, 1)

; Weapon type filters (move below)
; (Delete the following block)
; $WeaponTypeGroup = GUICtrlCreateGroup("Weapon Types", 32, 380, 340, 120)
; $GUIPickupSwordsCheckbox = GUICtrlCreateCheckbox("Swords", 40, 400, 100, 20)
; GUICtrlSetState($GUIPickupSwordsCheckbox, $GUI_CHECKED)
; GUICtrlSetOnEvent($GUIPickupSwordsCheckbox, "GuiButtonHandler")

; $GUIPickupAxesCheckbox = GUICtrlCreateCheckbox("Axes", 40, 420, 100, 20)
; GUICtrlSetState($GUIPickupAxesCheckbox, $GUI_CHECKED)
; GUICtrlSetOnEvent($GUIPickupAxesCheckbox, "GuiButtonHandler")

; $GUIPickupHammersCheckbox = GUICtrlCreateCheckbox("Hammers", 40, 440, 100, 20)
; GUICtrlSetState($GUIPickupHammersCheckbox, $GUI_CHECKED)
; GUICtrlSetOnEvent($GUIPickupHammersCheckbox, "GuiButtonHandler")

; $GUIPickupDaggersCheckbox = GUICtrlCreateCheckbox("Daggers", 40, 460, 100, 20)
; GUICtrlSetState($GUIPickupDaggersCheckbox, $GUI_CHECKED)
; GUICtrlSetOnEvent($GUIPickupDaggersCheckbox, "GuiButtonHandler")

; $GUIPickupScythesCheckbox = GUICtrlCreateCheckbox("Scythes", 150, 400, 100, 20)
; GUICtrlSetState($GUIPickupScythesCheckbox, $GUI_CHECKED)
; GUICtrlSetOnEvent($GUIPickupScythesCheckbox, "GuiButtonHandler")

; $GUIPickupBowsCheckbox = GUICtrlCreateCheckbox("Bows", 150, 420, 100, 20)
; GUICtrlSetState($GUIPickupBowsCheckbox, $GUI_CHECKED)
; GUICtrlSetOnEvent($GUIPickupBowsCheckbox, "GuiButtonHandler")

; $GUIPickupWandsCheckbox = GUICtrlCreateCheckbox("Wands", 150, 440, 100, 20)
; GUICtrlSetState($GUIPickupWandsCheckbox, $GUI_CHECKED)
; GUICtrlSetOnEvent($GUIPickupWandsCheckbox, "GuiButtonHandler")

; $GUIPickupStavesCheckbox = GUICtrlCreateCheckbox("Staves", 150, 460, 100, 20)
; GUICtrlSetState($GUIPickupStavesCheckbox, $GUI_CHECKED)
; GUICtrlSetOnEvent($GUIPickupStavesCheckbox, "GuiButtonHandler")

; $GUIPickupShieldsCheckbox = GUICtrlCreateCheckbox("Shields", 260, 400, 100, 20)
; GUICtrlSetState($GUIPickupShieldsCheckbox, $GUI_CHECKED)
; GUICtrlSetOnEvent($GUIPickupShieldsCheckbox, "GuiButtonHandler")

; $GUIPickupFocusItemsCheckbox = GUICtrlCreateCheckbox("Focus Items", 260, 420, 100, 20)
; GUICtrlSetState($GUIPickupFocusItemsCheckbox, $GUI_CHECKED)
; GUICtrlSetOnEvent($GUIPickupFocusItemsCheckbox, "GuiButtonHandler")

; $GUIPickupArmorCheckbox = GUICtrlCreateCheckbox("Armor", 260, 440, 100, 20)
; GUICtrlSetState($GUIPickupArmorCheckbox, $GUI_CHECKED)
; GUICtrlSetOnEvent($GUIPickupArmorCheckbox, "GuiButtonHandler")

; $GUIPickupRunesCheckbox = GUICtrlCreateCheckbox("Runes", 260, 460, 100, 20)
; GUICtrlSetState($GUIPickupRunesCheckbox, $GUI_CHECKED)
; GUICtrlSetOnEvent($GUIPickupRunesCheckbox, "GuiButtonHandler")

; $GUIPickupInsigniasCheckbox = GUICtrlCreateCheckbox("Insignias", 260, 480, 100, 20)
; GUICtrlSetState($GUIPickupInsigniasCheckbox, $GUI_CHECKED)
; GUICtrlSetOnEvent($GUIPickupInsigniasCheckbox, "GuiButtonHandler")
; GUICtrlCreateGroup("", -99, -99, 1, 1)

; Quick selection buttons (move to right column)
$QuickSelectionGroup = GUICtrlCreateGroup("Quick Selection", 400, 190, 350, 120)
$GUIAllLootButton = GUICtrlCreateButton("Select All Loot", 416, 214, 100, 25)
GUICtrlSetOnEvent($GUIAllLootButton, "GuiButtonHandler")

$GUINoLootButton = GUICtrlCreateButton("Deselect All Loot", 416, 244, 100, 25)
GUICtrlSetOnEvent($GUINoLootButton, "GuiButtonHandler")

$GUIRareOnlyButton = GUICtrlCreateButton("Rare+ Only", 416, 274, 100, 25)
GUICtrlSetOnEvent($GUIRareOnlyButton, "GuiButtonHandler")

$GUIWeaponsOnlyButton = GUICtrlCreateButton("Weapons Only", 530, 214, 100, 25)
GUICtrlSetOnEvent($GUIWeaponsOnlyButton, "GuiButtonHandler")

$GUIMaterialsOnlyButton = GUICtrlCreateButton("Materials Only", 530, 244, 100, 25)
GUICtrlSetOnEvent($GUIMaterialsOnlyButton, "GuiButtonHandler")

$GUISpecialOnlyButton = GUICtrlCreateButton("Special Only", 530, 274, 100, 25)
GUICtrlSetOnEvent($GUISpecialOnlyButton, "GuiButtonHandler")
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
GUICtrlCreateGroup("", -99, -99, 1, 1)

; Sell Weapon Types
; (Delete the following block)
; $SellWeaponTypeGroup = GUICtrlCreateGroup("Weapon Types", 32, 200, 350, 180)
; $GUISellSwordsCheckbox = GUICtrlCreateCheckbox("Swords", 48, 224, 100, 20)
; $GUISellAxesCheckbox = GUICtrlCreateCheckbox("Axes", 48, 248, 100, 20)
; $GUISellHammersCheckbox = GUICtrlCreateCheckbox("Hammers", 48, 272, 100, 20)
; $GUISellDaggersCheckbox = GUICtrlCreateCheckbox("Daggers", 48, 296, 100, 20)
; $GUISellScythesCheckbox = GUICtrlCreateCheckbox("Scythes", 48, 320, 100, 20)
; $GUISellBowsCheckbox = GUICtrlCreateCheckbox("Bows", 160, 224, 100, 20)
; $GUISellWandsCheckbox = GUICtrlCreateCheckbox("Wands", 160, 248, 100, 20)
; $GUISellStavesCheckbox = GUICtrlCreateCheckbox("Staves", 160, 272, 100, 20)
; $GUISellShieldsCheckbox = GUICtrlCreateCheckbox("Shields", 160, 296, 100, 20)
; $GUISellFocusItemsCheckbox = GUICtrlCreateCheckbox("Focus Items", 160, 320, 100, 20)
; $GUISellArmorCheckbox = GUICtrlCreateCheckbox("Armor", 272, 224, 100, 20)
; $GUISellRunesCheckbox = GUICtrlCreateCheckbox("Runes", 272, 248, 100, 20)
; $GUISellInsigniasCheckbox = GUICtrlCreateCheckbox("Insignias", 272, 272, 100, 20)
; GUICtrlCreateGroup("", -99, -99, 1, 1)

; Sell Special Items
$SellSpecialItemsGroup = GUICtrlCreateGroup("Special Items", 400, 64, 320, 180)
$GUISellMaterialsCheckbox = GUICtrlCreateCheckbox("Materials (Wood, Cloth, etc.)", 416, 88, 200, 20)
$GUISellDyesCheckbox = GUICtrlCreateCheckbox("Dyes", 416, 112, 150, 20)
$GUISellKeysCheckbox = GUICtrlCreateCheckbox("Keys", 416, 136, 150, 20)
$GUISellScrollsCheckbox = GUICtrlCreateCheckbox("Scrolls", 416, 160, 150, 20)
$GUISellConsumablesCheckbox = GUICtrlCreateCheckbox("Consumables", 416, 184, 150, 20)
GUICtrlCreateGroup("", -99, -99, 1, 1)

GUICtrlCreateGroup("", -99, -99, 1, 1)

; Tab 6: Salvage
GUICtrlCreateTabItem("Salvage")
$GroupSalvage = GUICtrlCreateGroup("Salvage Items", 16, 40, 760, 520)

; Salvage Item Rarity
$SalvageRarityGroup = GUICtrlCreateGroup("Item Rarity", 32, 64, 350, 120)
$GUISalvageGoldCheckbox = GUICtrlCreateCheckbox("Gold Items (Legendary)", 48, 88, 150, 20)
$GUISalvagePurpleCheckbox = GUICtrlCreateCheckbox("Purple Items (Unique)", 48, 112, 150, 20)
$GUISalvageBlueCheckbox = GUICtrlCreateCheckbox("Blue Items (Rare)", 48, 136, 150, 20)
$GUISalvageGreenCheckbox = GUICtrlCreateCheckbox("Green Items (Uncommon)", 48, 160, 150, 20)
$GUISalvageWhiteCheckbox = GUICtrlCreateCheckbox("White Items (Common)", 220, 88, 150, 20)
GUICtrlCreateGroup("", -99, -99, 1, 1)

; Salvage Weapon Types
; (Delete the following block)
; $SalvageWeaponTypeGroup = GUICtrlCreateGroup("Weapon Types", 32, 200, 350, 180)
; $GUISalvageSwordsCheckbox = GUICtrlCreateCheckbox("Swords", 48, 224, 100, 20)
; $GUISalvageAxesCheckbox = GUICtrlCreateCheckbox("Axes", 48, 248, 100, 20)
; $GUISalvageHammersCheckbox = GUICtrlCreateCheckbox("Hammers", 48, 272, 100, 20)
; $GUISalvageDaggersCheckbox = GUICtrlCreateCheckbox("Daggers", 48, 296, 100, 20)
; $GUISalvageScythesCheckbox = GUICtrlCreateCheckbox("Scythes", 48, 320, 100, 20)
; $GUISalvageBowsCheckbox = GUICtrlCreateCheckbox("Bows", 160, 224, 100, 20)
; $GUISalvageWandsCheckbox = GUICtrlCreateCheckbox("Wands", 160, 248, 100, 20)
; $GUISalvageStavesCheckbox = GUICtrlCreateCheckbox("Staves", 160, 272, 100, 20)
; $GUISalvageShieldsCheckbox = GUICtrlCreateCheckbox("Shields", 160, 296, 100, 20)
; $GUISalvageFocusItemsCheckbox = GUICtrlCreateCheckbox("Focus Items", 160, 320, 100, 20)
; $GUISalvageArmorCheckbox = GUICtrlCreateCheckbox("Armor", 272, 224, 100, 20)
; $GUISalvageRunesCheckbox = GUICtrlCreateCheckbox("Runes", 272, 248, 100, 20)
; $GUISalvageInsigniasCheckbox = GUICtrlCreateCheckbox("Insignias", 272, 272, 100, 20)
; GUICtrlCreateGroup("", -99, -99, 1, 1)

; Salvage Special Items
$SalvageSpecialItemsGroup = GUICtrlCreateGroup("Special Items", 400, 64, 320, 180)
$GUISalvageMaterialsCheckbox = GUICtrlCreateCheckbox("Materials (Wood, Cloth, etc.)", 416, 88, 200, 20)
$GUISalvageDyesCheckbox = GUICtrlCreateCheckbox("Dyes", 416, 112, 150, 20)
$GUISalvageKeysCheckbox = GUICtrlCreateCheckbox("Keys", 416, 136, 150, 20)
$GUISalvageScrollsCheckbox = GUICtrlCreateCheckbox("Scrolls", 416, 160, 150, 20)
$GUISalvageConsumablesCheckbox = GUICtrlCreateCheckbox("Consumables", 416, 184, 150, 20)
GUICtrlCreateGroup("", -99, -99, 1, 1)

GUICtrlCreateGroup("", -99, -99, 1, 1)

GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")
GUISetState(@SW_SHOW)

; Initialize skill names with placeholders
InitializeSkillNames()

; Initialize statistics display
UpdateStatisticsDisplay()

#EndRegion ### END Koda GUI section ###

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

Func GuiButtonHandler()
    Switch @GUI_CtrlId
        Case $GUIInitializeButton
            Out("Initializing (connect only, not starting bot loop)")
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
            GUICtrlSetState($GUIInitializeButton, $GUI_DISABLE)
            GUICtrlSetState($GUIRefreshButton, $GUI_DISABLE)
            GUICtrlSetState($GUINameCombo, $GUI_DISABLE)
            GUICtrlSetState($GUIStartBotButton, $GUI_ENABLE)
            WinSetTitle($MainGui, "", GetCharname() & " - Bot for test")
            $BotInitialized = True
            ; Update skillbar display after initialization
            UpdateSkillbarDisplay()
            ; Update Luxon faction stats after initialization
            $Stat_LuxonFaction = GetLuxonFaction()
            $Stat_LuxonFactionMax = GetMaxLuxonFaction()
            $Stat_CurrentGold = GetGoldCharacter()
            UpdateStatisticsDisplay()

        Case $GUIStartBotButton
            If Not $BotInitialized Then
                Out("Please initialize first before starting the bot loop.")
                Return
            EndIf
            $BotRunning = True
            GUICtrlSetState($GUIStartBotButton, $GUI_DISABLE)
            Out("Bot loop started.")

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

        ; Quick Selection Button Handlers
        Case $GUIAllLootButton
            ; Select all loot checkboxes
            GUICtrlSetState($GUIPickupGoldCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupPurpleCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupBlueCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupGreenCheckbox, $GUI_CHECKED)
            GUICtrlSetState($GUIPickupWhiteCheckbox, $GUI_CHECKED)
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

        Case $GUISalvageGoldCheckbox
            If GUICtrlRead($GUISalvageGoldCheckbox) = $GUI_CHECKED Then
                Out("Salvage Gold items enabled")
            Else
                Out("Salvage Gold items disabled")
            EndIf

        Case $GUISalvagePurpleCheckbox
            If GUICtrlRead($GUISalvagePurpleCheckbox) = $GUI_CHECKED Then
                Out("Salvage Purple items enabled")
            Else
                Out("Salvage Purple items disabled")
            EndIf

        Case $GUISalvageBlueCheckbox
            If GUICtrlRead($GUISalvageBlueCheckbox) = $GUI_CHECKED Then
                Out("Salvage Blue items enabled")
            Else
                Out("Salvage Blue items disabled")
            EndIf

        Case $GUISalvageGreenCheckbox
            If GUICtrlRead($GUISalvageGreenCheckbox) = $GUI_CHECKED Then
                Out("Salvage Green items enabled")
            Else
                Out("Salvage Green items disabled")
            EndIf

        Case $GUISalvageWhiteCheckbox
            If GUICtrlRead($GUISalvageWhiteCheckbox) = $GUI_CHECKED Then
                Out("Salvage White items enabled")
            Else
                Out("Salvage White items disabled")
            EndIf

        Case $GUISalvageMaterialsCheckbox
            If GUICtrlRead($GUISalvageMaterialsCheckbox) = $GUI_CHECKED Then
                Out("Salvage Materials pickup enabled")
            Else
                Out("Salvage Materials pickup disabled")
            EndIf

        Case $GUISalvageDyesCheckbox
            If GUICtrlRead($GUISalvageDyesCheckbox) = $GUI_CHECKED Then
                Out("Salvage Dyes pickup enabled")
            Else
                Out("Salvage Dyes pickup disabled")
            EndIf

        Case $GUISalvageKeysCheckbox
            If GUICtrlRead($GUISalvageKeysCheckbox) = $GUI_CHECKED Then
                Out("Salvage Keys pickup enabled")
            Else
                Out("Salvage Keys pickup disabled")
            EndIf

        Case $GUISalvageScrollsCheckbox
            If GUICtrlRead($GUISalvageScrollsCheckbox) = $GUI_CHECKED Then
                Out("Salvage Scrolls pickup enabled")
            Else
                Out("Salvage Scrolls pickup disabled")
            EndIf

        Case $GUISalvageConsumablesCheckbox
            If GUICtrlRead($GUISalvageConsumablesCheckbox) = $GUI_CHECKED Then
                Out("Salvage Consumables pickup enabled")
            Else
                Out("Salvage Consumables pickup disabled")
            EndIf

        Case $GUISalvageSwordsCheckbox
            If GUICtrlRead($GUISalvageSwordsCheckbox) = $GUI_CHECKED Then
                Out("Salvage Swords pickup enabled")
            Else
                Out("Salvage Swords pickup disabled")
            EndIf

        Case $GUISalvageAxesCheckbox
            If GUICtrlRead($GUISalvageAxesCheckbox) = $GUI_CHECKED Then
                Out("Salvage Axes pickup enabled")
            Else
                Out("Salvage Axes pickup disabled")
            EndIf

        Case $GUISalvageHammersCheckbox
            If GUICtrlRead($GUISalvageHammersCheckbox) = $GUI_CHECKED Then
                Out("Salvage Hammers pickup enabled")
            Else
                Out("Salvage Hammers pickup disabled")
            EndIf

        Case $GUISalvageDaggersCheckbox
            If GUICtrlRead($GUISalvageDaggersCheckbox) = $GUI_CHECKED Then
                Out("Salvage Daggers pickup enabled")
            Else
                Out("Salvage Daggers pickup disabled")
            EndIf

        Case $GUISalvageScythesCheckbox
            If GUICtrlRead($GUISalvageScythesCheckbox) = $GUI_CHECKED Then
                Out("Salvage Scythes pickup enabled")
            Else
                Out("Salvage Scythes pickup disabled")
            EndIf

        Case $GUISalvageBowsCheckbox
            If GUICtrlRead($GUISalvageBowsCheckbox) = $GUI_CHECKED Then
                Out("Salvage Bows pickup enabled")
            Else
                Out("Salvage Bows pickup disabled")
            EndIf

        Case $GUISalvageWandsCheckbox
            If GUICtrlRead($GUISalvageWandsCheckbox) = $GUI_CHECKED Then
                Out("Salvage Wands pickup enabled")
            Else
                Out("Salvage Wands pickup disabled")
            EndIf

        Case $GUISalvageStavesCheckbox
            If GUICtrlRead($GUISalvageStavesCheckbox) = $GUI_CHECKED Then
                Out("Salvage Staves pickup enabled")
            Else
                Out("Salvage Staves pickup disabled")
            EndIf

        Case $GUISalvageShieldsCheckbox
            If GUICtrlRead($GUISalvageShieldsCheckbox) = $GUI_CHECKED Then
                Out("Salvage Shields pickup enabled")
            Else
                Out("Salvage Shields pickup disabled")
            EndIf

        Case $GUISalvageFocusItemsCheckbox
            If GUICtrlRead($GUISalvageFocusItemsCheckbox) = $GUI_CHECKED Then
                Out("Salvage Focus items pickup enabled")
            Else
                Out("Salvage Focus items pickup disabled")
            EndIf

        Case $GUISalvageArmorCheckbox
            If GUICtrlRead($GUISalvageArmorCheckbox) = $GUI_CHECKED Then
                Out("Salvage Armor pickup enabled")
            Else
                Out("Salvage Armor pickup disabled")
            EndIf

        Case $GUISalvageRunesCheckbox
            If GUICtrlRead($GUISalvageRunesCheckbox) = $GUI_CHECKED Then
                Out("Salvage Runes pickup enabled")
            Else
                Out("Salvage Runes pickup disabled")
            EndIf

        Case $GUISalvageInsigniasCheckbox
            If GUICtrlRead($GUISalvageInsigniasCheckbox) = $GUI_CHECKED Then
                Out("Salvage Insignias pickup enabled")
            Else
                Out("Salvage Insignias pickup disabled")
            EndIf

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

Func Out($TEXT)
    Local $TIME = "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] - "
    Local $TEXTLEN = StringLen($TEXT)
    Local $CONSOLELEN = _GUICtrlEdit_GetTextLen($GUIActionsEditExtended)
    If $TEXTLEN + $CONSOLELEN > 30000 Then GUICtrlSetData($GUIActionsEditExtended, StringRight(_GUICtrlEdit_GetText($GUIActionsEditExtended), 30000 - $TEXTLEN - 1000))
    _GUICtrlEdit_AppendText($GUIActionsEditExtended, @CRLF & $TIME & $TEXT)
    _GUICtrlEdit_Scroll($GUIActionsEditExtended, 1)
EndFunc

; Log to Extra tab
Func OutExtra($TEXT)
    Local $TIME = "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] - "
    Local $TEXTLEN = StringLen($TEXT)
    Local $CONSOLELEN = _GUICtrlEdit_GetTextLen($GUIExtraEdit)
    If $TEXTLEN + $CONSOLELEN > 30000 Then GUICtrlSetData($GUIExtraEdit, StringRight(_GUICtrlEdit_GetText($GUIExtraEdit), 30000 - $TEXTLEN - 1000))
    _GUICtrlEdit_AppendText($GUIExtraEdit, @CRLF & $TIME & $TEXT)
    _GUICtrlEdit_Scroll($GUIExtraEdit, 1)
    UpdateExtraStatisticsDisplay()
EndFunc

Func UpdateExtraStatisticsDisplay()
    ; Always update coordinates, even if bot is not initialized
    Local $currentX = 0
    Local $currentY = 0
    
    If $BotInitialized Then
        $currentX = Round(X(-2))
        $currentY = Round(Y(-2))
    EndIf
    
    GUICtrlSetData($ExtraStatCoordsLabel, "Coords: (" & $currentX & ", " & $currentY & ")")
    
    ; Only update other stats if bot is initialized
    If $BotInitialized Then
        GUICtrlSetData($ExtraStatDeathsLabel, "Deaths: " & $Stat_Deaths)
        GUICtrlSetData($ExtraStatTotalRunsLabel, "Total Runs: " & $Stat_TotalRuns)
        GUICtrlSetData($ExtraStatTotalRunTimeLabel, "Total Run Time: " & $Stat_TotalRunTime & "s")
        GUICtrlSetData($ExtraStatAvgRunTimeLabel, "Avg Run Time: " & $Stat_AvgRunTime & "s")
        GUICtrlSetData($ExtraStatGoldsLabel, "Golds picked up: " & $Stat_Golds)
        GUICtrlSetData($ExtraStatPurplesLabel, "Purples picked up: " & $Stat_Purples)
        GUICtrlSetData($ExtraStatBluesLabel, "Blues picked up: " & $Stat_Blues)
        GUICtrlSetData($ExtraStatWhitesLabel, "Whites picked up: " & $Stat_Whites)
        GUICtrlSetData($ExtraStatLuxonFactionLabel, "Luxon Faction: " & $Stat_LuxonFaction & " / " & $Stat_LuxonFactionMax)
        GUICtrlSetData($ExtraStatLuxonDonatedLabel, "Luxon Donated: " & $Stat_LuxonDonated)
        GUICtrlSetData($ExtraStatCurrentGoldLabel, "Current Gold: " & $Stat_CurrentGold)
        GUICtrlSetData($ExtraStatGoldPickedUpLabel, "Gold Picked Up: " & $Stat_GoldPickedUp)
    EndIf
EndFunc

Func _Exit()
    Exit
EndFunc

; Utility function: Min of two values
Func Min($a, $b)
    If $a < $b Then
        Return $a
    Else
        Return $b
    EndIf
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
    Local $stepSize = 2500 ; units per step for smooth movement
    Local $lastMoveToX = $aX
    Local $lastMoveToY = $aY
    Local $currentTargetID = 0 ; Track current target to prevent spamming
    ; Log the action
    If $aDescription <> "" Then
        Out("Moving to kill: " & $aDescription & " at (" & $aX & ", " & $aY & ")")
    Else
        Out("Moving to kill enemies at (" & $aX & ", " & $aY & ")")
    EndIf

    ; Smooth movement loop: move in small steps, check for enemies after each step
    While Not $lDestinationReached
        If GetIsDead($lMe) Then
            Out("Player is dead, stopping combat")
            OutExtra("Character died at (" & X(-2) & ", " & Y(-2) & ") while moving to (" & $lastMoveToX & ", " & $lastMoveToY & ")")
            Return False
        EndIf
        Local $curX = X(-2)
        Local $curY = Y(-2)
        Local $dist = GetDistanceToXY($aX, $aY, -2)
        If $dist < 100 Then
            $lDestinationReached = True
            ExitLoop
        EndIf
        ; Check for enemies in range
        $lEnemyCount = GetNumberOfEnemiesNearAgent(-2, $aRange)
        If $lEnemyCount > 0 Then
            ExitLoop ; Break movement and start combat immediately
        EndIf
        ; Calculate direction and move a small step
        Local $dx = $aX - $curX
        Local $dy = $aY - $curY
        Local $len = Sqrt($dx * $dx + $dy * $dy)
        If $len = 0 Then
            $lDestinationReached = True
            ExitLoop
        EndIf
        Local $stepX = $curX + ($dx / $len) * Min($stepSize, $len)
        Local $stepY = $curY + ($dy / $len) * Min($stepSize, $len)
        MoveTo($stepX, $stepY, 50)
        ; Update coordinates in real-time during movement
        UpdateExtraStatisticsDisplay()
        ; No unnecessary sleep, keep movement smooth
    WEnd

    ; Main movement and combat loop
    Do
        If GetIsDead($lMe) Then
            Out("Player is dead, stopping combat")
            OutExtra("Character died at (" & X(-2) & ", " & Y(-2) & ") while moving to (" & $lastMoveToX & ", " & $lastMoveToY & ")")
            Return False
        EndIf
        If GetDistanceToXY($aX, $aY, $lMe) < 100 Then
            $lDestinationReached = True
        EndIf
        $lEnemyCount = GetNumberOfEnemiesNearAgent(-2, $aRange)
        If $lEnemyCount > 0 Then
            If Not $lInCombat Then
                Out("Found " & $lEnemyCount & " enemies, engaging combat immediately!")
                $lInCombat = True
            EndIf
            ; Combat loop for current enemies - NO TIMEOUT, fight until all enemies are dead
            Do
                If GetIsDead($lMe) Then
                    Out("Player is dead during combat")
                    OutExtra("Character died at (" & X(-2) & ", " & Y(-2) & ") while moving to (" & $lastMoveToX & ", " & $lastMoveToY & ")")
                    Return False
                EndIf
                $lEnemyCount = GetNumberOfEnemiesNearAgent(-2, $aRange)
                If $lEnemyCount = 0 Then
                    Out("Combat complete, continuing movement to target")
                    $lInCombat = False
                    ExitLoop
                EndIf
                $lTarget = GetNearestEnemyPtrToAgent(-2)
                If $lTarget <> 0 And Not GetIsDead($lTarget) Then
                    Local $targetID = ID($lTarget)
                    ; Only change target and attack if this is a new target
                    If $targetID <> $currentTargetID Then
                        ChangeTarget($lTarget)
                        Attack($lTarget, True)
                        $currentTargetID = $targetID
                        Out("Switched to new target: " & GetPlayerName($lTarget))
                    EndIf
                    ; Only use skills if within spell range
                    If GetDistance($lTarget, -2) <= $RANGE_SPELLCAST Then
                        UseSkillsWithPriorityAndCustomOrder($lTarget)
                    EndIf
                EndIf
                ; Update coordinates during combat
                UpdateExtraStatisticsDisplay()
            Until False
            PickUpLoot()
            Out("Checking for dead party members after combat...")
            CheckAndResurrectPartyMembers()
            ; After combat, resume smooth movement if not at destination
            If Not $lDestinationReached Then
                While Not $lDestinationReached
                    If GetIsDead($lMe) Then
                        Out("Player is dead, stopping combat")
                        OutExtra("Character died at (" & X(-2) & ", " & Y(-2) & ") while moving to (" & $lastMoveToX & ", " & $lastMoveToY & ")")
                        Return False
                    EndIf
                    Local $curX = X(-2)
                    Local $curY = Y(-2)
                    Local $dist = GetDistanceToXY($aX, $aY, -2)
                    If $dist < 100 Then
                        $lDestinationReached = True
                        ExitLoop
                    EndIf
                    $lEnemyCount = GetNumberOfEnemiesNearAgent(-2, $aRange)
                    If $lEnemyCount > 0 Then
                        ExitLoop ; Break movement and start combat again
                    EndIf
                    Local $dx = $aX - $curX
                    Local $dy = $aY - $curY
                    Local $len = Sqrt($dx * $dx + $dy * $dy)
                    If $len = 0 Then
                        $lDestinationReached = True
                        ExitLoop
                    EndIf
                    Local $stepX = $curX + ($dx / $len) * Min($stepSize, $len)
                    Local $stepY = $curY + ($dy / $len) * Min($stepSize, $len)
                    MoveTo($stepX, $stepY, 50)
                WEnd
            EndIf
        Else
            If Not $lDestinationReached Then
                If Not $lInCombat Then
                    Local $curX = X(-2)
                    Local $curY = Y(-2)
                    Local $dist = GetDistanceToXY($aX, $aY, -2)
                    If $dist < 100 Then
                        $lDestinationReached = True
                    Else
                        Local $dx = $aX - $curX
                        Local $dy = $aY - $curY
                        Local $len = Sqrt($dx * $dx + $dy * $dy)
                        If $len > 0 Then
                            Local $stepX = $curX + ($dx / $len) * Min($stepSize, $len)
                            Local $stepY = $curY + ($dy / $len) * Min($stepSize, $len)
                            MoveTo($stepX, $stepY, 50)
                        EndIf
                    EndIf
                EndIf
            EndIf
        EndIf
        If TimerDiff($lDeadlock) > 60000 Then
            Out("Movement timeout reached")
            Return False
        EndIf
    Until $lDestinationReached
    Out("Reached destination at (" & $aX & ", " & $aY & ")")
    Out("🎮 " & GetRandomGameJoke())
    $Stat_LuxonFaction = GetLuxonFaction()
    $Stat_LuxonFactionMax = GetMaxLuxonFaction()
    $Stat_CurrentGold = GetGoldCharacter()
    UpdateStatisticsDisplay()
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
		[12500, -3500, 'Naga 8'], _
		[14000, -6000, 'Outcast Warrior Boss'], _
		[13000, -6000, 'Leftovers'] _
	]
	
	; Define ranges for each location (most use default, some use spirit range)
	Local $ranges[] = [$RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT, $RANGE_SPIRIT]
	
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
	; Set flag to continue the loop
	$ReadyToStartRun = True
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
        ; No skills available, just return (main loop handles attacking)
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
        UseSkillEx($skillSlot, $lTarget, 3000, false)
        HighlightSkillLabel($skillSlot)
        RndSleep(200)
        $CurrentCustomSkillIndex += 1
        If $CurrentCustomSkillIndex >= $CustomFightingCount Then
            $CurrentCustomSkillIndex = 0 ; Reset to beginning
        EndIf
    Else
        $CurrentCustomSkillIndex += 1
        If $CurrentCustomSkillIndex >= $CustomFightingCount Then
            $CurrentCustomSkillIndex = 0 ; Reset to beginning
        EndIf
    EndIf
    ; Main combat loop handles attacking, no need to call Attack here
EndFunc

Func UsePrioritySkills($lTarget)
    ; First, try to use priority skills
    For $i = 1 To 8
        Local $skillEnabled = GUICtrlRead($SkillCheckboxes[$i-1]) = $GUI_CHECKED
        Local $skillPriority = GUICtrlRead($SkillPriorityCheckboxes[$i-1]) = $GUI_CHECKED
        Local $skillRecharged = IsRecharged($i)
        Local $skillEnergy = GetEnergy(-2)
        Local $skillEnergyReq = GetEnergyReq(GetSkillbarSkillID($i))
        If $skillPriority And $skillEnabled And $skillRecharged And $skillEnergy >= $skillEnergyReq Then
            UseSkillEx($i, $lTarget, 3000, True)
            HighlightSkillLabel($i)
            RndSleep(200)
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
        If $skillEnabled And Not $skillPriority And $skillRecharged And $skillEnergy >= $skillEnergyReq Then
            UseSkillEx($i, $lTarget, 3000, True)
            HighlightSkillLabel($i)
            RndSleep(200)
            Return ; Exit after using one skill
        EndIf
    Next
    ; If no skills are available, main combat loop handles attacking
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
		OutExtra("Team is dead at (" & X(-2) & ", " & Y(-2) & ") waiting for resurrection. Last move target: (" & $lastMoveToX & ", " & $lastMoveToY & ")")
		
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

Func UpdateStatisticsDisplay()
    GUICtrlSetData($StatDeathsLabel, "Deaths: " & $Stat_Deaths)
    GUICtrlSetData($StatTotalRunsLabel, "Total Runs: " & $Stat_TotalRuns)
    GUICtrlSetData($StatTotalRunTimeLabel, "Total Run Time: " & $Stat_TotalRunTime & "s")
    GUICtrlSetData($StatAvgRunTimeLabel, "Avg Run Time: " & $Stat_AvgRunTime & "s")
    GUICtrlSetData($StatGoldsLabel, "Golds picked up: " & $Stat_Golds)
    GUICtrlSetData($StatPurplesLabel, "Purples picked up: " & $Stat_Purples)
    GUICtrlSetData($StatBluesLabel, "Blues picked up: " & $Stat_Blues)
    GUICtrlSetData($StatWhitesLabel, "Whites picked up: " & $Stat_Whites)
    GUICtrlSetData($StatLuxonFactionLabel, "Luxon Faction: " & $Stat_LuxonFaction & " / " & $Stat_LuxonFactionMax)
    GUICtrlSetData($StatLuxonDonatedLabel, "Luxon Donated: " & $Stat_LuxonDonated)
    GUICtrlSetData($StatCurrentGoldLabel, "Current Gold: " & $Stat_CurrentGold)
    GUICtrlSetData($StatGoldPickedUpLabel, "Gold Picked Up: " & $Stat_GoldPickedUp)
    UpdateExtraStatisticsDisplay()
EndFunc

; Helper to highlight a skill label when used
Func HighlightSkillLabel($slot)
    GUICtrlSetBkColor($SkillLabels[$slot-1], 0xFFFF00) ; Yellow
    AdlibRegister("_UnhighlightSkillLabel" & $slot, 200)
EndFunc

Func _UnhighlightSkillLabel1()
    GUICtrlSetBkColor($SkillLabels[0], 0xCCCCCC)
    AdlibUnRegister("_UnhighlightSkillLabel1")
EndFunc
Func _UnhighlightSkillLabel2()
    GUICtrlSetBkColor($SkillLabels[1], 0xCCCCCC)
    AdlibUnRegister("_UnhighlightSkillLabel2")
EndFunc
Func _UnhighlightSkillLabel3()
    GUICtrlSetBkColor($SkillLabels[2], 0xCCCCCC)
    AdlibUnRegister("_UnhighlightSkillLabel3")
EndFunc
Func _UnhighlightSkillLabel4()
    GUICtrlSetBkColor($SkillLabels[3], 0xCCCCCC)
    AdlibUnRegister("_UnhighlightSkillLabel4")
EndFunc
Func _UnhighlightSkillLabel5()
    GUICtrlSetBkColor($SkillLabels[4], 0xCCCCCC)
    AdlibUnRegister("_UnhighlightSkillLabel5")
EndFunc
Func _UnhighlightSkillLabel6()
    GUICtrlSetBkColor($SkillLabels[5], 0xCCCCCC)
    AdlibUnRegister("_UnhighlightSkillLabel6")
EndFunc
Func _UnhighlightSkillLabel7()
    GUICtrlSetBkColor($SkillLabels[6], 0xCCCCCC)
    AdlibUnRegister("_UnhighlightSkillLabel7")
EndFunc
Func _UnhighlightSkillLabel8()
    GUICtrlSetBkColor($SkillLabels[7], 0xCCCCCC)
    AdlibUnRegister("_UnhighlightSkillLabel8")
EndFunc

