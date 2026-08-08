---
doc_id: third_party_tooling_adoption_spec
version: 0.9.0
updated: 2026-08-08
owner: agent_operating_model
status: active
---

# Third-Party Tooling Adoption Spec

Companion to `docs/plans/harness_v2_decision_and_cicd_delivery_plan.md`. That
document decides *what the harness should do*. This one decides *how much of it
we should stop writing ourselves*.

This is an **evaluation spec, not an adoption mandate.** Every candidate below
is a hypothesis with a kill criterion. Adopting a tool that does not
demonstrably remove a problem is a regression, not progress — it adds a
dependency, a version to track, and a second way to do something.

This is a temporary execution tracker. Each candidate moves to one GitHub
Issue when it is ready for evaluation; that Issue records the hypothesis,
evidence, and adopt-or-reject outcome. Retire this document once the bounded
initial queue is dispositioned. Its durable lesson is a short routing rule,
not a new repository ledger or a standing PR form.

## 1. Why this exists

The harness review established that the repository grew a large custom control
plane. A follow-up review established something narrower and more actionable:
a substantial fraction of that custom code re-implements mature, free, open
source tooling — including in places where the hand-rolled version is
**correctness-critical and probably wrong**.

The root cause is specific to AI-first development and deserves naming:

> An agent asked to solve a problem writes code. It does not stop, survey the
> ecosystem, weigh adoption cost, and return recommending a library instead.
> Humans build less than they could because maintaining code hurts them.
> Agents feel no such pain, so they have a systematic and uncorrected bias
> toward building over adopting.

Nothing in the current process corrects for this. §2 is the correction.

## 2. Standing rule — build-versus-adopt

Before adding a dependency, a general-purpose subsystem, or a substantial
replacement for shared tooling, the implementation Issue or PR states:

1. the observable capability or defect being addressed;
2. at least one platform or established-tool alternative considered; and
3. why the selected option fits the repository's safety and maintenance needs.

More than roughly 100 new lines of general-purpose code is a review trigger,
not an automatic rejection. Product-specific Catch contracts and validators
are not reinvention merely because they are custom; they encode product policy
that a generic tool cannot own. `AGENTS.md` stays a short router; detailed
review guidance belongs in `tool/README.md`. Do not create a scanner that
pretends to prove ecosystem research occurred.

**Adoption is not automatically right either.** The root tooling runtime has a
deliberately small dependency surface (`ajv`, `ajv-formats`, `pngjs`, `react`,
`react-dom`, and `typescript`). That is a security asset for a public
repository handling dating and payment data, not merely an accident. Every
adoption spends some of it.

A candidate library must clear all of:

- actively maintained (releases within ~12 months; unresolved critical issues
  addressed);
- permissive license (MIT/Apache-2.0/BSD);
- proportionate transitive dependency count — prefer zero-dependency libraries
  for small jobs;
- a capability we actually use, not one we might;
- no meaningful new privileged surface (nothing that wants credentials,
  network access at build time, or postinstall scripts).

Prefer, in order: **the platform's own standard library** → a zero-dependency
focused library → a well-known larger framework → writing it ourselves.

## 3. Adoption protocol — prove it, then keep it

No candidate is adopted on reputation. Each follows this sequence, and the
evidence goes in the PR body, not in a tracked ledger:

1. **State the problem** in observable terms — a number, a defect class, or a
   named failure that has actually happened.
2. **State the hypothesis** as a falsifiable prediction with a threshold.
   "Reduces X by at least N" or "detects failure class Y that we currently
   miss."
3. **Build the smallest real slice.** One script, one platform, one surface —
   never a repository-wide sweep as the first move.
4. **Measure against the stated threshold**, on real repository inputs, not a
   toy example.
5. **Adopt or reject explicitly.** A rejection is a successful outcome; record
   its reason in the candidate Issue so it is not re-proposed without new
   evidence.
6. **Only then roll out** in independent PRs that can each be reverted alone.

**Equivalence oracles are mandatory for replacements.** When new tooling
replaces existing behavior, prove behavioral equality before deleting anything.
Where the repository already owns a verifier, use it — for example, a Fastlane
migration must satisfy the existing
`tool/platform/verify_ios_release_identity.mjs` and
`tool/platform/check_mobile_package.mjs` with unchanged results.

