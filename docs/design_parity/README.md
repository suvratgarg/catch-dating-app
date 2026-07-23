---
doc_id: design_parity_tracker
version: 0.1.34
updated: 2026-07-23
owner: product_design_parity
status: active
---

# Design Parity Tracker

This folder owns the feature-by-feature contract for bringing Catch screens and
widgets closer to the design specification. It connects product states, Flutter
screens, reusable components, UI captures, future previews, and drift-prevention
checks in one durable matrix.

## Source Files

| File | Purpose |
|---|---|
| `claude_widgetbook_inventory.md` | Persistent inventory comparison between the Claude Design export, local Widgetbook, local component contracts, and foundation token/style sources. |
| `comprehensive_todo.md` | Canonical execution checklist for remaining design-parity work across sources of truth, state contracts, Widgetbook, captures, pixel comparison, composition, tokens, features, drift prevention, and pass cadence. |
| `composition_migration_spec.md` | Layered implementation spec for migrating screens into controller-owned state composition, registered sections, registered components, and platform-neutral design tokens/contracts. |
| `../../design/features/event_detail.feature.json` | Current Event Detail surface, state, action, outcome, and evidence orchestration; the completed first composition tracker is retirement-ready. |
| `design/screens/screen_coverage.json` | Exhaustive route-to-screen coverage ledger. Every generated route is contracted, aliased, planned, or excluded from baseline design parity. |
| `design/screens/catch.screens.json` | Machine-readable screen composition registry connecting routes, controller owners, states, captures, sections, and implementation paths. |
| `design/features/*.feature.json` | Structured multi-surface feature orchestration contracts. Each surface binds a Flutter screen, marketing route, or admin route plus native components, action owners, and evidence. |
| `design/features/generated/*.feature_contract.json` | Generated cross-surface state/action/evidence projections. These artifacts are deterministic and must not be edited by hand. |
| `design/features/feature_coverage.json` | Exhaustive cross-surface migration ledger. Every registered Flutter screen, marketing route, and admin route component is contracted, grouped, planned with stable debt, or explicitly excluded. |
| `tool/design/check_design_parity.mjs` | Standard local design parity gate. Runs component contracts, route inventory, capture coverage, screen coverage, screen contracts, Widgetbook refs, and advisory scanners. |
| `tool/design/build_feature_contracts.mjs` | Compiles multi-surface feature sources, enforces exact authority-state coverage and action cardinality, resolves runtime-native evidence, and fails stale generated output. |
| `tool/design/check_feature_coverage.mjs` | Fails missing, duplicate, unknown, falsely contracted, or orphaned feature coverage across the three product runtimes. |
| `tool/design/check_screen_coverage.mjs` | Validates screen coverage against route inventory, capture coverage, and the screen composition registry. |
| `tool/design/check_screen_contracts.mjs` | Validates screen contracts against route inventory, capture catalog entries, component dependencies, Flutter source paths, and Dart symbols. |
| `tool/design/check_widgetbook_contract_refs.mjs` | Validates component contracts and contract preview ids against generated Widgetbook directories. |
| `tool/design/check_screen_contract_hygiene.mjs` | Advisory scanner for raw Material controls and hand-rolled visual values in contracted screen implementation files. Masks comments/string literals, ignores `Colors.transparent`, and prints sample line refs so findings are reviewable before promotion to lints. |
| `tool/design/screen_top_bar_contracts.json` | Exhaustive role classification for every Flutter `Scaffold.appBar`, every consumer/Host tab-root header surface, canonical zero-inset geometry, and reviewed raw media-hero exceptions. New app bars and shell branches are unregistered by default and fail the gate. |
| `tool/design/check_screen_top_bar_contracts.mjs` | Blocking screen-chrome gate. Rejects unregistered/raw/wrong app-bar owners, incomplete tab-root coverage, root headers that bypass `CatchScreenHeaderTitle`/`CatchScreenTopBar`, local padding/height/text-scaling overrides, and a nonzero canonical post-safe-area inset. |
| `tool/design/check_screen_gutters.mjs` | Advisory inventory for `EdgeInsets` constructors across `lib/**/presentation/**/*.dart` and contracted screen implementation files. Classifies likely screen-gutter candidates separately from lower-confidence local spacing so manual UI reviews have broad evidence instead of a narrow lint. |
| `design/reference_screens/manifest.json` | Exported design-reference PNG manifest used for advisory pixel comparison. |
| `tool/design/check_reference_screens.mjs` | Validates reference PNG metadata and can compare exported references against UI capture output. |
| `state_matrix.json` | Machine-readable feature/state matrix for design parity passes. |
| `state_matrix.schema.json` | JSON Schema for the matrix shape. |
| `tool/design/check_design_parity_matrix.mjs` | Validates routes, captures, component ids, screen contracts, source paths, tests, and state entries. |
| `widgetbook/` | Local Widgetbook workspace for reusable component and hard-to-reach state previews. |

