🧩 TouchAPI Integration

TouchAPI is an optional companion layer that supercharges GwAu3 with robust orchestration, quality-of-life automation, and battle/loot frameworks. It’s designed to sit “above” the base API, coordinating your bots while GwAu3 handles the low-level Guild Wars interface.

What TouchAPI Adds

Auto Start & Auto Restart

Launch one or many bots with predefined profiles.

Watchdog service that restarts a bot after crashes, map load failures, DCs, or stuck conditions.

Optional staggered starts to reduce login spikes and minimize rate-limit issues.

Session & Crash Recovery

Detects character stuck states (no progress in X seconds, pathing loops) and triggers soft resets.

Auto re-log, auto re-zone, and optional “return to safe outpost” routines.

Enhanced Combat Framework

Priority-based target selection (by profession, threat, distance, condition).

Skill rotation helpers with cooldown tracking and conditional gating (energy, hex/condition presence, party HP).

Interrupt/disable windows and kiting behaviors for dangerous skills or AoE.

Smart Looting & Inventory

Filter-driven auto-loot with rarity, type, and value thresholds.

Bag routing (materials, ID’d gear, salvaged parts) and optional merchant/salvage cycles.

Anti-clutter routines (ID → salvage → sell) with configurable safety rules.

Scheduling & Profiles

Per-character or per-role JSON/INI profiles (build, route, loot filters, merchants).

Time-based schedule (farm A in the morning, farm B in the evening).

Rotations across characters or accounts to spread risk and diversify income.

Multi-Instance Orchestration

Coordinate multiple Guild Wars instances (separate PIDs), with per-instance throttle controls.

Party leader/follower roles, ready checks, and synchronized zone transitions.

Telemetry & Logging

Structured logs (action, zone, drops, runtime) for post-run analytics.

Optional CSV export of runs and loot summaries.

Extensible Hooks

Pre/Post hooks for map load, party form, fight start/end, loot, and vendor trips.

Simple plugin surface so you can inject custom logic without touching core loops.

# GwAu3 - Guild Wars AutoIt3 API

A comprehensive AutoIt3 API for automating and controlling Guild Wars.

## 📋 Description

GwAu3 is an AutoIt3 library that provides a programming interface to interact with the Guild Wars game. It allows you to create bots, assistance tools, and automation applications for Guild Wars.

## ✨ Features

### Core
- **Initialization**: Connection to Guild Wars process
- **Memory**: Read/write game memory
- **Scanner**: Pattern search in memory
- **Updates**: Automatic update system from GitHub

### Commands
- **Agent**: Targeting, interaction with NPCs and players
- **Attributes**: Attribute points management
- **Chat**: Send messages, whispers
- **Friend**: Friend list and status management
- **Party**: Party and heroes management
- **Inventory**: Item manipulation
- **Map**: Movement and travel
- **Skills**: Skill usage
- **Trade**: Buy/sell with merchants
- ...

### Data
- **Agent**: Game entity information
- **Guild**: Guild data
- **Inventory**: Inventory management
- **Map**: Map information
- **Party**: Party composition and states
- **Quest**: Quest tracking
- **Skill**: Skills database
- ...

## 🚀 Installation

1. **Prerequisites**
   - AutoIt3 v3.3.16.1 or higher (32-bit)
   - Guild Wars installed
   - Windows 7/8/10/11

2. **Installation**
   ```
   1. Download the project
   2. Ensure all files are in the same folder
   3. Launch Guild Wars
   4. Run your AutoIt3 script
   ```

## 💻 Usage

### Basic Example

```autoit
#include "Core.au3"

; Initialize with character name
Core_Initialize("Character Name")

; Or initialize with process PID
; Core_Initialize($ProcessID)

; Usage examples
Local $l_i_MyID = Agent_GetMyID()
Local $l_s_CharName = Player_GetCharname()
Local $l_i_MapID = Map_GetCharacterInfo("MapID")

; Movement
Map_Move(1000, -500)

; Targeting
Agent_ChangeTarget($TargetID)

; Use a skill
Skill_UseSkill(1) ; Uses skill 1
```

## 📚 Module Documentation
📖 [AutoIt Naming Convention Documentation](GwAu3/Constants/README.md)
### Core
- `Core_Initialize($CharacterName)` : Initialize connection
- `Core_SendPacket(...)` : Send packets to server
- `Core_Enqueue(...)` : Queue commands

### Agent
- `Agent_GetMyID()` : Returns your character's ID
- `Agent_ChangeTarget($AgentID)` : Target an agent
- `Agent_GetAgentInfo($AgentID, $Info)` : Get agent information

### Map
- `Map_Move($X, $Y)` : Move character
- `Map_TravelTo($MapID)` : Travel to a zone
- `Map_GetCharacterInfo($Info)` : Current zone information

### Inventory
- `Item_UseItem($Item)` : Use an item
- `Item_MoveItem($Item, $Bag, $Slot)` : Move an item
- `Item_GetBagInfo($BagNumber, $Info)` : Bag information

### Skills
- `Skill_UseSkill($SkillSlot)` : Use a skill
- `Skill_GetSkillInfo($SkillID, $Info)` : Skill information

## ⚙️ Configuration

### Automatic Updates

The `config.ini` file in GwAu3\GwAu3\Core allows you to configure automatic updates:

```ini
[Update]
Enabled=1      ;0 = Disable Automatic Updates
Verbose=1      ;0 = Silently update and delete, no prompts (Use at your own risk)
Owner=JAG-GW
Repo=GwAu3
Branch=main
```

## ⚠️ Warnings

- **Use at your own risk**: Using bots may violate Guild Wars Terms of Service
- **32-bit mode required**: AutoIt3 must be run in 32-bit (x86) mode
- **Antivirus**: Some antivirus software may detect scripts as potential threats

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest new features
- Improve documentation

## 📄 License
This project is licensed under the [MIT License](LICENSE) - see the LICENSE file for details.

## 🙏 Acknowledgments

- Guild Wars community
- AutoIt3 developers
- All project contributors
