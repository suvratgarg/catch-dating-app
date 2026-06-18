#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath, pathToFileURL} from "node:url";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const defaultPacketPath = path.join(
  scriptDir,
  "generated",
  "organizer_promotion_execution_packet.json"
);

if (isMain()) {
  main();
}

export function checkOrganizerPromotionExecutionPacket(packet) {
  const errors = [];
  const warnings = [];
  if (!packet || typeof packet !== "object") {
    return {
      ok: false,
      errors: ["Promotion execution packet must be an object."],
      warnings,
      summary: emptySummary(),
    };
  }

  const phases = Array.isArray(packet.phases) ? packet.phases : [];
  const summary = packet.summary ?? {};
  if (packet.schemaVersion !== 1) {
    errors.push(`Expected schemaVersion 1, got ${packet.schemaVersion}.`);
  }
  if (!Array.isArray(packet.phases)) {
    errors.push("phases must be an array.");
  }
  if (!Array.isArray(packet.guardrails) || packet.guardrails.length === 0) {
    errors.push("guardrails must be a non-empty array.");
  }
  if (summary.phases !== phases.length) {
    errors.push(`summary.phases ${summary.phases} does not match ${phases.length}.`);
  }

  const phasesByStatus = countBy(phases, "status");
  if (!sameRecord(summary.phasesByStatus ?? {}, phasesByStatus)) {
    errors.push("summary.phasesByStatus does not match phase statuses.");
  }
  const blockedPhases = phases.filter((phase) =>
    phase.status?.startsWith("blocked") ||
      phase.status?.startsWith("waiting") ||
      phase.status?.startsWith("disabled")).length;
  if (summary.blockedPhases !== blockedPhases) {
    errors.push(
      `summary.blockedPhases ${summary.blockedPhases} does not match ` +
        `${blockedPhases}.`
    );
  }
  const remoteRead = phases.filter((phase) =>
    phase.executionMode === "remote_read_local_write_guarded").length;
  if (summary.guardedRemoteReadPhases !== remoteRead) {
    errors.push(
      `summary.guardedRemoteReadPhases ${summary.guardedRemoteReadPhases} ` +
        `does not match ${remoteRead}.`
    );
  }
  const remoteWrite = phases.filter((phase) =>
    phase.executionMode === "remote_write_guarded").length;
  if (summary.guardedRemoteWritePhases !== remoteWrite) {
    errors.push(
      `summary.guardedRemoteWritePhases ${summary.guardedRemoteWritePhases} ` +
        `does not match ${remoteWrite}.`
    );
  }

  const ids = new Set();
  for (const phase of phases) {
    validatePhase({errors, ids, phase});
  }
  validateGateConsistency({errors, phases, summary});
  if (summary.pendingAdminDecisions > 0) {
    warnings.push(
      `${summary.pendingAdminDecisions} admin publication decision(s) pending.`
    );
  }
  if (summary.pendingPolicyDecisions > 0) {
    warnings.push(
      `${summary.pendingPolicyDecisions} product policy decision(s) pending.`
    );
  }

  return {
    ok: errors.length === 0,
    errors,
    warnings,
    summary: {
      status: summary.status ?? "unknown",
      phases: phases.length,
      blockedPhases,
      pendingAdminDecisions: summary.pendingAdminDecisions ?? 0,
      pendingPolicyDecisions: summary.pendingPolicyDecisions ?? 0,
      approvedPublicProjections: summary.approvedPublicProjections ?? 0,
      claimTargetPreviewWrites: summary.claimTargetPreviewWrites ?? 0,
      canRunLocalPreview: summary.canRunLocalPreview === true,
      canDeployNewPublicPages: summary.canDeployNewPublicPages === true,
      canWriteClaimTargets: summary.canWriteClaimTargets === true,
    },
  };
}

export function renderPromotionExecutionPacketMarkdown(packet) {
  const summary = packet.summary ?? {};
  const lines = [
    "# Organizer Promotion Execution",
    "",
    `Status: ${summary.status ?? "unknown"}; ` +
      `${summary.phases ?? 0} phase(s); ` +
      `${summary.blockedPhases ?? 0} blocked/waiting phase(s).`,
    "",
    `Local preview: ${summary.canRunLocalPreview ? "ready" : "blocked"}`,
    `Deploy new public pages: ${summary.canDeployNewPublicPages ? "ready" : "blocked"}`,
    `Claim-target writes: ${summary.canWriteClaimTargets ? "ready" : "blocked"}`,
    "",
  ];

  for (const phase of packet.phases ?? []) {
    lines.push(
      `## ${phase.label}`,
      "",
      `Status: ${phase.status}`,
      `Mode: ${phase.executionMode}`,
      `Command: \`${phase.command}\``,
      ""
    );
    for (const blocker of phase.blockers ?? []) {
      lines.push(`- Blocker: ${blocker}`);
    }
    for (const output of phase.outputs ?? []) {
      lines.push(`- Output: ${output}`);
    }
    lines.push("");
  }
  return `${lines.join("\n")}\n`;
}

