# GwAu3 - Guild Wars AutoIt3 API ⚔️

A comprehensive **AutoIt3 API** for automating and controlling **Guild Wars**, featuring advanced farming bots with robust disconnect detection, stuck prevention, and auto-start capabilities.

---

## 🚀 Quick Start

### Prerequisites
- **AutoIt3 v3.3.16.1+** (32-bit required)
- **Guild Wars** installed and updated
- **Windows 7/8/10/11**

### Installation
1. Download the project
2. Ensure all files are in the same folder
3. Launch Guild Wars
4. Run your AutoIt3 script

---

## 🧩 TouchAPI Integration

**TouchAPI** is an optional companion layer that **supercharges GwAu3** with robust orchestration, quality-of-life automation, and advanced combat/loot frameworks.  
It sits "above" the base API, coordinating your bots while GwAu3 handles the low-level Guild Wars interface.

### 🚀 What TouchAPI Adds

#### 🔄 Auto Start & Auto Restart
- Launch one or many bots with predefined profiles  
- Watchdog service that restarts a bot after crashes, map load failures, disconnects, or stuck conditions  
- Optional staggered starts to reduce login spikes and minimize rate-limit issues  

#### 🛡️ Session & Crash Recovery
- Detects stuck states (no progress, pathing loops) and triggers soft resets  
- Auto re-log, auto re-zone, and optional **return to safe outpost** routines  

#### ⚔️ Enhanced Combat Framework
- Priority-based target selection (by profession, threat, distance, condition)  
- Skill rotation helpers with cooldown tracking and conditional gating  
- Interrupt/disable windows and kiting for dangerous skills or AoE  

