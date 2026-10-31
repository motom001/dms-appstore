# DMS App Store

App-Store-Einträge für das [DMS](https://github.com/motom001/dms): Dokumentenmanagement für Haushalte und Familien. Damit installierst du das DMS auf einem Heimserver mit einem Klick, ohne Docker oder Kommandozeile.

| System | So fügst du den Store hinzu |
| --- | --- |
| **umbrelOS** | App Store → ⋯ (oben rechts) → *Community App Stores* → `https://github.com/motom001/dms-appstore` |
| **ZimaOS** | App Store → *Quellen verwalten* → `https://cdn.jsdelivr.net/gh/motom001/dms-appstore@gh-pages` |
| **CasaOS** | App Store → *Weitere Apps* → `https://github.com/motom001/dms-appstore/archive/refs/heads/main.zip` |

Danach steht **DMS** im App Store. Nach der Installation öffnest du die App. Ein Assistent fragt nach dem Namen deines Haushalts und legt den ersten Administrator an. Die Datenbank ist schon angebunden.

> **Gleich nach der Installation einrichten.** Bis der Administrator angelegt ist, könnte das jeder in deinem Heimnetz tun.

Ausführlich unter [Wie komme ich an ein DMS? → App-Store](https://motom001.github.io/dms/installieren/aktuell/app-store/).

## Weitere Plattformen

| Plattform | Ordner | Stand |
| --- | --- | --- |
| **TrueNAS** | `truenas/dms/` (erzeugt) | wird bei jedem Release mit dem Prüfwerkzeug des Katalogs getestet; bereit für einen PR an [truenas/apps](https://github.com/truenas/apps) unter `ix-dev/community/dms` ([#182](https://github.com/motom001/dms/issues/182)) |
| **Unraid** | `unraid/dms.xml`, `unraid/dms-datenbank.xml` | Vorlagen für Community Applications; Einreichung über [ca.unraid.net](https://ca.unraid.net/submit) ([#183](https://github.com/motom001/dms/issues/183)) |
| **UGREEN** | `ugreen/` | Entwurf für das App Center, offene Fragen in `ugreen/README.md` ([#181](https://github.com/motom001/dms/issues/181)) |
| **Umbrel offiziell** | `offiziell/umbrel/dms/` (erzeugt) | bereit für einen PR an [getumbrel/umbrel-apps](https://github.com/getumbrel/umbrel-apps) ([#186](https://github.com/motom001/dms/issues/186)) |
| **ZimaOS offiziell** | `Apps/DMS/` | dieselbe Datei für einen PR an [IceWhaleTech/CasaOS-AppStore](https://github.com/IceWhaleTech/CasaOS-AppStore) ([#186](https://github.com/motom001/dms/issues/186)) |

Anleitungen ohne App-Store (Synology, QNAP, UGREEN, TrueNAS, Unraid, Docker) stehen unter [Wie komme ich an ein DMS?](https://motom001.github.io/dms/installieren/aktuell/).

## Aufbau

| Pfad | Inhalt |
| --- | --- |
| `vorlagen/` | Vorlagen für Umbrel, ZimaOS/CasaOS und TrueNAS – **hier ändern** |
| `werkzeuge/erzeugen.py` | setzt Version, Images (mit Digest) und Bilder ein |
| `umbrel-app-store.yml`, `motom001-dms/` | Umbrel (erzeugt) |
| `Apps/DMS/`, `store-config.json`, `supported-languages.json` | ZimaOS/CasaOS (Compose erzeugt) |
| Branch `gh-pages` | gebauter ZimaOS-Store (v2) |

Der Workflow **Store aktualisieren** läuft täglich und nach Änderungen an den Vorlagen. Er holt das neueste DMS-Release, löst die Images für amd64 und arm64 auf ihren Digest auf und erzeugt die Einträge. Dann **installiert er sie probehalber**: Umbrel und ZimaOS/CasaOS starten, das DMS wird über die API eingerichtet, neu gestartet und die Anmeldung geprüft; TrueNAS läuft durch das Prüfwerkzeug des Katalogs. Erst dann checkt er ein und baut den ZimaOS-Store. Von Hand lässt er sich auch für eine bestimmte Version starten.

Fehler und Wünsche bitte im [DMS-Repository](https://github.com/motom001/dms/issues) melden.
