# BamBuddy Home Assistant Add-on

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
[![License][license-shield]](LICENSE)

Self-hosted command center for Bambu Lab printers. Manage your entire printer farm locally — no Bambu Cloud required.

## About

[BamBuddy](https://bambuddy.cool) lets you monitor and control your Bambu Lab printers entirely on your local network. This add-on wraps the official BamBuddy Docker image so it can run directly inside Home Assistant OS/Supervised.

## Installation

1. Add this repository to your Home Assistant add-on store:
   `https://github.com/naked-head/ha-addon-bambuddy`
2. Install the **BamBuddy** add-on.
3. Configure the options (see below).
4. Start the add-on.
5. Open the Web UI on port **8000** of your Home Assistant host.

## Configuration

| Option | Default | Description |
|---|---|---|
| `bind_address` | *(empty)* | IP to bind to. Leave empty for all interfaces, or set a specific IP alias (e.g. `192.168.50.53`) |
| `timezone` | `Europe/Rome` | Your local timezone |
| `log_level` | `info` | Log verbosity: `trace`, `debug`, `info`, `warning`, `error` |

## Ports

| Port | Protocol | Description |
|---|---|---|
| 8000 | TCP | BamBuddy Web UI |
| 1883 | TCP | MQTT (Virtual Printer) |
| 8883 | TCP | MQTT over TLS (Virtual Printer) |
| 2222 | TCP | SFTP (Virtual Printer) |

> **Note:** Port 8883 is also used by MQTT brokers. If you already run Mosquitto or another broker on this port, configure a separate IP alias and set `bind_address` accordingly.

## Home Assistant Panel

Since BamBuddy's web interface cannot be embedded via HA Ingress (due to SPA architecture constraints), you can add it as a sidebar panel:

1. Go to **Settings → Dashboards**.
2. Click **Add Dashboard** and choose **Webpage**.
3. Set the URL to `http://<your-ha-ip>:8000`.
4. It will appear in your sidebar.

## Virtual Printer & BambuStudio

To use Virtual Printer with BambuStudio, you need to add BamBuddy's CA certificate to the slicer. See the [official documentation](https://wiki.bambuddy.cool/features/virtual-printer/) for instructions.

If you use BambuStudio installed via **Flatpak**, the certificate file is at:
```
/var/lib/flatpak/app/com.bambulab.BambuStudio/current/active/files/share/BambuStudio/resources/cert/printer.cer
```

## Support

- [BamBuddy Documentation](https://wiki.bambuddy.cool)
- [BamBuddy GitHub](https://github.com/maziggy/bambuddy)
- [Add-on GitHub](https://github.com/naked-head/ha-addon-bambuddy)

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[license-shield]: https://img.shields.io/github/license/naked-head/ha-addon-bambuddy.svg
