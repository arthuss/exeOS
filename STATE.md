# STATE

- `exeOS` now consumes read-only catalog data from same-origin static feed snapshots under `/feeds/...`, sourced from `Wallpaper-management-hub/dist/feeds` via `scripts/sync-hub-feeds.ps1`.
- The current web catalog path is image-first and preview-only, but `/` now renders the full browser grid from `web/feeds/catalog/all.json` with live search plus tier/collection/tag filters.
- The `exeOS` head now includes Pinterest domain verification meta tag `p:domain_verify=62eb30bb548044d3fe6eb7f238a78198`, and the current hosting deployment is live on both `dotexe-pro.web.app` and `www.dotexe.pro`.
- `exeOS` now has a live read-only detail/preview path under canonical `/w/:wallpaperRef` URLs. Legacy `/catalog/:wallpaperId` links redirect there, and Firebase Hosting rewrites SPA deep links back to `index.html` so direct detail URLs work on `www.dotexe.pro`.
- `exeOS` preview images on web now opt into `WebHtmlElementStrategy.prefer` for feed-backed preview surfaces because the underlying Firebase Storage responses do not currently expose CORS headers required for Flutter Web byte-fetch image loading.
- `exeOS` now opens directly into the full browser catalog on `/` instead of a separate landing/preview shell.
- The current full-grid dataset comes from `web/feeds/catalog/all.json` (mirrored from `Wallpaper-management-hub/dist/feeds/catalog/all.json`), while detail pages resolve from the same feed snapshots under `/w/:wallpaperRef`.
- `exeOS` top tags are still static feed metadata from `tags.json`; they are not yet wired to the Android discovery/analytics trend path.
- When feed items expose a neutral `marketing` slice, `exeOS` now prefers its title/description/slug-derived canonical ref on the public detail surface.
- `exeOS` now serves the Pinterest base tracking tag (`pintrk`, tag id `2613860752663`) from `web/index.html` on both `dotexe-pro.web.app` and `www.dotexe.pro`.
- The current implementation also re-fires `pintrk(''page'')` on `pushState`, `replaceState`, `load`, and `popstate` so Flutter web route changes remain visible to Pinterest without full page reloads.
- `exeOS` detail pages now include an Android app CTA that targets the matching wallpaper directly through `intent://w/<productId>#Intent;scheme=exeget;package=com.exeget.livewallpaper;...` with Play Store fallback.
- The repo now also contains `/.well-known/assetlinks.json` plus a dedicated no-cache hosting header, but this web slice is not live yet because the latest Firebase Hosting deploy failed on CLI auth (`firebase login --reauth` required again).
- The current `assetlinks.json` fingerprint came from the local release/upload keystore and still needs one Play Console cross-check against the real Play app-signing certificate before HTTPS app-link auto-verification should be treated as final.
- The pending Android app-link website slice is now live on both `dotexe-pro.web.app` and `www.dotexe.pro`.
- Live `/.well-known/assetlinks.json` currently serves a broader fingerprint set than the checked-in minimal file, and it already includes the local release/upload-key fingerprint. Treat the remaining work as Play Console validation, not a missing website deploy.
- `exeOS` now serves centralized legal pages directly on `www.dotexe.pro` under `/privacy-policy`, `/terms-of-service`, `/delete-account`, and `/impressum` instead of relying on the older `arthuss.github.io` split.
- Flutter web now uses path URL strategy so those legal routes stay on canonical clean paths without hash-fragment fallback.
- The current legal content is centralized in repo state (`lib/features/legal/data/legal_documents.dart`) and linked from the catalog, detail, settings, and legal pages themselves.
- The only intentionally open legal follow-up is filling the final full provider metadata for the Impressum if additional legal entity/address fields are required beyond the current centralized contact baseline.
- The live exeOS web shell now treats privacy/terms/delete-account/impressum as top-level routes in navigation behavior as well as routing configuration: footer/legal links use context.go(...), so /settings no longer stays as the apparent URL when navigating into legal pages.
- Wallpaper detail pages now make the large preview surface itself clickable; when a preview MP4 exists, the thumbnail plus play overlay opens that MP4 externally, and the adjacent button labels now describe external preview/open-image actions instead of duplicating a generic asset link.
- 2026-04-02 feed state:
  - `web/feeds/catalog/all.json` was resynced from Hub after the `product0-799` Firestore cutoff.
  - The current live `www.dotexe.pro/feeds/catalog/all.json` snapshot contains 1488 items.
  - Removed legacy examples such as `product99` are no longer present in the live web catalog feed.
- 2026-04-04 feed state:
  - `web/feeds` was resynced from the Hub export after the category-aware schema rollout.
  - The current live `www.dotexe.pro/feeds/catalog/all.json` snapshot still contains 1488 items.
  - The live web app now also serves `www.dotexe.pro/feeds/categories.json` with 9 categories from the Hub schema.
