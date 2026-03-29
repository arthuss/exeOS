# STATE

- `exeOS` now consumes read-only catalog data from same-origin static feed snapshots under `/feeds/...`, sourced from `Wallpaper-management-hub/dist/feeds` via `scripts/sync-hub-feeds.ps1`.
- The current web catalog path is image-first and preview-only; it renders curated `last-updated` items plus top tag shelves from the exported hub feed JSONs.
- The `exeOS` head now includes Pinterest domain verification meta tag `p:domain_verify=62eb30bb548044d3fe6eb7f238a78198`, and the current hosting deployment is live on both `dotexe-pro.web.app` and `www.dotexe.pro`.
- `exeOS` now has a live read-only detail/preview path under `/catalog/:wallpaperId`. The route resolves items from the same exported feed snapshots, and Firebase Hosting rewrites SPA deep links back to `index.html` so direct detail URLs work on `www.dotexe.pro`.
