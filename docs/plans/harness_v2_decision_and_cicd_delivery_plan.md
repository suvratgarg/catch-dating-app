---
doc_id: harness_v2_decision_and_cicd_delivery_plan
version: 0.3.34
updated: 2026-08-07
owner: agent_operating_model
status: execution-in-progress
---

# Harness v2 Decision + CI/CD Delivery Plan (Fable response)

This execution plan consolidates Fable's accepted Harness review with the
owner's delivery asks (TestFlight automation, affected-only CI, safe
rules/index deployment, website deployment). The superseded 973-line review
brief was retired on 2026-08-06 after its decisions and evidence were preserved
here. This plan retires when the punch list below is executed; it does not
become a permanent layer.

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
| Retired planner was order-dependent (first match won) | Verified at the pre-cutover baseline before deletion |
| `lib/**` selected all builds + functions + visual | Verified from the retired pre-cutover routing table |
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
| 2.6 | Prune `widget_catalog.md` history; retire the eleven verified docs; fold durable agent workflow into a short entrypoint plus lifecycle commands. Preserve one short Harness v2 ADR after retiring this execution plan. |

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
| 4.5 | Update `docs/release_operations.md` CD Policy and retain one short Harness v2 ADR; retire this execution plan. |

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

This is the first environment-readiness tranche, not completion of items 0.5
or 3.1. API enablement, deploy/runtime IAM, required parameters, deployed
revision-to-secret binding, distinct signing-key material, and post-deploy
health still need explicit probes or provisioning receipts. None may be
inferred from an enabled secret version or an active TTL policy.

### Checkpoint 3 — first measured transition rehearsal (2026-08-06)

| Signal | First attempt | Current result |
|---|---|---|
| Isolated checkout | Full worktree checkout failed after 2.31s at 44% with `No space left on device`; only 197 MiB remained and existing repo worktrees occupied about 24 GB | Removed only the ignored, reproducible 1.4 GB root `build/` cache; no source or other worktree was removed. Sparse checkout materialized 39 MB in 0.37s, then 64 MB after selected-check dependencies were added in 0.57s |
| Remote preservation | Sandboxed push failed DNS resolution in 0.05s | Approved network push created the preservation branch in 2.00s; the first bounded commit pushed in 2.30s |
| Harness check execution | A selected `check --affected` path referenced undefined `result.status` and could throw after the child check completed | CLI now propagates `execution.status`; injected failure and repository-level execution are covered; 30 / 30 focused Harness tests passed in 0.77s |
| First bounded commit | No measured integration unit | `41c407ce5` changed two files (+41/−4), committed in 0.04s, and was pushed before the deletion tranche |
| Duplicate plan surface | Two temporary plans totaling 1,391 lines | Accepted review brief retired (973 deleted lines); this execution plan remains until its punch list is closed |

Issues discovered during the rehearsal:

- `H2-TRANSITION-001` — worktree creation has no disk-space or materialization
  budget. `harness task start` must preflight capacity and either create a
  scope-appropriate sparse checkout or refuse before a partial checkout. The
  integration rehearsal reproduced the failure at 71% after 3.20s with only
  268 MiB free; the equivalent bounded worktree materialized 699 files / 26 MB
  in about 0.3s. A focused test later reproduced the same failure while trying
  to create a redundant full fixture checkout.
- `H2-TRANSITION-002` — a selected `tool/run.mjs check <id>` validates path
  existence for every manifest entry. Sparse tasks therefore need unrelated
  source directories, while doc-version and root-hygiene gates treat
  unmaterialized paths as deletions. Task setup must materialize the declared
  validation closure; separate global integrity validation from selected-check
  execution while keeping the full gates required in CI.
- `H2-TRANSITION-003` — managed-environment access failed before product
  verification: sandboxed push DNS resolution failed in 0.05s, Dart SDK-cache
  access failed in 0.04s, and a shared-worktree Git commit failed on
  `index.lock` in 0.01s. Approved reruns succeeded; the measured commit itself
  took 0.05s. Receipts must record initial and approved timings separately and
  classify Git metadata, network, and SDK access failures as environment
  constraints rather than product regressions.
- `H2-TRANSITION-004` — the current audit stamp snapshots global dirty
  documentation state, so a Harness-only pass attempted to absorb an unrelated
  organizer-document version. The contaminated registry update was not
  committed. The ten-commit integration rehearsal then stopped twice on four
  path-level conflicts in the shared audit ledgers (`agent_metrics.jsonl` and
  `passes.jsonl` once each; generated `files.jsonl` twice). Phase 2 must replace
  global snapshot stamping with scoped, immutable CI evidence before ordinary
  parallel work can be pleasant.
- `H2-TRANSITION-005` — the audit registry treated sparse disk materialization
  as repository truth. `File.existsSync` filtering attempted to shrink
  `files.jsonl` from 7,232 to 3,570 rows; an unmaterialized policy manifest
  could fall back to `{}` and erase metadata from 2,483 aggregate rows; and
  `mark-pass` reported success while silently skipping new paths. The affected-
  tools tranche now reads tracked paths and sparse-omitted required JSON from
  the Git index, rejects unresolved stages and missing/malformed policy,
  validates pass scope, rejects unknown refresh options, and provides exact
  `refresh --check` parity. Four focused tests and 7,236-entry parity passed.
- `H2-TRANSITION-006` — squash-only integration was not represented in task
  metadata. A tree-equivalent stacked branch produced historical conflicts
  after its parent squash; replaying the reviewed refinement from integrated
  `main` took 0.07s without conflict and produced the identical tree. Tasks
  must record integration method and integrated base tree; after a squash,
  replay reviewed commits from integrated `main` instead of merging the
  historical stack. The clean replacement chain replayed the lifecycle,
  deletion, and evidence commits in 0.06s, 0.10s, and 0.17s respectively with
  no conflicts, but each parent squash still required its child to be replayed
  again from integrated `main`: deletion took 0.17s and the final three-commit
  evidence replay took 0.33s. The protocol keeps integration safe; it does not
  remove the coordination tax. Dependent squash-only PRs should be serialized,
  or an explicit stack tool must automatically restack descendants.
  The complete checkout/snapshot/setup stack was subsequently replayed twice:
  both the pushed branch and detached rerere replay produced tree
  `92a5c9b6e1122c74ffd3a902fafc46731b8f8a7d` with zero diff. Rerere restored
  only the reviewed ledger resolutions; explicit staging and continuation
  remained required.
- `H2-TRANSITION-007` — the outer component graph selected the correct Tools
  lane, but the reusable workflow still launched six category buckets, each
  installing Flutter, root npm, Functions npm, and scanner dependencies. The
  affected-tools selector removes five runners for owned tool changes, but its
  remaining runner still performs the broad bootstrap. Dependency-aware setup
  is the next course correction, not more path-routing prose.
- `H2-TRANSITION-008` — local readiness totals changed from 4,605 to 4,660 as
  sparse materialization and focused tests changed, despite every run reporting
  100/100. A score whose denominator depends on checkout materialization is not
  comparable across agents; future receipts must report the declared validation
  closure alongside the numerator and denominator.
- `H2-TRANSITION-009` — runner reduction and wall-clock reduction diverged
  under account contention. PR #153 used only 183 runner-seconds but waited
  between every dependent Tools job while PR #152 exercised the full graph,
  producing 814s wall time. The uncontended attempt completed in 274s wall
  time with 254 runner-seconds even though its plan checkout varied from 27s
  to 117s. Migration measurements must report queue gaps, aggregate runner
  time, and setup variance separately rather than treating one wall sample as
  a stable property of the selected checks.
- `H2-TRANSITION-010` — a deterministic post-squash branch name already
  existed from the historical stack. Branch creation failed safely in 0.01s;
  inspection showed that reusing the stale branch would have produced a
  21-file, +90/−1,514 diff against current `main`, including removal of newly
  merged affected-tools and sparse-audit fixes. Task branches need an attempt
  identity plus recorded base tree, and task setup must refuse branch reuse
  when the recorded base is not the current integrated base. Old branches may
  remain as evidence, but must be marked superseded rather than presented as
  active merge paths.
- `H2-TRANSITION-011` — affected selection cannot compensate for an unbounded
  full-repository checkout. Final evidence PR #158 attempt 1 assigned a runner
  immediately, then spent 274s in the `docs-policy` job while
  `actions/checkout@v6` remained on its checkout step; it was cancelled after
  the checkout had been observed in progress for 250s. The cancelled attempt
  consumed 305 runner-seconds and 320s wall. The unchanged retry passed with
  3 active jobs, 55 runner-seconds, and 74s wall, proving this was checkout
  infrastructure variance rather than a repository check failure. Phase 1.9
  must add graph-projected sparse checkout inputs and bounded job timeouts;
  ordinary lanes should not clone unrelated product surfaces before running a
  25-second policy check.

### Checkpoint 4 — authoritative cutover candidate (2026-08-06)

| Signal | Current result |
|---|---|
| Bounded plan-output commit | `cdbffcb22` added fail-closed fixed outputs and role projection (+158/−5); 37 focused tests passed in 0.69s; commit 0.03s; push 3.24s |
| Workflow authority commit | `3cb9b9080` routed CI, Firebase dev deploy, and mobile release through Harness v2 (+207/−62); 57 combined legacy/v2 tests passed in 0.67s; four workflows parsed as YAML; commit 0.04s; push 2.53s |
| Ordinary shared Flutter projection | `flutter` plus `flutter_web_smoke`; Consumer and Host dev debug web only; no Android, iOS, or production-web build |
| Ordinary documentation projection | One `docs` target; the dedicated job runs monotonic document checks without Flutter, npm, or Functions installation |
| Old-system execution evidence | The five-file foundation PR still launched 27 active jobs under v1, including device builds, visual integration, four Flutter shards, coverage, and multiple web builds |
| V1 retirement candidate | 21 files, +179/−1,146 (net −967): planner implementation/tests and the duplicate 493-line routing table are deleted; focused verification is green |
| Sparse validation closure | Global gates initially misreported absent unrelated files; adding only their declared owner/guard paths took 0.39s and grew the worktree from 64 MB to 84 MB, after which root hygiene and readiness passed |
| Current audit-stamp overhead | Sandboxed Dart failed in 0.04s on SDK-cache writes; the approved rerun took 0.41s and rewrote 10 global catalog lines plus one shared pass receipt for nine scoped paths |
| Squash-stack reconciliation | Repository policy rejected the merge-commit path in 1.36s; the foundation squash completed in 3.67s and left the tree-equivalent stacked cutover historically conflicting. `backup/harness-v2-pre-cutover-20260806` preserved the pre-cutover state; replaying the three reviewed cutover commits from integrated `main` took 0.28s without conflict, and candidate/replay trees were identical. |
| Full-cutover CI | PR #150 / run `31100381412` passed with 31 active jobs, 9,000 runner-seconds, and 1,183s wall time versus v1 run `31096882945` at 30 jobs, 9,121 runner-seconds, and 1,574s wall: +1 job, −1.3% runner time, and −24.8% wall time. Because a control-plane change deliberately selects the full graph, compute is effectively flat; the wall improvement is scheduling evidence, not an ordinary-path efficiency result. |
| Cutover integration | PR #150 squash-merged as `228941c70` in 3.29s; Harness v2 is authoritative and the retired v1 planner remains deleted. Preserve the backup and manual-v1 rollback evidence for the planned seven-day window. |

