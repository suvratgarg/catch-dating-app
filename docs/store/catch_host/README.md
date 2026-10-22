# Catch Host App Store Asset Pack

The App Store submission packet for the iOS `Catch Host` app, not the consumer
Catch app. Open work and owner decisions are tracked in Linear `CAT-39`
("Prepare Catch Host release"), not in this folder.

## App Store Connect record

| Field | Value | Source |
| --- | --- | --- |
| App name | Catch Host | `docs/release_operations.md` |
| Apple app ID | 6778927317 | `docs/release_operations.md` |
| Bundle ID | `com.catchdates.host` | `docs/release_operations.md` |
| SKU | `catch-host-ios` | `docs/release_operations.md` |
| Primary language | English (U.S.) | `docs/release_operations.md` |
| Access | Full Access | `docs/release_operations.md` |

## Release build source

`node tool/platform/resolve_app_target.mjs --role host --environment prod`
resolves the Host release target to this build:

| Field | Value |
| --- | --- |
| Project root | `apps/host` |
| Entrypoint | `apps/host/lib/main_prod.dart` |
| Xcode scheme / configuration | `host-prod` / `Release-host-prod` |
| Marketing version | `1.0.1` (`apps/host/pubspec.yaml`) |
| Producer | `.github/workflows/mobile-internal-release.yml` |

The packet's privacy, permission and export-compliance answers describe that
target. The legacy root `ios/` project is not the Host release source.

## Packet contents

| Document | Path | State on 2026-10-22 |
| --- | --- | --- |
| Metadata, URLs, age rating, export compliance | `docs/store/catch_host/metadata.md` | Drafted. Seller name, copyright and territories wait on owner decisions. |
| App privacy answers | `docs/store/catch_host/privacy_inventory.md` | Drafted per Apple data type from source. Needs legal/product sign-off and a check against the archive privacy report. |
| Reviewer access, review notes, payment posture | `docs/store/catch_host/review_notes.md` | Drafted. The reviewer accounts are not provisioned; codes stay out of the repository. |
| App icon, 1024x1024 PNG | `docs/store/catch_host/icon/app-icon-1024.png` | Ready, from the Host prod icon |
| 6.9-inch iPhone screenshots | `docs/store/catch_host/screenshots/iphone_6_9/` | Draft sources. The eight-shot production brief requires revision. |
| Asset manifest | `docs/store/catch_host/asset_manifest.json` | Updated |

The approved cross-app screenshot order, replacement decisions, platform export
matrix and QA contract are in
[`../app_listing_screenshot_production_brief.md`](../app_listing_screenshot_production_brief.md).
The five images in this pack are source drafts, not final upload assets.

## In-app requirements and where they live

| Requirement | Host build state on `origin/main` `3c930f24b` |
| --- | --- |
| Account deletion (5.1.1(v)) | Organizer tab → Account menu → Delete account |
| In-app privacy policy link (5.1.1(i)) | Not in a build yet. Branch `claude/legal-links-in-app-20261022` adds Privacy policy, Terms and Help & support to the same Account menu, together with the prod URLs in `tool/env/dart_defines/prod.json`. |
| Report and block for user-generated content (1.2) | Inbox conversation menu |
| Encryption declaration | `ITSAppUsesNonExemptEncryption` = `false` in `apps/host/ios/Runner/Info.plist` |
| Prod backend parity | The release workflow runs `check_client_callable_dependencies.mjs --role host --environment prod --verify-live` before archiving |

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

The packet also applies these App Review Guidelines:

- 2.1 (demo account and complete app)
- 1.2 (user-generated content)
- 3.1.1, 3.1.3(c), 3.1.3(e) and 3.1.3(f) (payments)
- 4.8 (login services)
- 5.1.1 (privacy, purpose strings and account deletion)
