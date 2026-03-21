# Changelog

All notable changes to WowRaidDeathTracker are documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/).

---

## [1.1.0] - 2026-03-21

### Added
- Minimap button via embedded LibDBIcon-1.0 (LibStub + LibDataBroker-1-1 eingebettet)
- Post top-5 deaths to raid/party chat — `/rdt post` und Post-Button im Footer
- Test-Modus mit Dummy-Daten — `/rdt test` / `/rdt test clear`; postet im Testmodus in `/say`
- Panel erscheint automatisch beim Beitreten einer Gruppe/Raid
- Panel blendet sich automatisch aus beim Verlassen der Gruppe/Raid
- Todesdaten werden automatisch zurückgesetzt beim Beitreten einer neuen Gruppe/Raid
- Design-Palette `D` angelehnt an FishingKit (Cyan-Akzent, einheitliche Farben)
- Hilfsfunktion `MakeFooterBtn` eliminiert duplizierten Button-Code
- Hilfsfunktion `GetSortedDeaths` — gemeinsame Sortierliste für Display und Post
- `/rdt debug` — zeigt Einträge, Panel-Größe und Minimap-Winkel

### Changed
- `/rdt` allein toggelt das Panel (show/hide/toggle als separate Befehle entfernt)
- Minimap-Button-Position wird in `RDTConfig.minimapPos` gespeichert (migriert von `minimapAngle`)
- Titelfarbe auf Cyan (`#47bef5`) angepasst, roter Akzent entfernt
- Schließen-Button und Footer-Buttons im FishingKit-Stil überarbeitet
- Header-Balken entfernt zugunsten einer einzelnen Trennlinie unter Titel und Icon

### Fixed
- Hunter Totenstellen (Feign Death) wurde fälschlicherweise als Tod gezählt — behoben via `unconsciousKiller`-Flag im Combat Log
- Tode von fremden Spielern in der Open World wurden mitgezählt — nur noch eigene Gruppen-/Raid-Mitglieder (`UnitInRaid` / `UnitInParty`)
- Gruppen-Events werden per `pcall` registriert um Addon-Load-Fehler bei ungültigen Event-Namen zu verhindern
- FontString-Mehrzeiligkeit in TBC Classic: zwei Ankerpunkte (TOPLEFT + BOTTOMRIGHT) verhinderten Mehrzeiligkeit — auf `SetWidth()` + einzelnen Ankerpunkt umgestellt
- Debug-Artefakte (`UIErrorsFrame:AddMessage`, debug `print` in `UpdateDisplay`) entfernt
- Veralteter `minimapAngle`-Feldname im Debug-Output korrigiert auf `minimapPos`
