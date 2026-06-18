#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(scriptDir, "..", "..");
const generatedRegisterPath = path.join(
  scriptDir,
  "generated",
  "organizer_policy_gap_register.json"
);
const defaultDecisionsRoot = path.join(scriptDir, "policy_gap_decisions");

const command = process.argv[2] ?? "help";
const args = process.argv.slice(3);

if (command === "help" || command === "--help" || command === "-h") {
  printHelp();
} else if (command === "list") {
  listPolicyGaps(args);
} else if (command === "draft") {
  draftDecision(args);
} else {
  console.error(`Unknown organizer policy gap decision command: ${command}`);
  printHelp();
  process.exit(64);
}

function listPolicyGaps(rawArgs = []) {
  const flags = parseFlags(rawArgs);
  const register = loadRegister(flags.register);
  console.log(
    `Organizer policy gaps: ${register.summary.gaps} gap(s), ` +
      `${register.summary.decisionRequired} still operationally blocked, ` +
      `${register.summary.reviewDecisions ?? 0} reviewed.`
  );
  for (const gap of register.gaps) {
    console.log(
      [
        gap.gapId.padEnd(44),
        gap.area.padEnd(20),
        gap.severity.padEnd(8),
        gap.status.padEnd(18),
        gap.decisionStatus ?? "not_reviewed",
      ].join("  ")
    );
  }
}

function draftDecision(rawArgs) {
  const gapId = rawArgs[0];
  if (!gapId || gapId.startsWith("--")) {
    console.error(
      "Usage: node tool/organizer_intake/policy_gap_decision.mjs " +
        "draft <gapId> [flags]"
    );
    process.exit(64);
  }

  const flags = parseFlags(rawArgs.slice(1));
  const decision = requiredFlag(flags, "decision");
  const reviewer = requiredFlag(flags, "reviewer");
  const date = requiredFlag(flags, "date");
  const note = requiredFlag(flags, "note");
  const dryRun = Boolean(flags["dry-run"]);
  const confirmRequiredInputs = Boolean(flags["confirm-required-inputs"]);

  if (!["accept", "hold", "reject"].includes(decision)) {
    failFlag("decision", "must be accept, hold, or reject");
  }
  if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) {
    failFlag("date", "must be YYYY-MM-DD");
  }

  const register = loadRegister(flags.register);
  const gap = register.gaps.find((entry) => entry.gapId === gapId);
  if (!gap) {
    console.error(`No policy gap found for ${gapId}.`);
    console.error("Run node tool/organizer_intake/organizer_intake.mjs first if inputs changed.");
    process.exit(1);
  }

  const decisionsRoot = flags["decisions-root"] ?
    path.resolve(repoRoot, flags["decisions-root"]) :
    defaultDecisionsRoot;
  if (existingDecisionFiles(decisionsRoot, gapId).length > 0) {
    console.error(`A policy gap decision already exists for ${gapId}:`);
    for (const file of existingDecisionFiles(decisionsRoot, gapId)) {
      console.error(`- ${relative(file)}`);
    }
    process.exit(1);
  }

  const requiredInputsReviewed = confirmRequiredInputs ?
    gap.requiredInputs :
    flagList(flags, "required-input");
  const unknownInputs = requiredInputsReviewed.filter((input) =>
    !gap.requiredInputs.includes(input)
  );
  const missingInputs = gap.requiredInputs.filter((input) =>
    !requiredInputsReviewed.includes(input)
  );
  if (unknownInputs.length > 0) {
    failFlag(
      "required-input",
      `unknown required input(s): ${unknownInputs.join(", ")}`
    );
  }
  if (decision === "accept" && missingInputs.length > 0) {
    failFlag(
      "confirm-required-inputs",
      "is required before accepting a policy gap decision"
    );
  }

  const policyGapDecisionBatchId = [
    date,
    gapId.replaceAll("_", "-"),
    "policy",
    decision,
  ].join("-");
  const outputPath = path.join(decisionsRoot, `${policyGapDecisionBatchId}.json`);
  const payload = {
    schemaVersion: 1,
    policyGapDecisionBatchId,
    decidedAt: date,
    reviewer,
    decisions: [
      {
        gapId,
        decision,
        requiredInputsReviewed,
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

  fs.mkdirSync(decisionsRoot, {recursive: true});
  if (fs.existsSync(outputPath)) {
    console.error(`Decision file already exists: ${relative(outputPath)}`);
    process.exit(1);
  }
  fs.writeFileSync(outputPath, rendered);
  console.log(`Wrote ${relative(outputPath)}.`);
  console.log("Run: node tool/organizer_intake/organizer_intake.mjs");
}

function loadRegister(registerPath) {
  const targetPath = registerPath ?
    path.resolve(repoRoot, registerPath) :
    generatedRegisterPath;
  if (!fs.existsSync(targetPath)) {
    console.error(`Missing policy gap register: ${relative(targetPath)}`);
    console.error("Run: node tool/organizer_intake/organizer_intake.mjs");
    process.exit(1);
  }
  return JSON.parse(fs.readFileSync(targetPath, "utf8"));
}

function existingDecisionFiles(decisionsRoot, gapId) {
  if (!fs.existsSync(decisionsRoot)) return [];
  const files = fs
    .readdirSync(decisionsRoot)
    .filter((file) => file.endsWith(".json"))
    .map((file) => path.join(decisionsRoot, file));
  return files.filter((file) => {
    const batch = JSON.parse(fs.readFileSync(file, "utf8"));
    return (batch.decisions ?? []).some((entry) => entry.gapId === gapId);
  });
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
    if (["confirm-required-inputs", "dry-run"].includes(key)) {
      flags[key] = true;
      continue;
    }
    const value = flagArgs[index + 1];
    if (!value || value.startsWith("--")) {
      console.error(`Flag --${key} requires a value.`);
      process.exit(64);
    }
    if (key === "required-input") {
      flags[key] = [...(flags[key] ?? []), value.trim()];
    } else {
      flags[key] = value;
    }
    index += 1;
  }
  return flags;
}

function flagList(flags, name) {
  const value = flags[name];
  if (!value) return [];
  return Array.isArray(value) ? value : [value];
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

function relative(file) {
  return path.relative(repoRoot, file);
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

function printHelp() {
  console.log(`Usage: node tool/organizer_intake/policy_gap_decision.mjs <command>

Commands:
  list
      List generated policy gaps and review decision state.
  draft <gapId>
      Draft a repo-backed policy gap review decision.

Draft flags:
  --decision <accept|hold|reject>
  --reviewer <name>
  --date <YYYY-MM-DD>
  --note <text>
  --required-input <exact required input>  Repeatable.
  --confirm-required-inputs              Mark every required input reviewed.
  --dry-run
  --register <path>
  --decisions-root <path>
`);
}
