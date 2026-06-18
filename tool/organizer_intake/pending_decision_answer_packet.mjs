#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath, pathToFileURL} from "node:url";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const defaultPacketPath = path.join(
  scriptDir,
  "generated",
  "organizer_pending_decision_answer_packet.json"
);

if (isMain()) {
  main();
}

export function checkOrganizerPendingDecisionAnswerPacket(packet) {
  const errors = [];
  const warnings = [];
  if (!packet || typeof packet !== "object") {
    return {
      ok: false,
      errors: ["Pending decision answer packet must be an object."],
      warnings,
      summary: emptySummary(),
    };
  }

  const answerSlots = Array.isArray(packet.answerSlots) ?
    packet.answerSlots :
    [];
  const answers = Array.isArray(packet.answerTemplate?.answers) ?
    packet.answerTemplate.answers :
    [];
  const followUps = Array.isArray(packet.followUps) ? packet.followUps : [];
  const summary = packet.summary ?? {};

  if (packet.schemaVersion !== 1) {
    errors.push(`Expected schemaVersion 1, got ${packet.schemaVersion}.`);
  }
  if (!Array.isArray(packet.answerSlots)) {
    errors.push("answerSlots must be an array.");
  }
  if (!Array.isArray(packet.answerTemplate?.answers)) {
    errors.push("answerTemplate.answers must be an array.");
  }
  if (summary.answerSlots !== answerSlots.length) {
    errors.push(
      `summary.answerSlots ${summary.answerSlots} does not match ` +
        `${answerSlots.length}.`
    );
  }
  if (answers.length !== answerSlots.length) {
    errors.push(
      `answerTemplate.answers length ${answers.length} does not match ` +
        `${answerSlots.length}.`
    );
  }

  const publication = answerSlots.filter((slot) =>
    slot.requestType === "admin_publication_decision");
  const policy = answerSlots.filter((slot) =>
    slot.requestType === "policy_decision");
  if (summary.adminPublicationDecisions !== publication.length) {
    errors.push(
      `summary.adminPublicationDecisions ` +
        `${summary.adminPublicationDecisions} does not match ` +
        `${publication.length}.`
    );
  }
  if (summary.policyDecisions !== policy.length) {
    errors.push(
      `summary.policyDecisions ${summary.policyDecisions} does not match ` +
        `${policy.length}.`
    );
  }
  const requiredQuestions = answerSlots.reduce((total, slot) =>
    total + (slot.requiredInputs ?? []).length, 0);
  if (summary.requiredPolicyQuestions !== requiredQuestions) {
    errors.push(
      `summary.requiredPolicyQuestions ${summary.requiredPolicyQuestions} ` +
        `does not match ${requiredQuestions}.`
    );
  }
  const safeDefaults = answerSlots.filter((slot) =>
    slot.safeDefaultDecision).length;
  if (summary.safeDefaultDecisions !== safeDefaults) {
    errors.push(
      `summary.safeDefaultDecisions ${summary.safeDefaultDecisions} ` +
        `does not match ${safeDefaults}.`
    );
  }
  if (summary.workflowFollowUps !== followUps.length) {
    errors.push(
      `summary.workflowFollowUps ${summary.workflowFollowUps} does not ` +
        `match ${followUps.length}.`
    );
  }

  const answerIds = new Set();
  for (const slot of answerSlots) {
    validateAnswerSlot(slot, errors);
    if (answerIds.has(slot.answerId)) {
      errors.push(`${slot.answerId}: duplicate answerId.`);
    }
    answerIds.add(slot.answerId);
  }
  for (const answer of answers) validateTemplateAnswer({
    answer,
    answerIds,
    errors,
  });
  if (answerSlots.length > 0) {
    warnings.push(`${answerSlots.length} decision answer slot(s) pending.`);
  }

  return {
    ok: errors.length === 0,
    errors,
    warnings,
    summary: {
      status: summary.status ?? "unknown",
      answerSlots: answerSlots.length,
      adminPublicationDecisions: publication.length,
      policyDecisions: policy.length,
      requiredPolicyQuestions: requiredQuestions,
      safeDefaultDecisions: safeDefaults,
      workflowFollowUps: followUps.length,
      untriagedWorkstreams: summary.untriagedWorkstreams ?? 0,
    },
  };
}

export function renderPendingDecisionAnswerPacketMarkdown(packet) {
  const lines = [
    "# Organizer Pending Decision Answers",
    "",
    `Status: ${packet.summary?.status ?? "unknown"}; ` +
      `${packet.summary?.answerSlots ?? 0} answer slot(s); ` +
      `${packet.summary?.requiredPolicyQuestions ?? 0} required policy question(s).`,
    "",
  ];
  for (const slot of packet.answerSlots ?? []) {
    lines.push(
      `## ${slot.subjectName}`,
      "",
      slot.prompt,
      "",
      `Answer id: \`${slot.answerId}\``,
      `Owner: ${slot.owner}`,
      `Options: ${(slot.decisionOptions ?? []).join(", ")}`,
      `Safe default decision: ${slot.safeDefaultDecision ?? "none"}`,
      `Blocking workstreams: ${(slot.blockingWorkstreams ?? []).join(", ") || "none"}`,
      ""
    );
    if ((slot.requiredAcknowledgements ?? []).length > 0) {
      lines.push(
        `Acknowledgements: ${slot.requiredAcknowledgements.join(", ")}`,
        ""
      );
    }
    for (const input of slot.requiredInputs ?? []) {
      lines.push(
        `- ${input.prompt} Default: ${input.recommendedSafeDefault}.`
      );
    }
    if ((slot.requiredInputs ?? []).length > 0) lines.push("");
    if (slot.dryRunCommands?.[0]) {
      lines.push(`Dry run: \`${slot.dryRunCommands[0]}\``, "");
    }
  }
  if ((packet.answerSlots ?? []).length === 0) {
    lines.push("No decision answers are pending.", "");
  }
  return `${lines.join("\n")}\n`;
}

