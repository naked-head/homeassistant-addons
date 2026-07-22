# InfluxDB – Home Assistant App

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
[![License][license-shield]](../LICENSE)

A Home Assistant app that runs [InfluxDB](https://www.influxdata.com/) OSS
**v2.8.0** — the time-series database, useful for storing Home Assistant's
long-term history (via the `influxdb:` integration) or any other time-series
data. Fills the gap left by `hassio-addons/addon-influxdb`, which only
covers InfluxDB v1.x and is no longer maintained.

This app is part of the [`naked-head/homeassistant-addons`](https://github.com/naked-head/homeassistant-addons) collection.

---

## Requirements

- Home Assistant OS or Supervised installation (Supervisor required)
- amd64 or aarch64 architecture

---

## Installation

### Via button (recommended)

[![Add Repository to Home Assistant](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https://github.com/naked-head/homeassistant-addons)

### Manual

1. In Home Assistant, go to **Settings → Apps → App Store**.
2. Click the three-dot menu → **Repositories**.
3. Add `https://github.com/naked-head/homeassistant-addons`.
4. Find **InfluxDB** in the store and click **Install**.

---

## Configuration

| Option | Default | Description |
|---|---|---|
| `reporting` | `false` | Send anonymous usage data to InfluxData |
| `log_level` | `info` | `trace`, `debug`, `info`, `warn`, `error`, `fatal` |
| `init_mode` | `skip` | `skip`: set up org/bucket/user/token yourself from the Web UI. `setup`: do it automatically on first boot using the options below |
| `init_username` / `init_password` / `init_org` / `init_bucket` | *(unset)* | Required only if `init_mode: setup` |
| `init_admin_token` | *(unset)* | Optional fixed operator token; leave empty to let InfluxDB generate one |
| `init_retention` | `"0"` | Initial bucket retention in seconds, `"0"` = infinite |

See the [full documentation](DOCS.md) for details, migration notes (including
from an existing Raspberry Pi / Docker install), and backup/restore examples.

---

## Web UI

No Ingress: InfluxDB's own web UI isn't built to run behind a proxied
subpath. Use the **Open Web UI** button on the app's Info tab instead — it
opens `http://<host>:8086` directly.

---

## Support

- [Full documentation](DOCS.md)
- [InfluxDB OSS v2 documentation](https://docs.influxdata.com/influxdb/v2/)
- [App issues](https://github.com/naked-head/homeassistant-addons/issues)

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[license-shield]: https://img.shields.io/badge/license-MIT-green.svg
