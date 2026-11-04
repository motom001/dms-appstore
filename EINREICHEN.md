# Einreichen in die offiziellen Stores

Checkliste für den Maintainer. Die Einträge liegen fertig in diesem Repository; eingereicht wird erst, wenn die Vorlagen das Image-Tag `:stabil` nutzen ([motom001/dms#714](https://github.com/motom001/dms/issues/714)) – die erzeugten Einträge zeigen dann auf die Version, auf die `:stabil` zeigt (mit Digest).

Vor jeder Einreichung:

- [ ] Der Workflow **Store aktualisieren** ist mit der aktuellen stabilen Version grün gelaufen (Probe-Installation Umbrel, ZimaOS/CasaOS, Prüfwerkzeug TrueNAS).
- [ ] Bildschirmfotos und Symbol aus `Apps/DMS/` (dieselben wie im eigenen Store).
- [ ] Beschreibung nach der Schreibregel: „Ablago – Dokumentenablage für zu Hause und kleine Betriebe“, englisch „Ablago – document filing for home and small businesses“.
- [ ] Support-Adresse: `https://github.com/motom001/dms/issues`; Website `https://ablago.app`; Handbuch `https://help.ablago.app`.
- [ ] Den Pull Request bzw. die Einreichung im jeweiligen Issue verlinken.

## umbrelOS – [#186](https://github.com/motom001/dms/issues/186)

Ordner `offiziell/umbrel/dms/` (erzeugt, App-ID `dms`, ohne Store-Präfix, ohne `icon` und `gallery` im Manifest).

1. Fork von [getumbrel/umbrel-apps](https://github.com/getumbrel/umbrel-apps), Ordner `offiziell/umbrel/dms/` als `dms/` hineinkopieren.
2. Dort prüfen: `npm run lint:apps -- dms --check-images`.
3. Pull Request stellen; Symbol (256 × 256, `Apps/DMS/icon.png`) und drei Bildschirmfotos in die PR-Beschreibung.
4. Das Umbrel-Team testet selbst; Rückfragen im PR beantworten.

## ZimaOS / CasaOS – [#186](https://github.com/motom001/dms/issues/186)

Ordner `Apps/DMS/` (Compose mit `x-casaos`, ein Container `dms-komplett`).

1. Fork von [IceWhaleTech/CasaOS-AppStore](https://github.com/IceWhaleTech/CasaOS-AppStore), Ordner `Apps/DMS/` übernehmen (Name des Ordners nach deren Vorgabe, z. B. `Apps/Ablago/`).
2. Validator des Repositorys laufen lassen (steht in deren README).
3. Pull Request stellen.

## TrueNAS – [#182](https://github.com/motom001/dms/issues/182)

Ordner `truenas/dms/` (erzeugt, bei jedem Release mit dem Prüfwerkzeug des Katalogs getestet).

1. Fork von [truenas/apps](https://github.com/truenas/apps), Ordner als `ix-dev/community/dms/` übernehmen.
2. Dort `./.github/scripts/ci.py --app dms --train community --test-file basic-values.yaml` – genau so prüft es auch der Workflow *Store aktualisieren*.
3. Pull Request stellen. Neue Versionen kommen danach über deren Renovate.

## Unraid – [#183](https://github.com/motom001/dms/issues/183)

Vorlagen `unraid/dms.xml` (**Ablago**) und `unraid/dms-datenbank.xml` (**Ablago-Datenbank**), Image `ghcr.io/motom001/dms:stabil`.

1. Auf einem Unraid-Server testen: beide Vorlagen über die URL aus `TemplateURL` hinzufügen, zuerst „Ablago-Datenbank“, dann „Ablago“; einrichten, neu starten, Update.
2. Im Unraid-Forum einen Support-Thread anlegen (verlangt Community Applications) und dessen Adresse als `<Support>` in beide Vorlagen eintragen.
3. Über [ca.unraid.net/submit](https://ca.unraid.net/submit) dieses Repository einreichen.

## UGREEN – [#181](https://github.com/motom001/dms/issues/181)

Ordner `ugreen/` (Entwurf). Zuerst die offenen Fragen in [`ugreen/README.md`](ugreen/README.md) mit UGREEN klären (Entwicklerkonto auf developer.ugnas.com). Danach:

1. `ugreen/bilder-holen.sh <Version>` (die Version, auf die `:stabil` zeigt), dann `cd ugreen && ugcli pack --build 1`.
2. Auf dem eigenen NAS installieren, einrichten, neu starten, Daten prüfen, auf die nächste Version aktualisieren.
3. Paket per E-Mail an UGREEN zur Prüfung schicken.
