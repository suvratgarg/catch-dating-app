# Event Success Module Runtime Tracker

Last updated: 2026-05-21

## Product Research Notes

- Luma separates in-person check-in from broader event management: hosts and check-in staff can scan QR codes, manually search the guest list, and review registration status before confirming check-in. Source: https://help.luma.com/p/check-in-guests-for-in-person-events
- Meetup keeps QR check-in inside an explicit event window, preserves manual attendee management as a fallback, and splits checked-in/not-checked-in/absent states once the event is live. Source: https://help.meetup.com/hc/en-us/articles/45352992737677-Introducing-the-new-attendee-list-and-QR-code-check-in
- Product implication for Catch: event-success modules should not appear just because a plan exists. Each module needs an explicit runtime gate, attendance-derived eligibility, and a server-owned data contract for any social assignment surface.
- Attendease/Eventup, Whova, and EventMobi all treat attendee networking visibility as an attendee choice or organizer-configured privacy policy. Source examples: https://eventupplanner.zendesk.com/hc/en-us/articles/27101288845079-Attendee-Networking, https://whova.com/privacy/, https://help.eventmobi.com/en/knowledge/can-i-hide-my-profile-from-the-attendee-list
- Product implication for Catch: micro-pods need an attendee-owned opt-out that removes the attendee from generated social assignment surfaces without granting client write access to assignment docs.
- Product decision 2026-05-21: guided rotations default to 15-minute rounds but read saved host cadence from `eventSuccessPlans/{eventId}.structureConfig.rotationIntervalMinutes` when present. Rounds are capped by both event duration and feasible interested-in pairings. Straight men/women should be paired with mutual-interest partners first; the scheduler should stop rather than fill leftover time with non-interested social pairs.
- Product decision 2026-05-21: hosts can override generated guided rotations, but safety constraints remain server-enforced. Overrides may bypass interest/gender scoring; they may not pair blocked, opted-out, ineligible, duplicate, or repeated-round attendees.
- Product decision 2026-05-21: V1 host overrides are edit-after-generate only. Hosts should generate a server-owned schedule first, then edit generated rounds; blank manual schedule creation is deferred.
- Product decision 2026-05-21: richer balancing should maximize mutual-interest pairings with fairness guardrails. The scheduler should pull underexposed compatible attendees back into the schedule before already-served attendees keep consuming all remaining mutual-interest pairs.
- Product decision 2026-05-21: the 12-item event-success list is implementation inventory, not product architecture. Host setup should group tools into layers: event structure, roster/attendance, assignments, compatibility, live reveal, conversation prompts, post-event matching, host coach, and safety. Event structure owns unit type, unit size, optional unit count, rotation cadence, and reveal countdown.
- Rotation research note 2026-05-21: classic round-robin/circle-method scheduling provides no-repeat pairings and uses a dummy/bye for odd participant counts. Speed-dating generators also commonly rotate one side and give uneven cohorts rotating breaks. Keep this as the design reference for a later richer balancing pass; V1 remains interest-scored generation with host override. Sources: https://en.wikipedia.org/wiki/Round-robin_tournament and https://speeddatingrotationgenerator.com/
- Matchbox research note 2026-05-21: Matchbox positions the reveal as a synchronized release moment, with countdown suspense, clues, and match explanations as the memorable product layer. Catch should treat live reveal as a host-controlled ceremony around assignments, not as decoration after rotations. Source: https://match.box/
- Product decision 2026-05-21: live reveal persists host-owned state on `eventSuccessPlans/{eventId}` and supports countdown, reveal-now, and reset for the current assignment round. It gates attendee companion UI for pods/rotations, but V1 does not make prewritten assignment docs secret from assigned attendees.
- Product decision 2026-05-21: host-assisted "private crush" is modeled as an explicit wingman request, not by exposing normal swipe targets. Attendees can opt into host visibility during the event after check-in; hosts see only consented requests and can use rotation edits or live facilitation to help.
- Product decision 2026-05-21: social missions and contextual openers are one conversation-cue layer in production UI. V1 derives live prompts and post-match openers from the saved playbook and event format; it does not add another attendee data collection or expose private questionnaire answers.
- Product decision 2026-05-21: compatibility questionnaire answers are attendee-owned and host-private. By default they enrich clues/explanations only. Hosts can explicitly opt in to `compatibilityAffectsRanking`, which lets the backend boost generated guided-rotation candidates after interested-in, safety, eligibility, and opt-out checks.
- Product decision 2026-05-21: compatibility is a reusable event-success module, not an event type. Activity/playbook controls the physical format; questionnaire config controls whether a host uses a template pack or custom questions, and whether answers stay clues-only or become a soft pairing/grouping signal.
- Product decision 2026-05-21: host analytics should use already-loaded event-success data before adding a separate analytics store. V1 report quality is based on feedback response, assignment coverage, assignment opt-outs, and active wingman requests.
- Product decision 2026-05-21: manual QA needs a dual-role harness before deeper product review. The harness should render host and attendee production surfaces from one fixture so setup, live, reveal, opt-out, questionnaire, and report states can be inspected side by side; backend write-path proof still belongs on a real dev/staging event.
- Product decision 2026-05-21: host-help candidate pickers should not show the whole roster. Real candidate fetches should filter attended participants by the viewer's interested-in genders plus event signup cohort snapshots, and the attendee UI should defensively filter public profiles by the viewer's interested-in genders before rendering.
- Product decision 2026-05-21: booked attendees are in a quiet pre-arrival state, not the live companion. Before check-in, the attendee surface may show event identity, self check-in when open, compatibility/preference inputs that help planning, and opt-out planning controls. Live prompt decks, conversation cues, assignment cards, and reveal ceremony cards should wait until check-in.
- Product decision 2026-05-21: checked-in attendees should not see every enabled live module at once. The host's Live-mode run-of-show step is the source of truth. `EventSuccessRuntime.attendeeMoment(...)` maps participation status, `activeStepIndex`, reveal status, and event-ended state into one attendee moment, and the companion renders that moment instead of stacking module cards.
- Product decision 2026-05-21: unanswered compatibility questionnaires may remain the active attendee moment after check-in during before/arrival stages. Once the attendee saves answers, or once the host moves into opening/activity/reveal, the companion should move back to the host's current live step.
- Product decision 2026-05-21: event-success defaults are activity recommendations, not event types. `EventSuccessActivityProfile` maps each `ActivityKind` to a playbook, structure config, supported tools, default-on tools, optional tools, and unsupported tools. Club defaults can store a primary activity and per-activity event-success defaults; event creation receives the profile for the selected activity and can still override it per event.
- Product decision 2026-05-21: the host Live UI should not be a long ungrouped dashboard. Production Live mode keeps the active run-of-show compact, then groups current-step tools separately from supporting controls so assignment/reveal operations remain discoverable without making the attendee companion show everything at once.

