# Catch Host App Review Notes

App Review access, the review-notes text, and the payment posture for the
`Catch Host` submission. Source facts were read on 2026-10-22 at `origin/main`
`3c930f24b`.

## How sign-in works

- The only sign-in method in the Host build is Firebase phone authentication
  with a 6-digit one-time code. The app has no password and no Google or Apple
  sign-in, so Guideline 4.8 (Sign in with Apple) does not apply.
- Any signed-in user can create an organizer. Club creation needs no approval
  gate, so a reviewer can also start from an empty account.
- The phone field's default country comes from the device locale, and the
  country picker accepts any code. Validation only checks digit count
  (`lib/auth/presentation/auth_input.dart`).
- Firebase Auth test phone numbers skip SMS delivery. On a physical device,
  app verification (App Attest and the APNs check) still runs as it does for a
  real number.

## Reviewer account design

Two Firebase Auth test numbers in the prod project `catch-dating-app-64e51`:

| Account | Purpose | State at submission |
| --- | --- | --- |
| A: demo organizer | Main review path | Signed in once, onboarded, owns the sample organizer and events |
| B: new host | First-run experience and **Delete account** | Never signed in. The reviewer creates it on first sign-in. |

These rules apply to the test numbers:

- **Keep numbers and codes out of this repository**, which is public. The
  values live only in App Store Connect → App Review Information and in the
  owner's password manager.
- **Use the fictional US range +1 (650) 555-0100 to 555-0199.** Reviewer
  devices usually default to +1, and this range is reserved for fiction.
- **Each number gets its own 6-digit code.** Neither code may be reused for any
  other account.
- **The numbers work project-wide.** Test numbers apply to every client of the
  prod project: the consumer app, the Host app and the website.
- **Deletion needs a fresh account.** Deleting account A removes the demo
  organizer access. The notes therefore point reviewers to account B for
  deletion. If account A is deleted anyway, repeat steps 3–6 of the procedure
  below before resubmitting.

## Provisioning procedure (needs owner approval; not performed)

Nothing below has been created in prod.

1. Confirm that the build chosen for submission is on TestFlight. Its release
   run must have passed
   `node tool/firebase/check_client_callable_dependencies.mjs --role host --environment prod --verify-live`,
   so that every callable the build uses exists in prod.
2. In the Firebase console, open `catch-dating-app-64e51` → Authentication →
   Sign-in method → Phone → **Phone numbers for testing**. Add numbers A and
   B, each with its own code.
3. On a physical iPhone running the TestFlight Host build, sign in with number
   A. This creates the Firebase Auth user and `users/{uid}`.
4. Complete Host onboarding. Create the organizer **Catch Review Demo** with a
   short description that says it is a sample organizer for App Review. Use a
   cover image Catch owns.
5. Create two events from the Events tab:
   - One free, open-admission event about two to three weeks after the planned
     submission date, with capacity 20 and a public venue. Give the title a
     `[Sample]` prefix and publish it.
   - One draft event, left unpublished.
   - Keep both events free so no payout account is needed. Never enter real
     bank or PAN details for the demo organizer.
6. Optional: register for the sample event on its public `catchdates.com`
   page with a third test number (C), so the guest list and Check-in board
   show one guest.
7. Sign out, sign back in with A, and walk the review path below. Organizer →
   Account menu must show Privacy policy, Terms, Help & support and Delete
   account. The first three appear only in a build that includes the
   legal-links change.
8. In App Store Connect → App Review Information, set **Sign-in required** on.
   Enter A's number in E.164 form as the user name and A's code as the
   password. Paste the notes below with the placeholders filled in, and add the
   owner's contact name, phone and email.

The published sample event is public on `catchdates.com` and in consumer
discovery for as long as it stays published. Account A has a `users/{uid}`
document like any other user.

## App Review notes text

Paste this after replacing every `<…>` placeholder. It is about 2,050
characters, within the 4,000-character limit.

```text
Catch Host is the organizer app for people who run in-person social events
such as run clubs, dinners, mixers and workshops. Organizers set up their
public organizer page and events, manage guest lists and check-in, message
guests and run the live event. Guests do not need this app; they register on
catchdates.com.

SIGN-IN
Catch Host uses phone-number sign-in with a one-time code. The numbers below
are test numbers: no SMS is sent, so enter the code shown here. Pick the +1
country code if it is not preselected.
- Demo organizer with sample data: <A phone>, code <A code>
- New, empty account (safe to delete): <B phone>, code <B code>
Please use the new account to test account deletion so the demo data stays
available.

SUGGESTED PATH (demo organizer)
1. Today: current work for the sample organizer "Catch Review Demo".
2. Events: open the "[Sample]" event to see event setup, admission and
   waitlist rules, the guest list and the Check-in board. "Create event" walks
   through the full setup flow.
3. Audience: guest and customer records for the organizer.
4. Inbox: guest conversations. Each conversation menu has Report and Block.
5. Organizer: the public page editor and preview. The Account menu (top
   right) contains Privacy policy, Terms, Help & support and Delete account.
   Sign out is next to it.

PAYMENTS
Catch Host sells nothing inside the app. It has no digital purchases,
subscriptions or upgrade prompts. Organizers can optionally connect a payout
account (Razorpay or Stripe) to receive payments that guests make on the web
for in-person event tickets. The demo organizer runs free events, so no payment
setup is needed for review.

PERMISSIONS
Location is requested only if an organizer turns on live location sharing for
a route event, and sharing runs only while the app is in the foreground. Photo
access is used when an organizer chooses an event or organizer photo.
Notifications are optional.

The app uses our production backend; no special configuration is needed.
Contact: <owner name>, <phone>, <email>.
```

