#!/usr/bin/env node
import path from "node:path";
import {createRequire} from "node:module";
import {fileURLToPath} from "node:url";

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(toolDir, "..");
const requireFromFunctions = createRequire(
  path.join(repoRoot, "functions/package.json")
);
const admin = requireFromFunctions("firebase-admin");

const args = parseArgs(process.argv.slice(2));
if (args.help) {
  printHelp();
  process.exit(0);
}

if (args.emulatorHost) {
  process.env.FIRESTORE_EMULATOR_HOST = args.emulatorHost;
}

admin.initializeApp({projectId: args.project});
const db = admin.firestore();
const now = admin.firestore.FieldValue.serverTimestamp();

const plan = await buildMigrationPlan(db);

if (args.json) {
  console.log(JSON.stringify(plan.summary, null, 2));
} else {
  printSummary(plan.summary);
}

if (!args.apply) {
  console.log("\nDry run only. Re-run with --apply to write relationship docs.");
  process.exit(0);
}

await applyPlan(db, plan);
console.log("\nApplied relationship document migration.");

function parseArgs(argv) {
  const parsed = {
    project: process.env.GCLOUD_PROJECT || process.env.GCP_PROJECT || "demo",
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

function printHelp() {
  console.log(`Usage: node tool/firestore_relationship_migration.mjs [options]

Builds Firestore relationship/action documents from legacy arrays and copies
legacy chats/{matchId}/messages into matches/{matchId}/messages.

Options:
  --apply                 Write the planned docs. Default is dry-run.
  --json                  Print summary as JSON.
  --project <id>          Firebase project id. Defaults to env project or demo.
  --emulator              Use Firestore emulator at 127.0.0.1:8080.
  --emulator-host <host>  Use a custom Firestore emulator host.
  -h, --help              Show this help.
`);
}

async function buildMigrationPlan(firestore) {
  const [usersSnap, clubsSnap, runsSnap, chatsSnap] = await Promise.all([
    firestore.collection("users").get(),
    firestore.collection("runClubs").get(),
    firestore.collection("runs").get(),
    firestore.collection("chats").get(),
  ]);

  const memberships = new Map();
  const participations = new Map();
  const savedRuns = new Map();
  const messageCopies = [];
  const warnings = [];

  for (const clubDoc of clubsSnap.docs) {
    const club = clubDoc.data();
    const clubId = clubDoc.id;
    for (const uid of stringArray(club.memberUserIds)) {
      const id = runClubMembershipId(clubId, uid);
      memberships.set(id, {
        path: `runClubMemberships/${id}`,
        data: {
          clubId,
          uid,
          role: uid === club.hostUserId ? "host" : "member",
          status: "active",
          joinedAt: now,
        },
      });
    }
    if (club.hostUserId && !memberships.has(runClubMembershipId(clubId, club.hostUserId))) {
      const id = runClubMembershipId(clubId, club.hostUserId);
      memberships.set(id, {
        path: `runClubMemberships/${id}`,
        data: {
          clubId,
          uid: club.hostUserId,
          role: "host",
          status: "active",
          joinedAt: now,
        },
      });
      warnings.push(`Added missing host membership for runClubs/${clubId}.`);
    }
  }

  for (const userDoc of usersSnap.docs) {
    const user = userDoc.data();
    const uid = userDoc.id;
    for (const clubId of stringArray(user.joinedRunClubIds)) {
      const id = runClubMembershipId(clubId, uid);
      if (!memberships.has(id)) {
        memberships.set(id, {
          path: `runClubMemberships/${id}`,
          data: {
            clubId,
            uid,
            role: "member",
            status: "active",
            joinedAt: now,
          },
        });
      }
    }
    for (const runId of stringArray(user.savedRunIds)) {
      const id = savedRunId(uid, runId);
      savedRuns.set(id, {
        path: `savedRuns/${id}`,
        data: {uid, runId, savedAt: now},
      });
    }
  }

  for (const runDoc of runsSnap.docs) {
    const run = runDoc.data();
    const runId = runDoc.id;
    const runClubId = typeof run.runClubId === "string" ? run.runClubId : "";
    for (const uid of stringArray(run.waitlistUserIds)) {
      setParticipation(participations, {
        runId,
        runClubId,
        uid,
        status: "waitlisted",
        waitlistedAt: now,
      });
    }
    for (const uid of stringArray(run.signedUpUserIds)) {
      setParticipation(participations, {
        runId,
        runClubId,
        uid,
        status: "signedUp",
        signedUpAt: now,
      });
    }
    for (const uid of stringArray(run.attendedUserIds)) {
      setParticipation(participations, {
        runId,
        runClubId,
        uid,
        status: "attended",
        attendedAt: now,
      });
    }
  }

  for (const chatDoc of chatsSnap.docs) {
    const matchId = chatDoc.id;
    const messagesSnap = await chatDoc.ref.collection("messages").get();
    for (const messageDoc of messagesSnap.docs) {
      messageCopies.push({
        from: messageDoc.ref.path,
        path: `matches/${matchId}/messages/${messageDoc.id}`,
        data: messageDoc.data(),
      });
    }
  }

  return {
    memberships: [...memberships.values()],
    participations: [...participations.values()],
    savedRuns: [...savedRuns.values()],
    messageCopies,
    summary: {
      project: args.project,
      emulatorHost: args.emulatorHost,
      apply: args.apply,
      runClubMemberships: memberships.size,
      runParticipations: participations.size,
      savedRuns: savedRuns.size,
      messageCopies: messageCopies.length,
      warnings,
    },
  };
}

function setParticipation(target, fields) {
  const id = runParticipationId(fields.runId, fields.uid);
  target.set(id, {
    path: `runParticipations/${id}`,
    data: {
      runId: fields.runId,
      runClubId: fields.runClubId,
      uid: fields.uid,
      status: fields.status,
      createdAt: now,
      updatedAt: now,
      ...(fields.signedUpAt ? {signedUpAt: fields.signedUpAt} : {}),
      ...(fields.waitlistedAt ? {waitlistedAt: fields.waitlistedAt} : {}),
      ...(fields.attendedAt ? {attendedAt: fields.attendedAt} : {}),
    },
  });
}

function stringArray(value) {
  return Array.isArray(value) ?
    value.filter((item) => typeof item === "string" && item.length > 0) :
    [];
}

function runClubMembershipId(clubId, uid) {
  return `${clubId}_${uid}`;
}

function runParticipationId(runId, uid) {
  return `${runId}_${uid}`;
}

function savedRunId(uid, runId) {
  return `${uid}_${runId}`;
}

function printSummary(summary) {
  console.log("Firestore relationship migration plan");
  console.log(`Project: ${summary.project}`);
  if (summary.emulatorHost) console.log(`Emulator: ${summary.emulatorHost}`);
  console.log(`runClubMemberships: ${summary.runClubMemberships}`);
  console.log(`runParticipations: ${summary.runParticipations}`);
  console.log(`savedRuns: ${summary.savedRuns}`);
  console.log(`messageCopies: ${summary.messageCopies}`);
  if (summary.warnings.length) {
    console.log("\nWarnings:");
    for (const warning of summary.warnings) console.log(`- ${warning}`);
  }
}

async function applyPlan(firestore, plan) {
  const writes = [
    ...plan.memberships,
    ...plan.participations,
    ...plan.savedRuns,
    ...plan.messageCopies,
  ];

  for (let i = 0; i < writes.length; i += 450) {
    const batch = firestore.batch();
    for (const write of writes.slice(i, i + 450)) {
      batch.set(firestore.doc(write.path), write.data, {merge: true});
    }
    await batch.commit();
  }
}
