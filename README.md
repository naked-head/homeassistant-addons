# Home Assistant Apps

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

A collection of Home Assistant apps.

## Installation

1. Navigate to **Settings → Apps → App Store** in Home Assistant.
2. Click the three-dot menu in the top right and select **Repositories**.
3. Add the following URL: `https://github.com/naked-head/homeassistant-addons`
4. Find the app you want in the store and click **Install**.

## Apps

### [BamBuddy](./bambuddy)

Self-hosted command center for Bambu Lab printers. Manage your entire printer farm locally, without Bambu Cloud.

### [Bambu Studio API](./bambu-studio-api)
Headless Bambu Studio CLI wrapped in a REST API. Sidecar for Bambuddy server-side slicing — lets Bambuddy dispatch slice jobs without a desktop slicer install. amd64 only.

### [InfluxDB](./influxdb)
InfluxDB OSS 2.8.0, the time-series database, for Home Assistant long-term history or any other time-series data. Fills the gap left by `hassio-addons/addon-influxdb`, which only covers v1.x and is no longer maintained.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
