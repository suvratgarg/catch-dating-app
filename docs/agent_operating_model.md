---
doc_id: agent_operating_model
version: 3.0.4
updated: 2026-08-07
owner: agent_operating_model
status: active
---

# Agent Operating Model

Catch should be easy for an AI agent to change because the repository has
small routing documents, explicit source contracts, and deterministic checks.
The goal is not to make agents remember more. It is to make the correct path
the shortest path.

## What This Harness Is

Git already owns source, history, branches, worktrees, diffs, and recovery.
GitHub Actions already owns shared execution, artifacts, approvals, and
deployment history. Catch adds only three repository-specific layers:

1. `tool/harness.mjs` is a read-only impact planner. It maps explicit paths or
   a Git diff to existing checks, build lanes, and delivery lanes.
2. `tool/agent/context_pack.mjs` is optional read-only guidance. It prints
   relevant owner docs, project skills, source rules, and check suggestions to
   stdout for a supplied path set.
3. `tool/git/worktree_guard.mjs` is an optional thin safety wrapper around
   ordinary Git worktrees. It protects exact-base creation, claimed-path
   overlap, dirty or out-of-scope work, and unpushed closeout.

None of these layers schedules agents, runs a hidden command pipeline, owns
product state, or replaces Git and CI.

## Operating Principle

Treat every agent as a capable contributor with unreliable ambient memory. A
rule that matters must be one of:

- executable: a lint, scanner, test, contract check, preview coverage gate, or
  CI job;
- authored: a canonical source document or domain contract with a clear owner;
- derived: read-only planner output, Git state, or an expiring CI artifact; or
- explicitly manual: a named review point in the owning runbook.

Do not create tracked execution histories. The former audit inventory, pass
history, documentation catalog, regression snapshot, and readiness machinery
have been removed. Put recurring protection in the owning test or scanner.

## Starting Loop

1. Run `git status --short --branch` and preserve unrelated changes.
2. Read `AGENTS.md`, then only the owner documents for the changed surface.
3. For a broad change, inspect the impact plan:

   ```sh
   node tool/harness.mjs explain --paths <path[,path...]> --json
   node tool/harness.mjs plan --base <base-ref> --head HEAD --json
   ```

4. When additional orientation is useful, print optional context guidance:

   ```sh
   node tool/agent/context_pack.mjs --task <label> --paths <path[,path...]>
   ```

   This command writes nothing. Its output is advice, not permission or a
   completion condition.
5. State the intended outcome, included and excluded paths, relevant owner
   docs, focused checks, and acceptance criteria before a broad edit.

## Enforcement Integrity

Rules, tools, CI wiring, and documentation anchors must not drift
independently. Active rules in `tool/policy/rules.json` name their
enforcement. Manifest tools that enforce a rule name the reverse mapping and,
for gates or ratchets, prove that the check cannot pass vacuously. A genuinely
manual check is declared as manual in its owning rule.

Run the meta-gate after changing an enforcement asset:

```sh
node tool/run.mjs check meta:enforcement-integrity
```

Update the rule, manifest entry, documentation anchor, executable known-bad
proof, and ratchet baseline together when those sources are affected. Do not
add a prose-only rule that claims deterministic enforcement.

## Execution Modes

| Mode | Use when | Required behavior |
|---|---|---|
| `answer` | The user asks a pointed question | Read the narrow source of truth and answer from current files or live state. |
| `focused-change` | The user asks for a specific code or document change | Edit the smallest safe surface and run focused checks. |
| `broad-cleanup` | The user asks for cleanup, migration, consolidation, or refactor | Inspect the read-only plan, declare scope, fix a coherent batch, and run selected checks. |
| `design-implementation` | The user gives a design, handoff, or screenshot | Convert intent into component contracts and preview states before or alongside implementation. |
| `release-operation` | The task affects deploy, CI, Firebase, App Store, or production data | Follow the release runbook and verify external state when the answer depends on it. |
| `parallel-delegation` | Independent work can proceed concurrently | Use disjoint Git worktrees and keep one final integration owner. |
| `strategy` | The user asks what to do | Separate current facts from recommendations and propose an executable next pass. |

