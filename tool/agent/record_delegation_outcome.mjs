#!/usr/bin/env node
import fs from "node:fs";
import {spawnSync} from "node:child_process";
import {fromRepo} from "../lib/repo_paths.mjs";

const args = parseArgs(process.argv.slice(2));

if (args.help) {
  printHelp();
  process.exit(0);
}

const required = ["taskId", "mode", "status", "parentReviewOutcome"];
for (const key of required) {
  if (!args[key]) {
    console.error(`Missing required argument: --${toFlagName(key)}`);
    printHelp();
    process.exit(64);
  }
}

const entry = {
  timestamp: new Date().toISOString(),
  event: "agent_delegation_outcome",
  task_id: args.taskId,
  mode: args.mode,
  status: args.status,
  parent_review_outcome: args.parentReviewOutcome,
  parent_branch: args.parentBranch ?? git(["branch", "--show-current"]),
  parent_head_sha: args.parentHeadSha ?? git(["rev-parse", "HEAD"]),
  parent_dirty_count: countDirtyFiles(),
  base_sha: args.baseSha ?? null,
  subagent_branch: args.subagentBranch ?? null,
  subagent_commit: args.subagentCommit ?? null,
  elapsed_minutes: numberOrNull(args.elapsedMinutes),
  files_changed: list(args.filesChanged),
  checks_run: list(args.checksRun),
  checks_failed: list(args.checksFailed),
  conflicts_count: numberOrZero(args.conflictsCount),
  parent_edits_required: numberOrZero(args.parentEditsRequired),
  notes: args.notes ?? null,
};

if (args.dryRun) {
  console.log(JSON.stringify(entry, null, 2));
} else {
  fs.appendFileSync(
    fromRepo("docs/audit_registry/agent_metrics.jsonl"),
    `${JSON.stringify(entry)}\n`,
  );
  console.log(`Recorded delegation outcome: ${entry.task_id}`);
}

function parseArgs(argv) {
  const parsed = {
    dryRun: false,
    help: false,
  };
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--dry-run") parsed.dryRun = true;
    else if (arg === "--task-id") parsed.taskId = requireValue(argv, ++i, arg);
    else if (arg === "--mode") parsed.mode = requireValue(argv, ++i, arg);
    else if (arg === "--status") parsed.status = requireValue(argv, ++i, arg);
    else if (arg === "--parent-review-outcome") parsed.parentReviewOutcome = requireValue(argv, ++i, arg);
    else if (arg === "--parent-branch") parsed.parentBranch = requireValue(argv, ++i, arg);
    else if (arg === "--parent-head-sha") parsed.parentHeadSha = requireValue(argv, ++i, arg);
    else if (arg === "--base-sha") parsed.baseSha = requireValue(argv, ++i, arg);
    else if (arg === "--subagent-branch") parsed.subagentBranch = requireValue(argv, ++i, arg);
    else if (arg === "--subagent-commit") parsed.subagentCommit = requireValue(argv, ++i, arg);
    else if (arg === "--elapsed-minutes") parsed.elapsedMinutes = requireValue(argv, ++i, arg);
    else if (arg === "--files-changed") parsed.filesChanged = requireValue(argv, ++i, arg);
    else if (arg === "--checks-run") parsed.checksRun = requireValue(argv, ++i, arg);
    else if (arg === "--checks-failed") parsed.checksFailed = requireValue(argv, ++i, arg);
    else if (arg === "--conflicts-count") parsed.conflictsCount = requireValue(argv, ++i, arg);
    else if (arg === "--parent-edits-required") parsed.parentEditsRequired = requireValue(argv, ++i, arg);
    else if (arg === "--notes") parsed.notes = requireValue(argv, ++i, arg);
    else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }
  return parsed;
}

function requireValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) throw new Error(`${flag} requires a value.`);
  return value;
}

function git(args) {
  const result = spawnSync("git", args, {
    cwd: fromRepo("."),
    encoding: "utf8",
  });
  if (result.status !== 0) return null;
  return result.stdout.trim() || null;
}

function countDirtyFiles() {
  const output = git(["status", "--short"]);
  if (!output) return 0;
  return output.split(/\r?\n/).filter(Boolean).length;
}

function list(value) {
  if (!value) return [];
  return String(value)
    .split(",")
    .map((item) => item.trim())
    .filter(Boolean);
}

function numberOrNull(value) {
  if (value === undefined || value === null || value === "") return null;
  const parsed = Number(value);
  if (!Number.isFinite(parsed)) throw new Error(`Expected a number, got ${value}.`);
  return parsed;
}

function numberOrZero(value) {
  return numberOrNull(value) ?? 0;
}

function toFlagName(key) {
  return key.replace(/[A-Z]/g, (match) => `-${match.toLowerCase()}`);
}

function printHelp() {
  console.log(`Usage: node tool/agent/record_delegation_outcome.mjs --task-id <id> --mode <mode> --status <status> --parent-review-outcome <outcome> [options]

Records a parent-reviewed subagent/worktree delegation outcome in
docs/audit_registry/agent_metrics.jsonl.

Common modes:
  explorer-readonly, worker-patch, verifier, protocol-adoption

Common statuses:
  integrated, accepted-info-only, rejected, blocked, superseded

Common parent review outcomes:
  accepted, accepted-with-edits, rejected, informational, pending

Options:
  --base-sha sha
  --subagent-branch branch
  --subagent-commit sha
  --elapsed-minutes number
  --files-changed path[,path...]
  --checks-run command[,command...]
  --checks-failed command[,command...]
  --conflicts-count number
  --parent-edits-required number
  --notes text
  --dry-run
`);
}
