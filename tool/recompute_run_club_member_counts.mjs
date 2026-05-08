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
  const plan = await buildMemberCountRepairPlan(db);

  if (args.json) {
    console.log(JSON.stringify(plan.summary, null, 2));
  } else {
    printSummary(plan.summary);
  }

  if (!args.apply) {
    console.log("\nDry run only. Re-run with --apply to write memberCount.");
    return;
  }

  await applyMemberCountRepairPlan(db, plan);
  console.log("\nApplied run club memberCount repairs.");
}

export async function buildMemberCountRepairPlan(firestore) {
  const [clubsSnap, membershipsSnap] = await Promise.all([
    firestore.collection("runClubs").get(),
    firestore.collection("runClubMemberships").get(),
  ]);

  const clubIds = new Set(clubsSnap.docs.map((doc) => doc.id));
  const activeCounts = new Map();
  const warnings = [];

  for (const doc of membershipsSnap.docs) {
    const data = doc.data();
    if (data.status !== "active") continue;
    if (typeof data.clubId !== "string" || data.clubId.length === 0) {
      warnings.push(`${doc.ref.path} has active status but no clubId.`);
      continue;
    }
    if (!clubIds.has(data.clubId)) {
      warnings.push(
        `${doc.ref.path} references missing runClubs/${data.clubId}.`
      );
      continue;
    }
    activeCounts.set(data.clubId, (activeCounts.get(data.clubId) ?? 0) + 1);
  }

  const repairs = [];
  for (const clubDoc of clubsSnap.docs) {
    const current = clubDoc.data().memberCount;
    const expected = activeCounts.get(clubDoc.id) ?? 0;
    if (current !== expected) {
      repairs.push({
        path: clubDoc.ref.path,
        clubId: clubDoc.id,
        currentMemberCount: current,
        expectedMemberCount: expected,
      });
    }
  }

  return {
    repairs,
    summary: {
      clubsScanned: clubsSnap.size,
      membershipsScanned: membershipsSnap.size,
      repairsNeeded: repairs.length,
      warnings,
      repairs,
    },
  };
}

export async function applyMemberCountRepairPlan(firestore, plan) {
  for (let i = 0; i < plan.repairs.length; i += 450) {
    const batch = firestore.batch();
    for (const repair of plan.repairs.slice(i, i + 450)) {
      batch.update(firestore.doc(repair.path), {
        memberCount: repair.expectedMemberCount,
      });
    }
    await batch.commit();
  }
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
  console.log(`Usage: node tool/recompute_run_club_member_counts.mjs [options]

Recomputes runClubs/{clubId}.memberCount from active
runClubMemberships/{clubId_uid} edge documents.

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
  console.log("Run club memberCount repair plan");
  console.log(`Clubs scanned: ${summary.clubsScanned}`);
  console.log(`Memberships scanned: ${summary.membershipsScanned}`);
  console.log(`Repairs needed: ${summary.repairsNeeded}`);

  if (summary.repairs.length > 0) {
    console.log("\nRepairs:");
    for (const repair of summary.repairs.slice(0, 100)) {
      console.log(
        `- ${repair.path}: ${repair.currentMemberCount} -> ` +
        `${repair.expectedMemberCount}`
      );
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