## Payments and in-app purchase posture

This section records the 2026-10-22 audit against Guidelines 3.1.1,
3.1.3(c), 3.1.3(e) and 3.1.3(f).

**What was searched.** The Host native graph (`apps/host/ios/Podfile.lock`)
has no StoreKit or `in_app_purchase`. The Host routes in
`lib/routing/go_router.dart` and the Host-audience copy in
`lib/l10n/app_en.arb` contain no plan, subscription, trial, upgrade, price for
Catch Host, or "pay Catch" call to action. The only plan-like UI is the weekly
post quota ("{remainingQuota} of {weeklyQuota} posts left this week" and
"Weekly limit reached"), which has no paid path.

### Money flows reachable in the Host app

| Flow | Where | What happens | Guideline position |
| --- | --- | --- | --- |
| Payout account | `lib/hosts/presentation/payments/host_payment_account_card.dart` | Razorpay Route KYC form in the app. Stripe onboarding opens Stripe's hosted page. | The host receives funds for in-person events. Not a purchase. |
| Form-fee payment connection | `lib/hosts/presentation/forms/host_form_payment_section.dart` | OAuth to the organizer's own payment provider | The organizer collects fees from applicants. Not a purchase. |
| Event offers | `lib/hosts/presentation/forms/host_response_offer_screen.dart` | Shares a guest payment link for an in-person event | 3.1.3(e): physical services paid outside IAP |
| Paid event tickets | Guests on the web | Provider checkout on `catchdates.com` | 3.1.3(e) |

### Commercial model

Catch plans to bill organizers ₹5,000 per month for tooling, outside the app.
The posture this relies on is 3.1.3(f): the app is a free stand-alone
companion to a paid service. Where the customer is an organisation, 3.1.3(c)
also applies. Under 3.1.3(f), the app and its metadata may contain no
purchasing and no call to action for purchase outside the app. That covers
prices, "subscribe", "upgrade", "start trial", "contact sales to unlock" and
links to pricing or payment pages.

An organizer whose paid access has lapsed must see neutral status copy with no
price, link or purchase prompt. Nothing in the Host app gates features on paid
status today.

### External pages the Host app opens

| Destination | Opened from | Current state |
| --- | --- | --- |
| `https://catchdates.com/privacy/`, `/terms/`, `/help/` | Organizer → Account menu, once the legal-links change ships | HTTP 200. Every page carries the site header, which has "Pricing and access" (`/host/#pricing`) and "Apply for a pilot" links (`website/src/content/site.ts`). The `/host/#pricing` section says the pilot is free and lists no purchasable tiers (`website/src/content/hostProduct.ts`). |
| `https://catchdates.com/host/organizer/<id>/messaging` | Organizer → messaging setup → "Connect WhatsApp Business" on iOS (`lib/core/external_links.dart`, `openHostMessagingSetup`) | HTTP 404 live. No website route is registered for it in `design/website/routes.json`. |
| Stripe hosted onboarding, provider OAuth pages, `wa.me` handoffs, map directions | Payout setup, form payments, guest messaging, events | Third-party destinations with no Catch pricing |

## Review-facing facts outside payments

- **Purpose strings.** `apps/host/ios/Runner/Info.plist` uses consumer purpose
  strings:
  - Location: "find nearby events and show distance". Host uses location only
    for live route sharing.
  - Camera: "scan host QR codes". The Host routes do not scan; the QR scanner
    lives in the consumer companion route, though `mobile_scanner` is linked.
  - Calendars: "booked events".
  - Health: two Health strings, although the Host build has no HealthKit
    entitlement.
  - Motion: "Explore … wrist lift".

  Guideline 5.1.1(ii) expects each prompt to describe the actual use.
- **Messaging setup.** The WhatsApp messaging-setup section shows "An
  administrator must configure the Catch Meta app and Embedded Signup
  configuration…" when the provider is not configured in prod.
- **User-generated content (Guideline 1.2).** Guest conversations have Report
  and Block. Organizer content is public on the website.
