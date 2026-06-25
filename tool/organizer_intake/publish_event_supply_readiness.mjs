#!/usr/bin/env node
import fs from "node:fs";
import {
  assertProdWriteAllowed,
  applyFirestoreEmulatorHost,
  resolveFirebaseProjectId,
} from "../lib/firebase_project.mjs";
import {isMain, parseCommonArgs} from "../lib/cli_args.mjs";
import {createFunctionsRequire, fromRepo} from "../lib/repo_paths.mjs";
import {
  applyEventSupplyReadinessPublishPlan,
  buildEventSupplyReadinessPublishPlan,
} from "./lib/event_supply_readiness_publish_core.mjs";

const defaultImportPlanPath =
  "tool/organizer_intake/generated/external_event_import_plan.json";
const defaultExecutionPlanPath =
  "tool/organizer_intake/generated/external_event_import_execution_plan.json";

if (isMain(import.meta.url)) {
  await main();
}

export async function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);
  if (args.help) {
    printHelp();
    return;
  }

  const importPlanPath = args.import_plan ?? defaultImportPlanPath;
  const executionPlanPath = args.execution_plan ?? defaultExecutionPlanPath;
  const publishPlan = buildEventSupplyReadinessPublishPlan({
    generatedAt: args.generated_at ?? new Date().toISOString(),
    importPlanPath,
    executionPlanPath,
    importPlan: readJson(importPlanPath),
    executionPlan: readJson(executionPlanPath),
  });

  if (args.json) {
    console.log(JSON.stringify(publishPlan.summary, null, 2));
  } else {
    printSummary(publishPlan.summary);
  }

  if (args.check) {
    console.log("\nCheck passed. Readiness artifact is schema-shaped.");
    return;
  }

  if (!args.apply) {
    console.log("\nDry run only. Re-run with --apply to publish readiness.");
    return;
  }

  const projectId = resolveFirebaseProjectId({
    env: args.env,
    project: args.project,
    defaultEnv: "dev",
  });
  assertProdWriteAllowed({
    env: args.env,
    projectId,
    project: args.project,
    apply: args.apply,
    allowProd: args.allowProd,
    confirmProd: args.confirmProd,
    action: "publish event supply readiness",
  });
  applyFirestoreEmulatorHost(args.emulatorHost);

  const requireFromFunctions = createFunctionsRequire();
  const admin = requireFromFunctions("firebase-admin");
  admin.initializeApp({projectId});
  const result = await applyEventSupplyReadinessPublishPlan(
    admin.firestore(),
    publishPlan,
    {serverTimestamp: admin.firestore.FieldValue.serverTimestamp()}
  );
  console.log(`\nPublished ${result.targetPath} in ${projectId}.`);
}

function parseArgs(argv) {
  return parseCommonArgs(argv, {
    booleanFlags: ["--check"],
    valueFlags: ["--import-plan", "--execution-plan", "--generated-at"],
  });
}

function readJson(relativePath) {
  const absolutePath = fromRepo(relativePath);
  return JSON.parse(fs.readFileSync(absolutePath, "utf8"));
}

function printSummary(summary) {
  console.log("External event supply readiness publish plan");
  console.log(`Target: ${summary.targetPath}`);
  console.log(`Generated: ${summary.generatedAt}`);
  console.log(`Import plan: ${summary.sourcePaths.importPlan}`);
  console.log(`Execution plan: ${summary.sourcePaths.executionPlan}`);
  console.log(`Candidates: ${summary.candidates}`);
  console.log(`Read-only drafts: ${summary.proposedReadOnlyEvents}`);
  console.log(`Waiting review: ${summary.waitingReview}`);
  console.log(`Import blockers: ${summary.importBlocked}`);
  console.log(`Execution blockers: ${summary.executionBlocked}`);
  console.log(`Projection errors: ${summary.projectionInvalidCount}`);
  console.log(`Import actions: ${summary.importActions}`);
  console.log(`Execution actions: ${summary.executionActions}`);
  console.log(`Write enabled: ${summary.writeEnabled ? "yes" : "no"}`);
  console.log(`Import policy: ${summary.importPolicyStatus}`);
  console.log(`Execution policy: ${summary.executionPolicyStatus}`);
}

function printHelp() {
  console.log(`Usage: node tool/organizer_intake/publish_event_supply_readiness.mjs [options]

Publishes the deterministic external event import plan and preflight snapshots
to eventSupplyReadiness/current for the live Events admin tab. Dry-run by
default. This does not import events or write externalEvents/{id}.

Options:
  --apply                    Write eventSupplyReadiness/current.
  --check                    Validate and print a read-only summary.
  --json                     Print summary as JSON.
  --env <dev|staging|prod>   Resolve project id from .firebaserc.
  --project <id>             Firebase project id.
  --emulator                 Use Firestore emulator at 127.0.0.1:8080.
  --emulator-host <host>     Use a custom Firestore emulator host.
  --allow-prod               Required with --apply against prod.
  --confirm-prod             Alias for --allow-prod.
  --import-plan <file>       Import plan JSON.
  --execution-plan <file>    Execution preflight JSON.
  --generated-at <iso>       Override the dashboard generatedAt timestamp.
  -h, --help                 Show this help.
`);
}
