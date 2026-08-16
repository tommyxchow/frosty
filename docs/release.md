# Release — version, notes, tag, then stores

Cut a GitHub + Play + App Store release from `main`. Not a changelog dump. Not a docs rewrite.

This playbook lives in the repo and loads only when you open this workspace and ask to release. It is not a global skill.

Flow: **preflight → bump + notes → commit on `main` → tag → wait for workflows → publish the GitHub draft.**

The tag is the mechanical trigger. This file is the judgment pass around it.

## Preflight

Main CI green on current `HEAD`. Then `gh workflow run "Release dry-run"` on that `main` — the monthly heartbeat is not enough after a toolchain bump.

Click any pending Apple agreement first (`developer.apple.com/account`, then App Store Connect Business) or the iOS job 403s. There is no API for that. On Play, glance Console Home and **Policy and programs > App content** (`Needs attention`); a DDA banner or new declaration can block the AAB the same way.

## Version

Release commit on `main` is only `pubspec.yaml` (`x.y.z+build`, bump both) and `assets/release-notes.md`. Message: `release vX.Y.Z`.

Features since last tag → minor. Fixes only → patch. Build number +1.

Do not put `AGENTS.md` or other docs in that commit.

## Notes

Write for someone opening the app, not the commit log. Match the latest shipped version's voice (`Added` / `Improved` / `Fixed`). Skip CI, Flutter upgrades, codegen, and anything a user wouldn't notice; the GitHub compare link is the rest.

Keep about three most recent versions, consecutive. Drop from the oldest end. Never skip a version in the middle. GitHub releases keep the full history.

- Features that didn't exist last release. Improvements only for behavior that already shipped — gating a new feature (opt-in permissions, an Enable flow) is not an improvement.
- If you can't remember the user-facing symptom, it doesn't belong.
- `[Android]` / `[iOS]` on platform-only lines. Cluster them: one tagged line at the end of its section, two or more adjacent.
- Credit GitHub PR authors as `(by @user on GitHub)` on each bullet they landed. Not AI, not issue reporters. The GitHub release body strips ` on GitHub` as redundant.

Example shape (from v5.1.0): `Added a new experimental native video player option with quality selection…` not `Bumped better_native_video_player`.

## Tag

```bash
git commit -m "release vX.Y.Z"
git push origin main
git tag vX.Y.Z                 # lightweight, on that commit
git push origin vX.Y.Z         # v*.*.* triggers both workflows
```

Do not `gh release create`. **Draft GitHub release** attaches `frosty-vX.Y.Z.apk` and fills the body from this version's section in `assets/release-notes.md`. **Build and release Frosty** uploads the Play AAB and submits iOS for review (`automatic_release: true`).

When the draft has the APK:

```bash
gh release edit vX.Y.Z --draft=false
```

The README latest-release badge stays stale until that publish. Store listing copy already points at GitHub — don't add per-version Play changelog files.

Do not push the tag until the release commit is on `origin/main`.
