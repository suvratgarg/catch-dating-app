---
doc_id: harness_v2_decision_and_cicd_delivery_plan
version: 0.3.3
updated: 2026-08-06
owner: agent_operating_model
status: execution-in-progress
---

# Harness v2 Decision + CI/CD Delivery Plan (Fable response)

This is Fable's response to
`docs/plans/agent_harness_rearchitecture_fable_review.md`, combined with the
owner's delivery asks (TestFlight automation, affected-only CI, safe
rules/index deployment, website deployment). Both documents retire when the
punch list below is executed; neither becomes a permanent layer.

**Owner decisions were locked on 2026-08-06 (§6). Codex executes the code-owned
work from this spec; Fable reviews the PRs. `[OWNER]` items are console or
GitHub-settings actions only the owner can perform.** Production cutovers are
gated, but owner-only actions do not block development and shadow validation of
later code-owned work.

## 0. Execution amendment after Codex review

The 2026-08-06 implementation review accepted the diagnosis but found that
v0.2 optimized the existing path router without actually creating the accepted
Harness v2 component model. It also found unsafe ambiguity around generator
selection, evidence retirement, exact-artifact deployment, environment
readiness, and rollback. Version 0.3 makes the following corrections binding:

1. A thin directional component graph is the first implementation artifact.
   Local affected checks, CI planning, generation planning, and deployment
   planning must consume that graph or projections generated from it.
2. Harness v1 remains active while v2 runs in shadow. Required checks do not
   switch until replay fixtures show that v2 is never narrower on high-risk
   changes and the owner has enabled the merge queue.
3. `role: generator` is not a PR-safe contract. Compile code generation uses a
   new deny-by-default declaration with explicit inputs, outputs, check command,
   determinism, platform, and `network: false`.
4. `docs/audit_registry` is classified file by file. Derived evidence leaves
   trunk; authored rules, baselines, and decisions move to named owners before
   the directory is retired. No bulk deletion occurs while active consumers
   remain.
5. GitHub is the receipt and artifact store, but a successful workflow for a
   SHA is not treated as proof of independently rebuilt bytes. Deploy jobs use
   the exact triggering SHA and checksum-bound deployment artifacts where the
   platform permits it.
6. Environment readiness runs before expensive deployment validation. Declared
   secrets, parameters, APIs, IAM, TTL policies, and other feature prerequisites
   fail fast without printing secret values.
7. Resume and rollback are separate contracts. A retry command is not called a
   rollback, and partial production state is reported explicitly.
8. The minimal worktree wrapper is a Phase 1 deliverable. Heartbeats and a
   distributed lease service remain deferred.

The implementation starts with foundations and measurement. It does not delete
v1 safety mechanisms merely to make the first PR smaller.

## 1. Verdict on the review brief

**Accept the diagnosis and the target architecture. Reject the program
structure. Execute as a short ordered punch list, not a 48-hour incident with
four parallel streams.**

Every measurable claim was independently re-verified on 2026-08-06:

| Claim | Verified |
|---|---|
| Audit registry ≈382,694 lines | Exact match |
| 68 of last 73 commits touch `docs/audit_registry` | Exact match |
| Planner is order-dependent (first match wins) | `tool/ci/plan_ci.mjs:99` uses `.find()` |
| `lib/**` selects all builds + functions + visual | `shared-flutter-source` rule in `tool/repository_root_manifest.json` |
| Test suite runs twice per Flutter PR | 4 shards + full serial `--concurrency=1` coverage rerun in `flutter-ci.yml` |
| Deployment re-runs validation | `firebase-dev-deploy.yml` reruns lint/tests/rules; `firebase.json` predeploy reruns lint+build again |
| No deploy stage checkpoint/resume | `tool/deploy_firebase_targets.sh` is a plain sequential loop |
| 36 worktrees / ~24 GB / 123 branches | Exact match |
| Debug token in local agent config | `FIREBASE_APP_CHECK_DEBUG_TOKEN=…` inside `.claude/settings.local.json` `permissions.allow` |

Findings the brief under-weighted or missed:

1. **Merge queue is OFF.** `ci.yml` handles `merge_group`, but the repo has no
   merge queue and branch protection has `strict: true`. Every merge to main
   (68/73 of which were registry churn) invalidates every open PR and forces a
   manual update + full re-run. This multiplies the registry problem and is a
   ten-minute settings fix.
