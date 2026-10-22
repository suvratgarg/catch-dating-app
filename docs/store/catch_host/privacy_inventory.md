# Catch Host Privacy Inventory

Draft App Store Connect privacy answers for `Catch Host` (`com.catchdates.host`,
app id `6778927317`). The answers describe what the Host release archive
collects. Source evidence was read on 2026-10-22 at `origin/main` `3c930f24b`.
The archive's own privacy report is still the final check. Legal/product
confirm the answers before they are entered.

## Which build these answers describe

The Host release workflow does not archive the root `ios/` project.
`node tool/platform/resolve_app_target.mjs --role host --environment prod`
resolves the target the release workflow
(`.github/workflows/mobile-internal-release.yml`) archives:

| Field | Value |
| --- | --- |
| Flutter project | `apps/host` (`catch_host_app`, version `1.0.1`) |
| Entrypoint | `apps/host/lib/main_prod.dart` → `runCatchApp(appRole: host, environment: prod)` |
| Xcode scheme / configuration | `host-prod` / `Release-host-prod` |
| Dart defines | `tool/env/dart_defines/prod.json` |
| Info.plist | `apps/host/ios/Runner/Info.plist` |
| Entitlements | `apps/host/ios/Runner/RunnerHost.entitlements`: `aps-environment` and App Attest only. There is no HealthKit and no Associated Domains. |
| Native dependency graph | `apps/host/ios/Podfile.lock` |

These answers hold only for archives built from `apps/host`. The legacy root
`ios/` project still has `*-host-prod` configurations, but its Info.plist does
not contain the analytics deactivation keys listed below.

### Native SDKs in the Host archive

`apps/host/ios/Podfile.lock` contains Firebase Auth, App Check (App Attest),
Firestore, Functions, Storage, Messaging, Remote Config, Crashlytics (with
Firebase Sessions), Analytics (`GoogleAppMeasurement` including
`IdentitySupport`, and `GoogleAdsOnDeviceConversion`), Google Maps 9.4.0,
`geolocator_apple`, `image_picker_ios`, `file_picker_darwin`, `mobile_scanner`,
`share_plus`, `url_launcher_ios`, `audioplayers_darwin`, `connectivity_plus`,
`flutter_timezone`, `package_info_plus` and `shared_preferences_foundation`.

The Host graph has none of these: a HealthKit or health plugin, a native
Razorpay SDK, Google or Apple sign-in, a client-side Algolia SDK, or StoreKit /
`in_app_purchase`.

Native code in `apps/host/ios/Runner/AppDelegate.swift` registers two channels:
`catch/calendar`, which uses EventKit for the add-to-calendar editor, and
`catch/phone_contacts`, which uses `CNContactPickerViewController` and returns
only the contacts the user selects. Neither channel uses `CNContactStore`.

### Collection switches in the release build

| Switch | Release value | Effect |
| --- | --- | --- |
| `FIREBASE_ANALYTICS_COLLECTION_DEACTIVATED` (Host Info.plist) | `true` | Analytics is off natively before Dart starts |
| `FIREBASE_ANALYTICS_COLLECTION_ENABLED`, `GOOGLE_ANALYTICS_IDFV_COLLECTION_ENABLED`, `GOOGLE_ANALYTICS_DEFAULT_ALLOW_*` | `false` | No collection, no IDFV, and all consent defaults denied |
| `FirebaseAutomaticScreenReportingEnabled` | `false` | No automatic screen views |
| `AppAnalytics.hostProductMeasurementEnabled` (`lib/core/analytics/app_analytics.dart`) | `false` | Dart uses `NoOpAnalyticsReporter` for the Host role |
| `AppConfig.shouldCollectObservability` | `true` for a prod release | Crashlytics collection is enabled at runtime, and the plist default `false` is overridden |
| `ErrorLogger.setUserId` (`lib/core/presentation/host_app_shell.dart`) | Firebase UID | Crash reports carry a `user_id` custom key |
| `FirebaseMessagingAutoInitEnabled` | `false` | The Host shell starts FCM after sign-in and stores the token under `users/{uid}` |
| `ITSAppUsesNonExemptEncryption` | `false` | See `metadata.md` |
| `NSUserTrackingUsageDescription` | absent | The app never shows an App Tracking Transparency prompt |

## Draft App Store Connect answers

Every row below has **Used for tracking: No**. Confidence describes how far
source evidence alone supports the answer.

