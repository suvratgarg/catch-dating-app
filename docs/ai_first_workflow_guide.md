---
doc_id: ai_first_workflow_guide
version: 1.0.0
updated: 2026-07-05
owner: agent_operating_model
status: active
---

# AI-First Workflow Guide

This guide explains the Catch agent workflow as a reusable pattern for another
repository. It is a descriptive map of the system, not a replacement for the
canonical owner docs. If this guide and an owner doc disagree, use the owner doc.

The core idea is simple: treat every AI agent as a capable contributor with
unreliable ambient memory. Important context must be routed, executable,
versioned, measured, or explicitly manual. The repo should make the correct
loop cheaper than an ad hoc partial fix.

## What The System Optimizes For

The workflow is designed to produce exhaustive, deterministic results by
removing guesswork from the agent loop:

- Agents start from a short entrypoint instead of reading a long wiki.
- Durable decisions live in named source-of-truth docs with owners, versions,
  and read policies.
- Broad tasks generate a context pack before editing.
- Rules are bound to tools, lints, scanners, tests, CI jobs, or manual review
  checkpoints.
- Repeated mistakes are promoted into regression guards or scanners.
- Cleanup and refactor work leaves append-only proof in audit ledgers.
- Generated registries make large surfaces inspectable without rereading every
  source file.
- Parallel agents may explore or patch only under a parent-owned integration
  protocol.

The result is not that the agent remembers everything. The result is that the
repo tells the agent what to read, what to avoid, what to run, and what evidence
must exist before handoff.

## System Map

```text
AGENTS.md
  -> docs/agent_operating_model.md
  -> docs/README.md + docs/audit_registry/doc_versions.json
  -> tool/agent/context_pack.mjs
      -> owner docs
      -> project-local skills
      -> active rules
      -> regression guards
      -> command plan
      -> acceptance criteria
  -> implementation or answer
  -> focused tests, lints, scanners, generated registry checks
  -> audit registry pass proof when applicable
  -> node tool/agent/check_agent_readiness.mjs
```

For another repo, copy the shape before copying the details. Start with a short
agent entrypoint, a small operating model, a tool manifest, a rules registry, a
regression ledger, and one readiness check. Add domain-specific scanners only
after the workflow has a stable place to register them.

## 1. Entrypoint: `AGENTS.md`

`AGENTS.md` is the first routing document for agents. It stays short on
purpose. It should answer:

- What must an agent do before editing?
- Which source-of-truth docs own each work type?
- Which local verification loop is required?
- Which rules are non-negotiable?
- What does "done" mean?

In Catch, the required starting loop is:

```sh
git status --short
sed -n '1,240p' docs/agent_operating_model.md
node tool/agent/context_pack.mjs --task <task-name> --paths <path[,path...]>
node tool/agent/check_agent_readiness.mjs
```

The context pack is required for broad cleanup or refactor work. The readiness
gate is required before handoff. The entrypoint also routes work by type:

- App architecture reads `docs/app_architecture.md`.
- Documentation cleanup reads `docs/README.md` and
  `docs/audit_registry/doc_versions.json`.
- Design-system work reads `docs/design_language.md`,
  `docs/design_parity/README.md`, and `docs/widget_catalog.md`.
- Data-contract work reads `docs/data_contracts.md`.
- Release and deploy work reads `docs/release_operations.md` and
  `docs/web_surface_architecture.md`.
- React web work reads `docs/web_surface_architecture.md`,
  `docs/agent_skills/catch-react-surface-refactor.md`, and the route/component
  registries under `design/`.

The important implementation detail is not the exact table. The important
detail is that work type, owner docs, and local checks are declared together.

## 2. Operating Model

`docs/agent_operating_model.md` defines the execution contract. It keeps agents
from using the same loop for every request.

Catch uses these modes:

- `answer`: read a narrow source of truth and answer with file-backed current
  state.
- `focused-change`: make a small code or doc change and run focused checks.
- `broad-cleanup`: generate a context pack, declare scope, classify findings,
  fix a coherent batch, and stamp proof.
- `design-implementation`: convert a design into component contracts,
  Widgetbook states or preview surfaces, implementation, and visual proof.