### Checkpoint 5 — affected Tools lane and deletion canaries (2026-08-06)

| Signal | Previous behavior | Current result |
|---|---|---|
| Two-file tool-checker path | PR #148 / run `31099656393` ran 10 active jobs and consumed 2,400 runner-seconds over 833s wall time. The Tools lane launched all six category buckets and consumed 2,366 runner-seconds over a 790s active envelope. | PR #153 / run `31105049522` passed twice with 5 active and 12 skipped jobs, exactly the owning doc-version checker plus four mandatory guards, and all six category buckets skipped. Contended attempt 1 used 183 runner-seconds (−92.4%) but 814s wall. Uncontended attempt 2 used 254 runner-seconds (−89.4%) and 274s wall (−67.1%). Its Tools path used 133 runner-seconds (−94.4%) over a 138s envelope (−82.5%). The clean replay in PR #154 / run `31108209945` then passed with 5 active and 12 skipped jobs, 226 runner-seconds (−90.6%), and 240s wall (−71.2%); it squash-merged as `464da8976` in 3.73s. PR #153 was closed with its benchmark evidence preserved. |
| Affected-runner bootstrap | Every category runner installed a broad shared toolchain. | The single affected runner completed green in 104–120s across both attempts, below the 300s acceptance threshold, but most of that time was Flutter, npm, Functions, ripgrep, and Playwright setup; the selected checks themselves completed locally in 2.4s. Phase 1.9 remains necessary. |
| Full-control-plane interpretation | Control-plane edits require full validation. | PR #152 changes the planner, workflow, manifest, and audit tool, so its full-matrix execution is intentional and is not used as the affected-only performance result. |
| Safe deletion accounting | The old system and accepted review artifacts were still physically present. | The v1 retirement commit removed 1,146 lines while adding 179 (net −967). Main merge `4a42066fe` removes 200 lines while adding 45 (net −155), including deletion of the 168-line retired Fable handoff. |
| Deletion-only CI path | PR #149 used 3 active jobs, 59 runner-seconds, and 75s wall before the clean replay. | Stacked PR #155 / run `31108373400` used 3 active jobs, 57 runner-seconds, and 71s wall. After #154 squash-merged, the tree-identical main-based PR #157 / run `31109183790` used 3 active and 11 skipped jobs, 58 runner-seconds, and 83s wall, then squash-merged as `4a42066fe` in 5.14s. Tools skipped entirely in both runs. |
| Shared-evidence integration tax | The first seven-file retirement replay on the historical stack conflicted in `files.jsonl` and `passes.jsonl` after 0.17s; preserving the sparse-safe side, regenerating from the staged index, and writing a scoped receipt restored exact 7,235-entry parity. | The pre-merge clean chain replayed without conflict, but squash integration required one more tree-identical deletion replay (0.17s) and, after deletion merged, one final three-commit evidence replay (0.33s). Safety improved; manual restacking remains real overhead. This validates the safe portion of `H2-TRANSITION-006` while `H2-TRANSITION-004` scoped-evidence debt remains. |
| Publication overhead | Historical branches and PRs obscured which commits were intended to merge. | The clean lifecycle branch pushed in 1.99s and opened PR #154 in 2.58s; the first deletion branch pushed in 1.96s and opened PR #155 in 2.89s. After the parent squash, its main-based replacement pushed in 2.04s and opened PR #157 in 4.79s. Obsolete PRs #148, #149, #153, #155, and #156 were closed with evidence comments rather than left as competing merge paths. |
| Checkout reliability | Full checkout cost was hidden inside aggregate job time. | PR #158 attempt 1 assigned a runner immediately but `actions/checkout@v6` remained in progress until the run was cancelled: 305 runner-seconds and 320s wall. The unchanged attempt 2 passed in 55 runner-seconds and 74s wall. This is a 5.5× compute and 4.3× wall swing before any meaningful policy variation, so checkout footprint and timeout must become explicit Harness outputs. |

### Checkpoint 6 — checkout closure and logical repository snapshot (2026-08-06)

| Signal | Before this tranche | Current result |
|---|---|---|
| Planner checkout | Every planning job cloned the full repository with no bounded checkout step. | PR #159 projects a five-file, root-anchored non-cone sparse closure with a three-minute checkout timeout. Its live planner checkout completed in 2s; the same run's full Tools preflight checkout took 149s. Local planner checkout took 0.05s and exposed exactly five tracked files. |
| Docs checkout | Docs-only validation inherited a full clone. | The graph projects an exact two-file docs closure; any `policy_docs` selection still fails safe to a full checkout. Local parity covered all 76 governed docs. |
| Sparse repository truth | A tool-only worktree produced 19 false manifest-path errors, a context pack with only 2 of 9 owner docs and no rules/guards, readiness at 13/32, root hygiene with 19 false failures, enforcement integrity crashing on an omitted rules file, and dependency enforcement passing after scanning 0 Dart files. | One shared repository snapshot now exposes 7,308 logical paths from 621 physically materialized files. Manifest validation passes; context-pack full/sparse outputs match; enforcement passes with 83 active rules and 96 bound tools; root hygiene passes; final readiness is 4,753/4,753 after parent receipts; dependency enforcement scans all 820 eligible Dart files with the same 8 acknowledged findings and 0 new findings. |
| Sparse read cost | A naive fallback implied one `git cat-file` process per omitted source. | The snapshot captures membership in about 107ms and hydrates all 1,341 logical Dart files (11.35MB) in one batch in about 132ms; a cached repeat takes about 4ms. The dependency gate's 820-file scan completes locally in about 0.18s. |
| Failure truthfulness | Readiness rounded 4,681/4,682 to a displayed 100/100, and empty materialization could shrink the denominator. | Any nonzero failure caps the displayed score at 99; the test inventory and dependency denominator come from the same captured logical file set; a zero-file dependency scan throws. |
| Canonical writes | Repository readers and writers both assumed disk materialization. | Reads use the logical snapshot; metrics and baselines remain explicit physical writes and refuse sparse-omitted or non-regular targets. The parent task materialized only the required receipt files before refreshing the test inventory from 624 to 625 tests. |
| Bounded implementation accounting | No common repository-view abstraction. | Five bounded commits change 14 source/test files by +1,547/−296 (net +1,251). The common reader and its adversarial tests account for +728; migrated production call sites remove 240 old filesystem-specific lines. Combined with the prior −2,070-line retirement and the pending +486 checkout projection, the transition remains net −333 lines before this checkpoint's receipts. |

The checkout PR is code-ready but not yet merge-ready. GitHub Actions reported
degraded performance during both failed attempts. The organizer-intake job
failed while downloading an action before repository code ran. The retry did
not fail fast: `tools-ci.yml` already declares `fail-fast: false`. The unrelated
marketing job instead exhausted its 15-minute job timeout after 364s in runner
setup, 209s in checkout, and 273s in its real category checks. No product failure
is inferred from those attempts, and another retry is held until Actions returns
to operational status.

Issues discovered during this tranche:

- `H2-TRANSITION-012` — the full Tools bucket's 15-minute job timeout includes
  provider-side runner setup and full-repository checkout. Under the Actions
  degradation, marketing reached its real checks with only about 4m33s left and
  was cancelled while running them. Preserve `fail-fast: false`, separate setup
  and check timing in receipts, and either reduce the checkout/setup closure or
  give full buckets an explicit outage margin without weakening step ceilings.
- `H2-TRANSITION-013` — filesystem presence is not repository truth in a sparse
  task. This caused both false failures and a zero-file false green. The shared
  stage-0 plus nonignored-untracked snapshot, batched local-blob reader, and
  full/sparse equivalence tests close the immediate defect. Partial clones that
  do not contain a required object fail closed without lazy network fetching.
- `H2-TRANSITION-014` — read closure and write closure are different. The test
  inventory generator failed immediately because its canonical output directory
  was omitted. The current task materialized only its declared receipt paths;
  `harness task start` must project writable outputs separately and generators
  must refuse to recreate a sparse-omitted tracked path accidentally.
- `H2-TRANSITION-015` — repository metadata writes still hit managed-sandbox
  `index.lock` restrictions. One cherry-pick failed immediately and succeeded
  only after approved escalation. This is the same environment class as
  `H2-TRANSITION-003`, but it remains a measurable integration interruption,
  not a source-code or Git conflict.

### Checkpoint 7 — dependency-aware affected setup (2026-08-06)

| Signal | Before this tranche | Current result |
|---|---|---|
| Setup authority | The planner selected five Node-only checks, but the affected runner still installed Node, Flutter, ripgrep, Flutter packages, root npm, Functions npm, and Playwright. Tool prerequisites were implicit in workflow prose. | Plan schema v2 projects a bounded `repositoryView` and canonical `setupRequirements` union after mandatory and transitive checks are selected. The five mandatory guards declare `index` plus `node`. Missing metadata widens to `full` plus all seven setup requirements; malformed metadata fails preflight. |
| Affected workflow | Every affected run restored npm caches and executed six expensive setup/install steps even when no selected check consumed them. | Node remains unconditional. npm cache restoration occurs only when root or Functions npm is required. Flutter, ripgrep, Flutter pub, root npm, Functions npm, and Playwright are each guarded by the exact planner token. This skips six of seven setup layers (85.7%) for the measured Node-only path. Full bucket behavior is deliberately unchanged. |
| Contract proof | No test connected transitive tool selection to runner prerequisites, and sparse clone fixtures could mix a dirty runner with its committed dependency. | 43/43 focused planner, runner, and workflow tests pass. They cover transitive unions, a missing-metadata full fallback, null/unknown/duplicate declarations, prerequisite gaps, canonical output ordering, full-mode widening, affected-job scoping, and a coherent dirty executable closure in full/sparse clones. YAML parsing, manifest validation, and `git diff --check` also pass. |
| Measured check cost | Three live affected jobs took 104s, 118s, and 120s; 76–91s was removable setup/post work. The pre-snapshot selected checks took about 2.4s locally. | The same five production checks now pass locally in 5.98s, and planner projection takes 0.45s. Holding normal 21–25s checkout constant gives a 31–38s expected affected job, a 70–76% reduction, with a live acceptance threshold of 45s. A live claim remains pending GitHub Actions recovery. |
| Change accounting | After the prior −2,070-line retirement, the repository-snapshot tranche and pending checkout projection left the transition net −333 source/test lines before receipts. | This safety contract is +370/−11 (net +359), taking the cumulative source/test transition to net +26 before this checkpoint's receipts. That is an explicit course-correction signal: do not expand per-tool declarations speculatively. Prove the ≤45s live result, then consume `repositoryView` in checkout and retire redundant workflow/setup code before adding another Harness abstraction. |
| Git interruption | Repository-metadata sandbox writes were already tracked as `H2-TRANSITION-015`. | The first stage attempt again failed immediately on the worktree `index.lock`; the approved retry succeeded. Commit `b27ceb9d1` took 0.06s and its preservation push took 2.07s. No source conflict occurred. |