## Rollout List

- [x] Create a persistent tracker for the event-success runtime work.
  - Done 2026-05-21: This file now tracks module gating, assignment ownership, verification commands, and resume notes.
- [x] Module runtime control plane.
  - Goal: A single domain object answers which host and attendee surfaces are active for a saved plan.
  - Done 2026-05-21: Added `EventSuccessRuntime` and routed companion/host surfaces through explicit module gates.
- [x] Honest V1 module behavior.
  - Goal: If a module is not selected, its attendee card, host report, and live run-of-show steps stay hidden.
  - Done 2026-05-21: Companion hides prompt, check-in, pod, private-crush, and feedback surfaces when the module gate is closed. Host report hides when `host_analytics` is disabled.
- [x] Run-of-show filtering.
  - Goal: Host live mode only advances through steps backed by selected modules and enabled follow-up toggles.
  - Done 2026-05-21: Host live mode now uses filtered runtime steps and shows a no-live-modules state instead of presenting unavailable steps.
- [x] Micro-pod assignment contract.
  - Goal: Store one server-owned `eventSuccessAssignments/{eventId_moduleId_uid}` document per attendee assignment.
  - Done 2026-05-21: Added `EventSuccessAssignment`, assignment repository watches, Firestore rules, and attendee pod display.
- [x] Backend-owned matching and reporting.
  - Goal: Host actions can generate deterministic V1 micro-pods, while client writes to assignment docs remain denied by rules.
  - Done 2026-05-21: Added `generateEventSuccessPods`, host-only callable authorization, deterministic V1 grouping, stale assignment cleanup, and unit coverage.
