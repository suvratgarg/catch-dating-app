---
doc_id: process_stack_review
version: 1.0.0
updated: 2026-08-16
owner: agent_operating_model
status: proposed
---

# Process Stack Review

Written after a single long delegated-agent session (2026-08-15/16) that shipped
four PRs, fixed a production incident, migrated production data — and produced
**three wrong diagnoses, one production rules regression, and roughly twelve
hours lost to a hung agent reported as healthy.**

Every finding below is grounded in something that actually happened in that
session, not in general principle. Where a claim is inference rather than
observation, it says so.

---

## 0. The unifying failure

Every significant error in the session was the same shape:

> **A representation of the system drifted from the system, and something
> trusted the representation.**

| What was trusted | What was true | Cost |
| --- | --- | --- |
| A branch named `main` | 17 commits behind origin, never pushed | Production rules regressed for ~1h |
| `grep -A 12` of a 32-line rules function | The `||` fallback branch was on line 17 | Wrong root cause; a regression built on it |
| First 60 lines of a 90-line agent report | The disclosure was 20 lines further down | Unfair accusation against the agent |
| `docs/data_contracts.md:292` emulator command | Missing `--project`; 8 Storage tests fail on a healthy tree | ~1h, nearly reported `main` as broken |
| `contracts/migrations/clubs_to_organizers.json` receipt: "41/41, no blockers" | Live dry-run: 7 writes needed, 5 blockers | Migration assumed complete when it was not |
| Spec citing `audience.readPii` | Appears nowhere in `functions/` or `lib/` | A phase specified against a capability that does not exist |
| Spec's "two free sort options" | The callable has **no sort field** at all | A phase item that could not be built as written |
| "Known pre-existing test failure" | Fixed upstream; only failing on my stale base | Two agents told to ignore a passing test |
| A live process with no output | Hung; **no `flutter`/`dart` children** | ~12h |
| "Verified: `flutter analyze` clean" | CI uses `dart analyze --fatal-infos`; strictly stricter | A CI cycle per branch |

The corrective that worked, every single time, was **measuring the thing
itself**: `git rev-list origin/main...main`, reading the whole function, querying
the live database, running the deployed-ruleset API, listing child processes.

This gives the organising principle for everything that follows:

> **Derive, don't declare.** Where a document, comment, or cached receipt states
> a fact the system already knows, generate it from the system or delete it.

---

## 1. Were tools where they were expected?

**No, and the pattern is diagnostic.** Every repo-specific gate in this session
was discovered by *breaking it in CI*, not by looking it up:

| Tool | How it was discovered |
| --- | --- |
| `tool/design/build_feature_contracts.mjs` | CI failure on missing preview evidence |
| `tool/test/check_flutter_test_size.mjs` | CI failure on an oversized spec |
| `tool/copy/check_mobile_copy_catalog.mjs` | CI failure on unregistered ARB keys |
| `admin/scripts/generateCallableValidators.mjs` | CI failure on stale validators |
| `dart analyze --fatal-infos` as the real gate | CI failure on a custom lint |

**Scale:** `tool/` holds **29 directories and 477 scripts**, with **753 check
entries** in `tool/tools_manifest.json`. That is not navigable by memory, and
nothing in the workflow surfaces "which of these apply to my change" as a
runnable answer.

`node tool/harness.mjs plan` and `node tool/run.mjs affected-tools` both exist
and both correctly identify the affected surface. **But they emit *identifiers*,
not *commands*.** The plan returns `ciTargets`, `checkIds`, `codegenIds`,
`buildTargets`; turning those into an actual verification run is a manual
translation step performed from memory — which is precisely where every missed
gate in this session lived.

**This is the single highest-leverage gap in the stack.**

---

## 2. Were they named sensibly?

Several names actively mispredict behaviour, and two of them cost real time.

### `tool/check_catch_ui_lints.sh` — the worst offender

