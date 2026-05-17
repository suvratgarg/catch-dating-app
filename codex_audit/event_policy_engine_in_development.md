# Event Policy Engine In Development

Status: in production migration, wired into create-event and booking while the
lab remains available for product review.

Owner intent:

- Keep `lib/event_policies/**` and `test/event_policies/**` even though the
  migration is still in progress and some formats remain preview-only.
- Do not delete this code as dead code during cleanup/audit passes.
- Production event creation now writes an `EventPolicyBundle` snapshot while
  keeping `Event.capacityLimit`, `Event.priceInPaise`, and `EventConstraints` as
  backward-compatible projections for legacy surfaces and documents.
- Booking/payment callables use backend-owned policy helpers for admission,
  cohort counts, viewer-specific price quotes, waitlist movement, and
  host-cancellation refunds.
- This policy engine is the proving ground for the future event-platform model:
  invite-only events, ranked or broadcast waitlists, balanced-ratio admission,
  inclusive cohort handling, cohort/demand-aware pricing previews, bounded
  cancellation policies, and platform-held settlement until completion.
- `lib/event_policies/domain/event_policy_preview.dart` keeps deterministic
  host-configuration fixtures for product review and tests.
- `lib/event_policies/presentation/event_policy_lab_screen.dart` is the
  dev/staging-only visual lab for those fixtures. It is reachable at
  `/dev/event-policy-lab` and from Settings when `AppConfig.enableEventPolicyLab`
  is true.

Migration rule:

1. Keep the lab read-only/static; it must not write drafts, Firestore, callables,
   Razorpay, attendance, swipes, reviews, or chat.
2. Keep the live migration backward-compatible with legacy event documents that
   only have capacity, price, and `EventConstraints`.
3. Treat the policy snapshot as the source for new event admission, pricing,
   cancellation, and settlement behavior, with server-side helpers as the
   backend authority.
4. Paid waitlist promotion must use an offer/quote/payment step before moving a
   user from waitlisted to signed up.
5. Inclusive event formats should use explicit cohort policies rather than
   forcing non-binary, queer, or open-to-multiple-genders users into a binary
   gender-ratio bucket.
6. Cancellation policy is a bounded platform policy axis, not free-form host
   text. Host cancellations always make attendees complete, and host payout is
   held until after event completion.

Current proof:

- `test/event_policies/event_policy_preview_test.dart` covers invite-only,
  capacity-only, balanced-ratio, demand-priced, and cancellation preview
  behavior.
- `test/event_policies/event_policy_lab_screen_test.dart` covers the visual lab
  on mobile and wider viewports, including demand-priced preview rows,
  cancellation rows, and debug payload rendering.
- `test/core/app_config_test.dart`, `test/routing/router_redirect_test.dart`,
  and `test/safety/settings_screen_test.dart` cover the dev-only availability
  gate, public static route behavior, and Settings entry.
- `test/events/create_event_screen_test.dart`,
  `test/events/create_event_controller_test.dart`,
  `test/events/event_detail_widgets_test.dart`, and Functions event/payment tests
  cover the first production migration path.

Preview fixture catalog:

- `invite_only_private_event`: private paid event, invite gate, no waitlist.
- `capacity_only_open_run`: total-capacity event with broadcast waitlist and no
  cohort balancing.
- `balanced_ratio_ranked_waitlist`: rough 50:50 binary ratio with tolerance,
  ranked waitlist, and manual review for out-of-ratio cohorts.
- `demand_priced_balanced_event`: balanced event with cohort demand premium and
  supply incentive previews, plus strict bounded cancellation examples.
- `queer_inclusive_affinity_event`: members/invites event using interest pools
  and explicit non-binary allocation rather than binary-only balancing.

Manual testing:

- Event the app against `dev` or `staging`.
- Open Settings and tap `Event policy lab`, or navigate directly to
  `/dev/event-policy-lab`.
- The lab is read-only/static. Production migration testing should happen
  through the normal create-event flow, event detail CTA, and Functions tests.