- [x] Production proof.
  - Goal: Focused Flutter tests, Functions build/lint, Firestore rules tests, analyzer, widget scanner, and audit-registry receipt.
  - Done 2026-05-21: See audit pass `event-success-module-runtime-2026-05-21`; focused Flutter tests, analyzer, Functions lint/test, Firestore-only rules tests, widget scan, and diff check were run.

## Current Pass Notes

- Do not let attendee screens infer feature availability directly from `EventSuccessPlan` booleans.
- Keep post-event swiping in the existing swipe/match pipeline; event-success should not duplicate that surface.
- Full v1 cleanup is allowed because this module has not shipped. Legacy private-crush identifiers and duplicate post-event swipe UI should be removed instead of compatibility-mapped.
- Host-assisted "wingman request" uses `eventSuccessWingmanRequests/{eventId_uid}` with explicit attendee consent and host visibility.
- Manual QA controls should be local to the surface they affect: fixture scenario/event format is global, host surface and ranking signal controls live with the host panel, and attendee opt-out controls live with the attendee panel.
- Manual QA host live controls are part of the state model, not dummy buttons. `Previous` and `Next` mutate the fixture `activeStepIndex`, reveal buttons mutate fixture reveal state, and both panes must update from that same plan so host-step QA matches the production interaction.
- Attendee lifecycle gates should stay explicit: `signedUp` means pre-arrival planning, `attended` means live companion, and ended + attended means post-event follow-up.
- Attendee live rendering should stay step-synced. `activeStepIndex` drives whether the companion shows a simple live context card, a prompt, conversation cues, an assignment surface, host-help, or the reveal ceremony. Reveal cards appear only once the host starts countdown or reveals; idle reveal steps remain context, not "waiting for host" cards.
- Micro-pods are operational assignments, not chemistry predictions. Use deterministic grouping from active participation edges first, then improve balancing after the host flow is proven.
- Client reads are allowed only for the assigned attendee and event hosts. Client writes to assignment docs should stay denied; Cloud Functions writes bypass rules through Admin SDK.

## Follow-On Slice

- [x] Attendee podmate visibility.
  - Done 2026-05-21: The companion fetches public profiles for the current attendee's assigned podmates and shows available names on the pod card without storing names in assignment docs.
- [x] Host pod summary.
  - Done 2026-05-21: The host live card groups generated assignments by pod label so hosts can confirm distribution before or during live mode.
- [x] Host check-in summary.
  - Done 2026-05-21: The event-success live tab now surfaces booked, checked-in, and waitlist counts when the check-in module is enabled, using the roster already loaded for live mode.
- [x] Block-aware pod generation.
  - Done 2026-05-21: `generateEventSuccessPods` now checks block edges among active participants and uses safety-aware grouping so blocked pairs are never assigned to the same micro-pod.
- [x] Attendee micro-pod opt-out.
  - Done 2026-05-21: Added attendee-owned `eventSuccessPreferences/{eventId_uid}` docs, companion opt-out/opt-in UI, host opt-out counts, Firestore rules, and Function-side exclusion/deletion of opted-out assignment docs.
  - Updated 2026-05-21: `generateEventSuccessPods` now mirrors guided rotations by preferring checked-in attendees once at least two eligible attendees have arrived, while still falling back to signed-up attendees for pre-arrival planning generation.
- [x] Guided rotation scheduler.
  - Done 2026-05-21: Added host-only `generateEventSuccessRotations`, 15-minute slot generation from event duration, mutual/one-way gender-interest pairing, participant-count caps, block-edge exclusion, guided-rotation opt-outs, stale assignment cleanup, host summary UI, attendee schedule UI, and focused backend/Dart coverage.
- [x] Host guided rotation overrides.
  - Done 2026-05-21: Added host-only `overrideEventSuccessRotations`, generated callable schema coverage, an edit sheet for generated rounds, server-side validation for duration bounds and eligible participants, non-overridable block/opt-out enforcement, empty-override rejection so generated schedules cannot be cleared accidentally, and focused backend/repository/widget coverage.
