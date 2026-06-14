# BamBuddy – Documentation

This app wraps the official [BamBuddy](https://bambuddy.cool) Docker image as a native Home Assistant Supervisor app, providing local management of Bambu Lab printers without Bambu Cloud.

This app is part of the [`naked-head/homeassistant-addons`](https://github.com/naked-head/homeassistant-addons) collection.

---

## Configuration Options

| Option | Type | Default | Description |
|---|---|---|---|
| `bind_address` | string | *(empty)* | IP address BamBuddy binds to. Leave empty for all interfaces (`0.0.0.0`), or set a specific IP alias (e.g. `192.168.50.53`) |
| `timezone` | string | `Europe/Rome` | Your local timezone |
| `log_level` | string | `info` | Log verbosity: `trace`, `debug`, `info`, `notice`, `warning`, `error`, `fatal` |
| `trusted_frame_origins` | string | *(empty)* | Space-separated list of origins allowed to embed BamBuddy in an iframe. Required to use BamBuddy as a HA sidebar webpage panel (e.g. `http://192.168.1.100:8123 https://ha.yourdomain.com`) |

---

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
| 50000-50029 | TCP | FTP passive data |

> **Note:** Port 8883 is also used by MQTT brokers. If you already run Mosquitto or another broker on this port, configure a separate IP alias on your network interface and set `bind_address` to that alias.

---

## Add BamBuddy to the Home Assistant sidebar

BamBuddy's web interface cannot be embedded via HA Ingress due to SPA architecture constraints. You can add it as a Webpage dashboard panel instead.

> **How iframe embedding works:** the Webpage panel loads BamBuddy in an iframe directly in the user's browser. This means the browser must be able to reach BamBuddy directly — Home Assistant only acts as a visual container, not as a proxy. This has an important implication: if you access HA via HTTPS from outside your network, the browser will block an HTTP iframe due to mixed content policy.

### Option 1 — Local HTTP access

If you access Home Assistant via HTTP on your local network:

1. Set `trusted_frame_origins` in the add-on configuration to your HA URL (e.g. `http://192.168.1.100:8123`).
2. Restart the add-on.
3. Go to **Settings → Dashboards**.
4. Click **Add Dashboard** → **Webpage**.
5. Fill in:
   - **Title**: `BamBuddy`
   - **Icon**: `mdi:printer-3d`
   - **URL**: `http://<your-ha-ip>:8000`
6. Click **Create**.

### Option 2 — HTTPS access via Cloudflare Tunnel

If you access Home Assistant via HTTPS and expose BamBuddy through a Cloudflare Tunnel:

#### Step 1 — Create a Cloudflare Transform Rule

1. Go to **Cloudflare Dashboard → your domain → Rules → Overview**.
2. Click **Create rule** and select **Response Header Transform Rule**.
3. Give the rule a name (e.g. `BamBuddy iframe`).
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

5. Click **Deploy**.

#### Step 2 — Add BamBuddy to the sidebar

1. Go to **Settings → Dashboards**.
2. Click **Add Dashboard** → **Webpage**.
3. Fill in:
   - **Title**: `BamBuddy`
   - **Icon**: `mdi:printer-3d`
   - **URL**: `https://bambuddy.yourdomain.com`
4. Click **Create**.

### Option 3 — HTTPS access via local Nginx reverse proxy

If you want to serve BamBuddy over HTTPS on your local network without exposing it publicly, you can put Nginx in front of BamBuddy with a self-signed certificate.

#### Step 1 — Install Nginx

Install Nginx on your Home Assistant host or on another machine on the LAN. The [Nginx Proxy Manager](https://nginxproxymanager.com/) add-on for Home Assistant is a convenient option.

#### Step 2 — Configure Nginx

Create a server block that proxies BamBuddy and overrides the CSP header:

```nginx
server {
    listen 443 ssl;
    server_name bambuddy.local;

    ssl_certificate     /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        # Override BamBuddy's CSP to allow HA to embed it in an iframe
        proxy_hide_header Content-Security-Policy;
        add_header Content-Security-Policy "frame-ancestors 'self' https://your-ha-domain.com;";
    }
}
```

Replace `your-ha-domain.com` with the URL you use to access Home Assistant.

#### Step 3 — Add BamBuddy to the sidebar

1. Go to **Settings → Dashboards**.
2. Click **Add Dashboard** → **Webpage**.
3. Fill in:
   - **Title**: `BamBuddy`
   - **Icon**: `mdi:printer-3d`
   - **URL**: `https://bambuddy.local`
4. Click **Create**.

> **Note:** If you use a self-signed certificate, your browser may require you to manually accept it by visiting `https://bambuddy.local` once before the iframe loads correctly in HA.

### Option 4 — Remote access via VPN

If you want to access BamBuddy from outside your network without exposing it publicly, use a VPN such as [WireGuard](https://www.wireguard.com/) or [Tailscale](https://tailscale.com/). Both are available as Home Assistant add-ons.

Once connected to the VPN, your remote device is on the LAN and can reach BamBuddy via HTTP as if you were home — use Option 1 in this case.

---

## Virtual Printer setup

### Step 1 — Create a virtual printer in BamBuddy

1. Open BamBuddy at `http://<your-ha-ip>:8000`.
2. Go to **Virtual Printers** and create a new printer.
3. Note the IP, serial number and access code assigned to the virtual printer.

### Step 2 — Download the CA certificate

1. In BamBuddy go to **Settings → Virtual Printer**.
2. Download the **CA Certificate** (`bbl_ca.crt`).

### Step 3 — Add the certificate to BambuStudio

Append the contents of `bbl_ca.crt` to the slicer certificate file.

**Standard installation:**
```
<BambuStudio install path>/resources/cert/printer.cer
```

**Flatpak installation:**
```
/var/lib/flatpak/app/com.bambulab.BambuStudio/current/active/files/share/BambuStudio/resources/cert/printer.cer
```
or
```
/var/lib/flatpak/app/com.bambulab.BambuStudio/current/active/files/share/BambuStudio/cert/printer.cer
```

> **Note:** Updating BambuStudio via Flatpak overwrites `printer.cer` — you will need to re-add the certificate after each update.

### Step 4 — Add the virtual printer in BambuStudio

1. In BambuStudio go to **Device → Add Printer**.
2. Select **Add a new Bambu Lab printer**.
3. Enter the IP, serial number and access code from Step 1.

---

## Data persistence

BamBuddy data (database, virtual printer certificates, logs) is stored in the HA Supervisor data volume and survives add-on updates and restarts.

---

## Support

For issues with the **add-on packaging**:
<https://github.com/naked-head/homeassistant-addons/issues>

For issues with **BamBuddy itself**:
- [BamBuddy wiki](https://wiki.bambuddy.cool)
- [BamBuddy GitHub](https://github.com/maziggy/bambuddy/issues)
