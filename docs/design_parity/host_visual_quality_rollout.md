---
doc_id: host_visual_quality_rollout
version: 1.4.0
updated: 2026-09-01
owner: product_design_parity
status: active
---

# Host Visual Quality Rollout

This document is the authored execution tracker for raising the visual and
interaction quality of the authenticated Host app across phone, tablet, and
desktop. It records scope, sequence, decisions, exclusions, and acceptance
criteria so each implementation pass can resume from current product truth.

It is not an audit receipt, generated history, readiness score, or replacement
source of truth. Git commits and CI own implementation evidence. The design
language, app architecture, screen/component contracts, routes, controllers,
and data contracts retain their existing authority.

## Working rule

Each checklist item below is one bounded delivery unit. Complete its intended
source and contract changes, run its derived focused checks, inspect the final
diff, update its status here, and commit the item before beginning the next
one. The commit containing the completed status is the completion boundary;
do not duplicate commit hashes or run logs in this file.

## Direction

The selected visual direction is **Host Command Center corrected to Catch
product truth**:

- Catch remains paper, ink, Archivo voice, platform-function typography, mono
  data roles, and activity pigment used only for meaning.
- Typography, alignment, whitespace, and hairlines carry hierarchy before
  containers.
- Each screen has one task thesis, one dominant object, and a bounded action
  budget.
- Phone remains concise. Tablet and desktop add task concurrency through
  adjacent panes instead of enlarging phone cards.
- Runtime behavior and source-backed data override any generated-reference
  detail that cannot be proved.

The local source study for this rollout is the 2026-08-31 cross-device Host
atlas under the originating Codex visualization task. It is visual intent, not
an implementation or product authority. The durable translation of that study
is the slice acceptance criteria below.

## Authority order

When sources disagree, use this order:

1. Product, route, controller, permission, and data-contract truth.
2. `docs/app_architecture.md` and feature owner documents.
3. `docs/design_language.md` and existing Catch primitives.
4. `design/screens`, `design/components`, feature contracts, and Widgetbook.
5. Generated/reference images for hierarchy and composition intent.
6. Fresh runtime captures for proof of the implemented result.

Do not change production behavior merely to resemble a reference image. Do not
refresh a visual baseline merely to make a changed implementation pass.

## Starting baseline

The rollout branch began from `origin/main` at `af38e06ba` on 2026-08-31.
Current main already contains the recent Customers/Audiences work and the
following corrected visual-evidence foundations:

- the routed Host capture shell has all five current production branches;
- the populated Events capture overrides the current timeline controller;
- Customers has populated People and Audiences captures;
- Forms has a populated full-shell capture; and
- independent customer rows use section-owned divided geometry.

These are baseline facts to preserve, not work to reproduce.

The corrective rollout now adopts these authoritative global destinations:

```text
Today · Events · Audience · Inbox · Organizer
```

The pre-correction shell:

```text
Events · Customers · Forms · Messaging · Organizer
```

remains a compatibility concern, not a competing product authority. Existing
deep links must redirect into the new hierarchy without losing identifiers,
queries, drafts, or Back behavior.

## Global acceptance contract

Every completed product slice must satisfy the applicable parts of this
contract:

- The primary task and dominant object are identifiable without the reference
  image.
- Product copy, metrics, statuses, permissions, and actions are source-backed.
- At most two visually heavy surfaces precede the first useful phone content.
- Root headers expose at most two actions.
- Independent records are flat rows unless their material or action semantics
  earn a surface under the containment doctrine.
- Screen, route, section, field, state, and action geometry stays with its
  existing canonical owner.
- Loading, error, empty, partial, offline, mutation, and populated states keep
  a coherent version of the same composition.
- Compact, medium, and expanded layouts receive the same typed state and
  callbacks; viewport changes do not introduce new repositories or behavior.
- Text scale 1.0, 1.5, and 2.0, light/dark, reduced motion, keyboard/pointer,
  visible focus, and semantic order are covered in proportion to the slice.