**One exception to "prove it helps":** *preventive* controls (for example
secret scanning) are justified by the risk they cover, not by finding something
on day one. Zero findings is the desired result, not evidence of uselessness.
This exception applies only to controls guarding a named, plausible harm, and
must be claimed explicitly.

## 4. Verified findings (checked against `f2bfa35c`, 2026-08-08)

These were measured, not assumed. They are the evidence base for §6.

| Finding | Evidence | Why it matters |
|---|---|---|
| Repository is **public**, owned by a personal user account | GitHub repository metadata | Actions runner cost is latency rather than spend; public source raises the bar on secret hygiene |
| **No repository-defined secret scanner** | no `gitleaks`, `trufflehog`, `detect-secrets`, or equivalent configuration in tracked source | GitHub secret scanning and push-protection status are external and unverified; a repository search cannot prove they are absent |
| **99 files define their own `parseArgs`** | current `tool/**` source inventory | Node ships `node:util.parseArgs`; this is real duplication but includes some deliberate command-specific validation |
| **Three surviving custom glob matchers** | `tool/harness/lib/component_graph.mjs`, `tool/agent/lib/context_plan.mjs`, and `tool/check_repository_root_hygiene.mjs` | The authoritative and advisory planners can silently omit a relevant check or owner rule |
| **414 `.mjs` + 17 `.sh` scripts** in `tool/` | tracked-source inventory | Large custom surface; high prior probability of further reinvention |
| **Root tooling dependency surface is small**: `ajv`, `ajv-formats`, `pngjs`, React, React DOM, TypeScript | root `package.json` | Protect it deliberately; this is not a claim that every workspace package has few dependencies |
| **npm workspaces exist**: `admin`, `website`, `packages/web-ui` | root `package.json` | The JS half is already a workspace monorepo; JS-ecosystem tooling could apply |
| **`lib/` is a single root Dart package** | only root `pubspec.yaml` covers `lib/` | Package-granularity Dart tooling collapses `lib/` to one node — see the Melos rejection in §6.3 |
| **`contracts/` is JSON Schema, not Protobuf** | `contracts/**/*.json`, `ajv` usage | Protobuf-ecosystem tooling does not apply — see the Buf rejection in §6.3 |
| **Merge queue is unavailable to a personal public repository** | GitHub feature eligibility and live repository ownership | It is an optional collaboration improvement, not a Harness cutover prerequisite — see §5 |

## 5. Non-blocking contingency — merge queue availability

The Harness does not depend on a merge queue. `main` already requires the
stable `CI / Required CI` result and exact delivery has its own ordered,
fail-closed source and artifact checks.

Moving the repository to an organization is an owner-only operational
migration, not a fallback checkbox. It changes the OIDC repository subject and
can invalidate environments, variables, secrets, and workload-identity
bindings. Decide on ownership before applying a pending environment-subject
binding if a transfer is genuinely imminent; otherwise keep the current
personal-repository binding and revisit collaboration tooling later.

## 6. Candidate queue

### 6.1 Tier A — strong prior, evaluate first

**A1. `picomatch` with `dot: true` for glob matching — retained as a test oracle, not a bootstrap runtime**

- *Problem:* the custom matcher returns false for `a/**/b` against `a/b`.
- *Initial result:* `97a0f7ed1` replaced the three surviving handwritten
  matchers with one cached Picomatch adapter. Its oracle compared the legacy
  matcher, Node's native matcher, and Picomatch across 7,248 tracked paths and
  126 Harness patterns: 71 individual pattern/path evaluations changed, zero
  terminal owner classifications changed, and Node native remained unsuitable
  because it omits dotfiles under the repository's required semantics.
- *Live CI correction:* the first PR run failed before planning because the
  sparse bootstrap intentionally had no `node_modules`. Adding a 12-package,
  script-disabled install repaired the 13-second planner, but the next run
  proved the deeper cost: six independent Functions, contracts, docs, app-
  target, and tool-preflight jobs imported the shared matcher before their own
  dependency setup and failed in under 30 seconds. Installing npm packages in
  every lane would make a path-routing helper a network bootstrap dependency.
