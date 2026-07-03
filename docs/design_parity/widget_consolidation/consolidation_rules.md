---
doc_id: widget_consolidation_rules
version: 0.2.0
updated: 2026-07-03
owner: widget_consolidation
status: active
---

# Widget Consolidation Rules

Decision rules distilled from the first 34 reviewed clusters (see
`decisions.json`). They let Codex triage candidates autonomously. Apply in
the order given: **KEEP rules are stop-losses and run first**; a candidate
that trips any K-rule is recorded and closed. Then the merge rules. A
candidate matching **no rule exactly** goes to Escalations — never stretch a
rule to fit. Record every outcome (including keeps) in `decisions.json` with
`"decidedBy": "codex-rule:<id>"`, so the review session audits the ledger
instead of re-reading widgets.

Scope limits (apply regardless of rules):

- Never invent a name for a new **core** (`Catch*`) primitive — propose one
  in the escalation and wait.
- Never merge a widget with **> 10 external usages** without a review
  decision.
- Never change visual output except (a) token standardization explicitly
  covered by a rule/order, or (b) skeleton width/jitter noise.
- `scope: screen` clusters always escalate (screens embed routing/providers;
  every reviewed one so far was composition, not duplication).

## KEEP rules (stop-losses)

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

## What stays with the review session (no rule possible)

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

Expected split based on the ledger so far: roughly 60% of remaining
candidates should triage under K1–K4/R1–R4; the rest escalate.