- Query, filters, selection, scroll, drafts, and route state survive the
  navigation and resize boundaries that own them.
- No text-bearing container depends on a fixed height.
- Repeated invariants become the smallest appropriate test, contract, lint,
  or scanner after the reference implementation proves them.
- A fresh runtime capture is reviewed beside the selected visual reference;
  screenshots supplement rather than replace behavioral proof.

## Status legend

| Status | Meaning |
|---|---|
| `pending` | Scoped but not started. |
| `in_progress` | Current delivery item; no later item may start. |
| `blocked` | A named external or product decision prevents progress. |
| `complete` | Source, contracts, checks, diff review, and commit boundary are complete. |

## Rollout checklist

| Item | Delivery unit | Status |
|---|---|---|
| T0 | Establish this persistent rollout contract and clean-worktree baseline | `complete` |
| S1 | Customers/People directory reference composition | `complete` |
| S2 | Customer record detail and adaptive selected-record composition | `complete` |
| S3 | Create Event essentials hierarchy and adaptive flow composition | `complete` |
| S4 | Durable Event workspace composition and route-state contract | `complete` |
| S5 | Forms library and builder studio composition | `complete` |
| S6 | Messaging Inbox list/thread composition | `complete` |
| S7 | Live workspace stage/roster/command composition | `complete` |
| S8 | Global shell, naming, and Forms placement product decision | `complete` |
| S9 | Cross-surface state, accessibility, and visual-regression hardening | `complete` |

## Corrective rollout checklist

This checklist supersedes the S8 decision below. It exists because the first
rollout treated an approved product direction as an unresolved research
question and therefore preserved the wrong top-level hierarchy.

| Item | Delivery unit | Status |
|---|---|---|
| C0 | Reopen the tracker and pin the approved Host IA and chrome invariants | `complete` |
| C1 | Preserve the original adaptive Catch bottom navigation and add an iOS regression | `complete` |
| C2 | Add a real Today destination and make Events the event inventory | `complete` |
| C3 | Consolidate People, Audiences, Forms, and Responses under Audience | `complete` |
| C4 | Rename the global Messaging destination to Inbox; migrate contracts, captures, and owner docs | `complete` |

## Feature-ownership refactor checklist

The visual and information-architecture rollout exposed a second problem: the
five destinations were still implemented largely inside the legacy
`lib/hosts/presentation/` aggregate. The product hierarchy is now being made
literal in source so each destination can own its policy, data projection,
route edge, typed state, widgets, tests, and visual states without rebuilding a
second monolithic Host home.

The target folders are `lib/hosts/<destination>/{domain,data,presentation}`.
Existing cross-destination concepts stay shared only when they are genuinely
shared; a temporary compatibility seam must be named in the active item and
removed by the item that owns its destination.

| Item | Delivery unit | Status |
|---|---|---|
| A0 | Pin feature-first destination ownership, migration order, exclusions, and completion rules | `complete` |
| A1 | Extract Today into its own vertical slice and move Dress Rehearsal out of the create-event chooser | `complete` |
| A2 | Extract the Events inventory, timeline state, and route screen into `lib/hosts/events/`; retire the legacy Home compatibility surface | `complete` |
| A3 | Extract Audience ownership, including People, Audiences, Forms, and Responses, without reviving a Forms destination | `pending` |
| A4 | Extract Inbox ownership and its Inbox/Sends modes while preserving conversation and composer state | `pending` |
| A5 | Extract Organizer ownership, then reduce `lib/hosts/presentation/` to intentional shared Host presentation seams | `pending` |

## Today attention-system checklist

This is the data and architecture gate before visual closeout of the first tab.
It keeps queue policy out of widgets and makes unsupported archetypes visible
instead of silently deriving them from incomplete fields.