2. **Websites validate twice and never consume CI.** On a main push,
   `react-surface-validation` runs inside CI *and* again inside
   `admin-website.yml` / `marketing-website.yml` before deploy (~25 min × 2
   surfaces × 2 runs). The deploy then rebuilds the site a third time via
   `firebase.json` predeploy hooks.
3. **A docs edit runs six tool buckets**, each installing Flutter + npm +
   functions deps + ripgrep, because the `documentation` rule selects the
   `tools` target.
4. **The full-validation schedule is weekly**, not nightly, so the brief's
   "move heavy checks to nightly" needs the nightly to exist first.
5. **Mobile release and website deploys trigger on raw push**, not on CI
   success. For mobile this is acceptable (main only advances through Required
   CI), but it should be understood, not accidental.

## 2. Adjustments to the proposal

1. **Drop the program management.** No incident declaration, no streams A/B/C,
   no integrator role, no 48-hour clock. The real work is ~10 mechanical
   changes; ceremony recreates the disease being cured.
2. **Build the minimum viable worktree broker now.** A wrapper that refuses
   OS-temp paths, records task/base/stack parent, performs isolated installs
   (shared download caches, never shared `node_modules`), exposes
   `start`/`doctor`/`finish`, and offers `reap --dry-run` covers the observed
   harm. Heartbeats and distributed leases remain deferred.
3. **No external receipt store.** GitHub provides run history, artifacts, and
   environment approval history. Every promoted artifact still carries the
   source run id, full SHA, toolchain identity, and digest; deployment downloads
   that artifact rather than inferring equivalence from `workflow_run` alone.
4. **Consolidating to 4 entry workflows is cosmetic; do it last.** The cost
   drivers are routing and duplication, not YAML file count. Note each harness
   PR currently triggers `ci-control-plane` full validation — batch harness
   changes accordingly.
5. **Track two outcome metrics, plus temporary migration counters:** PR
   wall-clock (p50/p95) and escaped defects are durable. During cutover, job
   fan-out, runner-minutes, selected components, generator count, duplicate
   builds, and v1/v2 selection deltas are emitted in GitHub summaries/artifacts
   and expire with this plan.

## 3. Answers to the 18 requested decisions

1. **Registry out of trunk?** Yes. Archive (branch or release tarball), stop
   feature-branch writes, regenerate on demand / nightly as CI artifacts.
2. **Rules/regressions → tests or expiring waivers?** Yes. Mechanical first
   pass by Codex; whatever doesn't convert cleanly is archived with history
   preserved in Git, not kept active by default.
3. **Front matter as sole doc metadata?** Yes. `doc_versions.json` /
   `doc_summaries.json` retire; catalog generated in CI as an artifact.
4. **One directional component model?** Yes for local checks, CI, generation,
   build, and deploy selection. Component manifests declare owned paths,
   dependencies, `alsoAffects`, supported operations, and risk. GitHub
   environments continue to own approval semantics.
5. **Which generated sources stay tracked?** All compile-critical ones
   (schema bindings, callable validators, l10n outputs) stay tracked for
   review visibility and offline builds. One `generate --affected --check`
   command gates freshness from the safe compile-codegen allowlist and must
   include the admin callable-validator edge that caused the Cross Paths CI
   failure. A scheduled full-safe-codegen check catches graph omissions.
6. **Fresh-clone reproducibility?** CI is a fresh clone and passes today;
   generated diffs are already reviewable because outputs are tracked. Keep.
7. **Feature agents stop writing shared generated outputs?** Yes for derived
   evidence. No for compile-critical bindings belonging to the change (a
   schema PR carries its bindings; the aggregator proves completeness).
   Integration-owned regeneration needs a merge queue first; defer.
8. **48-hour cutover?** Direction approved; structure replaced by §4. The
   required-check swap itself is one branch-protection edit, reversible in
   minutes.
9. **High-risk allowlist:** Firestore/Storage rules emulator suite, contract
   freshness checks, functions payment/consent/auth tests, secret scanning,
   Storage IAM verification, mobile package identity verification. These never
   leave the required path for their trigger surfaces.
