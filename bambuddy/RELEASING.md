# Releasing BamBuddy

## Before tagging

- [ ] CI green on `main` (shellcheck, yaml, smoke)
- [ ] `./test/smoke.sh` passes locally
- [ ] Manual test with `./test/run.sh full` — UI reachable, no errors in log
- [ ] Fresh install tested (empty `/data`, setup from scratch)
- [ ] Upgrade tested (existing `/data` from previous version — no crash, no data loss)
- [ ] `version:` bumped in `config.yaml`
- [ ] `CHANGELOG.md` updated
- [ ] New/changed options documented in `DOCS.md` and `translations/`

## Beta first

Always release as pre-release first when the release contains:

- a PR from a third party
- code ported from another fork
- changes to `config.yaml` schema or options
- a refactor of `rootfs/etc/services.d/bambuddy/run`

Tag and push:

    git tag bambuddy-v1.0.13-beta.1
    git push origin bambuddy-v1.0.13-beta.1

Then on GitHub → Releases → Draft new release → select the tag →
check **Set as a pre-release**.

Only users with "Show beta versions" enabled in HACS will see it.
Wait a few days. No reports → promote to stable.

## Stable release

    git tag bambuddy-v1.0.13
    git push origin bambuddy-v1.0.13

GitHub → Releases → Draft new release → select the tag → publish (not pre-release).

## If it breaks in production

1. Tag the previous known-good commit as a new patch version — don't
   force-push or delete the bad tag; users who already upgraded need a
   version number higher than the broken one.
2. Add a scenario to `test/scenarios/` that reproduces the failure.
3. Verify the new scenario fails against the broken image, passes against the fix.