| Item | Delivery unit | Status |
|---|---|---|
| B0 | Add the exhaustive policy catalog, evaluated projection/callable schemas, generated contract outputs, rules, indexes, fixtures, and owner documentation | `complete` |
| B1 | Implement the manager-authorized read-through reconciler for every source-ready server kind, with bounded fail-closed scans and resolution tests | `complete` |
| B2 | Replace Today’s event-only derivation with the callable projection plus the local attendance outbox merge; preserve Dress Rehearsal as a shortcut | `complete` |
| B3 | Add machine-readable responsibility contracts for the five top-level Host features and generate their local overview Markdown plus a drift check | `pending` |
| B4 | Align Today’s compact and wide visual states with the approved renders, run runtime captures, and close the first tab | `pending` |

### A1 boundary

- `/host/today` constructs `HostTodayScreen` directly.
- Today owns route/display state, the attention policy, the Today feed
  projection, provider-free body/overview widgets, its clock, and its route
  effects under `lib/hosts/today/`.
- The supported queue is exhaustive inside a named seven-day horizon and is
  ordered by immediate, soon, then upcoming urgency; facts outside that window
  stay in Events until they become time-sensitive.
- The Events timeline controller lives in `lib/hosts/events/presentation/` and is consumed
  only by the Events inventory. Today owns a separate bounded feed controller
  over the shared Event repository, so top-level features do not consume each
  other's screen controllers.
- Dress Rehearsal is a dedicated Today action and is absent from the
  create-event chooser. Creating and rehearsing are separate intents.
- A2 removed `HostOperationsHomeScreen`, `HostOperationsSurface`, and the
  combined Home compatibility path. `/host/events` now constructs
  `HostEventsScreen` directly.
- A1 deliberately does not reorganize the Events presentation tree, Audience,
  Inbox, Organizer, or the shared shell.

### Approved information architecture

- **Today** is the operational home: the next or live event, time-sensitive
  attention, the safest immediate action across the organizer's events, and
  the dedicated Dress Rehearsal entry.
- **Events** is the durable event inventory and entry point for creation,
  lifecycle history, and event workspaces. Rehearsal remains event-scoped but
  is entered from Today rather than the create-event chooser.
- **Audience** owns people, saved audiences, forms, and responses as one
  participant-relationship area. Form builders and deep response routes remain
  focused routes within that authority rather than global destinations.
- **Inbox** owns conversations and outbound sends. The short shell label does
  not remove the Sends peer workspace inside it.
- **Organizer** retains profile, venue, staff, payout, and settings authority.

### Navigation chrome invariant

The rollout must retain the existing platform-adaptive `CatchTabBar` rather
than replace it with the flat fixed bar shown in reference renders. Compact
iOS keeps the floating frosted Catch pill and body extension; compact Android
keeps the existing anchored platform treatment; medium and expanded widths
keep the existing rail and sidebar. The same five branch states must survive
all placements.

## T0 — Persistent rollout contract

### Goal

Create one durable, source-backed execution plan before broad UI mutation.

### Included

- Direction and authority order.
- Current-main baseline.
- Bounded slice sequence.
- Slice-specific acceptance and exclusions.
- Commit-after-item rule.

### Excluded

- Runtime UI changes.
- New architecture or component APIs.
- Generated evidence or pass receipts.
- Shell/navigation decisions.

### Completion criteria

- This tracker is linked from `docs/design_parity/README.md`.
- The tracker is committed on an isolated branch based on current
  `origin/main`.
- The original dirty worktree remains untouched.

## S1 — Customers/People directory reference composition

### Goal

Make the People directory feel immediate, calm, and operational using current
CRM truth and existing Catch owners. This is the first production reference
slice for the Directory archetype.

### Included

- Populated People view at compact width.
- Header, summary, search, sort/filter, and first-fold ordering.
- Flat customer rows and local press behavior.
- Loading, empty, active-query empty, partial-coverage, pagination pending,
  and pagination failure states affected by the composition.
