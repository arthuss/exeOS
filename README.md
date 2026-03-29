# exeOS

`exeOS` is the shared web and future iOS client for the live wallpaper platform.

## Current scope

Phase A focuses on a productized shell:

- branded app structure
- router-based navigation
- full-catalog landing surface backed by static hub feeds
- settings and theme handling
- web hosting target via Firebase Hosting

Firebase auth, favorites, entitlements, and payments are intentionally out of scope for this step and will be added in later phases.

## Local development

```bash
pwsh -ExecutionPolicy Bypass -File .\scripts\sync-hub-feeds.ps1
flutter pub get
flutter run -d chrome
```

## Near-term roadmap

1. Google sign-in on web
2. Inline video preview on top of the feed-backed detail flow
3. Favorites, entitlements, and account linking on top of the read-only catalog

## Firebase Hosting

This repo deploys to the secondary Firebase Hosting site `dotexe-pro` in the
`wallpaper-management-hub` project.

Initialize once if needed:

```bash
firebase experiments:enable webframeworks
firebase target:apply hosting webapp dotexe-pro
```

Deploy the current Flutter web app:

```bash
pwsh -ExecutionPolicy Bypass -File .\scripts\sync-hub-feeds.ps1
$env:Path = 'C:\tools\flutter\bin;' + $env:Path
firebase deploy --only hosting:webapp
```
