# Changelog

All notable changes to RaidDeathTracker are documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/).

---

## [1.9.0] - 2026-07-29

### Added
- **Dungeon timers** — the instance timer now also runs in 5-man dungeons: first pull starts it, boss kills are recorded with kill time and fight duration, and `/rdt time` labels the run as "Dungeon time". Limited to TBC dungeons for now (checked via instance map id); old-world dungeons don't trigger it. All TBC dungeon boss NPC ids were added to the combat-log fallback.
- The timer now requires being in a group, so solo instance farming no longer arms it.
- `/rdt time <name>` — whispers the raid/dungeon time and boss kill list to a player. Any argument that is not a channel keyword or `reset` is treated as a whisper target.
- **Raid completion stops the clock** — the timer freezes the moment **all required bosses** of the raid are dead (kill order doesn't matter), instead of only after leaving the instance. Optional encounters (Attumen, Maiden, Opera, Illhoof, Netherspite, Nightbane, Chess) don't gate completion but still extend the frozen time when killed afterwards. A "complete" line with the final time is printed and the panel shows a green "done" tag. Zones without a known boss list — including all dungeons — stop on their end boss instead.
- **Multi-raid nights** — pulling in a second raid with the same group no longer resets the timer. The clock is retroactively paused at the last boss kill of the previous raid and resumes on the first pull of the next one, so travel time between raids is excluded. Deaths, boss list and total time stay merged; `/rdt time` shows all bosses grouped per raid, each with its active-time kill stamp. Applies to same-type chains only (raid→raid, dungeon→dungeon); switching between raid and dungeon starts fresh.

## [1.8.0] - 2026-07-23

### Added
- **Raid timer** — starts automatically on the first pull inside a raid instance and shows elapsed time as a line in the panel (`Zone  time  -  N bosses down`). The timer uses epoch time and is stored inside `RDTConfig` (a SavedVariable registered since v1.0), so it survives `/reload` and disconnects mid-raid without requiring a client restart to pick up a new TOC entry.
- **Boss kill times** — boss kills are detected via `ENCOUNTER_END` / `BOSS_KILL` plus a combat-log fallback (`UNIT_DIED` of known TBC raid boss NPC ids) for encounters where the classic client doesn't fire encounter events (e.g. Hydross). All paths are deduplicated per encounter id and boss name. Each kill is recorded with time since raid start plus the fight duration and prints a short "Boss down" line to chat.
- `/rdt time [channel]` — prints the raid time and the boss kill list (optionally posts to say/yell/party/raid/emote); `/rdt time reset` clears the timer
- Raid timer data is saved into sessions, so browsing a past session with the arrows also shows that raid's time and boss kills via `/rdt time`
- Test mode now includes a dummy Karazhan raid log

## [1.7.1] - 2026-07-08

### Changed
- **TBC Anniversary 2.5.6 compatibility** — bumped the `.toc` interface version to `20506` so the addon is no longer flagged out of date on patch 2.5.6. No functional changes.

## [1.7.0] - 2026-06-24

### Added
- `/rdt list [channel]` — shows the full group roster including members with 0 deaths; optionally posts it to say/yell/party/raid/emote
- `/rdt zero [channel]` — shows only group members with 0 deaths (the survivors); optionally posts it to a channel

Both commands derive 0-death members from the current group roster, since per-session rosters are not stored.

---

## [1.6.0] - 2026-05-22

### Added
- Post button now uses the currently viewed session — when browsing a saved session via the navigation arrows, posting sends that session's top 5. The chat header includes the session name so readers see which raid is being reported.

### Fixed
- Holy priests with Spirit of Redemption were counted twice — once on the initial death and once when the 15s ghost form expired. Duplicate `UNIT_DIED` events for the same player within 20s are now ignored on the non-hunter death path (Feign Death handling is unchanged).

---

## [1.5.0] - 2026-04-19

### Added
- Panel is now actually resizable via the bottom-right grip; chosen size is persisted in `RDTConfig` and restored on reload (clamped to 220x150 – 500x450)

### Changed
- Renamed addon files from `WowRaidDeathTracker.lua`/`.toc` to `RaidDeathTracker.lua`/`.toc` to match the addon folder name; internal addon name and LibDBIcon registration key updated accordingly

### Fixed
- `SetResizable(true)` was only called on the old bounds-API path, so `StartSizing()` silently failed when `SetResizeBounds` was available — now always enabled

---

## [1.4.1] - 2026-03-28

### Added
- Documented session save behavior (only on group leave) in README

### Fixed
- Added missing `Author` field in TOC

---

## [1.4.0] - 2026-03-28

### Added
- Channel selection popup on Post button (Say, Yell, Party, Raid, Emote)
- `/rdt post [channel]` slash command argument for channel selection

### Changed
- Simplified README to match common WoW addon style

---

## [1.3.2] - 2026-03-24

### Changed
- Translated all documentation, code comments, and UI text to English

---

## [1.3.1] - 2026-03-24

### Added
- `.pkgmeta` for CurseForge packaging
- Screenshots (window, chat) and addon icon in `media/`

### Changed
- Simplified TOC notes

---

## [1.3.0] - 2026-03-21

### Added
- Session navigation in the panel via `<` / `>` buttons in the footer
- Badge shows session name when browsing

### Fixed
- Class colors: replaced `RAID_CLASS_COLORS` with hardcoded `CLASS_COLORS` table — reliable in TBC Classic Anniversary

---

## [1.2.0] - 2026-03-21

### Added
- Player names colored by class (`RAID_CLASS_COLORS`), class stored in `RDTClassCache`
- "Most Valuable Corpse" — title for the player with the most deaths, displayed below the ranking
- Session management: session is automatically saved when leaving a group (zone + date), max 5 sessions (FIFO)
- `/rdt sessions` — list all saved sessions
- `/rdt session <n>` — view session n read-only in the panel
- Total death count included in `/rdt post` output
- TOC: icon (`Spell_Shadow_DeathCoil`) and category (`Hall of Shame`)

### Changed
- Post output always uses `EMOTE` channel (no more channel detection)
- `PLAYER_ENTERING_WORLD` no longer triggers a data reset — only actual group join resets data

### Fixed
- Hunter Feign Death detected via 3-second delay — only affects Hunters
- Party/raid members found via `UnitExists()` iteration instead of `GetNumRaidMembers()` (unreliable in TBC Classic Anniversary)
- Data was lost after `/reload` due to incorrect auto-reset on `PLAYER_ENTERING_WORLD`
- Only deaths of own group members are counted (no more open-world tracking)

---

## [1.1.0] - 2026-03-21

### Added
- Minimap button via embedded LibDBIcon-1.0 (LibStub + LibDataBroker-1-1 embedded)
- Post top-5 deaths to raid/party chat — `/rdt post` and post button in footer
- Test mode with dummy data — `/rdt test` / `/rdt test clear`; posts to `/say` in test mode
- Panel appears automatically when joining a group/raid
- Panel hides automatically when leaving the group/raid
- Death data automatically reset when joining a new group/raid
- Design palette `D` inspired by FishingKit (cyan accent, uniform colors)
- Helper function `MakeFooterBtn` eliminates duplicated button code
- Helper function `GetSortedDeaths` — shared sorted list for display and post
- `/rdt debug` — shows entries, panel size, and minimap angle

### Changed
- `/rdt` alone toggles the panel (show/hide/toggle removed as separate commands)
- Minimap button position stored in `RDTConfig.minimapPos` (migrated from `minimapAngle`)
- Title color changed to cyan (`#47bef5`), red accent removed
- Close button and footer buttons redesigned in FishingKit style
- Header bar removed in favor of a single divider line below title and icon

### Fixed
- Hunter Feign Death was incorrectly counted as a death — fixed via `unconsciousKiller` flag in combat log
- Deaths of other players in the open world were counted — now only own party/raid members (`UnitInRaid` / `UnitInParty`)
- Group events registered via `pcall` to prevent addon load errors on invalid event names
- FontString multiline issue in TBC Classic: two anchor points (TOPLEFT + BOTTOMRIGHT) prevented multiline — switched to `SetWidth()` + single anchor
- Debug artifacts (`UIErrorsFrame:AddMessage`, debug `print` in `UpdateDisplay`) removed
- Outdated `minimapAngle` field name in debug output corrected to `minimapPos`
