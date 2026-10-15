#!/usr/bin/env node
"use strict";

const admin = require("firebase-admin");
const {backfillContactSummaries, activateContactSummaries} =
  require("../lib/hostReadModels/contactBackfill");

const {backfillSimpleSummaries, activateSimpleSummaries} =
  require("../lib/hostReadModels/simpleStore");

const {backfillResponseSummaries, activateResponseSummaries} =
  require("../lib/hostReadModels/responseStore");

async function main(argv = process.argv.slice(2)) {
  const args = new Map();
  for (let index = 0; index < argv.length; index++) {
    const flag = argv[index];
    if (["--apply", "--activate"].includes(flag)) args.set(flag, true);
    else if (["--project", "--organizer", "--model"].includes(flag)) {
      args.set(flag, argv[++index]);
    } else throw new Error(`Unknown argument: ${flag}`);
  }
  const projectId = args.get("--project");
  const organizerId = args.get("--organizer");
  if (typeof projectId !== "string" || !/^[a-z0-9-]+$/.test(projectId) ||
      typeof organizerId !== "string" || !/^[A-Za-z0-9_-]+$/.test(organizerId)) {
    throw new Error("Provide explicit --project and --organizer identifiers.");
  }
  const model = args.get("--model") ?? "contacts";
  if (!["contacts", "forms", "events", "groups", "responses"].includes(model)) {
    throw new Error("Use --model contacts, forms, events, groups or responses.");
  }
  const apply = args.get("--apply") === true;
  if (args.has("--activate") && !apply) {
    throw new Error("Activation requires --apply and successful parity.");
  }
  const app = admin.initializeApp({projectId});
  try {
    const db = app.firestore();
    const scanned = model === "contacts" ?
      await backfillContactSummaries(db, organizerId, apply) :
      model === "responses" ?
        await backfillResponseSummaries(db, organizerId, apply) :
        await backfillSimpleSummaries(db, model, organizerId, apply);
    const activated = args.has("--activate") ?
      (model === "contacts" ? await activateContactSummaries(db, organizerId) :
        model === "responses" ? await activateResponseSummaries(db, organizerId) :
          await activateSimpleSummaries(db, model, organizerId)) : null;
    console.log(JSON.stringify({projectId, organizerId, model, apply, scanned,
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
