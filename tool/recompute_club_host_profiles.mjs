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

  const admin = requireFromFunctions("firebase-admin");
  admin.initializeApp({projectId: resolveProjectId(args)});
  const db = admin.firestore();
  const plan = await buildClubHostProfileRepairPlan(
    db,
    loadProfileProjection()
  );

  if (args.json) {
    console.log(JSON.stringify(plan.summary, null, 2));
  } else {
    printSummary(plan.summary);
  }

  if (!args.apply) {
    console.log("\nDry run only. Re-event with --apply to write host fields.");
    return;
  }

  await applyClubHostProfileRepairPlan(db, plan);
  console.log("\nApplied club host profile repairs.");
}

export async function buildClubHostProfileRepairPlan(
  firestore,
  profileProjection
) {
  const [clubsSnap, usersSnap] = await Promise.all([
    firestore.collection("clubs").get(),
    firestore.collection("users").get(),
  ]);

  const users = new Map(usersSnap.docs.map((doc) => [doc.id, doc.data()]));
  const warnings = [];
  const repairs = [];

  for (const clubDoc of clubsSnap.docs) {
    const club = clubDoc.data();
    const ownerUserId = resolveOwnerUserId(club);
    if (!ownerUserId) {
      warnings.push(`${clubDoc.ref.path} has no ownerUserId or hostUserId.`);
      continue;
    }

    const hostUserIds = resolveHostUserIds(club, ownerUserId);
    const missingHostUserId = hostUserIds.find((uid) => !users.has(uid));
    if (missingHostUserId) {
      warnings.push(
        `${clubDoc.ref.path} references missing users/${missingHostUserId}.`
      );
      continue;
    }
    const deletedHostUserId = hostUserIds.find((uid) =>
      users.get(uid)?.deleted === true
    );
    if (deletedHostUserId) {
      warnings.push(
        `${clubDoc.ref.path} is hosted by deleted users/${deletedHostUserId}.`
      );
      continue;
    }

    const hostProfiles = hostUserIds.map((uid) => {
      const user = users.get(uid);
      return {
        uid,
        displayName: profileProjection.publicDisplayName(user),
        avatarUrl: profileProjection.publicAvatarUrl(user),
        role: uid === ownerUserId ? "owner" : "host",
      };
    });
    const primaryHostProfile = hostProfiles[0];
    const expected = {
      hostName: primaryHostProfile.displayName,
      hostAvatarUrl: primaryHostProfile.avatarUrl,
      ownerUserId,
      hostUserIds,
      hostProfiles,
      profileImageUrl: club.profileImageUrl ?? null,
    };
    const current = {
      hostName: club.hostName,
      hostAvatarUrl: club.hostAvatarUrl ?? null,
      ownerUserId: club.ownerUserId ?? null,
      hostUserIds: Array.isArray(club.hostUserIds) ? club.hostUserIds : [],
      hostProfiles: Array.isArray(club.hostProfiles) ? club.hostProfiles : [],
      profileImageUrl: club.profileImageUrl ?? null,
    };
    if (
      JSON.stringify(current) !== JSON.stringify(expected)
    ) {
      repairs.push({
        path: clubDoc.ref.path,
        clubId: clubDoc.id,
        hostUserId: ownerUserId,
        current,
        expected,
      });
    }
  }

  return {
    repairs,
    summary: {
      clubsScanned: clubsSnap.size,
      usersScanned: usersSnap.size,
      repairsNeeded: repairs.length,
      warnings,
      repairs,
    },
  };
}

export async function applyClubHostProfileRepairPlan(firestore, plan) {
  for (let i = 0; i < plan.repairs.length; i += 450) {
    const batch = firestore.batch();
    for (const repair of plan.repairs.slice(i, i + 450)) {
      batch.update(firestore.doc(repair.path), repair.expected);
    }
    await batch.commit();
  }
}

function loadProfileProjection() {
  try {
    return requireFromFunctions("./lib/shared/profileProjection.js");
  } catch (error) {
    throw new Error(
      "Could not load functions/lib/shared/profileProjection.js. " +
      "Event `npm --prefix functions run build` before this repair tool. " +
      `Original error: ${error.message}`
    );
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
  console.log(`Usage: node tool/recompute_club_host_profiles.mjs [options]

Recomputes club host projection fields from users/{uid} profile documents.
Backfills ownerUserId, hostUserIds, hostProfiles, and profileImageUrl for
legacy clubs while preserving the old hostName/hostAvatarUrl projection.

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

function resolveOwnerUserId(club) {
  if (typeof club.ownerUserId === "string" && club.ownerUserId.length > 0) {
    return club.ownerUserId;
  }
  if (typeof club.hostUserId === "string" && club.hostUserId.length > 0) {
    return club.hostUserId;
  }
  return null;
}

function resolveHostUserIds(club, ownerUserId) {
  return [
    ownerUserId,
    typeof club.hostUserId === "string" ? club.hostUserId : null,
    ...(Array.isArray(club.hostUserIds) ? club.hostUserIds : []),
    ...(Array.isArray(club.hostProfiles)
      ? club.hostProfiles.map((host) => host?.uid)
      : []),
  ]
    .filter((uid) => typeof uid === "string" && uid.length > 0)
    .filter((uid, index, all) => all.indexOf(uid) === index);
}

function printSummary(summary) {
  console.log("Club host profile repair plan");
  console.log(`Clubs scanned: ${summary.clubsScanned}`);
  console.log(`Users scanned: ${summary.usersScanned}`);
  console.log(`Repairs needed: ${summary.repairsNeeded}`);

  if (summary.repairs.length > 0) {
    console.log("\nRepairs:");
    for (const repair of summary.repairs.slice(0, 100)) {
      console.log(
        `- ${repair.path}: ${JSON.stringify(repair.current)} -> ` +
        `${JSON.stringify(repair.expected)}`
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