10. **Dynamic edges:** explicit `alsoAffects` declarations in component
    manifests (assets→both apps, dart-defines→builds, Firebase config→apps +
    backend), each with a selection fixture test. No runtime discovery. Path
    classification happens before edge expansion so terminal ordinary docs do
    not conflict with union composition; policy and runtime-content Markdown
    have explicit component owners.
11. **Stacked change sets:** no atomic multi-PR machinery. Merge queue
    ordering + PR base-branch stacking. The Cross Paths pattern (phase N+1
    branched off main while phase N unmerged) becomes: branch phase N+1 off
    the phase-N PR branch.
12. **Receipt retention:** GitHub run history + checksum-bound artifacts
    (14–90 days) + environment deployment log. Nothing external. The receipt
    identifies the exact source run and full SHA.
13. **Cross-agent leases:** not now (single owner). The worktree wrapper
    removes the two real hazards: temp paths and shared/symlinked installs.
14. **Crashed-lease recovery:** `reap --dry-run` inventory proving
    clean/merged/pushed status per worktree and branch; deletions only with
    owner acknowledgment of the report.
15. **Firebase partial-deploy grouping:** a change-specific deployment DAG
    orders index creation/readiness, Functions, callable/IAM smoke checks,
    Firestore rules, and Storage verification according to declared
    dependencies. Shared Function dependencies may select the whole Function
    group. Remote Config and index **deletions** remain manual-only; automation
    never uses `--force`.
16. **Nightly regression response:** nightly-red opens an incident with a
    candidate revert PR only after deterministic reproduction and last-green
    attribution. Infrastructure failures and flaky tests never auto-blame a
    commit range.
17. **What prevents harness v3 sprawl:** honestly — owner discipline plus two
    budgets: component manifests stay small (≈30 lines), and any new
    governance artifact must carry an expiry or a test that fails when stale.
    No mechanism substitutes for declining scope.
18. **Transient deploy failure resumes same artifact?** Yes: a full-SHA/source-
    run input, stage checkpoints in GitHub artifacts, idempotent postcondition
    checks, and a failure summary printing the exact first-incomplete-stage
    command. Rollback/roll-forward guidance is separate.

## 4. Execution punch list

`[OWNER]` = only the owner can do it (console/settings access). Everything
else is Codex-executable in ordinary PRs.

Execution constraints for Codex:

- Every `.github/**` or `tool/ci/**` change triggers the `ci-control-plane`
  full-validation rule. Batch workflow changes into as few PRs as each phase
  allows; do not split one phase's YAML edits across many PRs.
- Keep Harness v1 required and run v2 in shadow until the Phase 1 cutover gate.
  A smaller v2 selection is evidence to inspect, never automatic proof that v1
  was wasteful.
- Owner-only work gates production activation and required-check cutover, not
  code development, fixture replay, or shadow measurement.
- Phase 2 is instructions-first: agent-facing documents and skills stop
  mandating registry writes **before** any registry file is removed.
- Never reproduce the App Check debug token value in any file, log, commit
  message, or PR body — including this document's history.
- Never delete a worktree or branch without the Phase 4 dry-run report and
  explicit owner acknowledgment; honor the keep-refs from
  `docs/plans/reconciliation_recovery_audit_20260716.md`.
- Do not add new ledgers, scores, receipts-in-git, or tracking documents as
  part of executing this plan. Temporary migration measurements belong in job
  summaries and expiring CI artifacts.

### Phase 0 — preservation, baselines, and active blockers (same day)

| # | Action |
|---|---|
| 0.1 | `[OWNER]` Rotate the App Check debug token (Firebase console → App Check → manage debug tokens), then delete the allow-rule containing it from `.claude/settings.local.json`. It is an attestation-bypass credential sitting in plaintext. |
| 0.2 | `[OWNER]` Enable merge queue for `main` (GitHub → Settings → Rules). `ci.yml` already handles `merge_group`; queued PRs stop needing manual branch updates. |
| 0.3 | Add `artifacts/visual-actuals/` and `artifacts/visual-diffs/` to `.gitignore` (currently untracked noise in `git status`). |
| 0.4 | Capture the §5 baseline from the live planner, workflows, recent GitHub runs, generator manifest, audit-registry consumers, and worktree inventory. Emit future comparisons in GitHub summaries rather than committing metric ledgers. |
| 0.5 | Add a fail-fast environment-readiness checker backed by a checked manifest of required secret metadata, TTL policies, APIs, IAM, and parameters. It must not read or print secret values. `[OWNER]` provision distinct `CROSS_PATHS_SUGGESTION_SIGNING_KEY` values and the `crossPathsSuggestionExposures.expiresAt` TTL policy in dev/staging/prod before enabling the CD chain. |
| 0.6 | Create the nightly/main integration mode in shadow before any PR device-build coverage is removed. |

