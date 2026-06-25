# Catch Host App Review Notes Draft

Use this as the starting point for App Store Connect review notes after the Host
TestFlight build is uploaded and smoke tested.

## Reviewer access

TBD before submission:

- Host reviewer account phone/email:
- OTP or sign-in instructions:
- Seeded club:
- Seeded event:
- QR/check-in sample, if needed:
- Backend environment:

## Suggested review-note text

Catch Host is the organizer app for approved Catch event hosts. It is separate
from the consumer Catch dating app and does not expose consumer dating browse or
matching surfaces to hosts.

Please sign in with the provided Host reviewer account. The account is seeded
with a club, a draft event, a published event, and sample attendee activity so
the Host flows can be reviewed without creating live production data.

Recommended review path:

1. Sign in with the provided Host reviewer account.
2. Open the Host home or events area and review the seeded club/event list.
3. Open an event and review event setup, admission/waitlist rules, invite links,
   and payment-related controls if present.
4. Open the attendance/check-in tools for the seeded event.
5. Open Event Success host tooling for live event operations.
6. Open the post-event report and confirm that it shows aggregate host-facing
   information only.
7. Open Settings, then verify Privacy Policy, Terms, Help & Support, and Delete
   Account entry points.

The app uses Firebase-backed services, App Check/App Attest, push
notifications, and Maps. Backend services must be live for review. Push
notifications and photo/location permissions are optional unless the reviewer
chooses flows that request them.

Safety controls are available through report, block, moderation, and account
deletion flows. Host identity is professional and role-gated; hosts do not need
to complete a consumer dating profile to operate Host tools.

## Submission blockers

- Replace every `TBD` reviewer-access value.
- Confirm App Check/App Attest accepts the production Host bundle ID.
- Confirm the seeded reviewer account does not require real payments.
- Confirm check-in and Event Success review flows have stable seeded data.
- Confirm account deletion is reachable in the submitted Host build.
