# Catch Host App Store Metadata

Draft App Store Connect metadata for `Catch Host`. Copy fields are ready to
paste. Fields marked **Pending** wait on the owner decision named in the row.

## App identity

| Field | Draft value | Notes |
| --- | --- | --- |
| App name | Catch Host | 10 characters |
| Bundle ID | `com.catchdates.host` | Matches the `host-prod` target in `apps/host` |
| Apple app ID | `6778927317` | Existing App Store Connect record |
| SKU | `catch-host-ios` | Existing App Store Connect record |
| Primary language | English (U.S.) | Existing App Store Connect record |
| Primary category | Business | Organizer operations tool |
| Secondary category | Productivity (recommended) | Social Networking would frame the app as consumer social and invite stricter content review. Lifestyle is a neutral alternative. |
| Price | Free | No in-app purchases. See the payment posture in `review_notes.md`. |
| Seller name | **Pending**: individual vs organization account | Apple shows the developer account holder. The account is individual today. |
| Copyright | **Pending**: same decision | `2026 Torana` if the account becomes an organization; `2026 Suvrat Garg` if it stays individual |
| Age rating | See the questionnaire below | The rating Apple calculates from the answers is likely below the 18+ that the Terms require |

### Seller-dependent facts

- The public Terms and Privacy policy name **Torana** as the operator of
  Catch, and require users to be 18 or older.
- An organization enrollment needs a legal entity with a D-U-N-S number. Apple
  enrolls sole proprietors and trade names as individuals, so if Torana is not
  a separate legal entity, the seller stays the individual account holder.
- The seller decision also determines:
  - the copyright line
  - the name on the store page
  - the EU Digital Services Act trader contact details, which App Store
    Connect requires only when the app is offered in EU storefronts

## URLs

All four returned HTTP 200 on 2026-10-22. A nonexistent path returns 404, so
the 200 responses are real pages.

| Field | Value |
| --- | --- |
| Privacy Policy URL | `https://catchdates.com/privacy/` |
| Support URL | `https://catchdates.com/help/` |
| Marketing URL | `https://catchdates.com/host/` |
| Terms (custom EULA or description link, optional) | `https://catchdates.com/terms/` |

## Copy fields

| Field | Draft value | Limit check |
| --- | --- | --- |
| Subtitle | Tools for event hosts | 21 of 30 characters |
| Promotional text | Create events, manage guests, check people in, and review private post-event signals from one host workspace. | 109 of 170 characters |
| Keywords | events,hosts,organizers,checkin,guestlist,clubs,waitlist,tickets,attendance,runclubs | 84 of 100 bytes |

## Description

Catch Host is the operator app for approved Catch organizers and partners.

Create clubs and events, publish guest-facing details, configure admission and
waitlist rules, and manage the event from one host workspace. During an event,
hosts can check people in, review attendance and payout state, and use Event
Success tools to keep the experience on track.

After the event, Catch Host summarizes aggregate operational signals and
follow-up items while keeping private attendee matching choices and safety
details out of host reports. Host identity stays professional and separate from
consumer dating profiles.

Use Catch Host to:

- Build a professional host profile
- Create clubs and event listings
- Configure capacity, approvals, payments, waitlists, and invite links
- Manage check-in and attendance
- Review aggregate post-event reporting
- Keep organizer tools separate from the Catch dating experience

### Copy facts

- The copy contains no price, subscription, trial, or reference to paying
  Catch outside the app. Guideline 3.1.1 and 3.1.3(f) depend on that staying
  true. "Payments" in the bullet list refers to guests paying organizers for
  in-person events.
- Two lines mention the consumer dating experience, but the consumer Catch app
  is not on the App Store.
- The first line says "approved … organizers", but any signed-in user can
  create an organizer in the Host app today.

## Age rating questionnaire

These are the answers for the App Store Connect age rating questionnaire, in
the version Apple introduced in 2025 with 4+, 9+, 13+, 16+ and 18+ ratings.
Check the question labels against the live form when entering them.

| Section | Question | Answer | Basis |
| --- | --- | --- | --- |
| In-app controls | Parental controls | No | — |
| In-app controls | Age assurance | No | The 18+ requirement is contractual (Terms). Host does no age verification. |
| Capabilities | Unrestricted web access | No | External links open in Safari. The app has no general-purpose browser. |
| Capabilities | User-generated content | Yes | Organizer pages, event listings and photos are public on the website |
| Capabilities | Messaging and chat | Yes | Inbox conversations and broadcasts with guests |
| Capabilities | Advertising | No | No ad SDK or ad placements |
| Mature themes | Profanity or crude humor | None | — |
| Mature themes | Horror or fear themes | None | — |
| Mature themes | Alcohol, tobacco, or drug use or references | Infrequent | "Pub quiz" and "Bar crawl" are selectable event activity types (`lib/activity/domain/activity_taxonomy.dart`) |
| Medical or wellness | Medical or treatment information | None | — |
| Medical or wellness | Health or wellness topics | No | Fitness activities are event types, not health content |
| Sexuality or nudity | Mature or suggestive themes | Infrequent | Tooling for singles events: mixer reveals, pairing, and cohort caps by gender and orientation |
| Sexuality or nudity | Sexual content or nudity | None | — |
| Sexuality or nudity | Graphic sexual content and nudity | None | — |
| Violence | Cartoon or fantasy, realistic, prolonged graphic, guns or weapons | None | — |
| Chance-based | Simulated gambling, contests, gambling, loot boxes | None / No | — |
| Other | Made for Kids | No | — |

The recommended age rating is **18+**, set with the questionnaire's option to
choose a higher rating than the calculated one. Three facts support 18+: the
Terms require users to be 18 or older; payouts need legal capacity for
Razorpay or Stripe KYC; and the app operates singles events. This is an
owner decision.

## Export compliance

| Item | Value | Evidence |
| --- | --- | --- |
| `ITSAppUsesNonExemptEncryption` | `false` | `apps/host/ios/Runner/Info.plist`, so App Store Connect skips the per-build encryption question |
| Encryption in use | Standard TLS only: URLSession, Firebase SDKs, and Firestore gRPC with BoringSSL. Apple platform crypto: App Attest and Keychain. | No custom encryption. `package:crypto` is used only for SHA-256 hashing. No SQLCipher. |
| Basis | Exempt: encryption used only for authentication and standard secure transport | Revisit if end-to-end message encryption or custom ciphers are added |

## Other App Store Connect answers

| Item | Draft answer | Notes |
| --- | --- | --- |
| Content rights | Contains third-party content, with rights held | Organizer-supplied text and photos, and Google Maps tiles |
| Sign-in required for review | Yes | See `review_notes.md` |
| App privacy | See `privacy_inventory.md` | — |
| Availability | **Pending**: owner territory choice | The pilot is India-first. Excluding EU storefronts avoids the DSA trader-status display until the seller decision is made. |
