# Catch Host Screenshots

Generated screenshots target Apple's 6.9-inch iPhone portrait size:
1320x2868 PNG. This five-image pack is retained as a draft source set. The
approved launch target is eight images in the order and states defined by
[`../app_listing_screenshot_production_brief.md`](../app_listing_screenshot_production_brief.md).

Regenerate with:

```sh
swift tool/store/generate_catch_host_app_store_screenshots.swift
```

## Generated set

| File | Source capture | Store headline | Status |
| --- | --- | --- | --- |
| `screenshots/iphone_6_9/01-event-setup.png` | `artifacts/marketing/app-screenshots/host-create-basics.png` | Build your host profile | Replace; setup is not the lead value proposition |
| `screenshots/iphone_6_9/02-admission-rules.png` | `artifacts/marketing/app-screenshots/host-create-policy.png` | Control admission | Retain source; move to H03 and refresh |
| `screenshots/iphone_6_9/03-live-event-flow.png` | `artifacts/marketing/app-screenshots/host-live-console.png` | Run live event flow | Retain source; promote to H01 and refresh |
| `screenshots/iphone_6_9/04-post-event-report.png` | `artifacts/marketing/app-screenshots/host-post-event-report.png` | Review the outcome | Retain as event-report evidence; use organizer insights for H08 |
| `screenshots/iphone_6_9/05-guest-details.png` | `artifacts/marketing/app-screenshots/host-create-location.png` | Plan guest details | Replace; visible state reads as guest directions |

## Caveats

- These are generated from deterministic Host demo captures, not from a fresh
  TestFlight archive.
- All five current PNGs contain an alpha channel and must not be uploaded to
  App Store Connect without flattening to an opaque export.
- Each generated image includes a `Demo data shown` footer.
- Refresh the source captures and regenerate this set after the Host release
  build is uploaded if any submitted UI differs from these screenshots.
