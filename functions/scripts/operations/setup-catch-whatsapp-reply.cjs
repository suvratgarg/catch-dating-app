#!/usr/bin/env node
"use strict";

const fs = require("node:fs");
const path = require("node:path");

// Deliberately offline. No Admin initialization, token reader or apply command.
// An inspected local JSON receipt is never promoted to a protected reviewed plan.
function inspect(argv = process.argv.slice(2)) {
  if (argv.length !== 3 || argv[0] !== "inspect-plan" ||
      argv[1] !== "--plan-file" || !argv[2]) {
    throw new Error("Use inspect-plan --plan-file <receipt>. Live apply is unavailable.");
  }
  const file = path.resolve(argv[2]);
  const stat = fs.lstatSync(file);
  if (!stat.isFile() || stat.isSymbolicLink() || stat.size > 65536) {
    throw new Error("Invalid offline plan receipt.");
  }
  const {validateSetupPlan, setupHash} = require(
    "../../lib/catchMessaging/whatsappOperatorSetup.js");
  const plan = JSON.parse(fs.readFileSync(file, "utf8"));
  validateSetupPlan(plan);
  return {kind: "catch-operator-plan-inspection", sourceSha: plan.sourceSha,
    planSha256: setupHash(plan), scopeSha256: setupHash(plan.scope),
    createdAtMillis: plan.createdAtMillis, expiresAtMillis: plan.expiresAtMillis,
    liveApplyAvailable: false};
}
if (require.main === module) {
  try {
    process.stdout.write(JSON.stringify(inspect()) + "\n");
  } catch {
    // Never echo arguments, private plan values or backend errors.
    process.stderr.write("Offline operator plan inspection unavailable. " +
      "Use inspect-plan --plan-file <receipt>; live apply is unavailable.\n");
    process.exitCode = 1;
  }
}
module.exports = {inspect};
