# WowRaidDeathTracker

**v1.3.2** — TBC Classic Anniversary Addon (2.5.5)

Tracks player deaths in party and raid, displays a top-5 ranking, and can post results to group chat.

## Files

| File | Contents |
|---|---|
| `WowRaidDeathTracker.toc` | Addon manifest (interface version, SavedVariables) |
| `WowRaidDeathTracker.lua` | All logic: events, UI, minimap button, slash commands |
| `libs/LibDBIcon-1-0.lua` | Embedded libraries: LibStub, LibDataBroker-1-1, LibDBIcon-1.0 |
| `CHANGELOG.md` | Version history |

## Installation

Copy the folder to `World of Warcraft/_anniversary_/Interface/AddOns/WowRaidDeathTracker/` and restart the game.

## Features

- Detects player deaths via `COMBAT_LOG_EVENT_UNFILTERED` → `UNIT_DIED`
- Automatically filters pets/NPCs using GUID prefix `Player-`
- Only deaths of your own party/raid members are counted
- Panel appears automatically when joining a group/raid and hides when leaving
- Displays top-5 players with ranking and death count
- Post top-5 via button or slash command to raid/party chat
- Design inspired by FishingKit (cyan accent, D palette)
- Drag & drop — window is freely movable and resizable
- Minimap button to show/hide (draggable)
- `SavedVariables: RaidDeathData, RDTConfig` — data and position persist across `/reload`

## Slash Commands

| Command | Description |
|---|---|
| `/rdt` | Toggle window |
| `/rdt reset` | Reset all deaths |
| `/rdt post` | Post top 5 to raid/party chat |
| `/rdt test` | Enable test mode with dummy data |
| `/rdt test clear` | Exit test mode |
| `/rdt debug` | Show debug information |

## Interface Version

`20505` = TBC Classic 2.5.5. Current version numbers: https://wowpedia.fandom.com/wiki/TOC_format

## Versioning

This project follows [Semantic Versioning](https://semver.org/). All changes are documented in [CHANGELOG.md](CHANGELOG.md).
