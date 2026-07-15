#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")" || exit 1

SCENARIO="${1:-minimal}"
FILE="scenarios/${SCENARIO}.json"
[ -f "$FILE" ] || { echo "No scenario: $FILE"; ls scenarios/; exit 1; }

docker network inspect bb-test >/dev/null 2>&1 || docker network create bb-test >/dev/null
docker rm -f bambuddy-test sup-mock >/dev/null 2>&1 || true

RUNDIR=$(mktemp -d /tmp/bambuddy-test.XXXX)
mkdir -p "$RUNDIR"/{data,config,share,media}
cp "$FILE" "$RUNDIR/data/options.json"

docker run -d --name sup-mock --network bb-test \
  -v "$RUNDIR/data/options.json":/mock/options.json:ro supervisor-mock >/dev/null

n=0
while [ $n -lt 20 ]; do
  docker run --rm --network bb-test alpine sh -c \
    'wget -qO- http://sup-mock/addons/self/options/config >/dev/null 2>&1' && break
  n=$((n+1)); sleep 0.5
done

echo "=== scenario: $SCENARIO   rundir: $RUNDIR   →  http://localhost:8000"
docker run --rm --name bambuddy-test --network bb-test -p 8000:8000 \
  -v "$RUNDIR/data":/data -v "$RUNDIR/config":/config \
  -v "$RUNDIR/share":/share -v "$RUNDIR/media":/media \
  -e SUPERVISOR_API=http://sup-mock -e SUPERVISOR_TOKEN=fake \
  bambuddy:test

docker rm -f sup-mock >/dev/null 2>&1 || true