The name, and `TESTS.md` §"Catch UI enforcement" ("Catch lint verification must
run from the repository root through the checked wrappers"), both read as: *this
is how you check your code against the Catch UI lints.*

It is not. Reading the source: it `mkdir`s `tool/catch_ui_lints_probe/`, seeds
**deliberately-violating fixture code**, and asserts that the lint rules *fire on
the probes*. It is an anti-vacuity meta-test of the linter. **It never analyses
`lib/`.**

Observed consequence: on PR #259 the agent ran it, it passed, and CI then failed
on `CATCH_NO_WIDGET_RETURNING_METHOD` in `lib/event_success/presentation/event_success_host_screen.dart:861`.
The documented verification wrapper passed while the thing it appears to verify
was broken.

It also **leaves probe fixtures behind when a run dies abruptly**. It does clean
up on EXIT/HUP/INT/TERM, but a `SIGKILL` — how the hung agent run in this
session was ended — bypasses every trap, stranding deliberately-violating Dart
files inside the tree. A later `dart analyze` then reports this script's own
fixtures as findings in your code. This cost analyzer re-runs on three separate
branches and had to be worked around with `rm -rf` in every agent prompt.

**Fixed (2026-08-16):** the script now sweeps stale `run.*` directories at
startup, which covers the crash case a trap structurally cannot, and the path is
gitignored. `TESTS.md` now states plainly that this script never analyses `lib/`
and points to `node tool/ci/check_flutter_workspace_analysis.mjs` — the gate CI
actually runs — for code compliance. The name remains misleading; renaming it to
`verify_catch_ui_lint_rules.sh` is still worth doing.

### Others

- **`worktree_guard finish`** does not finish. It refuses when the branch has no
  upstream, with no supported alternative, so a stale blanket claim on `lib/hosts`
  blocked every host task for days and was routed around twice in one session.
  (Tranche B added `--abandon`; the naming problem remains.)
- **`migrate_clubs_to_organizers.mjs`** never deletes anything — it is additive
  by design. "Migrate" implies completion; `copy_clubs_to_organizers` would be
  honest, and would make the still-pending `freeze_legacy_writes` / `retire_legacy`
  phases obvious.
- **`context_pack.mjs`** printed correct output and then exited 1, repo-wide.
  Printing success then failing trains readers to ignore exit codes on repo
  tooling — which is exactly the habit that made `codex exec`'s "failed turn
  exits 0" dangerous.

---

## 3. Did they serve a real purpose?

**Emphatically yes, for a specific class.** Three governance systems caught real
defects in this session that no conventional gate would have:

| System | What it caught |
| --- | --- |
| Feature-contract evidence | Widgetbook previews orphaned by a refactor — invisible to analyzer and tests |
| Catch UI lint plugin | A private Widget-returning helper; enforces a real architectural rule |
| Flutter test-size ratchet | **Duplicated coverage** — the same lifecycle behaviour asserted twice, once in a 1647-line file already flagged as oversized. Both versions passed all tests |

The size ratchet finding is the most interesting: it detected *redundancy*, which
tests structurally cannot. That is a genuinely good gate.

The data-contract check, rules emulator suite, and schema-contract generation all
did their jobs and blocked genuine drift.

**Lower value observed:** `worktree_guard` (bypassed twice, blocked legitimate
work, protects against a scenario — concurrent edits to the same paths — that did
not occur), and `context_pack.mjs` (broken repo-wide, and when working provided
routing information also available from `AGENTS.md`).

---

## 4. Did they cost more than they returned?

Costs were **almost never in the checks themselves** — they were in the *distance
between the check and its discoverability*.

| Cost | Hours (approx) | Cause |
| --- | --- | --- |
| Rules-deployment drift diagnosis | ~4 | No check compared deployed rules to repo (now fixed) |
| Emulator `--project` omission | ~1 | Documented command was wrong |
| Probe-directory contamination | ~0.5 | Tool leaves debris |
| Gate discovery via CI failures | ~1.5 | No derived gate list |
| Hung agent unnoticed | ~12 | Monitoring watched the wrong signal |

The checks are not the problem. **The problem is that knowing which to run, and
what they actually do, is tribal knowledge encoded in prose.**

---

## 5. Simplification and consolidation

Ranked by expected reduction in future error:

1. **One verification entry point.** `node tool/run.mjs verify --base <ref>`
   that resolves the affected surface and *executes* the gates, printing what it
   ran. Replaces every hand-curated gate list in every prompt and doc. Prompts
   currently repeat a 6-line gate block that was wrong twice.
2. **Collapse the three analyzer stories into one.** Today: `flutter analyze`
   (misses the plugin), `dart analyze lib` (misses the plugin per TESTS.md),
   `dart analyze --fatal-infos` (what CI uses), plus a wrapper that tests the
   rules rather than the code. Publish exactly one command as the compliance
   gate.
3. **Make every tool clean up after itself.** `trap`-based cleanup in
   `check_catch_ui_lints.sh`; no tool should leave state that changes another
   tool's result.
4. **Retire `context_pack.mjs` or make it authoritative.** It duplicates
   `AGENTS.md` routing. If it stays, generate `AGENTS.md`'s routing table *from*
   it so the two cannot disagree.

---

## 6. What was out of date

- `docs/data_contracts.md:292`, `docs/release_operations.md:1066` — emulator
  command missing `--project demo-catch-rules` (**fixed** in #259).
- `AGENTS.md` step 3 — instructed every agent to run a repo-wide-broken tool
  (**fixed** in #257).
- `contracts/migrations/clubs_to_organizers.json` — receipt claimed completion;
  reality had 7 outstanding writes and 5 blockers (**data now migrated**; the
  receipt remains hand-recorded and will drift again).
- `TESTS.md` §"Catch UI enforcement" — describes the probe harness as the
  verification path for code compliance. **Still wrong.**
- `docs/plans/host_customers_and_messaging_restructure_spec.md` — cited
  `audience.readPii` (never implemented) and a sort control the callable cannot
  express. Both corrected in-place during the session.

---

## 7. Generation over hand-maintenance — the systematic fix

This is the answer to *"is it possible for certain statements to be generated
instead of hand maintained so that drift can be systematically eliminated?"*

**Yes, and each one below corresponds to a specific failure above.**

| Hand-maintained today | Derive from | Drift it caused |
| --- | --- | --- |
| Gate commands in `TESTS.md`, `AGENTS.md`, every agent prompt | `tools_manifest.json` + affected-surface resolution | Missed feature-contract, size-ratchet, copy-catalog, validator gates |
| `--project demo-catch-rules` retyped in docs | `firebase.json` / the rules harness's own project id | 8 spurious Storage failures, ~1h |
| `AGENTS.md` source-of-truth routing table | Tool manifest ownership metadata | Recommended a broken tool |
| Migration receipts in `contracts/migrations/*.json` | Re-running the dry-run; store *verified-at SHA + timestamp* | "Complete" migration that was not |
| Spec `file:line` references | Symbol lookup at read time | Every reference stale after one rebase |
| Spec-referenced capability names (`audience.readPii`) | Assert the symbol exists in `lib/`/`functions/` | A phase specified against nothing |
| "Known pre-existing failures" lists in prompts | Run the suite on the merge base and diff | Two agents told to ignore an already-fixed test |
| Local↔remote branch assumptions | `git rev-list --left-right origin/main...HEAD` before any deploy | **Production rules regression** |

**Three concrete generators, in value order:**

1. **`tool/run.mjs verify --base <ref>`** — resolves and *runs* the affected
   gates. Then `TESTS.md` and every prompt cite one command instead of a list,
   and the list cannot drift because it no longer exists.
2. **A deploy preflight** — refuse to deploy rules/config unless the working ref
   is an ancestor-or-equal of its remote counterpart, printing the divergence.
   This single check would have prevented the production regression outright.
3. **A spec-symbol linter** — for `docs/plans/*.md`, assert that referenced code
   symbols and capability names resolve. Cheap, and it would have caught
   `audience.readPii` before it reached an implementation prompt.

---

## 8. Agent-supervision findings

These concern how agents are driven, and are the source of the largest single
loss.

- **A failed Codex turn exits 0.** Gate on `turn.completed` in the JSONL, never
  the process exit code.
- **`codex exec --json` output is buffered.** A quiet run can make hours of
  progress with an empty stream file. Stream-tailing is not a liveness signal.
- **A hung agent is indistinguishable from a working one by process liveness
  alone.** The distinguishing signal is **child processes**: a run executing
  gates has `flutter`/`dart` children. Twelve hours were lost to reporting a
  hung run as "in the verification gates".
- **Any watch must make silence an event.** Every monitor written in this session
  failed silently at least once: a jq that counted queued checks as zero, a
  filter that matched `--reporter compact` as a gate, a completion watch that
  waited for an exit that never came. A monitor that cannot say
  `STALLED: no change for N minutes` is decoration.
- **Never hand an agent a conclusion.** A confidently-stated diagnosis in a
  prompt is the answer, not context — asking "do you agree?" afterwards does not
  recover independence. Give symptom, evidence, reproduction; ask for a diagnosis
  *reported back before implementation*.
- **Conversely: the standing instruction "if this does not survive your own
  reading of the code, stop and say so" paid for itself three times** — catching
  `audience.readPii`, the merge-evidence assumptions, and the impossible sort
  control. It is the single most valuable line in any prompt used this session.
- **Sandbox grants for a Flutter repo:** `~/.dart-tool`, `~/.dartServer`,
  `~/.pub-cache`, `<flutter-sdk>/bin/cache`, and the **main repo `.git`** (a
  linked worktree's git metadata lives there, so `git commit` is otherwise
  impossible — this masqueraded as three separate runs "ignoring" an explicit
  commit instruction).
- **Delegate on out-of-repo worktrees.** Nested worktrees under `.claude/` and
  `.codex/` broke `context_pack.mjs`; moving to `/private/tmp/catch-*` fixed it
  without touching the tool.

---

## 9. Ranked recommendations

1. **`tool/run.mjs verify --base <ref>`** — one derived, executing verification
   entry point. Collapses the largest recurring error class.
2. **Deploy preflight refusing to deploy from a ref behind its remote.** Prevents
   the one production incident that actually occurred.
3. **Fix `check_catch_ui_lints.sh`** — rename to reflect that it tests rules,
   add `trap` cleanup, and publish the real compliance command.
4. **Correct `TESTS.md` §"Catch UI enforcement"** — it currently documents a
   meta-test as a compliance gate.
5. **Standing agent-prompt clauses**, promoted into `AGENTS.md`: commit
   incrementally; stop rather than implement a diagnosis that fails your own
   reading; report pre-existing failures rather than inheriting a stale list.
6. **Regenerate migration receipts rather than recording them**, with a
   verified-at SHA.
7. **Spec-symbol linter** for `docs/plans/*.md`.
8. **Prune worktrees** (30 registered, ~7 from this session) and relocate agent
   worktrees out of the repository tree.