**Phase 0 development gate:** baseline recorded; the readiness checker proves a
known-missing prerequisite fails before installs/tests/deploy; nightly/main
shadow mode exists. **Cutover gate:** token rotated and absent from local agent
configuration; merge queue active on `main`; required Cross Paths secret
metadata and TTL policy ready in each target environment.

### Phase 1 — Harness v2 kernel and CI cost collapse (2–3 days)

| # | Action | Effect |
|---|---|---|
| 1.1 | Add a small versioned component schema and kernel. Components declare owned paths, `dependsOn`, `alsoAffects`, operations, risk, role, and safe codegen edges. | One directional model exists in code, not prose |
| 1.2 | Add `harness explain/check/generate --affected` and adapters that project current CI outputs. `--shadow` compares v1 and v2 selections without changing required jobs. | Local, CI, and codegen share explanations |
| 1.3 | Add explicit event modes: `pr`, `merge_group`, `main`, `nightly`, and `release`, with fixtures for presentation, contract, policy docs, ordinary docs, native, Firebase config, generated bindings, and unknown paths. | Coverage moves tiers deliberately |
| 1.4 | Classify terminal file kinds before union-expanding component edges. Ordinary docs use the cheap docs lane; `AGENTS.md`, skills, workflow manifests, and runtime content keep explicit owners. | No precedence hack or Markdown under-validation |
| 1.5 | Implement the minimum worktree wrapper: `start`, `doctor`, `finish`, and `reap --dry-run`; reject OS-temp paths, shared installed dependencies, missing base SHA, and unpushed unique work. | Parallel tasks fail safe before corrupting state |
| 1.6 | Add a deny-by-default compile-codegen manifest and `generate --affected --check`; include schema bindings, callable validators including admin, and l10n outputs. Full safe generation runs nightly. | No repair/deploy command can enter PR preflight |
| 1.7 | Put cheap deterministic source/codegen preflight ahead of expensive selected lanes. | Stale output stops runners before fan-out |
| 1.8 | Run Flutter test shards with `--coverage`, merge deterministic lcov artifacts, and delete the serial full-suite coverage rerun. | One suite execution instead of two |
| 1.9 | Split node-only tool buckets from Flutter-needing buckets and install only what each bucket uses. | Tool setup cost falls materially |
| 1.10 | After main/nightly coverage exists, route ordinary `lib/**` PRs to Flutter validation plus one affected-role dev web compile smoke; remove Functions, device builds, prod web, and visual integration unless an explicit edge selects them. Native/config paths retain platform builds. | Baseline six targets becomes two for an ordinary presentation edit |

**Phase 1 gate:** high-risk fixtures are never narrower than v1 without an
owner-reviewed reason; an ordinary presentation edit changes from six selected
targets to Flutter validation + affected-role web smoke; an ordinary doc edit
selects only the new docs lane; policy docs select policy validation; contract
changes still reach every declared consumer; unknown paths fail closed. Shadow
summaries report v1/v2 deltas for at least one real PR and one merge-group run.
Use wall-clock and runner-minutes—not literal GitHub job count—as the outcome.

### Phase 2 — evidence and instruction migration (2–3 days; instructions first)

