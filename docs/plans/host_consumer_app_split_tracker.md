---
doc_id: host_consumer_app_split_tracker
version: 0.1.1
updated: 2026-06-10
owner: host_consumer_split
status: implemented
---

# Host / Consumer App Split Tracker

## Goal

Split Catch into two installable app experiences on the same backend:

- Consumer app: dating, discovery, attendance, matching, consumer chats, and profile ownership.
- Host app: event creation, club creation, club editing, event editing, event manage, Event Success host tooling, and the event-flow stepper.

The split must preserve current production data, keep shared services reusable, and remove host-only UI from the consumer navigation surface.

## Product Boundaries

- Host accounts must operate without completing a consumer dating profile.
- Host identity is separate from dating identity. The same auth user can have a consumer dating profile and a host profile, but host surfaces must never deep-link to or expose the dating profile by default.
- Host profile data is professional: display name, avatar/logo, role/title, club/event affiliation, verified host state, support/contact affordances, and operational permissions.
- Message-host conversations are professional support/operations threads. Host avatars in those threads must not open dating profiles, and the header must not show dating metadata or match-style user context.
- Consumer app can display host identity for events and clubs, but cannot expose host management affordances.
- Host app can display attendee and booking state needed to operate an event, but cannot become a dating browse/match surface.

## Current Evidence

- Consumer and host roles now share one Flutter bootstrap with explicit consumer and host entrypoints.
- The host app mounts a role-specific router and host shell for events, clubs, inbox, and account surfaces.
- Consumer routing no longer mounts host create/edit/manage screens, and consumer UI gates host-only affordances.
- Host identity is durable in `hostProfiles/{uid}` and projected into club host snapshots without exposing dating/public profile data.
- Message-host conversations now render professional host identity and disable dating-profile navigation from the chat header.
- Push token registration is app-role/install scoped through `users/{uid}/pushInstallations/{installationId}`.
- Backend club host projections are owned by host profile writes, not dating profile writes.
- Native target generation supports host Apple schemes and host Android application IDs.
- Host Firebase Android, iOS, and web apps are registered in dev, staging, and prod; their SDK config files are checked into the role-specific config paths.
- Host Android Firebase apps mirror the matching consumer app SHA fingerprints for dev, staging, and prod, and host Android SDK configs were refreshed after SHA registration.
- Host App Check provider registrations were verified in Firebase Console on 2026-06-10 for dev, staging, and prod: Android uses Play Integrity, iOS uses App Attest, and web uses reCAPTCHA Enterprise.
- Host web, Android debug, iOS simulator, and macOS debug builds pass for the dev host role.

## Completion Snapshot

As of 2026-06-10, the in-repo migration is implemented for app-role bootstrapping, role-specific routing, host shell, consumer host-tool removal, professional host identity, professional message-host chat behavior, app-role push registration, deep-link routing contracts, data contracts, rules, functions, validation tooling, native role target generation, and host Firebase app config material.

The host Firebase config files now exist for:

- `firebase/dev/host/android/google-services.json`
- `firebase/dev/host/ios/GoogleService-Info.plist`
- `firebase/dev/host/macos/GoogleService-Info.plist`
- `firebase/dev/host/web/firebase-messaging-sw.js`
- Matching `staging` and `prod` host config files.

Host Android SHA registration now mirrors the consumer Firebase Android apps:

- Dev/staging host Android apps have the shared SHA-1 plus both SHA-256 fingerprints from the corresponding consumer apps.
- Prod host Android app has both SHA-1 fingerprints plus both SHA-256 fingerprints from the prod consumer app.
- Host Android SDK config files were refreshed after SHA registration.

Verified build evidence:

- `./tool/flutter_with_env.sh dev --role host build web`
- `./tool/flutter_with_env.sh dev --role host build apk --debug`
- `./tool/flutter_with_env.sh dev --role host build ios --simulator --no-codesign`
- `./tool/flutter_with_env.sh dev --role host build macos --debug`
- `./tool/flutter_with_env.sh dev --role consumer build apk --debug`

Verified App Check evidence:

- Dev, staging, and prod host Android apps show `Play Integrity` and `Registered` in Firebase Console.
- Dev, staging, and prod host iOS apps show `App Attest` and `Registered` in Firebase Console.
- Dev, staging, and prod host web apps show `reCAPTCHA Enterprise` and `Registered` in Firebase Console.
- Firebase CLI `15.1.0` and `gcloud` `566.0.0` do not expose App Check app-management commands in this local toolchain, so the provider evidence was captured through Firebase Console refreshes.

## Workstreams

### 1. App Role, Entrypoints, And Bootstrap

Status: implemented

- Add an `AppRole` runtime concept with `consumer` and `host`.
- Keep `lib/main.dart` as the backward-compatible consumer entrypoint.
- Add explicit `lib/main_consumer.dart` and `lib/main_host.dart` targets.
- Share Firebase, App Check, Remote Config, observability, error handling, and Riverpod bootstrap through a single app bootstrap.
- Add `CATCH_APP_ROLE` to dart defines so native and CI jobs can declare role even when the entrypoint also sets it.

Acceptance:

- `flutter run -t lib/main_consumer.dart` launches the current consumer app.
- `flutter run -t lib/main_host.dart` launches with `AppRole.host`.
- Existing `flutter run` behavior remains consumer-compatible.

### 2. Consumer Router And Host Router

Status: implemented

- Split the current GoRouter graph into role-specific route sets.
- Consumer router keeps public event/club discovery, RSVP, booking, attendance, matching, chats, profile, onboarding, and settings.
- Host router owns host manage, create/edit event, create/edit club, Event Success host flow, attendance tooling, payout/account setup, and the event-flow stepper.
- Shared public detail routes must render role-appropriate actions.

Acceptance:

- Consumer app cannot navigate to host creation/edit/manage routes by URL, push, or in-app action.
- Host app can deep-link into host manage/edit/Event Success surfaces without mounting consumer dating tabs.

### 3. Host App Shell

Status: implemented

- Build a host-first shell instead of reusing the five-tab dating shell.
- Primary areas should be operating surfaces: events, clubs, inbox/support, payouts/account, settings.
- Event Success host flow should be reachable from active event state and host manage.
- Host app must not initialize consumer-only companion launchers or dating affordances.

Acceptance:

- Host shell has no swipes/matches/dating profile tab.
- Host app can create, edit, publish, manage, and run Event Success without using consumer navigation.

### 4. Remove Host Tooling From Consumer App

Status: implemented

- Remove create/edit/manage host calls-to-action from consumer-only screens.
- Keep consumer-facing host display on event/club detail pages.
- Preserve admin/debug gates separately from host affordances.

Acceptance:

- Consumer smoke path has no host create/edit/manage entrypoints.
- Existing event/club details still show professional host identity and message-host action where appropriate.

### 5. Shared Repository Boundaries

Status: implemented

- Keep shared domain/repository code for clubs, events, tickets, payments, Event Success, chats, media, analytics, auth, and safety where both apps need it.
- Add app-role facades where read/write operations need role-specific behavior.
- Avoid duplicating Firebase models; separate identity/view models from transport models.

Acceptance:

- Shared code does not import role-specific presentation layers.
- Host presentation code can be tested without consumer shell dependencies.

### 6. Push Token And Installation Model

Status: implemented

- Replace single `users/{uid}.fcmToken` ownership with app-role/install-scoped tokens.
- Proposed shape: `users/{uid}/pushInstallations/{installationId}` with `appRole`, `platform`, `token`, `updatedAt`, `environment`, and app version metadata.
- Keep legacy `fcmToken` read compatibility during migration.
- Route notifications by notification type and app role.

Acceptance:

- Installing both consumer and host apps does not make either app lose notifications.
- Host operational notifications do not open consumer dating routes.
- Consumer dating notifications do not open host routes.

### 7. Host Identity Schema

Status: implemented

- Add durable host identity separate from dating/public profile.
- Proposed canonical shape: `hostProfiles/{uid}` plus club-scoped host display snapshots on `clubs/{clubId}.hostProfiles`.
- Host profile fields should include professional display name, avatar/logo URL, bio/role, verified state, linked clubs, permissions, contact policy, created/updated timestamps, and moderation state.
- Add `users/{uid}.roles.host` or equivalent account-role summary for fast gating, but keep professional host profile data out of the dating public profile.

