# RaidDeathTracker

Tracks player deaths in party and raid, displays a top-5 ranking, and can post results to group chat.

## Features

- Counts deaths of party/raid members in real time
- Panel appears automatically when joining a group and hides when leaving
- Displays top-5 players with ranking and death count
- Raid & dungeon timer: starts on the first pull in a raid or TBC dungeon, shows elapsed time in the panel and records each boss kill with time since the first pull and fight duration
- Post results to raid/party chat via button or slash command
- Freely movable and resizable window
- Minimap button to show/hide
- Data persists across reloads (including the raid timer)

## Slash Commands

| Command | Description |
|---|---|
| `/rdt` | Toggle window |
| `/rdt reset` | Reset all deaths |
| `/rdt post` | Post top 5 to raid/party chat |
| `/rdt time [channel]` | Show raid time & boss kill list (optionally post to a channel) |
| `/rdt time <name>` | Whisper the raid time & boss kill list to a player |
| `/rdt time reset` | Reset the raid timer |
| `/rdt test` | Enable test mode with dummy data |
| `/rdt test clear` | Exit test mode |

## Notes

- Session history is saved automatically when you **leave the group**. If you log off while still in a raid, the current session will not be saved to history (but live data persists across reloads).
- Deaths are tracked via the combat log, which only covers events within ~50 yards. If you are dead and the group moves away from your corpse, their deaths may not be recorded.
- The raid/dungeon time counts live while you are inside the instance and stops the moment **all required bosses** are dead (kill order doesn't matter; dungeons stop on the end boss). Optional bosses killed afterwards extend the time to their kill; leaving the instance also freezes the time at the last boss kill.
- **Multi-raid nights:** pulling in another raid with the same group continues the timer — the travel time between the raids is excluded (the clock retroactively pauses at the previous raid's last boss kill and resumes on the next first pull). Deaths and boss kills stay merged into one list. Raid→dungeon (or vice versa) starts a fresh timer instead.
- Dungeon timers currently cover **TBC dungeons only** and require being in a group.

## Download

[CurseForge](https://www.curseforge.com/wow/addons/wow-raid-death-tracker)
