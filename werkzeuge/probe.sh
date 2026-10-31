#!/usr/bin/env bash
# Probe-Installation der erzeugten App-Einträge (motom001/dms#176, #186) ohne echtes Gerät:
# startet die Compose-Datei von Umbrel bzw. ZimaOS/CasaOS so, wie die Plattform sie startet
# (Pfade, Variablen, Containernamen nachgebildet), richtet das DMS über die API ein,
# startet neu und prüft, dass die Daten bleiben.
#
#   werkzeuge/probe.sh umbrel|casaos [--ohne-einrichtung]
set -euo pipefail
ART="${1:?umbrel oder casaos}"
OHNE_EINRICHTUNG="${2:-}"
cd "$(dirname "$0")/.."
arbeit=$(mktemp -d)
compose="$arbeit/docker-compose.yml"

case "$ART" in
  umbrel)
    # app_proxy gibt es nur unter umbrelOS; Umbrel gibt den Containern feste Namen <app>_<dienst>_1.
    python3 - "$compose" <<'PY'
import sys, yaml
d = yaml.safe_load(open('motom001-dms/docker-compose.yml'))
d['services'].pop('app_proxy')
for name, s in d['services'].items():
    s['container_name'] = f'motom001-dms_{name}_1'
d['services']['server']['ports'] = ['18478:3000']
d.pop('version', None)
yaml.safe_dump(d, open(sys.argv[1], 'w'))
PY
    export APP_DATA_DIR="$arbeit/app" APP_MOTOM001_DMS_DB_PASSWORD="$(openssl rand -hex 32)"
    for o in files geheim sicherung postgres; do mkdir -p "$APP_DATA_DIR/data/$o"; done
    PORT=18478
    ;;
  casaos)
    sed "s#/DATA/AppData/\$AppID#$arbeit/app#g" Apps/DMS/docker-compose.yml > "$compose"
    PORT=8478
    ;;
  *) echo "unbekannt: $ART"; exit 2 ;;
esac

projekt="probe-$ART"
dc() { docker compose -p "$projekt" -f "$compose" "$@"; }
aufraeumen() { dc down -v >/dev/null 2>&1 || true; sudo rm -rf "$arbeit" 2>/dev/null || true; }
trap aufraeumen EXIT

warte() {
  for _ in $(seq 1 90); do
    curl -fsS "http://127.0.0.1:$PORT/api/konto/status" >/dev/null 2>&1 && return 0
    sleep 2
  done
  echo "::error::$ART: DMS antwortet nicht"; dc logs --tail 60; return 1
}

dc up -d --quiet-pull
warte
status=$(curl -fsS "http://127.0.0.1:$PORT/api/konto/status")
echo "$status" | jq -c '{einrichtungNoetig, einrichtung}'
[ "$(echo "$status" | jq -r '.einrichtung.phase')" = konto ] || { echo "::error::$ART: Assistent beginnt nicht beim Mandanten"; exit 1; }

if [ "$OHNE_EINRICHTUNG" = --ohne-einrichtung ]; then
  echo "::notice::$ART: ältere DMS-Version – Einrichtung ohne Code wird nicht geprüft."
  exit 0
fi
[ "$(echo "$status" | jq -r '.einrichtung.code')" = false ] || { echo "::error::$ART: Einrichtungscode verlangt"; exit 1; }

# Einrichten wie im Assistenten (ohne Code), dann neu starten: Mandant und Administrator bleiben.
curl -fsS -X POST "http://127.0.0.1:$PORT/api/konto/einrichten" -H 'x-dms: 1' -H 'content-type: application/json' \
  -d '{"mandant":"Familie Probe","name":"Admin","email":"admin@probe.invalid","passwort":"ein-langes-probe-passwort"}' >/dev/null
dc restart
warte
nachher=$(curl -fsS "http://127.0.0.1:$PORT/api/konto/status")
[ "$(echo "$nachher" | jq -r '.einrichtungNoetig')" = false ] || { echo "::error::$ART: nach dem Neustart wieder uneingerichtet"; exit 1; }
curl -fsS -X POST "http://127.0.0.1:$PORT/api/konto/anmelden" -H 'x-dms: 1' -H 'content-type: application/json' \
  -d '{"email":"admin@probe.invalid","passwort":"ein-langes-probe-passwort"}' >/dev/null \
  || { echo "::error::$ART: Anmeldung nach dem Neustart scheitert"; exit 1; }
echo "$ART: installiert, eingerichtet, neu gestartet, Anmeldung klappt."