`repositoryView: index` is a required logical-read claim only in this tranche;
the affected workflow still performs a full checkout. It must not be reported as
a sparse-checkout improvement until the next checkout-consumption slice proves
the local-blob and writable-output closure end to end.

Issue discovered during this tranche:

- `H2-TRANSITION-016` — setup narrowing is safe only after the complete selected
  tool closure is known. A missing transitive prerequisite, malformed explicit
  declaration, or formatter that accepts a noncanonical dependency set can
  turn a speed optimization into an under-installed false failure. Project the
  union after mandatory and `alsoCheckIds` expansion, widen absent metadata to
  today's full behavior, reject malformed metadata, and keep full mode on the
  full setup. `REG-HARNESS-AFFECTED-SETUP-001` makes this contract executable.

### Checkpoint 8 — deterministic integration rehearsal (2026-08-06)

| Signal | Measured result |
|---|---|
| Capacity | A full worktree failed at 71% after 3.20s with 268 MiB free. The replacement root-anchored sparse worktree materialized 699 files / 26 MB in about 0.3s. No unrelated worktree or dirty organizer file was removed. |
| Composition | Ten reviewed commits from the checkout, repository-snapshot, and affected-setup tranches form a 33-path union. The integrated tree has zero missing or unexpected paths, and every branch-owned source blob matches its reviewed tip. |
| Shared evidence | The replay stopped twice on four path-level shared-ledger conflicts. Append-only evidence was semantically unioned and `files.jsonl` regenerated to 7,237 entries rather than choosing either stale side. |
| Determinism | Pushed branch `d62e0f8f4` and detached rerere replay `cf95b727b` both resolve to tree `92a5c9b6e1122c74ffd3a902fafc46731b8f8a7d`; `git diff --exit-code` reports no difference. |
| Local Git operations | The ten replay operations took 2.05s total, 0.11s median, and 0.05–0.56s each. These are Git command durations and exclude investigation and manual-resolution wall time. |
| Preservation pushes | Ten bounded pushes took 25.76s total, 2.17s median, and 1.74–4.30s each. Every replayed unit was remotely preserved before the next unit began. |
| External status | GitHub Actions remained in a major outage, so this checkpoint proves local composition and remote preservation only. No new CI or live-runtime claim is inferred. |

This rehearsal strengthens `H2-TRANSITION-001`, `H2-TRANSITION-004`, and
`H2-TRANSITION-006`; it does not introduce another overlapping transition id.
The next implementation slice consumes the already-projected repository view
and must reduce checkout materialization without partial-clone filtering or a
shallower history.

### Checkpoint 9 — checkout consumption and disk-bounded proof (2026-08-06)

| Signal | Before this slice | Current result |
|---|---|---|
| Tools preflight materialization | The preflight always materialized the complete 7,308-file / 167.58 MiB working tree before resolving the affected plan. | A static root-anchored non-cone closure materializes 625 files / 7.04 MiB: 91.45% fewer files and 95.80% fewer working-tree bytes. It retains `tool/`, the local toolchain action, Functions Node metadata, Flutter dependency metadata, and the three Apple workflows read by the pin guard. |
| Affected-runner materialization | `repositoryView: index` was projected but ignored; the affected runner still materialized the full repository. | Exact `index` output materializes 622 files / 7.07 MiB: 91.49% fewer files and 95.78% fewer working-tree bytes. Missing, malformed, future, or otherwise non-index output takes the unchanged full checkout. |
| Repository truth | An aggressive partial clone could make a sparse-omitted blob unavailable to the logical snapshot. | Both bounded checkouts keep `fetch-depth: 0`, omit partial-clone filtering, and therefore retain all local objects needed by `GIT_NO_LAZY_FETCH=1` reads. The full six-bucket path remains unchanged. |
| Executable proof | The first combined focused gate passed 103/104 checks; its only failure was the test fixture attempting another full checkout and exhausting disk. | The fixture now compares materialized and omitted canonical inputs through bounded sparse clones. The exact preflight closure runs the toolchain pin guard, and the exact affected closure runs all five production guards. The combined repository-view, setup, runner, workflow, readiness, and governance suite passes 124/124 in 9.89s. |
| Redundant work | Preflight validated the complete tool manifest, then `affected-tools` immediately performed the same fail-closed validation again. The equivalence test also materialized a complete duplicate repository. | The duplicate manifest step and full fixture checkout are removed. Production/test changes are +285/−47 (net +238): the runtime footprint falls sharply, while exact closure, fallback, Node-only, and real sparse-clone proofs account for the net source growth. |
| Live claim | The last healthy full Tools preflight checkout took 149s; affected jobs took 104–120s before setup projection. | No network-transfer or live wall-time improvement is claimed from local materialization bytes. GitHub Actions remains unavailable; the acceptance target is still an affected job at or below 45s after service recovery. |

This closes the immediate checkout-consumption portion of
`REG-HARNESS-AFFECTED-SETUP-001` and strengthens the existing disk-budget
finding `H2-TRANSITION-001`. It deliberately does not add another transition
id. After a live canary, the next deletion candidate is the now-redundant broad
setup contract—not another layer of checkout metadata.

### Checkpoint 10 — sparse task-worktree broker and first root-doc retirement (2026-08-06)

| Signal | Before this slice | Current result |
|---|---|---|
| Task creation | Parallel-agent instructions relied on prose plus ad hoc `git worktree` commands. There was no capacity preflight, durable task state, active lock, remote-branch collision contract, or guaranteed preservation push. | `node tool/harness.mjs task start` validates the exact base SHA/stack parent and explicit sparse paths, reserves 1 GiB plus a 256 MiB default task budget, creates only under `.claude/worktrees/`, writes task metadata in Git state, locks the active worktree, atomically requires the remote branch to be absent, and pushes it to `origin`. |
| Task health and closeout | “Disposable” worktrees could remain live indefinitely or be mistaken for deletion-safe based on age, cleanliness, or a gone upstream. | `task doctor` verifies lifecycle, lock, sparse materialization, capacity, and shared-cache boundaries. `task finish` requires a clean, remotely equal head, records a recoverable terminal transition, and unlocks without deleting. `task reap --dry-run` refreshes live remote heads and has no apply path; ignored-inspection failures and legacy-unknown ownership block classification. |
| Live inventory | No authoritative command could quantify the shared worktree pool. | The report inspected 45 registered worktrees. The 44 secondary worktrees occupied 8.49 GiB; four sparse worktrees averaged about 38 MiB versus about 192 MiB for full `.claude` worktrees, an observed ~80% reduction. Strict autonomous removal eligibility is zero. The latest report returned `deletionAuthorized: false`, one zero-byte stale registration for owner review, 44 blocked entries, six legacy-review-only worktrees totaling about 1.0 GiB, and digest `5f9145de292157c6505807f06ec0831fa3216bc87c4d43f0e0140adef9d16d0c`. Live state must be refreshed before any owner decision. |
| Executable proof | Delegation policy was guarded only by the broad readiness command. | 59/59 focused Harness tests pass in 2.14s, including lifecycle/CLI recovery, collision, sparse-path, capacity, ignored-payload, and report-only cases. The final owner gate also passes 40 runner/impact, 10 monotonic, 3 document-state, 19 enforcement, 6 root-hygiene, and 2 inventory tests in 15.40s; manifest, audit parity, diff/JSON, and 4,948/4,948 readiness pass. `AGENT-DELEGATION-001` now maps bidirectionally to `agent:harness-v2`, and `REG-AGENT-007` names the focused lifecycle tests. |
| Preservation timing | No bounded lifecycle commit existed. | Source commit `e22963491` completed in under 0.1s and its branch push completed in 2.44s. The live report took about 18.9s, dominated by fail-closed remote and worktree inspection rather than deletion. |
| Consolidation | Current delegation behavior was repeated across agent entrypoints while an implemented 890-line root-hygiene review spec remained indexed as a live retirement candidate. | Canonical instructions now route to the four Harness task commands, and the obsolete root-hygiene spec plus its live catalog/index/backlog links are deleted. The complete 25-file instruction, authority, test, registry, delegation-evidence, and retirement tranche is +422/−1,047, net −625 lines. Historical merge-drop and append-only pass references remain intact. |

Issue discovered during this tranche:

- `H2-TRANSITION-017` — closed in Checkpoint 11. `checkSafety` distinguishes a
  tool's read-only validation path from its explicit remote-write command. The
  manifest validator and Harness now share an exact `local-readonly` contract;
  malformed values fail closed and the field remains limited to
  `agent:harness-v2`.
- `H2-TRANSITION-018` — closed in Checkpoint 12. Markdown retirement lifecycle was duplicated between
  source frontmatter and `doc_versions.json`; the root-hygiene source correctly
  said `retirement_ready` while the catalog still said `implemented`, so a safe
  deletion failed and would have required a ceremonial intermediate PR. Source
  frontmatter is now the sole Markdown authority, missing/malformed/duplicate
  status fails closed, catalog lifecycle remains only for non-Markdown
  artifacts, and tests prove an active source overrides a stale
  `retirement_ready` catalog row. Derived document-state artifacts and agent
  context packs now publish only source-derived Markdown status. The same-branch
  deletion passes against `origin/main` without
  weakening target-file or catalog-row absence proof.

### Checkpoint 11 — executable check-safety contract (2026-08-06)

| Signal | Before this slice | Current result |
|---|---|---|
| Safety authority | Harness coerced `checkSafety` through `String(...)` and accepted any value with a `local` prefix and no `remote` substring. A typo or array could therefore cross the local-check allowlist while the manifest validator remained silent. | One shared executable contract now admits only the exact `local-readonly` override, requires non-empty checks, rejects redundant overrides on already-local commands, and fails closed for malformed values. `safety` continues to describe the command; `checkSafety` describes only its validation commands. No parallel JSON schema was added. |
| Direct proof | No negative test exercised the split between a remote-write command and its local checks. | 55/55 focused runner, tool-impact, and Harness CLI tests pass in 8.30s. They cover null, scalar, collection, prefix, suffix, write, and remote malformed values; direct Harness inclusion/exclusion; and an end-to-end manifest rejection fixture. |
| Scope | The unvalidated override was trusted by `agent:harness-v2`. | Adoption remains limited to `agent:harness-v2`; another tool cannot use the field safely without passing the same closed validator and tests. |
| Implementation size | The field had one consumer and no executable schema or negative proof. | The bounded enforcement tranche is 12 files, +192/−29 lines, net +163. This is deliberate guard/test growth; the following lifecycle-catalog and adapter retirements must more than offset it before claiming a net-negative migration. |

### Checkpoint 12 — single Markdown lifecycle authority (2026-08-06)