- Medium and expanded provider-free composition where current route and URL
  state can support it without premature shell migration.
- Focused Widgetbook/capture/test updates.

### Excluded

- Global Customers-to-Audience rename.
- Moving Forms into Customers.
- New CRM metrics, inferred value/risk segments, or messaging capabilities.
- Customer-detail information architecture beyond the selection seam needed
  for the directory.
- App-wide generic Directory scaffold extraction.

### Acceptance

- A normal populated phone state exposes the first real person within roughly
  300–380 logical pixels from the content top.
- Summary vocabulary remains source-backed.
- Search, current sort, and filter state read as result tools rather than peer
  navigation or primary content.
- No card-per-person or decorative status surface is introduced.
- The current People/Audiences state and route contract remain truthful.
- The implementation passes the global acceptance contract.

## S2 — Customer record detail and adaptive selection

### Goal

Give a customer record one compact identity/action header and a clear reading
path across memory, attendance, communication, and history.

### Included

- Compact pushed-record route.
- Current privacy and communication capability truth.
- Provider-free medium/expanded selected-record composition.
- URL/back/resize/selection restoration where master-detail is adopted.
- Loading, missing, primary failure, partial enrichment, mutation, and long
  content states.

### Excluded

- Invented relationship health, risk, or revenue claims.
- New communication channels.
- Global shell changes.

### Acceptance

- Identity, trusted contact state, privacy, and primary action precede the
  long record.
- Destructive and administrative actions remain contextual and guarded.
- Wide composition adds useful adjacency without changing customer behavior.

## S3 — Create Event essentials and adaptive flow

### Goal

Preserve the existing robust draft/controller lifecycle while making required
event decisions precede optional enrichment and giving larger viewports a
real step/form/consequence composition.

### Included

- Step ordering and first-step composition.
- Existing step header, draft, validation, frozen-request, and exit contracts.
- Compact optional-media treatment before media exists.
- Medium step rail and expanded bounded form lane plus source-backed preview
  or readiness consequence.
- Loading, validation, restored draft, save/submit pending/error/offline,
  text-scale, reduced-motion, and dark states.

### Excluded

- New event fields or backend requirements.
- Invented publishing/readiness signals.
- Event workspace route migration, except the existing post-create handoff.

### Acceptance

- A host can define the viable event before optional media dominates the
  viewport.
- Draft state is always visibly truthful.
- Form decisions and errors survive platform and viewport changes.
- The 600–680 logical-pixel form lane remains readable on wide screens.

## S4 — Durable Event workspace

### Goal

Make the event the stable operational subject from preparation through live
operation and recap without duplicating existing lifecycle authorities.

### Included

- Overview and lifecycle-owned workspace hierarchy.
- Guests, event-scoped Inbox, Rehearsal, and Run entry points where current
  capabilities and permissions support them.
- Compact and wide overlay-roster behavior that preserves the one lifecycle
  workspace and its underlying element.
- URL/deep-link/back/resize state.

### Excluded

- New lifecycle phases or backend permissions.
- Duplicate attendance, Event Success, messaging, or Forms implementations.
- Event-scoped Forms until a real event/form relationship and route exist.
- Persistent mode navigation that competes with lifecycle relevance.
- Shell destination changes.

### Acceptance

- One selected event remains the subject across workspace areas.
- Existing aliases and lifecycle policies remain truthful.
- Wide adjacency reduces navigation without leaking restricted capability.

## S5 — Forms library and builder studio

### Goal

Raise Forms from a phone-width route to a coherent library and responsive
studio while preserving the current Forms authority until S8.

### Included

- Forms/Responses peer navigation and search hierarchy.
- Library density and real states.
- Builder outline, editor, and preview composition at capable widths.
- Current template, logic, validation, conflict, undo, publish, response, and
  authorization behavior.

### Excluded

- Moving Forms under Customers/Audience.
- Per-form accessibility or theme controls that weaken platform baselines.
- New automation, analytics, or delivery capability without source authority.

