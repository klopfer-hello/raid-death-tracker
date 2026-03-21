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
  CHANGELOG.md
  README.md
  CLAUDE.md
```

## Versionierung

- Schema: **Semantic Versioning** (`MAJOR.MINOR.PATCH`)
- Version steht in `WowRaidDeathTracker.toc` (`## Version`) und im Lua-Header-Kommentar
- Releases werden als **Git-Tags** gesetzt: `git tag v1.1.0`
- Jeder Release erhält einen Eintrag in `CHANGELOG.md` (Format: Keep a Changelog)

| Bump | Wann |
|---|---|
| `PATCH` | Bugfixes ohne neue Features |
| `MINOR` | Neue Features, rückwärtskompatibel |
| `MAJOR` | Brechende Änderungen (z.B. SavedVariables-Format) |

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
- Nutze Conventional Commits Regeln

## Code-Review-Regeln

Bei jedem Review auf folgende Punkte achten:

### Bugs
- Debug-Artefakte (`print`, `UIErrorsFrame:AddMessage`) die in Produktion landen
- Veraltete Variablennamen nach Refactorings (z.B. umbenannte SavedVariable-Felder)

### Wartbarkeit
- Magic Numbers — benannte Konstanten verwenden (z.B. `TOP_N` statt `5`)
- Duplizierter Code — gemeinsame Logik in Hilfsfunktionen extrahieren, wenn sie an mehreren Stellen identisch vorkommt

### Effizienz
- Unnötige Schleifen wenn das Ergebnis bereits bekannt ist (z.B. `#table` statt manuelles Zählen)

### Konsistenz
- Sort-Stabilität: gleiche Sortierpredikate überall wo dieselbe Datenstruktur sortiert wird
- Einheitliche Nutzung von definierten Konstanten im gesamten File

### WoW-spezifisch
- `SendChatMessage` akzeptiert keine WoW-Color-Escapes (`|c`, `|r`) — nie Pipe-Sequenzen in Chat-Nachrichten verwenden
- FontString mit zwei Ankerpunkten (TOPLEFT + BOTTOMRIGHT) verhindert Mehrzeiligkeit in TBC Classic — stattdessen `SetWidth()` + einzelnen Ankerpunkt
