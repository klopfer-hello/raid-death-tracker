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
- Filtert Pets/NPCs automatisch über GUID-Prefix `Player-`
- Nur Tode eigener Gruppen-/Raid-Mitglieder werden gezählt
- Panel erscheint automatisch beim Betreten einer Gruppe/Raid und versteckt sich beim Verlassen
- Zeigt Top-5-Spieler mit Ranking und Todesanzahl
- Top-5 per Knopf oder Slash-Command in Raid/Party-Chat posten
- Design angelehnt an FishingKit (Cyan-Akzent, D-Palette)
- Drag & Drop – Fenster frei verschiebbar und in der Größe anpassbar
- Minimap-Button zum Ein-/Ausblenden (per Drag verschiebbar)
- `SavedVariables: RaidDeathData, RDTConfig` – Daten und Position überleben `/reload`

## Slash Commands

| Befehl | Funktion |
|---|---|
| `/rdt` | Fenster ein-/ausblenden |
| `/rdt reset` | Alle Tode zurücksetzen |
| `/rdt post` | Top 5 in Raid/Party-Chat posten |
| `/rdt test` | Testmodus mit Dummy-Daten aktivieren |
| `/rdt test clear` | Testmodus beenden |
| `/rdt debug` | Debug-Informationen anzeigen |

## Interface-Version

`20505` = TBC Classic 2.5.5. Aktuelle Versionsnummern: https://wowpedia.fandom.com/wiki/TOC_format