| # | Action |
|---|---|
| 2.1 | Produce a machine-checked migration table for every `docs/audit_registry` file: `delete`, `replace-with-test`, `generated-artifact`, or `move-authored-state`, including every active consumer and successor path. |
| 2.2 | Update all instruction authorities first: `AGENTS.md`, `CLAUDE.md` if present, repo skills/manifests, installed Catch Codex skills, context-pack/readiness commands, and owner docs. Tiny Codex/Claude adapters invoke the same repo-owned CLI. |
| 2.3 | Implement the replacement front-matter/catalog/link/policy-doc checks before retiring `doc_versions.json`, `doc_summaries.json`, readiness scoring, or context-pack requirements. |
| 2.4 | Migrate regression ledger entries and active rules to focused tests, explicit component risk gates, or expiring waivers. Produce a one-time replacement report; do not silently archive privacy, payment, auth, storage, or deployment invariants. |
| 2.5 | Move authored architecture/design adoption state to its durable owner; publish regenerable inventories and snapshots as nightly/on-demand artifacts; then delete bounded batches only after active-reference count reaches zero. |
| 2.6 | Prune `widget_catalog.md` history; retire the eleven verified docs; fold durable agent workflow into a short entrypoint plus lifecycle commands. Preserve one short Harness v2 ADR after retiring both planning documents. |

Main-branch churn drops to product changes only; the merge queue rarely
requeues; PR staleness largely disappears.

**Phase 2 gate:** zero active tool/workflow/instruction references to removed
paths; fresh-clone gates pass; a stale-branch fixture cannot reintroduce retired
registries; two consecutive ordinary product PRs merge with zero registry,
receipt, or metric-file changes. Keep a manual v1 validation workflow and
rollback ref for seven days after cutover.

### Phase 3 — exact-SHA delivery and recovery (2–3 days)

| # | Action |
|---|---|
| 3.1 | Make environment readiness the first CD job and require declared secret metadata/version, TTL, APIs, IAM, parameters, and environment identity before dependency installation or tests. |
| 3.2 | Replace dev-only deploy with `firebase-cd.yml`: successful same-repository main CI at an exact SHA selects a change-specific DAG; dev and staging deploy automatically with health gates; prod waits in the reviewer-protected `prod` environment. |
| 3.3 | Use a receipt-gated CI deployment Firebase config without validation/build predeploy hooks. Retain the normal guarded `firebase.json` for local/manual deployment so unverified commands do not lose protection. |
| 3.4 | Wait for required new indexes to reach `READY`; deploy dependent Functions; sync callable invokers; run reachability/IAM/rules/Storage smoke checks; then promote. Persist stage checkpoints and postconditions as GitHub artifacts. |
| 3.5 | Resume accepts only a full commit SHA/source run that belongs to protected `main` and passed Required CI. It restarts the first incomplete idempotent stage. Define roll-forward/rollback behavior per Functions, rules, Storage, Hosting, indexes, data migrations, secrets, and TestFlight. |
| 3.6 | Websites trigger from successful trusted main CI, explicitly check out `workflow_run.head_sha`, replan that exact diff, and assert SHA equality. A protected production-build job validates production configuration, materializes production marketing data, builds once, uploads a digest-bound `dist`, and deploys it with no predeploy rebuild. Add sanitized, least-privilege marketing PR previews; fork PRs receive no credentials. |
| 3.7 | Host TestFlight automation updates the Host target, global release policy, checker, checker tests, and runbook. `[OWNER]` enable automatic distribution or workflow assignment for both internal groups. |
| 3.8 | Mobile keeps the main-push trigger for every affected-role merge. Preserve `cancel-in-progress: false` queued replacement semantics; isolate manual intent without allowing overlapping store mutations. For backend-coupled mobile changes, build early but gate TestFlight upload on successful production backend promotion and smoke proof. |
| 3.9 | `[OWNER]` Resolve Play Console access (`playInternalEvidence: play-console-blocked`). GCP publisher auth is ready; automation remains behind `GOOGLE_PLAY_UPLOAD_ENABLED`. |

**Phase 3 gate:** a backend merge fails fast on a seeded missing prerequisite;
after readiness it deploys dev → staging with health proof and queues exact-SHA
prod approval; a seeded stage failure resumes from the first incomplete
postcondition; a website merge deploys the checksum-bound production artifact
without rebuilding; a Host merge reaches its TestFlight group after coupled
backend gates; rollback/roll-forward commands are exercised in non-prod.

### Phase 4 — hygiene (background)

