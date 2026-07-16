# Reconciliation Recovery Audit — 2026-07-16

Full git-archaeology sweep of every branch and commit from 2026-07-01 through
2026-07-16, triggered by work lost during Codex's git operations. This is a
handoff document for Codex: Section 4 is the restore queue, Section 5 needs
owner judgment before acting, Section 6 is hands-off (active session owns it),
Section 8 is prevention, Section 9 is transferable improvements.

## Authoritative closeout — 2026-07-16

All audit items have a final disposition. The implementation tree audited for
loss is `fb42a1dcf7be83ae2250f35f9ef1fe5c0bb9ef2e` on
`codex/reconciliation-audit-closeout-20260716`. The only deferred behavior is
strict production event-location reads: the implementation and repair path are
ready, but activation is deliberately gated on repairing nine production data
blockers. The audit performed no production writes.

| Item | Final disposition | Durable proof |
|---|---|---|
| §0 preservation | Complete | Named preservation/recovery refs exist on origin; both dirty source worktrees also have immutable `backup/` branches. |
| §4.1 + §5.3 React lexicon | Complete — strict | Reusable React validation runs the strict cross-stack surface map for both web apps; component/controller/governance checks pass. |
| §4.2 primitives shim | Complete | The shadowing `website/src/shared/ui/primitives.tsx` shim is deleted; imports resolve the family-split directory and both web builds/Storybooks pass. |
| §4.3 governance docs | Complete | Claims were reconciled to current code, governed versions moved forward, and the monotonic doc-version ratchet passes. |
| §4.4 profile prompts | Complete | Profile edit shows completed prompts plus exactly the next slot; finalized field APIs and focused tests are retained. |
| §4.5 l10n orphans | Complete — zero debt | All 97 verified zero-reference catalog keys (including the obsolete Host operations keys) were removed; inventory now reports 2,774/2,774 used, zero orphans, and zero missing getters. |
| §5.1 event location | Handled — activation deferred | Nullable compatibility, map/list filtering, maps-search fallback, repeat prefill, and edit initialization are tested. Production dry-run: 272 scanned, 125 valid, 138 deterministic repairs, 9 blockers, 0 warnings, 0 writes. |
| §5.2 adaptive tabs | Complete | `CatchAdaptiveTabScaffold` owns keyboard-safe behavior and is adopted by consumer and Host shells with navigation/keyboard tests. |
| §5.4 bottom actions | Complete | `CatchBottomDock` no longer owns the rich CTA variant; `CatchBottomAction` is the canonical primary-action owner and contracts/tests were refreshed. |
| §5.5 residual merge risk | Complete | Four-tree audit classified 3,791 paths; all 1,173 exact discards have receipts and all 248 both-diverged paths have semantic reviews. Strict mode reports zero missing/invalid receipts. |
| §5.6 design context | Complete | Design-system exports were regenerated from current sources rather than restored from either historical side. |
| §8 prevention | Complete | Push/rerere defaults are enabled; preservation-before-rewrite, daily WIP, omnibus retirement, parent-owned integration, branch lifecycle, merge receipts, and no-shared-history-rewrite rules are in the operating model or enforced tooling. |
| §9 improvements | Complete | Reusable React CI, doc/l10n ratchets, merge auditor, legacy-mirror architecture guidance, React dependency graph, primitive-owned geometry checks, and anti-vacuity scanner tests are implemented. |

Immutable audit inputs:

- base: `c323772f334536ba62c6b4c49cac4251b8a069a1`
- ours: `6bec6517a9338e472f447114a17ff094dd6ffa5f`
- theirs: `a59af56625eb78f1153bd16b337c3cab7e20881e`
- merged implementation: `fb42a1dcf7be83ae2250f35f9ef1fe5c0bb9ef2e`

Machine-readable closeout evidence:

- `docs/audit_registry/reconciliation_merge_drop_report_20260716.json`
- `docs/audit_registry/reconciliation_discard_receipt_20260716.json`
- `docs/audit_registry/reconciliation_semantic_review_20260716.json`
- `docs/audit_registry/reconciliation_20260716.json`

The remaining sections are the historical forensic record that produced this
queue. Their branch names, HEAD values, and imperative wording describe the
pre-closeout snapshot; the table above is authoritative for current status.

