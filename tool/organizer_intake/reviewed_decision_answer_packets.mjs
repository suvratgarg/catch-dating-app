#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath, pathToFileURL} from "node:url";
import {repoRoot, relativeToRepo} from "../lib/repo_paths.mjs";
import {checkPendingDecisionAnswerApply} from
  "./apply_pending_decision_answers.mjs";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const defaultRoot = path.join(scriptDir, "answer_packets");

if (isMain()) {
  try {
    main();
  } catch (error) {
    console.error(error instanceof Error ? error.message : String(error));
    process.exit(64);
  }
}

export function buildReviewedDecisionAnswerPacketRegister({
  allowStaleSource = false,
  packet = null,
  root = defaultRoot,
} = {}) {
  const packetPath = packet ? path.resolve(packet) : null;
  const files = packetPath ? [packetPath] : listPacketFiles(root);
  const answerPacketsRoot = packetPath ? path.dirname(packetPath) : root;
  const entries = files.map((file) => entryForFile({
    allowStaleSource,
    file,
  }));
  const summary = summaryFor(entries);
  return {
    schemaVersion: 1,
    generatedFrom: {
      answerPacketsRoot: relativeToRepo(answerPacketsRoot),
      generatedAnswerPacket:
        "tool/organizer_intake/generated/organizer_pending_decision_answer_packet.json",
    },
    summary,
    guardrails: [
      "This register is read-only; it never records decisions, writes Firestore, publishes pages, or applies answer packets.",
      "Ready packets must be source-fresh, complete, and pass the same dry-run/write command planning checks used by apply_pending_decision_answers.mjs.",
      "Stale reviewed packets should be recreated from the latest generated answer packet unless an operator explicitly overrides freshness after manual comparison.",
    ],
    entries,
  };
}

export function checkReviewedDecisionAnswerPacketRegister(register, {
  requireReady = false,
} = {}) {
  const errors = [];
  const warnings = [];
  if (!register || typeof register !== "object") {
    return {
      ok: false,
      errors: ["Reviewed decision answer packet register must be an object."],
      warnings,
      summary: emptySummary(),
    };
  }
  const entries = Array.isArray(register.entries) ? register.entries : [];
  const summary = register.summary ?? {};
  if (register.schemaVersion !== 1) {
    errors.push(`Expected schemaVersion 1, got ${register.schemaVersion}.`);
  }
  if (summary.packets !== entries.length) {
    errors.push(`summary.packets ${summary.packets} does not match ${entries.length}.`);
  }
  for (const field of [
    "readyToApply",
    "awaitingAnswers",
    "invalid",
    "stale",
    "sourceFresh",
  ]) {
    const actual = entries.filter((entry) => entry[field] === true).length;
    if ((summary[field] ?? 0) !== actual) {
      errors.push(`summary.${field} ${summary[field]} does not match ${actual}.`);
    }
  }
  for (const entry of entries) {
    if (entry.invalid) {
      errors.push(`${entry.path}: ${entry.errors.join("; ")}`);
    } else if (entry.stale) {
      errors.push(`${entry.path}: source fingerprint is stale.`);
    }
  }
  if (requireReady && (summary.readyToApply ?? 0) === 0) {
    errors.push("No reviewed decision answer packet is ready to apply.");
  }
  if (entries.length === 0) {
    warnings.push("No reviewed decision answer packet drafts exist.");
  } else if ((summary.awaitingAnswers ?? 0) > 0) {
    warnings.push(`${summary.awaitingAnswers} reviewed answer packet(s) still need answers.`);
  }
  return {
    ok: errors.length === 0,
    errors,
    warnings,
    summary: {
      status: summary.status ?? "unknown",
      packets: entries.length,
      readyToApply: summary.readyToApply ?? 0,
      awaitingAnswers: summary.awaitingAnswers ?? 0,
      invalid: summary.invalid ?? 0,
      stale: summary.stale ?? 0,
    },
  };
}

