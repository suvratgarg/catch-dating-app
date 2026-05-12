---
doc_id: location_stack
version: 1.1.0
updated: 2026-05-12
owner: recursive_audit_loop
status: active
---

# Location Stack

## Product Policy

Catch should treat location as optional for account creation and general app
usage, but required for workflows where location is the product guarantee.

- Users can browse clubs, view profiles, chat, and use most app surfaces without
  sharing live device location.
- Hosts must pin exact run starting coordinates when creating a run.
- Participants must be near the pinned run coordinates to self check in.
- Exact user coordinates must not be exposed through public profile documents.
- Run coordinates are event coordinates, not private user coordinates, and can
  be shown on maps or opened in navigation apps.

## Current State

The app currently uses:

- `geolocator` for device location.
- `google_maps_flutter` for in-app run maps and run-location picking.
- `LocationCoordinate`, the app-owned coordinate value object, for domain
  coordinates and client-side distance calculations.
- `users/{uid}.latitude/longitude` as private profile fields.
- `publicProfiles/{uid}.city` for public coarse location; exact coordinates are
  not projected into public profiles.
- `runs/{runId}.startingPointLat/startingPointLng` for pinned run locations.
- `selfCheckInAttendance` Cloud Function for authoritative distance-gated
  check-in.
- `placesAutocomplete` and `placeDetails` callable Functions as the server-side
  bridge to Google Places API (New).

## Implemented in This Pass

- New run creation now requires `startingPointLat` and `startingPointLng` in the
  Flutter controller and in the `createRun` Cloud Function schema.
- Create-run UI now marks the map pin as required and blocks progression until
  the host pins an exact starting point.
- New run documents now store non-null starting coordinates.
- Existing coordinate-less legacy runs remain readable so old data does not
  crash map/detail screens.
- Run detail location taps now open an in-app run location preview; the preview
  has an explicit Google Maps directions CTA.
- Payment confirmation directions share the same Google Maps directions URL
  helper.
- `flutter_map` has been removed from `pubspec.yaml`; map rendering now goes
  through Google Maps SDK for Flutter.
- The location picker now supports Google Places-backed search, with
  Autocomplete session tokens and India-biased results.
- Google Places API keys stay server-side in Firebase Secret Manager; the app
  does not ship a Places web-service key.
- Participant self-check-in now opens 10 minutes before the run, closes 30
  minutes after the run start, and keeps the 200 m maximum distance.
- Check-in location permission failures now surface clear user-facing guidance
  for disabled services, denied permission, and permanently denied permission.
- Public profile exact coordinates have been removed from the Dart model,
  Firestore TypeScript contract, and `syncPublicProfile` projection.
- `tool/strip_public_profile_coordinates.mjs` can dry-run/apply removal of
  legacy `latitude`/`longitude` fields from existing `publicProfiles` docs.
- `latlong2.LatLng` has been removed from app-facing code and the dependency
  graph; SDK-specific coordinate types now stay at Google Maps adapter edges.
- `tool/validate_google_maps_config.mjs` validates dev/staging/prod local Maps
  SDK config for iOS and Android without printing secrets. `tool/flutter_with_env.sh`
  runs that validation before native run/build commands.
- Native iOS and Android key loaders defensively trim the accidental `keyString:`
  wrapper so local key copy/paste mistakes fail less mysteriously.

## Google Maps Usage Tiers

As of the 2025 Google Maps Platform pricing model:

- Essentials SKUs generally include 10,000 free billable events per SKU per
  month.
- Pro SKUs generally include 5,000 free billable events per SKU per month.
- Enterprise SKUs generally include 1,000 free billable events per SKU per
  month.
- Essentials Map Tiles APIs are documented separately as up to 100,000 free
  calls per SKU per month.
- Google replaced the old USD 200 monthly credit with per-SKU monthly free
  usage caps.
- India billing can have reduced INR pricing for eligible India-based customers
  with primary India usage.

References:

- https://mapsplatform.google.com/pricing/
- https://developers.google.com/maps/billing-and-pricing/overview
- https://developers.google.com/maps/billing-and-pricing/india

## Recommended Provider Direction

- Use Google Maps SDK for Flutter for in-app maps.
- Use Google Places API (New) through callable Functions for meeting-point
  autocomplete and place details.
- Continue using external Google Maps URLs for turn-by-turn directions instead
  of building route rendering into Catch. In-app map previews should show the
  destination; routing belongs in Google Maps.
- Set API quotas and billing alerts before enabling any paid map provider.

