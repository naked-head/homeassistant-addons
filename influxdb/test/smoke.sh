#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")" || exit 1

NET=influxdb-test
IMG="${INFLUXDB_IMAGE:-ghcr.io/naked-head/ha-app-influxdb-amd64:latest}"

if ss -lnt | grep -q ':8086 '; then
  echo "✘ port 8086 in use — close tunnel/container first"; exit 1
fi

docker network inspect "$NET" >/dev/null 2>&1 || docker network create "$NET" >/dev/null

cleanup() { docker rm -f influxdb-smoke influxdb-mock >/dev/null 2>&1; }
trap cleanup EXIT

FAIL=0
for f in scenarios/*.json; do
  s=$(basename "$f" .json)
  echo "─── $s"
  cleanup

  RUNDIR=$(mktemp -d /tmp/influxdb-smoke.XXXX)
  mkdir -p "$RUNDIR/data"
  cp "$f" "$RUNDIR/options.json"

  docker run -d --name influxdb-mock --network "$NET" \
    -v "$RUNDIR/options.json":/mock/options.json:ro \
    supervisor-mock >/dev/null

  n=0
  while [ $n -lt 20 ]; do
    docker run --rm --network "$NET" alpine sh -c \
      'wget -qO- http://influxdb-mock/addons/self/options/config >/dev/null 2>&1' && break
    n=$((n+1)); sleep 0.5
  done

  docker run -d --name influxdb-smoke --network "$NET" -p 8086:8086 \
    -v "$RUNDIR/data":/data \
    -e SUPERVISOR_API=http://influxdb-mock \
    -e SUPERVISOR_TOKEN=fake \
    "$IMG" >/dev/null

  ok=0
  n=0
  while [ $n -lt 60 ]; do
    curl -sf -o /dev/null http://127.0.0.1:8086/health && { ok=1; break; }
    n=$((n+1)); sleep 1
  done

  L=$(docker logs influxdb-smoke 2>&1 | sed 's/\x1b\[[0-9;]*m//g')

  # setup-missing is expected to refuse to start (validation failure), not
  # come up healthy — handle it separately and skip the generic checks below.
  if [ "$s" = "setup-missing" ]; then
    if [ "$ok" = 1 ]; then
      echo "  ✘ /health came up, but this scenario should have failed validation"
      FAIL=1
    else
      echo "  ✔ correctly refused to start"
    fi
    grep -q 'is empty.' <<<"$L" \
      || { echo "  ✘ expected validation error message missing"; FAIL=1; }

    cleanup
    docker run --rm -v "$RUNDIR":/x alpine rm -rf /x/data /x/options.json >/dev/null 2>&1
    rmdir "$RUNDIR" 2>/dev/null
    continue
  fi

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
    setup)
      grep -q 'init_mode=setup: preparing automatic setup for first boot.' <<<"$L" \
        || { echo "  ✘ setup mode not applied"; FAIL=1; }

      # Use jq instead of grepping for an exact string: InfluxDB may or may
      # not put a space after the colon depending on version/build, and a
      # raw grep on '"allowed":false' is fragile to that formatting detail.
      setup_response=$(curl -sf http://127.0.0.1:8086/api/v2/setup)
      if ! jq -e '.allowed == false' <<<"$setup_response" >/dev/null 2>&1; then
        echo "  ✘ initial setup did not complete (/api/v2/setup still allows setup)"
        echo "    raw response: ${setup_response}"
        FAIL=1
      fi
      ;;
    default|empty)
      grep -q 'init_mode=skip: no automatic setup' <<<"$L" \
        || { echo "  ✘ skip mode not applied"; FAIL=1; }
      ;;
  esac

  cleanup
  docker run --rm -v "$RUNDIR":/x alpine rm -rf /x/data /x/options.json >/dev/null 2>&1
  rmdir "$RUNDIR" 2>/dev/null
done

if [ "$FAIL" = 0 ]; then echo "ALL PASS"; else echo "FAILURES"; fi
exit $FAIL