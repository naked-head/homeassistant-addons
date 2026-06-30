# Bambu Studio API – Home Assistant Add-on

A Home Assistant add-on that runs the **Bambu Studio API** sidecar — a headless
Bambu Studio CLI wrapped in a REST API — so [Bambuddy](https://github.com/maziggy/bambuddy)
(and anything else that parla la stessa API) can dispatch server-side slicing
jobs without a desktop slicer install.

This add-on packages the `bambu-studio-api` service from the upstream
[`maziggy/orca-slicer-api`](https://github.com/maziggy/orca-slicer-api) fork
(branch `bambuddy/profile-resolver`) as a first-class HA add-on.
See the [Bambuddy slicer-api docs](https://wiki.bambuddy.cool/features/slicer-api/)
for how the sidecar fits into the broader workflow.

> **Forked from** [`griffinmartin/ha-app-bambu-studio-api`](https://github.com/griffinmartin/ha-app-bambu-studio-api).
> This repository is part of the [`naked-head/homeassistant-addons`](https://github.com/naked-head/homeassistant-addons)
> collection alongside the [BamBuddy add-on](../homeassistant-addon/).

![amd64 only](https://img.shields.io/badge/amd64-yes-green.svg)
![aarch64 unsupported](https://img.shields.io/badge/aarch64-no-red.svg)

---

## Requirements

- Home Assistant OS or Supervised installation (Supervisor required)
- **amd64 architecture only** — Bambu Lab does not publish an ARM64 AppImage,
  so this add-on cannot be built on aarch64 hosts. See the
  [platform requirements section of the Bambuddy wiki](https://wiki.bambuddy.cool/features/slicer-api/#platform-requirements)
  for context.

---

## Installation

### Via button (recommended)

[![Add Repository to Home Assistant](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https://github.com/naked-head/homeassistant-addons)

### Manual

1. In Home Assistant, go to **Settings → Add-ons → Add-on Store**.
2. Click the three-dot menu → **Repositories**.
3. Add `https://github.com/naked-head/homeassistant-addons`.
4. Find **Bambu Studio API** in the store and click **Install**.

The first install takes **5–10 minutes** because the add-on downloads the
official Bambu Studio AppImage (~220 MB) and builds the Node wrapper.
Later updates reuse the cached layers.

---

## Configuration

After install:

1. Open **Bambu Studio API → Configuration → Network**.
2. The host port defaults to **3001** (matches the Bambuddy wiki's default
   for the `bambu-studio-api` sidecar). Change it here if 3001 is already
   taken on your HA host.
3. Toggle `debug` under **Configuration → Options** if you need verbose logs.
4. Start the add-on.

Then in Bambuddy:

1. **Settings → Workflow → Slicer**
2. **Preferred Slicer:** Bambu Studio
3. Toggle **Use Slicer API** on
4. **Sidecar URL:** `http://<your-ha-ip>:3001`

Health check: `http://<your-ha-ip>:3001/health`

---

## Data persistence

Slicer profiles, uploaded presets, and the sidecar's working data live in:

addon_configs/<slug>_bambu_studio_api/data/

accessible via the **File Editor** add-on. Data survives updates, restarts,
and reinstalls (as long as you opt to keep add-on data on uninstall).

---

## Updates

Bambu Studio version bumps are handled automatically via a GitHub Actions workflow
that runs daily. When a new [BambuStudio release](https://github.com/bambulab/BambuStudio/releases)
is detected, a Pull Request is opened against this repository with the updated
`Dockerfile`, `config.yaml`, and `CHANGELOG.md`. Once the PR is merged, Home
Assistant will offer the new version as a regular add-on update.

No manual intervention is needed beyond merging the PR.

---

## Disclaimer

This is **not** an official release by Bambu Lab, by Bambuddy's maintainers,
or by the upstream `orca-slicer-api` authors. This repository simply packages
the upstream `bambu-studio-api` service as a native Home Assistant add-on for
easier installation alongside Bambuddy.

Support here is limited to the **HA add-on packaging** itself. For upstream issues:

- Bambu Studio: <https://github.com/bambulab/BambuStudio>
- Slicer API wrapper: <https://github.com/maziggy/orca-slicer-api>
- Bambuddy: <https://github.com/maziggy/bambuddy>
- Original HA add-on packaging: <https://github.com/griffinmartin/ha-app-bambu-studio-api>

---

## License

MIT — see [LICENSE](../LICENSE). The bundled Bambu Studio binary and the
upstream wrapper are covered by their own licenses (AGPL-3.0 for the wrapper,
Bambu Lab's terms for the Bambu Studio binary).
