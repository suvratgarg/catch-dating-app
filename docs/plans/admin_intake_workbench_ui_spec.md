---
doc_id: admin_intake_workbench_ui_spec
version: 1.0.0
updated: 2026-07-27
owner: web_platform
status: active
---

# Admin Intake Workbench — UI Spec (for Codex)

Scope: `admin/src/shared/ui/AdminPrimitives/intake.tsx`, the intake block of
`admin/src/styles.css` (~L2600–3200), and the three Intake workspaces under
`admin/src/features/intake/`.

Companion: [`organizer_intake_live_projection_spec.md`](organizer_intake_live_projection_spec.md)
— that spec owns *what data* reaches this screen; this one owns *how it is
worked*. Neither blocks the other.

**Coordination:** work on this screen was already in flight when this spec was
written (a draft-scaffolding flow with `DRAFT CREATED` status and an "Open
organizer draft" action exists in a build but not in the committed tree).
Reconcile with that work rather than reverting it; every directive here is about
layout, density, hierarchy and interaction, not about removing new capability.

---

## 0. Operating profile (owner-specified, drives everything below)

| Question | Answer |
|---|---|
| Session length | Minutes today, **hours soon** |
| Unit of work | **~50 records per sitting**, not one |
| Users | Owner today, employees soon |
| Aesthetic | **An internal tool that borrows the Catch palette** — not an editorial surface |

Every trade-off below resolves toward: sustained batch throughput by a trained
operator. When in doubt, favor scanning fifty rows over admiring one.

Implementation state (2026-07-27): implemented across Organizer, Event, and
Automation Intake with one shared batch-workbench primitive. The production
build, route stories, accessibility suite, responsive browser checks, and
selection-stability regressions are the release evidence for this contract.

---

## 1. The reframe

The current screen is built as a **dashboard**: a narrow queue feeding a large
report pane, one record at a time. The actual job is **batch triage**. That
mismatch is the root of most complaints; fixing typography alone will not
address it.

Consequences, in priority order:

1. The **queue is the workspace**. It gets the width and the height.
2. A row must carry enough to decide **without opening anything**. If a decision
   routinely requires opening the inspector, the row is missing a column.
3. **Multi-select and bulk disposition are primary**, not a power-user extra.
4. The **detail becomes an inspector** — opened for the minority of records that
   genuinely need adjudication.
5. **Keyboard-first.** An hour of mouse-driven triage is a bad hour.

---

## 2. Diagnosis — mechanical causes

Fix the cause, not the symptom.

| Symptom | Cause |
|---|---|
| Bottom ~40% of the screen is empty; detail text clips mid-sentence | `styles.css:2764` — `max-height: min(620px, calc(100vh - 330px))`. A hard 620px ceiling plus a magic constant for the chrome above, which desynchronizes whenever the banner or toolbar wraps. |
| "Fonts are a mess", poor legibility | Seven font sizes in this block alone (9/10/11/12/13/16/22px). Record titles are 13px; evidence is 11px; status and meta are 9–10px uppercase mono. Hierarchy is inverted — decoration shouts, content whispers. |
| Nothing reads as more important than anything else | `.intake-review-status` is the *only* annotation style: 9px mono uppercase pill, `max-width: 150px`, centered. `MANUAL REVIEW REQUIRED`, `6 MAPPED SOURCE FIELDS` and `DRAFT CREATED` render identically and wrap into blobs. |
| Pending tasks not highlighted inline | `readiness.blockers` is a count in the top bar; the failing checks sit at the bottom of the left column; the resolving action is absent. Forced by the primitive's fixed six-slot shape (`AdminIntakeWorkbenchDetail`: primary / checklist / impact / note / footer), which every consumer must fill in order — hence Automation's filler row "No open tasks or blockers". |
| Sections incomprehensibly organized | Same fixed shape. Section order is a function of the interface, not of what the record needs. |
| Summary metrics poorly chosen | Stage rail spends ~90px on four counts, three of which are `0`. The 30-metric grid behind Diagnostics is pipeline telemetry, not operator state. |
| Loading states poorly represented | Whole screen falls back to a one-line `AdminWorkbenchNote`; Automation reuses the same `EmptyState` for "loading" and "no data" with a static icon. |
| Glitches | Orphan sentence ("Full pipeline diagnostics are available only in sample and Storybook coverage.") rendered bare inside the filter toolbar; status pills wrapping; queue rows 78px tall carrying three lines of mixed-register text. |
| Position lost during batch work | `organizerIntakeWorkbench.tsx:141` and `IntakeOperationsWorkspace.tsx:76` — when the selected entry leaves the filtered set, selection resets to `filteredEntries[0]`. Dispositioning an item throws the operator back to the top of the list. Fatal at 50 records. |

---

## 3. Layout

1. **Full height, one primary scroll region.** Remove the `max-height` cap and
   the `calc(100vh - 330px)` constant. The app shell owns viewport height
   (`100dvh`); every flex/grid ancestor of the scroll region carries
   `min-height: 0`. The table scrolls; the page does not.
2. **Three zones**, not two panes:
   - **Header** (sticky, compact): title, stage segmented control, filters,
     search, operator metrics (§9). Target ≤ 96px total, down from ~230px today.
   - **Table** (fills remaining height): the workspace.
   - **Inspector** (right, collapsible, resizable, default closed at ≥1600px and
     overlay below): opened per record.
3. **Selection action bar** replaces the header's filter row when ≥1 row is
   selected — count, bulk actions, clear. It must not shift the table.
4. **Stage rail collapses** into a segmented control in the header. Four counts
   do not need four cards.
5. Row height **36–40px**, one line of content per row, from 78px/3 lines today.
   Fifty rows should be scannable without scrolling on a 1440px-tall display.

### Table columns (organizer queue)

Fixed, scannable, decision-carrying. No column may be a chip pile.

`[checkbox] · Name · Kind (candidate/entity) · Market · Source/platform · Top blocker · Age · Status`

"Top blocker" is the single most important addition: the reason this row is not
already done, in plain text, in the row. If a row has no blocker it is
dispositionable from the list.

---

## 4. Typography

Adopt a tool type system. The Catch **palette** is borrowed; the Catch editorial
**type** is not.

1. **Interface font**: the system UI stack. Reserve `--catch-font-head`
   (Archivo) for the page title only. It is a display face and is the reason
   13px table text feels wrong.
2. **Three sizes, no more**: `meta 12px` / `body 13px` / `title 18px`. A single
   `20–22px` page title is permitted. **9px and 10px are deleted from this
   screen.** Anything currently at 9–10px is either promoted to 12px or removed
   because it was never worth the pixels.
3. **Mono (`--catch-font-mono`) is for identifiers only** — domain keys, run
   ids, hashes, external keys. Never for status, labels, counts or headings.
4. **Uppercase is for section headers only**, at 12px with tracking. Not for
   status, not for values, not for meta.
5. Line-height ≥ 1.4 for any wrapping text. Numeric columns use tabular figures.

---

## 5. Color and status semantics

The palette already carries meaning; it just isn't used meaningfully. Bind tone
to consequence, and stop rendering every annotation as a pill.

| Tone | Meaning | Treatment |
|---|---|---|
| `--red` | **Blocking** — this cannot proceed | Solid chip. Loud. Rare. |
| `--orange` | **Waiting** on a human or external input | Soft chip. |
| `--green` | **Done / ready** | Quiet — text with a check, not a filled pill. |
| neutral | Informational (counts, field provenance, source kind) | **Plain text. No chip.** |

Rules: at most **one** chip per row and at most **two** in the inspector header.
Remove `max-width: 150px` and centered text from status elements — a status that
needs wrapping is a sentence, and belongs in the row's blocker column, not a
pill.

---

## 6. Interaction model

### Batch disposition (primary)

1. Checkbox column, shift-click range select, "select all matching filter".
2. Selection action bar exposes the same decisions as the inspector: approve,
   hold, suppress, attach — each disabled with a **stated reason** when the
   selection contains records that fail its gate ("12 of 18 selected are blocked
   on ownership review").
3. Bulk actions are partial-safe: apply to the eligible subset, report the
   skipped remainder, never silently drop.
4. **Group-by-blocker** filter facet, alongside stage. The high-value question
   at 50 records is "show me everything blocked on ownership verification" —
   then dispose of the group in one pass.

### Keyboard

Publish the map in a `?` overlay and keep it stable:

`j`/`k` move · `x` toggle select · `Enter` open inspector · `Esc` close ·
`a` approve · `h` hold · `s` suppress · `/` focus search · `?` shortcuts

Every action reachable by keyboard must be reachable by mouse and be announced
to assistive tech; the shortcut is an accelerator, never the only path.

### Selection stability (regression-worthy)

After a disposition, selection advances to the **next** row in the current
order. It must never jump to `filteredEntries[0]`, and the list must not
re-sort or re-filter underneath the operator mid-pass. A dispositioned row stays
in place, visibly resolved, until an explicit refresh. Add a regression test.

### Undo over confirm

At fifty records per sitting, modal confirmations are the enemy. Apply
optimistically with a **10-second undo** in a toast. Where the domain supports
supersession, undo records a superseding decision rather than deleting history.
Irreversible actions keep an explicit confirm — but there should be almost none
on this screen, since intake decisions are records, not publications.

---

## 7. The record inspector

Replace the fixed six-slot `AdminIntakeWorkbenchDetail` with a **composable
section list**: an ordered array of typed sections the consumer supplies, so a
record with no policy state renders no policy section. No filler rows.

Mandatory ordering principle — **resolution first**:

1. **What's blocking, and the action that clears it.** Each blocker names its
   resolving action inline. This is the top of the pane, not the bottom.
2. Decision controls, pinned and always visible without scrolling. A disabled
   control states its gate.
3. Evidence and provenance.
4. Impact (what changes on approval) — keep this; it is genuinely good and is
   the one place the current design earns its density.
5. Raw/diagnostic detail, collapsed by default.

---

## 8. States

1. **Skeletons, not sentences.** The table renders shaped placeholder rows at
   true row height. Loading must be visually distinct from empty — never reuse
   `EmptyState` for both.
2. **Empty** distinguishes three cases, in copy: nothing matches this filter /
   nothing in this stage / **not available from the live projection** (see
   companion spec §9 Phase 1). The third must never look like the first two.
3. **Error** is inline and retryable at the pane that failed; a failed inspector
   must not blank the table.
4. **In-flight rows** show per-row pending state; the table stays interactive.
   Bulk operations show progress and a per-record result summary.
5. Delete the orphan diagnostics sentence from the toolbar; if the message is
   worth keeping it belongs in the empty/unavailable state, not the filter row.

---

## 9. Metrics

Replace stage counts and the 30-metric grid with **four operator numbers** in
the header:

`Needs you now` · `Waiting on external` · `Cleared today` · `Oldest untouched`

Rules: a metric earns its place only if it changes what the operator does next.
Pipeline telemetry stays in Diagnostics.

---

## 10. Delete list

- `max-height` / `min-height` on `.intake-review-workbench`.
- All 9px and 10px font sizes in the intake block.
- `max-width: 150px` and `text-align: center` on status elements.
- Uppercase mono styling on anything that is not an identifier.
- The four-card stage rail (becomes a segmented control).
- Filler checklist rows ("No open tasks or blockers").
- The orphan diagnostics sentence in the toolbar.

---

## 11. Non-goals

- No change to which callables are invoked or to any approval gate. This spec
  moves and restyles controls; it does not widen authority. The publication
  boundary notice stays.
- No new design language. Borrow the existing Catch palette tokens; do not mint
  colors.
- Not a rewrite of the Events or Automation workspaces — but both consume the
  same primitive, so both must be migrated and verified. Automation stays
  read-only.
- Do not build a saved-views/assignment system yet; single operator today.

---

## 12. Verification

```sh
node tool/run.mjs check web:react-architecture-boundaries
node tool/run.mjs check web:react-ui-primitives
node tool/run.mjs check web:react-component-governance
node tool/run.mjs check web:shared-ui-adoption
node tool/run.mjs check web:admin-feature-ui-size
node tool/run.mjs check web:admin-components
node tool/run.mjs check web:admin-storybook
node tool/agent/check_agent_readiness.mjs
```

Plus the admin typecheck/test loop, `web:admin-bundle-budget` after the admin
production build, and `web:admin-storybook-bundle-budget` after the Storybook
build. Update `design/admin/components.json` **before** component/Storybook
changes, per `AGENTS.md` routing.

Required new tests:

1. Selection advances to the next row after disposition and never resets to the
   first row; the list does not re-sort mid-pass.
2. Bulk action applies to the eligible subset and reports the skipped remainder.
3. A disabled decision control exposes its gate as text.
4. Loading, empty-filter, empty-stage and unavailable render as four distinct
   states.
5. Keyboard map: every shortcut has a mouse equivalent and an accessible name.
6. No element in the intake block renders below 12px (guard against regression).

Acceptance, stated as a task rather than a screenshot: **an operator can take
fifty Incoming candidates to a disposition in one sitting, without opening the
inspector for records that carry no blocker, and without losing their place.**

---

# Part II — Event leads workspace

Appended 2026-07-26, after §0–§12 entered implementation. **Do not re-open
§0–§12.** Everything in §1–§11 (full-height layout, type scale, status
semantics, batch model, keyboard map, inspector shape, states, metrics) applies
to **all three** intake workspaces including Event leads. This part adds only
what Events needs *differently*, plus Events-specific defects found in
`eventIntakeWorkbench.tsx` and `EventIntakeWorkspace.tsx`.

Verification in §12 applies unchanged; §20 extends it.

## 13. Why Events is not a copy of Organizers

Three structural differences drive everything below:

1. **Events expire.** An organizer is durable; an event is worthless the moment
   it has passed. Time is the primary axis and is currently absent from the UI.
2. **Events must be attributed to an organizer** and inherit a visibility
   ceiling from it (companion spec R4/R8). Attribution is not shown anywhere on
   this screen today.
3. **Two record kinds share one queue**: `source_result` in Incoming,
   `event_candidate` in every later stage. Their checks, decisions and columns
   differ.

## 14. Events-specific defects

| Defect | Evidence |
|---|---|
| **Stages overlap and double-count.** `verify` = candidates not approved; `resolve` = candidates needing attention. A candidate needing attention is *also* not approved, so it appears in both, inflating counts and resurfacing work already handled. Organizers uses exclusive `stageItems`; Events does not. | `eventIntakeWorkbench.tsx:95–100`, `206–222` |
| **Nothing checks whether the event has already happened.** `candidateChecks` verifies a date *exists*, never that it is in the future. An operator can spend an hour approving events that are already over. | `eventIntakeWorkbench.tsx:334` |
| **Editing leaves the workbench.** "Edit evidence" calls `openDiagnostics()`, which switches tab *and* drops the operator into the legacy 834-line tabbed screen. Mid-triage context loss. | `eventIntakeWorkbench.tsx:111–114, 252` |
| **Every decision posts the whole record as `edits`.** `edits: selected.value as unknown as Record<string, unknown>` is sent even when nothing was edited, making decision records unauditable — you cannot tell what a human actually changed. | `eventIntakeWorkbench.tsx:121` |
| **Duplicates are a checkbox, not an affordance.** `dedupe.duplicateCandidateIds` flips a check; there is no way to see, compare or resolve the duplicates. | `eventIntakeWorkbench.tsx:338` |
| **Borrowed Marketing shell.** `EventIntakeWorkspace.tsx` is 834 lines importing ~30 primitives including `AdminMarketingTabs`, `AdminMarketingPanel`, `AdminMarketingGrid`, `AdminMarketingTitleInput`. This is why Events looks unlike Organizers. | `EventIntakeWorkspace.tsx:1–65` |
| **`score` is decorative.** Rendered as `score 72` in meta text; sorts nothing, filters nothing. | `eventIntakeWorkbench.tsx:325, 360` |
| Selection reset and loading/empty conflation | `eventIntakeWorkbench.tsx:83–86`; `if (!bridge) return null` at `:88` with the parent's `EmptyState` doubling as the loading state |

## 15. Time as the primary axis

1. Add a **`When`** column: event start datetime plus a relative marker
   (`in 3d`, `tomorrow`, `passed 6d ago`). Default sort is soonest-upcoming
   first — the most perishable work first.
2. Add a check `event_has_not_passed` to `candidateChecks`. A passed event
   cannot be approved for import.
3. **Passed events are a terminal state, not a deletion.** Per companion spec
   R7 a passed event on an unclaimed entity stays reviewable, so route it to a
   `Passed` filter rather than dropping it from the queue. It must never sit in
   the active stages competing for attention.
4. Surface, do not recompute, expiry: the operations projection already carries
   `expiresAt` and reconcile already expires ended events. Read that.
5. Show **bridge provenance in the header**: which market, which reviewed run,
   generated when. Today `bridgeGeneratedAt` is buried in an impact row. Given
   that the Mumbai bridge is stale and Indore's is absent
   (`LAUNCH-SUPPLY-002`), a stale or missing bridge is a **first-class empty
   state with the market named** — never a silent zero.

## 16. Organizer attribution

1. Add an **`Organizer`** column showing the attributed organizer, or
   **`unattributed`** as a blocking value.
2. Unattributed events get a distinct treatment and a primary action that
   **creates an organizer discovery lead** from the event's host field
   (companion spec Phase C). This screen is where that product rule becomes
   visible.
3. Render the inherited ceiling honestly: when the attributed organizer is not
   app-visible, the event's app-visibility control is **disabled with that as
   its stated reason** (per §6, a disabled control always states its gate). Do
   not hide the control and do not let the operator exceed the ceiling.

## 17. Queue columns

Stage determines record kind, so the column set switches with the stage rather
than trying to be universal.

- **Incoming** (`source_result`):
  `[✓] · Title · Source/platform · Observed · Risk flags · Top blocker · Status`
- **Verify / Resolve / Ready** (`event_candidate`):
  `[✓] · Title · When · Organizer · Venue/neighborhood · Source · Top blocker · Status`

`Top blocker` carries the same contract as §3: the single reason this row is not
done, in plain text, so most rows never need the inspector.

## 18. Stages, batch actions, and editing

1. **Make the four stages mutually exclusive**, matching Organizers: Incoming =
   source leads; Verify = candidate with no blockers awaiting decision; Resolve
   = candidate with blockers; Ready = approved. A record appears in exactly one.
2. Events-specific bulk actions, in addition to §6's: *approve all
   source-backed and future-dated*, *reject all passed*, *hold all missing
   source*. Each reports its skipped remainder.
3. **Editing happens in the inspector**, never by navigating away. Remove the
   `openDiagnostics()` jump from the edit affordance.
4. **Send only changed fields** in `edits`, with before/after values. This is
   not cosmetic: companion spec Phase F uses field-level corrections as the
   training signal for extractor rule proposals, and a payload that always
   contains the entire record makes that signal unusable. Fixing this here is a
   prerequisite for the self-improving loop.
5. Duplicates get a real affordance: from a flagged candidate, view the
   duplicate set side by side and keep one / drop the rest as a single action.
6. Either make `score` a sortable column with a documented meaning, or delete
   it.

## 19. Structural cleanup

1. Migrate Events onto the same intake primitives as Organizers; drop the
   `AdminMarketing*` borrowings. Marketing packaging and intake review are
   different jobs and should stop sharing a shell.
2. Split `EventIntakeWorkspace.tsx` (834 lines) to satisfy
   `web:admin-feature-ui-size`; the legacy Crawl setup / Source inbox / Event
   candidates tabs become inspector sections or Diagnostics content, not a
   parallel UI.
3. After migration there must be **one** Events UI. Two parallel screens bridged
   by `setActiveTab` is the current state and must not survive.

## 20. Verification (extends §12)

Additional required tests:

1. Each candidate appears in exactly one stage; stage counts sum to the total
   with no double counting.
2. A passed event fails `event_has_not_passed`, cannot be approved, and is
   routed to `Passed` rather than an active stage.
3. Default sort is soonest-upcoming; passed events never sort above upcoming
   ones in an active stage.
4. An unattributed event blocks approval and offers organizer-lead creation.
5. An event whose organizer is not app-visible has its app-visibility control
   disabled with the ceiling stated.
6. A decision payload contains only changed fields with before/after values.
7. A missing or stale market bridge renders a named empty state, distinct from
   "no results".
8. No `AdminMarketing*` primitive is imported by an intake feature file.

Acceptance for Part II: **an operator can clear a week of event leads for one
market in a sitting — sorted by urgency, never approving something already
past, always seeing which organizer an event belongs to — without leaving the
table for records that carry no blocker.**
