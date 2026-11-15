# VUMC Archive.org Sermon Series — Roku Beta 137

This is an experimental branch only. Do not merge into `main` or replace the published Roku channel until it is tested.

## Behavior
- Roku left navigation has **Sermon Series** as its ninth entry.
- Sermon Series -> Sermons -> series card -> 16:9 sermon thumbnail grid -> MP4 playback.
- The `VideoCatalogTask` reads public Archive.org uploads for `versaillesumcworshipteam@gmail.com`.
- Videos must have separate Archive.org subject tags `type:sermon` and `series:Series Name`. A semicolon-delimited subject field is supported.
- Direct MP4 links and `__ia_thumb.jpg` are retrieved from each item's metadata.
- Latest Streams and Watch Live code are unchanged.

## Build
A GitHub Actions workflow (`.github/workflows/build-roku-beta.yml`) is configured to validate component XML and package `manifest`, `source`, `components`, and `images` into a Roku sideload ZIP. Check Actions for a completed run and download the `VUMC-Roku-Archive-Series-Beta` artifact. If no workflow run appears, GitHub Actions may need enabling in repository settings; alternatively download branch source, ZIP the four items at ZIP root, and sideload via Roku Developer Mode.

## Test checklist
1. On Archive.org, confirm both sermons have `type:sermon` and `series:...` tags in the metadata JSON.
2. Confirm the original MP4 URL plays on a Roku device.
3. Open Sermon Series in beta, select Sermons, then select a series.
4. Confirm episode thumbnails and playback, Back navigation, and the existing Watch Live and Latest Streams features.
5. Upload another tagged sermon and reopen the app to confirm automatic discovery.

## Limitations
- This first beta fetches Archive.org directly from Roku; loading may be slow for a large collection, and Archive.org indexing can lag.
- No persistent last-known-good catalog cache yet.
- The Cloudflare Worker prototype in `experiments/archive-series-worker.js` is **not deployed** and is not currently used by the Roku catalog task.
- GitHub XML validation is not a substitute for on-device BrightScript compilation and playback testing.