function validateAnswerSlot(slot, errors) {
  for (const field of [
    "answerId",
    "requestType",
    "priority",
    "owner",
    "subjectId",
    "subjectName",
    "prompt",
  ]) {
    if (!slot[field]) errors.push(`${slot.answerId ?? "slot"} missing ${field}.`);
  }
  if (!Array.isArray(slot.decisionOptions) || slot.decisionOptions.length === 0) {
    errors.push(`${slot.answerId}: decisionOptions must be a non-empty array.`);
  }
  if (
    slot.safeDefaultDecision &&
    !slot.decisionOptions?.includes(slot.safeDefaultDecision)
  ) {
    errors.push(`${slot.answerId}: safeDefaultDecision is not allowed.`);
  }
  if (!Array.isArray(slot.requiredAcknowledgements)) {
    errors.push(`${slot.answerId}: requiredAcknowledgements must be an array.`);
  }
  if (!Array.isArray(slot.requiredInputs)) {
    errors.push(`${slot.answerId}: requiredInputs must be an array.`);
  }
  if (!Array.isArray(slot.blockingWorkstreams)) {
    errors.push(`${slot.answerId}: blockingWorkstreams must be an array.`);
  }
  if (!Array.isArray(slot.dryRunCommands)) {
    errors.push(`${slot.answerId}: dryRunCommands must be an array.`);
  }
}

function validateTemplateAnswer({answer, answerIds, errors}) {
  if (!answer || typeof answer !== "object") {
    errors.push("answerTemplate contains a non-object answer.");
    return;
  }
  if (!answerIds.has(answer.answerId)) {
    errors.push(`${answer.answerId ?? "answer"}: unknown answerId.`);
  }
  if (answer.decision !== null) {
    errors.push(`${answer.answerId}: decision must remain null in template.`);
  }
  if (typeof answer.note !== "string") {
    errors.push(`${answer.answerId}: note must be a string.`);
  }
  if (!Array.isArray(answer.requiredInputsReviewed)) {
    errors.push(`${answer.answerId}: requiredInputsReviewed must be an array.`);
  }
  if (!answer.acknowledgements || typeof answer.acknowledgements !== "object") {
    errors.push(`${answer.answerId}: acknowledgements must be an object.`);
  }
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    printHelp();
    process.exit(0);
  }

  const packetPath = path.resolve(args.packet ?? defaultPacketPath);
  const packet = readJson(packetPath);
  const result = checkOrganizerPendingDecisionAnswerPacket(packet);
  if (args.requireAnswered && result.summary.answerSlots > 0) {
    result.errors.push(
      `${result.summary.answerSlots} decision answer slot(s) remain pending.`
    );
    result.ok = false;
  }
  if (args.check && !result.ok) {
    printErrors(result);
    process.exit(1);
  }

  if (args.format === "json") {
    console.log(JSON.stringify(args.check ? result : packet, null, 2));
  } else if (args.format === "markdown") {
    console.log(renderPendingDecisionAnswerPacketMarkdown(packet));
  } else {
    printText({packetPath, result});
  }
  if (!result.ok) process.exit(1);
}

function parseArgs(argv) {
  const args = {
    check: false,
    format: "text",
    help: false,
    packet: null,
    requireAnswered: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--check") args.check = true;
    else if (arg === "--require-answered") args.requireAnswered = true;
    else if (arg === "--format") {
      args.format = requiredValue(argv, ++index, arg);
    } else if (arg === "--packet") {
      args.packet = requiredValue(argv, ++index, arg);
    } else if (arg === "--help" || arg === "-h") {
      args.help = true;
    } else {
      fail(`Unknown argument: ${arg}`);
    }
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

function printText({packetPath, result}) {
  console.log(
    "Organizer pending decision answers: " +
      `${result.summary.answerSlots} slot(s), ` +
      `${result.summary.requiredPolicyQuestions} policy question(s), ` +
      `${result.summary.safeDefaultDecisions} safe default(s), ` +
      `status ${result.summary.status}.`
  );
  console.log(`Source: ${relative(packetPath)}`);
  for (const warning of result.warnings) console.log(`- ${warning}`);
}

function printErrors(result) {
  console.error("Organizer pending decision answer packet check failed:");
  for (const error of result.errors) console.error(`- ${error}`);
}

function emptySummary() {
  return {
    adminPublicationDecisions: 0,
    answerSlots: 0,
    policyDecisions: 0,
    requiredPolicyQuestions: 0,
    safeDefaultDecisions: 0,
    status: "invalid",
    untriagedWorkstreams: 0,
    workflowFollowUps: 0,
  };
}

function requiredValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) {
    fail(`${flag} requires a value`);
  }
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
  console.log(`Usage: node tool/organizer_intake/pending_decision_answer_packet.mjs [options]

Validates and renders the read-only answer packet for pending organizer
publication and product policy decisions.

Options:
  --check             Validate the generated packet.
  --require-answered  Future gate: fail while answer slots remain pending.
  --format <format>   text, markdown, or json.
  --packet <path>     Packet path. Defaults to generated answer packet.
  -h, --help          Show this help.
`);
}

function isMain() {
  return process.argv[1] &&
    import.meta.url === pathToFileURL(process.argv[1]).href;
}