- *Final result:* the runtime now uses one dependency-free canonical matcher
  with the corrected dotfile and zero-directory-globstar semantics. Picomatch
  4.0.4 remains a development-only oracle. The committed test compares the
  bootstrap matcher against Picomatch for every active graph/manifest pattern
  across more than 7,000 tracked paths; the current 1,436,094 evaluations have
  zero differences. Only the Harness test lane installs the root dependency.
- *Regression boundary:* tests cover zero-directory `**`, dotfiles,
  normalization, literal scope ownership, every consumer's affected-tool
  closure, the planner's sparse import closure, and the repository-wide
  Picomatch equivalence oracle. The direct development dependency is locked at
  Picomatch 4.0.4 and never required by the runtime planner.
- *Why not Node alone:* Node 24's `path.matchesGlob` does not preserve the
  repository's intended dotfile behavior. `picomatch` is MIT-licensed,
  zero-runtime-dependency, and already present transitively.
- *Slice:* first delete the obsolete relationship matcher with its duplicate
  planner. Then replace the surviving Harness and context matchers behind a
  three-way oracle: current behavior, Node native behavior, and Picomatch.
- *Acceptance:* semantic tests cover zero-directory `**`, dotfiles, leading
  `./`, and current component classification. Every divergence is classified;
  the new matchers have no omitted active context rules.
- *Decision:* keep mature tooling as an executable oracle when a runtime
  dependency would widen the bootstrap boundary. Do not trade an 82-line
  centralized helper for package installation in every CI lane.

**A2. GitHub native secret protection plus optional Gitleaks defense in depth — native retained; Gitleaks rejected**

- *Problem:* no tracked repository-defined secret scanner exists, while the
  repository is public and workflows handle production credentials.
- *Slice:* first inspect and enable GitHub secret scanning and push protection.
  Then run a redacted full-history Gitleaks scan and add an unprivileged PR
  scan only if it adds useful local or historical coverage.
- *Acceptance:* the check has `contents: read`, receives no deployment
  secrets, never uses `pull_request_target`, is pinned immutably, and has a
  known-bad fixture proving it cannot pass vacuously.
- *Kill if:* the local scan cannot reach a clean, low-noise baseline. Do not
  mistake a repository search for proof that GitHub-native protection is off.
- *Measured result (2026-08-08):* authenticated repository metadata confirms
  that GitHub secret scanning and push protection are enabled. A checksum-
  verified Gitleaks 8.30.1 full-history scan ran with 100% redaction across 615
  commits and 273.36 MB in 62.9 seconds. It reported 175 matches: 95 Google
  API-key matches repeating the same Firebase client configuration represented
  by GitHub's nine open Google API-key alerts, plus 80 generic-key matches in
  Pod lockfile checksums, fixtures, demo data, and retired generated audit
  artifacts. It found no additional actionable secret class.
- *Decision:* do not add a Gitleaks dependency or CI lane. It would require a
  large allowlist to restate what native scanning already knows and would
  create a noisy second authority. Keep GitHub-native protection. Review the
  nine Firebase client keys in Google Cloud for appropriate application/API
  restrictions before resolving or dismissing those alerts; do not print or
  copy key values into repository evidence.

**A3. `node:util.parseArgs` (Node standard library, zero dependency) — adopted in a bounded pilot; standalone inventory unchanged**

- *Problem:* 99 tools define custom argument parsers; flag syntax and unknown-
  flag behavior vary. `tool/lib/cli_args.mjs` already concentrates a common
  parser used by five tools.
- *Result:* the five current consumers now share a `node:util.parseArgs`
  tokenizer. The helper shrank from 67 to 57 lines (a 10-line reduction) while
  preserving its existing caller-facing fields, including `allowProd`,
  `confirmProd`, custom underscore-named fields, and the last-flag-wins
  emulator precedence.
- *Correction after merge:* those five commands already consumed the shared
  helper before the pilot. The change modernized that helper; it did not
  convert any of the 99 files that still define their own `parseArgs`
  function. The earlier statement that 94 remained incorrectly subtracted
  the helper's five existing consumers from a separate 99-file inventory.
- *Regression boundary:* four focused tests cover unknown flags, missing
  values, duplicate values, `--x value`, `--x=value`, `-h`, positionals,
  invalid helper declarations, and the exact five consumer imports. The tool
  runner, manifest, Harness validation, graph coverage, root hygiene, and
  documentation metadata checks also pass.