## Pass Workflow

1. Choose one feature from `state_matrix.json`.
2. Read the feature's design refs, implementation paths, component ids, capture
   ids, and open gaps.
3. Expand the state list before editing UI. Include loading, populated, empty,
   error, offline, permission, mutation, light/dark, text-scale, and reduced
   motion states when they apply.
4. Add or update fixtures, captures, previews, tests, and component contracts as
   part of the same feature pass.
5. Run the local design parity gate:

   ```bash
   npm run design:parity:check
   ```

6. Run focused analyzer/tests/scanners for the touched feature.
7. Stamp the pass in `docs/audit_registry/passes.jsonl`.

## New Route Workflow

When `lib/routing/go_router.dart` changes, update the route-derived design
ledgers in the same PR:

1. Regenerate the route inventory:

   ```bash
   node tool/ui_capture/check_route_inventory.mjs --update
   ```

2. Add or update the route in `design/screens/screen_coverage.json` with one of
   the explicit decisions: `contracted`, `alias`, `planned`, or `excluded`.
3. Add or update the route in `tool/ui_capture/capture_coverage.json` with one
   of the explicit capture decisions: `captured`, `alias`, `planned`, or
   `excluded`.
4. For a new product screen, add the screen contract in
   `design/screens/catch.screens.json` and a matching screen/state entry in
   `docs/design_parity/state_matrix.json`.
5. Run the aggregate gate:

   ```bash
   npm run design:parity:check
   ```

Flutter CI also runs this gate, so new product routes cannot pass CI without
screen and capture coverage decisions.

The router remains the source for path inventory only. Rich design metadata
belongs in the portable `design/screens` and `docs/design_parity` ledgers so the
same contracts can serve Flutter, Widgetbook, website/social templates, and
future design-tool exports without making Dart routing the design source of
truth.

## State Statuses

- `planned`: Known requirement; no implementation proof yet.
- `implemented`: Code path exists, but capture/preview/test proof is incomplete.
- `captured`: UI capture exists for the state.
- `tested`: Automated widget/unit/integration test covers the state.
- `ready`: State has implementation, useful visual proof, and relevant tests.
- `blocked`: State is blocked by missing fixture/data/tooling/design source.

## Visual Comparison Policy

Pixel comparison should be introduced as an advisory gate first. Store exported
design references under `design/reference_screens/` and compare them against
`tool/ui_capture/run_captures.mjs` output. Mask dynamic regions such as status
bars, maps, timestamps, remote photos, and generated counters before enforcing a
threshold.

Dashboard Home is the first wired baseline. Refresh the comparable Flutter
captures with:

```bash
node tool/ui_capture/run_captures.mjs --ids dashboard_home,dashboard_home_empty_start --device design-phone --output-dir /tmp/catch-dashboard-reference-captures
```

Then run the advisory comparison:

```bash
node tool/design/check_reference_screens.mjs --compare --capture-dir /tmp/catch-dashboard-reference-captures
```

Host references must use a repo-pinned `design/source_packs/` source with a
hash-complete, locally closed dependency manifest and must compare the real
application navigation chrome. App Build Matrix regenerates the four primary
full-shell Host captures and runs a focused `--strict` comparison. Strict mode
fails unknown or missing captures, dimension drift, and threshold regressions.
A real but unfinished feature may declare a stable `parityDebtId` plus a looser
`regressionThresholds` ceiling; that ceiling prevents further drift and does
not change the canonical parity threshold or close the debt.

## Preview Policy

Use previews for hard-to-reach component and screen states. Use route captures
for full-screen composition, navigation chrome, fixture realism, and review
artifacts. A state can be `ready` with either a useful route capture or a useful
preview, but high-traffic P1 routes should eventually have both.

The local Widgetbook workspace lives in `widgetbook/`. Primitive previews should
map to `design/components/catch.components.json` contract states, and screen
previews should use the same fixture fakes as UI captures where possible. Run
`cd widgetbook && dart run build_runner build` after adding annotated use cases.