| # | Action |
|---|---|
| 4.1 | Worktree/branch reap: dry-run inventory proving merged/clean/pushed per item → owner ack → remove. Recovers ~24 GB; kills 42 dead upstreams + 26 stale backups. Respect the reconciliation-audit keep-refs. |
| 4.2 | Promote the Phase 0 nightly shadow to full validation. Nightly-red opens an incident; it opens a candidate revert PR only after deterministic reproduction and last-green attribution. |
| 4.3 | Dependabot: grouped weekly updates (root npm, functions npm, pub, GitHub Actions). |
| 4.4 | Nightly environment drift report: deployed Firestore/Storage rules + index list vs repo (Firebase management REST). Report-only. |
| 4.5 | Update `docs/release_operations.md` CD Policy and retain one short Harness v2 ADR; retire this document and the review brief. |

## 5. Measurement and course-correction contract

Temporary migration measurements are emitted per run and summarized after 10
ordinary product PRs. They are not committed as a new metrics product.

| Signal | 2026-08-06 baseline | Initial target |
|---|---:|---:|
| Ordinary Flutter presentation path | 6 CI targets, 16 active jobs, ≈88m47s runner time on the sampled run | 2 targets; ≤45 runner-minutes median |
| Ordinary documentation path | 2 targets, 11 jobs, 39m44s aggregate runner time and 17m42s wall-clock on sampled PR #138 | 1 docs lane; ≤3 jobs and <5 runner-minutes |
| Broad Cross Paths PRs (7-run sample) | 20m48s median / 38m24s p95 wall-clock; 145m19s median / 174m49s p95 runner time | ≥40% p95 wall-clock and ≥50% runner-time reduction after 10 comparable PRs |
| Flutter suite executions per PR | 2; serial coverage rerun median 14m44s | 1 |
| Website builds per affected main merge, per surface | 3 | 2 total: source validation + one deployable production build; 0 deploy rebuilds |
| Duplicate website validation on sampled merge | Admin 12m45s + 12m58s; Marketing 7m27s + 7m28s; ≈20m26s repeated validation before the Firebase rebuild | 0 repeated validation and 0 deploy rebuilds |
| Backend validation after already-green CI | workflow validation plus Firebase predeploy reruns; sampled missing-secret failure surfaced ≈2m21s into the job | deploy-specific readiness/smoke only; known missing prerequisite in <30s |
| Active entries labeled `role: generator` | 61, including remote/deploy commands | 0 implicitly trusted; only explicit affected compile-codegen entries |
| Audit registry | 382,694 lines; 68/73 recent commits touched it | 0 registry files in ordinary product PRs |
| Worktrees | 36 registered; one already prunable; ≈24 GB reported | no temp-path, prunable, unpushed-unique, or unowned worktrees after owner-approved reap |
| Latest backend deploy attempts | 2/2 failed after expensive validation on missing Cross Paths secret | missing declared prerequisites fail before expensive validation |

### Checkpoint 1 — shadow kernel (2026-08-06)

| Signal | First graph draft | Current shadow result |
|---|---:|---:|
| Tracked-path ownership | 3,485 / 7,294 (47.8%) | 7,305 / 7,305 (100%); 0 unknown, 0 ambiguous |
| Ordinary shared Flutter selection | 6 v1 targets | 2 v2 targets (−66.7%); v1 still authoritative |
| Host-only Flutter selection | 5 v1 targets | 2 v2 targets (−60%); v1 still authoritative |
| Authored contract selection | 7 v1 consumer targets | 7 v2 consumer targets; no deploy permission from affected edges |
| Explicit safe compile-codegen | 0 v2 declarations | 7 allowlisted declarations; full check suite 5.71s generator time / 10.1s command wall-clock, all passing locally |
| Kernel behavioral verification | No v2 suite | 30 / 30 focused tests passing, including fail-closed CLI, path ownership, affected edges, and disposable l10n freshness |
| Shadow event coverage | local PR explanation only | `pr`, `merge_group`, `main`, and nightly full modes; CI artifact/summary wiring added without changing fanout |

The 47.8% ownership draft was rejected before workflow wiring because a graph
that silently falls back for more than half the repository cannot support a
safe cutover. Reaching exact tracked-path ownership is a prerequisite, not a
reason to trust the operational edges: v1/v2 replay and the high-risk parity
gate remain outstanding.

