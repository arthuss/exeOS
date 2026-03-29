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
