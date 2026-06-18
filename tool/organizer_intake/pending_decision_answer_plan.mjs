#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath, pathToFileURL} from "node:url";
import {buildPendingDecisionAnswerPlan} from
  "./lib/pending_decision_answer_plan_core.mjs";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const defaultPacketPath = path.join(
  scriptDir,
  "generated",
  "organizer_pending_decision_answer_packet.json"
);

if (isMain()) {
  main();
}

export function checkPendingDecisionAnswerPlan(packet, options = {}) {
  return buildPendingDecisionAnswerPlan(packet, options);
}

export function renderPendingDecisionAnswerPlanMarkdown(plan) {
  const lines = [
    "# Organizer Pending Decision Answer Plan",
    "",
    `Status: ${plan.summary.status}; ` +
      `${plan.summary.plannedActions} planned action(s); ` +
      `${plan.summary.pendingAnswers} pending answer(s).`,
    "",
  ];
  if (plan.plannedActions.length === 0) {
    lines.push("No decision draft commands are ready yet.", "");
  }
  for (const action of plan.plannedActions) {
    lines.push(
      `## ${action.subjectName}`,
      "",
      `Answer id: \`${action.answerId}\``,
      `Decision: ${action.decision}`,
      `Dry run: \`${action.dryRunCommand}\``,
      `Write: \`${action.writeCommand}\``,
      ""
    );
  }
  if (plan.pendingAnswers.length > 0) {
    lines.push("## Pending Answers", "");
    for (const answerId of plan.pendingAnswers) {
      lines.push(`- ${answerId}`);
    }
    lines.push("");
  }
  return `${lines.join("\n")}\n`;
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    printHelp();
    process.exit(0);
  }

  const packetPath = path.resolve(args.packet ?? defaultPacketPath);
  const packet = readJson(packetPath);
  const plan = buildPendingDecisionAnswerPlan(packet, {
    requireComplete: args.requireComplete,
  });
  if (args.check && !plan.ok) {
    printErrors(plan);
    process.exit(1);
  }
  if (args.format === "json") {
    console.log(JSON.stringify(plan, null, 2));
  } else if (args.format === "markdown") {
    console.log(renderPendingDecisionAnswerPlanMarkdown(plan));
  } else {
    printText({packetPath, plan});
  }
  if (!plan.ok) process.exit(1);
}

function parseArgs(argv) {
  const args = {
    check: false,
    format: "text",
    help: false,
    packet: null,
    requireComplete: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--check") args.check = true;
    else if (arg === "--require-complete") args.requireComplete = true;
    else if (arg === "--format") args.format = requiredValue(argv, ++index, arg);
    else if (arg === "--packet") args.packet = requiredValue(argv, ++index, arg);
    else if (arg === "--help" || arg === "-h") args.help = true;
    else fail(`Unknown argument: ${arg}`);
  }
  if (!["json", "markdown", "text"].includes(args.format)) {
    fail("--format must be json, markdown, or text");
  }
  return args;
}

function readJson(file) {
  if (!fs.existsSync(file)) {
    fail(`Missing pending decision answer packet: ${relative(file)}`);
  }
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function printText({packetPath, plan}) {
  console.log(
    "Organizer pending decision answer plan: " +
      `${plan.summary.status}, ${plan.summary.plannedActions} action(s), ` +
      `${plan.summary.pendingAnswers} pending.`
  );
  console.log(`Source: ${relative(packetPath)}`);
  for (const warning of plan.warnings) console.log(`- ${warning}`);
}

function printErrors(plan) {
  console.error("Organizer pending decision answer plan check failed:");
  for (const error of plan.errors) console.error(`- ${error}`);
}

function requiredValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) fail(`${flag} requires a value`);
  return value;
}

function relative(file) {
  return path.relative(path.resolve(scriptDir, "..", ".."), file);
}

function fail(message) {
  console.error(message);
  process.exit(64);
}

function printHelp() {
  console.log(`Usage: node tool/organizer_intake/pending_decision_answer_plan.mjs [options]

Validates a filled pending-decision answer packet and renders the local decision
draft commands needed to turn reviewed answers into repo-backed decisions.

The generated packet is allowed to be incomplete. Add --require-complete when
checking a copied packet that should be ready to draft decisions.

Options:
  --check              Validate the packet/answers.
  --require-complete   Fail while any answer remains null.
  --format <format>    text, markdown, or json.
  --packet <path>      Packet path. Defaults to generated answer packet.
  -h, --help           Show this help.
`);
}

function isMain() {
  return process.argv[1] &&
    import.meta.url === pathToFileURL(process.argv[1]).href;
}