| Apple data type | Collected | Linked to user | Purposes | Host build source | Confidence |
| --- | --- | --- | --- | --- | --- |
| Contact Info: Name | Yes | Yes | App Functionality | Host/organizer profile name. Razorpay Route payout contact, beneficiary and stakeholder names. | High |
| Contact Info: Email Address | Yes | Yes | App Functionality | Business and stakeholder email in the Razorpay Route payout form. Collected only when a host sets up INR payouts, but optional collection still counts. | High |
| Contact Info: Phone Number | Yes | Yes | App Functionality | Firebase phone OTP sign-in, the only Host sign-in method. Business and stakeholder phone in the payout form. | High |
| Contact Info: Physical Address | No | — | — | The payout form fields have no postal address. Event venues are event content. | Medium |
| Contact Info: Other User Contact Info | No | — | — | — | High |
| Health & Fitness: Health, Fitness | No | — | — | No HealthKit entitlement and no health plugin in the Host graph | High |
| Financial Info: Payment Info | No | — | — | Hosts buy nothing in the app. Guest checkout runs on the web through the payment provider. | High |
| Financial Info: Credit Info | No | — | — | — | High |
| Financial Info: Other Financial Info | Yes | Yes | App Functionality | Bank account number, IFSC, beneficiary, business and stakeholder PAN, and ownership percentage, submitted to Razorpay Route. Stripe onboarding runs on a Stripe-hosted page. | High |
| Location: Precise Location | Yes | Yes | App Functionality | Opt-in "Share the moving group" foreground position for route events with live tracking (`lib/hosts/presentation/widgets/host_event_live_location_field.dart`). It is written to a server-owned event position document. | High |
| Location: Coarse Location | No | — | — | The location picker centres on the device position only when permission was already granted. The position stays on the device. | Medium |
| Sensitive Info | No | — | — | Hosts give no sensitive data about themselves. Cohort caps for singles events (for example straight men and straight women) use attendee profile data that the consumer channels collect, not the Host app. | High |
| Contacts | Yes | Yes | App Functionality | Guest roster file import (`lib/hosts/data/host_roster_file_service.dart`). Organizer-managed customer records. Wedding phone-contact import of selected contacts, which is off by default (see below). | Medium: this is a judgment about third-party contact data that organizers upload |
| User Content: Emails or Text Messages | Yes | Yes | App Functionality | Inbox chats with guests, broadcasts and follower updates | High |
| User Content: Photos or Videos | Yes | Yes | App Functionality | Organizer and event images from the photo picker, stored in Firebase Storage | High |
| User Content: Audio Data | No | — | — | `audioplayers` only plays bundled sounds | High |
| User Content: Gameplay Content | No | — | — | — | High |
| User Content: Customer Support | No | — | — | Help opens the website. The app has no in-app support form. | Medium |
| User Content: Other User Content | Yes | Yes | App Functionality | Organizer page, events, forms, offers, posts, notes, reports and tracking-setting IDs | High |
| Browsing History | No | — | — | — | High |
| Search History | No | — | — | Customer and offer search queries are used at request time only | Medium |
| Identifiers: User ID | Yes | Yes | App Functionality | Firebase Auth UID, also set as the Crashlytics `user_id` key | High |
| Identifiers: Device ID | Yes | Yes | App Functionality, Analytics | FCM token and Firebase installation id under `users/{uid}/pushInstallations`. The Google Maps SDK manifest declares Device ID as linked, for Analytics and App Functionality. | High |
| Purchases: Purchase History | No | — | — | — | High |
| Usage Data: Product Interaction | Yes | No | Analytics | The Google Maps SDK manifest declares it (not linked, Analytics). Firebase Analytics sends nothing during the release hold. | Medium |
| Usage Data: Advertising Data | No | — | — | — | High |
| Usage Data: Other Usage Data | No | — | — | — | High |
| Diagnostics: Crash Data | Yes | Yes | App Functionality, Analytics | Crashlytics, linked through the UID custom key. The Google Maps SDK declares it for Analytics. | High |
| Diagnostics: Performance Data | Yes | No | Analytics | Google Maps SDK manifest. Firebase Sessions, which ships with Crashlytics. | Medium |
| Diagnostics: Other Diagnostic Data | Yes | Yes | App Functionality, Analytics | Crashlytics custom keys and logs (linked). Firebase SDK telemetry (not linked). | High |
| Surroundings, Body | No | — | — | — | High |
| Other Data: Other Data Types | Yes | Yes | Analytics | Google Maps (linked) and Firebase Messaging (not linked) SDK manifests | Low |

