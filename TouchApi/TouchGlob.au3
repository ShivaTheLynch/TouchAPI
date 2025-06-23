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