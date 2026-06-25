# Catch Host Privacy Inventory Draft

This is a working inventory for App Store Connect privacy labels. Legal/product
must confirm final answers before submission.

## Current posture

- Planned tracking answer: no cross-app advertising tracking.
- No IDFA or advertising SDK was identified in the dependency scan.
- Firebase Analytics, Crashlytics, Messaging, App Check, Maps, Algolia, and
  Razorpay still require processor-by-processor confirmation before final labels.
- The shared app includes Health-related code/dependencies. Host should not list
  Health data unless the submitted Host build actually requests or collects it.

## Data categories to review

| Apple privacy area | Likely Host data | Linked to user | Draft use |
| --- | --- | --- | --- |
| Contact Info | Phone number, email, display name, support contact details | Yes | App functionality, account management, support |
| User Content | Host profile, club details, event listings, event images, messages, reports, reviews/responses | Yes | App functionality, moderation, support |
| Photos or Videos | Host/event images selected for upload | Yes | App functionality |
| Location | Event venue and map data; device precise/coarse location only if the Host build requests current location | Yes if collected | App functionality |
| Financial Info | Host payout setup, payment-account metadata, transaction/refund references when paid events are enabled | Yes | Payments, fraud prevention, support |
| Purchases | Paid-event order or ticket metadata if visible to Host | Yes | App functionality, payments, support |
| Identifiers | Firebase Auth UID, installation/push token, App Check/App Attest identifiers, device identifiers from SDKs | Yes | App functionality, security, analytics |
| Usage Data | Screen views, feature events, invite/waitlist/activity counters, operational analytics | Yes | Analytics, product improvement, app functionality |
| Diagnostics | Crash logs, performance data, error reports | Verify Crashlytics linkage | Diagnostics, product improvement |
| Sensitive Info | Safety reports or moderation notes if exposed in Host workflows | Yes if collected | Safety, moderation, support |

## Third-party services to confirm

| Service | Repo evidence | Privacy review note |
| --- | --- | --- |
| Firebase Auth | `firebase_auth` dependency | Phone/email auth and user identifiers |
| Cloud Firestore | `cloud_firestore` dependency | Host profile, clubs, events, operational data |
| Firebase Storage | `firebase_storage` dependency | Uploaded event/host media |
| Firebase Messaging | `firebase_messaging` dependency | Push notification tokens and delivery data |
| Firebase App Check/App Attest | `firebase_app_check` dependency and host App ID capability | Device/app integrity signals |
| Firebase Analytics | `firebase_analytics` dependency | Usage events; confirm event taxonomy and linkage |
| Firebase Crashlytics | `firebase_crashlytics` dependency | Diagnostics; confirm linkage and retention |
| Google Maps | `google_maps_flutter` dependency | Venue/map rendering and possible Maps SDK data |
| Algolia | Functions search/indexing usage | Search/index processor for public/host data |
| Razorpay | `razorpay_flutter` dependency | Payments and payout-related metadata if active |
| Apple Push Notifications | Host App ID capability | Notification delivery |

## Safety and account controls

The repository includes moderation, reporting, blocking, and account-deletion
paths. Mention these in review notes because the app can contain user-generated
content and organizer/attendee interaction surfaces.

Final confirmation needed:

- Exact App Store Connect privacy label choices for each category.
- Whether Diagnostics are linked to user identity in Firebase configuration.
- Whether Host role can request device location or Health permissions.
- Whether paid event flows are enabled in the submitted Host build.
- Whether any marketing attribution, retargeting, or ads tooling is active.
