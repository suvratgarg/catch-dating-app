---
doc_id: host_visual_quality_rollout
version: 0.3.0
updated: 2026-08-31
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

The current authoritative global destinations remain:

```text
Events · Customers · Forms · Messaging · Organizer
```

The studied alternative:

```text
Today · Events · Audience · Inbox · Organizer
```

is a product and route-authority proposal. It must not be smuggled into a
styling slice. The shell decision remains its own late rollout item after the
underlying compositions prove their value.

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
| S3 | Create Event essentials hierarchy and adaptive flow composition | `in_progress` |
| S4 | Durable Event workspace composition and route-state contract | `pending` |
| S5 | Forms library and builder studio composition | `pending` |
| S6 | Messaging Inbox list/thread composition | `pending` |
| S7 | Live workspace stage/roster/command composition | `pending` |
| S8 | Global shell, naming, and Forms placement product decision | `pending` |
| S9 | Cross-surface state, accessibility, and visual-regression hardening | `pending` |

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
- Guests, Messages, Forms, and Run entry points where current capabilities and
  permissions support them.
- Compact menu/pushed-route behavior and wide persistent workspace navigation.
- URL/deep-link/back/resize state.

### Excluded

- New lifecycle phases or backend permissions.
- Duplicate attendance, Event Success, messaging, or Forms implementations.
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

The first pending production item is **S2 — Customer record detail and
adaptive selection**. Start from the current pushed detail route and expanded
master-detail seam, then inspect the complete identity, memory, activity,
communication, loading, failure, mutation, selection, and route-state owners
before editing.
