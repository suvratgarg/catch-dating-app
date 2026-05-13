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
  const firestore = admin.firestore();
  const plan = await buildFutureRunAttendanceRepairPlan(firestore);

  if (args.json) {
    console.log(JSON.stringify(plan.summary, null, 2));
  } else {
    printSummary(plan.summary);
  }

  if (!args.apply) {
    console.log("\nDry run only. Re-run with --apply to write repairs.");
    return;
  }

  await applyFutureRunAttendanceRepairPlan(firestore, plan);
  console.log("\nApplied future-run attendance repairs.");
}

export async function buildFutureRunAttendanceRepairPlan(
  firestore,
  now = new Date()
) {
  const [runsSnap, participationsSnap, swipesSnap] = await Promise.all([
    firestore.collection("runs").get(),
    firestore.collection("runParticipations").get(),
    firestore.collectionGroup("outgoing").get(),
  ]);

  const futureRunIds = new Set();
  for (const doc of runsSnap.docs) {
    const startTime = doc.data().startTime?.toDate?.();
    if (startTime && startTime > now) futureRunIds.add(doc.id);
  }

  const participationRepairs = [];
  const adjustedParticipations = [];
  for (const doc of participationsSnap.docs) {
    const data = doc.data();
    const repaired =
      data.status === "attended" && futureRunIds.has(data.runId);
    const nextData = repaired
      ? {...data, status: "signedUp", attendedAt: null}
      : data;

    adjustedParticipations.push(nextData);
    if (repaired) {
      participationRepairs.push({
        path: doc.ref.path,
        runId: data.runId,
        uid: data.uid,
        update: {status: "signedUp", attendedAt: null},
      });
    }
  }

  const expectedAggregates = aggregateParticipations(adjustedParticipations);
  const attendedKeys = attendedParticipationKeys(adjustedParticipations);
  const affectedRunIds = new Set(participationRepairs.map((repair) => repair.runId));
  const aggregateRepairs = [];
  for (const runDoc of runsSnap.docs) {
    if (!affectedRunIds.has(runDoc.id)) continue;
    const data = runDoc.data();
    const expected = expectedAggregates.get(runDoc.id) ?? emptyAggregate();
    const current = {
      bookedCount: data.bookedCount,
      checkedInCount: data.checkedInCount,
      waitlistedCount: data.waitlistedCount,
      genderCounts: normalizeObject(data.genderCounts ?? {}),
    };
    if (!sameAggregate(current, expected)) {
      aggregateRepairs.push({
        path: runDoc.ref.path,
        runId: runDoc.id,
        current,
        expected,
      });
    }
  }
  const swipeDeletes = [];
  for (const doc of swipesSnap.docs) {
    const data = doc.data();
    if (!futureRunIds.has(data.runId)) continue;
    if (
      !attendedKeys.has(`${data.runId}_${data.swiperId}`) ||
      !attendedKeys.has(`${data.runId}_${data.targetId}`)
    ) {
      swipeDeletes.push({
        path: doc.ref.path,
        runId: data.runId,
        swiperId: data.swiperId,
        targetId: data.targetId,
      });
    }
  }

  return {
    participationRepairs,
    aggregateRepairs,
    swipeDeletes,
    summary: {
      futureRunsScanned: futureRunIds.size,
      participationsScanned: participationsSnap.size,
      swipesScanned: swipesSnap.size,
      participationRepairsNeeded: participationRepairs.length,
      aggregateRepairsNeeded: aggregateRepairs.length,
      swipeDeletesNeeded: swipeDeletes.length,
      participationRepairs,
      aggregateRepairs,
      swipeDeletes,
    },
  };
}

export async function applyFutureRunAttendanceRepairPlan(firestore, plan) {
  for (let i = 0; i < plan.participationRepairs.length; i += 450) {
    const batch = firestore.batch();
    for (const repair of plan.participationRepairs.slice(i, i + 450)) {
      batch.update(firestore.doc(repair.path), repair.update);
    }
    await batch.commit();
  }

  for (let i = 0; i < plan.aggregateRepairs.length; i += 450) {
    const batch = firestore.batch();
    for (const repair of plan.aggregateRepairs.slice(i, i + 450)) {
      batch.update(firestore.doc(repair.path), repair.expected);
    }
    await batch.commit();
  }

  for (let i = 0; i < plan.swipeDeletes.length; i += 450) {
    const batch = firestore.batch();
    for (const deletion of plan.swipeDeletes.slice(i, i + 450)) {
      batch.delete(firestore.doc(deletion.path));
    }
    await batch.commit();
  }
}

