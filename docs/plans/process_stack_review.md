---
doc_id: process_stack_review
version: 2.0.0
updated: 2026-08-31
owner: agent_operating_model
status: active
---

# Engineering Process Standard And Improvement Plan

## Purpose

This document translates the process advice in Jez Humble and David Farley's
*Continuous Delivery* and Google's *Software Engineering at Google* into an
operating standard for Catch. It serves two audiences at once:

- a reader who wants to understand what the books recommend, what Catch does
  today, and where the gaps are; and
- an implementing agent or engineer who needs an ordered, verifiable checklist
  for improving the pipeline without losing work or weakening delivery safety.

This is the durable owner for that comparison and improvement backlog. The
implementation mechanics remain owned by
[`agent_operating_model.md`](../agent_operating_model.md),
[`ai_first_workflow_guide.md`](../ai_first_workflow_guide.md), and
[`release_operations.md`](../release_operations.md). Do not create a second
process tracker or a tracked metrics ledger. Update this document when the
standard or backlog changes; keep time-series evidence in GitHub, CI summaries,
or expiring CI artifacts.

The title *Continuous Delivery* is used below. If a discussion calls it
*Continuous Deployment*, remember that continuous delivery means every accepted
change is releasable, while continuous deployment additionally releases every
accepted change automatically. Catch can adopt the former without requiring the
latter for every production surface.

## How To Read This Document

The books are not certification standards, and neither book supplies one finite
compliance checklist. The catalogue below covers their project-level,
process-relevant advice: culture and leadership, knowledge, code ownership,
version control, testing, build, integration, delivery, operations, and
measurement. It intentionally does not reproduce every anecdote or
technology-specific example.

Each practice has one of four current-state labels:

- **Established** — the practice has a current owner and executable or live
  evidence.
- **Partial** — useful machinery exists, but coverage, enforcement, or feedback
  is incomplete.
- **Gap** — the practice is materially absent or contradicted by current
  behavior.
- **Not measured** — the repository does not yet contain enough outcome
  evidence to make a responsible claim.

