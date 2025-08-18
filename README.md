# GwAu3 - Guild Wars AutoIt3 API ⚔️

A comprehensive **AutoIt3 API** for automating and controlling **Guild Wars**.

---

## 🧩 TouchAPI Integration

**TouchAPI** is an optional companion layer that **supercharges GwAu3** with robust orchestration, quality-of-life automation, and advanced combat/loot frameworks.  
It sits “above” the base API, coordinating your bots while GwAu3 handles the low-level Guild Wars interface.

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
- Bag routing (materials, ID’d gear, salvaged parts) and merchant/salvage cycles  
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

## 📋 Description

**GwAu3** is an AutoIt3 library that provides a programming interface to interact with the Guild Wars game.  
It allows you to create bots, assistance tools, and automation applications for Guild Wars.

---

## ✨ Features

### 🔧 Core
- Initialization: connect to Guild Wars process  
- Memory: read/write game memory  
- Scanner: pattern search in memory  
- Updates: automatic update system from GitHub  

### 💬 Commands
- Agent: targeting, interaction with NPCs and players  
- Attributes: attribute points management  
- Chat: send messages, whispers  
- Friend: friend list and status management  
- Party: party and heroes management  
- Inventory: item manipulation  
- Map: movement and travel  
- Skills: skill usage  
- Trade: buy/sell with merchants  
- ...  

### 📦 Data
- Agent: game entity information  
- Guild: guild data  
- Inventory: inventory management  
- Map: map information  
- Party: party composition and states  
- Quest: quest tracking  
- Skill: skills database  
- ...  

---

## 🚀 Installation

1. **Prerequisites**
   - AutoIt3 v3.3.16.1 or higher (**32-bit**)  
   - Guild Wars installed  
   - Windows 7 / 8 / 10 / 11  

2. **Steps**
   ```text
   1. Download the project
   2. Ensure all files are in the same folder
   3. Launch Guild Wars
   4. Run your AutoIt3 script
