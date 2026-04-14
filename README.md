# exeOS

`exeOS` is the shared web and future iOS client for the live wallpaper platform.

## Current scope

Phase A focuses on a productized shell:

- branded app structure
- router-based navigation
- static product landing page at `/`
- feed-backed Flutter catalog shell under `/catalog`
- canonical wallpaper landing routes under `/w/:wallpaperRef`
- centralized legal routes under `/privacy-policy`, `/terms-of-service`, `/delete-account`, and `/impressum`
- settings and theme handling
- web hosting target via Firebase Hosting

Firebase auth, favorites, entitlements, and payments are intentionally out of scope for this step and will be added in later phases.

## Local development

```bash
pwsh -ExecutionPolicy Bypass -File .\scripts\sync-hub-feeds.ps1
flutter pub get
flutter run -d chrome
```

This previews the Flutter app shell itself. The production Hosting output additionally stages the sibling workspace landing page from `..\landingpage` onto the public root `/`.
The landing page prefers the mirrored Hub feed at `/feeds/landing/videos.json` for its rotating preview-video pool and only falls back to the local `landing-videos.json` stub for local-only scenarios.

## Near-term roadmap

1. Google sign-in on web
2. Inline video preview on top of the feed-backed detail flow
3. Favorites, entitlements, and account linking on top of the read-only catalog

## Public link shape

- the public root `/` is a static landing page
- the Flutter app shell starts at `/catalog`
- canonical public wallpaper URLs live under `/w/:wallpaperRef`
- legacy `/catalog/:wallpaperId` links redirect into `/w/...`

## Firebase Hosting

This repo deploys to the secondary Firebase Hosting site `dotexe-pro` in the
`wallpaper-management-hub` project.

Initialize once if needed:

```bash
firebase experiments:enable webframeworks
firebase target:apply hosting webapp dotexe-pro
```

Build the staged Hosting output (`index.html` landing + `app.html` Flutter shell) and deploy it:

```bash
$env:Path = 'C:\tools\flutter\bin;' + $env:Path
pwsh -ExecutionPolicy Bypass -File .\scripts\build-hosting.ps1
firebase deploy --only hosting:webapp --project wallpaper-management-hub
```

If you want the auth-enabled web shell in that build, export `EXEOS_FIREBASE_API_KEY` before running `build-hosting.ps1`.
