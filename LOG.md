# LOG

- 2026-03-29: Wired `exeOS` to same-origin hub feed snapshots via `web/feeds`, added a feed sync script, and replaced catalog placeholders with real read-only preview cards backed by curated/tag exports.
- 2026-03-29: Added the Pinterest domain verification meta tag to `web/index.html` and deployed `exeOS` to Firebase Hosting (`dotexe-pro`). Verified the tag live on both `https://dotexe-pro.web.app` and `https://www.dotexe.pro`.
- 2026-03-29: Added real catalog detail navigation to `exeOS`. Catalog cards on home and catalog screens now route into `/catalog/:id`, a new detail screen resolves feed items from the exported hub feeds, and Firebase Hosting now rewrites deep links back to `index.html` so direct catalog detail URLs return 200 instead of 404.