export function renderReviewedDecisionAnswerPacketRegisterMarkdown(register) {
  const summary = register.summary ?? {};
  const lines = [
    "# Reviewed Organizer Decision Answer Packets",
    "",
    `Status: ${summary.status ?? "unknown"}; ` +
      `${summary.packets ?? 0} packet(s); ` +
      `${summary.readyToApply ?? 0} ready to apply; ` +
      `${summary.awaitingAnswers ?? 0} awaiting answers.`,
    "",
  ];
  if ((register.entries ?? []).length === 0) {
    lines.push("No reviewed answer packets exist yet.", "");
  }
  for (const entry of register.entries ?? []) {
    lines.push(
      `## ${entry.path}`,
      "",
      `Status: ${entry.status}`,
      `Reviewer: ${entry.reviewer ?? "unknown"}`,
      `Decided at: ${entry.decidedAt ?? "unknown"}`,
      `Source freshness: ${entry.sourceFreshness}`,
      `Planned actions: ${entry.plannedActions}`,
      `Pending answers: ${entry.pendingAnswers}`,
      ""
    );
    for (const error of entry.errors ?? []) lines.push(`- Error: ${error}`);
    for (const warning of entry.warnings ?? []) lines.push(`- Warning: ${warning}`);
    if ((entry.errors ?? []).length > 0 || (entry.warnings ?? []).length > 0) {
      lines.push("");
    }
  }
  return `${lines.join("\n")}\n`;
}

function entryForFile({allowStaleSource, file}) {
  const relativePath = relativeToRepo(file);
  try {
    const packet = JSON.parse(fs.readFileSync(file, "utf8"));
    const partial = checkPendingDecisionAnswerApply(packet, {
      allowPartial: true,
      allowStaleSource,
      write: false,
    });
    const complete = partial.ok ?
      checkPendingDecisionAnswerApply(packet, {
        allowPartial: false,
        allowStaleSource,
        write: false,
      }) :
      null;
    const pendingAnswers = partial.summary?.pendingAnswers ?? 0;
    const plannedActions = partial.summary?.plannedActions ?? 0;
    const readyToApply = Boolean(complete?.ok && plannedActions > 0);
    const sourceFreshness = partial.summary?.sourceFreshness ?? "unknown";
    const invalid = !partial.ok;
    const stale = sourceFreshness === "stale" ||
      sourceFreshness === "source_missing" ||
      sourceFreshness === "missing_fingerprint";
    return {
      path: relativePath,
      reviewer: packet.answerTemplate?.reviewer ?? packet.reviewDraft?.reviewer ?? null,
      decidedAt: packet.answerTemplate?.decidedAt ?? null,
      reviewDraft: packet.reviewDraft ?? null,
      status: invalid ?
        "invalid" :
        readyToApply ?
          "ready_to_apply" :
          pendingAnswers > 0 ?
            "awaiting_answers" :
            "no_planned_actions",
      answerSlots: Array.isArray(packet.answerSlots) ? packet.answerSlots.length : 0,
      plannedActions,
      pendingAnswers,
      readyToApply,
      awaitingAnswers: !invalid && pendingAnswers > 0,
      invalid,
      stale,
      sourceFresh: sourceFreshness === "fresh",
      sourceFreshness,
      errors: [
        ...partial.errors,
        ...(complete?.errors ?? []).filter((error) =>
          !error.endsWith("answer(s) are still pending."))
      ],
      warnings: [
        ...partial.warnings,
        ...(complete?.warnings ?? []),
      ],
    };
  } catch (error) {
    return {
      path: relativePath,
      reviewer: null,
      decidedAt: null,
      reviewDraft: null,
      status: "invalid",
      answerSlots: 0,
      plannedActions: 0,
      pendingAnswers: 0,
      readyToApply: false,
      awaitingAnswers: false,
      invalid: true,
      stale: false,
      sourceFresh: false,
      sourceFreshness: "unknown",
      errors: [error instanceof Error ? error.message : String(error)],
      warnings: [],
    };
  }
}

function listPacketFiles(root) {
  if (!fs.existsSync(root)) return [];
  return fs
    .readdirSync(root)
    .filter((file) => file.endsWith(".json"))
    .sort()
    .map((file) => path.join(root, file));
}