## Feature Contract Compiler

Feature contracts are orchestration indexes, not replacement sources of truth.
They declare one semantic feature identity with one or more runtime-specific
surface projections. Each surface declares valid state dimensions, cardinality
for explicit action domains, and one mapping for every state in its owning
screen or route contract. It references native component ids, action-owner
symbols, data-contract paths, previews, captures, and tests; the compiler
resolves those authorities into one checked generated artifact.

The compiler is paired with `design/features/feature_coverage.json`. That ledger
defines the complete migration boundary from existing authoritative registries,
so adding a Flutter screen, marketing route, or admin route component without a
feature decision fails the design-parity gate. A `planned` target may intentionally
reuse an existing feature identity across runtimes. `feature.explore` is the
first checked example: it contains both `screen.explore.discovery` and the
marketing `organizer_search` route, while their components, action owners,
states, and evidence remain runtime-specific.

All 32 registered Flutter screens are now covered. Event Detail with its exact-location projection, Explore, Dashboard Home,
Event Success, Host Home, Host Organizers, Host Organizer Create, Host Event
Create, Host Event Manage with its owner-edit projection, Host Inbox, Catches
Hub, Catches Event, Matches List, Chat Thread, Self Profile, Public Profile,
Organizer Detail, Phone Authentication, Member Onboarding with its Start
Welcome projection, Event Planning, Matching Preferences, Event Recap,
Notifications, Reviews, Payments, and Account Settings are the current Flutter
reference contracts. Marketing Home, Host Acquisition, and Organizer Claim
complete the stateful marketing routes, while Explore and Organizer Detail
retain their existing marketing projections. Organizer Detail is the first
three-surface reference:
consumer Flutter, host Flutter, and the canonical marketing listing share one
semantic feature identity while retaining separate actions and state
inventories.

All 14 registered Admin route authorities are also compiled across 12 feature
identities: Access Review, Role Management, Data Quality, Event Publishing,
Finance Operations, Growth KPI, Intake, Marketing Operations, Organizer
Publishing, Overview, Safety Triage, and User Analytics. Intake and Overview
each retain two projections because their secondary route components expose
independent state and actions; they are not flattened into grouped coverage.
Admin route previews are resolved from `design/admin/components.json` just as
marketing route previews are resolved from the website registry.

Actions name one of the surface's declared Dart or TypeScript owners, so a
larger feature may compose multiple action domains without pretending one enum
or controller owns everything. Action outcomes are typed as local surface
states, route destinations, or side effects. A read-only surface may declare no
actions or action owners; the format never requires fabricated behavior.

A coordinated workspace may bind several route projections to one authority
when users experience them as one feature. Host Organizers is the reference:
Edit, Insights, Preview, Event Defaults, Live Guide, Payments, Team, and host
identity retain separate action owners and states inside one feature contract.
Do not split a feature merely because a spoke has its own URL, and do not merge
routes whose state or actions do not share a coherent user goal.

A filtered route can also be a projection of a broader workspace even when it
uses a different screen class. Saved Events is a saved-only view of the same
planned-event agenda, organizer-name enrichment, and Event Detail handoff as
Calendar, so both belong to Event Planning. A shared widget is useful evidence,
but the deciding test is shared user goal plus overlapping data and action
semantics—not class identity alone.

Do not infer actions from repository capabilities. Saved Events has a
`SavedEventRepository` in its authority metadata, but the list route exposes no
save or unsave control; its contract contains only back, recovery, and event
navigation actions. Mutations remain with Event Detail until production UI
actually exposes them.

Cardinalize meaningful user decisions and side effects, not raw field-entry
events. Host Event Create and Host Organizer Create are the references: wizard
movement, media and location selection, typed organizer/activity/policy/guide
choices, draft lifecycle, submission, and success navigation are explicit
actions; text entry remains form data governed by field validators and data
schemas. This keeps action coverage complete without treating every keystroke
as a separate contract operation.

A child route should keep its own internal actions when it is already a
registered authority. Event Detail owns opening its exact-location projection;
Event Location Map owns route recovery, back navigation, and external
directions. A fullscreen modal that is not that registered route must not borrow
its authority merely because both involve maps. Host Event Edit actually opens
`LocationPickerScreen`, so its contract owns that modal result locally and no
longer claims an Event Location Map transition. This preserves typed route edges
without making one authority describe a different production screen.

