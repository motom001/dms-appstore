#!/usr/bin/env bash
# Probe-Installation der erzeugten App-Einträge (motom001/dms#176, #186) ohne echtes Gerät:
# startet die Compose-Datei von Umbrel bzw. ZimaOS/CasaOS so, wie die Plattform sie startet
# (Pfade, Variablen, Containernamen nachgebildet), richtet das DMS über die API ein,
# startet neu und prüft, dass die Daten bleiben.
#
#   werkzeuge/probe.sh umbrel|casaos|unraid [--ohne-einrichtung]
#
# Unraid (motom001/dms-appstore#29): unraid/ablago.xml wird in eine Compose-Datei übersetzt, wie Unraid den Container
# startet (Port, Variablen, Ordner, ExtraParams). PROBE_IMAGE ersetzt das Image (in der CI dms-komplett des Releases).
set -euo pipefail
ART="${1:?umbrel, casaos oder unraid}"
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
    PORT=18478 DIENST=server
    ;;
  casaos)
    sed "s#/DATA/AppData/\$AppID#$arbeit/app#g" Apps/DMS/docker-compose.yml > "$compose"
    PORT=8478 DIENST=dms
    ;;
  unraid)
    python3 - "$compose" "$arbeit/app" <<'PY'
import os, sys, yaml, xml.etree.ElementTree as E
c = E.parse('unraid/ablago.xml').getroot()
s = {'image': os.environ.get('PROBE_IMAGE') or c.findtext('Repository'), 'ports': [], 'environment': {}, 'volumes': []}
for k in c.findall('Config'):
    wert = (k.text or k.get('Default') or '').strip()
    if k.get('Type') == 'Port': s['ports'].append(f'1{wert}:{k.get("Target")}')
    elif k.get('Type') == 'Variable' and wert: s['environment'][k.get('Target')] = wert
    elif k.get('Type') == 'Path':
        ziel = wert.replace('/mnt/user/appdata/ablago', sys.argv[2]); os.makedirs(ziel, exist_ok=True)
        s['volumes'].append(f'{ziel}:{k.get("Target")}:{k.get("Mode") or "rw"}')
extra = (c.findtext('ExtraParams') or '').split()
if '--init' in extra: s['init'] = True
if 'no-new-privileges:true' in extra: s['security_opt'] = ['no-new-privileges:true']
yaml.safe_dump({'services': {'ablago': s}}, open(sys.argv[1], 'w'))
PY
    # Unraid legt appdata als nobody:users (99:100) an.
    sudo chown -R 99:100 "$arbeit/app" 2>/dev/null || chown -R 99:100 "$arbeit/app"
    PORT=18080 DIENST=ablago
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
# Ohne Code richtet Ablago nur aus dem Heimnetz ein (motom001/dms#1359). Vom Host über den veröffentlichten Port kommt
# die Anfrage hier über das Docker-Gateway, und das gilt seit #1355/#1463 nicht als Heimnetz. Deshalb schickt sie ein
# Container im selben Netz – wie ein Gerät im Heimnetz bzw. der app_proxy von Umbrel. Dafür reicht Node aus dem
# Ablago-Image selbst, ohne weiteres Image.
c=$(dc ps -q "$DIENST")
netz=$(docker inspect -f '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{"\n"}}{{end}}' "$c" | head -1)
bild=$(docker inspect -f '{{.Config.Image}}' "$c")
docker run --rm --network "$netz" --entrypoint node "$bild" -e '
  fetch("http://'"$DIENST"':3000/api/konto/einrichten", { method: "POST",
    headers: { "x-dms": "1", "content-type": "application/json" },
    body: JSON.stringify({ mandant: "Familie Probe", name: "Admin", email: "admin@probe.invalid", passwort: "ein-langes-probe-passwort" }) })
  .then(async (r) => { if (!r.ok) { console.error(r.status, await r.text()); process.exit(1); } })
  .catch((e) => { console.error(e); process.exit(1); });' || { echo "::error::$ART: Einrichten scheitert"; exit 1; }
dc restart
warte
nachher=$(curl -fsS "http://127.0.0.1:$PORT/api/konto/status")
[ "$(echo "$nachher" | jq -r '.einrichtungNoetig')" = false ] || { echo "::error::$ART: nach dem Neustart wieder uneingerichtet"; exit 1; }
curl -fsS -X POST "http://127.0.0.1:$PORT/api/konto/anmelden" -H 'x-dms: 1' -H 'content-type: application/json' \
  -d '{"email":"admin@probe.invalid","passwort":"ein-langes-probe-passwort"}' >/dev/null \
  || { echo "::error::$ART: Anmeldung nach dem Neustart scheitert"; exit 1; }
if [ "$ART" = unraid ]; then
  # PUID/PGID 99:100: alles in appdata gehört nobody:users, damit die Freigabe an die Sicherungen kommt.
  fremd=$(sudo find "$arbeit/app" -mindepth 1 \( ! -uid 99 -o ! -gid 100 \) -printf '%p %U:%G\n' 2>/dev/null | grep -v '/postgres\(/\| \)' | head -5 || true)
  [ -z "$fremd" ] || { echo "::error::unraid: nicht 99:100: $fremd"; exit 1; }
fi
echo "$ART: installiert, eingerichtet, neu gestartet, Anmeldung klappt."
