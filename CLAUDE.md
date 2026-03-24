# WowRaidDeathTracker – Project Context for Claude

## Environment
- World of Warcraft: The Burning Crusade Classic Anniversary — Patch 2.5.5
- Interface version: `20505`
- Lua 5.1 (WoW sandbox — no io, os, require, debug)

## WoW API Restrictions
- No `BackdropTemplate` / `SetBackdrop` — use manual pixel borders via `AddPixelBorder()` instead
- Resize: defensive check `SetResizeBounds` vs. `SetResizable`/`SetMinResize`
- No `C_*` namespace (treat C_Timer as unavailable)
- CombatLog: `CombatLogGetCurrentEventInfo()`
- The pipe character `|` in `FontString:SetText()` is a WoW escape — never use as literal
- `math.atan2` (Lua 5.1 style)

## Libraries
- LibStub (embedded in `libs/LibDBIcon-1-0.lua`)
- LibDataBroker-1-1 (embedded, minimal shim)
- LibDBIcon-1.0 (embedded, custom implementation)

## File Structure
```
WowRaidDeathTracker/
  libs/
    LibDBIcon-1-0.lua   -- LibStub + LDB + LibDBIcon (do not edit)
  WowRaidDeathTracker.toc
  WowRaidDeathTracker.lua
  CHANGELOG.md
  README.md
  CLAUDE.md
```

## Versioning

- Schema: **Semantic Versioning** (`MAJOR.MINOR.PATCH`)
- Version is in `WowRaidDeathTracker.toc` (`## Version`) and in the Lua header comment
- Releases are set as **Git tags**: `git tag v1.3.0`
- Each release gets an entry in `CHANGELOG.md` (format: Keep a Changelog)

| Bump | When |
|---|---|
| `PATCH` | Bug fixes without new features |
| `MINOR` | New features, backwards compatible |
| `MAJOR` | Breaking changes (e.g. SavedVariables format) |

### Release Checklist

A release consists of the following steps — always in this order:

1. `git log vX.Y.Z..HEAD --oneline` — review commits since last release
2. Determine version (PATCH / MINOR / MAJOR)
3. `CHANGELOG.md` — add new section `## [X.Y.Z] - YYYY-MM-DD` with Added / Changed / Fixed
4. `WowRaidDeathTracker.toc` — update `## Version: X.Y.Z`
5. `WowRaidDeathTracker.lua` — update header comment `v X.Y.Z` and load print
6. `README.md` — update version badge if present
7. Commit: `chore: release vX.Y.Z`
8. Set tag: `git tag vX.Y.Z`

## SavedVariables
- `RaidDeathData` — table: `{ [playerName] = count }`
- `RDTConfig` — table: `{ minimapPos = <angle> }`

## Commit Requirements

Commits must follow the **Conventional Commits** standard:

```
<type>(<scope>): <description>

<body>  ← optional, explains the "why"

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```

### Allowed Types
| Type | When |
|---|---|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Restructuring without behavior change |
| `docs` | Documentation only |
| `chore` | Build, TOC, configuration |

### Rules
- Description in **English**, lowercase, no period at the end
- Body in English, explains concretely what and why
- Each logically separate change → its own commit
- Always append `Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>`
- Never use `--no-verify` or force-push without explicit request
- Follow Conventional Commits rules

## Code Review Rules

Check the following points during every review:

### Bugs
- Debug artifacts (`print`, `UIErrorsFrame:AddMessage`) that end up in production
- Outdated variable names after refactorings (e.g. renamed SavedVariable fields)

### Maintainability
- Magic numbers — use named constants (e.g. `TOP_N` instead of `5`)
- Duplicated code — extract shared logic into helper functions when identical in multiple places

### Efficiency
- Unnecessary loops when the result is already known (e.g. `#table` instead of manual counting)

### Consistency
- Sort stability: same sort predicates everywhere the same data structure is sorted
- Uniform usage of defined constants throughout the file

### WoW-specific
- `SendChatMessage` does not accept WoW color escapes (`|c`, `|r`) — never use pipe sequences in chat messages
- FontString with two anchor points (TOPLEFT + BOTTOMRIGHT) prevents multiline in TBC Classic — use `SetWidth()` + single anchor instead
