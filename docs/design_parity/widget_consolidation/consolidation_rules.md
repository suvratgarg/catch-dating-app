---
doc_id: widget_consolidation_rules
version: 1.0.0
updated: 2026-07-12
owner: widget_consolidation
status: active
---

# Widget Consolidation Rules

The actionable unit is a stable UI pattern family, not a generated similarity
pair or cluster. `pattern_families.json` records the family intent, approved
quality reference, target contract, accepted visual delta, and a disposition
for every reviewed member. Similarity pairs, name families, and structural
clusters are discovery evidence only.

The K/R/D rules below are post-decision implementation tactics. Apply them only
after a review session has approved the family and promoted its members to one
of `canonical`, `repair`, `unify`, `register`, or `discard`. They help execute
the decision safely; they do not decide which rendering or API is strongest.
Record mechanical outcomes in `decisions.json` with
`"decidedBy": "codex-rule:<id>"` and the stable pattern-family id.

## Pattern-family review gate

Before creating a work order:

1. Assign the candidate to a stable family in `pattern_families.json`, or
   record an explicit boundary explaining why it belongs to another family.
2. Render every available member side by side in Widgetbook under consistent
   theme, viewport, and text-scale contexts. Missing previews are tracked
   evidence, not permission to decide from a class name.
3. Choose the best visual and API reference. Do not assume the `Catch*`, core,
   oldest, or most-used implementation is strongest.
4. Give each member exactly one disposition:
   - `canonical`: approved reference; implementation, contract, and canonical
     Widgetbook surface agree.
   - `repair`: valid concept whose visuals, API, contract, or preview are below
     the approved quality bar.
   - `unify`: migrate into the named target contract; aliases are not an end
     state.
   - `register`: valid distinct concept that needs stable global ownership and
     review coverage.
   - `discard`: obsolete, redundant, or too weak/trivial to remain public.
5. Record any intentional visual change in `acceptedVisualDelta` and the
   decision source. Only `approved` or `implemented` families produce work
   orders.
6. Repair or establish the canonical reference first, then migrate siblings,
   rerender the whole family, and close with contracts, Widgetbook, tests,
   scanners, registries, receipts, and readiness proof.

Raw `dedupe-pair-*` and `dedupe-cluster-*` ids must never be direct work-order
owners. Cluster ids are regeneration evidence and are not stable decisions.

Scope limits (apply regardless of rules):

- Never invent a name for a new **core** (`Catch*`) primitive outside an
  approved pattern-family decision.
- Never merge a widget with **> 10 external usages** without an approved
  family decision and explicit migration proof.
- Never change visual output unless the family records the accepted visual
  delta, or the change is token standardization/skeleton noise explicitly
  covered by an existing order.
- `scope: screen` clusters always escalate (screens embed routing/providers;
  every reviewed one so far was composition, not duplication).

## KEEP rules (post-decision stop-losses)

Run KEEP rules before mechanical merge rules. A K-rule may expose an incorrect
family assignment or an unsafe implementation plan, but it does not silently
override an approved `unify` or `discard` decision; return that conflict to the
review session.