### Checkpoint 2 — deployment readiness (2026-08-06)

| Signal | Baseline | Current result |
|---|---:|---:|
| Functions secret declaration coverage | No deploy-time source-of-truth reconciliation | 10 / 10 literal `defineSecret` declarations mapped to target-aware requirements |
| Cross Paths expiry prerequisite | Missing TTL discovered during/after deploy work | 1 / 1 declared TTL policy checked with the four owning Function targets |
| Failure position | Known missing secret surfaced ≈2m21s into the sampled deploy job | Authenticated broad-Functions probe itself fails in 12.10s locally and now precedes setup/install/validation work that consumed ≈128s (90.8%) of the sampled path; first GitHub end-to-end timing remains pending |
| Secret exposure surface | Ad hoc CLI inspection | 3 metadata-only `gcloud` command families; 0 payload-access commands; no apply mode |
| Behavioral verification | No dedicated suite | 17 / 17 focused readiness tests passing, including workflow-order, selector fail-closed, timeout, terminal-state, and payload-redaction guards |

The dev probe currently reports the Cross Paths signing secret and TTL policy
as not ready. That is expected environment truth, not a reason to weaken the
gate: deployment remains blocked until those prerequisites are deliberately
provisioned. The exact Cross Paths target probe returned that result in 4.47s;
the broader automatic Functions-deploy probe checked all 11 target-selected
prerequisites in 12.10s. GitHub checkout and OIDC timing will be measured on the
first shadow/preflight workflow run.

Durable outcomes are PR wall-clock p50/p95 and escaped defects. Record the
baseline from the ten most recent comparable PRs and compare after ten v2 PRs.
Course-correct when any of these occur:

- v2 omits a v1 high-risk check without an explicit reviewed edge decision;
- ordinary-PR p95 improves by less than 40% or runner-minutes by less than 50%;
- a skipped check causes an escaped defect within 14 days (restore the edge
  immediately, then refine ownership);
- affected codegen exceeds two minutes for an ordinary presentation edit or
  selects an unrelated generator;
- deploy readiness runs after dependency installation or repeats a known
  missing-prerequisite failure;
- component manifests exceed the ≈30-line budget because operational scripts,
  exceptions, or policy prose are being embedded in the graph.

## 6. Decisions (locked by owner, 2026-08-06)

1. **D1 — PR compile smoke: KEEP.** `lib/**` PRs compile one dev web debug
   build for the affected role(s); all device and prod-web builds move to
   main push + nightly after those tiers exist (punch item 1.10).
2. **D2 — prod backend deploys: AUTO-CHAINED WITH APPROVAL PAUSE.** dev →
   staging automatic after CI green; prod queues under the `prod` environment
   and waits for the owner's one-click approval (punch item 3.2).
3. **D3 — TestFlight cadence: EVERY AFFECTED-ROLE MERGE**, with pending-run
   replacement and no in-flight cancellation; backend-coupled uploads wait for
   production backend readiness (punch item 3.8).
4. **D4 — executor: CODEX EXECUTES ALL PHASES from this spec.** Fable reviews
   the PRs. `[OWNER]` items remain owner-only console/settings actions.
5. **D5 — migration: SHADOW BEFORE CUTOVER.** V1 remains the required path
   until v2 fixture/replay parity and merge-queue readiness pass.
6. **D6 — codegen: EXPLICIT SAFE AFFECTED SET.** Existing generator-role
   metadata is never interpreted as permission to run a command in PR CI.
7. **D7 — delivery: EXACT SHA + DIGESTED ARTIFACT.** `workflow_run` gates
   trust; it does not substitute for artifact identity, environment readiness,
   health gates, or rollback semantics.
8. **D8 — evidence retirement: CLASSIFY THEN DELETE.** Authored state moves to
   a durable owner and active consumers reach zero before derived evidence
   leaves trunk.

## 7. Explicitly not building now

- Worktree lease broker with heartbeats (wrapper + reap only).
- External receipt/artifact store; GitHub artifacts carry the required digest
  and provenance manifest.
- Atomic multi-change-set merge machinery.
- Any new dashboard, score, or metrics product.
- Untracking compile-critical generated source.
- Automation of Remote Config deploys or index deletions.