- [x] Fairness-aware guided rotation balancing.
  - Done 2026-05-21: Updated `generateEventSuccessRotations` to track attendee exposure and break counts while scheduling; compatible attendees who have been skipped are prioritized before already-served mutual-interest pairs continue. Added mixed-cohort backend coverage proving rotating breaks happen instead of starving one-way-compatible attendees.
- [x] Architecture layer reset and structure config.
  - Done 2026-05-21: Added `EventSuccessProductLayer`, grouped setup tools by product layer, persisted `EventSuccessStructureConfig` on plan/defaults, added a shared structure editor using Catch primitives, validated the config in Firestore rules, and made guided rotations use the saved cadence with a 15-minute legacy fallback.
- [x] Live reveal ceremony layer.
  - Done 2026-05-21: Added `live_reveal` as a product-layer module for structured formats, persisted reveal status/round/timestamps on plans, added host countdown/reveal/reset controls, added attendee pod/rotation reveal gating with countdown clues and post-reveal explanations, validated new plan fields in Firestore rules, and covered the state in repository/runtime/widget/rules tests.
- [x] Host-assisted wingman requests.
  - Done 2026-05-21: Added attendee-owned, host-readable `eventSuccessWingmanRequests/{eventId_uid}` docs with explicit host-visible consent, attended-attendee/target/block validation in Firestore rules, attendee companion request/withdraw UI, host Live-mode request summary, repository/controller providers, and focused repository/widget/rules coverage.
- [x] Conversation cue layer.
  - Done 2026-05-21: Added `EventSuccessConversationCueLibrary`, shared `EventSuccessConversationCueCard`, host Live-mode cue decks, attendee live prompts, attendee post-match opener suggestions, runtime gates for live prompts vs post-event openers, widget/domain coverage, and widget-catalog docs.
- [x] Compatibility questionnaire and optional ranking signal.
  - Done 2026-05-21: Added event-scoped questionnaire content, attendee-owned `eventSuccessCompatibilityResponses/{eventId_uid}` docs, companion save/edit UI, a host setup toggle for whether answers can affect ranking, host Live-mode signal status, Firestore rules that deny host reads of individual answers, and Functions scoring that only loads/uses responses when both the module and `compatibilityAffectsRanking` are enabled.
  - Updated 2026-05-21: Added plug-and-play `EventSuccessQuestionnaireConfig`, built-in questionnaire packs, custom question support, setup/defaults/manual-QA pack selection, and removed the manual-QA framing that treated "mixer reveal" as a separate event format.
  - Updated 2026-05-21: Broke the circular companion gate by loading the attendee response from module/participation eligibility, then passing `compatibilityResponseSaved` into `EventSuccessRuntime.attendeeMoment(...)`. Unanswered checked-in attendees now see the questionnaire during early arrival flow instead of losing it after check-in.
- [x] Host analytics / coach signal quality.
  - Done 2026-05-21: The host report now summarizes live signal quality from feedback response, assignment coverage, assignment opt-outs, and wingman requests. Coach recommendations and strengths use those same aggregates so the report explains what worked and what to adjust without exposing private attendee targets.
- [x] Manual QA harness.
  - Done 2026-05-21: Added `/dev/event-success-manual-qa`, a Settings development entry, and a side-by-side QA screen that renders the production host panel and attendee companion from one fixture across social run, racket pair, quiz team, and mixer reveal scenarios.
  - Updated 2026-05-21: Grouped host controls with the host panel and attendee controls with the attendee panel so the QA harness matches the real product surfaces being reviewed.
- [x] Host-help candidate eligibility.
  - Done 2026-05-21: `fetchWingmanRequestCandidates` now takes the current user profile and filters attended participants by interested-in gender and signup cohort before fetching public profiles. The companion screen also defensively filters candidate profiles before rendering host-help lists.
- [x] Pre-check-in companion gating.
  - Done 2026-05-21: Booked attendees now see a pre-arrival planning card instead of live prompt decks or reveal cards. Assignment/reveal/conversation cue surfaces are gated to checked-in attendees, while compatibility and opt-out preferences remain available before arrival when configured.
