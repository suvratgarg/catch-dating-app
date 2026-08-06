---
doc_id: harness_v2_decision_and_cicd_delivery_plan
version: 0.3.13
updated: 2026-08-06
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
