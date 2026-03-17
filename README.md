# exeOS

`exeOS` is the shared web and future iOS client for the live wallpaper platform.

## Current scope

Phase A focuses on a productized shell:

- branded app structure
- router-based navigation
- catalog-ready screen layout
- settings and theme handling
- web hosting target via Firebase App Hosting

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
4. App Hosting rollout on the `exeos` backend
