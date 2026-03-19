# exeOS

`exeOS` is the shared web and future iOS client for the live wallpaper platform.

## Current scope

Phase A focuses on a productized shell:

- branded app structure
- router-based navigation
- catalog-ready screen layout
- settings and theme handling
- web hosting target via Firebase Hosting

Firebase auth, feed integration, favorites, entitlements, and payments are intentionally out of scope for this step and will be added in later phases.

## Local development

```bash
flutter pub get
flutter run -d chrome
```

## Near-term roadmap

1. Google sign-in on web
2. Read-only wallpaper catalog from existing hub feeds
3. Preview/detail flow
4. Firebase Hosting rollout on the `dotexe-pro` site

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
firebase deploy --only hosting:webapp
```
