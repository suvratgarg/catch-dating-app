#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {createRequire} from "node:module";
import {fileURLToPath, pathToFileURL} from "node:url";

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(toolDir, "..");
const requireFromFunctions = createRequire(
  path.join(repoRoot, "functions/package.json")
);
const admin = requireFromFunctions("firebase-admin");

if (isMain()) {
  await main();
}

export async function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);
  if (args.help) {
    printHelp();
    return;
  }

  if (args.emulatorHost) {
    process.env.FIRESTORE_EMULATOR_HOST = args.emulatorHost;
  }

  admin.initializeApp({projectId: resolveProjectId(args)});
  const db = admin.firestore();
  const plan = await buildRunAggregateRepairPlan(db);

  if (args.json) {
    console.log(JSON.stringify(plan.summary, null, 2));
  } else {
    printSummary(plan.summary);
  }

  if (!args.apply) {
    console.log("\nDry run only. Re-run with --apply to write run aggregates.");
    return;
  }

  await applyRunAggregateRepairPlan(db, plan);
  console.log("\nApplied run aggregate repairs.");
}

export async function buildRunAggregateRepairPlan(firestore) {
  const [runsSnap, participationsSnap] = await Promise.all([
    firestore.collection("runs").get(),
    firestore.collection("runParticipations").get(),
  ]);

  const runIds = new Set(runsSnap.docs.map((doc) => doc.id));
  const aggregates = new Map();
  const warnings = [];

  for (const doc of participationsSnap.docs) {
    const data = doc.data();
    if (typeof data.runId !== "string" || data.runId.length === 0) {
      warnings.push(`${doc.ref.path} has no runId.`);
      continue;
    }
    if (!runIds.has(data.runId)) {
      warnings.push(`${doc.ref.path} references missing runs/${data.runId}.`);
      continue;
    }
    const aggregate = aggregateForRun(aggregates, data.runId);
    if (data.status === "signedUp" || data.status === "attended") {
      aggregate.bookedCount += 1;
      if (typeof data.genderAtSignup === "string") {
        aggregate.genderCounts[data.genderAtSignup] =
          (aggregate.genderCounts[data.genderAtSignup] ?? 0) + 1;
      }
    }
    if (data.status === "attended") {
      aggregate.checkedInCount += 1;
    }
    if (data.status === "waitlisted") {
      aggregate.waitlistedCount += 1;
    }
  }

  const repairs = [];
  for (const runDoc of runsSnap.docs) {
    const data = runDoc.data();
    const expected = aggregateForRun(aggregates, runDoc.id);
    const current = {
      bookedCount: data.bookedCount,
      checkedInCount: data.checkedInCount,
      waitlistedCount: data.waitlistedCount,
      genderCounts: data.genderCounts ?? {},
    };
    if (!sameAggregate(current, expected)) {
      repairs.push({
        path: runDoc.ref.path,
        runId: runDoc.id,
        current,
        expected: cloneAggregate(expected),
      });
    }
  }

  return {
    repairs,
    summary: {
      runsScanned: runsSnap.size,
      participationsScanned: participationsSnap.size,
      repairsNeeded: repairs.length,
      warnings,
      repairs,
    },
  };
}

export async function applyRunAggregateRepairPlan(firestore, plan) {
  for (let i = 0; i < plan.repairs.length; i += 450) {
    const batch = firestore.batch();
    for (const repair of plan.repairs.slice(i, i + 450)) {
      batch.update(firestore.doc(repair.path), repair.expected);
    }
    await batch.commit();
  }
}

export function aggregateForRun(aggregates, runId) {
  if (!aggregates.has(runId)) {
    aggregates.set(runId, {
      bookedCount: 0,
      checkedInCount: 0,
      waitlistedCount: 0,
      genderCounts: {},
    });
  }
  return aggregates.get(runId);
}

function sameAggregate(current, expected) {
  return current.bookedCount === expected.bookedCount &&
    current.checkedInCount === expected.checkedInCount &&
    current.waitlistedCount === expected.waitlistedCount &&
    JSON.stringify(normalizeObject(current.genderCounts)) ===
      JSON.stringify(normalizeObject(expected.genderCounts));
}

function cloneAggregate(aggregate) {
  return {
    bookedCount: aggregate.bookedCount,
    checkedInCount: aggregate.checkedInCount,
    waitlistedCount: aggregate.waitlistedCount,
    genderCounts: normalizeObject(aggregate.genderCounts),
  };
}

function normalizeObject(value) {
  return Object.fromEntries(Object.entries(value ?? {}).sort());
}

function parseArgs(argv) {
  const parsed = {
    env: null,
    project: null,
    emulatorHost: null,
    apply: false,
    json: false,
    help: false,
  };

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--apply") parsed.apply = true;
    else if (arg === "--json") parsed.json = true;
    else if (arg === "--emulator") parsed.emulatorHost = "127.0.0.1:8080";
    else if (arg === "--emulator-host") {
      parsed.emulatorHost = requireValue(argv, ++i, arg);
    } else if (arg === "--env") {
      parsed.env = requireValue(argv, ++i, arg);
    } else if (arg === "--project") {
      parsed.project = requireValue(argv, ++i, arg);
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }

  return parsed;
}

function requireValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) {
    throw new Error(`${flag} requires a value.`);
  }
  return value;
}

function resolveProjectId(parsed) {
  if (parsed.project) return parsed.project;
  if (parsed.env) {
    const firebaserc = JSON.parse(
      fs.readFileSync(path.join(repoRoot, ".firebaserc"), "utf8")
    );
    const project = firebaserc.projects?.[parsed.env];
    if (!project) {
      throw new Error(`No Firebase project alias found for env: ${parsed.env}`);
    }
    return project;
  }
  return process.env.GCLOUD_PROJECT ||
    process.env.GOOGLE_CLOUD_PROJECT ||
    "catchdates-dev";
}

function printHelp() {
  console.log(`Usage: node tool/recompute_run_aggregate_counts.mjs [options]

Recomputes runs/{runId} aggregate projections from runParticipations edges.
bookedCount counts signedUp + attended, checkedInCount counts attended,
waitlistedCount counts waitlisted, and genderCounts counts signedUp + attended.

Options:
  --apply                 Write repairs. Default is dry-run.
  --json                  Print summary as JSON.
  --env <dev|staging|prod> Resolve project id from .firebaserc.
  --project <id>          Firebase project id.
  --emulator              Use Firestore emulator at 127.0.0.1:8080.
  --emulator-host <host>  Use a custom Firestore emulator host.
  -h, --help              Show this help.
`);
}

function printSummary(summary) {
  console.log("Run aggregate repair plan");
  console.log(`Runs scanned: ${summary.runsScanned}`);
  console.log(`Participations scanned: ${summary.participationsScanned}`);
  console.log(`Repairs needed: ${summary.repairsNeeded}`);

  if (summary.repairs.length > 0) {
    console.log("\nRepairs:");
    for (const repair of summary.repairs.slice(0, 100)) {
      console.log(`- ${repair.path}: ${JSON.stringify(repair.expected)}`);
    }
    if (summary.repairs.length > 100) {
      console.log(`... ${summary.repairs.length - 100} more repairs`);
    }
  }

  if (summary.warnings.length > 0) {
    console.log("\nWarnings:");
    for (const warning of summary.warnings.slice(0, 100)) {
      console.log(`- ${warning}`);
    }
    if (summary.warnings.length > 100) {
      console.log(`... ${summary.warnings.length - 100} more warnings`);
    }
  }
}

function isMain() {
  return process.argv[1] &&
    import.meta.url === pathToFileURL(process.argv[1]).href;
}