function validatePhase({errors, ids, phase}) {
  if (!phase || typeof phase !== "object") {
    errors.push("phase must be an object.");
    return;
  }
  for (const field of [
    "phaseId",
    "label",
    "status",
    "executionMode",
    "command",
  ]) {
    if (!phase[field]) errors.push(`${phase.phaseId ?? "phase"} missing ${field}.`);
  }
  if (ids.has(phase.phaseId)) errors.push(`${phase.phaseId}: duplicate phaseId.`);
  ids.add(phase.phaseId);
  if (!Array.isArray(phase.blockers)) {
    errors.push(`${phase.phaseId}: blockers must be an array.`);
  }
  if (!Array.isArray(phase.outputs)) {
    errors.push(`${phase.phaseId}: outputs must be an array.`);
  }
  if (
    (phase.executionMode === "remote_write_guarded" ||
      phase.executionMode === "local_write_guarded") &&
    !String(phase.command).includes("--write")
  ) {
    errors.push(`${phase.phaseId}: guarded write phase must show an explicit write flag.`);
  }
}

function validateGateConsistency({errors, phases, summary}) {
  const phaseById = new Map(phases.map((phase) => [phase.phaseId, phase]));
  const adminPhase = phaseById.get("review_admin_publication_decisions");
  if (summary.pendingAdminDecisions > 0 &&
    adminPhase?.status !== "waiting_on_admin_review") {
    errors.push("admin review phase must wait while admin decisions are pending.");
  }
  const policyPhase = phaseById.get("review_product_policy_decisions");
  if (summary.pendingPolicyDecisions > 0 &&
    policyPhase?.status !== "waiting_on_policy_input") {
    errors.push("policy review phase must wait while policy decisions are pending.");
  }
  const claimWrite = phaseById.get("claim_target_firestore_write");
  if (summary.canWriteClaimTargets !== true &&
    claimWrite?.status === "ready_after_reviewed_firestore_dry_run") {
    errors.push("claim-target write phase cannot be ready while summary blocks writes.");
  }
  if (summary.canDeployNewPublicPages === true &&
    summary.approvedPublicProjections < 1) {
    errors.push("cannot deploy new public pages without approved projections.");
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
  const result = checkOrganizerPromotionExecutionPacket(packet);
  if (args.requireReady && !result.summary.canDeployNewPublicPages) {
    result.errors.push("No reviewed public organizer promotion is ready to deploy.");
    result.ok = false;
  }
  if (args.check && !result.ok) {
    printErrors(result);
    process.exit(1);
  }

  if (args.format === "json") {
    console.log(JSON.stringify(args.check ? result : packet, null, 2));
  } else if (args.format === "markdown") {
    console.log(renderPromotionExecutionPacketMarkdown(packet));
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
    requireReady: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--check") args.check = true;
    else if (arg === "--require-ready") args.requireReady = true;
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
    fail(`Missing promotion execution packet: ${relative(file)}`);
  }
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function printText({packetPath, result}) {
  console.log(
    "Organizer promotion execution: " +
      `${result.summary.status}, ${result.summary.phases} phase(s), ` +
      `${result.summary.blockedPhases} blocked/waiting, ` +
      `${result.summary.pendingAdminDecisions} admin pending, ` +
      `${result.summary.pendingPolicyDecisions} policy pending.`
  );
  console.log(`Source: ${relative(packetPath)}`);
  for (const warning of result.warnings) console.log(`- ${warning}`);
}

function printErrors(result) {
  console.error("Organizer promotion execution packet check failed:");
  for (const error of result.errors) console.error(`- ${error}`);
}

function countBy(items, field) {
  return Object.fromEntries([...items.reduce((counts, item) => {
    const key = item[field] ?? "unknown";
    counts.set(key, (counts.get(key) ?? 0) + 1);
    return counts;
  }, new Map()).entries()].sort(([left], [right]) =>
    String(left).localeCompare(String(right))));
}

function sameRecord(left, right) {
  return JSON.stringify(sortRecord(left)) === JSON.stringify(sortRecord(right));
}

function sortRecord(record) {
  return Object.fromEntries(Object.entries(record).sort(([left], [right]) =>
    left.localeCompare(right)));
}

function emptySummary() {
  return {
    approvedPublicProjections: 0,
    blockedPhases: 0,
    canDeployNewPublicPages: false,
    canRunLocalPreview: false,
    canWriteClaimTargets: false,
    claimTargetPreviewWrites: 0,
    pendingAdminDecisions: 0,
    pendingPolicyDecisions: 0,
    phases: 0,
    status: "invalid",
  };
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
  console.log(`Usage: node tool/organizer_intake/promotion_execution_packet.mjs [options]

Validates and renders the read-only promotion execution packet that connects
reviewed organizer approvals to website generation and claim-target sync.

Options:
  --check            Validate the generated packet.
  --require-ready    Future deploy gate: fail until a public promotion is ready.
  --format <format>  text, markdown, or json.
  --packet <path>    Packet path. Defaults to generated promotion packet.
  -h, --help         Show this help.
`);
}

function isMain() {
  return process.argv[1] &&
    import.meta.url === pathToFileURL(process.argv[1]).href;
}
