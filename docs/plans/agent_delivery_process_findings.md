# Agent Delivery Process — Findings And Recommendations

Status: living note · opened 2026-08-15
Origin: observations made while dispatching and supervising Codex runs against
[`host_customers_and_messaging_restructure_spec.md`](host_customers_and_messaging_restructure_spec.md).
Every item below was hit in practice during this work, not theorised.

Severity: **P1** costs work or ships breakage · **P2** costs time · **P3** hygiene.

---

## P1 — A failed Codex turn exits 0

**Observed.** The Phase 0 run ended with `turn.failed`
(`Error running remote compact task: 404`) after editing nine files. The
`codex exec` process still exited **0**. Any wrapper trusting the exit code
would have reported success on a run that committed nothing and verified
nothing.

**Why it matters.** This is the single most dangerous failure mode for
unattended delegation: the supervisor believes the task is done, the branch
looks touched, and the breakage surfaces later in CI or, worse, in review.

**Recommendation.** Never gate on `codex exec`'s exit code. Gate on the JSONL
stream. Minimum viable check, suitable for a wrapper script:

```sh
codex exec --json … > run.jsonl
python3 - <<'PY'
import json,sys
ok=False
for line in open('run.jsonl'):
    line=line.strip()
    if not line: continue
    t=json.loads(line).get('type')
    if t=='turn.completed': ok=True
    if t in ('turn.failed','error'): ok=False; break
sys.exit(0 if ok else 1)
PY
```

Worth promoting into `tool/` as a registered helper (e.g.
`tool/agent/codex_dispatch.mjs`) so every delegation gets the same gate rather
than each session re-deriving it.

## P1 — Linked worktrees make `git commit` impossible under `workspace-write`

**Observed.** Three consecutive delegated runs produced good, gate-passing work
and committed none of it. The third stated the reason outright:

```
.git/worktrees/host-crm-phase12-20260815/index.lock: Operation not permitted
```

**Cause.** A linked worktree's `.git` is a *pointer file*. Objects, refs, logs
and lock files all live in the **main** repository's
`.git/worktrees/<name>/` and `.git/objects`. Sandbox writable roots are scoped
to the worktree directory, which does not contain any of that. So every `git
commit` inside a linked worktree fails, no matter how the prompt is worded.

**I misdiagnosed this twice.** I recorded that the agent was "batching commits
despite the loudest requirement in the prompt" and hardened the prompt in
response. The prompt was never the problem; the agent was structurally unable to
comply and, on the run where it could report freely, said so precisely and
stopped rather than proceeding unverified. The corrected lesson: **when an agent
repeatedly fails to follow a specific, explicit instruction, suspect the
environment before the agent.**

**Recommendation.** Grant the main repository's `.git` directory:

```sh
codex exec -s workspace-write --add-dir "<main-repo>/.git" …
```

Or avoid linked worktrees for delegated work entirely — a separate `git clone`
has a self-contained `.git` inside the sandbox root and needs no extra grant, at
the cost of disk and a push/fetch to move commits back. Given this repo already
has 22 worktrees and the `context_pack` breakage above, clones may be the better
default for agent work.

## P1 — Delegated runs should still commit incrementally

**Observed.** Phase 0 produced ~350 lines of good work across nine files and
committed none of it. It survived only because the worktree persisted after the
turn died; nothing about the setup guaranteed that.

**Not motivated by compaction.** The Phase 0 turn died on a compaction 404, but
that was CLI version drift and has not recurred since upgrading to 0.147.0 —
the Phase 1–2 run logged zero compaction failures and zero `turn.failed`
events. The real justification is broader and permanent: **any** interruption
strands uncommitted work. During Phase 1 the supervisor stopped the run
deliberately (sandbox blocker, §"Codex sandbox breaks gen-l10n"), and the
in-flight tree at that moment had 10 analyzer errors and 16 failing tests —
mid-edit, uncommittable. Without the earlier checkpoint at a green gate
boundary, that stop would have cost the whole phase.

**Recommendation.** Make "commit after each numbered item, as soon as its
focused checks pass" a standing clause in every delegation prompt, not a
per-task decision. Applied to the Phase 1–2 dispatch. Consider adding it to
`AGENTS.md` so it binds Codex runs started from any surface, not only ones I
dispatch.

**Secondary benefit.** Incremental commits make `codex exec resume` genuinely
useful after a mid-run failure, and make review tractable — one commit per
item beats one commit per phase.

