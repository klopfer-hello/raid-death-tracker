# WowRaidDeathTracker – Projekt-Kontext für Claude

## Umgebung
- World of Warcraft: The Burning Crusade Classic Anniversary — Patch 2.5.5
- Interface-Version: `20505`
- Lua 5.1 (WoW-Sandbox — kein io, os, require, debug)

## WoW API Einschränkungen
- Kein `BackdropTemplate` / `SetBackdrop` — stattdessen manuelle Pixel-Borders via `AddPixelBorder()`
- Resize: defensive Prüfung `SetResizeBounds` vs. `SetResizable`/`SetMinResize`
- Kein `C_*` Namespace (C_Timer als nicht vorhanden behandeln)
- CombatLog: `CombatLogGetCurrentEventInfo()`
- Das Pipe-Zeichen `|` in `FontString:SetText()` ist ein WoW-Escape — nie als Literal verwenden
- `math.atan2` (Lua 5.1 Stil)

## Bibliotheken
- LibStub (eingebettet in `libs/LibDBIcon-1-0.lua`)
- LibDataBroker-1-1 (eingebettet, minimaler Shim)
- LibDBIcon-1.0 (eingebettet, eigene Implementierung)

## Dateistruktur
```
WowRaidDeathTracker/
  libs/
    LibDBIcon-1-0.lua   -- LibStub + LDB + LibDBIcon (nicht editieren)
  WowRaidDeathTracker.toc
  WowRaidDeathTracker.lua
  CLAUDE.md
```

## SavedVariables
- `RaidDeathData` — table: `{ [playerName] = count }`
- `RDTConfig` — table: `{ minimapPos = <angle> }`

## Commit-Anforderungen

Commits müssen dem **Conventional Commits**-Standard folgen:

```
<type>(<scope>): <beschreibung>

<body>  ← optional, erklärt das "warum"

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```

### Erlaubte Types
| Type | Wann |
|---|---|
| `feat` | Neues Feature |
| `fix` | Bugfix |
| `refactor` | Umstrukturierung ohne Verhaltensänderung |
| `docs` | Nur Dokumentation |
| `chore` | Build, TOC, Konfiguration |

### Regeln
- Beschreibung auf **Englisch**, Kleinschreibung, kein Punkt am Ende
- Body auf Deutsch oder Englisch, erklärt konkret was und warum
- Jede inhaltlich getrennte Änderung → eigener Commit
- Immer `Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>` anhängen
- Nie `--no-verify` oder force-push ohne explizite Aufforderung
- Nutze connventional commit regeln
