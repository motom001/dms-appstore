#!/usr/bin/env bash
# Legt die Images als tar-Dateien ab, wie ugcli sie erwartet (rootfs_{arch}/images/, ein Tag je Datei).
#   ugreen/bilder-holen.sh 0.40.0
set -euo pipefail
V="${1:?Version, z. B. 0.40.0}"
cd "$(dirname "$0")"
sed -i "s#ghcr.io/motom001/dms:[0-9.]*#ghcr.io/motom001/dms:$V#" rootfs_common/docker-compose.yaml
sed -i "s#^version: .*#version: \"$V\"#" project.yaml
for arch in amd64 arm64; do
  mkdir -p "rootfs_$arch/images"
  for bild in "ghcr.io/motom001/dms:$V" postgres:17; do
    docker pull --platform "linux/$arch" "$bild"
    docker save "$bild" -o "rootfs_$arch/images/$(echo "$bild" | tr '/:' '__').tar"
  done
done
echo "Fertig. Jetzt: ugcli pack --build 1"
