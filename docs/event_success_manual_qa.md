# Event Success Manual QA

Updated: 2026-05-21

This guide covers product QA for the event-success host and attendee flow.

## Tooling

- Dev/staging visual harness: `/dev/event-success-manual-qa`
- Settings entry: Settings -> Development -> Event success manual QA
- Real event preview: `/dev/event-success-preview/:clubId/:eventId`
- Static lab: `/dev/event-success-lab`

## Use The Manual QA Harness

Use the manual QA harness first when checking UI fit, copy, reveal states, and
host/attendee consistency. It renders the production host panel and attendee
companion side by side from one fixture.

Check the global fixture scenario controls:

- `Social run`: whole-group run flow, micro-pods, attendance, prompts, feedback.
- `Racket pairs`: pair units, 15-minute rotations, live reveal, rotation cards.
- `Quiz teams`: team units, team assignment labels, reveal and conversation
  prompts.

Use the host-panel controls for host-only state:

- `Host surface`: switch between setup, live, and report without leaving the
  side-by-side QA surface.
- `Questionnaire`: opt the compatibility layer into any fixture scenario rather
  than treating it as a standalone event type.
- `Pairing signal`: confirm the host-facing ranking signal changes setup copy,
  live signal state, and reveal explanations when the questionnaire is enabled.
- `Questionnaire pack`: switch between template packs or a custom host-authored
  questionnaire and confirm the attendee companion uses that pack.
- In `Live`, use `Previous` and `Next` inside the host panel to advance the
  fixture run-of-show. The host and attendee panes should both move to the same
  step label.
- Use the host reveal card to drop the countdown, reveal now, and reset. The
  attendee pane should move through countdown and revealed states from those
  host controls.

The attendee lifecycle is derived from the host surface:

- `Setup`: before check-in; attendee should see setup-sensitive pre-event
  surfaces only. It should show `Before you arrive`, optional planning
  preferences, and no live prompt deck, conversation cue deck, reveal card, or
  partner names.
- `Live`: attendee should see only the context for the host's active
  run-of-show step, not every enabled module at once. If the questionnaire is
  enabled and the fixture is in a before/arrival step, an unanswered checked-in
  attendee should see the questionnaire before opening, live assignment, or
  reveal moments.
- Host reveal countdown: host reveal status should match attendee countdown/clue state.
- Host reveal now: attendee should see the current assignment details.
- `Report`: attendee should see feedback and post-match openers; host report
  should show signal quality and coach output.

Use attendee opt-out toggles to confirm stale assignment cards disappear and
host counts update.

For `Ask the host to help`, confirm the picker only shows eligible host-help
candidates for the current attendee. Example: a straight woman should see
checked-in men whose event signup cohort indicates interest in women, not the
entire checked-in roster.

The companion is intentionally step-synced. If the host is on arrival/check-in,
the attendee should not also see conversation cues, reveal cards, and host-help
requests. Those surfaces should appear only when the host Live-mode step or
reveal status makes them the current moment.

Activity scenarios should follow the production recommendation profile, not a
test-only event-type shortcut. Racket scenarios default to guided rotations and
live reveal while hiding micro-pods; quiz scenarios treat teams as the assignment
unit; host-led classes keep assignment tools advanced or unavailable; and the
questionnaire stays a reusable toggle that can feed clues or optional ranking.

## Use A Real Dev Event

Use a real dev/staging event when checking write paths, permissions, callable
generation, and persistence:

1. Create or open an event as the host.
2. Save event-success setup from Host Manage.
3. Book/check in at least two attendee accounts.
4. Generate micro-pods or guided rotations.
5. Edit generated rotations.
6. Start countdown, reveal, and reset from the host Live section.
7. Open the companion as an attendee and verify assignment/reveal state.
8. Submit questionnaire, opt-out, wingman request, and feedback.
9. Return to the host report and confirm aggregate signal quality.

Do not use the manual QA harness for backend write-path proof. It is fixture
data for visual and state QA; real write-path QA belongs on a dev/staging event
with Firestore rules, Functions, and real user identities.