- `release-operation`: use runbooks and verify live or workflow state when the
  answer depends on it.
- `parallel-delegation`: use short-lived worktrees, disjoint scopes, parent
  integration, and outcome metrics.
- `strategy`: separate current-state facts from recommendations and propose an
  executable pass.

For broad cleanup, the operating model requires the agent to state the durable
goal, scope, owner docs, active rules, regression ids, commands, and acceptance
criteria before editing. This prevents "scan the repo and improve things" from
turning into random file touching.

For repeated architecture migrations, the operating model also requires a
reference pattern contract:

- create or reuse a pattern id;
- build one high-quality prototype first;
- copy the reference exhibit into the architecture doc;
- track adopters, variants, exceptions, and checks in a machine-readable
  tracker; and
- stamp the pass with the pattern id.

This makes a migration ratchet forward instead of allowing the tenth migrated
file to be worse than the first.

## 3. Docs Index And Read Policies

`docs/README.md` is the docs source-of-truth index. It keeps durable docs
separate from temporary trackers and session summaries. The policy is:

- prefer updating an existing source-of-truth doc over creating a new doc;
- create a new doc only when it has a distinct durable owner, audience, and
  update path;
- reconcile duplicate docs instead of keeping both;
- treat date-stamped audits as snapshots that must be reverified before use.

`docs/audit_registry/doc_versions.json` adds machine-readable metadata:

- `path`;
- `version`;
- `updated`;
- `status`;
- `read_policy`;
- sometimes `read_when` for more detailed routing.

`docs/audit_registry/doc_summaries.json` gives compact read/skip guidance for
long docs. The point is to reduce prompt baggage. An agent can learn which docs
matter before opening thousands of lines of historical context.

If you copy this pattern, do not start by writing more docs. Start by creating a
doc index that tells agents which docs not to read.

## 4. Context Packs

`tool/agent/context_pack.mjs` turns the routing model into a concrete packet for
one task. It reads:

- `docs/audit_registry/doc_versions.json`;
- `docs/audit_registry/rules.json`;
- `docs/agent_regression_ledger.json`;
- `docs/agent_skills/skills_manifest.json`;
- the task name and path scope passed on the command line.

It outputs:

- scope and dirty-work warning;
- owner docs and why they were selected;
- matching project-local skills;
- active rules for the touched paths;
- regression guards for the touched paths;
- command plan;
- acceptance criteria.

Example:

```sh
node tool/agent/context_pack.mjs \
  --task architecture-refactor \
  --paths lib/events,lib/explore
```

For another repo, this is the highest-leverage tool to build early. It converts
your docs and registries into an agent-readable plan. Without it, agents must
manually infer what applies to a scope.

## 5. Project-Local Skills

`docs/agent_skills/` contains short workflow routers for repeated Catch work.
The machine-readable source is `docs/agent_skills/skills_manifest.json`; the
markdown files are human-readable copies.

Each skill declares:

- `skill_id`;
- `path`;
- `version`;
- `applies_to` globs;
- `source_docs`;
- `required_tools`;
- `required_commands`;
- `success_receipt`;
- known failure modes.

Examples include:

- `catch-architecture-refactor`;
- `catch-doc-hygiene`;
- `catch-design-parity`;
- `catch-marketing-website`;
- `catch-react-surface-refactor`;
- `catch-parallel-delegation`;
- `catch-release-check`.

These skills are deliberately not a second architecture system. They route
agents to the canonical docs, commands, ledgers, and acceptance criteria for
work that happens often enough to deserve a reusable loop.

## 6. Audit Registry

`docs/audit_registry/` is the durable state for repeated cleanup, architecture,
widget, controller, testability, and documentation passes.

Key files:

- `files.jsonl`: tracked files and their latest pass metadata.
- `passes.jsonl`: append-only pass receipts with scope, rules, commands,
  outcomes, and new debt.
- `rules.json`: active, watch, and archived rules.
- `doc_versions.json`: durable doc metadata and read policies.
- `doc_summaries.json`: compact read/skip policies for long docs.
- `backlog.json`: active backlog, stable debt ids, scanner counts, and next-up
  queues.
- `agent_metrics.jsonl`: readiness scores, delegation outcomes, workflow
  metrics, and baseline receipts.