| Signal | Before this slice | Current result |
|---|---|---|
| Catalog authority | All 62 governed Markdown rows repeated lifecycle `status` beside source frontmatter; four already disagreed with their sources. Thirteen governed non-Markdown artifacts also used catalog status legitimately. | Markdown rows now contain zero catalog statuses; all 13 non-Markdown statuses remain. The catalog schema advances to 5.0.0 and rejects either authority split. The metadata migration itself is net −30 lines; the complete 25-file source-repair, enforcement, test, and receipt tranche is +319/−156, net +163, so the next adapter/doc retirement remains required to reduce total Harness size. |
| Source completeness | Eight governed README files had no frontmatter and two prose-valued status lines were unparseable, so blindly deleting catalog fields would have emitted ten null lifecycle states. | All 62 governed Markdown sources now produce exactly one status. The eight README owners received minimal status-only frontmatter and the two prose statuses preserve their explanation as comments. Document-state generation and context packs fail closed on missing governed source status. |
| Executable proof | The monotonic gate could pass a current catalog whose derived Markdown lifecycle was null. | 15/15 focused lifecycle and document-state tests pass in 0.53s. The 96-test owner gate passes in 13.04s across runner, impact, enforcement, lifecycle, document-state, readiness, root-hygiene, and inventory checks; readiness is 4,981/4,981. The working-tree gate passes against legacy `origin/main` with 18 increases, 57 unchanged entries, one proven retirement, and zero findings; a direct invariant scan reports 62 valid Markdown sources, zero Markdown catalog statuses, and 13 non-Markdown catalog statuses. |
| Broker rehearsal | This cleanup began in the legacy rehearsal worktree. | `task start` created and remotely preserved an exact-SHA, locked 26.6 MiB sparse worktree in 3.10s; `task doctor` passed in 0.16s. The first sandboxed invocation correctly failed closed because its nested remote probe lacked network authority; the same command succeeded once that declared remote-write permission was granted. |

### Checkpoint 13 — parallel-delegation adapter retirement (2026-08-06)

| Signal | Before this slice | Current result |
|---|---|---|
| Delegation authority | A 40-line adapter doc and 47-line manifest recipe repeated policy and lifecycle commands already owned by the operating model and Harness. The React refactor router also imported this unrelated delegation layer. | The adapter doc and recipe are deleted. Parallel delegation is an explicit `context_pack.mjs --mode parallel-delegation` projection owned by the operating model; its four command templates are exported from the Harness lifecycle itself. React routing no longer carries delegation policy. |
| Context completeness | Deleting the recipe alone would silently remove start, doctor, finish, reap, outcome recording, `AGENT-DELEGATION-001`, and parent-ownership acceptance from generated task context. The old recipe also invoked a self-referential `--task parallel-delegation` context command. | A focused test proves the mode emits the owner doc, active rule, four canonical lifecycle commands, outcome recorder, and parent-owned acceptance without selecting the retired skill or emitting a recursive context command. Readiness passes 4,963/4,963; its denominator is 18 checks smaller than Checkpoint 12 because the duplicate recipe is gone. |
| Sparse executable closure | The first focused run passed 47/48 tests: the new context-pack import was absent from the sparse-equivalence fixture and failed before assertions. | `REG-HARNESS-SPARSE-SNAPSHOT-001` now covers direct executable imports, and the fixture materializes the Harness lifecycle module. The unchanged focused gate then passed 48/48 in 8.82s; the complete owner gate passed 119/119 in 8.94s. |
| Broker rehearsal | Ad hoc worktree creation made task isolation and preservation timing hard to compare. | `task start` created and pushed the exact-SHA, locked 27.8 MiB sparse worktree in 2.89s; `task doctor` reported healthy in 0.5s. The read-only delegation audit was recorded as accepted with parent edits. |
| Line accounting | Checkpoints 10–12 contributed net −299 lines across the root-doc retirement and two safety tranches. | The complete 17-file implementation, checkpoint, delegation metric, and audit-receipt tranche is +140/−164, net −24. The four cleanup/safety commits are now cumulatively net −323 lines while retaining executable behavior. |

Issue discovered during this tranche:

- `H2-TRANSITION-019` — executable sparse closures are dependency graphs, not
  lists of entrypoints. A new direct import caused the materialized fixture to
  fail even though the production module existed in the full checkout. Keep
  direct imports in the bounded fixture closure and let full/sparse equivalence
  tests fail before a checkout optimization is published.

### Checkpoint 14 — document-summary authority retirement (2026-08-06)

| Signal | Before this slice | Current result |
|---|---|---|
| Read-policy authority | `doc_versions.json` and a 674-line `doc_summaries.json` independently routed agents to governed documentation. Changing one owner could leave the other stale, while the `audit:registry docs` command still read the duplicate summary file. | `doc_versions.json` is the sole live read-policy catalog. The docs command reads it directly, omits retired rows, sorts deterministically, and fails with exit 64 when a filter matches nothing. The document-hygiene skill and portable workflow guide no longer instruct agents to maintain a parallel summary registry. |
| Retirement size | The duplicate registry occupied 674 lines and remained a default sparse-task anchor. | It is a five-line lifecycle tombstone pending retirement of `doc_versions.json` itself: a 99.3% reduction and 669 fewer physical lines. No tool, test, skill, or task anchor consumes it. Historical receipts remain immutable. |
| Executable proof | The summary command had no direct check in the tool manifest, and a missing path filter could be mistaken for successful routing. | The manifest exercises `audit_registry.dart docs --path widget`; the focused positive command prints five governed policies and the negative command fails closed. Document lifecycle/state tests pass 15/15, the monotonic comparison preserves all 75 governed paths with zero inconsistencies, and the broker lifecycle suite passes 9/9. |
| Sparse handoff closure | Task anchors materialized both required agent entrypoints but omitted direct imports needed by the context-pack and readiness commands. The mandated gates therefore crashed before inspecting the sparse repository. | The broker now anchors the missing document-lifecycle, dependency-direction, and test-inventory modules. One regression test derives every relative import from both mandatory entrypoints and proves that the sparse closure covers it. This closes the immediate `H2-TRANSITION-020` failure without widening to the whole `tool/` tree. |
| Measured next deletions | Follow-on cleanup was described generically. | Three independent read-only audits identified bounded candidates: nine completed handoff docs remove 4,050 direct lines; two reproducible raw merge reports remove 121,680 lines / 4.09 MB; and four UI compatibility wrappers should remove about 250–300 net lines while eliminating 80% of duplicate full-repository analyzer launches. Each remains an independent commit and verification boundary. |
| Line accounting | The four prior cleanup/safety commits were cumulatively net −323 lines. | The complete 17-file implementation, regression guard, checkpoint, three audit metrics, generated inventory, and pass receipt is +120/−751, net −631. The five cleanup/safety commits are now cumulatively net −954 lines. |

Issue discovered during this tranche:

- `H2-TRANSITION-020` — a sparse broker cannot advertise a mandatory command
  while omitting that command's executable import closure. Both context-pack
  generation and readiness failed before repository evaluation in this task.
  Treat those entrypoints as broker-owned closure roots, derive their relative
  imports in a regression test, and prove the fix in the next brokered task.

### Checkpoint 15 — completed feature-handoff retirement (2026-08-06)

| Signal | Before this slice | Current result |
|---|---|---|
| Temporary documentation | Nine completed implementation specs and design-parity handoffs remained indexed as live retirement candidates after their durable decisions had moved to owner docs, contracts, registries, scanners, and tests. | All nine source files are deleted together: 4,050 direct lines. `docs/README.md` now records the completed lifecycle rather than maintaining another candidate table; the backlog item is closed; and current catalog and regression-owner references point only to surviving authorities. Historical pass, merge, metric, and rule-introduction receipts remain unchanged. |
| Deletion proof | A missing file or catalog row alone could not prove safe retirement. | The working-tree monotonic gate compares exact base `1543ca986`, reads each base source frontmatter, and proves nine `retirement_ready` removals, 75→66 governed paths, five version increases, zero decreases, and zero removal inconsistencies. The 15 focused lifecycle/state tests pass in 0.67s. |
| Broker regression canary | `H2-TRANSITION-020` had repaired mandatory sparse imports but was not yet exercised by a fresh task. | `task start` created and pushed a 23.9 MB sparse worktree in 3.27s. Its own context pack (0.12s), readiness (4,996/4,996 in 0.17s), manifest gate (0.03s), enforcement gate (83 rules / 96 tools in 0.74s), and doctor (0.26s) all pass from the sparse checkout. |
| Dependency truth | Context planning could select Node-based design checks without proving that the task had a runnable dependency environment. | The two optional feature-contract checks failed before repository evaluation because `ajv` is absent. No full `npm install` or shared `node_modules` symlink was introduced into the 64 MiB task: the broker explicitly rejects shared dependency symlinks. `H2-TRANSITION-021` records the need for declared local setup profiles and an immutable content-addressed dependency strategy. |
| Line accounting | The five prior cleanup/safety commits were cumulatively net −954 lines. | The complete 17-file deletion, live-reference repair, checkpoint, generated inventory, and pass receipt is +55/−4,172, net −4,117. The six cleanup/safety commits are now cumulatively net −5,071 lines. |

Issue discovered during this tranche:

- `H2-TRANSITION-021` — sparse path closure and executable dependency closure
  are separate contracts. A task may contain a script and package manifest but
  still lack the packages required to execute it. The broker should declare a
  bounded setup profile, estimate installed bytes before task creation, and use
  an immutable content-addressed store rather than unsafe cross-worktree
  `node_modules` symlinks. Until then, report the setup blocker explicitly and
  run only checks whose local runtime closure is present.

### Checkpoint 16 — derived merge-report retirement (2026-08-06)

| Signal | Before this slice | Current result |
|---|---|---|
| Raw evidence footprint | Two generated four-tree comparison reports occupied 121,680 lines / 4,091,283 bytes in `docs/audit_registry` despite having no tool, workflow, catalog, or current-document consumer. | Both raw reports are deleted. The authored discard receipts, semantic review, Organizer Detail design QA, append-only pass records, and active merge-audit enforcement remain. Historical references inside another raw report and immutable ledgers are deliberately untouched. |
| Reproducibility | Removing a report without a deterministic reconstruction path could discard unique evidence. | Strict regeneration from retained Git refs and receipts matched both files byte-for-byte: reconciliation SHA-256 `0dba93b892f15ac98f7aa8011ca0638a10979c703958d2857f8ba4feac348258`, blob `6c8b6d1bce8a7fd23427c79c11f5ab13aa46065a`, 0.21s; Organizer Detail SHA-256 `5d0a3e6c791a0f18f318066bc3655e67c7fe398c30f1d853e24871f58730d447`, blob `768a342c99bfafafdbce20f54deb551f865a2f6d`, 0.20s. |
| Scope boundary | A third generated phone-only report was another apparent deletion candidate. | It remains because one merged input commit lacks an `origin/*` preservation ref. The tranche removes only evidence whose inputs and human decisions are already durably recoverable. |
| Broker timing | Large audit-registry cleanup historically encouraged work in a shared full checkout. | `task start` created and pushed a 19.5 MB sparse worktree in 3.28s; context generation took 0.14s and doctor passed in 0.32s. |
| Line accounting | The six prior cleanup/safety commits were cumulatively net −5,071 lines. | The complete five-file deletion, checkpoint, generated inventory, and pass receipt is +13/−121,684, net −121,671. The seven cleanup/safety commits are now cumulatively net −126,742 lines. |

