#!/usr/bin/env node
import {spawnSync} from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath, pathToFileURL} from "node:url";
import {repoRoot, relativeToRepo} from "../lib/repo_paths.mjs";
import {fingerprintDecisionAnswerPacket} from
  "./lib/decision_answer_packet_fingerprint.mjs";
import {buildPendingDecisionAnswerPlan} from
  "./lib/pending_decision_answer_plan_core.mjs";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const defaultPacketPath = path.join(
  scriptDir,
  "generated",
  "organizer_pending_decision_answer_packet.json"
);

if (isMain()) {
  try {
    main();
  } catch (error) {
    console.error(error instanceof Error ? error.message : String(error));
    process.exit(64);
  }
}

export function buildPendingDecisionAnswerApplySteps(plan, {
  write = false,
} = {}) {
  const steps = [];
  for (const action of plan.plannedActions ?? []) {
    steps.push({
      actionId: action.actionId,
      answerId: action.answerId,
      label: `dry-run ${action.answerId}`,
      mode: "dry-run",
      command: normalizeNodeCommand(action.dryRunCommandParts),
      displayCommand: action.dryRunCommand,
    });
    if (write) {
      steps.push({
        actionId: action.actionId,
        answerId: action.answerId,
        label: `write ${action.answerId}`,
        mode: "write",
        command: normalizeNodeCommand(action.writeCommandParts),
        displayCommand: action.writeCommand,
      });
    }
  }
  return steps;
}

export function checkPendingDecisionAnswerApply(packet, {
  allowPartial = false,
  allowStaleSource = false,
  write = false,
} = {}) {
  const plan = buildPendingDecisionAnswerPlan(packet, {
    requireComplete: !allowPartial,
  });
  const freshness = checkReviewDraftSourceFreshness(packet, {
    allowStaleSource,
  });
  const errors = [
    ...plan.errors,
    ...freshness.errors,
  ];
  const warnings = [
    ...plan.warnings,
    ...freshness.warnings,
  ];
  const ok = errors.length === 0;
  const steps = ok ?
    buildPendingDecisionAnswerApplySteps(plan, {write}) :
    [];
  return {
    ok,
    errors,
    warnings,
    summary: {
      status: ok && steps.length > 0 ?
        write ? "ready_to_write_decisions" : "ready_to_dry_run_decisions" :
        errors.length > 0 ? "invalid" : plan.summary.status,
      plannedActions: plan.summary.plannedActions,
      pendingAnswers: plan.summary.pendingAnswers,
      applySteps: steps.length,
      write,
      allowPartial,
      sourceFreshness: freshness.status,
    },
    plan,
    steps,
  };
}

export function runPendingDecisionAnswerApply(packet, {
  allowPartial = false,
  allowStaleSource = false,
  json = false,
  runner = defaultRunner,
  write = false,
} = {}) {
  const applyPlan = checkPendingDecisionAnswerApply(packet, {
    allowPartial,
    allowStaleSource,
    write,
  });
  if (!applyPlan.ok) return {...applyPlan, results: []};

  const results = [];
  for (const step of applyPlan.steps) {
    if (!json) console.log(`==> ${step.label}: ${step.displayCommand}`);
    const result = runner(step.command, step);
    const normalized = {
      answerId: step.answerId,
      command: step.command,
      label: step.label,
      mode: step.mode,
      status: result.status ?? 1,
      stdout: result.stdout ?? "",
      stderr: result.stderr ?? "",
    };
    results.push(normalized);
    if (normalized.status !== 0) {
      return {
        ...applyPlan,
        ok: false,
        errors: [
          ...applyPlan.errors,
          `${step.label} failed with status ${normalized.status}.`,
        ],
        failedStep: step.label,
        results,
      };
    }
  }
  return {...applyPlan, results};
}

function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);
  if (args.help) {
    printHelp();
    return;
  }

  const packetPath = path.resolve(args.packet ?? defaultPacketPath);
  const packet = readJson(packetPath);
  const result = args.check ?
    checkPendingDecisionAnswerApply(packet, {
      allowPartial: args.allowPartial,
      allowStaleSource: args.allowStaleSource,
      write: args.write,
    }) :
    runPendingDecisionAnswerApply(packet, {
      allowPartial: args.allowPartial,
      allowStaleSource: args.allowStaleSource,
      json: args.json,
      write: args.write,
    });

  if (args.json) {
    console.log(JSON.stringify({
      ok: result.ok,
      errors: result.errors,
      warnings: result.warnings,
      summary: result.summary,
      failedStep: result.failedStep,
      results: result.results,
      steps: result.steps,
    }, null, 2));
  } else {
    printText({packetPath, result});
  }
  if (!result.ok) process.exit(1);
}