- `architecture_pattern_adoption.json`: reference exhibits, prototypes,
  adopters, variants, exceptions, and back-propagation obligations.
- generated design/widget registries such as widget classification,
  similarity, and new-widget inventory reports.

The normal loop is:

```sh
dart tool/audit_registry.dart refresh
dart tool/audit_registry.dart rules --status active
dart tool/audit_registry.dart docs --path <topic>
dart tool/audit_registry.dart next --screen-limit 20
dart tool/audit_registry.dart mark-pass \
  --pass <pass-id> \
  --rules RULE-001,RULE-002 \
  --paths path/one.dart,path/two.dart \
  --proof "command that passed"
dart tool/audit_registry.dart report
```

The registry makes progress durable. A future agent can see what was reviewed,
which rules were applied, which checks passed, and which debt remains.

## 7. Rules, Enforcement, And The Tool Manifest

Catch treats prose as insufficient enforcement. Repeated rules move into
`docs/audit_registry/rules.json`, and machine-checkable rules bind to tools in
`tool/tools_manifest.json`.

Manifest entries describe:

- stable `id`;
- `category`;
- implementation `path`;
- command;
- safety label;
- status;
- role such as `finder`, `gate`, `ratchet`, or `generator`;
- rule ids enforced by the tool;
- checks used to validate the tool;
- `vacuityProof` for gates and ratchets.

`tool/run.mjs` is the stable dispatcher:

```sh
node tool/run.mjs list
node tool/run.mjs check --manifest-only
node tool/run.mjs check --category meta
node tool/run.mjs check web:react-component-governance
```

`tool/check_enforcement_integrity.mjs` is the meta-gate. It validates that
rules, tools, CI wiring, doc anchors, known-bad probes, roles, and ratchet
baselines do not drift independently.

This is the enforcement pattern to copy:

```text
rule in rules.json
  -> owner doc anchor
  -> tool manifest entry
  -> scanner/lint/test implementation
  -> known-bad or vacuity proof
  -> CI or local gate
  -> receipt when the baseline changes
```

If a rule is not yet machine-checkable, it still gets an explicit manual
enforcement entry. Missing enforcement should be visible, not implied.

## 8. Regression Ledger

`docs/agent_regression_ledger.json` stores hard-won failures that future agents
must not rediscover. Each entry has:

- stable id;
- title;
- status;
- `applies_to` globs;
- symptom;
- guard command or manual check;
- owner docs;
- notes.

Examples include:

- broad cleanup skipping the audit registry loop;
- stale generated design and tool manifests after wide refactors;
- Widgetbook failures being misdiagnosed as setup failures;
- Flutter tests being run in parallel and racing on native asset outputs;
- parallel subagents fragmenting canonical ownership;
- enforcement assets drifting from the rules they claim to prove.

The context-pack tool surfaces matching regression guards for a scope. This is
how old mistakes become part of the next agent's starting context without
requiring a human to remember them.

## 9. Analyzer Lints, Scanners, And Ratchets

Catch uses multiple enforcement layers because not every rule fits the same
shape.

Analyzer-backed UI lints live in `packages/catch_ui_lints` and are enabled from
the top-level `analysis_options.yaml`. They surface through normal
`flutter analyze --no-fatal-infos` and IDE analyzer flows. These are used when a
UI invariant is deterministic enough to be a lint.

Repo scanners live under focused tool folders:

- `tool/architecture/` for architecture boundaries;
- `tool/audit/` for code catalog and migration candidates;
- `tool/contracts/` for schema, Firestore, and Storage contract checks;
- `tool/design/` for widget, token, Widgetbook, and design registry checks;
- `tool/marketing/` and `tool/web/` for website, admin, and React governance;
- root `tool/check_*.mjs` or `tool/check_*.sh` for stable historical
  entrypoints and meta-gates.

Scanners have different roles:

- `finder`: discovers candidates or emits inventories.
- `gate`: must pass to hand off.
- `ratchet`: permits known baseline debt but blocks new drift.
- `generator`: writes or refreshes checked-in artifacts.

Use ratchets when a codebase has existing debt but should not get worse.
Baseline changes should be reviewed and recorded as metrics or pass receipts.

