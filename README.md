# RaidDeathTracker

Tracks player deaths in party and raid, displays a top-5 ranking, and can post results to group chat.

## Features

- Counts deaths of party/raid members in real time
- Panel appears automatically when joining a group and hides when leaving
- Displays top-5 players with ranking and death count
- Post results to raid/party chat via button or slash command
- Freely movable and resizable window
- Minimap button to show/hide
- Data persists across reloads

## Slash Commands

| Command | Description |
|---|---|
| `/rdt` | Toggle window |
| `/rdt reset` | Reset all deaths |
| `/rdt post` | Post top 5 to raid/party chat |
| `/rdt test` | Enable test mode with dummy data |
| `/rdt test clear` | Exit test mode |

## Notes

- Session history is saved automatically when you **leave the group**. If you log off while still in a raid, the current session will not be saved to history (but live data persists across reloads).
- Deaths are tracked via the combat log, which only covers events within ~50 yards. If you are dead and the group moves away from your corpse, their deaths may not be recorded.

## Download

[CurseForge](https://www.curseforge.com/wow/addons/wow-raid-death-tracker)
