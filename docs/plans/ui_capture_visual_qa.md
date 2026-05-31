# UI Capture Visual QA

Snapshot date: 2026-05-31

This file tracks the visual quality layer after route coverage is complete. The
coverage gate answers "does every planned route render"; this QA list answers
"is the rendered state useful for review, demos, or marketing."

## Status Labels

- `ready`: useful as a review artifact now.
- `marketing-candidate`: strong enough to feed the framed marketing pipeline.
- `fixture-needs-data`: route renders, but the fixture is too empty or generic.
- `screen-needs-fix`: capture exposed a UI/state issue in the real screen.
- `review-only`: keep for coverage and regression review, not marketing.

## Current Queue

| Capture | Status | Consumer | Notes | Next action |
|---|---|---|---|---|
| `profile_self` | ready | Review | Strong profile fixture with real portrait asset. | Keep as baseline profile review capture. |
| `start_welcome` | ready | Review | Clear first-run welcome state. | Review-only unless onboarding marketing needs it. |
| `auth_phone_entry` | review-only | Review | Phone-entry state renders correctly but is intentionally sparse. | Add OTP-state variant only if auth flow review needs it. |
| `onboarding_welcome` | ready | Review | Brand-forward onboarding screen. | Review-only for now. |
| `event_detail_member` | ready | Review | Rich event detail, attendees, policy, and reviews. | Keep as canonical event detail surface. |
| `dashboard_home` | ready | Review | Dense signed-in dashboard with member and host content. | Candidate for future app-store style review, not marketing now. |
| `club_detail_member` | ready | Review | Good member-state club detail and schedule. | Add real club image later if this becomes marketing. |
| `calendar_planned_events` | ready | Review | Booked plus multiple saved synthetic events render well. | Keep as coverage/review capture. |
| `saved_events_list` | ready | Review | Shared synthetic event fixtures now render a dense three-event saved list. | Keep as coverage/review capture. |
| `filters_preferences` | review-only | Review | Correct but very sparse. | Add only if filters get a broader preference surface. |
| `event_location_map` | ready | Review | Network tiles stay disabled, with a deterministic local map placeholder behind the pin. | Keep offline rendering as the default capture path. |
| `member_event_discovery` | marketing-candidate | Review + marketing | Strong event discovery feed and framed marketing source. | Keep active; improve bottom browse content later. |
| `create_club_basics` | fixture-needs-data | Review | First step is valid but too empty for demo review. | Seed draft or initial form data once form fixture hooks exist. |
| `edit_club_basics` | fixture-needs-data | Review | Existing club name/city appear, but visual state is still image-empty. | Add deterministic club image/photo state. |
| `host_event_setup` | marketing-candidate | Review + marketing | Active marketing source now opens on a seeded event policy step with capacity, pricing, admission, and age-range data. | Keep as marketing source; revisit if the setup narrative needs an earlier step. |
| `edit_hosted_event` | ready | Review | Shows locked schedule plus editable location. | Keep as review capture. |
| `host_live_console` | marketing-candidate | Review + marketing | Persisted live plan now shows run-of-show, roster filters, host controls, readable dark-mode stage contrast, and canonical synthetic roster names. | Keep active in marketing exports. |
| `host_post_event_report` | marketing-candidate | Review + marketing | Added missing host report variant with roster and scorecard fixture. | Light mode is ready; dark mode needs a later host-report contrast pass. |
| `post_run_catch_window` | marketing-candidate | Review + marketing | Strong post-event catch surface. | Keep active. |
| `swipe_hub_active` | ready | Review | Good open-catch-window hub. | Review-only unless product story needs it. |
| `notifications_activity` | ready | Review | Useful event and update notifications. | Add unread/empty variants later if needed. |
| `event_recap_attendees` | fixture-needs-data | Review | Good structure and canonical synthetic attendees, but attendee cards still lack photo-backed assets. | Use synthetic persona photos when image fixture pipeline supports them. |
| `event_success_companion` | ready | Review | Stage foreground now resolves to readable ink on the animated companion background. | Keep in review catalog; dark preview card contrast can be tuned later. |
| `match_chat_context` | marketing-candidate | Review + marketing | Strong context chat story. | Keep active. |
| `matches_list_context` | ready | Review | Useful match list with unread state. | Add more avatar/photo fidelity later. |
| `public_profile_member` | ready | Review | Good public profile copy; synthetic avatar placeholder is acceptable for review. | Add photo-backed synthetic profile later. |
| `reviews_history_list` | ready | Review | Shared synthetic review fixtures now render multiple review history cards. | Keep as review capture. |
| `settings_account` | review-only | Review | Good settings coverage; dev section makes it unsuitable for marketing. | Consider production-mode settings fixture later. |
| `payment_history_empty` | review-only | Review | Valid empty state. | Add populated receipt variant only if payment QA needs it. |

## Next Fidelity Passes

1. Re-render and inspect the full catalog after the synthetic fixture
   centralization pass.
2. Add image-backed synthetic personas for recap, matches, and public-profile
   surfaces.
3. Tune `host_post_event_report` dark-mode contrast if that dark variant becomes
   a marketing source.
