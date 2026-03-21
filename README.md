# WowRaidDeathTracker

TBC Classic Anniversary Addon (2.5.5) – verfolgt Spielertode solo, in Party und Raid und zeigt ein Ranking der meisten Tode.

## Dateien

| Datei | Inhalt |
|---|---|
| `WowRaidDeathTracker.toc` | Addon-Manifest (Interface-Version, SavedVariables) |
| `WowRaidDeathTracker.lua` | Gesamte Logik: Events, UI, Minimap-Button, Slash-Commands |

## Installation

Ordner nach `World of Warcraft/_anniversary_/Interface/AddOns/WowRaidDeathTracker/` kopieren und Spiel neu starten.

## Features

- Erkennt Spielertode via `COMBAT_LOG_EVENT_UNFILTERED` → `UNIT_DIED`
- Filtert Pets/NPCs automatisch uber GUID-Prefix `Player-`
- Funktioniert solo, in Party und Raid
- Zeigt Top-5-Spieler mit Ranking und Todesanzahl
- Modernes, schlankes Panel-Design ohne externe Bibliotheken
- Drag & Drop – Fenster frei verschiebbar und in der Grosse anpassbar
- Reset-Button im Fenster
- Minimap-Button zum Ein-/Ausblenden (per Drag verschiebbar)
- `SavedVariables: RaidDeathData, RDTConfig` – Daten und Position uberleben `/reload`

## Slash Commands

| Befehl | Funktion |
|---|---|
| `/rdt` | Hilfe anzeigen |
| `/rdt show` | Fenster anzeigen |
| `/rdt hide` | Fenster verstecken |
| `/rdt toggle` | Fenster umschalten |
| `/rdt reset` | Alle Tode zurucksetzen |
| `/rdt test` | Einen zufälligen Test-Eintrag hinzufügen |
| `/rdt test clear` | Alle Daten zurucksetzen und Test-Badge ausblenden |

## Interface-Version

`20505` = TBC Classic 2.5.5. Aktuelle Versionsnummern: https://wowpedia.fandom.com/wiki/TOC_format