Acceptance:

- Host app onboarding can create/claim a host profile without requiring dating onboarding completion.
- Consumer event and club surfaces render host identity from host profile/snapshot data, never from dating profile projection.
- Clicking a host avatar from host-owned surfaces cannot open the dating profile unless a future explicit product decision adds a separate public host page.

### 8. Professional Message-Host Conversations

Status: implemented

- Separate message-host threads from dating match chats in routing, headers, metadata, and analytics.
- Header should show event/club/host support context, not dating U-Meta or match compatibility data.
- Host avatar in these threads should be non-navigational or open a professional host page only.
- Preserve moderation, blocking/reporting, and notification safety semantics.

Acceptance:

- Message-host button starts or opens an operations/support conversation.
- Conversation UI does not expose dating profile, dating metadata, match status, or compatibility indicators.
- Both host and consumer apps can participate in the same professional thread with role-appropriate UI.

### 9. Event Success Host Runtime

Status: implemented

- Keep Event Success attendee companion runtime consumer-visible.
- Move host authoring/control surfaces to host app.
- Ensure host app can configure groups, assignments, first-hello/arrival ritual, readiness checks, and live showtime controls.
- Keep plan writes callable/rules-authorized for host owners only.

Acceptance:

- Host Event Success setup and live operations work from host app.
- Consumer app only sees attendee-facing companion/arrival/runtime experiences.

### 10. Native Targets, Bundle IDs, And Firebase Apps

Status: implemented

- Add app-role flavor dimension or separate native targets for consumer and host.
- Android needs distinct application IDs for host builds across dev/staging/prod.
- iOS needs distinct bundle IDs, schemes, display names, icons, entitlements, and Firebase app configs for host builds.
- Update Firebase config storage and `tool/use_firebase_environment.sh` to copy role-aware configs.

Acceptance:

- Consumer and host apps can be installed side by side on the same device.
- Each app registers to the correct Firebase app and App Check identity.
- CI/build scripts can build every environment-role pair.

### 11. Deep Links, Universal Links, And Routing Contracts

Status: implemented

- Define role-specific deep-link hosts/paths.
- Consumer links should open consumer attendance/discovery/chat flows.
- Host links should open host manage/edit/Event Success operational flows.
- Add fallback behavior when the wrong app receives a link.

Acceptance:

- Host operational notification links do not land in consumer dead routes.
- Public event links remain consumer-friendly.
- Shared URLs have deterministic fallback screens.

## Implementation Order

1. Land app role, bootstrap, explicit entrypoints, and tracker. Done.
2. Split router providers into consumer/host graphs while preserving current consumer behavior. Done.
3. Build host shell with existing host screens mounted inside it. Done.
4. Gate/remove host actions from consumer screens. Done.
5. Add host identity model and migrate message-host UI away from dating profile assumptions. Done.
6. Split push token storage and notification routing. Done.
7. Add native role configs and Firebase app config tooling. Done.
8. Wire deep links and CI/build matrix. In-app route/deep-link contracts done; GitHub app build matrix includes dev host web, prod host web, Android debug, and iOS simulator build jobs.
9. Run full contract checks, targeted Flutter tests, and simulator smoke for both entrypoints. Contract checks, targeted tests, host web/Android/iOS/macOS builds, consumer Android debug build, host-specific launcher asset generation, and App Check provider verification passed.

## Open Decisions

- Whether `hostProfiles/{uid}` should later become organization-backed in addition to user-backed. The implemented migration supports user host profiles plus club-scoped display snapshots.
- Whether message-host should eventually move to a dedicated support-thread collection. The implemented migration keeps typed professional host inquiries inside the existing match/chat model for compatibility.
- Whether host app launches initially to a native mobile shell only or includes a parallel web dashboard at `hosts.catchdates.com`. This tracker focuses on mobile app separation first.
- Host store release follow-ups live in `docs/release_operations.md`: configure the Xcode Cloud workflow for App Store Connect app `6778927317` / `com.catchdates.host`, then prove a host TestFlight upload/install/launch cycle. Apple Developer/App Store Connect host records, repo-side host icons, and GitHub break-glass host archive/export support are implemented.