function summaryFor(entries) {
  const readyToApply = entries.filter((entry) => entry.readyToApply).length;
  const awaitingAnswers = entries.filter((entry) => entry.awaitingAnswers).length;
  const invalid = entries.filter((entry) => entry.invalid).length;
  const stale = entries.filter((entry) => entry.stale).length;
  const sourceFresh = entries.filter((entry) => entry.sourceFresh).length;
  return {
    status: entries.length === 0 ?
      "no_reviewed_packets" :
      invalid > 0 || stale > 0 ?
        "invalid_packets" :
        readyToApply > 0 ?
          "ready_to_apply" :
          "awaiting_answers",
    packets: entries.length,
    readyToApply,
    awaitingAnswers,
    invalid,
    stale,
    sourceFresh,
  };
}

function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);
  if (args.help) {
    printHelp();
    return;
  }
  const register = buildReviewedDecisionAnswerPacketRegister({
    allowStaleSource: args.allowStaleSource,
    root: path.resolve(args.root),
    packet: args.packet ? path.resolve(args.packet) : null,
  });
  const result = checkReviewedDecisionAnswerPacketRegister(register, {
    requireReady: args.requireReady,
  });
  if (args.check && !result.ok) {
    printErrors(result);
    process.exit(1);
  }
  if (args.format === "json") {
    console.log(JSON.stringify(args.check ? result : register, null, 2));
  } else if (args.format === "markdown") {
    console.log(renderReviewedDecisionAnswerPacketRegisterMarkdown(register));
  } else {
    printText({register, result});
  }
  if (!result.ok) process.exit(1);
}

function parseArgs(argv) {
  const args = {
    allowStaleSource: false,
    check: false,
    format: "text",
    help: false,
    requireReady: false,
    root: defaultRoot,
    packet: null,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--allow-stale-source") args.allowStaleSource = true;
    else if (arg === "--check") args.check = true;
    else if (arg === "--format") args.format = requiredValue(argv, ++index, arg);
    else if (arg === "--require-ready") args.requireReady = true;
    else if (arg === "--root") args.root = requiredValue(argv, ++index, arg);
    else if (arg === "--packet") args.packet = requiredValue(argv, ++index, arg);
    else if (arg === "--help" || arg === "-h") args.help = true;
    else throw new Error(`Unknown argument: ${arg}`);
  }
  if (!["json", "markdown", "text"].includes(args.format)) {
    throw new Error("--format must be json, markdown, or text.");
  }
  return args;
}

function printText({register, result}) {
  const summary = register.summary ?? {};
  console.log(
    "Reviewed organizer decision answer packets: " +
      `${summary.status}, ${summary.packets} packet(s), ` +
      `${summary.readyToApply} ready, ${summary.awaitingAnswers} awaiting answers.`
  );
  console.log(`Root: ${register.generatedFrom?.answerPacketsRoot ?? "unknown"}`);
  for (const warning of result.warnings) console.log(`- ${warning}`);
}

function printErrors(result) {
  console.error("Reviewed decision answer packet check failed:");
  for (const error of result.errors) console.error(`- ${error}`);
}

function requiredValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) throw new Error(`${flag} requires a value.`);
  return value;
}

function emptySummary() {
  return {
    status: "invalid",
    packets: 0,
    readyToApply: 0,
    awaitingAnswers: 0,
    invalid: 0,
    stale: 0,
  };
}

function printHelp() {
  console.log(`Usage: node tool/organizer_intake/reviewed_decision_answer_packets.mjs [options]

Scans reviewed organizer decision answer packets and reports whether any are
fresh, complete, and ready for the guarded apply step.

Options:
  --check              Validate the register.
  --require-ready      Fail unless at least one packet is ready to apply.
  --allow-stale-source Allow stale-source reviewed packets.
  --format <format>    text, markdown, or json.
  --root <path>        Answer packet root. Default: ${relativeToRepo(defaultRoot)}
  --packet <path>      Check one reviewed answer packet instead of scanning root.
  -h, --help           Show this help.
`);
}

function isMain() {
  return process.argv[1] &&
    import.meta.url === pathToFileURL(process.argv[1]).href;
}