Audit method: exact Git tree-entry comparison across base, ours, theirs, and
the immutable merged implementation. "Discarded" means the merged entry kept
one side byte-for-byte while the other side differed. Strict mode requires a
non-empty, category-exact receipt for every such path.

---

## 0. URGENT — do these before anything else

1. **Push every local-only branch.** None of the 2026-07-16 recovery branches
   exist on origin. A disk failure today loses the entire recovery again.
   Push at minimum:
   - `codex/full-reconciliation-20260716` (current branch, 23 commits past main)
   - `codex/reconciliation-backup-20260716-a59af566` / `codex/catch-platform-hardening-20260712`
     (local tip `a59af5662` holds the WIP snapshot `27bc0e3a6` — the single most
     valuable preservation commit; origin only has the older `0704ca480`)
   - `codex/full-reconciliation-isolated-20260716`, `codex/port-widget-pattern-core-20260716`,
     `codex/catch-app-reconciliation-20260716`, `codex/apps-architecture-fixes-20260716`
   - The widget family: `codex/widget-pattern-core-20260712`,
     `codex/widget-pattern-tests-20260712`, `codex/widget-pattern-widgetbook-20260712`,
     `codex/pwf-*-20260713`, `codex/widget-triage-{a,b}-20260712`, `codex/widget-dialog-r2-20260712`
2. **Do not delete or rebase `a59af5662` or `58bc22587`** until every item in
   Sections 4–5 is resolved. They are the only copies of the dropped content.
3. Stashes `stash@{0}` and `stash@{1}` (pre-recovery active work) are fully
   accounted for: 23/25 files live in the current working tree; the
   `catch_top_bar.dart` + test changes were committed. Keep them until the
   active host-app session lands, then drop.

---

## 1. What actually happened (mechanism)

1. **7-11 → 7-12**: `codex/catch-platform-hardening-20260712` was built as a
   long-running omnibus branch (dev-project pointing, marketing/deploy
   hardening, typography/copy contracts, website audit enforcement). On 7-12 it
   went through **five consecutive rebase/fixup cycles onto origin/main**
   (visible in the reflog), landing on main as PR #76 — but the local branch
   stayed alive.
