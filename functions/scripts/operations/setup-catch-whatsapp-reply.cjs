#!/usr/bin/env node
"use strict";

const fs = require("node:fs");
const path = require("node:path");

// Inspection stays offline. It never promotes caller JSON to a reviewed plan.
function inspect(argv = process.argv.slice(2)) {
  if (argv.length !== 3 || argv[0] !== "inspect-plan" ||
      argv[1] !== "--plan-file" || !argv[2]) {
    throw new Error("Invalid operator command.");
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
async function run(argv = process.argv.slice(2)) {
  if (argv[0] === "inspect-plan") return inspect(argv);
  const command = argv[0];
  if (!((argv.length === 1 && ["fingerprint", "plan"].includes(command)) ||
      (argv.length === 3 && ["apply", "reconcile"].includes(command) &&
        argv[1] === "--plan-id" && /^[A-Za-z0-9_-]{1,128}$/u.test(argv[2])))) {
    throw new Error("Invalid operator command.");
  }
  const {createOperatorRuntime, executionIdentity} = require("./catch-whatsapp-operator-runtime.cjs");
  if (command === "fingerprint") return executionIdentity();
  const runtime = createOperatorRuntime();
  return command === "plan" ? runtime.plan() : runtime[command](argv[2]);
}
if (require.main === module) run().then((receipt) => {
  process.stdout.write(JSON.stringify(receipt) + "\n");
}).catch(() => {
  // Never echo arguments, token/profile values or private backend errors.
  process.stderr.write("Protected operator command unavailable. " +
    "Use inspect-plan --plan-file <receipt>, fingerprint, plan, " +
    "apply --plan-id <id>, or reconcile --plan-id <id>.\n");
  process.exitCode = 1;
});
module.exports = {inspect, run};
