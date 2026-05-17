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

const plan = await buildMigrationPlan(db);

if (args.json) {
  console.log(JSON.stringify(plan.summary, null, 2));
} else {
  printSummary(plan.summary);
}

if (!args.apply) {
  console.log("\nDry event only. Re-event with --apply to write relationship docs.");
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

Copies legacy chats/{matchId}/messages into matches/{matchId}/messages.
Relationship/action documents are now created by callables and direct edge
repositories only; this tool no longer reconstructs edge documents from legacy
parent-document arrays.

Options:
  --apply                 Write the planned docs. Default is dry-event.
  --json                  Print summary as JSON.
  --project <id>          Firebase project id. Defaults to env project or demo.
  --emulator              Use Firestore emulator at 127.0.0.1:8080.
  --emulator-host <host>  Use a custom Firestore emulator host.
  -h, --help              Show this help.
`);
}

async function buildMigrationPlan(firestore) {
  const chatsSnap = await firestore.collection("chats").get();
  const messageCopies = [];
  const warnings = [];

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
    messageCopies,
    summary: {
      project: args.project,
      emulatorHost: args.emulatorHost,
      apply: args.apply,
      messageCopies: messageCopies.length,
      warnings,
    },
  };
}

function printSummary(summary) {
  console.log("Firestore relationship migration plan");
  console.log(`Project: ${summary.project}`);
  if (summary.emulatorHost) console.log(`Emulator: ${summary.emulatorHost}`);
  console.log(`messageCopies: ${summary.messageCopies}`);
  if (summary.warnings.length) {
    console.log("\nWarnings:");
    for (const warning of summary.warnings) console.log(`- ${warning}`);
  }
}

async function applyPlan(firestore, plan) {
  const writes = plan.messageCopies;

  for (let i = 0; i < writes.length; i += 450) {
    const batch = firestore.batch();
    for (const write of writes.slice(i, i + 450)) {
      batch.set(firestore.doc(write.path), write.data, {merge: true});
    }
    await batch.commit();
  }
}
