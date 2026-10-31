# DMS für das UGREEN App Center (Entwurf)

Zu [motom001/dms#181](https://github.com/motom001/dms/issues/181). Aufbau nach dem [UGREEN-Entwicklerportal](https://developer.ugnas.com/en/doc/backend/quick-start/develop-docker-app.html):

```
project.yaml                    App-Angaben, Parameter (Datenbank-Passwort)
rootfs_common/docker-compose.yaml
rootfs_common/icon.png          256 × 256
rootfs_{amd64,arm64}/images/    Images als tar – von bilder-holen.sh erzeugt, nicht eingecheckt
```

## Offene Fragen (vor dem ersten Paket klären)

Die Dokumentation beantwortet das nicht; am besten fragt der Maintainer nach der Registrierung bei UGREEN nach.

1. **Mehrere Container:** Das Beispiel hat nur einen Dienst. Geht `app` + `db` in einer App? Falls nicht, bräuchte das DMS eine Variante mit eingebauter Datenbank.
2. **Dauerhafte Daten:** Welcher Pfad bleibt bei Updates erhalten? Die Vorlage nimmt vorläufig `./data/…` relativ zum Installationsordner.
3. **Testen vor der Freigabe:** Lässt sich ein `.upk` auf dem eigenen NAS installieren, bevor UGREEN es prüft?
4. **Kosten, Dauer der Prüfung, Entwicklerkonto** (Privatperson).
5. **Paketgröße:** Die Images liegen im Paket, je Architektur etwa 300 MB für DMS und PostgreSQL. Ist das zulässig?

## Paket bauen (nach der Klärung)

```sh
ugreen/bilder-holen.sh 0.40.0     # Images je Architektur als tar
cd ugreen && ugcli pack --build 1 # ergibt build_dir/{amd64,arm64}_nasync_io.github.motom001.dms_0.40.0.0001.upk
```

Danach auf dem eigenen NAS testen (installieren, einrichten, neu starten, Daten bleiben, Update) und per E-Mail an UGREEN zur Prüfung schicken. Klappt das, kann der Workflow *Store aktualisieren* das Paket bei jedem Release mitbauen.
