# WoW TBC Anniversary Addon – Project Context

## Environment
- World of Warcraft: The Burning Crusade Anniversary (Classic) — Patch 2.5.5
- Interface version: 20505
- Lua 5.1 (WoW sandbox — no io, os, require, debug)

## API Baseline
- No C_* namespaces (except C_Timer if confirmed available — treat as absent by default)
- Use GetCurrentMapAreaID() / GetMapInfo() — NOT C_Map
- Use UnitAura() — NOT C_UnitAuras
- Use old GetSpellInfo(id) signature
- No LibRangeCheck versions targeting Retail
- CombatLog via CombatLogGetCurrentEventInfo() — available in 2.5.x

## Libraries used
- LibStub
- AceAddon-3.0, AceEvent-3.0, AceDB-3.0
- (ergänze deine hier)

## Conventions
- Namespace: `MyAddon` global table
- No global pollution
- Events unregistered on PLAYER_LOGOUT / PLAYER_LOGIN cycle
- SavedVariables documented in DB.lua

## File structure
- Core.lua — addon bootstrap
- Modules/ — feature modules  
- Libs/ — embedded libraries (do not edit)
- Locales/ — locale files
