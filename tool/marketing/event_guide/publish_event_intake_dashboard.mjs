#!/usr/bin/env node
import fs from "node:fs";
import {
  assertProdWriteAllowed,
  applyFirestoreEmulatorHost,
  resolveFirebaseProjectId,
} from "../../lib/firebase_project.mjs";
import {isMain, parseCommonArgs} from "../../lib/cli_args.mjs";
import {createFunctionsRequire, fromRepo} from "../../lib/repo_paths.mjs";
import {
  applyEventIntakeDashboardPublishPlan,
  buildEventIntakeDashboardPublishPlan,
} from "./lib/event_intake_dashboard_publish_core.mjs";

const defaultBridgePath = "admin/src/generated/eventIntakeBridge.json";

if (isMain(import.meta.url)) {
  await main();
}

export async function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);
  if (args.help) {
    printHelp();
    return;
  }

  const bridgePath = args.bridge ?? defaultBridgePath;
  const publishPlan = buildEventIntakeDashboardPublishPlan({
    bridge: readJson(bridgePath),
    bridgePath,
    generatedAt: args.generated_at ?? null,
  });

  if (args.json) {
    console.log(JSON.stringify(publishPlan.summary, null, 2));
  } else {
    printSummary(publishPlan.summary);
  }

  if (args.check) {
    console.log("\nCheck passed. Event Intake bridge is publishable.");
    return;
  }

  if (!args.apply) {
    console.log("\nDry run only. Re-run with --apply to publish dashboard.");
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
    action: "publish event intake dashboard",
  });
  applyFirestoreEmulatorHost(args.emulatorHost);

  const requireFromFunctions = createFunctionsRequire();
  const admin = requireFromFunctions("firebase-admin");
  admin.initializeApp({projectId});
  const result = await applyEventIntakeDashboardPublishPlan(
    admin.firestore(),
    publishPlan,
    {serverTimestamp: admin.firestore.FieldValue.serverTimestamp()}
  );
  console.log(`\nPublished ${result.targetPath} in ${projectId}.`);
}

function parseArgs(argv) {
  return parseCommonArgs(argv, {
    booleanFlags: ["--check"],
    valueFlags: ["--bridge", "--generated-at"],
  });
}

function readJson(relativePath) {
  return JSON.parse(fs.readFileSync(fromRepo(relativePath), "utf8"));
}

function printSummary(summary) {
  console.log("Event Intake dashboard publish plan");
  console.log(`Target: ${summary.targetPath}`);
  console.log(`Generated: ${summary.generatedAt}`);
  console.log(`Bridge: ${summary.sourcePaths.bridge}`);
  console.log(`City: ${summary.city}`);
  console.log(`Week start: ${summary.weekStart ?? "unknown"}`);
  console.log(`Bridge source: ${summary.bridgeSource}`);
  console.log(`Source profiles: ${summary.sourceProfiles}`);
  console.log(`Query templates: ${summary.queryTemplates}`);
  console.log(`Source results: ${summary.sourceResults}`);
  console.log(`Event candidates: ${summary.eventCandidates}`);
  console.log(`Dedupe groups: ${summary.dedupeGroups}`);
}

function printHelp() {
  console.log(`Usage: node tool/marketing/event_guide/publish_event_intake_dashboard.mjs [options]

Publishes the generated Event Intake bridge to eventIntakeDashboards/current for
the live Intake admin tab. Dry-run by default. This does not write canonical
events, externalEvents/{id}, marketingOpsDashboards/current, or content drafts.

Options:
  --apply                    Write eventIntakeDashboards/current.
  --check                    Validate and print a read-only summary.
  --json                     Print summary as JSON.
  --env <dev|staging|prod>   Resolve project id from .firebaserc.
  --project <id>             Firebase project id.
  --emulator                 Use Firestore emulator at 127.0.0.1:8080.
  --emulator-host <host>     Use a custom Firestore emulator host.
  --allow-prod               Required with --apply against prod.
  --confirm-prod             Alias for --allow-prod.
  --bridge <file>            Generated Event Intake bridge JSON.
  --generated-at <iso>       Override dashboard generatedAt timestamp.
  -h, --help                 Show this help.
`);
}
