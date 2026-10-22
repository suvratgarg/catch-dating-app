# Catch Host Store Metadata

This is the record of the store metadata submitted for `Catch Host` on the App
Store and Google Play. Evidence is the ignored local folder
`build/store-upload/`, captured on 2026-10-20 and 2026-10-21:

- `host-store-progress-20261020.json`
- `host-listing-copy-draft.json`
- `catch-host-closed-test-brief.txt`
- the `apple-*.png` and `google-*.png` console screenshots

The reviewer credential files in that folder are private and are never copied
here.

## App Store (iOS)

### Submission

| Field | Live value |
| --- | --- |
| Apple app ID | `6778927317` |
| Bundle ID / SKU | `com.catchdates.host` / `catch-host-ios` |
| Version / build | `1.0.1` / `202610200000357901` (source `171c1cb07`) |
| Status | Submitted 2026-10-21; Waiting for Review |
| Developer account (seller) | Individual: Suvrat Garg |
| Copyright | `2026 Torana` |
| Primary language | English (U.S.) |
| Price / in-app purchases | Free / none |

### Product page

| Field | Live value |
| --- | --- |
| Name | Catch Host |
| Subtitle | Events and guest management |
| Promotional text | Create events, manage guests, check people in, and review private post-event signals from one host workspace. |
| Keywords | `events,organizer,guests,attendance,check-in,event management` |
| Privacy Policy URL | `https://catchdates.com/privacy/` |
| Support URL | `https://catchdates.com/help/` |
| Screenshots | 3 iPhone (6.3-inch, 1206×2622: Today, Rehearsal, Room) and 2 iPad (13-inch landscape, 2752×2064: Rehearsal, Room). Validation passed. Source files are in `build/store-upload/listing-assets/`. |

The App Store screenshot of the version page shows the promotional text. The
other product-page values come from the listing copy record.

Description, from the listing copy record (`host-listing-copy-draft.json`):

```text
Catch Host helps organizers prepare events and manage the people attending them.

Use your organizer workspace to:
• Create and update event details.
• Keep your events and guest information together.
• Manage attendance and event check-in.
• Communicate through event conversations and announcements.
• Work across the organizers you have access to.

Sign in with your phone number to access your Host account. Available tools depend on your organizer access and event setup.

Catch Host is for adults aged 18 and over. Catch Host is operated by Torana.

Support: https://catchdates.com/help/
Privacy: https://catchdates.com/privacy/
```

The description mentions no price, subscription, trial, or purchase outside the
app.

### Other App Store Connect declarations

| Declaration | Live value |
| --- | --- |
| App Review contact, reviewer sign-in and notes | Saved. Values live only in App Store Connect and the private local credential file. |
| Content rights | Saved |
| App Privacy | Published 2026-10-20: 18 data types, all linked, tracking No. See `privacy_inventory.md`. |
| EU Digital Services Act trader status | Trader declaration submitted. Status In Review, last updated 2026-10-21. |
| Export compliance | `ITSAppUsesNonExemptEncryption` = `false` in the submitted `apps/host/ios/Runner/Info.plist`. Standard TLS and Apple platform crypto only; `package:crypto` is used for SHA-256 hashing only. |

### Age rating

| Item | Live value |
| --- | --- |
| Calculated rating | 13+ |
| Override | 18+. Read back as 18+ in 173 countries or regions and 19+ in Korea; older OS versions show 17+ with regional exceptions. |
| Alcohol, tobacco, or drug use or references | Infrequent. The owner confirmed occasional alcohol-related events, and "Pub quiz" and "Bar crawl" are selectable activity types. |
| Violence (all four questions) | None, confirmed by the owner |
| Age suitability URL | `https://catchdates.com/terms/` |

The remaining questionnaire answers are not captured in the local evidence.
The source supports a 13+ calculation from these answers:

- User-generated content: Yes. Organizer pages and events are public.
- Messaging and chat: Yes. Hosts have inbox conversations with guests.
- Mature or suggestive themes: likely Infrequent, because the app includes
  tooling for singles events.
- Everything else: None.

## Google Play (Android)

| Field | Live value |
| --- | --- |
| App ID / package | `4972959437074694171` / `com.catchdates.host` |
| Internal testing | `1.0.1 (452901)` "Host initial testing", available to internal testers since 2026-10-20 (not reviewed). Draft `1.0.1 (457901)` "Host store candidate" kept as a draft. |
| Closed testing | Alpha track, India, `1.0.1 (457901)`. Submitted 2026-10-21 with 14 publishing changes; automated checks passed. |
| Production access | Needs at least 12 opted-in testers for 14 continuous days, then a production-access application |
| Title | Catch Host |
| Short description | Plan events and manage guests in one organizer workspace. |
| Full description | Same text as the App Store description above |
| Graphics | 512 icon. 1024×500 feature graphic, image-generated and labelled AI-created. 3 phone screenshots. |
| Content rating (IARC) | Category "All Other App Types". Teen in North America; 12+ in several other regions. Location sharing: Yes. |
| Target audience | 18 and over |
| App access | Reviewer access saved |
| Advertising ID | Yes, for Analytics |
| Data safety | Saved and submitted: no data shared with third parties |
| Other declarations | No ads; not a government app; no health features; no financial-services features. Content declarations show "All caught up" (10 actioned). |
| Privacy URL | `https://catchdates.com/privacy/` |

## Seller and copyright facts

- **Seller and copyright differ.** The App Store seller is the individual
  account holder, Suvrat Garg. The copyright line and the listing description
  name Torana, which is also the operator in the public Terms and Privacy
  policy.
- **Organization accounts need a legal entity.** Apple enrolls an organization
  only as a legal entity with a D-U-N-S number. A move to an organization
  account would change the seller name shown on the store.