## Broad Cleanup Contract

Before editing a broad surface, be able to state:

- the durable outcome;
- included and explicitly excluded paths;
- owner documents and source contracts;
- executable rules and relationships that apply;
- commands that prove the batch; and
- observable acceptance criteria.

If the plan is too broad to review as one diff, split it into coherent batches.

## Reference Pattern Contract

Repeated architecture migrations start with one high-quality reference
implementation, not prose alone. Use the existing pattern-adoption contract
when the surface is governed by one:

- create or reuse its pattern id;
- build and verify one reference implementation;
- keep the reference exhibit in the owning architecture document current;
- classify adopters, variants, and explicit exceptions; and
- if a later adopter improves the pattern, update the reference and revisit
  earlier adopters.

This is product architecture state, not agent execution state.

## Git Preservation And Reconciliation

Working branches are single-use preservation units. Push bounded commits. Do
not leave unique intended work only in a working tree, stash, reflog, or local
branch.

Before a rebase, reset, amend, history rewrite, or conflict-heavy merge:

1. fetch and record the current branch, HEAD, upstream, and status;
2. create a dated recoverable `backup/` ref when the branch has unique or
   shared work;
3. keep `rerere.enabled=true` for stable repeated conflict resolution; and
4. never rewrite a shared upstream branch; create a fresh branch and import
   reviewed commits instead.

For a reconciliation touching more than 50 paths, use the exact four-tree
classifier. Review every path where both sides diverged; exact blob comparison
cannot prove semantic incorporation.

```sh
node tool/git/audit_merge_drops.mjs \
  --base <merge-base> --ours <pre-merge-ours> \
  --theirs <integrated-tip> --merged <result> --json
```

Governed Markdown owns its identity, semantic version, update date, owner, and
lifecycle in source frontmatter. Validate it against Git directly:

```sh
node tool/docs/check_doc_metadata.mjs --base origin/main
```

After a squash or merge is proven on `origin/main`, remove its disposable
worktree and prune its single-use branch. Do not reuse it for another slice.

## Repo-Managed Pre-Commit Hook

Install the repository hook for this clone only; do not use `--global`:

```sh
git config core.hooksPath tool/git/hooks
git config --get core.hooksPath
```

`core.hooksPath` is stored in the repository's common Git config, so linked
worktrees inherit it. The hook reads the source-owned compile-codegen catalog.
Staged localization ARB changes regenerate and explicitly stage the declared
Flutter outputs; staged Dart files are formatted and explicitly re-staged; all
seven committed compile-critical generator families run their declared
freshness checks when an input or output is staged. Contract changes therefore
check both schema projections and, for `contracts/callables/**`, Admin callable
validators. A failure prints the exact write command to run.

The hook does not run the analyzer or broad test suites. It refuses partially
staged Dart files because formatting and re-staging one would otherwise absorb
unstaged work into the commit. Bootstrap a fresh worktree before using the hook
so its pinned Flutter, Dart, root npm, and Functions npm dependencies exist.

## Parallel Worktrees

Parallel agents are useful only when one parent remains responsible for the
integrated result. Assign disjoint file sets. Keep shared architecture
decisions, canonical owner documents, common manifests, and final verification
with the parent unless a child is explicitly assigned the whole file set.

After creating a worktree, bootstrap its own pinned dependencies with one
repository command:

```sh
bash tool/git/bootstrap_worktree.sh
```

The command runs root `npm ci`, Functions `npm ci`, and `flutter pub get` in
that worktree. Keep these installs local to the worktree; do not symlink
another checkout's `node_modules` or invent `NODE_PATH` overrides.

The worktree guard is optional. Use it when several local tasks need an
overlap check or when safe closeout is easy to forget:

```sh
node tool/git/worktree_guard.mjs start \
  --task-id <task-id> \
  --base-sha <40-character-sha> \
  --paths <claimed-path[,claimed-path...]>
node tool/git/worktree_guard.mjs doctor --worktree <path>
node tool/git/worktree_guard.mjs finish --worktree <path>
node tool/git/worktree_guard.mjs finish --worktree <path> \
  --abandon --reason <why> [--by <identity>]
node tool/git/worktree_guard.mjs stale --stale-days 7
```

`start` creates a normal branch and worktree at the exact supplied commit and
records a disposable local claimed-path set. It refuses overlap with another
active local claim. `doctor` reports registration, branch, dirty-state, and
out-of-scope problems. `finish` removes only the local claim after the branch
is clean and any unique commits are pushed. `stale` reports candidates and
never deletes anything. When a task is deliberately superseded and pushing its
commits is inappropriate, `finish --abandon` releases the claim only if the
worktree is clean. It requires a reason, records `--by` or the local Git
identity in a disposable file under Git's common directory, and leaves the
branch and worktree untouched.

The guard does not install dependencies, run checks, push, merge, remove a
worktree, or authorize commands. A contributor can use ordinary Git directly
when local claims are unnecessary.

### Delegation Flow

1. The parent records its exact base SHA and assigns non-overlapping claimed
   paths. It may inspect a planner result or optional context guidance first.
2. The child confirms its worktree, branch, base SHA, and status before editing.
   When using the guard, `doctor` performs the local safety inspection.
3. The child edits only its assigned files, runs focused checks sequentially
   where the toolchain requires it, commits, pushes, and reports the branch,
   commit SHA, changed files, checks, and blockers.
4. The parent reviews the Git diff and imports only accepted commits. The
   parent then runs integration checks and reviews the final diff.
5. When using the guard, run `finish` after clean, pushed closeout. If the task
   was superseded, use the explicit clean-only `finish --abandon` path. Remove
   the disposable worktree separately with an explicit Git command when
   desired.

If a child appears on the parent's worktree or edits an overlapping file set,
stop it and preserve only a reviewed Git diff. If the parent base advances,
finish or preserve the old proposal and create a fresh worktree from the new
exact SHA instead of silently rebasing a live child.

### Ownership Rules

- One file has one writer during a parallel batch.
- Parent-owned by default: `AGENTS.md`, this document, canonical architecture
  docs, authored design contracts, shared manifests, and integration changes.
- Children avoid generated output unless generation is their explicit task.
- Flutter tests, Flutter analysis, emulator checks, and native builds run
  sequentially unless one isolated verification owner is assigned.

Assess delegation with ordinary task and PR wall time, merge conflict rate,
escaped defects, and user rework. Keep that analysis in the task or CI system,
not in repository telemetry.

## UI And Design Implementation

Design work should flow through:

```text
design or handoff
  -> component or screen contract
  -> Widgetbook state or preview surface
  -> implementation
  -> screenshot, golden, or focused visual review
  -> deterministic design checks
```

When intent is ambiguous, inspect the actual artifact or preview before asking
for a narrow product decision.

## Regression Ownership

Put regression protection in the owning test, scanner, component risk gate, or
named manual release check. Do not recreate a central regression database.

## Project Skills

Project-local skills under `docs/agent_skills/` are short routers to canonical
documents and existing checks. Their machine-readable manifest owns path
matching and required checks. Context guidance is optional and does not make
the skills a second architecture system.

After changing skill routing, run:

```sh
node tool/run.mjs check agent:context-pack
```

## Completion

A task is complete when the intended source and contract changes exist,
compile-critical generated output is synchronized, relevant deterministic
checks pass, the final Git diff is bounded, and any required external state is
verified. No tracked harness evidence is required.

The harness remains healthy when the planner explains affected work without
writing source, optional context guidance stays stdout-only, parallel work is
ordinary Git plus a thin optional guard, and an ordinary product change causes
zero governance-file churn.