- *Deliberate boundary:* command-specific validation—subcommands,
  duplicate-option rejection, path resolution, enums, and production-write
  guards—remains outside the tokenizer. All 99 standalone custom parser
  definitions remain; each needs a clustered equivalence slice before it can
  join this helper, and parsers whose custom behavior is product policy should
  remain local.

**A4. Dependabot — security-only configuration and repository settings enabled**

- *Problem:* the repository has no automated dependency-update workflow.
- *Result:* `.github/dependabot.yml` covers the root and five npm manifests,
  eight pub manifests, and GitHub Actions. It groups security updates by
  ecosystem and sets `open-pull-requests-limit: 0`, so this change enables no
  routine version-update PRs.
- *Live result:* PR #179 merged the configuration to `main` on 2026-08-08.
  Dependency alerts and Dependabot security updates were then enabled; routine
  version-update PRs remain disabled. The first scan found 38 patchable npm
  alerts across 11 packages and three lockfiles: 27 in
  `functions/package-lock.json`, 9 in the root lockfile, and 2 in
  `operations/package-lock.json`. Severity was 21 high, 16 medium, and 1 low;
  no automated PR had appeared at the measurement point.
- *Acceptance:* reduce the initial patchable backlog in bounded package/lockfile
  slices and measure the resulting security-only PR volume. Version updates
  remain disabled until that batch is understood.
- *Kill if:* security updates themselves compete materially with product work;
  keep Dependabot's alerts but remove the PR configuration rather than adding a
  second bot.

**A5. Fastlane feasibility study — deferred**

- *Current state:* mobile delivery is now a 1,523-line package producer and a
  1,214-line exact-artifact promoter. Both roles use separate promotion; Host
  is not a special lower-risk mode.
- *Assessment:* the safe Fastlane-replaceable subset is roughly 205 workflow
  lines. The remaining logic binds source attempts, exact signed bytes,
  provenance, signing identity, postconditions, and replay protection.
- *Precondition:* exercise the current promoter successfully first. Then do a
  paper feasibility pass before changing any release path.
- *Kill if:* it cannot show meaningful net deletion after Ruby, Bundler,
  Fastlane, lockfile, test, and credential-boundary work. The oracle is
  semantic identity and valid SHA-bound receipts, not byte equality across two
  separately signed builds.

### 6.2 Tier B — plausible, but requires a decision first

**B1. Nx for the npm-workspace half**

- *Context:* `admin`, `website`, and `packages/web-ui` are already npm
  workspaces, which is Nx's native territory. But Codex has **already built**
  `tool/harness/lib/component_graph.mjs` covering the whole repository at 100%
  path ownership.
- *Boundary:* Harness alone decides repository impact, required validation, and
  delivery authorization. Nx could only order and cache work **inside an
  already-selected web lane**; it must not become a second repository graph.
- *Precondition:* collect the Harness plan's ten comparable PR timing samples.
  The planner itself is about 0.07 seconds; current long poles are actual
  Admin, iOS, coverage, and visual execution.
- *Current evidence:* the ten latest successful PR runs span 71–1,654 seconds
  from start to completion: two exceed 20 minutes and eight finish within
  274 seconds. They are different selected-workload shapes, not a comparable
  task baseline. Collect ten runs with the same selected lanes before a shadow
  execution experiment; do not let a single 22-minute broad run select Nx.
- *Slice, if pursued:* shadow-compare package-task execution, not deployment
  authorization, then measure end-to-end wall time and runner minutes.
- *Kill if:* there is no material measured improvement or any divergence omits
  a required check. Divergence requires classification; it is not adoption
  evidence by itself.

**B2. Remote build caching (Nx Cloud, Turborepo cache, or self-hosted)**

- *Correction to an earlier claim:* because this repository is public, Actions
  runners are free. Caching therefore buys **wall-clock latency and job
  concurrency headroom**, not money. Free-tier concurrency caps are the real
  constraint under the fleet-parallelism goal.
- *Hypothesis:* cache hit rate above 40% on repeat CI work.
- *Kill if:* below that — the setup and cache-invalidation reasoning cost more
  than the savings.
- *Sequence after:* the ten comparable PR timing baseline. Extend native GitHub
  caches first, then consider a remote task cache only for repeatable,
  uncredentialed work. Never cache signed packages, deployable artifacts,
  live-data snapshots, or mutation jobs.

