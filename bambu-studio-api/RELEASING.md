# Releasing Bambu Studio API

Unlike BamBuddy, this App ships a **pre-built image** (`image:` in
`config.yaml`, published to GHCR by `.github/workflows/bambu-studio-api-build.yml`).
The image must exist before users can install the new version — otherwise HACS
offers a version whose image cannot be pulled, and the Supervisor falls back to
building the Dockerfile locally (~15 minutes on a typical HA host).

## Order matters

1. Bump `version:` in `config.yaml`
2. Update `CHANGELOG.md`
3. Merge to `main` — this triggers the builder
4. **Wait for the builder to finish** and verify the tag exists at
   `ghcr.io/naked-head/ha-app-bambu-studio-api-amd64:<version>`
5. Only then tag and publish the release

## Before merging

- [ ] CI green (shellcheck, yaml, smoke)
- [ ] `./test/smoke.sh` passes locally
- [ ] `version:` bumped in `config.yaml`
- [ ] `CHANGELOG.md` updated
- [ ] New/changed options documented in `DOCS.md` and `translations/`

## Verify the image was published

    docker pull ghcr.io/naked-head/ha-app-bambu-studio-api-amd64:0.1.9

If this fails, do not tag the release yet.

## Beta first

Same rule as BamBuddy — pre-release when the change contains a third-party PR,
an upstream version bump (`BAMBU_VERSION` / `UPSTREAM_REF`), or schema changes.

    git tag bambu-studio-api-v0.1.9-beta.1
    git push origin bambu-studio-api-v0.1.9-beta.1

GitHub → Releases → Draft new release → select the tag →
check **Set as a pre-release**.

## Stable release

    git tag bambu-studio-api-v0.1.9
    git push origin bambu-studio-api-v0.1.9

GitHub → Releases → Draft new release → select the tag → publish.

## Upstream version bumps

`BAMBU_VERSION` and `UPSTREAM_REF` in the Dockerfile pin external sources that
can change under you:

- A new `BAMBU_VERSION` must have a Linux AppImage on the BambuStudio releases
  page — the build fails fast if not.
- `UPSTREAM_REF` is a branch, not a tag: upstream can move it. A rebuild with
  no local changes can therefore produce a different image.

Both are reasons to release as beta first.
