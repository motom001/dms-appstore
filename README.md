# DMS App Store

App-Store-Einträge für das [DMS](https://github.com/motom001/dms): Dokumentenmanagement für Haushalte und Familien. Damit installierst du das DMS auf einem Heimserver mit einem Klick, ohne Docker oder Kommandozeile.

| System | So fügst du den Store hinzu |
| --- | --- |
| **umbrelOS** | App Store → ⋯ (oben rechts) → *Community App Stores* → `https://github.com/motom001/dms-appstore` |
| **ZimaOS** | App Store → *Quellen verwalten* → `https://cdn.jsdelivr.net/gh/motom001/dms-appstore@gh-pages` |
| **CasaOS** | App Store → *Weitere Apps* → `https://github.com/motom001/dms-appstore/archive/refs/heads/main.zip` |

Danach steht **DMS** im App Store. Nach der Installation öffnest du die App. Ein Assistent fragt nach dem Namen deines Haushalts und legt den ersten Administrator an. Die Datenbank ist schon angebunden.

> **Gleich nach der Installation einrichten.** Bis der Administrator angelegt ist, könnte das jeder in deinem Heimnetz tun.

Ausführlich im Administratorhandbuch: [Installation mit einem Klick](https://motom001.github.io/dms/admin/aktuell/app-store/).

## Aufbau

| Pfad | Inhalt |
| --- | --- |
| `vorlagen/` | Vorlagen für Umbrel und ZimaOS/CasaOS – **hier ändern** |
| `werkzeuge/erzeugen.py` | setzt Version, Images (mit Digest) und Bilder ein |
| `umbrel-app-store.yml`, `motom001-dms/` | Umbrel (erzeugt) |
| `Apps/DMS/`, `store-config.json`, `supported-languages.json` | ZimaOS/CasaOS (Compose erzeugt) |
| Branch `gh-pages` | gebauter ZimaOS-Store (v2) |

Der Workflow **Store aktualisieren** läuft täglich und nach Änderungen an den Vorlagen. Er holt das neueste DMS-Release, löst die Images für amd64 und arm64 auf ihren Digest auf, erzeugt die Einträge, checkt sie ein und baut den ZimaOS-Store. Von Hand lässt er sich auch für eine bestimmte Version starten.

Fehler und Wünsche bitte im [DMS-Repository](https://github.com/motom001/dms/issues) melden.