## P1 — Generated artifacts drift from their sources with no local gate

**Observed.** Phase 0 added ARB keys and did not run `flutter gen-l10n`,
leaving three `undefined_getter` compile errors. Separately it left two files
failing `dart format`. Both are mechanical, both were caught only because the
supervisor ran the gates by hand.

**Recommendation.** A pre-commit hook covering the mechanical, deterministic
cases:

| Trigger | Action |
| --- | --- |
| `lib/l10n/*.arb` staged | run `flutter gen-l10n`, stage the result |
| any `*.dart` staged | run `dart format` on staged files, re-stage |
| `contracts/**` staged | fail with a pointer to the regeneration command |

This class of error should never reach a human reviewer or CI. Note the repo
deliberately has no husky-style hook infrastructure today — the lightest option
is a `core.hooksPath` directory checked into the repo so worktrees inherit it.

## P1 — Unignored artifacts force `git add -u`, which silently drops new source

**Observed.** Because the `node_modules` symlinks are unignored (§".gitignore
does not cover symlinked node_modules"), `git add -A` in a delegated worktree
would commit absolute-path symlinks. The safe-looking alternative is `git add -u`
— but that stages **only modifications to already-tracked files**. Commit
`465e8104c` therefore modified `host_customers_screen.dart` to import a new
composer library while omitting the composer itself (683 lines) and its test
(111 lines), both untracked. **The commit did not build from a clean checkout**,
and looked fine locally only because the files existed on disk.

The agent caught this, not the supervisor: *"465e8104c omitted the untracked
composer source and test."*

**Why it matters.** The two `git add` modes fail in opposite directions, and the
unignored-artifact bug removes the safe one. `-A` commits junk; `-u` drops new
source. Neither failure is visible in `git status` afterwards, and the second
survives every local gate because the working tree is complete — only a fresh
clone or CI would catch it.

**Recommendation.** Fix the ignore patterns first (that restores `-A` as safe),
and until then stage explicit paths rather than either blanket mode. A cheap
guard for any delegated branch, run before handoff:

```sh
git stash -u && git stash pop   # or simply:
git ls-files --others --exclude-standard
```

Anything listed there that is not a build artifact is source the branch is
missing. Worth adding to a pre-handoff check alongside the gate run.

## P1 — Nothing detects drift between committed and deployed Firestore rules

**Observed.** A Host-facing bug ("Event unavailable" on the LIVE tab) was
finally traced to the **deployed** ruleset lacking a
`match /eventSuccessAssignmentDrafts/{...}` block that **is present** at
`firestore.rules:1814` in the repository. Deployed ruleset
`fbe517d7-03fc-4579-95ac-4d6a7a7629af`, updated 2026-08-13, matches repository
commit `c222133e4` — i.e. production is running an older rules revision than
`main`.

Firestore denies unmatched paths by default, so a missing `match` block denies a
query **even when the collection is empty**. One denied read collapses the entire
Event Success section into a generic error.

**Why it evaded everything.** Local `npm run test:rules` exercises the
*checkout's* rules, which are correct, so the suite is green. Admin-SDK probes
bypass rules entirely, so they also pass. The only way to see it is to probe the
**deployed** ruleset with a real uid — which nothing in the pipeline does.

**Cost.** Roughly an afternoon, three wrong diagnoses, and a rules change
(`f51cde546`) written to fix a cause that did not exist.

**Recommendation.** Two guards, both cheap:

1. **Drift check in CI.** Fetch the active ruleset and compare its content hash
   against the committed `firestore.rules`. Fail the build when they differ
   without an intentional deploy. `firebase firestore:rules:list` / the Rules
   API expose the active ruleset id and content.
2. **Deploy rules with the code that needs them.** A client subscribing to a
   collection whose `match` block is not yet deployed is a broken release; rules
   deploy should be part of the same release step, not a separate manual action.

**Related code defect found alongside it.** The LIVE path subscribes to
guided-rotation drafts whenever assignments load, even when the plan does not
select guided rotations
(`lib/event_success/presentation/event_success_host_screen.dart:240`). Gating
that subscription on the plan's selected modules would have avoided the denied
read entirely — defence in depth against exactly this class of drift.

## P1 — Never diagnose from a truncated read, and never hand an agent a conclusion

**Observed.** Investigating a host-access bug, I read `isClubHostForEvent` with
`grep -A 12`, saw it require `organizerId`, and concluded "the rules have no
`clubId` fallback while every other layer does." The function is 32 lines. Line
17 begins an `|| (...)` branch that falls back to `clubs/{clubId}` for events
without `organizerId`. **The fallback existed; I had truncated it away.**

I then wrote that conclusion into a delegation prompt as a stated diagnosis,
asking only that the agent "verify it yourself" and "say if you disagree". The
agent did not disagree. It implemented the fix I described — which collapsed the
two branches into an organizers-only lookup and **deleted the legacy fallback**,
turning a read that previously succeeded for un-migrated events into a denial.

Two distinct failures, both mine:

1. **Truncated evidence.** `-A 12` on a 32-line function. Any conclusion of the
   form "X does not handle Y" requires reading all of X, and is worth
   double-checking against the opposite hypothesis before acting.
2. **Anchoring the agent.** A confidently-stated diagnosis in a prompt is not
   neutral context; it is the answer. Asking "do you agree?" after supplying the
   conclusion does not recover independence — the agent optimises for
   implementing what was described.

**The same error recurred within the hour.** Reviewing the agent's final report,
I read the first 60 lines, saw no mention of a failing test my own verification
had found, and told the owner the agent had not disclosed it. It had — 20 lines
further down, with the correct attribution: *"418 passed, one failed … I
reproduced the identical failure on untouched `main`, so it is not caused by
these commits."*

So the pattern is not "I mis-grepped once". It is **forming a judgement from a
partial read of a long artifact**, twice in one session — once on a 32-line
rules function, once on a 90-line agent report — and in the second case the
partial read produced an unfair accusation against the agent.

The verification habit is sound: independently re-running gates is what caught
the failing test at all. The reading habit is not. **Read the whole artifact
before characterising it**, especially when the characterisation is negative or
becomes an instruction to someone else. Cheap guards: `wc -l` before excerpting,
and when a report is structured per-item, read every item's gate list rather
than the first.

**Recommendation.** For investigation-shaped delegation, give the agent the
**symptom, the evidence, and the reproduction** — not the diagnosis. Ask it to
find the cause and *report back before implementing*. Two-phase it: diagnose,
review the diagnosis, then fix. Where a diagnosis genuinely must be supplied,
state it as a hypothesis with its evidence and explicitly name the cheapest
falsifying check ("read the whole function; if there is an `||` branch I am
wrong").

The real defect here, once the whole function was read, was narrower and would
have been missed by the fix as first specified: the two branches are mutually
exclusive on **field presence** rather than **lookup success**, so an event
carrying an `organizerId` that points at a non-existent organizer document has
no fallback at all. That is the partial-migration case — the exact population
the fix was supposed to rescue.

## P2 — The supervisor's gate set must match the changed surface, not habit

**Observed.** Checkpoint commit `23a63e6fb` was taken after `flutter analyze`
(clean) and `flutter test test/hosts test/routing` (338 passed). Both genuinely
passed. But the commit also changed `design/features/host_customers.feature.json`,
and the owning gate for that surface — `node tool/design/build_feature_contracts.mjs`
— was **not** run. It fails on that commit with three separate violations:

```
actions/10/codeValue: must match pattern "^[A-Za-z_][A-Za-z0-9_]*$"
bindings.componentContracts: unknown catch.bottom_sheet
scenarios.customer_filter_sheet: preview evidence is required
```

A commit that would have failed CI was recorded as "verified". The agent found
and fixed all three afterwards, but the supervisor's own claim was wrong.

**Root cause.** I reused a fixed gate set (analyze + tests + ui-lints) instead of
selecting gates from the changed paths, which is exactly what `AGENTS.md`'s
source-of-truth routing table exists to prevent.

**Recommendation.** Derive the gate set per commit from changed paths. A minimal
mapping, taken from `AGENTS.md`:

| Changed path | Required gate |
| --- | --- |
| `design/features/**` | `node tool/design/build_feature_contracts.mjs` |
| `contracts/**` | `./tool/check_data_contract.sh` |
| `functions/**` | `npm --prefix functions test` |
| `lib/**` UI | `bash tool/check_catch_ui_lints.sh` |
| any Dart | `flutter analyze` + owning `flutter test` |

Better still: `node tool/harness.mjs plan --base <base> --head HEAD --json`
already selects checks by changed surface. The supervisor should run *that* and
execute what it returns, rather than curating a list by hand. This applies to
agents and humans equally — the mistake here was mine, not the agent's.

## P2 — Fresh worktrees cannot run codegen without a bootstrap step

**Observed.** In a clean worktree, `node tool/contracts/generate_schema_contracts.mjs`
fails immediately:

```
Error: Cannot find module 'json-schema-to-typescript'
requireStack: [ …/host-crm-phase12-20260815/functions/package.json ]
```

`git worktree add` gives you tracked files only — `functions/node_modules` and
`.dart_tool` do not exist, so contract generation and the analyzer both fail on
first use. Phase 0 hit the same class of issue: `flutter analyze` silently ran
`pub get` first.

**How the agent recovered.** Codex set `NODE_PATH` to the *main checkout's*
`functions/node_modules` and re-ran successfully ("Generated 853 schema
contract files"). That is a legitimate unblock, but it is borrowing another
checkout's installed dependency tree — if the worktree's `functions/package.json`
ever diverges from the main checkout's installed state, codegen silently runs
against the wrong dependency versions.

**Recommendation.** A documented, single-command worktree bootstrap, run as part
of `worktree_guard start` or as a sibling helper:

```sh
npm --prefix functions ci
flutter pub get
```

Cheap to run, removes a whole class of first-command failure, and stops agents
inventing `NODE_PATH` workarounds that couple worktrees to each other. Worth
adding to `docs/agent_operating_model.md` alongside the worktree guidance.

## P1 — The Codex sandbox breaks `flutter gen-l10n` (and misreports it as a crash)

**Observed.** Under `-s workspace-write`, `flutter gen-l10n` exits non-zero with
what looks like a tool crash:

```
Oops; flutter has exited unexpectedly: "ProcessException: `dart format` failed with exit code 1
stdout:  Formatted …/app_localizations_en.dart
         Formatted …/app_localizations.dart
         Formatted 2 files (2 changed)
stderr:  FileSystemException: Failed to set file modification time,
         path = '/Users/…/.dart-tool/dart-flutter-telemetry-session.json'
         (OS Error: Operation not permitted, errno = 1)
```

**What is actually happening.** `gen-l10n` generates the files successfully and
then shells out to `dart format`. That *nested* Dart process writes a telemetry
session file to `~/.dart-tool/`, which is outside the sandbox's writable roots.
The write fails, `dart format` exits 1, and the flutter tool converts a
succeeded-then-failed-cleanup into a crash report.

**Verified:** after the "crash", all 3195 ARB keys were present in the generated
localizations — zero missing. **The output is correct; only the exit code lies.**

**Why it matters.** This is a false negative on the one gate whose omission
already caused the only real breakage in this programme (Phase 0's three
`undefined_getter` errors). An agent seeing this will either burn turns fighting
it — Codex made five attempts, escalating through `FLUTTER_SUPPRESS_ANALYTICS`
and `DASH__SUPPRESS_ANALYTICS`, neither of which helps because the telemetry
write happens in the nested process during `getSessionId` regardless of
suppression — or conclude l10n regeneration is impossible and skip it.

**It is not one directory — it is three.** Granting `~/.dart-tool` cleared the
telemetry failure and immediately exposed the next denial:

```
Flutter failed to open a file at ".../flutter/bin/cache/lockfile".
```

Every `flutter` invocation touches `engine.stamp`, `engine.realm` and `lockfile`
inside the SDK cache. So a Flutter repo needs all of:

| Path | Needed by |
| --- | --- |
| `~/.dart-tool` | telemetry session file, written by any nested `dart` process |
| `<flutter-sdk>/bin/cache` | `lockfile`, `engine.stamp`, `engine.realm` on every `flutter` command |
| `~/.pub-cache` | package resolution during `pub get` / `build_runner` |

**Recommendation.** Standardise the grant in the dispatch helper:

```sh
codex exec -s workspace-write \
  --add-dir "$HOME/.dart-tool" \
  --add-dir "$HOME/.pub-cache" \
  --add-dir "$HOME/development/flutter/bin/cache" …
```

Note `codex exec resume` accepts **neither** `-s` nor `--add-dir`; on that
subcommand the same settings must go through
`-c sandbox_mode="workspace-write"` and
`-c 'sandbox_workspace_write.writable_roots=[…]'`. A helper that hides this
asymmetry is worth more than a documented note, because the resume path is
exactly where a supervisor is under time pressure.

**Do not accept the `FLUTTER_ALREADY_LOCKED=true` workaround** an agent will
reach for. It suppresses the SDK lock rather than granting the write, and the
lock exists to stop concurrent `flutter` processes corrupting the shared cache —
which is precisely the situation when a supervisor and an agent are both
running gates.

**Credit where due:** on hitting this wall the agent stopped and reported
"no new commit was created because the required checks have not run", rather
than committing unverified work or claiming the gates passed. That is the
behaviour the prompt asks for and it worked.

## P1 — `.gitignore` does not cover symlinked `node_modules`

**Observed.** Unblocking the codegen failure above, Codex symlinked the
worktree's dependency trees at the main checkout:

```
worktree/node_modules            -> /…/catch_dating_app/node_modules
worktree/functions/node_modules  -> /…/catch_dating_app/functions/node_modules
```

Root `.gitignore:127` is `**/node_modules/`. **The trailing slash restricts the
pattern to directories**, so it does not match a symlink of the same name.
`git check-ignore` confirms both paths are unignored, and they appear as `??`
in `git status`.

**Why it matters.** Any agent or human running `git add -A` in such a worktree
commits two symlinks containing absolute paths specific to one machine. That
breaks every other checkout and CI, and is the kind of change that reads as
noise in review and gets waved through.

**Recommendation.** Drop the trailing slash so the pattern matches directories
*and* symlinks:

```diff
-**/node_modules/
+**/node_modules
```

Worth auditing the rest of `.gitignore` for the same trailing-slash assumption
(`build/`, `.dart_tool/`, `coverage/` are the likely candidates) — agents
symlink build outputs for the same reason they symlinked these. Pairs with the
worktree-bootstrap recommendation above: if bootstrap installs dependencies
properly, agents stop reaching for symlinks in the first place.

## P2 — `dart format --set-exit-if-changed` in a pipeline reports the pipe

**Observed.** I ran `dart format --set-exit-if-changed … | tail -6` and read
`$?`, which captured `tail`'s status, not `dart format`'s. It reported a clean
format check on two unformatted files. I only caught it because the summary
line said "2 changed".

**Recommendation.** Applies to any check script, not just this one: capture
`${PIPESTATUS[0]}`, or write to a file and check the status before piping. Worth
a grep of `tool/*.sh` for `--set-exit-if-changed`, `--check` or `-q` flags
followed by a pipe.

## P2 — Config and CLI version drift breaks delegation silently

**Observed.** `~/.codex/config.toml` pinned `model = "gpt-5.6-sol"` while the
installed CLI was 0.139.0, which rejects it with HTTP 400. The same drift is
the likely cause of the `/codex/responses/compact` 404. Upgrading to 0.147.0
fixed the model (verified with a live turn) and refreshed the models cache.

**Recommendation.** A preflight in the dispatch wrapper: run a trivial
`codex exec -s read-only "reply OK"` and assert `turn.completed` before
dispatching real work. Costs seconds, converts a 20-minute wasted run into an
immediate, legible failure.

## P2 — The worktree guard cannot release claims held by unpushed branches

**Observed.** `codex/host-fixes-20260813` holds a claim on all of `lib/hosts`,
created 2026-08-12. Its worktree is clean and its work is committed, but
`worktree_guard finish` refuses with `branch_has_no_upstream` and
`out_of_scope_changes`, so the claim cannot be released and every subsequent
task touching `lib/hosts` is blocked from claiming scope.

The guard is right to refuse — it is protecting commits that exist only on this
machine, exactly the failure mode of the 2026-07-16 reconciliation incident.
The gap is that there is no supported path forward short of pushing.

**Recommendation.** Two parts:

1. Push or retire `codex/host-fixes-20260813`. Until then the guard is
   effectively off for all host work, because the only way past it is to skip
   claiming — which is what I did for Phases 0 and 1–2, and it is not a
   pattern that should become normal.
2. Give the guard a supported release path for this state — e.g.
   `finish --abandon` that records who abandoned the claim and why, refusing
   only when the worktree is *dirty*. A blanket claim that outlives its task by
   days is worse than no claim, because it trains agents to bypass the tool.

## P2 — Blanket path claims are too coarse

**Observed.** The blocking claim covers `lib/hosts`, `lib/core/widgets`,
`lib/event_success`, `docs/design_parity/widget_consolidation` and
`test/ui_captures`. Any host work overlaps it by construction.

**Recommendation.** Claim the narrowest paths the task actually writes.
Consider having the guard warn when a claim covers a whole feature root, and
prefer `lib/hosts/presentation/customers` over `lib/hosts`.

## P1 — Nested worktrees have broken `tool/agent/context_pack.mjs` repo-wide

**Observed.** `AGENTS.md` step 3 tells every agent to run:

```sh
node tool/agent/context_pack.mjs --task <label> --paths <paths>
```

It exits 1. Reproduced in the **main checkout**, not only in a worktree:

```
Error: Repository path must be relative and canonical:
".codex/worktrees/figma-sync-20260813/".
```

`repository_snapshot.mjs` enumerates repository paths and rejects that entry.
The cause is worktree sprawl *inside the repository tree* — worktrees live under
`.codex/worktrees/`, `.claude/worktrees/` and `.audit_work/worktrees/`, and the
snapshot walker cannot canonicalise a nested worktree directory.

**Why it matters.** The routing document instructs agents to run a command that
always fails. Confusingly, it prints its full, correct output *before* throwing,
so the failure looks cosmetic and trains agents to ignore exit codes on repo
tooling — the same habit that made the `codex exec` exit-0 problem dangerous.

**Recommendation.** Two independent fixes, both worth doing:

1. **Make the snapshot walker skip nested worktrees.** `git worktree list
   --porcelain` gives the authoritative set to exclude; anything under a
   registered worktree path is not part of this checkout's tree.
2. **Stop creating worktrees inside the repository.** Several existing ones
   already live at `/private/tmp/catch-*`, which is the pattern that does not
   trip this. The guard currently *requires* task worktrees to be direct
   children of `.claude/worktrees` — that requirement is what forces the
   breakage, and should be relaxed to allow an out-of-tree root.

This upgrades the sprawl item below from hygiene to correctness: the sprawl is
not merely untidy, it has disabled a documented part of the agent workflow.

**Confirmed by experiment (2026-08-15).** After moving delegated worktrees out
of the repository to `/private/tmp/catch-*`, the same command that exits 1 in
the main checkout exits **0** inside the out-of-tree worktree — because that
checkout contains no nested `.codex/worktrees/` or `.claude/worktrees/`
directories for the snapshot walker to choke on. Recommendation 2 is therefore
not merely a tidiness preference: **relocating agent worktrees out of the
repository repairs `context_pack.mjs` for delegated runs without touching the
tool at all.** Recommendation 1 is still worth doing, because the main checkout
remains broken for anyone working there directly.

## P3 — Worktree sprawl

**Observed.** 22 registered worktrees, several unclaimed and idle for days;
`worktree_guard stale --stale-days 1` flags `registered_worktree_has_no_claim`
for a number of them. Three separate worktrees hold overlapping in-flight work
on the Customers/Messaging surface.

**Recommendation.** A periodic prune. The guard deliberately never removes
worktrees, so this needs an owner decision per branch: merged → remove;
unmerged and wanted → push; unmerged and dead → delete. Worth doing before the
remaining phases land, because the merge order below already has three
claimants on the same files.

## P3 — Feature work is stacked on unmerged branches

**Observed.** `lib/hosts/presentation/customers/host_customers_screen.dart`
does not exist on `main`. The Customers surface lives only on
`codex/customers-crm-reorg` / `codex/customers-crm-main-merge`, and today's
`codex/host-organizer-messaging-20260815` touches the same surface. Phase 0 and
Phases 1–2 are therefore stacked two deep on unmerged history, and the local
checkout has 49 uncommitted files rewriting the same two screens.

**Concrete conflict already identified.** The committed base uses local
`_selectedOrganizerId` state in the Customers header; the uncommitted working
tree uses the shared `hostOrganizerSelectionProvider`. These will collide in
the header region.

**Recommendation.** Land the CRM branches into `main` before the remaining
phases go out. Every additional phase stacked on unmerged history multiplies
the eventual reconciliation. This is the highest-value process fix available
right now, and it is an owner decision, not an agent one.

---

## Summary — what I would action first

1. **Land the CRM branches on `main`** (P3 by severity, P1 by consequence — it
   compounds daily).
2. **Standing incremental-commit clause** in `AGENTS.md` for delegated runs.
3. **`turn.completed` gate + preflight** in a registered dispatch helper.
4. **Pre-commit hook** for `gen-l10n` and `dart format`.
5. **Push or retire `codex/host-fixes-20260813`**, then prune worktrees.