### Acceptance

- Structure, current edit, and consequence are concurrently understandable at
  wide widths.
- Phone retains one focused task and reachable peer destinations.
- Accessibility is product behavior, not an organizer option.

## S6 — Messaging Inbox

### Goal

Separate global destination, Inbox/Sends workspace, event/general scope,
audience selection, query, and commands into unmistakable levels.

### Included

- Current Inbox and Sends/campaign capabilities.
- Phone list and pushed thread.
- Medium list/thread and expanded navigation/list/thread composition.
- Independent query, selection, thread draft, and route state.

### Excluded

- New transport or delivery claims.
- Treating external WhatsApp handoff as a sent message.
- Unscoped broadcasts.

### Acceptance

- Every control makes its navigation or filtering level clear.
- Conversation discovery and response can coexist on capable widths.
- Current communication-route permissions and observability remain truthful.

## S7 — Live workspace

### Goal

Refine the existing task-specific Live grammar into a viewport-safe stage,
roster/supporting context, recovery surface, and one command region.

### Included

- Current Preparation, Live Operations, and Recap ownership.
- Live state and sync confidence.
- Guests/roster access without a clipped affordance.
- Manual/offline recovery and role-aware commands.
- Medium/expanded supporting-pane composition.

### Excluded

- New staff permissions, live phases, or event mutations.
- Persistent mode navigation that contradicts lifecycle ownership.

### Acceptance

- Current instruction and safe next action dominate.
- Roster access remains visible and viewport-safe.
- Offline/retry truth is visible before a consequential command is repeated.

## S8 — Global shell and Forms placement decision

### Goal

Decide and, only if approved by product evidence, migrate the global Host
information architecture.

### Decision options

1. Retain `Events · Customers · Forms · Messaging · Organizer`.
2. Adopt `Today · Events · Audience · Inbox · Organizer`, with Forms visible
   inside Audience and Event workspaces plus direct links.
3. Retain Forms globally and make Today a mode within Events.

### Required evidence

- Host usage or research for Today versus Forms frequency and mental models.
- Current route, controller, deep-link, notification, and authority audit.
- State-preservation prototype for compact and wide shells.
- Exact migration and compatibility plan before source changes.

### Acceptance

- The chosen option is reflected in owner docs, routes, screen/feature
  contracts, captures, copy, tests, and shell behavior in one bounded migration.
- No implementation maintains two competing global authorities.

### Superseded decision

The initial rollout selected option 3 and retained
`Events · Customers · Forms · Messaging · Organizer`. Product review rejected
that conclusion. C0-C4 replace it with option 2; this text remains only to make
the correction and its scope reviewable in Git.

- `/host` already redirects to Events, whose operational spotlight, attention
  queue, and lifecycle list provide the time-sensitive Today composition.
- Customers is the truthful parent of People and Audiences; Audience cannot
  replace its person-level CRM meaning.
- Forms owns a standalone route family for templates, responses, applications,
  builder, preview, share, analytics, and automations. Contextual links may
  point into it, but do not replace its global authority.
- Messaging truthfully contains the peer Inbox and Sends workspaces; Inbox
  alone would hide outbound work.
- Apple and Android guidance supports a small set of persistent peer
  destinations with adaptive bottom/rail/sidebar placement and retained state.
  Airbnb's Today pattern is an overview of active reservations, which maps to
  Catch's existing Events composition rather than proving a second route.
- The repository contains route analytics instrumentation but no verified Host
  frequency study or exported usage result. A future migration therefore needs
  new product evidence, not a reference-image preference.

The shell coverage gate and runtime state-preservation test created for this
decision must be migrated in C3-C4 so they enforce the approved hierarchy
instead of perpetuating this superseded one.

## S9 — Cross-surface hardening

### Goal

Turn proven visual and interaction invariants into durable product quality.

### Included

