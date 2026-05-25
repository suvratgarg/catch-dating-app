---
doc_id: marketing_app_media_pipeline
version: 1.0.0
updated: 2026-05-25
owner: marketing_website
status: active
---

# Marketing App Media Pipeline

The website should not hand-author app screenshots. Marketing pages consume
records generated from `tool/marketing/capture_manifest.json`, and the sync
tool verifies whether the checked-in website assets still match the app capture
source.

## Capture Lifecycle

Each capture has one of three statuses:

| Status | Meaning |
|---|---|
| `pending-fixture` | The website uses a checked-in placeholder until the synthetic demo fixture and screenshot harness are ready. |
| `active` | `sourcePath` must exist, is copied to `website/assets/app-screenshots/`, and CI checks the source hash. |
| `paused` | The capture is excluded from the generated website manifest. |

When the synthetic host/member fixture is ready, flip the relevant capture from
`pending-fixture` to `active`, generate the app screenshot into its `sourcePath`,
then run:

```sh
node tool/marketing/sync_website_media.mjs --update
node tool/marketing/sync_website_media.mjs --check
```

## Website Contract

Website pages use `data-capture-slot="<capture-id>"` and an image marked with
`data-capture-image`. `website/script.js` loads
`/assets/app-screenshots/manifest.json` and swaps in the active asset path,
caption, alt text, and status label.

The current host vertical at `/host/` and the homepage hero both consume these
slots. This means the page can be designed now while screenshot freshness is
owned by the capture manifest later.

## CI Behavior

`tool/tools_manifest.json` registers `marketing:app-media-sync`, so
`node tool/run.mjs check` runs the marketing media check with the rest of tool
CI. Pending captures pass only if their placeholders exist and the generated
website manifest is current. Active captures fail if the app-generated source
image is missing, stale, or not synced to the website.

## Fixture Boundary

The manifest names fixture keys such as `salesDemo.host.liveConsole`, but it
does not create that synthetic data. The screenshot harness should treat those
keys as an input contract owned by the sales-grade demo data workstream.
