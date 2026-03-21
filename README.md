# WowRaidDeathTracker

TBC Classic Anniversary Addon – zählt Spielertode im Raid/Party und zeigt eine Strichliste pro Spieler.

## Dateien

| Datei | Inhalt |
|---|---|
| `WowRaidDeathTracker.toc` | Addon-Manifest (Interface-Version, SavedVariables) |
| `WowRaidDeathTracker.lua` | Gesamte Logik: Events, UI, Slash-Commands |

## Installation

Ordner nach `World of Warcraft/_classic_/Interface/AddOns/WowRaidDeathTracker/` kopieren.

## Features

- Erkennt Spielertode via `COMBAT_LOG_EVENT_UNFILTERED` → `UNIT_DIED`
- Filtert Pets/NPCs über GUID-Prefix `Player-`
- Strichliste: Gruppen zu 5 als `卌`, Rest als `|`
- Sortierung: meiste Tode oben
- Drag & Drop – Fenster frei verschiebbar
- ScrollFrame für viele Spieler
- `SavedVariables: RaidDeathData` – überlebt `/reload`
- Reset-Button im Fenster + `/rdt reset`

## Slash Commands

| Befehl | Funktion |
|---|---|
| `/rdt` | Hilfe anzeigen |
| `/rdt show` | Fenster anzeigen |
| `/rdt hide` | Fenster verstecken |
| `/rdt toggle` | Fenster umschalten |
| `/rdt reset` | Alle Tode zurücksetzen |

## Mögliche Erweiterungen (für Claude Code)

- Nur Tode in bestimmten Zonen/Raids zählen
- Mindest-Gruppengröße als Filter
- Boss-spezifisches Tracking (Tode pro Boss-Encounter)
- Minimap-Button zum Ein-/Ausblenden
- Farb-Konfiguration über Options-Panel
- Export der Daten als Chat-Nachricht

## Interface-Version

`20504` = TBC Classic Phase 1. Bei anderen Phasen ggf. anpassen.
Aktuelle Versionen: https://wowpedia.fandom.com/wiki/TOC_format