**B3. JSON Schema breaking-change detection — problem confirmed; no package adopted**

- *Problem:* `contracts/` changes can break deployed consumers, and nothing
  currently proves compatibility — only freshness of generated outputs.
- *Historical proof:* commit `b9ca7ae7335a43d86c73f88b6fc64b986244adbe`
  tightened the established Cross Paths response contract by making
  `event.pairHoldAvailable` required. A disposable run of
  `json-schema-diff@1.0.0` against the complete prior/current `contracts/`
  trees returned a nonzero breaking-change result. The need is therefore real,
  not theoretical.
- *Candidate result:* do **not** add `json-schema-diff` yet. It has seven direct
  dependencies, emits a deprecation warning for its embedded
  `json-schema-ref-parser@9`, and needs full historical contract trees merely
  to resolve Catch's relative refs. That expands the root tooling surface and
  needs a bespoke archive wrapper before it can be a safe CI gate.
- *Boundary:* Protobuf tooling remains inapplicable (see §6.3), and we will not
  write a homegrown compatibility checker to compensate. Re-open only if a
  maintained, lower-surface tool handles relative refs without that wrapper, or
  after an owner decides the confirmed risk justifies the additional runtime.

**B4. Terraform / OpenTofu with the Firebase provider**

- *Problem:* environment configuration is asserted by hand-written scripts;
  drift between `dev`, `staging`, and `prod` is detected only by ad-hoc probes.
- *Assessment:* this changes infrastructure ownership; it is not a replacement
  for environment-readiness probes. **Defer** until repository ownership and
  OIDC identities are stable and recurring drift is demonstrated or the owner
  explicitly chooses declarative infrastructure. The first slice, if any, is a
  non-mutating imported plan for one safe development resource, never prod.

### 6.3 Tier C — rejected, with reasons (do not re-propose without new evidence)

| Candidate | Rejected because |
|---|---|
| **Melos** | Verified structural mismatch: `lib/` is a single root Dart package, so package-granularity affected detection collapses the largest surface to one node and yields nothing. Revisit **only** if `lib/` is split into real packages |
| **Buf / Protobuf schema registry** | Protobuf-specific. `contracts/` is JSON Schema validated with `ajv`. The *concept* survives as B3; the tool does not apply |
| **Bazel / Pants** | Adoption cost is disproportionate. Published readiness guidance puts Bazel at the 1,000+ engineer scale. Would consume the entire cutover budget |
| **Codemagic / Bitrise** | Paid CI does not solve the demonstrated problem: GitHub Actions already provides the exact-artifact producer/promoter boundaries; current long poles need measured optimization first |
| **Argo Rollouts / Flagger** | Kubernetes-native. This stack is Firebase; there is no traffic-splitting substrate for them to control |
| **LaunchDarkly / Unleash** | Firebase Remote Config is already present and already deployed-to. No gap |
| **Checkly / Datadog Synthetics** | The marketing site already runs synthetic probes as plain scripts on free infrastructure. Extend that pattern to the backend rather than buying it |

## 7. Bounded reinvention review

Do not start with a repository-wide audit or a multi-library PR. The five
named candidates above already cover the known high-value work. Evaluate one
in an independent, revertible Issue/PR pair, then decide whether another
inventory is justified from the merged branch.

If a later inventory is needed, rank capability groups by correctness
criticality first, duplication second, and code size third. Stop when the best
remaining candidate is neither correctness-critical nor implemented at least
three times. A small glob error that can omit a check outranks a large formatter
used once.

## 8. What not to do

- Do not adopt anything without the §3 evidence in its Issue or PR.
- Do not open a repository-wide dependency-adoption PR.
- Do not create another tracker, dashboard, scorecard, or ledger for this work.
- Do not add a dependency to save fewer than ~50 lines unless it fixes a
  correctness bug.
- Do not adopt a tool because it is popular, modern, or recommended by a
  benchmark — only because it removes a problem this repository actually has.
- Do not delete custom code before its replacement passes an equivalence
  oracle.
- Do not treat a rejection in §6.3 as reversible without new structural
  evidence (for example, Melos becomes viable only if `lib/` is modularized).
- Do not let this document outlive the candidate dispositions.
