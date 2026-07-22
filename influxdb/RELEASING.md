# Releasing InfluxDB

Like Bambu Studio API, this app ships a **pre-built image** (`image:` in
`config.yaml`, published to GHCR by `.github/workflows/influxdb-build.yml`).
The image must exist for every supported architecture before users can
install the new version — otherwise HA offers a version whose image can't be
pulled for that arch, and the Supervisor falls back to building the
Dockerfile locally (slow: it re-downloads and re-installs s6-overlay +
bashio on top of the InfluxDB base image on the user's own hardware).

## Order matters

1. Bump `version:` in `config.yaml`
2. Update `CHANGELOG.md`
3. Merge to `main` — this triggers the builder for **both** amd64 and
   aarch64
4. **Wait for the builder to finish** and verify both tags exist:
   - `ghcr.io/naked-head/ha-app-influxdb-amd64:<version>`
   - `ghcr.io/naked-head/ha-app-influxdb-aarch64:<version>`
5. Only then tag and publish the release

## Before merging

- [ ] CI green (shellcheck, yaml, smoke)
- [ ] `./influxdb/test/smoke.sh` passes locally
- [ ] Fresh install tested (empty `/data`, setup from the Web UI)
- [ ] `init_mode: setup` tested end-to-end (org/bucket/user created, token
      usable)
- [ ] Upgrade tested (existing `/data` from a previous version — no crash,
      no data loss, `init_mode: setup` correctly ignored)
- [ ] `version:` bumped in `config.yaml`
- [ ] `CHANGELOG.md` updated
- [ ] New/changed options documented in `DOCS.md`, `README.md` and
      `translations/`

## Verify the images were published

    docker pull ghcr.io/naked-head/ha-app-influxdb-amd64:2.8.0-1
    docker pull ghcr.io/naked-head/ha-app-influxdb-aarch64:2.8.0-1

If either pull fails, do not tag the release yet.

## Beta first

Same rule as the other apps in this repo — release as pre-release first
when the change contains:

- a bump of the pinned `influxdb:x.y.z` base image tag in the Dockerfile
- a change to `config.yaml` schema or options
- a refactor of `rootfs/etc/services.d/influxdb/run`
- an s6-overlay or bashio version bump

```
git tag influxdb-v2.8.0-2-beta.1
git push origin influxdb-v2.8.0-2-beta.1
```

GitHub → Releases → Draft new release → select the tag →
check **Set as a pre-release**.

Only users with "Show beta versions" enabled will see it. Wait a few days.
No reports → promote to stable.

## Stable release

```
git tag influxdb-v2.8.0-2
git push origin influxdb-v2.8.0-2
```

GitHub → Releases → Draft new release → select the tag → publish (not
pre-release).

## Bumping the pinned InfluxDB version

`FROM influxdb:2.8.0` in the Dockerfile pins an external source that can
change under you:

- Always check the [InfluxDB OSS v2 release notes](https://docs.influxdata.com/influxdb/v2/reference/release-notes/influxdb/)
  before bumping — some 2.x releases change on-disk token storage (see the
  2.9.0 token-hashing change) and may not be silently downgrade-safe.
- **Never** bump to a tag outside the 2.x series (`2`, `latest`, `3-core`,
  etc.) — since 27 May 2026 the `latest`/`2` tags on Docker Hub point to
  InfluxDB 3 Core, which is not compatible with an existing v2 database.
- After bumping, re-run the full "Before merging" checklist above,
  including a real upgrade test against `/data` from the previous pinned
  version.

Both of the above are reasons to release as beta first.

## If it breaks in production

1. Tag the previous known-good commit as a new patch version — don't
   force-push or delete the bad tag; users who already upgraded need a
   version number higher than the broken one.
2. Add a scenario to `test/scenarios/` that reproduces the failure.
3. Verify the new scenario fails against the broken image, passes against
   the fix.