- Longest-content and localization-shaped fixtures.
- Text-scale 1.0/1.5/2.0.
- Light/dark and reduced motion.
- Keyboard, pointer, hover, focus, semantics, resize, Back/Forward, and state
  restoration.
- Accepted visual baselines and strict regression thresholds where dynamic
  regions can be bounded honestly.
- Promotion of only repeated, deterministic invariants into contracts/lints.

### Excluded

- Baseline refreshes without accepted runtime comparison.
- New generic primitives based on visual similarity alone.
- A tracked run ledger or replacement evidence registry.

### Outcome

- `CatchScreenTopBar` now reserves the same two supporting-copy lines that its
  title stack renders from 1.5x text scale, including search-enabled headers.
- Expanded shell identity can use two lines at large text instead of clipping
  the Host product name.
- Demand-pricing consequence copy keeps the same four-line budget as the
  adjacent Cross Paths policy explanation.
- Shared tests pin subtitle geometry, shell identity wrapping, compact through
  expanded branch continuity, Forms draft preservation, and the policy-copy
  contract.
- The reference set now has reviewed light/dark phone and desktop compositions
  at 2.0x text scale, a phone pass at 1.5x, and the registered reduced-motion
  Event and Inbox states. These remain review artifacts rather than product
  authority or tracked pass receipts.
- Component context, Claude handoff projection, design-sync manifest, and the
  pinned Host source-pack digest are current with the implemented contracts.

## Per-item completion loop

For every item:

1. Refresh `origin/main` and inspect overlapping work before editing.
2. Create or continue the isolated rollout worktree.
3. Mark only that item `in_progress`.
4. Read the current source owners as whole units.
5. Derive focused checks from the intended paths.
6. Implement the smallest coherent production surface and its states.
7. Add or update behavior tests, Widgetbook, captures, and contracts in the
   same item when their authority changes.
8. Render the relevant runtime state at compact and applicable wide widths.
9. Compare runtime, reference, and previous runtime together; classify
   differences as intent-breaking, product-correct, reference defect, or craft
   defect.
10. Run focused checks, `git diff --check`, final status, and scope review.
11. Mark the item `complete` and commit it before moving on.

## Handoff state

The original bounded rollout is complete through S9, and the corrective
rollout is complete through C4. The shared `CatchTabBar` required no runtime
restoration because it remained identical to the pre-rollout source; dedicated
tests now pin the floating frosted iOS treatment, anchored Android treatment,
and keyboard continuity. Today owns the live/next-event spotlight,
cross-event attention, and a bounded later-event preview; Events owns the
complete schedule and history without duplicating the operational hero.
`/host` and Host startup resolve to `/host/today`. One Audience branch owns
People, Audiences, Forms, and Responses, while legacy Customers and Forms deep
links redirect into that branch without losing nested path or query state.
The shell label is Inbox; the route retains Messaging as its local title above
the Inbox and Sends modes. These statements describe committed rollout source
and local verification only; no merge, deployment, or distribution claim is
made here.

Feature-ownership hardening is active. A1 and A2 are complete: Today and Events
are direct route-owned vertical slices with separate screen state, view models,
and controllers. Today owns a bounded feed over the shared event repository;
Events owns the full timeline and inventory. Dress Rehearsal is a dedicated
Today action, and the legacy combined Home compatibility surface is gone. B0
now defines the source-backed attention contract. B1 implements the manager-
authorized read-through reconciler, including canonical and legacy event
ownership, ordinary waitlists, explicit manual join requests, applications,
provider and form-automation failures, payout readiness, deterministic
resolution, and fail-closed source caps. B2 consumes the callable through a
Today-owned repository, strictly parses exhaustive coverage, merges normalized
local attendance retry/conflict work, and preserves event content while naming
an incomplete attention source instead of showing a false all-clear. B3 is
next: generate the five feature-responsibility overviews from machine-readable
contracts and enforce drift. A3-A5 remain intentionally pending.