Counts and GitHub settings in this document are a dated audit snapshot, not
permanent facts. Re-run the commands in [Baseline and measurement](#baseline-and-measurement)
before acting on them.

## Executive Verdict

Catch is strongest where a rule has been turned into an executable contract:
owned architecture documents, generated data contracts, affected-change
planning, derived CI gates, exact-artifact delivery, environment separation,
and preservation-first Git tooling. Those mechanisms align well with both
books.

The most important gaps are not a lack of tools. They are gaps between the
declared process and the actual completion signal:

1. A working branch is treated as preserved once it is clean and pushed, even
   though it may never be reviewed or integrated into `main`.
2. `main` requires CI but not independent review. Recent merged changes are
   often much larger than a single reviewable batch.
3. Engineering flow and reliability outcomes are not measured consistently, so
   process changes cannot yet be judged against a stable baseline.
4. Nightly and branch-hygiene failures provide evidence, but there is no common
   service-level objective, error-budget, incident-review, and action-closure
   loop across the delivery system.
5. AI increases production capacity much faster than review capacity. Without
   smaller slices, independent verification, and one integration owner, more
   agents can create more stranded work and more correlated mistakes.

The first operating change is therefore trunk-based development with ephemeral
review branches, not unrestricted direct pushes to `main`.

## Book-Derived Process Standard

### A. Organization, people, and knowledge

| ID | Advice from the books | Catch today | Status | Required refinement |
| --- | --- | --- | --- | --- |
| P01 | Optimize for software sustainability across its expected lifetime, not only immediate output. Make decisions against time and scale. [SE at Google ch. 1](https://abseil.io/resources/swe-book/html/ch01.html) | Durable owner documents, versioned contracts, and migration plans explicitly address change over time. Completion metrics still emphasize source/check state more than long-term operating cost. | Partial | Add maintenance, deprecation, reliability, and operator-cost acceptance criteria to broad task contracts (`PROC-13`, `PROC-18`). |
| P02 | Work as a team: make ownership explicit, enable psychological safety, and use blameless learning after failures. [SE at Google ch. 2](https://abseil.io/resources/swe-book/html/ch02.html) | File and surface ownership are documented. The repository contains incident lessons, but there is no single lightweight incident threshold and action-closure mechanism. | Partial | Establish the incident and learning loop in `PROC-17`; assess systems and controls, not individual blame. |
| P03 | Scale leadership by defining direction, delegating bounded decisions, and keeping accountability for the integrated result. [SE at Google ch. 5](https://abseil.io/resources/swe-book/html/ch05.html) and [ch. 6](https://abseil.io/resources/swe-book/html/ch06.html) | Broad tasks require a goal, scope, exclusions, checks, and acceptance. Parallel work requires a parent integration owner. | Established | Enforce those fields in task intake and make integration proof mandatory (`PROC-04`, `PROC-08`). |
| P04 | Make knowledge discoverable through teaching, documentation, review, and communities rather than relying on private memory. [SE at Google ch. 3](https://abseil.io/resources/swe-book/html/ch03.html) | `AGENTS.md`, the docs index, owner documents, planner, context pack, and tool manifest provide strong routing. Their effectiveness for onboarding and incident recovery is not measured. | Partial | Measure failed-gate discovery and documentation-driven recovery; fix routing at its owner when a miss occurs (`PROC-13`, `PROC-19`). |
| P05 | Treat equity, accessibility, and differing user and contributor contexts as engineering inputs, not late review. [SE at Google ch. 4](https://abseil.io/resources/swe-book/html/ch04.html) | Product and design documents include accessibility and privacy constraints on selected surfaces. No repository-wide accessibility outcome gate is evidenced by this review. | Partial | Add risk-based accessibility, privacy, localization, and device coverage to task and release acceptance (`PROC-14`). |
| P06 | Measure productivity as a multidimensional system of outcomes, quality, flow, satisfaction, and trade-offs; do not mistake activity for productivity. [SE at Google ch. 7](https://abseil.io/resources/swe-book/html/ch07.html) | CI produces abundant activity evidence, but Catch does not yet maintain a small engineering-flow scorecard. Lines, commits, tokens, and agent count are not valid success measures. | Gap | Implement the three primary KPIs and guardrails below (`PROC-01`, `PROC-19`). |
| P07 | Give documentation the same ownership, audience, lifecycle, and review discipline as code. Prefer documentation close to the thing it governs. [SE at Google ch. 10](https://abseil.io/resources/swe-book/html/ch10.html) | Frontmatter, one-owner routing, a docs index, metadata checks, and a ban on duplicate trackers are established. Some long documents still depend on human discovery. | Established | Keep the owner model; add checks for broken routing and retire superseded guidance in the same change (`PROC-13`). |

### B. Source, change, and review

| ID | Advice from the books | Catch today | Status | Required refinement |
| --- | --- | --- | --- | --- |
| P08 | Use consistent style and automated rules to reduce avoidable debate and make code easier to change. [SE at Google ch. 8](https://abseil.io/resources/swe-book/html/ch08.html) | Formatters, analyzer rules, custom lints, source metadata, contract checks, and registered scanners are extensive. | Established | Keep rules executable and delete prose-only duplicates; evaluate false positives and runtime cost (`PROC-13`). |
| P09 | Require timely code review by someone other than the author; review correctness, design, complexity, tests, naming, comments, style, and documentation. [SE at Google ch. 9](https://abseil.io/resources/swe-book/html/ch09.html) | `main` requires `Required CI`, conversation resolution, administrator enforcement, and linear history. It currently requires zero approving reviews; none of the latest 50 merged PRs had a GitHub review decision. | Gap | Add independent review by risk tier and protect it from same-agent self-approval (`PROC-07`, `PROC-09`). |
| P10 | Give reviewers tooling that presents a small, understandable change with tests and history; optimize for review quality and latency. [SE at Google ch. 19](https://abseil.io/resources/swe-book/html/ch19.html) | PRs and local diff tools exist, but 28 of the latest 50 merged PRs exceeded 1,000 changed lines and 19 exceeded 50 files. Generated and authored changes are not uniformly separated. | Gap | Add reviewability advisories, generated-diff classification, and reviewer context packets (`PROC-06`, `PROC-08`). |
| P11 | Keep one authoritative version-control history and favor trunk-based development: integrate small changes into the trunk frequently and avoid long-lived development branches. [SE at Google ch. 16](https://abseil.io/resources/swe-book/html/ch16.html); [CD continuous integration](https://continuousdelivery.com/foundations/continuous-integration/) | `origin/main` is authoritative and production delivery is main-driven. Branches are single-use preservation units, but the current remote audit found 14 branches older than 48 hours without integration proof and 11 older than seven days without an open PR or integration proof. | Gap | Adopt the trunk policy in the next section and implement `PROC-02` through `PROC-06`. |
| P12 | Make developer tools easy to discover and search across the codebase; derive applicable workflows instead of relying on memory. [SE at Google ch. 17](https://abseil.io/resources/swe-book/html/ch17.html) | The planner, tool manifest, `tool/run.mjs`, and `verify_local.mjs` derive affected checks. This materially improves on the earlier historical audit that found gates through CI failure. | Established | Make derived verification the only documented local gate entry and measure unmapped targets (`PROC-13`). |
| P13 | Manage dependencies deliberately: control versions, evaluate compatibility and security, automate updates, and retain the ability to migrate away. [SE at Google ch. 21](https://abseil.io/resources/swe-book/html/ch21.html) | Lockfiles, dependency workflows, and grouped Dependabot updates exist. [PR #303](https://github.com/suvratgarg/catch-dating-app/pull/303) currently groups 21 packages and fails dependency resolution, showing that batching and ownership still need refinement. | Partial | Establish bounded update groups, compatibility checks, owner routing, and supply-chain policy (`PROC-15`). |
| P14 | Execute large-scale changes incrementally, with tooling, migration stages, backsliding prevention, and explicit completion. [SE at Google ch. 22](https://abseil.io/resources/swe-book/html/ch22.html) | Architecture trackers, schemas, generated outputs, migration contracts, and exact merge-drop audits exist. Large PR sizes and lingering branches show incomplete batch control. | Partial | Require staged migrations and acceptance per slice; prevent new legacy usage before removing old paths (`PROC-06`, `PROC-16`). |
| P15 | Deprecate deliberately: warn, migrate users, prevent new use, remove compatibility code, and verify completion. [SE at Google ch. 15](https://abseil.io/resources/swe-book/html/ch15.html) | Several migration documents distinguish compatibility and retirement, but there is no common expiration and stale-deprecation gate. | Partial | Add owner, deadline, use-count, backsliding check, and removal criteria to every deprecation (`PROC-16`). |

### C. Build, analysis, and testing

| ID | Advice from the books | Catch today | Status | Required refinement |
| --- | --- | --- | --- | --- |
| P16 | Make builds repeatable, isolated, and sufficiently hermetic that the same source and declared inputs produce the same outputs. [SE at Google ch. 18](https://abseil.io/resources/swe-book/html/ch18.html); [CD configuration management](https://continuousdelivery.com/foundations/configuration-management/) | Pinned dependencies, lockfiles, worktree bootstrap, generated-output freshness checks, and exact-artifact packaging are established. Native toolchains and external stores are not fully hermetic. | Partial | Record and verify remaining external inputs; test clean bootstrap and artifact identity (`PROC-12`, `PROC-20`). |
| P17 | Use static analysis early and centrally, with actionable results and a path for suppressions that does not normalize failure. [SE at Google ch. 20](https://abseil.io/resources/swe-book/html/ch20.html) | Analyzer, fatal-info CI, custom lints, schema checks, and specialized scanners are strong. | Established | Track false-positive waivers with owners and expiry; keep local and CI commands derived from the same source (`PROC-13`). |
| P18 | Build quality in with a layered test strategy: many small tests, fewer larger tests, and explicit coverage of important integration and end-to-end risks. [SE at Google ch. 11](https://abseil.io/resources/swe-book/html/ch11.html); [CD test automation](https://continuousdelivery.com/foundations/test-automation/) | Unit, widget, contract, emulator, integration, native build, golden, and smoke-test layers exist. Nightly visual integration and both iOS simulator build jobs are failing in the audit snapshot. | Partial | Restore the nightly signal, define ownership and repair time, then measure escaped failures rather than raw test count (`PROC-10`, `PROC-14`). |
| P19 | Keep unit tests fast, deterministic, behavior-focused, and independent. Avoid tests that merely mirror implementation. [SE at Google ch. 12](https://abseil.io/resources/swe-book/html/ch12.html) | Focused tests and test-size checks exist; bounded frame advancement and behavior seams are documented for Flutter. Flake rate and quarantine age are not measured centrally. | Partial | Add deterministic retry evidence, quarantine expiry, and mutation/known-bad checks for critical gates (`PROC-10`, `PROC-13`). |
| P20 | Use test doubles only at stable boundaries; prefer realistic collaborators where excessive mocking would hide integration risk. [SE at Google ch. 13](https://abseil.io/resources/swe-book/html/ch13.html) | Repository seams, fakes, Firebase emulators, and contract tests support this direction, but this audit did not quantify excessive mocking. | Not measured | Add the question to architecture review and sample high-risk features before creating a new rule (`PROC-14`). |
| P21 | Maintain larger tests for behavior that smaller tests cannot establish, with clear ownership, useful diagnostics, and controlled cost. [SE at Google ch. 14](https://abseil.io/resources/swe-book/html/ch14.html) | Integration, emulator, build, golden, capture, and smoke surfaces exist, but nightly failures reduce trust in the top of the pyramid. | Partial | Define a critical-journey suite, repair SLA, environment owner, and failure triage path (`PROC-10`, `PROC-14`). |

### D. Integration and delivery

| ID | Advice from the books | Catch today | Status | Required refinement |
| --- | --- | --- | --- | --- |
| P22 | Put all code, configuration, scripts, schemas, and environment definitions needed to reproduce a release under controlled versioning. [CD configuration management](https://continuousdelivery.com/foundations/configuration-management/) | Application code, infrastructure configuration, workflows, schemas, and deployment scripts are versioned. Live cloud and store state can still diverge and therefore requires direct verification. | Established | Keep source-controlled intent plus live preflight/postcondition checks; never treat checked-in state as deployment proof (`PROC-12`). |
| P23 | Integrate at least daily; every accepted change should trigger fast automated checks, and a broken build is the team's first repair priority. [SE at Google ch. 23](https://abseil.io/resources/swe-book/html/ch23.html); [CD continuous integration](https://continuousdelivery.com/foundations/continuous-integration/) | `Required CI` gates pull requests and `main`; affected checks are derived. Long-lived branches violate daily integration, and nightly failures demonstrate that not every shared signal is kept green. | Partial | Enforce the 24/48-hour branch clock, add a nightly repair owner and repair objective, and measure time-to-green (`PROC-03`, `PROC-10`). |
| P24 | Use one deployment pipeline that gives rapid feedback first, increases confidence in later stages, and makes release state visible. [SE at Google ch. 24](https://abseil.io/resources/swe-book/html/ch24.html); [CD deployment pipeline](https://martinfowler.com/bliki/DeploymentPipeline.html) | The Delivery workflow, aggregate `Required CI`, environment jobs, packaging, and promotion records form a substantial deployment pipeline. | Established | Add the flow and reliability scorecard and prove each stage's owner, timeout, and failure recovery (`PROC-11`, `PROC-19`). |
| P25 | Build an artifact once, then promote the same immutable artifact; do not rebuild differently for later environments. [CD deployment patterns](https://continuousdelivery.com/implementing/patterns/) | Exact-artifact packaging and promotion are explicit release invariants. | Established | Add periodic artifact-identity exercises and fail closed on provenance mismatch (`PROC-12`). |
| P26 | Use the same automated deployment mechanism in every environment, then verify environment-specific configuration and smoke tests. [CD deployment patterns](https://continuousdelivery.com/implementing/patterns/) | Shared workflow code and environment-separated credentials are strong. Some production gates and third-party store behavior necessarily differ. | Partial | Contract-test deploy paths and require environment postconditions instead of assuming parity (`PROC-12`). |
| P27 | Decouple deployment from user release where risk warrants it; use dark launch, feature flags, canaries, and incremental rollout with fast rollback. [CD deployment patterns](https://continuousdelivery.com/implementing/patterns/) | Main-driven delivery and store promotion exist. Shared `prod` has a reviewer gate, while `prod-hosting` and `prod-mobile` are intentionally approval-free and main-bound. A unified policy for flag ownership, expiry, progressive rollout, and rollback evidence is not established by this review. | Partial | Define release-risk tiers, rollout/rollback paths, flag expiry, and emergency authority (`PROC-11`). |
| P28 | Evolve databases and APIs with backward-compatible, expand/migrate/contract steps so application and data changes can be deployed independently. [CD deployment patterns](https://continuousdelivery.com/implementing/patterns/) | Schema contracts, migration dry-runs, compatibility states, rules tests, and data-contract checks are strong. Historical receipts have drifted from live state, so direct measurement remains mandatory. | Established | Make live dry-run/postcondition proof authoritative and add expiry to compatibility stages (`PROC-12`, `PROC-16`). |

### E. Operations and continuous improvement

| ID | Advice from the books | Catch today | Status | Required refinement |
| --- | --- | --- | --- | --- |
| P29 | Shorten and amplify feedback loops from development through production; make failures visible and actionable. [CD principles](https://continuousdelivery.com/principles/) | CI, branch hygiene, analytics, deployment checks, and runtime validation surfaces exist. They do not yet roll up to a small owner-based reliability view. | Partial | Define delivery and critical-service signals, owners, alert thresholds, and time-to-repair (`PROC-17`, `PROC-19`). |
| P30 | Design for low-risk change, repeatable recovery, and continuous improvement rather than relying on heroics. [CD principles](https://continuousdelivery.com/principles/); [SE at Google ch. 24](https://abseil.io/resources/swe-book/html/ch24.html) | Backups before history rewrite, immutable artifacts, rollback guidance, guarded data changes, and environment controls exist. Recovery exercises and change-failure rate are not measured consistently. | Partial | Add restore/rollback drills and record change failures and recovery time (`PROC-17`, `PROC-20`). |
| P31 | Use blameless incident analysis to correct system conditions, assign durable actions, and verify those actions close. [SE at Google ch. 2](https://abseil.io/resources/swe-book/html/ch02.html) | Historical incident lessons have improved rules and tools. No common trigger, owner, due date, and effectiveness review is evidenced. | Gap | Implement a lightweight incident template and action-closure check without creating a second permanent ledger (`PROC-17`). |
| P32 | Treat compute capacity, latency, reliability, and cost as engineering design constraints, not afterthoughts. [SE at Google ch. 25](https://abseil.io/resources/swe-book/html/ch25.html) | Platform-specific constraints appear in architecture and operations documents. This process audit found no common capacity forecast or cost guardrail for the delivery system. | Not measured | Identify critical capacity/cost risks and add thresholds only where decisions require them (`PROC-18`). |

## The Trunk-Based Development Decision

### The call-out is substantially correct

The user's reading was not a misunderstanding. *Software Engineering at Google*
uses the term **trunk-based development** and describes Google's model as one
repository without development branches. It argues that long-lived development
branches delay feedback, make merges harder, and permit incompatible versions of
reality. *Continuous Delivery* likewise requires frequent integration into
trunk and says GitHub-style branching remains compatible only when branches are
very short-lived.

The durable principle is:

> There is one authoritative evolving product state, and unfinished work is
> integrated into it in very small safe steps instead of diverging for days or
> weeks.

This does **not** mean that every repository must allow every engineer or agent
to push unchecked code directly to `main`. Catch's `main` drives CI and delivery
surfaces. Short pull-request branches are appropriate as ephemeral review
buffers, provided they do not become alternate development lines.

### Catch target policy

> All product development targets `origin/main`. A branch is a disposable,
> single-purpose review buffer, never a place where a project lives. A task is
> complete only when its accepted commit is verified on `origin/main`, or when
> the task is explicitly abandoned after its unique work has been classified
> and preserved or discarded by an authorized reviewer.

Operational rules:

1. Start every new task from a freshly fetched exact `origin/main` SHA.
2. Create one branch for one coherent, reviewable slice and publish it early.
3. Open a draft PR within two working hours of the first unique commit.
4. Integrate at least daily. At 24 hours, a branch is **at risk**; at 48 hours,
   it is **overdue** and blocks starting another ordinary slice for the same
   owner until it is merged, split, or explicitly abandoned.
5. Prefer changes that can be reviewed in one sitting. Lines and file counts are
   advisory diagnostics, not quality targets; generated and vendored changes
   are classified separately.
6. Use backward-compatible changes, dark paths, or expiring feature flags to
   keep incomplete features safe on `main`.
7. Require `Required CI` and risk-appropriate independent review before merge.
8. Enable auto-merge after approval so waiting for a button does not extend
   branch lifetime.
9. Verify the accepted commit or squash result on `origin/main`; then remove the
   disposable worktree and branch.
10. Never delete an overdue branch merely because it is old. First classify its
    unique commits and paths as integrated, superseded, intentionally abandoned,
    or still valuable.

### Why work has felt lost

Git usually retains the bytes, but the process loses the work when a pushed
branch has no active PR, no integration owner, no deadline, and no completion
event. Catch currently has two related controls:

- `branch_hygiene.mjs` identifies branches after seven days using tip commit
  age and PR/integration evidence; and
- `worktree_guard finish` proves a worktree is clean and its unique commits are
  pushed before releasing the local claim.

Those are preservation controls, not integration controls. A new commit resets
tip age; an indefinitely open PR remains active; and `finish` does not prove the
change reached `origin/main`. The repair is to measure branch divergence and PR
age, assign an integration owner, and make integration or explicit abandonment
the final state.

### Required state machine

```text
fresh origin/main
  -> task contract and claimed paths
  -> ephemeral branch and early draft PR
  -> small authored change plus derived checks
  -> independent review by risk tier
  -> Required CI and auto-merge
  -> accepted commit verified on origin/main
  -> worktree and branch retired

exception:
  overdue or superseded
  -> classify every unique commit/path
  -> preserve/import, or explicitly abandon with reason and reviewer
  -> retire branch only after classification
```

## Amendments For An AI-First Development Workflow

The books' constraints changed; their control theory did not. AI makes code,
tests, documentation, and alternatives cheaper to produce. It does not make
intent, integration, independent judgment, production authority, or user
outcomes cheaper to verify. The workflow therefore needs these amendments:

| AI-first amendment | Required behavior | Enforcement or evidence |
| --- | --- | --- |
| Treat generation as proposal, not authority | An agent may propose source and tests; accepted truth is the reviewed diff, derived checks, live system state, and user-visible outcome. | Task prompt and completion report separate proposal, source, merge, deploy, and runtime states. |
| Preserve reviewer independence | The same model context must not diagnose, implement, write the only test, and approve a high-risk change. Use a fresh-context reviewer or human approver based on risk. | Risk label and review record; mutation or known-bad test for critical controls. |
| Scale by review capacity | Add agents only when work can be divided into non-overlapping, independently reviewable slices with one parent integration owner. | Claimed paths, early PRs, batch-size diagnostics, integration owner. |
| Assume correlated error | Multiple agents given the same diagnosis can reproduce the same false assumption. Give reviewers symptoms and evidence, not the proposed conclusion. | Reviewer context packet includes problem, reproduction, constraints, diff, and counter-evidence. |
| Derive context and gates | Do not rely on a prompt's remembered check list, stale branch name, old receipt, or partial file excerpt. | Fresh fetch, whole-unit reading, planner, `verify_local.mjs`, live pre/postconditions. |
| Separate authored and generated changes | Generated output can overwhelm meaningful review. Keep source/schema changes and their deterministic generated result identifiable. | PR classification and generator freshness check; no hand edits to generated output. |
| Make silence observable | A living agent process is not proof of progress. Long-running work needs bounded phases, output or child-work evidence, timeout, and a stalled state. | Monitor reports last meaningful state change and fails or asks for attention after the defined threshold. |
| Commit and publish coherent slices | AI sessions can be interrupted. No intended work may exist only in an uncommitted tree, stash, reflog, or local-only ref. | Explicit-path commit, remote ref, draft PR, then integration proof. |
| Keep humans on consequential authority | Legal, privacy, destructive data, credentials, payments, production migration, and irreversible release decisions require named human authority even when checks pass. | Risk-tier protection and environment approval. |
| Measure outcomes, not AI activity | Tokens, prompts, agent count, generated lines, and commits are cost/activity observations, not productivity or quality metrics. | Use the primary KPIs and guardrails below. |
| Minimize simultaneous change | AI can cheaply produce large cross-cutting diffs, but causality and rollback worsen as simultaneous variables increase. | One coherent hypothesis per slice; staged migrations; compare outcome before next process change. |
| Capture durable learning in owners and rules | If an incident reveals a recurring condition, update the owning doc and preferably its test/scanner. Do not create a session ledger. | Owner document, executable regression check, PR and CI history. |

### Risk tiers

| Tier | Examples | Minimum merge authority |
| --- | --- | --- |
| R0 — mechanical | Formatting, deterministic regeneration, typo with no semantic effect | Required CI; automated approval is acceptable when authorship and generated provenance are clear. |
| R1 — bounded | Local behavior with focused tests, non-sensitive UI, reversible tooling | Required CI plus independent fresh-context review. |
| R2 — consequential | Auth, privacy, money, data contracts, deployment logic, broad architecture, migrations | Required CI, independent technical review, named human approval, and rollback/postcondition plan. |
| R3 — irreversible or regulated | Production destructive data operation, credential/authority expansion, legal or safety decision, public irreversible release | R2 controls plus explicit authorized operator approval at execution time and verified recovery or containment plan. |

Risk is based on impact and reversibility, not on diff size. A one-line permission
change can be R3; a large deterministic regeneration can be R0.

## Baseline And Measurement

### Audit snapshot

Snapshot date: **2026-08-31**. Source base:
`af38e06baac31d8e1e1b458c8741f131361ec732` (`origin/main`).

| Signal | Current baseline | Meaning and caveat |
| --- | --- | --- |
| Remote branch state | 22 non-main remote branches: 2 open-PR, 4 newer than 48h, 2 integrated, and 14 older than 48h without PR/integration proof. At the current seven-day policy: 11 are classified abandoned and 2 are supervised prune candidates. | Re-run `branch_hygiene.mjs`. The current classifier uses tip commit age; it does not yet measure first divergence or indefinitely old open PRs. |
| Open hygiene incident | GitHub issue #249 lists 11 stale branches, some 10–33 days old, up to 16 commits ahead and 312 changed paths. | The issue is live external state and may change after this snapshot. |
| Merge latency | Latest 50 merged PRs: median PR-open-to-merge 0.77h, p90 2.24h, none above 24h. Latest 20: median earliest-commit-to-merge 1.81h, p90 5.51h, one above 24h. | Merged-only samples exclude abandoned work. Commit dates can be affected by rebase or cherry-pick. |
| Reviewability diagnostic | Latest 50 merged PRs: median 1,479 changed lines and 21 files; p90 27,191 lines and 155 files. 22/50 (44%) were at or below both provisional diagnostics of 1,000 lines and 50 files. | Lines and files do not equal complexity. Generated, vendored, schema, and lockfile changes need separate classification before this becomes a gate. |
| Independent review | Zero required approvals on `main`; 0/50 sampled merged PRs reported a GitHub review decision. | Comments or out-of-band review are not captured by this signal. The control should require auditable independent approval by risk. |
| Shared verification | `Required CI` protects `main`, with strict status, administrator enforcement, linear history, and conversation resolution. | This establishes automation, not independent judgment. |
| Merge settings | Branch deletion after merge is enabled; repository auto-merge is disabled. | Automatic branch cleanup helps only after a merge. Enabling auto-merge should follow, not precede, review enforcement. |
| Nightly health | The exact-main push CI succeeded; a later nightly full run failed visual integration and both iOS simulator builds. Branch hygiene also failed on the 11 abandoned branches. | Re-run before prioritizing repair; do not label an old failure current without live evidence. |

### Three primary KPIs

These are the only top-level process-success KPIs. They measure flow toward the
trunk without rewarding raw output.

| KPI | Definition | Baseline | Initial target | Source and calculation |
| --- | --- | --- | --- | --- |
| K1 — overdue unique branches | Count of non-release remote branches whose first divergence from `origin/main` is over 48h old and which lack verified integration or explicit reviewed abandonment. Open PRs remain counted when older than 48h. | Approximation: 14 using current tip-age classifier. True divergence-age baseline must be implemented. | 0 within 30 days; then remain 0 in the daily audit. | Daily branch-hygiene workflow. Derive merge base, first unique commit time, PR state/age, integration proofs, and explicit disposition. |
| K2 — reviewable-batch rate | Percentage of semantic PRs that satisfy the repository's calibrated reviewability model. Start with authored diff at or below both 1,000 changed lines and 50 files, excluding separately identified generated/vendor/lockfile output; refine using review time and defect evidence. | Provisional 22/50 = 44% before generated-diff normalization. | At least 80% after 30 days and 90% after 60 days, without worse guardrails. | Merged PR metadata plus path classification in an expiring CI artifact. Report the numerator, denominator, exclusions, and exceptions. |
| K3 — first-commit-to-main p90 | p90 elapsed time from the first unique authored commit in a task slice to the accepted result appearing on `origin/main`. Abandoned work is reported separately, not silently omitted. | 5.51h for a 20-merged-PR approximation; 1/20 exceeded 24h. | Keep p90 below 24h while reducing K1 to zero. | PR/commit/main history. Preserve squash/cherry-pick mapping and label approximations. |

These are initial operating targets, not industry benchmarks. K1's target comes
directly from the no-stranded-work invariant; K3's 24-hour bound tests daily
integration; K2's 80%/90% targets are hypotheses to calibrate after generated
output is separated and review-cost evidence is available.

### Drivers and guardrails

Drivers explain whether the new process is being used:

- draft PR opened within two working hours of first unique commit;
- percentage of accepted tasks with a named integration owner;
- percentage of R1–R3 changes with auditable independent approval; and
- percentage of branches with an explicit integrated or abandoned terminal
  state.

Guardrails prevent a faster process from becoming a worse process:

- required-CI pass rate and median/p90 time-to-green;
- change-failure rate: accepted changes requiring revert, emergency correction,
  or incident within the agreed observation window;
- escaped-regression count by severity and median time to restore;
- nightly critical-journey pass rate and oldest unresolved nightly failure;
- zero branches deleted with unclassified unique commits or paths;
- feature-flag and compatibility-deprecation age; and
- user outcome or service-level signals for the changed surface.

Do not claim improvement when a primary KPI improves but a material guardrail
worsens. Do not optimize the provisional line/file thresholds directly; they
are review-cost diagnostics to calibrate against review latency, rework, and
escaped defects.

### Validation cadence

- **Every PR:** derive checks, classify risk and generated output, record first
  commit, integration owner, review authority, and final main SHA.
- **Daily:** measure overdue branches, broken shared signals, and time-to-green.
- **Every 10 merged semantic PRs:** recompute K2/K3 and guardrails; inspect
  exceptions rather than averaging them away.
- **Monthly:** review K1–K3, failure/recovery outcomes, reviewer load, and user or
  service impact; change one major process variable at a time.
- **After an incident:** verify whether the relevant control existed, fired,
  was understood, and prevented recurrence. A new rule is incomplete until a
  known-bad fixture or equivalent test proves it can fail.

## Executable Improvement Checklist

This is an ordered backlog. Each slice must use the repository's ordinary task
contract: goal, scope, exclusions, checks, and acceptance. Implement and merge
one coherent slice before interpreting its effect; do not run multiple Flutter
analyzer or test processes concurrently.

### Phase 0 — Preserve and establish a trustworthy baseline

#### PROC-01 — Reproduce and publish the baseline calculation

- [ ] Fetch `origin/main` and record its exact SHA.
- [ ] Query live branch protection, repository merge settings, open PRs, merged
  PRs, workflows, and branch refs.
- [ ] Add a read-only process-metrics command that calculates K1–K3, drivers,
  guardrails, sample windows, and exclusions from Git/GitHub state.
- [ ] Store each run in the GitHub job summary and an expiring artifact; do not
  commit a generated history file.
- [ ] Add fixture tests for merged, open, draft, abandoned, rebased, squashed,
  generated-only, and clock-boundary cases.
- [ ] Demonstrate a known-bad fixture changes the expected KPI.

Completion: a reviewer can reproduce every baseline number from current source
systems, and uncertainty is visible rather than silently coerced to zero.

#### PROC-02 — Classify every existing non-main branch without deleting it

- [ ] Run remote and local branch hygiene from fresh `origin/main`.
- [ ] For every overdue branch, record exact tip, merge base, unique commits,
  changed paths, PR state, author/owner, and the strongest integration proof.
- [ ] Ask the owner or designated reviewer to choose: integrate, split/import,
  superseded, intentionally abandon, or retain as an explicitly named release
  exception.
- [ ] Create a recoverable backup ref before any history rewrite or
  conflict-heavy import.
- [ ] For reconciliations over 50 paths, run `audit_merge_drops.mjs` and review
  every path changed on both sides.
- [ ] Delete only branches with verified integration or explicit reviewed
  abandonment. Report what was removed and the recovery path.

Completion: K1 is zero for the pre-policy backlog, no unique work is deleted
without classification, and issue #249 is resolved from current evidence.

### Phase 1 — Make branches ephemeral and completion truthful

#### PROC-03 — Correct branch-age and PR-age semantics

- [ ] Change `branch_hygiene.mjs` to measure first divergence age, not only tip
  age.
- [ ] Keep open/draft PR branches visible after 24h and overdue after 48h; an
  old PR is not automatically healthy.
- [ ] Distinguish integrated, release exception, at risk, overdue, and explicitly
  abandoned. Keep prune eligibility a supervised conclusion, never permission.
- [ ] Update fixture tests, workflow summary, issue body, and owner docs.
- [ ] Prove that adding a new commit does not reset an overdue branch to healthy.

Completion: K1 has an exact executable definition and the daily workflow fails
on an overdue non-exempt branch.

#### PROC-04 — Add integration and abandonment as terminal states

- [ ] Extend worktree closeout so ordinary `finish` requires proof that the
  accepted result is on `origin/main`; retain a separate handoff state when the
  child has pushed a reviewable proposal but the parent has not integrated it.
- [ ] Require branch, commit, PR, integration owner, and expected next action in
  the handoff output.
- [ ] Make explicit abandonment require a clean tree, reason, unique-work
  classification, and independent reviewer identity.
- [ ] Keep local claims disposable and untracked; use GitHub/PR/Git as durable
  evidence.
- [ ] Test squash merge, rebase merge, cherry-pick/import, supersession,
  interrupted session, and no-upstream cases.

Completion: a task cannot report final completion merely because its branch is
clean and pushed.

#### PROC-05 — Adopt early PRs, branch clocks, and auto-merge

- [ ] Publish the trunk policy in the operating model and PR template.
- [ ] Open a draft PR within two working hours of the first unique commit.
- [ ] Assign one integration owner and show the 24h/48h clock in the PR.
- [ ] Configure auto-merge only after required review and CI controls are live.
- [ ] Exempt release branches only with owner, purpose, base, expiry, and
  reconciliation plan.
- [ ] Add a fail-closed check that rejects an unowned or expired exception.

Completion: new ordinary work either reaches `origin/main` within 48h or has a
visible blocked/abandoned disposition.

#### PROC-06 — Calibrate small-batch reviewability

- [ ] Classify authored, generated, vendored, lockfile, asset, and migration
  output separately.
- [ ] Start with advisory 1,000-line/50-file authored-diff diagnostics.
- [ ] Require a split plan or reviewer-approved rationale when a semantic PR
  exceeds the diagnostic.
- [ ] Observe review time, rework, merge conflicts, and escaped defects for at
  least 30 semantic PRs.
- [ ] Recalibrate thresholds from evidence; never reward gaming line count.

Completion: K2 reaches its target without a guardrail regression, and generated
output no longer obscures the authored decision.

### Phase 2 — Add independent judgment to AI-produced changes

#### PROC-07 — Enforce risk-tiered review

- [ ] Add R0–R3 risk classification with protected path defaults.
- [ ] Require an independent fresh-context reviewer for R1–R3.
- [ ] Require named human approval for R2 and execution-time authority for R3.
- [ ] Prevent the authoring agent identity from satisfying the only approval.
- [ ] Configure branch protection or a required check so the rule is executable.
- [ ] Test missing, stale, self-authored, and lower-than-required approvals.

Completion: GitHub refuses an R1–R3 merge without the specified independent
authority, and R0 automation remains fast.

#### PROC-08 — Standardize the reviewer context packet

- [ ] Include goal, user-visible behavior, risk, exact base/head SHA, authored
  diff, generated diff, reproduction, assumptions, tests, rollback, and known
  gaps.
- [ ] Give the reviewer symptoms and evidence, not an asserted root cause.
- [ ] Require the reviewer to inspect whole changed units and independently
  state correctness, integration risk, and missing tests.
- [ ] Keep large raw logs in CI artifacts; the PR contains concise links and
  conclusions.

Completion: a fresh reviewer can evaluate the change without inheriting the
author's conclusion or reconstructing the task from chat history.

#### PROC-09 — Separate test authorship from critical-control proof

- [ ] For R2/R3 behavior, require either independently authored tests, mutation
  evidence, a known-bad fixture, or an equivalent negative control.
- [ ] Verify that the new test fails for the defect or forbidden state and
  passes for the accepted implementation.
- [ ] Keep runtime/live postconditions separate from source tests.

Completion: no consequential change is accepted only because code and a test
generated from the same assumption agree with each other.

### Phase 3 — Make shared verification fast, green, and trusted

#### PROC-10 — Restore and own shared-signal health

- [ ] Re-run the current nightly failure on exact `origin/main`.
- [ ] Assign owners for visual integration and iOS simulator build failures.
- [ ] Define repair objectives for required CI and nightly critical journeys.
- [ ] Remove or quarantine only with owner, reason, expiry, and retained risk
  coverage.
- [ ] Measure time-to-green and oldest unresolved failure.

Completion: shared critical journeys are green or carry explicit, expiring
risk acceptance; persistent red is not normalized.

#### PROC-11 — Define release-risk, flag, and rollback policy

- [ ] Map R0–R3 to deploy, release, environment approval, observation, and
  rollback requirements.
- [ ] For incomplete work on trunk, prefer backward-compatible dark paths;
  create a feature flag only when runtime separation is actually needed.
- [ ] Every flag has owner, creation date, default, rollout metric, rollback
  condition, and expiry/removal task.
- [ ] Exercise rollback or containment for each consequential delivery lane.

Completion: deployment and user release are intentionally coupled or decoupled
per risk, and expired flags fail an executable check.

#### PROC-12 — Verify immutable delivery and live postconditions

- [ ] Prove package provenance from exact main SHA through promotion.
- [ ] Fail deploy preflight when the source ref is behind, divergent from, or
  unverified against its authoritative remote.
- [ ] Use the same deploy implementation across environments where possible.
- [ ] Query live configuration, rules, migrations, hosting, and store state
  after delivery; a checked-in receipt is never enough.
- [ ] Run periodic artifact-identity and recovery exercises.

Completion: each delivery report distinguishes source, merge/CI, deployed
artifact, distribution, runtime health, and user availability.

#### PROC-13 — Keep the gate map derived and anti-vacuous

- [ ] Make `node tool/harness/verify_local.mjs --base origin/main` the canonical
  local CI-equivalent entrypoint.
- [ ] Fail closed when a changed target has no mapped gate.
- [ ] For every recurring rule, include a known-bad fixture or equivalent proof
  that the check detects the prohibited state.
- [ ] Check waiver owner and expiry; reject stale suppressions.
- [ ] Update owner docs and the executable rule in the same PR.

Completion: an agent does not need a remembered gate list, and an empty or
vacuously passing check cannot establish compliance.

#### PROC-14 — Calibrate the test portfolio to product risk

- [ ] Map critical user and operator journeys to unit, contract, integration,
  emulator, visual, build, smoke, and runtime evidence.
- [ ] Identify gaps and redundant tests; do not use aggregate coverage as the
  sole quality measure.
- [ ] Add accessibility, privacy, localization, network/error, and representative
  device states according to risk.
- [ ] Sample test-double usage at high-risk boundaries before adding policy.
- [ ] Track flakes, quarantine age, escaped regression, and repair time.

Completion: every R2/R3 journey has evidence at the cheapest layer capable of
detecting its failure plus at least one appropriate integration/runtime layer.

### Phase 4 — Close lifecycle and operational feedback gaps

#### PROC-15 — Make dependency updates small and owned

- [ ] Classify runtime, build, dev, native, and security dependencies by risk.
- [ ] Split incompatible or high-risk major updates from routine compatible
  updates; avoid unreviewable grouped batches.
- [ ] Route each update to an owner and the checks for affected surfaces.
- [ ] Define response time for exploitable vulnerabilities and verify lockfile,
  provenance, and license policy where applicable.

Completion: automated updates are mergeable review units and a failed grouped
update cannot remain an unowned standing branch.

#### PROC-16 — Standardize migration and deprecation completion

- [ ] Every migration has expand, observe/migrate, prevent-backsliding,
  contract/remove, and recovery phases.
- [ ] Every compatibility path has owner, live use signal, deadline, and removal
  criterion.
- [ ] Derive completion from current source/live dry-run, not a historical prose
  receipt.
- [ ] Fail on new use of deprecated paths after the freeze phase.

Completion: a migration is not called complete while old writes, reads, flags,
or compatibility paths remain without an explicit active exception.

#### PROC-17 — Establish incident, SLO, and recovery learning

- [ ] Define incident thresholds for delivery loss, production regression,
  security/privacy, data integrity, and prolonged critical-signal failure.
- [ ] Use a lightweight blameless review: impact, timeline, direct and systemic
  conditions, detection, recovery, and bounded actions with owner/due date.
- [ ] Put durable recurring actions in owner docs and executable controls; track
  action closure in the existing issue/PR system, not a repository ledger.
- [ ] Define service or delivery objectives only for decisions that need them;
  include error budget or an equivalent risk threshold.
- [ ] Verify effectiveness after the observation window.

Completion: material failures produce closed, tested system improvements and
recovery time trends downward without hiding incidents.

#### PROC-18 — Add maintenance, capacity, and cost to broad decisions

- [ ] For broad features, state expected lifetime, ownership, migration cost,
  operational load, data growth, latency/capacity constraint, and retirement
  path.
- [ ] Add thresholds only where an exceeded value changes a decision.
- [ ] Review actual utilization/cost against estimates after rollout.

Completion: significant architecture decisions include the cost of keeping,
operating, scaling, and eventually removing the system.

#### PROC-19 — Operate the scorecard and improvement experiment

- [ ] Publish K1–K3, drivers, guardrails, definitions, samples, and caveats in a
  CI summary plus expiring artifact.
- [ ] Establish the true baseline before enabling enforcement.
- [ ] Change one major workflow variable at a time and state the expected KPI
  movement and guardrail risk.
- [ ] Review after every 10 semantic PRs and monthly; retain, adjust, or revert
  based on evidence.
- [ ] Survey reviewer/operator friction periodically; quantitative flow alone
  cannot measure cognitive load or trust.

Completion: every process change has a before value, expected effect,
observation window, result, and retain/adjust/revert decision.

#### PROC-20 — Exercise clean-room reproducibility and recovery

- [ ] From a fresh worktree at an exact SHA, bootstrap declared dependencies,
  derive gates, build/package, and compare expected artifact identities.
- [ ] Exercise restore, rollback, or containment for critical data and delivery
  paths without making destructive production changes.
- [ ] Record missing external inputs and either declare, remove, or monitor them.
- [ ] Turn recurrent failures into focused regression checks.

Completion: the project can reproduce and recover its critical deliverables
from declared source and authorized external inputs within its objective.

## Quality Verification For Every Process Change

A process improvement is complete only when all applicable layers are proven:

1. **Source:** the intended policy/tool/config change exists in a reviewed diff
   from fresh `origin/main`; unrelated dirty work is absent.
2. **Control behavior:** focused unit/fixture tests pass, including at least one
   known-bad or boundary case that proves the control can fail.
3. **Derived integration:** `verify_local.mjs --base origin/main --list` selects
   the expected gates, and the applicable local CI-equivalent checks pass.
4. **Independent review:** the risk-appropriate reviewer verifies the design,
   implementation, tests, false-positive path, bypass path, and documentation.
5. **Main integration:** the exact accepted result is present on `origin/main`;
   a clean pushed branch is not enough.
6. **Live configuration:** branch protection, workflow, environment, or deploy
   state is queried after a settings change; repository prose is not proof.
7. **Outcome:** the relevant primary KPI moves in the expected direction during
   the observation window without a material guardrail regression.
8. **Retirement:** temporary flags, exceptions, compatibility code, backup refs,
   worktrees, and branches have explicit expiry and are removed after proof.

When a check fails, first reproduce it on the exact merge base. Report a truly
pre-existing failure separately; do not inherit an old claim that it is known,
and do not weaken the new control merely to make the run green.

## Suggested Execution Order

The recommended first implementation sequence is:

1. `PROC-01` — make the baseline reproducible.
2. `PROC-02` — reconcile existing work without deleting unique changes.
3. `PROC-03` and `PROC-04` — make branch age and task completion truthful.
4. `PROC-07` — add independent risk-tiered review.
5. `PROC-05` and `PROC-06` — introduce early PRs, auto-merge, and calibrated
   small-batch diagnostics.
6. `PROC-10`, `PROC-13`, and `PROC-14` — restore trust in shared verification.
7. `PROC-11`, `PROC-12`, and `PROC-17` — tighten release, live proof, and
   recovery learning.
8. Operate `PROC-19` continuously and schedule the remaining lifecycle work by
   measured risk.

Do not start by deleting branches or imposing a hard line-count gate. Start by
making the evidence correct, preserving every unique change, and then changing
one control at a time.

## Definition Of Done For This Improvement Program

The program is complete when:

- ordinary work begins at fresh `origin/main`, opens an early PR, and reaches
  verified `origin/main` or explicit reviewed abandonment within 48 hours;
- K1 remains zero and K2/K3 meet their targets for two consecutive monthly
  reviews;
- R1–R3 changes cannot merge without the required independent authority;
- required CI and critical nightly journeys have owners, repair objectives, and
  stable green evidence;
- exact-artifact, live-postcondition, rollback, migration, and deprecation
  controls are exercised rather than only documented;
- escaped defects, change failures, and recovery time do not materially worsen;
- agents and humans can derive applicable gates and current state without a
  remembered checklist; and
- no unique intended work exists only on an unowned branch, worktree, stash,
  reflog, or local machine.

## Sources And Evidence

### Books and official companion material

- Titus Winters, Tom Manshreck, and Hyrum Wright,
  [*Software Engineering at Google*](https://abseil.io/resources/swe-book/html/toc.html),
  especially chapters 1–25 as linked in the practice catalogue.
- Jez Humble and David Farley,
  [*Continuous Delivery*](https://martinfowler.com/books/continuousDelivery.html).
- Continuous Delivery companion material:
  [principles](https://continuousdelivery.com/principles/),
  [foundations](https://continuousdelivery.com/foundations/),
  [configuration management](https://continuousdelivery.com/foundations/configuration-management/),
  [continuous integration](https://continuousdelivery.com/foundations/continuous-integration/),
  [test automation](https://continuousdelivery.com/foundations/test-automation/),
  and [deployment patterns](https://continuousdelivery.com/implementing/patterns/).

### Catch source and live evidence

- [`AGENTS.md`](../../AGENTS.md) — repository entrypoint and non-negotiable
  execution rules.
- [`agent_operating_model.md`](../agent_operating_model.md) — task contracts,
  Git preservation, worktrees, delegation, and completion.
- [`ai_first_workflow_guide.md`](../ai_first_workflow_guide.md) — planner,
  checks, Git/CI evidence, and exact-artifact workflow.
- [`release_operations.md`](../release_operations.md) — branch hygiene,
  branch protection, environments, delivery, and release proof.
- [`branch_hygiene.mjs`](../../tool/git/branch_hygiene.mjs) and
  [`worktree_guard.mjs`](../../tool/git/worktree_guard.mjs) — executable current
  branch/worktree semantics.
- [`verify_local.mjs`](../../tool/harness/verify_local.mjs) — derived local
  CI-equivalent gate selection and execution.
- [GitHub issue #249](https://github.com/suvratgarg/catch-dating-app/issues/249)
  — live stale-branch report at the audit snapshot.

Reproduce current repository evidence with read-only commands before relying on
the snapshot:

```sh
git fetch origin --prune
git rev-parse origin/main
node tool/git/branch_hygiene.mjs --base origin/main --remote origin --json
node tool/git/branch_hygiene.mjs --base origin/main --local --json
node tool/harness/verify_local.mjs --base origin/main --list
gh api repos/suvratgarg/catch-dating-app/branches/main/protection
gh api repos/suvratgarg/catch-dating-app
gh pr list --state open --limit 100 --json number,title,headRefName,isDraft,createdAt,updatedAt
gh run list --limit 30
```

The commands above inspect state. Branch deletion, protection changes, workflow
changes, merge, deployment, and production operations remain separate authorized
actions.
