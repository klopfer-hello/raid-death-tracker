# Changelog

All notable changes to WowRaidDeathTracker are documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/).

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
