---
doc_id: agent_operating_model
version: 1.0.0
updated: 2026-06-30
owner: agent_operating_model
status: active
---

# Agent Operating Model

Catch should be easy for an AI agent to understand because the repo contains
small routing docs, machine-readable contracts, deterministic checks, and proof
ledgers. The goal is not to make agents remember more. The goal is to make the
correct workflow cheaper than a partial fix.

## Operating Principle

Treat every agent as a capable contributor with unreliable ambient memory.
Instructions that matter must be one of:

- executable: lint, scanner, test, contract check, generated manifest, Widgetbook
  coverage, CI job;
- versioned: canonical docs and registries with clear owners;
- measured: pass receipts, regression ids, readiness scores, and trendable
  metrics; or
- explicitly manual: a named human review point with a stable checklist.

If a rule is only a paragraph in a long doc, expect it to drift.

## Execution Modes

| Mode | Use when | Required behavior |
|---|---|---|
| `answer` | The user asks a pointed question | Read the narrow source of truth and answer with file-backed current state. |
| `focused-change` | The user asks for a specific code/doc change | Read owner docs, edit the smallest safe surface, run focused checks. |
| `broad-cleanup` | The user asks for cleanup, migration, consolidation, or refactor | Generate a context pack, declare scope, classify findings, fix a coherent batch, stamp proof. |
| `design-implementation` | The user gives a design/handoff/screenshot | Convert intent into component contracts and Widgetbook states before or alongside Flutter implementation. |
| `release-operation` | The task affects deploy, release, CI, Firebase, App Store, or production data | Use documented runbooks and verify live/workflow state when the answer depends on it. |
| `strategy` | The user asks what to do | Separate current-state facts from recommendations and propose an executable next pass. |

## Broad Cleanup Contract

Before editing in `broad-cleanup`, the agent must be able to state:

- goal: the durable outcome, not just a file list;
- scope: included paths and explicitly excluded paths;
- owner docs: source-of-truth files that govern the change;
- active rules: audit or architecture rules that apply;
- regression ids: relevant entries from `docs/agent_regression_ledger.json`;
- commands: checks that prove the batch;
- acceptance: what must be true to call the batch done.

Use `node tool/agent/context_pack.mjs` to assemble this packet. If the packet is
too broad, split the work into numbered batches and record remaining debt.

## UI And Design Implementation Contract

Do not use "read design and eyeball implementation" as the main workflow.
Design work should flow through:

```text
design or handoff
  -> component/screen contract
  -> Widgetbook states or preview surface
  -> implementation
  -> screenshot, golden, or focused visual review
  -> design/check proof
```

When design intent is ambiguous, ask for a narrow decision only after inspecting
the actual design artifact or Widgetbook surface.

## Regression Ledger

`docs/agent_regression_ledger.json` is the durable list of hard-won fixes that
should not be reintroduced. Each entry has:

- `id`: stable id referenced by context packs and pass receipts;
- `title`: short failure description;
- `status`: `active`, `watch`, or `archived`;
- `applies_to`: paths or globs;
- `symptom`: what regressed;
- `guard`: command, test, scanner, or manual check;
- `owner_docs`: canonical docs to read before touching the area.

Add a ledger entry whenever a bug or drift pattern has cost enough time that the
next agent should see it before editing.

## Skill Freshness

Project-local agent skills live under `docs/agent_skills/`. They are not a
second architecture system. They are short workflow routers that point to
canonical docs, commands, ledgers, and acceptance criteria.

Each skill must declare:

- `skill_id`;
- `version`;
- `updated`;
- `source_docs`;
- `required_commands`;
- `success_receipt`;
- `known_failure_modes`.

The readiness gate checks that skill source docs and commands still exist.

## Measuring Workflow Quality

The readiness gate reports an `agent readiness score`. The score is intentionally
simple at first:

- required docs exist and are indexed;
- regression ledger is valid and every active entry has a guard;
- project-local skills resolve their source docs and commands;
- tool manifest includes the agent scripts;
- metric files are parseable.

Append durable measurements to `docs/audit_registry/agent_metrics.jsonl` after
meaningful broad passes. Useful metrics:

- readiness score;
- context-pack count generated for the pass;
- checks planned versus checks run;
- scanner count deltas;
- regressions added, moved to watch, or archived;
- user-reported rework after the pass.

Over time, workflows with higher pass rates and lower rework should become the
default recommended path in `AGENTS.md` and the relevant skill.

## Done Criteria For This Harness

This operating model is active only if:

- `AGENTS.md` routes agents here;
- `docs/README.md` and `docs/audit_registry/doc_versions.json` index this doc;
- `tool/agent/context_pack.mjs` can build scoped packets;
- `tool/agent/check_agent_readiness.mjs` validates the harness; and
- `node tool/run.mjs check --category agent` passes.