Dependency fallback is not automatically a valid data state. Event Recap,
Reviews History, and Payment History currently render the same fallback when a
secondary record is genuinely absent, still loading, or failed to load.
Notifications similarly renders an identity-provider error as if the member
were signed out. A feature contract should expose each collapse as debt instead
of calling every unresolved dependency a successful empty or fallback state.
The same rule applies to external effects: requesting directions or opening an
external settings link is implemented, but ignored false/error results and
unrestricted repeated taps remain part of the action contract until production
defines pending and failure behavior.

Action names describe observed outcomes rather than promising more than the
implementation does. Payment History therefore contracts its current support
CTA as `show_support_guidance`: the button closes the sheet and displays a
snackbar, but it does not open a support channel. Either production behavior or
the visible label must change before the contract can truthfully call that
action a support handoff.

Action availability must describe production behavior, including unsafe
behavior. Host Organizer Create and Host Event Edit currently leave some
navigation or form decisions active after a mutation snapshot is submitted.
Their pending scenarios and screen gaps record that concurrency honestly; do
not model the form as frozen until production state and focused tests prove it.
Phone Authentication is now the frozen-snapshot reference: phone and country
controls disable while the request is pending, duplicate controller dispatches
share one future, and flow reset invalidates stale Firebase callbacks. Treat
every control that can mutate, dismiss, or invalidate an in-flight snapshot as
part of the pending action matrix, even when the primary button itself is
disabled. Versioned editing and independently keyed concurrency remain explicit
tested variants under `ARCH-PENDING-SNAPSHOT-001`, not implicit exceptions.
Member Onboarding and Matching Preferences are now the first promoted
adopters. Onboarding freezes step-back plus identity, prompt, and running
preference controls; Matching Preferences freezes route exit, reset, age,
gender, and apply. Both add controller-level deduplication and focused route,
state, and widget proof.
Account Settings extends the rule across independent mutation domains:
preference, unblock, delete, and sign-out guards currently disable only their
own controls, so destructive and route actions can overlap. Contract the whole
surface's concurrent action availability, not just the button owned by one
controller.

When two registered surfaces use the same production implementation and differ
only by viewer policy, prefer separate projections in one feature contract.
Chat Thread is the reference: consumer and host routes both render
`ChatScreen`, while each projection keeps its own states, action availability,
evidence, and profile/share/safety policy. Shared code alone is insufficient if
the user goals differ; Host Inbox remains separate because event scoping,
audience segmentation, and broadcasts are host operations rather than thread
behavior.

The same rule applies when one implementation serves two registered entry
points for the same user goal. `WelcomePage` is both the onboarding welcome
state and the logged-out Start route, so Member Onboarding owns two projections
instead of creating a duplicate Start feature. Reuse the same semantic action
ids across such projections when the user decision and production callback are
the same; keep separate state inventories and evidence for each authority.

Implemented UI is not necessarily reachable product behavior. Member
Onboarding records the Instagram step with an explicit `orphaned` reachability
dimension and a stable screen gap because no production entry mode or forward
transition currently reaches it. Do not silently present previewed or captured
states as live-flow coverage; either prove a route transition or classify the
state as unreachable debt.

Flutter preview evidence may use the stable annotated Widgetbook builder id or
the `Type/Use case name` identity. Prefer the builder id when the same builder
is intentionally annotated for several component types, because the generated
Widgetbook registry uses that builder as their shared evidence seam.

Action owners may be Dart classes, enums, or top-level functions. The compiler
validates each declared symbol directly, so route helpers such as
`openNotificationRoute` remain attributed to their real production owner
instead of being reassigned to a nearby class merely to satisfy the contract.

An action whose owner exists but whose runtime callback is not connected may be
declared with `implementationStatus: known_gap`, stable debt, and a concrete
source note. The action must still be classified, but the compiler rejects any
scenario that enables it. Generated actions without an explicit status project
as `implemented`. This prevents a contract from turning an existing controller
method into a false claim that the user-facing action works.

For state-rich surfaces, use the compact state matrix: `stateIds` must list the
authority's exact state inventory, `scenarioDefaults` declares the repeated
dimension/action case once, and `scenarioOverrides` records only meaningful
differences. The compiler expands this into the same generated scenario
projection and rejects missing, unknown, duplicate, or out-of-inventory state
overrides. This keeps source contracts reviewable without allowing a newly
registered state to pass silently.

