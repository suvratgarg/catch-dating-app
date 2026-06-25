# Catch Host Screenshots

Generated screenshots target Apple's 6.9-inch iPhone portrait size:
1320x2868 PNG. Apple accepts 1-10 screenshots; this pack prepares five.

Regenerate with:

```sh
swift tool/store/generate_catch_host_app_store_screenshots.swift
```

## Generated set

| File | Source capture | Store headline | Status |
| --- | --- | --- | --- |
| `screenshots/iphone_6_9/01-event-setup.png` | `artifacts/marketing/app-screenshots/host-create-basics.png` | Build your host profile | Ready |
| `screenshots/iphone_6_9/02-admission-rules.png` | `artifacts/marketing/app-screenshots/host-create-policy.png` | Control admission | Ready |
| `screenshots/iphone_6_9/03-live-event-flow.png` | `artifacts/marketing/app-screenshots/host-live-console.png` | Run live event flow | Ready |
| `screenshots/iphone_6_9/04-post-event-report.png` | `artifacts/marketing/app-screenshots/host-post-event-report.png` | Review the outcome | Ready |
| `screenshots/iphone_6_9/05-guest-details.png` | `artifacts/marketing/app-screenshots/host-create-location.png` | Plan guest details | Ready |

## Caveats

- These are generated from deterministic Host demo captures, not from a fresh
  TestFlight archive.
- Each generated image includes a `Demo data shown` footer.
- Refresh the source captures and regenerate this set after the Host release
  build is uploaded if any submitted UI differs from these screenshots.