**K1 — Composition is not duplication.**
If widget A instantiates widget B (B appears in A's construction tree — check
`widgetsUsed` in the fingerprint artifact or grep A's build), never merge the
pair, whatever the similarity score. Record keep-distinct.
*Evidence: ProfileTab/ProfileTabContent, DashboardFull/DashboardFullSliverBody.*

**K2 — Domain forks stay forked.**
If the pair's constructor/param types come from parallel domain model
families (e.g. `…GroupOverrideRound` vs `…RotationOverrideRound`; two
`…PreviewRow` types), keep-distinct and note the family. Unifying trades
duplication for generics + conditional business logic.
*Evidence: the 14-widget Group/Rotation family; EventPolicy row pairs.*

**K2 discriminator (v0.2.0 — added after the 2026-07-03 audit found K2
over-applied):** parallel param TYPES alone do not make a domain fork. K2
requires the build bodies to contain **diverging business logic** —
different conditionals, different computed semantics, different
interactions. If the bodies are structurally parallel and differ only in
typed field access, metric keys, labels, or parallel view-model plumbing,
that is a **presentation kit duplicated across features** — the highest-value
merge class. Do not keep it; ESCALATE it as a kit-unification candidate
(the shared API needs review-session design).
*Counter-evidence that motivated this: Host/User analytics
MetricTile/TrendPanel/MetricGrid/DataQualityPanel pairs — near-identical
surfaces, tokens, and layout over parallel `*MetricCard`/`*TrendPoint`
types; wrongly kept as K2, re-opened by the audit.*

**K3 — Already sharing internals.**
If both builds delegate to the same shared body/spec symbol (grep both bodies
for a common `*Body` / `*Spec` / shared private helper), the dedupe already
happened; two public entry points are API ergonomics. Keep-distinct.
*Evidence: CatchErrorState/CatchInlineErrorState.*

**K4 — Churn threshold.**
If the mergeable shared code is under ~10 lines AND the two names carry
distinct intent, keep-distinct. Do not create a parameterized widget that
needs 3+ new knobs to reproduce both originals.
*Evidence: CompanionError/CompanionMessage, celebration details cards,
dashboard home screens.*

**K5 — Concept mismatch → escalate (not merge, not keep).**
Same skeleton but the typography/token roles differ in kind (label* vs
title* vs kicker styles; meta row vs section title vs status leading): this
is a design-intent question. Escalate with both bodies quoted.
*Evidence: StageSectionLabel vs meta rows; UnsavedChangesPill vs CTA
leadings; MapPill vs PhotoSlotMainBadge.*

## MERGE rules

**R1 — Byte clones.**
Identical fine-stream `shapeHash` AND identical constructor param names/types.
Merge:
- both in the same file/feature → keep the better-named one in the more
  shared file; delete the other; repoint call sites.
- one in `lib/core/widgets/` → it is canonical; absorb the feature copy.
- cross-feature, neither in core → this wants promotion: ESCALATE with a
  proposed `Catch*` name (the merge itself waits for the name).
*Evidence: HostAnalyticsBar/UserAnalyticsBar, EventDetailSocialSkeleton/
OptimisticSocialSkeleton.*

**R2 — Thin wrappers over an existing primitive.**
Build returns a single call to an existing `Catch*` primitive, optionally
inside ≤2 trivial layout wrappers (`Center`, `Padding`, `SizedBox`, `Align`,
`CatchScreenBody`), passing only constructor params and literals — AND the
widget has ≤3 call sites. Inline the expression at each call site, delete the
class. Conditional expressions inside the arguments move verbatim.
*Evidence: the six c009 empty states, both history empty states,
Calendar/SavedEvents messages.*

**R3 — Same-file content variants.**
Two+ widgets in the SAME file, equal coarse structure, bodies differing only
in literals (strings, icons) or exactly one argument. Parameterize into one
widget whose params are named after what varies; delete the rest.
If the varying argument is a Widget and call sites choose it from data,
folding that choice inside is a design question → do the merge with a widget
param and note the fold option in Escalations.
*Evidence: AttendedLeading/BookedLeading, DirectoryIdentity/PhotoCard.*

**R4 — Delegation within a file.**
Pair in one file where B = A plus computed content or a fixed configuration:
rewrite B's build to construct A (B stays public). No call sites change.
*Evidence: PaperTicketSerial→PaperTicketDetail, CatchTabDockIcon→
CatchCountBadge, CatchConfirmDialog→CatchFormDialog.*

## DRIFT rule (side-quest, always on)

**D1 — Tokenize raw literals encountered while executing any order.**
Raw dimensions/alphas/icon sizes in files you are already editing: replace
with an existing exact-or-nearest token when the value is skeleton/jitter
noise; otherwise escalate with a proposed token name. Never add tokens
yourself except where an order names one explicitly. Report every fix in the
receipt.
*Evidence: `size: 11` → CatchIcon.micro; MapPill 0.93 alpha; raw skeleton
title widths.*

## What stays with the review session (no mechanical rule possible)

The judgment calls that produced the most value are exactly the ones that
resist codification:

1. **New-primitive API design** (CatchScrim's preset constructors, the
   CatchSkeletonRows leading enum, CatchMetaRow's two-color API) — deciding
   the *shape* of the merged API and which knobs to refuse.
2. **Concept identity** (K5 escalations) — whether two lookalikes are one
   design concept or two.
3. **Canonical naming** — every new `Catch*` name.
4. **Standardization trade-offs** — accepting a visual change (RunningStat's
   label flip) versus preserving pixels.

These judgments are now made explicitly at the pattern-family gate. K1–K5 and
R1–R4 begin only after the family target and accepted visual delta are known.
