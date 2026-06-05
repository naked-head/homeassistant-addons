# Changelog

## 0.1.2

Fix add-on failing to start with `s6-supervise bambu-studio-api: warning:
unable to spawn ./run (waiting 60 seconds): No such file or directory`.

The conventional HA add-on shebang `#!/usr/bin/with-contenv bashio`
expects `with-contenv` at `/usr/bin/`, which is where HA base-* images
put it. The s6-overlay v3 release tarballs we install onto our Ubuntu
base install it at `/command/with-contenv` only — so the kernel couldn't
resolve the interpreter and s6 reported the run script as missing even
though the file was present. Add a symlink so the conventional shebang
works.

## 0.1.1

- Use the official Bambu Studio icon and logo instead of placeholder PNGs.
- Wire `config.yaml` to the GHCR pre-built image so installs are a fast
  pull instead of a 5–10 minute local build.
- Switch CI to `docker/build-push-action` so the published image actually
  ends up in the registry (the previous workflow built but failed during
  retag).

## 0.1.0

Initial release.

- Packages the `bambu-studio-api` service from
  [`maziggy/orca-slicer-api`](https://github.com/maziggy/orca-slicer-api),
  branch `bambuddy/profile-resolver`.
- Bundles Bambu Studio AppImage `v02.06.00.51`.
- Runs on Ubuntu 22.04 with Node 22; amd64 only (Bambu Lab does not publish
  an ARM64 AppImage).
- Persists slicer profiles and uploaded presets under
  `addon_configs/<slug>_bambu_studio_api/data/`.
- Default host port `3001` to match the
  [Bambuddy wiki](https://wiki.bambuddy.cool/features/slicer-api/), editable
  via **Configuration → Network**.
- Watchdog and webui both hit `/health`.