function aggregateParticipations(participations) {
  const aggregates = new Map();
  for (const data of participations) {
    if (typeof data.runId !== "string" || data.runId.length === 0) continue;
    const aggregate = mapEntry(aggregates, data.runId, emptyAggregate);
    if (data.status === "signedUp" || data.status === "attended") {
      aggregate.bookedCount += 1;
      const gender = data.genderAtSignup;
      if (typeof gender === "string" && gender.length > 0) {
        aggregate.genderCounts[gender] = (aggregate.genderCounts[gender] ?? 0) + 1;
      }
    }
    if (data.status === "attended") aggregate.checkedInCount += 1;
    if (data.status === "waitlisted") aggregate.waitlistedCount += 1;
  }
  for (const [runId, aggregate] of aggregates.entries()) {
    aggregates.set(runId, normalizeAggregate(aggregate));
  }
  return aggregates;
}

function attendedParticipationKeys(participations) {
  const keys = new Set();
  for (const data of participations) {
    if (
      data.status === "attended" &&
      typeof data.runId === "string" &&
      typeof data.uid === "string"
    ) {
      keys.add(`${data.runId}_${data.uid}`);
    }
  }
  return keys;
}

function emptyAggregate() {
  return {
    bookedCount: 0,
    checkedInCount: 0,
    waitlistedCount: 0,
    genderCounts: {},
  };
}

function normalizeAggregate(aggregate) {
  return {
    bookedCount: aggregate.bookedCount,
    checkedInCount: aggregate.checkedInCount,
    waitlistedCount: aggregate.waitlistedCount,
    genderCounts: normalizeObject(aggregate.genderCounts),
  };
}

function sameAggregate(current, expected) {
  return current.bookedCount === expected.bookedCount &&
    current.checkedInCount === expected.checkedInCount &&
    current.waitlistedCount === expected.waitlistedCount &&
    JSON.stringify(normalizeObject(current.genderCounts)) ===
      JSON.stringify(normalizeObject(expected.genderCounts));
}

function normalizeObject(value) {
  return Object.fromEntries(Object.entries(value ?? {}).sort());
}

function mapEntry(map, key, create) {
  if (!map.has(key)) map.set(key, create());
  return map.get(key);
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
  console.log(`Usage: node tool/repair_future_run_attendance.mjs [options]

Downgrades invalid future-run attended participations to signedUp and repairs
affected run aggregate counts.

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
  console.log("Future-run attendance repair plan");
  console.log(`Future runs scanned: ${summary.futureRunsScanned}`);
  console.log(`Participations scanned: ${summary.participationsScanned}`);
  console.log(`Swipes scanned: ${summary.swipesScanned}`);
  console.log(`Participation repairs needed: ${summary.participationRepairsNeeded}`);
  console.log(`Aggregate repairs needed: ${summary.aggregateRepairsNeeded}`);
  console.log(`Swipe deletes needed: ${summary.swipeDeletesNeeded}`);

  if (summary.participationRepairs.length > 0) {
    console.log("\nParticipation repairs:");
    for (const repair of summary.participationRepairs.slice(0, 100)) {
      console.log(`- ${repair.path}: attended -> signedUp`);
    }
    if (summary.participationRepairs.length > 100) {
      console.log(`... ${summary.participationRepairs.length - 100} more repairs`);
    }
  }

  if (summary.aggregateRepairs.length > 0) {
    console.log("\nAggregate repairs:");
    for (const repair of summary.aggregateRepairs.slice(0, 100)) {
      console.log(`- ${repair.path}: ${JSON.stringify(repair.expected)}`);
    }
    if (summary.aggregateRepairs.length > 100) {
      console.log(`... ${summary.aggregateRepairs.length - 100} more repairs`);
    }
  }

  if (summary.swipeDeletes.length > 0) {
    console.log("\nSwipe deletes:");
    for (const deletion of summary.swipeDeletes.slice(0, 100)) {
      console.log(`- ${deletion.path}`);
    }
    if (summary.swipeDeletes.length > 100) {
      console.log(`... ${summary.swipeDeletes.length - 100} more deletes`);
    }
  }
}

function isMain() {
  return process.argv[1] &&
    import.meta.url === pathToFileURL(process.argv[1]).href;
}