function parseArgs(argv) {
  const args = {
    allowPartial: false,
    allowStaleSource: false,
    check: false,
    help: false,
    json: false,
    packet: null,
    write: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--allow-partial") args.allowPartial = true;
    else if (arg === "--allow-stale-source") args.allowStaleSource = true;
    else if (arg === "--check") args.check = true;
    else if (arg === "--json") args.json = true;
    else if (arg === "--packet") args.packet = requiredValue(argv, ++index, arg);
    else if (arg === "--write") args.write = true;
    else if (arg === "--help" || arg === "-h") args.help = true;
    else throw new Error(`Unknown argument: ${arg}`);
  }
  return args;
}

function defaultRunner(command) {
  return spawnSync(command[0], command.slice(1), {
    cwd: repoRoot,
    encoding: "utf8",
    stdio: "inherit",
  });
}

function checkReviewDraftSourceFreshness(packet, {
  allowStaleSource = false,
} = {}) {
  const reviewDraft = packet?.reviewDraft;
  if (!reviewDraft) {
    return {status: "not_review_draft", errors: [], warnings: []};
  }
  if (allowStaleSource) {
    return {
      status: "not_enforced",
      errors: [],
      warnings: ["Review draft source freshness was not enforced."],
    };
  }
  const sourcePacket = reviewDraft.sourcePacket;
  const expected = reviewDraft.sourceFingerprint?.value;
  const algorithm = reviewDraft.sourceFingerprint?.algorithm;
  const errors = [];
  if (!sourcePacket) {
    errors.push("reviewDraft.sourcePacket is required for reviewed answer packets.");
  }
  if (algorithm !== "sha256" || !expected) {
    errors.push("reviewDraft.sourceFingerprint sha256 value is required.");
  }
  if (errors.length > 0) return {status: "missing_fingerprint", errors, warnings: []};

  const sourcePath = path.isAbsolute(sourcePacket) ?
    sourcePacket :
    path.join(repoRoot, sourcePacket);
  if (!fs.existsSync(sourcePath)) {
    return {
      status: "source_missing",
      errors: [`reviewDraft.sourcePacket does not exist: ${relativeToRepo(sourcePath)}`],
      warnings: [],
    };
  }
  const current = fingerprintDecisionAnswerPacket(readJson(sourcePath));
  if (current !== expected) {
    return {
      status: "stale",
      errors: [
        "reviewDraft.sourceFingerprint does not match the current generated " +
          "answer packet. Recreate the reviewed answer packet or pass " +
          "--allow-stale-source after manual verification.",
      ],
      warnings: [],
    };
  }
  return {status: "fresh", errors: [], warnings: []};
}

function normalizeNodeCommand(parts) {
  if (!Array.isArray(parts) || parts.length === 0) {
    throw new Error("Apply step command parts are missing.");
  }
  if (parts[0] === "node") return [process.execPath, ...parts.slice(1)];
  return parts;
}

function readJson(file) {
  if (!fs.existsSync(file)) {
    throw new Error(`Missing pending decision answer packet: ${relativeToRepo(file)}`);
  }
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function printText({packetPath, result}) {
  console.log(
    "Organizer pending decision answer apply: " +
      `${result.summary.status}, ${result.summary.applySteps} step(s), ` +
      `${result.summary.plannedActions} action(s), ` +
      `${result.summary.pendingAnswers} pending.`
  );
  console.log(`Source: ${relativeToRepo(packetPath)}`);
  for (const warning of result.warnings) console.log(`- ${warning}`);
  for (const error of result.errors) console.error(`- ${error}`);
}

function requiredValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) throw new Error(`${flag} requires a value.`);
  return value;
}

function printHelp() {
  console.log(`Usage: node tool/organizer_intake/apply_pending_decision_answers.mjs [options]

Validates a filled pending-decision answer packet and applies its local
decision-draft handoff. Default execution runs only the generated dry-run
commands. Passing --write runs each dry-run command first, then writes the
corresponding repo-backed decision JSON through the existing decision tools.

Options:
  --check           Validate the packet and apply steps without running commands.
  --allow-partial   Allow unanswered slots. Only answered slots produce steps.
  --allow-stale-source
                    Skip source fingerprint freshness checks for reviewed packets.
  --write           After dry-run preflight, write local decision JSON files.
  --json            Emit machine-readable output.
  --packet <path>   Packet path. Defaults to generated answer packet.
  -h, --help        Show this help.
`);
}

function isMain() {
  return process.argv[1] &&
    import.meta.url === pathToFileURL(process.argv[1]).href;
}