## 10. Domain Source-Of-Truth Docs

The agent workflow is generic, but each domain still needs a canonical owner.
Catch has owner docs for:

- Flutter app architecture: `docs/app_architecture.md`;
- feature maps: `lib/README.md` and feature-level READMEs;
- widget inventory: `docs/widget_catalog.md`;
- design language: `docs/design_language.md`;
- design parity: `docs/design_parity/`;
- data contracts: `docs/data_contracts.md`;
- backend operations: `docs/backend_operation_catalog.md`;
- release operations: `docs/release_operations.md`;
- web surface architecture: `docs/web_surface_architecture.md`;
- marketing website architecture: `docs/marketing_website_architecture.md`;
- route and component contracts under `design/website/` and `design/admin/`.

The rule is: a scanner should point to an owner doc, and an owner doc should
tell the agent which scanner proves the rule. Either side alone will drift.

## 11. Generated Registries And Design Contracts

Generated artifacts are part of the AI workflow because they give agents a
bounded view of broad surfaces:

- `design/website/routes.json` describes public marketing routes and metadata.
- `design/website/components.json` describes marketing website component
  ownership and review coverage.
- `design/admin/components.json` describes admin route/workspace entries,
  shared primitives, feedback providers, and Storybook coverage.
- `docs/audit_registry/widget_classification.json` classifies Dart widget roles
  and ownership.
- `docs/audit_registry/widget_similarity.json` supports widget consolidation
  review.
- `docs/audit_registry/new_widget_inventory_scan.json` tracks newly added
  widgets against a base ref.
- `design_context_pack/**` and related design exports let external design tools
  and agents see the current component/tokens state.

The operating principle is that generated registries are not optional logs.
When their source changes, the generator and check must run in the same pass.

## 12. CI As The Remote Version Of Local Gates

Local checks and CI should share the same tool ids wherever possible.

Important workflow surfaces include:

- `.github/workflows/tools-ci.yml`: validates the tool manifest and runs
  manifest categories through `node tool/run.mjs`.
- `.github/workflows/flutter-ci.yml`: runs design parity, backend/frontend
  error scans, analyzer, and sequential Flutter tests.
- `.github/workflows/contracts-ci.yml`: runs contract and architecture gates.
- `.github/workflows/marketing-website.yml` and
  `.github/workflows/admin-website.yml`: validate React web builds and related
  generated contracts.
- release workflows and Firebase deploy workflows for environment and release
  operations.

The target is local-to-CI parity. A contributor should be able to run the same
tool id locally that CI uses remotely.

## 13. Parallel Agent Protocol

Parallel agents are useful only if they preserve a single integration owner.

The parent agent owns:

- architecture decisions;
- canonical docs;
- generated registries;
- audit receipts;
- final verification;
- integration of accepted branch diffs.

Subagents may own:

- read-only inventory;
- isolated patch proposals in disjoint files;
- scanner interpretation;
- alternative sketches for a named pattern.

Each subagent must prove isolation with working directory, branch, base SHA, and
status. It returns a structured packet including commit SHA, changed files,
checks run, pattern delta, risks, and "do not merge if" conditions. The parent
reviews the diff before importing anything.

Delegation outcomes are recorded with:

```sh
node tool/agent/record_delegation_outcome.mjs \
  --task-id <task-id> \
  --mode worker-patch \
  --status integrated \
  --parent-review-outcome accepted-with-edits
```

This keeps parallelism measurable. If delegation repeatedly creates conflicts
or parent rewrites, the workflow should change.

## 14. Readiness Gate And Metrics

`tool/agent/check_agent_readiness.mjs` validates that the agent harness remains
usable. It checks for:

- required entrypoint files;
- docs index references;
- doc version entries;
- registered agent tools;
- regression ledger shape;
- project-local skill shape;
- metric parseability;
- selected architecture baseline warnings.

Run it before handoff:

```sh
node tool/agent/check_agent_readiness.mjs
```

Use `--record-metric` when you want to append a trendable readiness event to
`docs/audit_registry/agent_metrics.jsonl`.

## 15. The Standard Request Loop

Use this loop for every non-trivial request:

1. Preserve the user's work.

   ```sh
   git status --short
   ```

