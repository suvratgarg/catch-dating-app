# Lib Code Map

Read `PROJECT_CONTEXT.md` first for the whole-app architecture and product
flow. Use `docs/app_architecture.md` as the canonical spec for feature, layer,
screen, controller, repository, async-state, error-surface, and widget
ownership. Use this file to route feature-specific code work without opening
broad audit history.

## Structure

Most app features follow the same shape:

- `domain`: Freezed models, enums, value objects, and pure domain helpers.
- `data`: repositories, Firebase adapters, and Riverpod providers.
- `presentation`: screens, controllers, widgets, and feature UI state.

Current ownership clarifications:

- Cross-cutting analytics code lives in `core/analytics`, not a top-level
  feature folder.
- Explore-owned search lives in `explore/data`.
- The calendar agenda route lives in `events/presentation/calendar`.
- Chat and host-inbox list UI lives in `chats/presentation/inbox`; `matches`
  owns match lifecycle models/repositories and match-specific presentation.
- Event display helpers and platform seams that are not widgets live in
  `events/domain` or `events/data`; shared event/activity visual primitives
  used by core widgets live in `core/widgets`.

Generated `*.g.dart`, `*.freezed.dart`, and Riverpod outputs live next to their
source files and should not be hand-edited.

## Feature READMEs

These feature-level docs carry local source-of-truth notes that used to live in
generic audit trackers:

| Area | Read before |
|---|---|
| `lib/event_policies/README.md` | Changing event policy bundles, admission, pricing, waitlist, cancellation, settlement, or the dev event-policy lab. |
| `lib/safety/README.md` | Changing blocking, reporting, account deletion, safety rules, or deletion/anonymization behavior. |
| `lib/user_profile/README.md` | Changing private profile identity fields, profile edit UI, public projection inputs, or profile schema migration. |

## Cross-Cutting Docs

- `docs/app_architecture.md`: **canonical Flutter app architecture spec** —
  feature folder shape, dependency direction, screen/controller/repository
  ownership, async state boundaries, error surfaces, UI layout/scroll/sizing
  rules, widget ownership, controller patterns, and enforcement policy.
- `docs/design_language.md`: **visual identity source of truth** — palette, typography,
  activity-color system, photo grading, metaphors, and the UI elevation roadmap.
- `docs/data_contracts.md`: Firestore documents, schema generation,
  relationship documents, migration policy, and rules-test workflow.
- `docs/backend_operation_catalog.md`: which writes are client-owned,
  callable-owned, trigger-owned, or server-only.
- `docs/widget_catalog.md`: widget inventory and reusable component ownership.
- `docs/event_success.md`: live event-success architecture, contracts, QA, and
  product guardrails.

## Edit Policy

Keep business logic out of widgets when a feature controller, repository, or
domain helper already owns it. When changing a feature's persisted shape, update
the JSON schema/contracts first, regenerate outputs, and run the contract gate
documented in `docs/data_contracts.md`.