### Checkpoint 17 — Catch UI wrapper consolidation (2026-08-06)

| Signal | Before this slice | Current result |
|---|---|---|
| Analyzer authority | Four 204-line compatibility scripts only translated historical command names into filters over `check_catch_ui_lint_drift.sh`. Their four manifest tools and rule bindings made one analyzer policy look like five separate enforcement systems. | The wrappers and manifest entries are deleted. `lint:catch-ui-drift` now directly binds `UI-LINT-001`, `DESIGN-TOKENS-001`, and `RESPONSIVE-LAYOUT-001`; current docs use the canonical ratchet or explicit `--code` filters. No alias layer replaces the wrappers. |
| CI work | Full Tools execution could launch the repository-wide analyzer through the canonical drift tool and again through each of four wrappers. Flutter CI also repeated three wrapper parser/gate steps after already caching one analyzer census. | Full Tools falls from five analyzer launches to one, an 80% reduction. Flutter CI keeps exactly one machine census and the shared warning/ratchet projections while deleting three redundant wrapper steps. A workflow regression test proves one census, the canonical `--check`, and absence of all four retired names. |
| Executable proof | Wrapper-level manifest and rule entries could disappear without proving canonical coverage remained, while sparse materialization could hide active docs that still invoked them. | 22/22 focused workflow, lifecycle, parser, and ratchet tests pass. A full-index guidance test now finds zero live wrapper references even when files are sparse-omitted. Manifest validation passes; enforcement remains 83 active rules and falls from 96 to 92 bound tools exactly because four aliases are gone; readiness passes 4,990/4,990. The generated design-language projection is byte-identical to its source at SHA-256 `2eaa85cff776b41d65ffbaa45f481ffa6ec4aa1cd2d0b2e2a31cd06b71e2ab3a`. |
| Task root isolation | The sparse task contained a Flutter-backed generator but omitted the root `pubspec` sentinels. Because task worktrees are nested under the primary repository, Flutter walked upward and began dependency resolution in the protected dirty checkout. | No new primary diff was created. Every future task now anchors `pubspec.yaml`, `pubspec.lock`, and `analysis_options.yaml`, and the lifecycle regression test pins them. A fresh task from commit `7e3f80514` materialized all three at its own root, resolved that exact path through Git and Flutter, passed the full generated-pack check and canonical UI ratchet, stayed clean, and finished healthy. `H2-TRANSITION-022` is closed. |
| Broker timing | Compatibility cleanup previously happened in shared full checkouts. | The cleanup task started at 17.7 MB in 3.44s; commit `7e3f80514` took 0.36s and pushed in 6.71s. The fresh canary started in 7.89s at 38.4 MB tracked, resolved cached dependencies in 6.46s, passed the monolithic pack check in 27.12s and the warm single analyzer ratchet in 29.20s, then passed doctor in 1.31s and terminal closeout in 1.32s. Its compiled footprint was 174.2 MB against a 256 MiB budget, with no shared dependency symlink. |
| Line accounting | The seven prior cleanup/safety commits were cumulatively net −126,742 lines. | The complete 28-file wrapper deletion, live-reference repair, generated projection, Harness guard, tests, registries, checkpoint, and audit receipt is +203/−473, net −270. The eight cleanup/safety commits are cumulatively net −127,012 lines. |

Issue discovered during this tranche:

- `H2-TRANSITION-022` — closed in Checkpoint 17. Nested task worktrees must contain project-root
  sentinels before any toolchain command runs. Otherwise Flutter can traverse
  into the parent primary checkout and resolve or generate files there. Anchor
  `pubspec.yaml`, `pubspec.lock`, and `analysis_options.yaml` in every task,
  retain the shared-dependency-symlink prohibition, and prove a fresh task sees
  its own root before claiming isolated execution; the fresh canary now does.

### Checkpoint 18 — legacy definition-catalog retirement (2026-08-06)

| Signal | Before this slice | Current result |
|---|---|---|
| Authority | A 935-line regex extractor persisted a complete Dart definition dump and a second heuristic candidate queue even though no live tool, workflow, or instruction consumed either output. The active manifest only syntax-parsed the generator and never proved either file current. | The generator, 38,977-line definition dump, 51-line candidate queue, and manifest entry are deleted. Current widget-consolidation authority remains with widget classification, similarity, new-widget inventory, the reviewed decision ledger, and the active backlog; no alias or replacement dump is introduced. |
| Staleness | The catalog claimed 779 source files from July 17 and embedded an absolute machine path and generation time. The live tree has 820 matching Dart files: 46 current files were absent and five deleted files remained. The backlog said zero candidates while the committed candidate queue still contained two. | The stale backlog note now routes to current focused authorities. Historical pass and consolidation receipts remain immutable, but they are not live consumers. The deleted blobs remain recoverable from Git as `56f9ae7d`, `6f823a343`, and `a2ce670ba`. |
| Regression proof | A retired generated dump could return because no gate asserted that it stayed absent. | `REG-AUDIT-DERIVED-EVIDENCE-001` and a required full-index Harness test now prove all three paths are absent and that current agent, audit, backlog, rule, and tool authorities do not route to their names. A fresh canary passed manifest validation, 83-rule/92-tool enforcement integrity, 11/11 workflow tests, 5,001/5,001 readiness, and three exact-base document-version increases; active manifest tools fell only from 230 to 229. |
| Broker timing | The prior large evidence cleanup used bespoke inspection boundaries. | The 8.28 MB task started in 19.13s and generated context in 1.18s; commit `f277dd2ea` took 0.19s and pushed in 7.61s. A mistyped guessed full SHA failed closed in 0.25s before creating state. The exact-SHA canary started in 11.45s at 6.70 MB; manifest, enforcement, workflow, readiness, and monotonic checks completed in 1.33s, 5.05s, 2.17s, 2.12s, and 3.51s; doctor passed in 1.02s and terminal closeout in 1.80s. |
| Line accounting | The first eight cleanup/safety commits were cumulatively net −127,012 lines; the evidence-only UI canary receipt was net zero. | The complete 11-file generator/output deletion, authority repair, full-index guard, checkpoint, registry refresh, and reviewed receipt is +98/−39,995, net −39,897. The clean canary receipt is +13/−11, net +2; the ten-commit measured series is therefore net −166,907 lines. The three direct retirements account for 39,965 deleted diff lines / 1,335,697 bytes. |

Issue discovered during this tranche:

- `H2-TRANSITION-023` — legitimate ad hoc sparse expansion is invisible to the
  task creation receipt, so doctor correctly blocks closeout with
  `sparse_checkout_metadata_mismatch`. Until the broker owns an explicit,
  budget-checked materialization operation, create a fresh capability-complete
  task rather than changing sparse patterns manually; restoring the recorded
  view is the only valid closeout path for an older task.
- `H2-TRANSITION-024` — the generated context-pack command plan can recommend a
  check whose executable entrypoint is absent from the task's sparse closure.
  This task correctly refused to improvise another expansion when
  `tool/run.mjs` and the enforcement checker were missing. Command-plan
  generation must publish its physical path closure to `task start`; until
  then, prove omitted commands in a fresh capability-complete canary, as this
  tranche did.

### Checkpoint 19 — current-only widget catalog (2026-08-07)

| Signal | Before this slice | Current result |
|---|---|---|
| Reader cost | `docs/widget_catalog.md` was 7,748 lines / 620,927 bytes. Current inventory did not begin until line 6,490 because 6,255 lines of release history and 217 lines of duplicated cleanup/process instructions came first. | The catalog is 1,291 lines / 306,844 bytes and current inventory begins at line 33. Total file size falls 50.6%, word count falls 53.7%, and pre-inventory scrolling falls 99.5%. Git and immutable audit receipts now own history; the catalog owns current inventory plus a 13-line maintenance contract. |
| Inventory safety | The history prefix mentioned current and retired widget names, so a text-presence checker could appear stronger than the actual current inventory. | `## App Entry Point` through EOF is byte-identical to the parent: 305,649 bytes at SHA-256 `4fe4a91ebdb270aa680e4e5c0cbeed2d4fded73b3a41279e189dab0cdd53c55c`. The full 820-file new-widget scan reports zero added, moved, or unresolved items. |
| Maintenance semantics | Routine widget edits appended another release heading and incremented a 669-patch semantic version, even though semantic document versions are contracts rather than edit counters. Four live rule anchors depended on the obsolete changelog heading. | Routine changes update only affected current-inventory rows. Version `3.0.0` marks the one-time reader-contract change; future version bumps are reserved for reader-contract or structural changes. Four rule anchors now point to the maintenance or architecture owner. `REG-DOC-INLINE-HISTORY-001`, the required structural test, manifest binding, and `WIDGET-CATALOG-001` prevent inline history from regrowing. |
| Proof | No machine gate constrained where usable inventory began or prevented semantic release headings from returning. | A fresh committed-state canary passed 12/12 document tests, 60 unchanged / 6 increased document versions, 83-rule / 92-tool enforcement integrity, manifest validation, 5,012/5,012 readiness, the exact suffix proof, the 36.13s full widget scan, and the 7,219-entry registry parity check. No Flutter run was selected because no Dart or rendered UI changed. |
| Broker timing | The first sparse declaration omitted a live design-policy consumer discovered during full-index review, and closing it without network authority mislabeled remote verification as non-preservation. | The untouched rehearsal was closed instead of manually widening its receipt. The corrected 46.6 MB task started in 22.14s; context generation took 0.30s; commit `83cc80890` took 0.16s and pushed in 5.77s. The warmed 46.3 MB canary started in 5.27s, doctor passed in 1.78s, and terminal closeout took 1.53s. |
| Line accounting | The ten prior cleanup/safety commits were cumulatively net −166,907 lines. | The 11-file core deletion and all owner, enforcement, test, registry, and receipt changes are +128/−6,529, net −6,401. The canary checkpoint receipt is +34/−5, net +29; the twelve measured commits are cumulatively net −173,279 lines. |

Issues discovered during this tranche:

- `H2-TRANSITION-025` — `task start` requires physical paths before the task's
  context/reference analysis can expose reverse live consumers. A full-index
  review found one design-policy consumer only after the first branch existed.
  The untouched task was cleanly closed and replaced; no sparse pattern was
  widened by hand. The broker needs an inspect-first task-plan transaction that
  expands enforcement anchors and live document references before branch
  creation. Until then, contract-removal tasks must perform a full-index
  reference preflight before `task start`.
- `H2-TRANSITION-026` — a sandboxed `task finish` reported
  `remote_head_not_preserved` while its own local snapshot showed matching HEAD
  and upstream SHAs. The remote probe was unavailable, not negative. Remote
  preservation needs three states (confirmed, absent, indeterminate) and an
  explicit `remote_verification_unavailable` blocker; until implemented, rerun
  terminal verification with declared network authority.

### Checkpoint 20 — live-only Widgetbook review evidence (2026-08-07)

