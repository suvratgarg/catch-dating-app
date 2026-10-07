#!/usr/bin/env node
"use strict";

const admin = require("firebase-admin");
const {backfillContactSummaries, activateContactSummaries} =
  require("../lib/hostReadModels/contactBackfill");

async function main(argv = process.argv.slice(2)) {
  const args = new Map();
  for (let index = 0; index < argv.length; index++) {
    const flag = argv[index];
    if (["--apply", "--activate"].includes(flag)) args.set(flag, true);
    else if (["--project", "--organizer"].includes(flag)) {
      args.set(flag, argv[++index]);
    } else throw new Error(`Unknown argument: ${flag}`);
  }
  const projectId = args.get("--project");
  const organizerId = args.get("--organizer");
  if (typeof projectId !== "string" || !/^[a-z0-9-]+$/.test(projectId) ||
      typeof organizerId !== "string" || !/^[A-Za-z0-9_-]+$/.test(organizerId)) {
    throw new Error("Provide explicit --project and --organizer identifiers.");
  }
  const apply = args.get("--apply") === true;
  if (args.has("--activate") && !apply) {
    throw new Error("Activation requires --apply and successful parity.");
  }
  const app = admin.initializeApp({projectId});
  try {
    const db = app.firestore();
    const scanned = await backfillContactSummaries(db, organizerId, apply);
    const activated = args.has("--activate") ?
      await activateContactSummaries(db, organizerId) : null;
    console.log(JSON.stringify({projectId, organizerId, apply, scanned,
      activated}));
  } finally {
    await app.delete();
  }
}
if (require.main === module) main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
module.exports = {main};
