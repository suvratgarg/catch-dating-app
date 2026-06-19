#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(scriptDir, "..", "..");
const generatedQueuePath = path.join(scriptDir, "generated", "admin_review_queue.json");
const generatedPublicationPacketsPath = path.join(
  scriptDir,
  "generated",
  "publication_review_packets.json"
);
const decisionsRoot = path.join(scriptDir, "review_decisions");

const command = process.argv[2] ?? "help";
const args = process.argv.slice(3);

if (command === "help" || command === "--help" || command === "-h") {
  printHelp();
} else if (command === "list") {
  listQueue();
} else if (command === "draft") {
  draftDecision(args);
} else {
  console.error(`Unknown organizer review command: ${command}`);
  printHelp();
  process.exit(64);
}

function listQueue() {
  const queue = loadQueue();
  console.log(
    `Organizer review queue: ${queue.summary.total} item(s), ` +
      `${queue.summary.readyForManualApproval} ready for manual approval.`
  );
  for (const item of queue.items) {
    console.log(
      [
        item.entityId.padEnd(18),
        item.displayName.padEnd(24),
        item.taskType.padEnd(18),
        item.priority,
        item.blockers.length > 0 ? `blocked: ${item.blockers.join(", ")}` : "ready",
      ].join("  ")
    );
  }
}

function draftDecision(rawArgs) {
  const entityId = rawArgs[0];
  if (!entityId || entityId.startsWith("--")) {
    console.error("Usage: node tool/organizer_intake/review_decision.mjs draft <entityId> [flags]");
    process.exit(64);
  }

  const flags = parseFlags(rawArgs.slice(1));
  const decision = requiredFlag(flags, "decision");
  const reviewer = requiredFlag(flags, "reviewer");
  const date = requiredFlag(flags, "date");
  const note = requiredFlag(flags, "note");
  const appVisibility = flags["app-visibility"] ?? "hidden";
  const queuePath = flags.queue ?
    path.resolve(repoRoot, flags.queue) :
    generatedQueuePath;
  const publicationPacketsPath = flags["publication-packets"] ?
    path.resolve(repoRoot, flags["publication-packets"]) :
    generatedPublicationPacketsPath;
  const outputRoot = flags["decisions-root"] ?
    path.resolve(repoRoot, flags["decisions-root"]) :
    decisionsRoot;
  const dryRun = Boolean(flags["dry-run"]);
  const confirmPublicChecklist = Boolean(
    flags["confirm-publication-checklist"] ?? flags["confirm-public-checklist"]
  );
  const confirmManualReportsReviewed = Boolean(
    flags["confirm-manual-reports-reviewed"]
  );
  const confirmAppDiscoverability = Boolean(
    flags["confirm-app-discoverability"]
  );

  if (!["approve_public", "hold", "suppress"].includes(decision)) {
    failFlag("decision", "must be approve_public, hold, or suppress");
  }
  if (!["hidden", "discoverable"].includes(appVisibility)) {
    failFlag("app-visibility", "must be hidden or discoverable");
  }
  if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) {
    failFlag("date", "must be YYYY-MM-DD");
  }
  if (decision === "approve_public" && !confirmPublicChecklist) {
    failFlag(
      "confirm-publication-checklist",
      "is required before approving a public indexed organizer projection"
    );
  }
  if (decision === "approve_public" &&
    appVisibility === "discoverable" &&
    !confirmAppDiscoverability) {
    failFlag(
      "confirm-app-discoverability",
      "is required because app discoverability is separate from website publication"
    );
  }

  const queue = loadQueue(queuePath);
  const item = queue.items.find((entry) => entry.entityId === entityId);
  if (!item) {
    console.error(`No review queue item found for entity ${entityId}.`);
    console.error("Run node tool/organizer_intake/organizer_intake.mjs first if inputs changed.");
    process.exit(1);
  }
  assertPublicationDecisionAllowed({
    appVisibility,
    confirmManualReportsReviewed,
    decision,
    dryRun,
    entityId,
    item,
    publicationPacketsPath,
  });

  const decisionBatchId = `${date}-${entityId}-${decision.replaceAll("_", "-")}`;
  const outputPath = path.join(outputRoot, `${decisionBatchId}.json`);
  const checklist = confirmPublicChecklist ?
    completeChecklist({manualReportsReviewed: confirmManualReportsReviewed}) :
    emptyChecklist();
  const payload = {
    schemaVersion: 1,
    decisionBatchId,
    decidedAt: date,
    reviewer,
    decisions: [
      {
        entityId,
        decision,
        appVisibility,
        checklist,
        note,
      },
    ],
  };
  const rendered = `${stableStringify(payload)}\n`;

  if (dryRun) {
    console.log(`Would write ${relative(outputPath)}:`);
    console.log(rendered);
    return;
  }

  const existingFiles = existingDecisionFiles(entityId, outputRoot);
  if (existingFiles.length > 0) {
    console.error(`A review decision already exists for ${entityId}:`);
    for (const file of existingFiles) {
      console.error(`- ${relative(file)}`);
    }
    process.exit(1);
  }

  fs.mkdirSync(outputRoot, {recursive: true});
  if (fs.existsSync(outputPath)) {
    console.error(`Decision file already exists: ${relative(outputPath)}`);
    process.exit(1);
  }
  fs.writeFileSync(outputPath, rendered);
  console.log(`Wrote ${relative(outputPath)}.`);
  console.log("Run: node tool/organizer_intake/organizer_intake.mjs");
}

