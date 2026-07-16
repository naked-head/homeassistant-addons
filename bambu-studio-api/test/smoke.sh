#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")" || exit 1

NET=bsa-test
IMG="${BSA_IMAGE:-ghcr.io/naked-head/ha-app-bambu-studio-api-amd64:latest}"

if ss -lnt | grep -q ':3001 '; then
  echo "✘ port 3001 in use — close tunnel/container first"; exit 1
fi

docker network inspect "$NET" >/dev/null 2>&1 || docker network create "$NET" >/dev/null

cleanup() { docker rm -f bsa-smoke bsa-mock >/dev/null 2>&1; }
trap cleanup EXIT

FAIL=0
for f in scenarios/*.json; do
  s=$(basename "$f" .json)
  echo "─── $s"
  cleanup

  RUNDIR=$(mktemp -d /tmp/bsa-smoke.XXXX)
  mkdir -p "$RUNDIR"/config
  cp "$f" "$RUNDIR/options.json"

  docker run -d --name bsa-mock --network "$NET" \
    -v "$RUNDIR/options.json":/mock/options.json:ro \
    supervisor-mock >/dev/null

  n=0
  while [ $n -lt 20 ]; do
    docker run --rm --network "$NET" alpine sh -c \
      'wget -qO- http://bsa-mock/addons/self/options/config >/dev/null 2>&1' && break
    n=$((n+1)); sleep 0.5
  done

  docker run -d --name bsa-smoke --network "$NET" -p 3001:3000 \
    -v "$RUNDIR/config":/config \
    -e SUPERVISOR_API=http://bsa-mock \
    -e SUPERVISOR_TOKEN=fake \
    "$IMG" >/dev/null

  ok=0
  n=0
  while [ $n -lt 60 ]; do
    curl -sf -o /dev/null http://127.0.0.1:3001/health && { ok=1; break; }
    n=$((n+1)); sleep 1
  done

  L=$(docker logs bsa-smoke 2>&1 | sed 's/\x1b\[[0-9;]*m//g')

  if [ "$ok" = 1 ]; then
    echo "  ✔ /health up"
  else
    echo "  ✘ /health DOWN"
    tail -30 <<<"$L"
    FAIL=1
  fi

  grep -qiE 'traceback|unbound variable|Failed to get addon config' <<<"$L" && {
    echo "  ✘ errors in log"
    grep -iE 'traceback|unbound variable|Failed to get addon config' <<<"$L" | head -5
    FAIL=1
  }

  case "$s" in
    debug)
      grep -q 'Debug logging ON' <<<"$L" \
        || { echo "  ✘ debug flag not applied"; FAIL=1; }
      ;;
    default|empty)
      grep -q 'Debug logging ON' <<<"$L" \
        && { echo "  ✘ debug enabled when it should not be"; FAIL=1; }
      ;;
  esac

  grep -q 'Linking persistent data directory' <<<"$L" \
    || { echo "  ✘ data dir linking missing"; FAIL=1; }

  cleanup
  docker run --rm -v "$RUNDIR":/x alpine rm -rf /x/config /x/options.json >/dev/null 2>&1
  rmdir "$RUNDIR" 2>/dev/null
done

if [ "$FAIL" = 0 ]; then echo "ALL PASS"; else echo "FAILURES"; fi
exit $FAIL