- 2026-04-07: xeOS wallpaper detail pages now embed preview MP4 playback directly inside the public /w/:wallpaperRef surface via Flutter's ideo_player, instead of treating the main preview card as an external media link. External-open actions remain available as secondary controls, and the implementation is shared-web/future-iOS compatible.

- 2026-04-07: The embedded exeOS detail preview-video player is now live on Firebase Hosting. Public wallpaper detail routes under https://www.dotexe.pro/w/<ref> no longer treat the main preview card as an external-open link for videos; the current live build plays preview MP4s inline and keeps external-open as a secondary action.

- 2026-04-07: The live exeOS preview surface is now stricter: web uses a native HTML5 embedded video element for preview MP4 playback, public detail pages no longer expose direct preview/standbild external-open buttons, and catalog/home cards use a non-clickbait Preview badge instead of a fake play-button affordance.

- 2026-04-07: xeOS Hosting now serves /main.dart.js with 
o-cache, no-store, must-revalidate in addition to index.html, lutter_bootstrap.js, and lutter_service_worker.js. This is an intentional fast-iteration web setting to reduce stale-browser bundles during active product work and should be reevaluated before later production cache tuning.

- 2026-04-07: Live Hosting verification: https://www.dotexe.pro/main.dart.js now responds with Cache-Control no-store, must-revalidate, no-cache. The current web deployment is intentionally optimized for iteration freshness rather than long bundle caching and should be revisited before later production cache tuning.
- 2026-04-07: exeOS repo state now includes the first Firebase web-auth shell: `firebase_core` / `firebase_auth` bootstrapped in Flutter, Google sign-in/out surfaced in Settings, and reserved callback routes for `/auth/complete`, `/connect/drive/complete`, and `/integrations/:provider/complete`. This is only the session/callback foundation; owner merge rules, web entitlements, Drive connect, and social provider connects remain separate follow-up work.

- 2026-04-07: Deliberate pre-deploy prerequisite for the new exeOS auth shell: confirm Firebase Auth has Google enabled and `www.dotexe.pro` in Authorized domains before exposing the login UI live. The current code handles `operation-not-allowed` and `unauthorized-domain` failures explicitly, but the runtime config should still be verified before rollout.
- 2026-04-07: exeOS web auth no longer stores the Firebase Browser key in repo source. `firebase_options.dart` now reads `EXEOS_FIREBASE_API_KEY` from a build-time dart-define, and the app intentionally falls back to an auth-disabled read-only shell when the define is missing. `QUICKSTART.md` documents the auth-enabled local run command.
- 2026-04-07: The first auth-enabled exeOS web shell is now live on `www.dotexe.pro`. Deployment used a build-time `EXEOS_FIREBASE_API_KEY` dart-define and a static Hosting deploy from `build/web` so the Firebase Browser key stays out of repo source. Live verification: `main.dart.js` still responds with no-store/no-cache headers, the bundle contains the Google sign-in UI text, `/w/product945` returns 200, and `/.well-known/assetlinks.json` remains live.

- 2026-04-07: Important deploy detail for future exeOS static web rollouts: Flutter's `build/web` output did not carry `/.well-known/assetlinks.json` automatically, so the file had to be copied into `build/web/.well-known/assetlinks.json` before the static Hosting deploy. If future sessions bypass the framework-integrated deploy path, they must preserve that file explicitly.
- 2026-04-07: Web-side identity resolution is now frozen conceptually: linked Firebase identities map onto the canonical `ownerId`, guest state never owns durable data, and later web/iOS sign-ins must resolve back into the existing owner instead of minting a parallel account. Non-attested channels remain authenticated but not equivalent to attested Android trust.
- 2026-04-07: exeOS live Settings now resolve the signed-in Firebase web session onto the canonical backend owner path through `ownerResolveSession`. The UI exposes resolving/error states plus the resolved `ownerId`, and the public bundle on `www.dotexe.pro` contains the new owner-resolution surface while still shipping with no-store bundle cache headers for fast iteration.
- 2026-04-09: exeOS repo state now includes a stronger catalog brand/verification surface: top-left brand text is `dotexe.pro`, the catalog hero explicitly identifies the site as the official Android live-wallpaper catalog with a Google Play CTA, tier filter chips use the shared badge assets again, and premium-tier wallpaper cards use colored tier framing around thumbnails rather than only a small label pill. Local validation passed via `flutter analyze` and `flutter build web`, but the refreshed Hosting deploy is still pending because the Firebase CLI session expired again during deploy. When resuming, rebuild with `EXEOS_FIREBASE_API_KEY`, copy `.well-known/assetlinks.json` into `build/web/.well-known/`, and deploy with `firebase deploy --only hosting:webapp --project wallpaper-management-hub`.