function loadQueue(queuePath = generatedQueuePath) {
  if (!fs.existsSync(queuePath)) {
    console.error(`Missing review queue: ${relative(queuePath)}`);
    console.error("Run: node tool/organizer_intake/organizer_intake.mjs");
    process.exit(1);
  }
  return JSON.parse(fs.readFileSync(queuePath, "utf8"));
}

function loadPublicationPackets(packetPath = generatedPublicationPacketsPath) {
  if (!fs.existsSync(packetPath)) {
    console.error(`Missing publication packets: ${relative(packetPath)}`);
    console.error("Run: node tool/organizer_intake/organizer_intake.mjs");
    process.exit(1);
  }
  return JSON.parse(fs.readFileSync(packetPath, "utf8"));
}

function existingDecisionFiles(entityId, root = decisionsRoot) {
  if (!fs.existsSync(root)) return [];
  const files = fs
    .readdirSync(root)
    .filter((file) => file.endsWith(".json"))
    .map((file) => path.join(root, file));
  return files.filter((file) => {
    const decision = JSON.parse(fs.readFileSync(file, "utf8"));
    return (decision.decisions ?? []).some((entry) => entry.entityId === entityId);
  });
}

function assertPublicationDecisionAllowed({
  appVisibility,
  confirmManualReportsReviewed,
  decision,
  dryRun,
  entityId,
  item,
  publicationPacketsPath,
}) {
  if (item.reviewDecision && !dryRun) {
    console.error(
      `Generated review state already has a ${item.reviewDecision.decision} decision for ${entityId}.`
    );
    process.exit(1);
  }
  if (decision !== "approve_public") return;

  const packet = findPublicationPacket(entityId, publicationPacketsPath);
  if (!packet) {
    console.error(`No publication review packet found for ${entityId}.`);
    console.error("Run node tool/organizer_intake/organizer_intake.mjs first if inputs changed.");
    process.exit(1);
  }
  if (!packet.adminDecision?.allowedDecisions?.includes(decision)) {
    console.error(`Publication packet ${packet.packetId} does not allow ${decision}.`);
    process.exit(1);
  }
  if (packet.adminDecision?.currentDecision && !dryRun) {
    console.error(
      `Publication packet ${packet.packetId} already has a ` +
        `${packet.adminDecision.currentDecision.decision} decision.`
    );
    process.exit(1);
  }
  const dataBlockers = packet.dataBlockers ?? [];
  const evidenceBlockers = packet.evidenceBlockers ?? [];
  const checklist = packet.approvalChecklist ?? {};
  const checklistComplete = Object.values(checklist).every(Boolean);
  const statusReady = packet.status === "ready_for_manual_publication_review" ||
    (dryRun && packet.status === "published");
  if (!statusReady ||
    dataBlockers.length > 0 ||
    evidenceBlockers.length > 0 ||
    !checklistComplete) {
    console.error(`Publication packet ${packet.packetId} is not ready for public approval.`);
    console.error(`status: ${packet.status}`);
    if (dataBlockers.length > 0) {
      console.error(`data blockers: ${dataBlockers.join(", ")}`);
    }
    if (evidenceBlockers.length > 0) {
      console.error(`evidence blockers: ${evidenceBlockers.join(", ")}`);
    }
    if (!checklistComplete) {
      const incomplete = Object.entries(checklist)
        .filter(([, value]) => value !== true)
        .map(([key]) => key);
      console.error(`incomplete checklist: ${incomplete.join(", ") || "unknown"}`);
    }
    process.exit(1);
  }
  const manualReports =
    packet.evidenceSummary?.manualReportsWithoutArtifacts ?? 0;
  if (manualReports > 0 && !confirmManualReportsReviewed) {
    failFlag(
      "confirm-manual-reports-reviewed",
      `is required because ${packet.packetId} has ${manualReports} manual report(s) without artifacts`
    );
  }
  if (packet.publicPresence?.appVisibility !== "hidden" &&
    appVisibility === "hidden") {
    console.error(
      `Publication packet ${packet.packetId} expected app visibility ` +
        `${packet.publicPresence.appVisibility}; refusing to draft hidden approval.`
    );
    process.exit(1);
  }
}