| Signal | Before this slice | Current result |
|---|---|---|
| Evidence authority | A committed 435,858-byte comparison page, a 465,199-byte coverage report, a one-time audit-plan JSON, and a 1,103-line static-page builder formed a second Widgetbook review system beside the live server and current coverage checker. | All four derived/static artifacts are deleted: 15,252 direct lines / 942,090 bytes. The live comparison server remains the review surface; current widget classification supplies source candidates; the live coverage checker supplies coverage; and reviewed decisions remain in their authored JSONL/latest authorities. No replacement snapshot is committed. |
| Staleness | The June 27 page showed 50 contracts, 708 components, and 714 use cases. Current coverage is 71 contracts and 956 source rows; the tracked coverage report retained 12 deleted rows and omitted 29 live rows. Its builder also carried 40 hard-coded overrides and a machine-specific Downloads path. | The focused live check reports 956 rows split into 169 roles, 510 features, and 277 screens, with zero decision-queue or stale-decision items. A full-index regression test prevents all four retired paths from returning and proves that the server no longer reads the report blob. |
| Live behavior | Static output could look current without proving that the actual review server still assembled its data. | The server is import-safe, exports its source-candidate predicate, and has two focused behavioral tests. The dynamic route served the existing `Catch Pattern Family Review` page title. The optional external Claude manifest was unavailable on this machine, so `/api/data` integration with that export remains unclaimed rather than being mistaken for a repository failure. |
| Executable proof | The static builder's manifest check only syntax-parsed the script; it did not regenerate or compare the page. | A fresh exact-SHA canary passes the two focused server tests and the 956-row live coverage check in 1.52s, manifest validation in 0.41s, 83-rule / 92-tool enforcement in 1.31s, test-inventory parity in 0.23s, 5,017/5,017 readiness in 0.92s, document monotonicity in 0.65s, and the 7,216-entry audit registry in 0.85s. No Flutter run was selected because no Dart or rendered UI changed. |
| Broker timing | Derived review cleanup previously encouraged edits and ad hoc checks in a full shared checkout. | The 45.8 MB canary started in 5.38s, ended at 50.5 MB, passed doctor in 3.35s, and reached a clean, remote-equal terminal state in 2.51s. Core commit `8ed7abf15` took 0.30s and pushed in 12.77s. |
| Line accounting | The twelve prior measured commits were cumulatively net −173,279 lines. | The 15-file authority consolidation, server repair, regression coverage, registry refresh, and audit receipt is +193/−15,379, net −15,186. The three-file checkpoint and canary receipt is +26/−4, net +22; the fourteen-commit measured series is therefore net −188,443 lines. |

Issue discovered during this tranche:

- `H2-TRANSITION-027` — `audit_registry.dart refresh --check` reads the index
  view for file-set changes. Before the four deletions and one addition were
  staged, it incorrectly reported the registry current; after staging, the same
  command correctly failed with exit 64 and exposed the five-path mismatch.
  Until the command either detects an unstaged file-set delta or makes its
  staging precondition explicit and fail-closed, run registry parity only after
  staging all additions and deletions and retain that ordering in task receipts.

### Checkpoint 21 — legacy widget-antipattern bundle retirement (2026-08-07)

| Signal | Before this slice | Current result |
|---|---|---|
| Duplicate authority | A 317-line Python regex scanner, a 154-line source-rewriting helper, and a committed 711-line heuristic report formed an untested widget-migration path beside current classification, delta, cleanup-ratchet, similarity, and reviewed-decision authorities. | The scanner, migrator, report, and both manifest entries are deleted. Current authorities remain unchanged; the existing full-index regression guard now keeps all six retired derived-audit paths absent. Historical receipts remain immutable. |
| Staleness and coverage | The July 15 report listed 15 files with findings, while a current isolated run found 17. The scanner changed after the report without refreshing it, and its syntax-only manifest check could not detect the drift. | Live cleanup reports one ratcheted candidate and passes. The current widget delta reports zero added, moved, or unresolved items. Manifest inventory falls from 272 to 270 total tools, 228 to 227 active tools, two to one support tool, and 19 to 17 audit tools without changing enforcement coverage. |
| Migration safety | The migrator discarded parameters when converting functions to classes, did not implement its own primitive-replacement disposition, globally renamed call sites, could not handle private-widget rows from its paired scanner, and had no behavioral test. | No automated source-rewriting replacement is introduced. Widget changes continue through current reviewed decisions, live finders, focused implementation, and normal verification. Recovery remains available from Git blobs `c0a46adf`, `74753cd6`, and `38021532`. |
| Fresh proof | Neither obsolete tool had an executable behavior test, and the tracked output had no parity check. | A fresh exact-SHA canary passes 11/11 workflow tests in 0.75s, manifest validation in 0.60s, 83-rule / 92-tool enforcement in 0.99s, the live cleanup ratchet in 1.19s, the zero-delta widget scan in 9.17s, two document-version increases in 0.58s, 5,017/5,017 readiness in 0.71s, test inventory in 0.15s, and 7,213-entry registry parity in 0.49s. No Flutter run was selected because no Dart or rendered UI changed. |
| Broker timing | A small cleanup still lacked a repeatable measured delivery loop. | The 45.8 MB task started in 4.15s and generated context in 0.13s. Core commit `cc3d5dfd0` took 0.07s and pushed in 4.31s. The 45.8 MB fresh canary started in 3.39s, passed doctor in 0.57s, and reached a clean, remote-equal terminal state in 1.31s. |
| Line accounting | The fourteen prior measured commits were cumulatively net −188,443 lines. | The nine-file core retirement is +20/−1,226, net −1,206. The three-file checkpoint receipt is +26/−4, net +22; the sixteen-commit measured series is therefore net −189,627 lines. |

Issue discovered while selecting the following tranche:

- `H2-TRANSITION-028` — a repository-wide scanner that walks the physical
  filesystem can report false drift in a correct sparse task. The Widgetbook
  variant inventory saw one materialized Dart file, skipped it, and called its
  current 26-file inventory stale; the same exact commit regenerated
  byte-equivalent content from a full archive. Repository-wide readers must use
  the captured repository snapshot abstraction, and their tests must prove full
  and sparse logical views agree before they are admitted to affected checks.

### Checkpoint 22 — live, sparse-safe Widgetbook variant finder (2026-08-07)

| Signal | Before this slice | Current result |
|---|---|---|
| Evidence authority | A 36,252-line / 999,970-byte JSON inventory duplicated data that the 0.05s finder can reconstruct from Widgetbook sources. It changed in 23 commits and generated 65,708 lines of Git churn. The comparison server loaded the full megabyte to obtain 46 review candidates. | The tracked JSON and two duplicate npm aliases are deleted. The import-safe finder emits deterministic summary or JSON on demand and never writes tracked output. The live comparison server calls it in process. The retired snapshot remains recoverable as blob `cef70389`. |
| Sparse truth | The generator recursively walked physical directories. This task materialized only `main.directories.g.dart`, which the generator intentionally skips, so `--check` falsely said a current inventory was stale. | The finder uses the captured repository snapshot and batch-reads sparse-omitted index blobs. With one physical Widgetbook Dart file, it sees all 26 logical files and returns 875 use cases, 822 components, 1,832 state cards, and 46 review candidates. Its complete output is semantically identical to the retired snapshot after removing the timestamp and updating the authority description. |
| Product behavior | Snapshot freshness was the only gate; it did not fail on excessive variants. The server could silently inherit stale candidate data. | The live builder validates non-vacuity and internal count consistency. Two seeded finder tests cover deterministic logical-source extraction and read-only CLI/JSON modes. Three server tests prove classification-only candidates, in-process variant derivation, and absence of every retired derived path. |
| Affected CI | Coupling the finder into the comparison server initially caused a finder edit to inherit the server's undeclared default: full repository view plus Node, Flutter, ripgrep, Flutter pub, root npm, Functions npm, and Playwright setup. | Both check surfaces now declare an index repository view with Node-only setup. An affected Widgetbook source selects the variant finder plus mandatory guards; a finder-source edit also selects the server test. A production-manifest regression test pins both plans as complete, affected, index-only, and Node-only. |
| Fresh proof | The old finder had no seeded test and its sparse check failed before evaluating repository truth. | A fresh exact-SHA canary passes finder 2/2 and server 3/3 in 1.57s, coverage with zero decision/stale queue in 0.34s, 27 repository-snapshot/impact tests in 1.15s, the live cleanup suite in 1.37s, manifest in 0.59s, 83-rule / 92-tool enforcement in 0.99s, three document-version increases in 0.50s, test inventory in 0.18s, 5,018/5,018 readiness in 0.55s, and 7,213-entry registry parity in 0.43s. No Flutter run was selected because no Dart or rendered UI changed. |
| Broker timing | The prior sparse task still carried the committed megabyte and the finder could not trust its view. | The 45.8 MB core task started in 3.43s and generated context in 0.12s; commit `003b38927` took 0.06s and pushed in 4.25s. The post-retirement canary materialized 44.8 MB in 3.44s, ended at 49.5 MB, passed doctor in 0.81s, and reached a clean, remote-equal terminal state in 1.24s. |
| Line accounting | The sixteen prior measured commits were cumulatively net −189,627 lines. | The 15-file conversion, tests, authority updates, generated registries, and audit receipt is +339/−36,389, net −36,050. The three-file checkpoint receipt is +34/−4, net +30; the eighteen-commit measured series is therefore net −225,647 lines. |

Issues discovered during this tranche:

- `H2-TRANSITION-029` — closed in Checkpoint 22. A selected tool without
  explicit CI requirements inherits the complete setup profile. Adding the
  live comparison server as a dependent check therefore turned a 0.05s Node
  finder into a full Flutter/npm/Functions/Playwright setup. Both tools now
  declare Node-only index checks, and the production-manifest impact test pins
  that bounded closure.
- `H2-TRANSITION-030` — the nominally read-only `dart
  tool/audit_registry.dart` command enters Flutter's SDK update wrapper and
  tries to rewrite shared engine stamp files. Restricted tasks fail before
  repository code, while the authorized rerun completes in about 0.4–0.5s.
  This is toolchain-environment friction, not a registry failure. Harness setup
  should provide a pinned hermetic Dart executable/cache or preauthorize the
  declared SDK-cache write once, so every fresh task does not pay a false-fail
  and escalation round trip.

### Checkpoint 23 — live-only localization usage ratchet (2026-08-07)

