---
doc_id: marketing_app_media_pipeline
version: 1.3.0
updated: 2026-09-21
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
| `active` | `sourcePath` must exist, is copied to `website/public/assets/app-screenshots/`, and CI compares source and website image bytes. |
| `paused` | The capture is excluded from the generated website manifest. |

When the synthetic host/member fixture is ready, flip the relevant capture from
`pending-fixture` to `active`, generate the app screenshot into its `sourcePath`,
then run:

```sh
node tool/marketing/sync_website_media.mjs --update
node tool/marketing/sync_website_media.mjs --check
```

## Website Contract

Website pages render React `CaptureCard` components keyed by
`data-capture-slot="<capture-id>"`. `website/src/App.tsx` loads
`/assets/app-screenshots/manifest.json` and swaps in the active asset path,
caption, alt text, walkthrough step, and status label.

The Host vertical at `/host/` and the homepage hero consume these slots through
`useMarketingCaptures()`. Capture selection and copy belong to the manifest.

Marketing styling imports the shared React web token layer from
`packages/web-config/styles/catch-web.css`; the generated token CSS itself is
owned by `dart run tool/design_tokens.dart`.

## CI Behavior

`tool/tools_manifest.json` registers `marketing:app-media-sync`, so
`node tool/run.mjs check` runs the marketing media check with the rest of tool
CI. Pending captures pass only if their placeholders exist and the generated
website manifest is current. Active captures fail if the app-generated source image is missing, the website
image is missing or has different bytes, or the generated manifest is out of
sync. This proves copy consistency; it does not prove that an old source PNG
reflects current app code. Regenerate and review affected captures after UI
changes.

## Fixture Boundary

The manifest names fixture keys such as `salesDemo.host.liveConsole`, but it
does not create that synthetic data. The screenshot harness should treat those
keys as an input contract owned by the sales-grade demo data workstream.

## Rendering And Review

The implemented exporter maps manifest fixture keys to production screen builders
in `test/ui_captures/catalog/screen_capture_catalog.dart`. The export-only
`capture_runner_test.dart` renders those widgets using synthetic fixtures; it
does not compare or update golden baselines.

```sh
node tool/marketing/export_app_screenshots.mjs --list
node tool/marketing/export_app_screenshots.mjs --update --ids member-event-discovery
node tool/marketing/sync_website_media.mjs --update
node tool/marketing/sync_website_media.mjs --check
```

Select ids from `--list`. Review the generated source PNGs before sync. Rendering
and syncing local assets does not publish the website.

The iPhone export renders at the final frame's 2x pixel ratio with explicit iOS
widget behavior. It loads the local macOS system font by default; another host
must provide `--sf-font <path>` to an available native iOS font. Font files stay
local and are never copied into website assets. Generic review captures can
choose `--platform ios --sf-font <path>` via `tool/ui_capture/run_captures.mjs`;
without those options they retain the deterministic test platform/font setup.
An iPhone device geometry alone does not establish iOS typography.

Design rules govern the implementation. Fresh rendered review validates the
result; a reviewed golden baseline then records it for regression detection.
An existing golden is not authority for spacing, typography, or an invalid
configuration. Product exports reuse production widgets and fixtures, without
requiring the UI to match an old image. Keep export, review, baseline updates,
and website sync as distinct explicit operations.