function findPublicationPacket(entityId, publicationPacketsPath) {
  const packets = loadPublicationPackets(publicationPacketsPath);
  return (packets.packets ?? []).find((packet) => packet.entityId === entityId) ?? null;
}

function completeChecklist({manualReportsReviewed = false} = {}) {
  return {
    crawlDisabledReviewed: true,
    identityReviewed: true,
    marketScopeReviewed: true,
    ...(manualReportsReviewed ? {manualReportsReviewed: true} : {}),
    mediaRightsReviewed: true,
    ownerSafeCopyReviewed: true,
    surfaceInventoryReviewed: true,
  };
}

function emptyChecklist() {
  return {
    crawlDisabledReviewed: false,
    identityReviewed: false,
    marketScopeReviewed: false,
    mediaRightsReviewed: false,
    ownerSafeCopyReviewed: false,
    surfaceInventoryReviewed: false,
  };
}

function parseFlags(flagArgs) {
  const flags = {};
  for (let index = 0; index < flagArgs.length; index += 1) {
    const arg = flagArgs[index];
    if (!arg.startsWith("--")) {
      console.error(`Unexpected positional argument: ${arg}`);
      process.exit(64);
    }
    const key = arg.slice(2);
    if ([
      "confirm-app-discoverability",
      "confirm-manual-reports-reviewed",
      "confirm-public-checklist",
      "confirm-publication-checklist",
      "dry-run",
    ].includes(key)) {
      flags[key] = true;
      continue;
    }
    const value = flagArgs[index + 1];
    if (!value || value.startsWith("--")) {
      console.error(`Flag --${key} requires a value.`);
      process.exit(64);
    }
    flags[key] = value;
    index += 1;
  }
  return flags;
}

function requiredFlag(flags, name) {
  const value = flags[name];
  if (typeof value !== "string" || value.trim().length === 0) {
    failFlag(name, "is required");
  }
  return value.trim();
}

function failFlag(name, reason) {
  console.error(`Invalid --${name}: ${reason}.`);
  process.exit(64);
}

function stableStringify(value) {
  return JSON.stringify(sortValue(value), null, 2);
}

function sortValue(value) {
  if (Array.isArray(value)) return value.map(sortValue);
  if (!value || typeof value !== "object") return value;
  return Object.fromEntries(
    Object.entries(value)
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([key, nested]) => [key, sortValue(nested)])
  );
}

function relative(file) {
  return path.relative(repoRoot, file);
}

function printHelp() {
  console.log(`Usage: node tool/organizer_intake/review_decision.mjs <command>

Commands:
  list
    Print the generated organizer admin review queue.

  draft <entityId> --decision <approve_public|hold|suppress> --reviewer <name>
      --date <YYYY-MM-DD> --note <text> [--app-visibility hidden|discoverable]
      [--queue <path>] [--publication-packets <path>] [--decisions-root <path>]
      [--confirm-publication-checklist] [--confirm-manual-reports-reviewed]
      [--confirm-app-discoverability] [--dry-run]

Examples:
  node tool/organizer_intake/review_decision.mjs list
  node tool/organizer_intake/review_decision.mjs draft afterfly \\
    --decision approve_public \\
    --reviewer "admin@example.com" \\
    --date 2026-06-17 \\
    --note "Manual QA complete." \\
    --confirm-publication-checklist \\
    --confirm-manual-reports-reviewed
`);
}
