# Bambu Studio API – Home Assistant App

A Home Assistant App that runs the **Bambu Studio API** sidecar — a headless
Bambu Studio CLI wrapped in a REST API — so [Bambuddy](https://github.com/maziggy/bambuddy)
(and anything else that speaks the same API) can dispatch server-side slicing
jobs without a desktop slicer install.

This packages the `bambu-studio-api` service from the upstream
[`maziggy/orca-slicer-api`](https://github.com/maziggy/orca-slicer-api) fork
(branch `bambuddy/profile-resolver`) as a first-class HA add-on. See the
[Bambuddy slicer-api docs](https://wiki.bambuddy.cool/features/slicer-api/) for
how the sidecar fits into the broader workflow.

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

[![Add Repository to Home Assistant](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https://github.com/griffinmartin/ha-app-bambu-studio-api)

### Manual

1. In Home Assistant, go to **Settings → Apps → App Store** (or **Add-on Store**).
2. Click the three-dot menu → **Repositories**.
3. Add `https://github.com/griffinmartin/ha-app-bambu-studio-api`.
4. Find **Bambu Studio API** in the store and click **Install**.

The first install takes **5–10 minutes** because the add-on downloads the
official Bambu Studio AppImage (~220 MB) and builds the Node wrapper. Later
updates reuse the cached layers.

---

## Configuration

After install:

1. Open **Bambu Studio API → Configuration → Network**.
2. The host port defaults to **3001** (matches the Bambuddy wiki's default
   for the `bambu-studio-api` sidecar). Change it here if 3001 is already
   taken on your HA host.
3. Open **Configuration → Options** and toggle `debug` if you need verbose logs.
4. Start the add-on.

Then in Bambuddy:

1. **Settings → Workflow → Slicer**.
2. **Preferred Slicer:** Bambu Studio.
3. Toggle **Use Slicer API** on.
4. **Sidecar URL:** `http://<your-ha-ip>:3001` (or whatever host port you chose).

Health check: `http://<your-ha-ip>:3001/health`.

---

## Data persistence

Slicer profiles, uploaded presets, and the sidecar's working data live in:

```
addon_configs/<slug>_bambu_studio_api/data/
```

accessible via the **File Editor** add-on. Data survives updates, restarts,
and reinstalls (as long as you opt to keep add-on data on uninstall).

---

## Updating the bundled Bambu Studio version

The Bambu Studio AppImage version is pinned at build time via the
`BAMBU_VERSION` build-arg in the add-on's `Dockerfile`. To bump it, edit
`bambu-studio-api/Dockerfile`, bump the add-on `version` in
`bambu-studio-api/config.yaml`, and add a `CHANGELOG.md` entry. Home Assistant
will then offer the new version as a regular add-on update.

---

## Disclaimer

This is **not** an official release by Bambu Lab, by Bambuddy's maintainers,
or by the upstream `orca-slicer-api` authors. This repository simply packages
the upstream `bambu-studio-api` service as a native Home Assistant App for
easier installation alongside Bambuddy.

I am not affiliated with any of these upstream projects and cannot provide
support for issues in the slicer CLI or the wrapper itself. For those, please
file issues upstream:

- Bambu Studio: <https://github.com/bambulab/BambuStudio>
- Slicer API wrapper: <https://github.com/maziggy/orca-slicer-api>
- Bambuddy: <https://github.com/maziggy/bambuddy>

Support here is limited to the **HA add-on packaging** itself.

---

## License

MIT — see [LICENSE](./LICENSE). The bundled Bambu Studio binary and the
upstream wrapper are covered by their own licenses (AGPL-3.0 for the wrapper,
Bambu Lab's terms for the Bambu Studio binary).
