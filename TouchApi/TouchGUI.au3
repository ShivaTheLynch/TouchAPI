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