### Evidence behind the Medium and Low answers

- SDK-declared types (Product Interaction, Performance Data and Other Data
  Types) come from the `PrivacyInfo.xcprivacy` files in the installed Host pods,
  which match `Podfile.lock` for Google Maps 9.4.0. Xcode Organizer → the Host
  archive → Generate Privacy Report shows the aggregate for the exact submitted
  build. Answer each SDK-declared type from that report: declare a type if the
  report lists it, and leave it out if it does not.
- Contacts: Apple defines Contacts as the user's address book or social graph.
  Organizer-uploaded guest lists and selected device contacts are recorded
  here as Contacts, which is conservative. Recording them as Other User Content
  instead is a legal/product classification choice.
- Search History and Customer Support depend on backend behaviour. They stay
  "No" as long as callables do not store query text and support remains on the
  website.

## Gated or held collection

**Wedding phone-contact import.** The client gates it with Remote Config
`host_wedding_phone_import_enabled`, whose bundled default is `false`
(`lib/hosts/data/host_release_config.dart`). The server gates it with
`CATCH_WEDDING_PHONE_IMPORT_READY`. Remote Config can turn it on without a new
binary. The Contacts row above already covers it. App Review sees the feature
only if the flag is on during review.

**Host product analytics.** Collection is on only when all three of these hold:

- `AppAnalytics.hostProductMeasurementEnabled` is `true`.
- The native deactivation keys are removed from the Host Info.plist.
- The organizer allows analytics on that device. The choice is device-local and
  expires after 30 days.

When it is on, Firebase Analytics sends only the seven allowlisted events in
`lib/core/analytics/host_analytics_policy.dart`: `auth_started`,
`auth_completed`, `onboarding_started`, `onboarding_completed`,
`host_club_created`, `host_event_created` and `host_event_published`. Each event
carries `app_role`, `measurement_version`, an optional `auth_method`, and the
environment, platform, version and build. Host never sets an analytics user ID
or logs screen views. Advertising consent signals stay denied.

The label changes when analytics is enabled:

- **Product Interaction** gains Firebase Analytics as a source. It stays
  Analytics and not linked, as long as `setUserId` stays suppressed for the
  Host role.
- **Device ID** already has the Analytics purpose. The GA app instance ID adds
  no new type.
- **Tracking** stays No while ad consent stays denied, no Google Ads link
  exists, and the app shows no ATT prompt.
- Tracking would become Yes, with an ATT prompt required, if Host analytics
  were linked to an organizer or user ID, shared for advertising measurement, or
  `IdentitySupport` were used with ATT.

The Host Firebase property `526484083` is separate from the website acquisition
property.

## Why tracking is "No"

- No ATT prompt and no `NSUserTrackingUsageDescription`. Without ATT
  authorization, iOS returns a zeroed IDFA even though `IdentitySupport` links
  AdSupport.
- No advertising SDK or ad network in the Host graph.
- The server-side Host acquisition Meta delivery
  (`functions/src/acquisition/metaPayload.ts`) sends only website `Lead` events
  with `action_source: "website"`.
- The pilot activation receipt (`functions/src/acquisition/pilotActivation.ts`)
  is an operational record with no vendor delivery.
- Organizer-configured tracking pixels run only on public web pages, never in
  the app.

## Privacy policy coverage

The live policy at `https://catchdates.com/privacy/` (effective 10 August 2026)
names Torana as operator. It covers account and profile data, messages, host
actions, crash and diagnostic information, approximate location, and precise
location used for a feature with device permission.

It does not mention these Host-specific categories:

- payout KYC data (bank account, PAN)
- organizer-uploaded guest and contact lists
- named processors (Google/Firebase, Google Maps, Razorpay, Stripe)

## Safety and account controls

| Control | Host location |
| --- | --- |
| Delete account | Organizer tab → Account menu (top right) → Delete account. It calls `requestAccountDeletion` and then signs out. |
| Report / block | Inbox → a guest conversation → actions menu → Report or Block |
| Privacy policy, Terms, Help & support | Organizer tab → Account menu. These rows appear only when the release dart defines carry the URLs. `origin/main` `tool/env/dart_defines/prod.json` does not define them yet; they are being added on branch `claude/legal-links-in-app-20261022`. |
