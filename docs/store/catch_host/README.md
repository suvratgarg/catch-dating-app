# Catch Host App Store Asset Pack

Prepared for the iOS Host app listing. This pack is scoped to `Catch Host`, not
the consumer Catch app.

## Known App Store Connect record

| Field | Value | Source |
| --- | --- | --- |
| App name | Catch Host | `docs/release_operations.md` |
| Apple app ID | 6778927317 | `docs/release_operations.md` |
| Bundle ID | `com.catchdates.host` | `docs/release_operations.md` |
| SKU | `catch-host-ios` | `docs/release_operations.md` |
| Primary language | English (U.S.) | `docs/release_operations.md` |
| Access | Full Access | `docs/release_operations.md` |

## Prepared assets

| Asset | Path | Status |
| --- | --- | --- |
| App icon, 1024x1024 PNG | `docs/store/catch_host/icon/app-icon-1024.png` | Ready from existing host prod icon |
| 6.9-inch iPhone screenshots | `docs/store/catch_host/screenshots/iphone_6_9/` | Ready from deterministic Host captures |
| Metadata draft | `docs/store/catch_host/metadata.md` | Ready for owner review |
| Privacy inventory draft | `docs/store/catch_host/privacy_inventory.md` | Ready for legal/product review |
| App Review notes draft | `docs/store/catch_host/review_notes.md` | Needs demo credentials and backend confirmation |
| Asset manifest | `docs/store/catch_host/asset_manifest.json` | Ready |

## Apple requirements referenced

As of June 22, 2026, Apple's App Store Connect docs say:

- App records need platform, app name, primary language, bundle ID, SKU, and
  access settings before upload:
  https://developer.apple.com/help/app-store-connect/create-an-app-record/add-a-new-app/
- App name is 2-30 characters, subtitle is up to 30 characters, privacy policy
  URL is required for iOS, and the bundle ID must match Xcode:
  https://developer.apple.com/help/app-store-connect/reference/app-information/app-information
- Promotional text is up to 170 characters, description is up to 4000
  characters, keywords are up to 100 bytes, and support URL is required:
  https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information
- Screenshots support 1-10 images, including 6.9-inch portrait PNG/JPEG sizes
  such as 1320x2868:
  https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications
- App privacy answers and privacy policy URL are required:
  https://developer.apple.com/help/app-store-connect/reference/app-information/app-privacy

## Remaining release blockers

- Accept any updated Apple Developer Program License Agreement if App Store
  Connect blocks release work.
- Create or confirm the Host Xcode Cloud workflow and upload a Host archive for
  bundle `com.catchdates.host`.
- Smoke test the Host TestFlight build with App Check/App Attest, Maps, phone
  auth, push, host club/event entrypoints, check-in, and Event Success tools.
- Replace review-note placeholders with reviewer credentials and seeded data.
- Have legal/product confirm privacy labels, age rating, copyright owner, and
  category choices before submission.
- Refresh screenshots from the release/TestFlight build if the UI changes before
  submission.