- [x] Step-synced attendee companion.
  - Done 2026-05-21: Added `EventSuccessAttendeeMoment` and `EventSuccessRuntime.attendeeMoment(...)`, then refactored the companion to render the current host run-of-show moment rather than every selected module. Checked-in arrival steps now show contextual copy only; prompts, cues, assignment cards, reveal, wingman requests, and post-event follow-up each appear only in their mapped step/status.
  - Updated 2026-05-21: The manual QA harness now treats host `Previous`/`Next` as real fixture state transitions. Advancing the host live step updates the shared plan, host progress labels, and attendee companion instead of only showing a snackbar.
- [x] Activity-aware defaults and production UI hygiene.
  - Done 2026-05-21: Added `EventSuccessActivityProfile`, mapped activity kinds to recommended playbooks/structure configs/tool support, moved club defaults to primary/supported/per-activity event-success defaults, wired create club/create event/host setup/manual QA through the same resolver, and updated contracts/generated schemas for the new default shape.
  - Done 2026-05-21: Simplified production host setup by grouping tools by recommendation fit, hid unsupported toggles, fixed legacy structure normalization when switching activity profiles, and made host Live mode compact with current-step tools separated from supporting controls.

## Resume Notes

- Start with `lib/event_success/domain/event_success_runtime.dart` for runtime gates.
- Activity default recommendations live in `lib/event_success/domain/event_success_activity_profile.dart`; do not add activity-specific event-success toggles directly in screens.
- Assignment model lives in `lib/event_success/domain/event_success_assignment.dart`.
- Repository surfaces live in `lib/event_success/data/event_success_repository.dart`.
- Backend callables are exported as `generateEventSuccessPods`, `generateEventSuccessRotations`, and `overrideEventSuccessRotations`; keep server-owned assignment writes, stale cleanup, opt-out exclusion, and blocked-pair filtering in those Functions.
- Live reveal state is stored on `eventSuccessPlans/{eventId}`. It is host
  writable and active-participant readable with the plan; assignment docs are
  still server-owned and attendee-scoped.
- Wingman requests live in `eventSuccessWingmanRequests/{eventId_uid}`. The
  requester can create/update their own request after attendance; event hosts
  can read active requests, but the target is not notified by this surface.
- Conversation cues are derived from plan modules and event format in
  `EventSuccessConversationCueLibrary`; no new persistence layer is needed for
  V1.
- Compatibility answers live in
  `eventSuccessCompatibilityResponses/{eventId_uid}`. Attendees can save/edit
  their own answers while booked or checked in; hosts cannot read individual
  answers through Firestore rules. Functions may read answers with Admin SDK
  only when the saved plan has the compatibility module selected and
  `compatibilityAffectsRanking == true`.
- Host analytics currently comes from the data the host surface already loads:
  roster, assignments, preferences, wingman requests, and feedback. Do not add a
  separate analytics collection until a metric needs durable history or
  cross-event aggregation.
- Manual QA has two modes: `/dev/event-success-manual-qa` for visual/state QA
  with fixture data, and real dev/staging events for write-path, callable,
  rules, and identity QA. The detailed checklist lives in
  `docs/event_success_manual_qa.md`.
- Host-help candidate filtering depends on
  `EventParticipation.genderAtSignup` and `cohortAtSignup`. If future exact
  queer/open mutuality needs more precision than cohort snapshots provide, add
  a backend-owned candidate endpoint or safe event-specific interest snapshot
  rather than widening `publicProfiles` with private dating preferences.
- Setup-state companion QA should show `Before you arrive` and should not show
  `Social prompt`, `Conversation cues`, `Rotation reveal`, or partner names.
  Use host `Live`, `Previous`/`Next`, countdown, and reveal controls for the live
  ceremony.
- Checked-in manual QA should validate the host-step mapping: arrival/check-in
  moments should show the current step context, countdown/revealed should show
  the ceremony, and post-event should show follow-up. Do not reintroduce a
  module-stack dashboard in the attendee companion.
- Firestore rules should sit beside `/eventSuccessPlans` and `/eventSuccessFeedback`.
- Latest audit receipt: `event-success-wingman-only-2026-05-21`.