React route review states do not always use the same vocabulary as Storybook
component states. `bindings.previewEvidence` may map an authority state to a
selected registry preview such as `component_id/StoryExport`; the compiler
checks that the component belongs to the route, the story source is declared,
and the preview is part of the selected marketing or Admin component registry.
Admin route wrappers whose registry preview is explicitly `not-required` may
bind controller tests instead of inventing a visual state. This makes the
relationship explicit without renaming either authority. Static-output tests
under `website/scripts/*.test.mjs` may provide test evidence for indexing and
canonical metadata states that cannot be meaningfully shown in Storybook.

Grouped route coverage is appropriate only when the secondary authority adds
no independent workflow state worth compiling. Organizer Claim binds both the
canonical `/claim/` workspace and its dynamic lookup route because the latter
has its own exact known, missing, pending, and unavailable state inventory.
The legacy organizer-listing family stays grouped because its only differences
are canonical/noindex static-output policy already proved by route tests.
Admin Intake and Overview do not qualify for grouping: Organizer Intake has
three independently reviewable states, and the live Overview wrapper has its
own query lifecycle and actions, so both compile as explicit projections.

A feature orchestration contract cannot replace a missing network schema.
Marketing Home and Host Acquisition can prove controller ownership, action
availability, UI evidence, and mutation outcomes, but `/api/join-waitlist`
still has separately declared website and Functions types. Keep their
`dataContracts` empty and name `WEB-LEAD-API-CONTRACT-001` until one checked
request/response schema spans that boundary; do not cite nearby Firestore or
analytics schemas as false proof.

An Admin callable binding must also state validation strength rather than
treating every generated validator as equivalent. `bindings.runtimeContracts`
names the callable and declares request and response validation separately as
`strict_schema` or `structural_object`. The compiler compares those values with
`admin/src/generated/validators/adminCallableValidators.ts` and rejects both
overclaiming and stale underclaiming. Structural validation is real boundary
protection, but it is not a field-level request/response schema;
`ADMIN-CALLABLE-STRICTNESS-001` owns that migration. The separate
`ADMIN-MUTATION-SNAPSHOT-001` debt covers Admin controls and peer mutations
that remain live after a request or query snapshot has been captured.

## Structural Lessons From Full Coverage

The complete Flutter, marketing, and Admin migration establishes the feature
contract as a coordination layer rather than a new monolithic source of truth.
The feature contract owns semantic feature identity and the checked links among
runtime projections. Screen and route registries continue to own state
inventories; component registries own reusable UI and previews; data schemas
own payload shape; production controllers own behavior; and tests and captures
own evidence. Duplicating any of those details in the feature contract would
create a second authority instead of preventing drift.

A durable feature boundary follows a coherent user goal plus overlapping data
and action semantics, not a route, widget, or class boundary. One feature may
therefore contain several route projections, while two routes that share an
implementation may remain separate when their viewer policy or operational
goal differs. This is why Organizer Detail spans three runtimes, Host
Organizers contains several workspace spokes, and Host Inbox remains distinct
from the shared Chat Thread implementation.

The preferred implementation seam is now explicit: registered authority to
controller-owned state, provider-free view composition, typed action outcome,
and native evidence. Contracts revealed risk wherever production collapses
loading, missing, and failed dependencies into one state; leaves peer controls
active after a mutation snapshot; or exposes a runtime boundary with only
structural-object validation. Those are architectural debts in the code, not
conditions the contract should hide.

New tooling should extend this graph by resolving existing authorities and
validation strength. It should not generate product behavior from prose or
replace specialist schemas. That separation keeps the format deterministic
while allowing the application structure to improve independently.

Required evidence stays strict. A real missing capture, preview, or test may be
admitted only through an explicit evidence exception tied to a stable open debt
id. The compiler rejects missing exceptions and also rejects stale exceptions
after the evidence is added. Compile and verify the contracts with:

```bash
node tool/design/check_feature_coverage.mjs --check
node tool/design/build_feature_contracts.mjs
node tool/design/build_feature_contracts.mjs --check
```

The compiler fails duplicate surfaces or authority bindings, runtime/authority
mismatches, duplicate or missing authority-state mappings, unknown action owner,
action, outcome, route, or dimension values, enabled known-gap actions,
undeclared Dart/TypeScript symbols, missing component/data paths, missing
capture/preview/test evidence, Admin callable or validation-strength drift,
unused evidence exceptions, stale output, and
orphaned generated artifacts. Natural-language
briefs may inform a contract draft, but only the reviewed JSON source is
executable. Flutter widgets, controllers, business algorithms, security rules,
and migrations remain manually implemented and tested against their owning
contracts.