2. **7-12 → 7-13**: The widget-pattern-family work was built on the same base
   (#77) across 8 sibling branches, integrated into
   `codex/widget-pattern-core-20260712` (`58bc22587`, "complete approved widget
   pattern families"). **Never PRed.**
3. **7-13 → 7-16**: Meanwhile main advanced 8 PRs (#78–#85): admin phone
   auth/account menu/console streamline, supply intake, and the profile
   field/section handoff saga. Several of these **re-derived work that also
   existed on the omnibus branch** (double application — supply intake from
   `ops-core`/`ops-backend`, field primitives from the WIP tree).
4. **7-16 morning**: The working tree — carrying ~4 days of uncommitted WIP —
   was snapshotted into `27bc0e3a6` ("chore(wip): preserve pending
   reconciliation snapshot") on the stale omnibus branch. This snapshot is what
   saved most of the work.
5. **7-16 afternoon**: Recovery: `catch-app-reconciliation` re-applied 8
   commits onto main; `full-reconciliation` merged the omnibus branch in
   (`c968699d8`), then patched known drops (`417eda3b9` typed tabs + website
   contracts, `1cec4f2f0` preserved widget behavior) and cherry-picked the
   widget-pattern port. The merge conflict resolution favored main's side in
   ~47 files where the branch had newer or unique content — those residual
   drops are Sections 4–5.

**Loss surface = the big merge + the manual port.** Everything merged to main
via PRs #67–#85 was verified intact (Section 7).

---

## 2. Current branch state (codex/full-reconciliation-20260716)

`HEAD = 1cec4f2f0`, 23 commits ahead of origin/main, containing:
- the full omnibus lineage via merge `c968699d8`
- re-applied canonical field/section work (`b3aa087a8`…`7a335c214`)
- the 3 app fixes (`a6e81a4ee` refunds-after-push-failures, `ec04ea8dc`
  explore-state-on-sign-out, `6bec6517a` hide-SDK-error-details)
- ops workflow engine cherry-picks (superseded by #81, harmless)
- events "defer strict location reads until repair" (`9790cdd7a`)
- widget-pattern port (`0b6b709d6`, `a59165165`, `b0ec57790`) + reconcile fix
  (`1cec4f2f0`) + typed-tabs/website restore (`417eda3b9`)

`codex/full-reconciliation-isolated-20260716` (`3a0dd8d40`) is a parallel
recovery attempt that differs from HEAD **only** in 11 events-domain files
(the strict-location model — see 5.1). Once 5.1 is resolved, delete it.

---

## 3. Branch-by-branch ledger (2026-07-01 → 07-16)

| Branch (tip) | Intent | Verdict |
|---|---|---|
| `claude/widget-consolidation-slice-1` (`f0064811a`, 126 commits: composition audit, WO-016…023 closeouts, analytics kit, CatchTabRail/CatchScrim/CatchCountBadge, onboarding step-state extraction, contract gating) | Widget consolidation slice 1 + composition audit | **MERGED** as PR #67 (squash). Signature artifacts verified in HEAD. Safe to delete after push. |
| `codex/worker-*-20260701` (10 branches, one widgetbook-state/adapter commit each) | Widgetbook state coverage workers | **INTEGRATED** into slice-1 lineage; residual diffs are later renames only. Safe to delete. |
| `codex/wo021-*`, `wo022-*`, `wo023-*` (9 branches) | WO work-order implementations | **INTEGRATED** (ledger closeout commits in slice-1 → #67). Safe to delete. |
| `codex/home-catches-unification` (`be3f6a757`) | Home+catches lifecycle unification | Core commit **MERGED** (main `4698d8848`); 2 extra commits were regenerable registry/context-pack refreshes. Safe to delete. |
| `codex/home-live-layer` (`e709c6457`) | Home live layer, club posts, splash fixes, club detail parity | **MERGED** as PR #68 + #71 lineage. Safe to delete. |
| `codex/host-app-live-operations` (`b262e64cf`) | Host app targets + live operations | **MERGED**, tree-identical to PR #71. Safe to delete. |
| `codex/automatic-prod-hosting` (local `987500d41`) | Hosting deploys (#72) + pre-rebase copies of omnibus commits | #72 **MERGED**; local extras superseded by the rebased omnibus branch. Safe to delete after omnibus is fully mined. |
| `codex/unified-mobile-release`, `mobile-release-signing-fix`, `mobile-release-export-signing-fix`, `release-live-state-sync` | Release standardization + signing (#73–#75, #77) | **MERGED**. Safe to delete. |
| `codex/catch-platform-hardening-20260712` (local `a59af5662` = origin `0704ca480` + WIP snapshot `27bc0e3a6` + test commit) | Omnibus: dev-project clients, marketing hardening, typography/copy contracts, website audit enforcement — plus 4 days of WIP | Committed part **MERGED** as #76; WIP snapshot only partially recovered → **Sections 4–5. KEEP.** |
| `codex/widget-triage-{a,b}`, `widget-dialog-r2`, `widget-pattern-widgetbook`, `widget-pattern-tests`, `pwf-{identity,compact-controls,progress-event-success}` | Widget pattern family workers (chips, badges, identity switcher, compact controls, progress cues, checker, registry schema) | **INTEGRATED** into `widget-pattern-core` (same-subject integration commits; shared residuals only). Keep until 4/5 resolved, then delete. |
| `codex/widget-pattern-core-20260712` (`58bc22587`) | Final "complete approved widget pattern families" | **PORTED** to HEAD via cherry-picks + reconcile fix; 36 discarded files audited (mostly the shared WIP surface). **KEEP** until Sections 4–5 resolved. |
| `codex/admin-phone-auth`, `admin-account-menu`, `admin-console-streamline` | Admin auth + console + shared web UI + visual baselines | **MERGED** (#78, #79, #80). Safe to delete. |
| `codex/ops-backend-20260714`, `ops-core-20260714` | Operations workflow contracts + intake engine | **MERGED** into #81 via cherry-picks (tree-verified). Safe to delete. |
| `codex/supply-intake-operations-platform` | Supply Intake platform | **MERGED**, tree-identical to #81. Safe to delete. |
| `codex/field-production-parity`, `profile-field-scroll-fix`, `apple-signing-repair`, `profile-field-final-consolidation` | Field/section handoff saga + iOS signing | **MERGED** (#82, #83, #84, #85; #85 tree-identical to branch tip). Safe to delete. |
| `codex/delegation-*` (5 branches), `codex/explore-map-implementation-20260713` | Delegation audit bookmarks | Pointer copies of `0704ca480` — no unique commits. Safe to delete. |
| Recovery branches (7-16): `primary-reconciliation` (=origin/main), `catch-app-reconciliation`, `apps-architecture-fixes`, `port-widget-pattern-core`, `full-reconciliation-isolated`, `reconciliation-backup-…` | Today's recovery | All content in HEAD except isolated's events files (5.1). Push first; delete after 4/5/6 resolved. |

Dangling commits (26): all May–June strays plus two 7-05 slice-1 WIP
snapshots; nothing in-window is unrecovered. Stashes 2–13 predate the window
(May–June "codex-preserve-*"); review separately before any `stash clear`.

---

## 4. CONFIRMED DROPS — restore queue for Codex

Ordered by value. For each: source of truth is the omnibus tip `a59af5662`
unless noted. Restore = re-apply from that tree, then run the named checks.

### 4.1 Marketing website lost component-lexicon enforcement — BLOCKED BY 5.3
`.github/workflows/marketing-website.yml` on HEAD has **no**
"Check cross-stack component lexicon" step; the branch version runs
`node tool/design/check_component_lexicon.mjs` and adds path triggers for
`tool/design/check_component_lexicon{,.test}.mjs`, `design/components/**`,
`tool/web/check_react_controller_test_targets.mjs`,
`tool/web/react_controller_test_targets.json`. The admin workflow on HEAD has
lexicon enforcement; marketing regressed to none. Restore the step + triggers
(keep HEAD's `check_storybook_visuals.mjs` trigger and ubuntu-24.04/visual
baseline machinery — that side is newer and correct).

Execution finding: do not restore the blocking lexicon step in isolation.
`a59af5662` also carries the companion fully populated component surface map;
without it, the checked command already fails on both clean HEAD and clean
origin/main. Resolve §5.3, reconcile the component contract, then restore the
step and its lexicon/design path triggers atomically.

### 4.2 Website primitives compatibility shim deletion was dropped — COMPLETE
The preserved WIP commit replaced the original 4,977-line
`website/src/shared/ui/primitives.tsx` monolith with the family-split
`website/src/shared/ui/primitives/` directory and deleted the old file. Current
HEAD already contained the split modules and a one-line compatibility export,
`export * from "./primitives/index";`. The initial audit therefore overstated
the live impact: the split directory was not dead code. The remaining dropped
intent was deletion of that shadowing compatibility shim so extensionless
imports resolve the byte-identical directory index directly. The shim is now
deleted and the website typecheck/build/Storybook, shared-UI adoption, import
boundaries, UI primitive, component-governance, route, and component checks
all pass.

### 4.3 Seven governance docs regressed to older versions
The merge kept main's older copies. Branch versions are strictly newer
(higher `version:` frontmatter) and document mechanisms that DO exist in HEAD
(verified: `tool/architecture/provider_graph.dart`, `tool/widget_cleanup_scan.sh`,
`tool/audit/widget_cleanup_baseline.json`, `design:fields:inventory:check`,
`contracts/migrations/event_meeting_location.json`, host-preview retirement):

| Doc | HEAD | Branch | Branch adds |
|---|---|---|---|
| `AGENTS.md` | 1.4.1 | 1.4.7 | React-web routing row with `web:shared-ui-adoption`, `web:react-controller-test-targets`, `web:admin-feature-ui-size`, `web:admin-bundle-budget`, `web:admin-storybook-bundle-budget` loops |
| `docs/README.md` | 4.5.5 | 4.6.0 | provider-graph reference; `plans/repository_root_hygiene_spec.md` row |
| `docs/release_operations.md` | 1.9.6 | 1.10.1 | **"Local Firebase Safety" section** (catchdates-dev default, wrapper-only remote commands, hosting-target guard, toolchain consistency) |
| `docs/backend_operation_catalog.md` | 1.2.13 | 1.2.14 | P0 event-location row (146/146 dev corpus, 9 prod blockers receipt), createEvent/updateEvent/selfCheckIn strict-location semantics, **"createEvent must not consult payout account — free event creation stays available"** product decision |
| `docs/marketing_website_architecture.md` | 0.4.162 | 0.4.166 | HEAD doc is stale vs HEAD **code**: still describes `HostPreviewPage.tsx`/`HostPreviewMain`, which are deleted; branch documents single canonical host route + `/host/preview` permanent redirect, choice chips/cards adoption |
| `docs/audit_registry/README.md` | 2.6.5 | 2.6.7 | `design:fields:inventory:check` usage; widget-cleanup ratchet semantics |
| `tool/README.md` | — | — | Riverpod provider-graph section (`--write/--check/--summary`), cleanup-ratchet semantics, drift-helper diagnostic-code note |

Restore branch versions, re-verify each claim against current code first
(especially backend catalog vs the 5.1 deferral — document the deferred state,
not the aspirational one), and bump versions/registry entries per governance.

### 4.4 Progressive prompt-slot disclosure dropped from profile edit
Branch `profile_tab.dart` renders `visiblePromptSlots` = completed prompts +
exactly the next slot; HEAD renders all slots. Also broader
`allowEmptySingleSelection` adoption (17 refs vs HEAD 3) and
`emptyValueText`-based display values in inline editors. The port commits
(`b3aa087a8`, `300581203`) carried most inline-editor work but not these.
Diff `a59af5662` vs HEAD across `lib/user_profile/presentation/widgets/` and
restore the intended behaviors (confirm against #85's finalized field API —
mechanical re-apply will not compile unchanged).

### 4.5 Orphaned l10n keys
`hostsHostOperationsTopBarTextKickerTitle` (+ generated accessors) survive in
`lib/l10n/` though `HostOperationsTopBar` was deleted. Sweep for l10n keys with
zero non-l10n references and prune (coordinate with the active host session,
which owns `lib/l10n/app_en.arb` edits right now).

---

## 5. JUDGMENT REQUIRED — owner decision before restoring

### 5.1 Strict event meeting-location domain model (ACTIVE AREA)
The omnibus/isolated branches made `Event.meetingLocation`/lat/lng **required**
with normalization-on-read, fail-closed validation, and legacy-mirror
promotion (`_normalizedEventJson`); HEAD deliberately deferred this
(`9790cdd7a` "defer strict location reads until repair" — production has 9
coordinate-less legacy events per
`contracts/migrations/event_meeting_location.json`). The working tree is
actively rebuilding this area. **Do not restore blindly.** Decision: keep the
deferral until prod repair completes, then adopt the strict model from
`a59af5662` (or `3a0dd8d40`, which differs from HEAD in exactly these 11
files). The strict implementation is complete and tested on those branches —
that's the hard-fought part; don't rewrite it from scratch.

### 5.2 CatchAdaptiveTabScaffold shell adoption (half-shipped)
HEAD ships the scaffold file, spec (`docs/design_parity/adaptive_tab_bar_spec.md`),
tests, and widgetbook entries — but `app_shell.dart`/`host_app_shell.dart`
don't use it (adoption existed only in the WIP snapshot; the merge kept main's
shells). Complication: #84 (7-15) added keyboard-visibility handling to the
shells, and the scaffold has **no keyboard-inset logic** — the WIP adoption
would regress #84. Decision: either (a) finish the redesign — add keyboard
handling to `CatchAdaptiveTabScaffold`, then adopt in both shells per the WIP
diff — or (b) retire it and delete the orphaned scaffold/tests/widgetbook
entries. Current half-state is the worst option.

### 5.3 `docs/design_language.md` surfaces-map strictness
HEAD (1.5.1, 7-14): surfaces map is "incremental… unmapped families remain
valid". Branch (1.5.2): "every declared symbol must exist". These are
*conflicting deliberate edits* — binding lexicon was the stated goal, but #80
may have relaxed it intentionally to land. Owner picks; then align
`check_component_lexicon.mjs` behavior and doc version.

### 5.4 CatchBottomDock CTA-variant removal
The WIP tree removed `CatchBottomDock.cta` (rich API: catchLine, footnote,
accent) in favor of plain-child composition; HEAD keeps the CTA variant with
live call sites in tests/widgetbook. No ratified decision found in
`widget_consolidation/decisions.json` (which the active session is editing).
Route through the widget-consolidation decision process rather than restoring.

### 5.5 Residual risk in 210 hand-merged files
Files where branch, main, and HEAD all differ were hand-merged; partial drops
can hide there (that's exactly where `1cec4f2f0` already had to patch four).
Highest-churn candidates NOT owned by the active session:
`lib/events/presentation/widgets/event_pins_map.dart` (WIP camera-follow logic
vs HEAD's), `lib/event_success/presentation/event_success_structure_config_editor.dart`,
`event_success_setup_body.dart`, `lib/hosts/presentation/event_management/widgets/event_policy_step.dart`,
`club_host_defaults_step.dart`, `lib/core/widgets/catch_section_layout.dart`,
`lib/events/shared/event_tiles/event_date_rail_card.dart`, `create_club_screen.dart`,
`lib/user_analytics/shared/user_analytics_panel.dart`. Recipe:

```sh
# For each suspect file, view what the preserved branch had that HEAD lacks:
git diff HEAD a59af5662 -- <file>        # '+' lines = branch-only
git diff HEAD 58bc22587 -- <file>        # widget-pattern variant
# Classify a whole tree in one pass (the method used for this audit):
# blob(HEAD)==blob(main) while blob(branch)!=blob(main)  => branch side discarded
```

### 5.6 design_context_pack exports
`design_context_pack/design_system/{design_language.txt,typography.json}`
diverged on both sides. Regenerate from the design-system source of truth
instead of restoring either side.

---

## 6. HANDS OFF — active session owns these (2026-07-16)

The working tree has ~48 dirty files. Do not "restore" over them:
- `lib/events/` location links, `event_location_map_*`, `event_map_view_model`
- `lib/explore/presentation/explore_map_screen.dart`
- `lib/hosts/` host_operations (`host_clubs_scaffold`, `host_organizer`,
  `host_club_profile`), `edit_hosted_event_screen`, payments card,
  team management, payout-prompt deletion, `create_event_prefill`
- `lib/l10n/*` and `docs/audit_registry/*`, `docs/widget_catalog.md`,
  `docs/generated/provider_graph/*`, `widget_consolidation/decisions.json`
- deleted: `host_organizer_payout_prompt{,_controller}.dart` (intentional)
- `tool/design/check_section_headers.mjs` (+118 lines, from stash@{0}, live)

---

## 7. Verified NOT lost (no action)

- PRs #67–#85 all tree-verified against their source branches (squash merges
  complete; #85 byte-identical to `profile-field-final-consolidation` tip).
- `firestore.rules`: HEAD is strictly newer (operations deny-alls from #81).
- Visual-baseline reorg: the 161 `design/visual_baselines/**` files "deleted"
  vs the branch were re-scoped to `<surface>/<platform>/` (HEAD has 1512
  baseline files); 259 `artifacts/visual-diffs/**` were transient captures.
- Admin controller/intake test tweaks: HEAD versions are newer supersets.
- `tools-ci.yml`, `check_website_components.mjs`, `check_storybook_visuals.mjs`,
  `catch_text_styles.dart`, `catch_form_field_label.dart`: branch copies were
  stale pre-PR states (blob-matched to older main commits).
- Analytics kit, CatchTabRail/Scrim/CountBadge, composition-audit doctrine,
  onboarding step states: all present in HEAD.
- Stashes 0/1 and both July dangling commits: accounted for.

---

## 8. Preventing this from happening again

The failure was compound: **omnibus branch + double application + 4 days of
uncommitted WIP + repeated rebases + big-bang merge + everything local-only.**
Each has a cheap guard:

1. **Push on branch creation, always.** `git config --global push.autoSetupRemote true`.
   A branch that exists only on one disk is not preserved. (Today: zero of the
   recovery branches are on origin.)
2. **Kill omnibus branches at slice time.** The moment work from a
   long-running branch is re-derived into a PR, the omnibus must be rebased
   onto the merged result the same day — or frozen read-only under
   `backup/`. Never let the same change exist as both "branch content" and
   "re-derived PR" for days; that is what made this merge unresolvable.
3. **Daily WIP commits.** The `chore(wip)` snapshot saved this incident —
   formalize it: any agent session that ends with a dirty tree commits to the
   session branch (never relies on the working tree surviving).
4. **Snapshot ref before destructive ops.** Before any
   rebase/reset/merge-with-conflicts, `git branch backup/<branch>-<date>`
   (Codex did this once — `reconciliation-backup-20260716-a59af566` — make it
   unconditional). Consider `git config rerere.enabled true` so repeated
   conflict resolutions stay consistent across the retry loops seen on 7-12.
5. **Audit every reconciliation merge mechanically.** Check in the method used
   here as `tool/git/audit_merge_drops.mjs`: given (base, ours, theirs,
   merged), list every file where merged==ours while theirs≠ours (theirs
   discarded) and vice versa; require an explicit receipt for each discarded
   file. This audit found all of Section 4 in minutes; make it a required
   post-merge step for any merge touching >50 files.
6. **Doc-version monotonic ratchet.** All seven Section-4.3 regressions were
   detectable as `version:` decreases in governed docs. Add a check (the
   audit registry already tracks `doc_versions.json`): a PR/merge may never
   *decrease* a governed doc's version. This repo already loves ratchets —
   this is the same pattern pointed at docs.
7. **Delete branches after squash-merge** (`gh pr merge --delete-branch`,
   `git fetch --prune`). 40+ stale branches made this audit harder and invite
   "which copy is real?" mistakes.
8. **No history rewrites on shared branches** for agents: Codex should treat
   rebase/amend/reset --hard as requiring an explicit snapshot ref first
   (rule 4) and never rewrite a branch that has an origin counterpart.

---

## 9. Cross-codebase improvement opportunities (spotted during audit)

1. **Unify the two React CI workflows.** `admin-website.yml` and
   `marketing-website.yml` drifted (lexicon check present in one, visual
   baselines in the other — Section 4.1 is a symptom). Extract a reusable
   workflow (`workflow_call`) parameterized by surface; drift becomes
   impossible.
2. **Doc-version ratchet** (Section 8.6) — generalize
   `tool/widget_cleanup_scan.sh`'s baseline-compare pattern ("reductions pass,
   increases fail") to doc versions and to **orphaned l10n keys** (Section
   4.5): generate key-usage inventory, baseline it, fail on new orphans.
3. **Merge-drop auditor as a checked-in tool** (Section 8.5) — the three-way
   blob classifier generalizes to any future reconciliation.
4. **Legacy-mirror normalization pattern.** `Event._normalizedEventJson`
   (promote structured field from legacy scalar mirrors at read time, then
   fail closed) is the cleanest Firestore migration-read pattern in the repo.
   When 5.1 lands, document it in `app_architecture.md` and apply to other
   models carrying legacy mirrors (e.g. `RunClub` next-event fields,
   `Payment` legacy fields) instead of ad-hoc `??` fallbacks.
5. **Provider-graph equivalent for the React side.** The Dart provider-graph
   generator (`tool/architecture/provider_graph.dart --check`) proved its
   worth; the web hardening audit found feature monoliths that an
   import-graph/feature-dependency generator for `website/`+`admin/` would
   have surfaced earlier. Same durable-artifact + `--check` shape.
6. **Geometry-owned-by-primitive doctrine.** `CatchTopBarActionGroup`
   (stash-recovered, now committed) encodes "callers cannot compose their own
   header Row" — same containment doctrine as the composition audit. Candidate
   next targets: bottom-dock action strips and section-header trailing actions,
   where ad-hoc Rows still exist.
7. **Anti-vacuity harnesses for web checks.** `tool/check_catch_ui_lints.sh`
   seeds probes to prove every lint fires. The website contract checks
   (`check_website_routes.mjs`, `check_component_lexicon.mjs`,
   `check_website_copy*`) have no equivalent — a seeded-fixture test per check
   would have caught the 4.1 regression (a check that silently stopped
   running).

---

## 10. Suggested execution order for Codex

1. §0 pushes (named preservation set complete).
2. §4.2 compatibility-shim deletion (complete); defer §4.1 until §5.3 and the
   component surface contract are resolved atomically.
3. §4.3 doc restores (verify claims against code as you go).
4. §4.4 profile behaviors (after confirming with owner they're wanted post-#85).
5. §5 items — one owner decision each; 5.1 waits for the active session.
6. §5.5 residual sweep with the recipe.
7. Branch cleanup per §3 ledger (only after 1–6 complete).
8. §8/§9 tooling as follow-up work orders.