| Signal | Before this slice | Current result |
|---|---|---|
| Evidence authority | `docs/audit_registry/l10n_key_usage.json` committed 59,552 generated lines / 1,531,345 bytes even though the scanner could rebuild it in about 0.2–0.3s. The snapshot changed in 24 commits and generated 78,552 lines of historical diff churn. | The tracked snapshot is deleted and remains recoverable as blob `915393b7`. The only retained decision state is the empty eight-line / 445-byte orphan baseline. Exact usage evidence is emitted live with `--json`; the fresh artifact is 61,699 lines / 1,726,773 bytes raw, about 74.5 KB compressed, and retained by Flutter CI for 14 days rather than committed. |
| Enforcement behavior | Freshness compared one generated copy with another beside the actual missing-getter and orphan controls. The write/check flags made ordinary maintenance rewrite the repository. | Missing catalog getters still fail unconditionally, new orphans still fail the shrink-only baseline, and baseline growth is still refused. Thirteen seeded tests cover exact locations, lexer exclusions, deterministic CLI JSON, both refusal paths, retired flag/path absence, and help. The live result remains 2,835/2,835 used keys, zero orphan or missing keys, and 3,116 getter references. |
| Workflow evidence | Flutter CI required the committed copy to be current and had no failure artifact dedicated to localization usage. | Flutter CI writes `build/ci/l10n-key-usage.json`, prints only its summary and ratchet, and uploads the complete SHA-addressed artifact with `if: always()`, error-on-missing, and 14-day retention. Twelve workflow tests pin the command, artifact action/version, path, failure behavior, retention, and permanent absence of the retired snapshot. |
| Affected CI | The tool had no declared CI requirements, so a scanner-only edit inherited the full repository plus Node, Flutter, ripgrep, Flutter pub, root npm, Functions npm, and Playwright setup. | The physical `lib/` scan deliberately keeps the full repository view but declares Node as its only setup requirement. The affected plan is complete, selects the scanner plus mandatory guards, and reduces declared setup categories from seven to one without making a false sparse-safety claim. Nineteen impact tests pin the full-view / Node-only closure for scanner, test, baseline, and fixture changes. |
| Fresh proof | Stored-file parity could pass while preserving unnecessary Git churn. | A clean exact-SHA canary reproduced byte-identical live JSON at SHA-256 `a62cc071…`, passed scanner 13/13 in 0.55s, workflow/impact 31/31 in 0.38s, the live census in 0.36s, 83-rule / 92-tool enforcement in 0.49s, three document-version increases in 0.07s, 5,022/5,022 readiness in 0.37s, test inventory, manifest, Harness validation, and 7,212-entry registry parity in 0.30s. No Flutter run was selected because no Dart or rendered UI changed. |
| Broker timing | A small evidence-storage change still needed proof that its clean-room delivery loop stayed bounded. | Core commit `85c02436a` was effectively instantaneous and pushed in 4.17s. The 42.5 MB canary materialized in 3.47s, ended at 47.2 MB, passed doctor in 0.11s, emitted the full JSON in 0.10s, and reached a clean remote-equal terminal state in 1.05s after network authorization. An abbreviated-SHA attempt failed before mutation as designed. |
| Line accounting | The eighteen prior measured commits were cumulatively net −225,647 lines. | The 14-file core retirement is +212/−59,738, net −59,526. The three-file checkpoint receipt is +28/−4, net +24; the twenty-commit measured series is therefore net −285,149 lines. |

Issue discovered during this tranche:

- `H2-TRANSITION-031` — the task lifecycle's remote preservation checks run as
  nested Git commands inside the Node broker. In a restricted task, direct
  `git ls-remote` succeeds but `task start` reports that it cannot prove the
  branch unused, and `task finish` reports `remote_head_not_preserved` even
  while its cached upstream SHA equals `HEAD`. Authorized reruns complete in
  3.47s and 1.05s. The broker needs a declared read-only Git-network
  entitlement or an explicit remote-probe boundary so sandbox denial is not
  misreported as a branch collision or lost preservation.

### Checkpoint 24 — live-only provider topology and executable sparse closure (2026-08-07)

| Signal | Before this slice | Current result |
|---|---|---|
| Evidence authority | Four committed provider-graph views totaled 39,410 lines / 1,444,412 bytes: a README, interactive HTML, full JSON, and Mermaid projection. The graph builder could reconstruct them in about four seconds, while the only authored decision state was the 67-line / 4,278-byte review ledger. | All four projections are deleted and guarded from returning. `tool/architecture/provider_graph_reviews.json` remains the sole durable authored authority. Full graph JSON and compact summary evidence are deterministic, read-only, and emitted only on demand. The retired views remain exactly recoverable from blobs `b9be3c24`, `24fc1c28`, `e5b896f1`, and `498469e8`. |
| Maintenance cost | The projections changed in 16 commits and generated 51,722 lines of historical diff churn. The Dart tool also carried the fixed output path, tracked-file drift checks, a README/Mermaid renderer, and a large embedded HTML application. | Repository-writing `--write` exits 64. The renderer/drift layer is removed, shrinking the tool from 1,649 to 1,318 lines. Live `--check`, `--summary`, and `--json` build the AST graph once; `--check --summary` now emits evidence and still enforces health instead of returning before validation. |
| Topology behavior | Snapshot freshness was mixed into graph correctness, so a regenerated copy could dominate review even though the actual contract is resolvable providers plus current architecture decisions. | The live gate reports 820 Dart files, 230 providers, 84 Mutations, 421 provider callsites, 335 unique pairs, 164 cross-feature pairs, zero duplicate/dangling/provider-internal-unresolved/cycle findings, and ten fully reviewed candidates. Six focused tests cover topology extraction, live failure parity, deterministic JSON/summary, retired/conflicting CLI flags, stale/unreviewed decisions, and malformed planned decisions. |
| Affected CI | Provider-tool edits inherited the default full setup: Node, Flutter, ripgrep, Flutter pub, root npm, Functions npm, and Playwright. Review-ledger edits were unmapped and forced the same full fallback. | Tool and review-ledger edits are both affected plans with the required full source view but only Node, Flutter, and Flutter pub setup: seven declared setup categories fall to three. The existing Flutter test lane continues to own `test/tool/**`; no bespoke provider artifact upload or duplicate Flutter workflow scan was added. |
| Executable sparse closure | The original task passed `task doctor` while every Flutter command failed first on missing `apps/consumer` and `apps/host`, then on missing root assets and local package dependencies. Two manual sparse expansions were required before a 2.46s warm focused test could run. | Future tasks always materialize both Flutter workspace manifests, `assets/`, `packages/catch_ui_lints/`, and `packages/phosphor_flutter/`. The fresh exact-SHA canary required no repair: it passed doctor in 0.47s, its first dependency-resolving Flutter test run passed 6/6 in 8.19s, and the live graph passed in 4.67s. This reliability closure adds about 12.1 MB to this post-retirement task (50.8 MB prior baseline to 63.0 MB logical materialization), still only 23.5% of the 256 MB budget. |
| Fresh governance proof | A healthy lifecycle receipt did not prove that the declared Flutter commands could start from the task's physical projection. | The fresh canary passed 42/42 workflow, lifecycle, and impact tests in 2.31s; manifest validation; 83-rule / 92-tool enforcement; six monotonic document-version increases; test inventory; 5,022/5,022 readiness; 7,208-entry registry parity; and clean remote-equal closeout in 1.30s. The canary started and pushed its exact base in 3.25s. |
| Line accounting | The twenty prior measured commits were cumulatively net −285,149 lines. | Core commit `2f975bb6b` is +385/−39,968, net −39,583. This three-file checkpoint receipt is +36/−4, net +32; the 22-commit measured series is therefore net −324,700 lines. The core commit itself took 0.05s and pushed in 4.55s. |

Issues discovered during this tranche:

- `H2-TRANSITION-032` — closed in Checkpoint 24. Sparse-task health covered
  Git/worktree integrity but not the root Flutter workspace's executable
  closure. The broker now includes workspace manifests, local path packages,
  and declared assets; a fresh first-run Flutter test proves the repair.
- `H2-TRANSITION-033` — closed in Checkpoint 26. Task creation recorded logical recursive bytes while
  doctor reports allocated `du` bytes under the same apparent size series. The
  canary was 62,953,704 logical bytes at creation and 68,816,896 allocated bytes
  at doctor before build output. Rename and expose both units; do not calculate
  worktree growth by subtracting one from the other.
- `H2-TRANSITION-034` — closed in Checkpoint 26. The lifecycle tests removed their fixture contents but
  leave an empty ignored `.claude/test-fixtures` directory. Terminal inspection
  collapses this to an unknown `.claude/` path, so a clean remote-equal task can
  accumulate a false ignored-payload hazard. Test cleanup should remove only
  its empty session parents, or ignored inspection should distinguish empty
  directory markers from payload without allowlisting arbitrary `.claude/`
  contents.

### Checkpoint 25 — live-only React dependency topology (2026-08-07)

| Signal | Before this slice | Current result |
|---|---|---|
| Evidence authority | Three committed React dependency views totaled 24,529 lines / 768,053 bytes: a full JSON graph, Mermaid projection, and generated README. They changed in 23 commits and produced 28,247 lines of historical diff churn even though no live consumer read them. | All three projections are deleted and guarded from returning. The live TypeScript-AST graph is the only topology authority; deterministic `--summary` and `--json` evidence is emitted on demand. Exact recovery remains available from blobs `bf5b5507af6886253d6822324571b4ebc7bed1e7`, `967fc50ee1dc2dd30c26b09c31c1c299c6f07390`, and `c9dabac664de5aa178c496b021a41a6bff12da37`. |
| Live behavior | Snapshot freshness, repository-writing `--write`, an output-directory contract, and README/Mermaid renderers were mixed into the safety gate. The root-owned tool imported TypeScript only through accidental workspace hoisting. | Repository-writing and output-directory flags now exit 64. `--check`, `--summary`, and `--json` build the graph once; combined evidence/check mode prints inspectable JSON before a blocking failure. The root manifest now directly owns TypeScript 6.0.3. The live graph reports 359 scanned modules, 18 dependency leaves, 1,288 edges, zero unresolved imports or direct website/admin violations, and report-only counts of six runtime cycles, seven type-inclusive cycles, and zero nonliteral dynamic imports. |
| Affected CI | A graph-tool edit inherited seven setup categories; a `packages/web-ui` input was unmapped and forced full fallback. Admin and Marketing workflows also treated changes to the generated docs projection as deploy-worthy input. | Graph-tool, test, and shared web-ui inputs are complete affected plans with the required full repository view but only Node plus root npm: seven setup categories fall to two, a 71.4% reduction. Both generated-only workflow triggers are gone; the reusable React validation workflow retains the live check, while real Admin, Marketing, and shared-package inputs still trigger their owning surface lanes. |
| Fresh proof and timing | A sparse task could not prove the root tool installed its own parser dependency, and retry behavior obscured the difference between an install failure and an orchestration race. | Core commit `c3d516026` took 0.04s and pushed in 4.24s. A fresh exact-SHA canary started in 3.46s at 52,614,289 logical tracked bytes, passed doctor in 0.47s, completed one task-cache-scoped `npm ci` in 22.56s, resolved root TypeScript 6.0.3, passed the full graph tool in 1.19s, web-ui typecheck in 1.06s, 35/35 Harness/impact tests in 0.29s, manifest, 83-rule/92-tool enforcement, four document-version increases, test inventory, 5,023/5,023 readiness, 7,205-entry registry parity, and clean remote-equal finish in 0.97s. |
| Line accounting | The 22 prior measured commits were cumulatively net −324,700 lines. | Core commit `c3d516026` is +300/−24,755, net −24,455. This checkpoint and canary receipt are +39/−4, net +35; the 24-commit measured series is therefore net −349,120 lines. |

Issues discovered during this tranche:

- `H2-TRANSITION-035` — a yielded dependency installer can remain active while
  an escalated retry starts in the same worktree. Two overlapping `npm ci`
  processes then delete and extract into the same dependency tree: all 317
  observed registry requests succeeded, but the retry produced 303 extraction
  path `ENOENT` failures and package extraction continued 61 seconds after the
  retry exited. This is a missing same-worktree execution lease, not cache,
  network, sparse-checkout, or Git isolation failure. Exclusive setup commands
  must expose PID, argv, start time, and session identity; reject a concurrent
  mutator before it starts; PID-validate stale leases; and wait for or explicitly
  terminate the original process before retry. The single-process canary with a
  task-scoped npm cache passed in 22.56s.
- `H2-TRANSITION-036` — task creation budgets tracked materialization but not the
  dependency footprint implied by declared setup. This 256 MiB task started at
  52,614,289 logical tracked bytes, then root npm expanded the allocated
  worktree to 504,016,896 bytes (480.7 MiB, 1.88× budget), so doctor correctly
  blocked closeout with `materialized_budget_exceeded` after all checks passed.
  Setup planning must project or reserve dependency bytes, keep logical and
  allocated units explicit, and either assign a sufficient effective budget or
  reject the plan before installation. Removing only the three regenerable
  task-local `node_modules` trees restored the task to 56,750,080 allocated
  bytes and a healthy terminal state.

### Checkpoint 26 — truthful task lifecycle receipts (2026-08-07)

| Signal | Before this slice | Current result |
|---|---|---|
| Storage contract | V1 wrote `estimatedTrackedBytes` and `materializedBytes` from logical recursive sizes, then doctor/reap exposed allocated `du` bytes as `sizeBytes`. One observed task appeared to grow from 25,355,083 to 26,079,232 bytes solely because the unit changed, a false 724,149-byte / 2.86% delta. | New tasks write `catch.harness-task/v2` with explicit tracked-logical, projected-allocated, initial-logical, and initial-allocated fields. Budget, current size, reap totals, and growth are allocated-byte contracts. The exact canary separately reports 32,060,516 logical and 34,045,952 allocated initial bytes, then a valid allocated delta of zero. V1 remains dual-read but its allocated delta is `null`; new v2 output contains none of the three ambiguous keys. |
| Handoff truth | Doctor could reject metadata-path, sparse-checkout, base-ancestry, storage, ignored-payload, dependency, or reserve drift while finish independently missed several of those blockers. An unreachable origin was collapsed into `remote_head_not_preserved`, indistinguishable from a real remote mismatch. Unknown ignored payload could become terminal before reap rejected it. | Doctor and finish share one integrity implementation. Finish additionally returns a structured live origin result and separates `remote_head_query_unavailable` from `remote_head_not_preserved`. Reap blocks malformed v2 storage metadata. Failed validation cannot unlock the worktree or transition its receipt. |
| Fixture ownership | The nine-test lifecycle suite left an empty ignored `.claude/test-fixtures`; Git collapsed it to `!! .claude/`, creating a false unknown-payload hazard. A first cleanup attempt passed alone but failed under concurrent test processes because each test pruned shared parents. | One process-owned session remains nonempty for the module lifetime; tests remove only exact owned children, and module teardown uses `lstat` plus empty-only `rmdir` without following symlinks or recursively deleting shared parents. Four simultaneous focused processes passed 68/68 tests in 7.0s and left no `.claude` residue; files, symlinks, nonempty directories, and legitimate siblings fail closed or remain preserved. |
| Fresh proof and timing | Focused coverage was 9/9 in 2.10s and did not assert units, v1 compatibility, doctor/finish parity, ignored handoff state, remote-query state, or concurrent cleanup. The original sparse task could not physically start all checks named by its own context pack. | Core commit `77a915b04` is +679/−109, committed in 0.02s, pushed in 2.46s, and closed through the live remote check in 0.89s. A fresh full-tool v2 canary started and pushed in 2.91s, passed doctor in 0.31s, passed 17/17 focused tests in 5.67s, all 74 Harness tests in 6.34s, manifest, 83-rule/92-tool enforcement, live and 6/6 tested root hygiene, test inventory, 5,033/5,033 readiness, and retained zero ignored payload with zero allocated growth. |
| Line accounting | The 24 prior measured commits were cumulatively net −349,120 lines. | Core commit `77a915b04` is net +570. This evidence receipt is +42/−3, net +39; the 26-commit measured series is therefore net −348,511 lines. |

Issues closed or discovered during this tranche:

- `H2-TRANSITION-033` — closed. V2 names every storage unit and permits only
  allocated-to-allocated growth; v1 stays readable without an invented
  baseline.
- `H2-TRANSITION-034` — closed. Process-owned fixture sessions remove exact
  children and prune shared parents only when ordinary and empty. Unknown or
  uninspectable ignored payload now blocks doctor and finish.
- `H2-TRANSITION-037` — closed. Finish now distinguishes an unavailable live
  origin query from a verified remote-head mismatch and exposes expected and
  observed heads when available.
- `H2-TRANSITION-038` — closed in Checkpoint 27. Every new start requires a
  clean, base-bound context pack; structured check ids derive exact physical
  entrypoints and support-only paths; directory selection is recomputed from
  tracked descendants at the base SHA; v3 receipts bind task, mode, scope,
  checks, closure, and digest; doctor/finish enforce the same owned-versus-
  support boundary. V1/v2 stay read-compatible, but the old v2 writer path is
  deleted.

`H2-TRANSITION-035` (same-worktree mutator lease) remains open.
`H2-TRANSITION-036` (setup-footprint projection) is partially improved: the
shared task-input path now selects Node only instead of all seven setup groups,
but a repository-wide install-footprint budget is still absent.

### Checkpoint 27 — task command closure and clean-clone canary (2026-08-07)

| Signal | Before this slice | Current result |
|---|---|---|
| Start authorization | New worktrees could be created from manually typed paths while the context pack named commands whose entrypoints were absent. The pack's task id, cleanliness, base, directory descendants, and selected checks were not one startability contract. | New starts are v3-only and require a complete `parallel-delegation` pack. Task id, mode, clean base SHA, normalized owned scope, tracked descendant selection, structured task/deferred checks, physical entrypoints, support paths, and digest are recomputed from base authorities and fail closed before registration. Absolute/traversal/missing paths, stale or under-scoped packs, malformed receipts, symlink escape, and support-path edits are covered. V1/v2 readers remain; no legacy writer remains. |
| Execution ownership | One undifferentiated command list mixed worker checks, lifecycle mutation, full-repository integration, Flutter analysis, canonical registry writes, and raw regression commands. | Every command carries `owner` and `phase`. The evidence worker received only `doctor` plus `agent:readiness` and root hygiene; the parent retained start/finish, full-view integration, canonical evidence, and unstructured guidance. Exact three-file evidence scope produced two worker and eight parent commands. |
| Routing/setup fanout | A change to shared task-input logic could conservatively fan out across all 227 active tools and all seven setup categories. Tool-only scopes also fell back to documentation hygiene. | Exact ownership selects 7/227 active tools, a 96.9% reduction, with one Node setup category, an 85.7% reduction. A new 15-line tooling router replaces the documentation fallback. An Explore projection estimates 855 files / 20.88 MiB instead of 7,276 files / 156.75 MiB: 88.2% fewer files and 86.7% fewer tracked bytes. |
| Log volume | `--output` still duplicated the complete JSON pack to stdout; one measured pack was 95,531 bytes. | The artifact remains complete on disk while stdout is a 217-byte task/digest receipt, a 99.77% reduction. The registered context-pack owner check now uses this path. |
| Live canary and failure discovery | Dirty implementation worktrees could mask assumptions that fail only after commit. Full-view checks were often attempted late or inside a sparse worker. | Core `4e5bd7814` committed in 0.04s and pushed in 4.92s. Canary a1 started in 3.20s, passed doctor in 0.45s and worker checks in 3.33s, then its clean full clone exposed one environment-dependent assertion. The bounded one-file fix `306bc6410` committed in 0.02s, pushed in 2.01s, passed 33/33 runner tests in 11.24s, worker checks in 1.49s, and the exact full parent closure in 79.41s. A non-temp full clone was required because OS-temp task roots intentionally fail closed. |
| Corrected v3 rehearsal | The prior evidence canary declared the whole `tool/` tree to avoid missing entrypoints. | Canary a2 started from exact fix SHA `306bc6410` in 3.32s with only the plan plus two audit ledgers writable. It materialized 27,111,194 logical / 29,011,968 allocated bytes, passed doctor in 0.46s, passed its 19 worker tests plus live checks in 3.47s at 5,099/5,099 readiness, and retained zero allocated growth before the evidence edit. Parent full-view checks had already passed at the exact base SHA. |
| Verification | Focused checks did not prove the same tree from dirty, clean, sparse, and full views. | The implementation tree passed 137/137 focused checks, then exact registered owners passed 54 runner, 91 Harness, 11 task-input, 13 readiness, 19 enforcement, six root-hygiene, and two inventory tests in 26.98s. Harness validation, 83-rule/92-tool enforcement, manifest validation, audit parity, root hygiene, inventory, and 5,099/5,099 readiness pass. Independent clean-clone review reproduced the one canary defect before the fix. |
| Line accounting | The 26 prior measured commits were cumulatively net −348,511 lines. | Core `4e5bd7814` is +2,406/−252, net +2,154; clean-clone fix `306bc6410` is +13/−9, net +4; this evidence receipt is +47/−20, net +27. The 29-commit measured series remains net −346,326 lines. This tranche deliberately adds the missing executable contract and tests while deleting the unreachable v2 writer branches; the preceding retirement tranches remain overwhelmingly deletion-negative. |

Issues closed or discovered during this tranche:

- `H2-TRANSITION-038` — closed. Structured closure now reaches start, sparse
  materialization, doctor, worker checks, parent integration, and finish.
- `H2-TRANSITION-039` — closed operationally. A full integration clone under
  `/private/tmp` correctly made 15 lifecycle fixtures refuse OS-temp task roots.
  Full lifecycle integration rehearsals now run from a non-temp disposable
  clone; production safety was not weakened to accommodate the test runner.
- `H2-TRANSITION-040` — open. One owned directory is still both the write
  ceiling and the impact-selection root. `docs/audit_registry` selected three
  skills, 22 regressions, 20 deferred checks, and 40 parent commands; naming
  the three actually writable files selected one skill, five deferred checks,
  and eight parent commands (75% fewer deferred checks and 80% fewer parent
  commands). A later slice should split `ownedPaths` from reviewed
  `plannedImpactPaths`, then reconcile actual diff paths at finish, rather than
  teaching users to over-broaden or hand-minimize one overloaded field.

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

- Continuous worktree heartbeats or automatic removal. The bounded lifecycle
  wrapper and report-only reap exist; deletion remains owner-authorized and
  outside the broker.
- External receipt/artifact store; GitHub artifacts carry the required digest
  and provenance manifest.
- Atomic multi-change-set merge machinery.
- Any new dashboard, score, or metrics product.
- Untracking compile-critical generated source.
- Automation of Remote Config deploys or index deletions.