## Google Cloud Setup Required

1. Attach billing to each Google Cloud project backing the Firebase
   environments you want to run with real maps.
2. Enable these APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API (New)
3. Create an Android-restricted Maps SDK key:
   - API restriction: Maps SDK for Android only.
   - App restriction: Android apps.
   - Add the Catch package names and signing certificate SHA-1s for debug,
     upload, and release builds.
   - Put the key in `android/local.properties` as
     `GOOGLE_MAPS_ANDROID_API_KEY=...`, or provide the same value as an
     environment variable in CI.
4. Create an iOS-restricted Maps SDK key:
   - API restriction: Maps SDK for iOS only.
   - App restriction: iOS apps.
   - Add each Catch bundle ID used by dev, staging, and prod.
   - Copy `ios/Flutter/GoogleMapsKeys.xcconfig.example` to
     `ios/Flutter/GoogleMapsKeys.xcconfig` and set
     `GOOGLE_MAPS_IOS_API_KEY=...`.
5. Create a server-side Places API key:
   - API restriction: Places API (New) only.
   - Do not put this key in Flutter, Android, or iOS config.
   - Store it as a Firebase Functions secret:
     `firebase functions:secrets:set GOOGLE_MAPS_PLACES_API_KEY`.
6. Set conservative quotas before TestFlight:
   - Maps SDK daily map-load quota per project.
   - Places Autocomplete request quota.
   - Place Details request quota.
   - Billing budget alert at a low threshold, plus a second alert at the
     maximum monthly amount you are willing to spend during beta.
7. Deploy Functions after setting the secret so `placesAutocomplete` and
   `placeDetails` can start.

## Remaining Implementation Plan

### Phase 1: Privacy Boundary

- Run `tool/strip_public_profile_coordinates.mjs --env <env>` as a dry run,
  then rerun with `--apply` for each environment that has legacy public
  coordinates.
- Decide whether swipe cards should show no location copy, city-only copy, or a
  coarse same-city/nearby-city label.
- Define `prefsShowOnMap` precisely or rename it if it does not control a real
  public map surface.

### Phase 2: Location Module

- Move location code into a dedicated `lib/location` feature.
- Add `LocationSnapshot`, `ApproximateLocation`, and `LocationPurpose` domain
  types.
- Centralize Geolocator usage in one `LocationRepository`.
- Add TTL/refresh policy:
  - low accuracy for city detection and map centering,
  - high accuracy only for check-in,
  - no background tracking,
  - manual refresh affordance.

### Phase 3: Run Location Quality

- Store the selected provider place id when available.
- Store display address separately from host-written meeting instructions.
- Validate run coordinate ranges in Firestore rules and callable schemas.
- Consider making host run edits require a pinned location before schedule or
  location changes are saved.

### Phase 4: Check-In Hardening

- Keep server-side check-in distance validation authoritative.
- Log check-in failure reason categories without storing raw coordinates in
  analytics.
- Add abuse controls for repeated failed check-ins.
- Keep host manual attendance as an override for edge cases.

### Phase 5: Maps Productionization

- Keep Google Maps as the production map provider unless product requirements
  force a provider change.
- Keep Google Maps SDK keys in environment-specific native config, with
  `tool/validate_google_maps_config.mjs` as the local guardrail.
- Add budget alerts, quota limits, and release checklist items.
- Add widget tests for disabled map base tiles and integration QA for real map
  rendering on device.

## Current Maps And Demo-Data Readiness

The retired transient maps/demo tracker has been folded into this document and
`docs/demo_data_seeding.md`.

Completed:

- Dashboard map view, create-run pin picker, run-detail location preview, and
  payment-confirmation directions all use the Google Maps stack.
- Native iOS/Android Maps config is validated by
  `tool/validate_google_maps_config.mjs`, and `tool/flutter_with_env.sh` runs
  that validation before native run/build commands.
- Active source/config no longer depends on `flutter_map`, OpenStreetMap, or
  `latlong2` app-facing coordinate types.
- Seeded runs use curated venue coordinates and validation rejects missing or
  drifted active run coordinates.
- Demo ops validation reports upcoming mapped runs and check-in-window
  signed-up runs.
- Active app models now store city/location as string ids backed by Firestore
  city config plus `city_catalog.dart` fallbacks.

Still open:

- Run on simulator/phone and capture proof that the map renders. Current
  blocker is local Xcode platform support for the target iOS runtime.
- Keep improving check-in-specific demo data so each anchor demo account can
  reliably test a location-gated run.