#### 💰 Smart Looting & Inventory
- Filter-driven auto-loot with rarity, type, and value thresholds  
- Bag routing (materials, ID'd gear, salvaged parts) and merchant/salvage cycles  
- Anti-clutter routines (ID → salvage → sell) with configurable safety rules  

#### 📅 Scheduling & Profiles
- Per-character or per-role JSON/INI profiles (build, route, loot filters, merchants)  
- Time-based schedules (farm A in the morning, farm B in the evening)  
- Account/character rotations to spread risk and diversify income  

#### 👥 Multi-Instance Orchestration
- Coordinate multiple Guild Wars instances (separate PIDs)  
- Party leader/follower roles, ready checks, and synchronized zone transitions  

#### 📊 Telemetry & Logging
- Structured logs (action, zone, drops, runtime) for post-run analytics  
- Optional CSV export of runs and loot summaries  

#### 🧩 Extensible Hooks
- Pre/Post hooks for map load, party form, fight start/end, loot, and vendor trips  
- Simple plugin surface to inject custom logic without touching core loops  

---

## 🎯 Farming Bots

### 🌟 Luxon Farm Bot (`Farm_MountQinkai.au3`)
**Location**: Mount Qinkai  
**Purpose**: Farm Luxon faction points efficiently  
**Features**:
- Comprehensive disconnect detection (8-second tolerance)
- Stuck character detection and auto-restart
- Auto-start with command line character selection
- Smart inventory management and merchant cycles
- Route optimization for maximum efficiency

### 🌟 Kurzick Farm Bot (`Farm_DrazachThicket.au3`)
**Location**: Drazach Thicket  
**Purpose**: Farm Kurzick faction points efficiently  
**Features**:
- Same robust disconnect detection as Luxon bot
- Stuck character detection and auto-restart
- Auto-start with command line character selection
- Comprehensive safety features and error handling
- Optimized farming routes and combat logic

---

## 🛡️ Safety Features

### 🔌 Disconnect Detection
- **Smart Detection**: Waits 8 seconds total to avoid false positives during map loading
- **Auto-Recovery**: Automatically closes Guild Wars and exits script on confirmed disconnect
- **Map Loading Tolerance**: Won't trigger during normal zone transitions

### 🚫 Stuck Prevention
- **Position Monitoring**: Tracks character movement every 30 seconds
- **Auto-Restart**: Restarts client if character is stuck for 10+ minutes
- **Path Recovery**: Attempts to unstuck character before restarting

### 🚀 Auto-Start Functionality
- **Command Line**: Launch with `-character "CharacterName"`
- **GUI Integration**: Automatically sets character in GUI
- **Enter Key Press**: Automatically presses Enter on character selection screen
- **Full Automation**: Bot starts running immediately after character selection

---

## 📋 Core Features

### 🔧 Core Functions
- **Initialization**: Connect to Guild Wars process
- **Memory Management**: Read/write game memory safely
- **Scanner**: Pattern search in memory
- **Updates**: Automatic update system from GitHub

### 💬 Game Interaction
- **Agent Management**: Targeting, interaction with NPCs and players
- **Attributes**: Attribute points management
- **Chat System**: Send messages, whispers
- **Friend System**: Friend list and status management
- **Party Management**: Party and heroes management
- **Inventory**: Item manipulation and management
- **Map System**: Movement and travel
- **Skills**: Skill usage and management
- **Trade System**: Buy/sell with merchants

### 📦 Data Management
- **Agent Information**: Game entity information
- **Guild Data**: Guild management
- **Inventory System**: Comprehensive inventory management
- **Map Information**: Zone and location data
- **Party Composition**: Party states and management
- **Quest Tracking**: Quest progress monitoring
- **Skill Database**: Skills information and usage

---

## 📚 Module Documentation

### 🔹 Core Functions
```autoit
Core_Initialize($CharacterName)     → Initialize connection
Core_SendPacket(...)               → Send packets to server
Core_Enqueue(...)                  → Queue commands
```

### 🔹 Agent Management
```autoit
Agent_GetMyID()                    → Returns your character's ID
Agent_ChangeTarget($AgentID)       → Target an agent
Agent_GetAgentInfo($AgentID, $Info) → Get agent information
```

### 🔹 Map & Movement
```autoit
Map_Move($X, $Y)                   → Move character
Map_TravelTo($MapID)               → Travel to a zone
Map_GetCharacterInfo($Info)        → Current zone information
```

### 🔹 Inventory Management
```autoit
Item_UseItem($Item)                → Use an item
Item_MoveItem($Item, $Bag, $Slot) → Move an item
Item_GetBagInfo($BagNumber, $Info) → Bag information
```

### 🔹 Skill System
```autoit
Skill_UseSkill($SkillSlot)         → Use a skill
Skill_GetSkillInfo($SkillID, $Info) → Skill information
```

---

## ⚙️ Configuration

### 🔄 Automatic Updates (GwAu3)
**Path**: `GwAu3\GwAu3\Core\config.ini`

```ini
[Update]
Enabled=1
Verbose=1
Owner=JAG-GW
Repo=GwAu3
Branch=main
```

### 🎮 Bot Configuration
- **Character Selection**: Set via command line or GUI
- **Safety Settings**: Adjustable disconnect and stuck detection timers
- **Farming Routes**: Configurable farming paths and priorities
- **Inventory Rules**: Customizable loot filters and merchant settings

---

## 🚨 Usage Examples

### 🌟 Start Luxon Farm Bot
```bash
Farm_MountQinkai.au3 -character "YourCharacterName"
```

### 🌟 Start Kurzick Farm Bot
```bash
Farm_DrazachThicket.au3 -character "YourCharacterName"
```

### 🔧 Manual Start
1. Launch Guild Wars
2. Run the bot script
3. Select character from GUI
4. Click "Start" button

---

## ⚠️ Important Warnings

### 🚨 Terms of Service
- **Use at your own risk**: Bots may violate Guild Wars Terms of Service
- **Account Safety**: Use on secondary accounts to minimize risk
- **Responsibility**: Users are responsible for compliance with game rules

### 🔧 Technical Requirements
- **32-bit mode required**: AutoIt3 must be run in 32-bit (x86) mode
- **Antivirus**: Some antivirus software may detect scripts as potential threats
- **Windows Only**: Currently only supports Windows operating systems

---

## 🤝 Contributing

Contributions are welcome! 🎉

### How to Contribute
- **Report bugs** 🐞
- **Suggest new features** 💡
- **Improve documentation** 📖
- **Submit pull requests** 🔄
- **Share farming strategies** 🎯

### Development Guidelines
- Follow AutoIt3 coding standards
- Test thoroughly before submitting
- Document new features clearly
- Maintain backward compatibility

---

## 📄 License

This project is licensed under the **MIT License** – see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments & Credits

### 🎮 Guild Wars Community
- **Guild Wars community** ❤️ for inspiration and support
- **AutoIt3 developers** 🔧 for the powerful scripting platform

### 🚀 Project Contributors
- **Greg, Kleutschi, Glob of Armbraces** 🎉 for their bot logic and enhanced combat/looting ideas
- **BubbleTea** 🌟 for creating the bots i used as my base.
- **All project contributors** 🌍 for their valuable contributions
- **Touchwise** 🌍 For creating TouchAPI

### 📚 Special Thanks
- **TouchAPI concept** for advanced automation frameworks
- **Farming community** for route optimization and efficiency tips
- **Testing community** for bug reports and feature suggestions

---

## 📞 Support & Community

### 🆘 Getting Help
- **GitHub Issues**: Report bugs and request features
- **Discussions**: Join community discussions
- **Wiki**: Check the project wiki for detailed guides

### 🌐 Community Links
- **Discord**: https://discord.gg/Ah3SufA5VH

---

## 🔄 Version History

### v2.0.0 (Current)
- ✅ Enhanced disconnect detection (8-second tolerance)
- ✅ Stuck character detection and auto-restart
- ✅ Auto-start functionality with command line support
- ✅ Comprehensive safety features
- ✅ Both Luxon and Kurzick farm bots

### v1.0.0
- ✅ Basic GwAu3 API implementation
- ✅ Core farming functionality
- ✅ Basic safety features

---

*Made with ❤️ for the Guild Wars community*