2. Read the entrypoint and operating model.

   ```sh
   sed -n '1,240p' AGENTS.md
   sed -n '1,260p' docs/agent_operating_model.md
   ```

3. Select execution mode.

   A pointed question can be answered from narrow owner docs. A broad cleanup,
   docs consolidation, architecture refactor, design pass, or workflow-harness
   change needs a context pack.

4. Generate the context pack.

   ```sh
   node tool/agent/context_pack.mjs --task <task> --paths <paths>
   ```

5. Read only selected owner docs.

   Use `doc_versions.json` and `doc_summaries.json` before opening long docs.

6. Implement the smallest coherent batch.

   Prefer existing patterns and owner docs. Keep generated files synchronized
   when source artifacts change.

7. Run focused proof.

   Use tests, analyzer, scanners, manifest checks, route/component checks,
   contract gates, or release runbooks according to the context pack.

8. Stamp pass proof when the work is cleanup or refactor work.

   ```sh
   dart tool/audit_registry.dart mark-pass \
     --pass <pass-id> \
     --rules <rule-ids> \
     --paths <paths> \
     --proof "<command>"
   ```

9. Run readiness before handoff.

   ```sh
   node tool/agent/check_agent_readiness.mjs
   ```

10. Report what changed, which checks ran, and what remains.

## 16. How To Implement This In Another Repo

Start with a minimal version. Do not try to recreate every Catch scanner at
once.

1. Add `AGENTS.md`.

   Keep it under two pages. Include starting loop, work-type routing,
   non-negotiable rules, and completion standard.

2. Add `docs/agent_operating_model.md`.

   Define execution modes, broad-task contract, parallel-agent rules, and what
   proof is required.

3. Add a docs index and doc metadata.

   Use `docs/README.md`, `docs/audit_registry/doc_versions.json`, and
   optionally `doc_summaries.json`.

4. Add a tool manifest and runner.

   Every durable scanner or generator gets an id, command, role, checks, and
   safety label.

5. Add a rules registry.

   Store rule ids, status, applies-to globs, instructions, owner docs, and
   enforcement entries.

6. Add a context-pack generator.

   It should select owner docs, rules, regression guards, commands, and
   acceptance criteria from task name plus path scope.

7. Add a regression ledger.

   Every expensive repeated failure gets a stable id, symptom, guard, and owner
   docs.

8. Add one readiness check.

   Validate that the harness itself has not drifted. This should run locally and
   in CI.

9. Add one domain-specific gate.

   Pick a real recurring problem and enforce it with a lint, scanner, test, or
   ratchet. Do not start with ten scanners.

10. Add pass receipts.

   Use JSONL so future agents can append proof without editing historical
   entries.

11. Wire local checks to CI.

   Prefer stable tool ids in CI instead of duplicating command lists in workflow
   YAML.

12. Iterate.

   Promote repeated manual review findings into scanners only after the rule is
   stable enough to check deterministically.

## 17. Anti-Patterns This Avoids

- A huge `AGENTS.md` that tries to be the whole architecture manual.
- Long docs with no read policy.
- One-off session summaries that become stale source-of-truth docs.
- Rules that exist only as prose.
- Scanners that are not registered in a manifest.
- CI checks that cannot be run locally by stable id.
- Generated registries that drift after refactors.
- Parallel subagents editing canonical docs or generated artifacts
  independently.
- Broad migrations without a prototype and pattern-adoption tracker.
- Passing gates that only prove syntax, not the intended invariant.

## 18. Maintenance Rhythm

Use a small rhythm to keep the workflow alive:

- When a rule matters repeatedly, add or update a scanner, lint, test, contract
  check, Widgetbook coverage gate, or manual status entry.
- When a scanner is added, register it in the tool manifest with role, rules,
  checks, and vacuity proof.
- When a check's baseline changes, record a receipt.
- When a cleanup pass finishes, stamp the audit registry.
- When a repeated failure costs real time, add a regression ledger entry.
- When a doc grows long, add or tighten its read policy.
- When a temporary tracker closes, fold durable findings into the owner doc and
  delete or archive the tracker.

The workflow works because it keeps context close to the code, proof close to
the rule, and agent instructions small enough to follow.
