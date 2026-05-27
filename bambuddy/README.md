# BamBuddy Home Assistant Add-on

<p align="center">
  <img src="https://bambuddy.cool/assets/img/logo_transparent.png" alt="BamBuddy" width="300">
</p>

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
[![License][license-shield]](LICENSE)

Self-hosted command center for Bambu Lab printers. Manage your entire printer farm locally — no Bambu Cloud required.

## About

[BamBuddy](https://bambuddy.cool) lets you monitor and control your Bambu Lab printers entirely on your local network. This add-on wraps the official BamBuddy Docker image so it can run directly inside Home Assistant OS/Supervised.

## Installation

1. Add this repository to your Home Assistant add-on store:
   `https://github.com/naked-head/homeassistant-addons`
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
| 3000 | TCP | Slicer bind/detect handshake |
| 3002 | TCP | Slicer bind/detect handshake (alt) |
| 2021 | UDP | SSDP printer discovery |
| 8883 | TCP | MQTT over TLS (Virtual Printer) |
| 6000 | TCP | File transfer tunnel |
| 322 | TCP | RTSP camera streaming (X1/H2/P2) |
| 990 | TCP | FTPS control |
| 2024-2026 | TCP | Proprietary slicer ports (A1/P1S) |
| 50000-50100 | TCP | FTP passive data |

> **Note:** Port 8883 is also used by MQTT brokers. If you already run Mosquitto or another broker on this port, configure a separate IP alias and set `bind_address` accordingly.

## Add BamBuddy to the Home Assistant sidebar

Since BamBuddy's web interface cannot be embedded via HA Ingress, you can add it as a sidebar panel:

1. Go to **Settings → Dashboards**.
2. Click **Add Dashboard** in the bottom right.
3. Choose **Webpage**.
4. Fill in the fields:
   - **Title**: `BamBuddy`
   - **Icon**: `mdi:printer-3d`
   - **URL**: `http://<your-ha-ip>:8000`
5. Click **Create** — BamBuddy will appear in your sidebar.

## Virtual Printer setup

### Step 1 — Create a virtual printer in BamBuddy

1. Open BamBuddy at `http://<your-ha-ip>:8000`
2. Go to **Virtual Printers** and create a new printer
3. Note the IP, serial number and access code assigned to the virtual printer

### Step 2 — Download the CA certificate

1. In BamBuddy go to **Settings → Virtual Printer**
2. Download the **CA Certificate** (`bbl_ca.crt`)

### Step 3 — Add the certificate to BambuStudio

Open BambuStudio and append the contents of `bbl_ca.crt` to the slicer certificate file.

**Standard installation:**
```
<BambuStudio install path>/resources/cert/printer.cer
```

**Flatpak installation possible path:**
```
/var/lib/flatpak/app/com.bambulab.BambuStudio/current/active/files/share/BambuStudio/resources/cert/printer.cer
/var/lib/flatpak/app/com.bambulab.BambuStudio/current/active/files/share/BambuStudio/cert/printer.cer
```

> **Note:** If you update BambuStudio via Flatpak, you will need to re-add the certificate as updates overwrite `printer.cer`.

### Step 4 — Add the virtual printer in BambuStudio

1. In BambuStudio go to **Device → Add Printer**
2. Select **Add a new Bambu Lab printer**
3. Enter the IP, serial number and access code from Step 1

Embed BamBuddy in the Home Assistant sidebar via Cloudflare

If you access Home Assistant via HTTPS and use Cloudflare Tunnel for BamBuddy, you need to allow HA to embed BamBuddy in an iframe. By default BamBuddy sets a `Content-Security-Policy` header that blocks embedding.

### Step 1 — Create a Cloudflare Transform Rule

1. Go to **Cloudflare Dashboard → your domain → Rules → Overview**
2. Click **Create rule** and select **Response Header Transform Rule**
3. Give the rule a name (e.g. `BamBuddy iframe`)
4. Configure the rule:

**When incoming requests match:**
- Field: `Hostname`
- Operator: `equals`
- Value: `bambuddy.yourdomain.com`

**Then modify response header:**
- Operation: `Set`
- Header name: `Content-Security-Policy`
- Value: `frame-ancestors 'self' https://your-ha-domain.com`

Replace `https://your-ha-domain.com` with the URL you use to access Home Assistant.

5. Click **Deploy**

### Step 2 — Add BamBuddy to the sidebar

1. Go to **Settings → Dashboards**
2. Click **Add Dashboard** → **Webpage**
3. Fill in the fields:
   - **Title**: `BamBuddy`
   - **Icon**: `mdi:printer-3d`
   - **URL**: `https://bambuddy.yourdomain.com`
4. Click **Create**

## Support
- [BamBuddy Documentation](https://wiki.bambuddy.cool)
- [BamBuddy GitHub](https://github.com/maziggy/bambuddy)
- [Add-on GitHub](https://github.com/naked-head/homeassistant-addons)

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[license-shield]: https://img.shields.io/badge/license-MIT-green.svg
