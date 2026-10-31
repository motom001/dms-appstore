#!/usr/bin/env python3
"""
Erzeugt die App-Einträge aus den Vorlagen (vorlagen/) für eine DMS-Version.

    python3 werkzeuge/erzeugen.py <version> <dms-image@sha256:…> <postgres-image@sha256:…> <dms-komplett-image@sha256:…> [datum]

  motom001-dms/          Umbrel (Community App Store; umbrel-app-store.yml liegt im Hauptordner)
  Apps/DMS/              ZimaOS/CasaOS (Quelle für den v2-Store und die v1-Zip-Datei)
  truenas/dms/           TrueNAS-Katalog (für einen PR an truenas/apps, ix-dev/community/dms)
  offiziell/umbrel/dms/  Umbrel offizieller Store (für einen PR an getumbrel/umbrel-apps, #186)

Die erzeugten Dateien werden eingecheckt: Umbrel und CasaOS (v1) lesen das Repository direkt.
"""
import os, re, shutil, sys
from datetime import date
from pathlib import Path

WURZEL = Path(__file__).resolve().parent.parent
CDN = 'https://cdn.jsdelivr.net/gh/motom001/dms-appstore@main/Apps/DMS'
SCREENSHOTS = ['screenshot-1.png', 'screenshot-2.png', 'screenshot-3.png']
MINDESTENS = (0, 42, 0)  # ab hier: DMS_EINRICHTUNGSCODE=aus und dms-komplett (ZimaOS/CasaOS)


def main():
    if len(sys.argv) < 5:
        sys.exit(__doc__)
    version, dms, pg, komplett = sys.argv[1].lstrip('v'), sys.argv[2], sys.argv[3], sys.argv[4]
    datum = sys.argv[5] if len(sys.argv) > 5 else date.today().isoformat()
    m = re.fullmatch(r'(\d+)\.(\d+)\.(\d+)', version)
    if not m:
        sys.exit(f'Version {version!r} ist keine Release-Nummer wie 0.39.0')
    if tuple(map(int, m.groups())) < MINDESTENS and not os.environ.get('PRUEFLAUF'):
        sys.exit(f'DMS {version} ist zu alt für die App-Stores (mindestens {".".join(map(str, MINDESTENS))})')
    for bild in (dms, pg, komplett):
        if not re.fullmatch(r'[\w./-]+:[\w.-]+@sha256:[0-9a-f]{64}', bild):
            sys.exit(f'Image {bild!r}: erwartet name:tag@sha256:…')

    werte = {
        'VERSION': version,
        'DMS_IMAGE': dms,
        'POSTGRES_IMAGE': pg,
        'DMS_KOMPLETT_IMAGE': komplett,
        'DATUM': datum,
        'ICON': f'{CDN}/icon.png',
        'HINWEISE': f'What is new: https://github.com/motom001/dms/releases/tag/v{version}',
        'HINWEISE_DE': f'Was neu ist: https://github.com/motom001/dms/releases/tag/v{version}',
        'GALERIE': '\n'.join(f'  - {CDN}/{s}' for s in SCREENSHOTS),
        'SCREENSHOTS': '\n'.join(f'    - {CDN}/{s}' for s in SCREENSHOTS),
    }

    def fuelle(text: str) -> str:
        aus = re.sub(r'\{\{(\w+)\}\}', lambda x: werte[x.group(1)], text)
        rest = re.findall(r'\{\{\w+\}\}', aus)
        if rest:
            sys.exit(f'Nicht ersetzt: {rest}')
        return aus

    # Umbrel
    ziel = WURZEL / 'motom001-dms'
    if ziel.exists():
        shutil.rmtree(ziel)
    ziel.mkdir()
    for name in ('umbrel-app.yml', 'docker-compose.yml', 'exports.sh'):
        (ziel / name).write_text(fuelle((WURZEL / 'vorlagen/umbrel' / name).read_text()))
    # Ordner für die Bind-Mounts müssen beim ersten Start existieren.
    for o in ('files', 'geheim', 'sicherung', 'postgres'):
        (ziel / 'data' / o).mkdir(parents=True)
        (ziel / 'data' / o / '.gitkeep').write_text('')

    # ZimaOS/CasaOS
    apps = WURZEL / 'Apps/DMS'
    apps.mkdir(parents=True, exist_ok=True)
    (apps / 'docker-compose.yml').write_text(fuelle((WURZEL / 'vorlagen/casaos/docker-compose.yml').read_text()))

    # TrueNAS: Tag samt Digest wie im Katalog üblich („0.40.0@sha256:…“)
    werte['DMS_TAG'] = dms.split(':', 1)[1]
    quelle = WURZEL / 'vorlagen/truenas/dms'
    ziel = WURZEL / 'truenas/dms'
    if ziel.exists():
        shutil.rmtree(ziel)
    for datei in quelle.rglob('*'):
        if datei.is_file():
            aus = ziel / datei.relative_to(quelle)
            aus.parent.mkdir(parents=True, exist_ok=True)
            text = datei.read_text()
            # Jinja der Vorlage ({% … %}, {{ tpl… }}) unangetastet lassen, nur unsere Platzhalter ersetzen.
            aus.write_text(re.sub(r'\{\{(VERSION|DATUM|DMS_TAG)\}\}', lambda x: werte[x.group(1)], text))

    # Umbrel offiziell (#186): App-ID „dms“ ohne Store-Präfix; Symbol und Galerie stellt das
    # Umbrel-Team, submission ist der PR an getumbrel/umbrel-apps.
    off = WURZEL / 'offiziell/umbrel/dms'
    if off.exists():
        shutil.rmtree(off)
    shutil.copytree(WURZEL / 'motom001-dms', off)
    for datei in off.rglob('*'):
        if not datei.is_file() or datei.name == '.gitkeep':
            continue
        t = datei.read_text().replace('motom001-dms', 'dms').replace('APP_MOTOM001_DMS_', 'APP_DMS_')
        if datei.name == 'umbrel-app.yml':
            t = re.sub(r'^icon: .*\n', '', t, flags=re.M)
            t = re.sub(r'^gallery:\n(  - .*\n)+', 'gallery: []\n', t, flags=re.M)
            t = t.replace('releaseNotes: >-\n  ' + werte['HINWEISE'], 'releaseNotes: ""')
            t = t.replace('submission: https://github.com/motom001/dms-appstore', 'submission: https://github.com/getumbrel/umbrel-apps/pull/TODO')
        datei.write_text(t)

    print(f'App-Einträge für DMS {version} erzeugt.')


if __name__ == '__main__':
    main()
