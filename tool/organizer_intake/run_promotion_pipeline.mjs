#!/usr/bin/env node
import {spawnSync} from "node:child_process";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {fromRepo, repoRoot, relativeToRepo} from "../lib/repo_paths.mjs";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const defaultFixture = fromRepo(
  "tool/organizer_intake/fixtures/existing_club_docs.empty.json"
);
const defaultAnswerPacket = fromRepo(
  "tool/organizer_intake/generated/organizer_pending_decision_answer_packet.json"
);
const defaultClaimReadinessReceipt = path.join(
  "/tmp",
  "catch-organizer-claim-target-readiness.json"
);

if (isMain()) {
  try {
    main();
  } catch (error) {
    console.error(error instanceof Error ? error.message : String(error));
    process.exit(64);
  }
}

export function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);
  if (args.help) {
    printHelp();
    return;
  }

  const steps = buildSteps(args);
  const results = [];
  for (const step of steps) {
    if (!args.json) console.log(`==> ${step.label}: ${step.command.join(" ")}`);
    const result = spawnSync(step.command[0], step.command.slice(1), {
      cwd: repoRoot,
      encoding: "utf8",
      stdio: args.json ? "pipe" : "inherit",
    });
    results.push({
      label: step.label,
      command: step.command,
      status: result.status ?? 1,
      stdout: result.stdout ?? "",
      stderr: result.stderr ?? "",
    });
    if ((result.status ?? 1) !== 0) {
      if (args.json) {
        console.log(JSON.stringify({
          ok: false,
          failedStep: step.label,
          results,
        }, null, 2));
      }
      process.exit(result.status ?? 1);
    }
  }

  if (args.json) {
    console.log(JSON.stringify({ok: true, results}, null, 2));
  } else {
    console.log("Organizer promotion pipeline completed.");
  }
}

export function buildSteps(args) {
  const steps = [];
  if (args.exportCurationDecisions) {
    if (!args.date) {
      throw new Error("--date YYYY-MM-DD is required with --export-curation-decisions.");
    }
    steps.push({
      label: "export curation decisions",
      command: compact([
        process.execPath,
        "tool/organizer_intake/export_curation_decisions_from_firestore.mjs",
        "--date",
        args.date,
        args.env ? "--env" : null,
        args.env,
        args.project ? "--project" : null,
        args.project,
        args.emulator ? "--emulator" : null,
        args.writeExport ? "--write" : null,
        args.allowEmptyExport ? "--allow-empty" : null,
        args.allowOverwriteExport ? "--allow-overwrite" : null,
      ]),
    });
  }

  if (args.exportReviewDecisions) {
    if (!args.date) {
      throw new Error("--date YYYY-MM-DD is required with --export-review-decisions.");
    }
    steps.push({
      label: "export review decisions",
      command: compact([
        process.execPath,
        "tool/organizer_intake/export_review_decisions_from_firestore.mjs",
        "--date",
        args.date,
        args.env ? "--env" : null,
        args.env,
        args.project ? "--project" : null,
        args.project,
        args.emulator ? "--emulator" : null,
        args.writeExport ? "--write" : null,
        args.allowEmptyExport ? "--allow-empty" : null,
        args.allowOverwriteExport ? "--allow-overwrite" : null,
      ]),
    });
  }

  if (args.exportEventReviewDecisions) {
    if (!args.date) {
      throw new Error("--date YYYY-MM-DD is required with --export-event-review-decisions.");
    }
    steps.push({
      label: "export event review decisions",
      command: compact([
        process.execPath,
        "tool/organizer_intake/export_event_review_decisions_from_firestore.mjs",
        "--date",
        args.date,
        args.env ? "--env" : null,
        args.env,
        args.project ? "--project" : null,
        args.project,
        args.emulator ? "--emulator" : null,
        args.writeExport ? "--write" : null,
        args.allowEmptyExport ? "--allow-empty" : null,
        args.allowOverwriteExport ? "--allow-overwrite" : null,
      ]),
    });
  }

  if (args.exportEventLocationResolutions) {
    if (!args.date) {
      throw new Error("--date YYYY-MM-DD is required with --export-event-location-resolutions.");
    }
    steps.push({
      label: "export event location resolutions",
      command: compact([
        process.execPath,
        "tool/organizer_intake/export_event_location_resolutions_from_firestore.mjs",
        "--date",
        args.date,
        args.env ? "--env" : null,
        args.env,
        args.project ? "--project" : null,
        args.project,
        args.emulator ? "--emulator" : null,
        args.writeExport ? "--write" : null,
        args.allowEmptyExport ? "--allow-empty" : null,
        args.allowOverwriteExport ? "--allow-overwrite" : null,
      ]),
    });
  }

  if (args.exportPolicyGapDecisions) {
    if (!args.date) {
      throw new Error("--date YYYY-MM-DD is required with --export-policy-gap-decisions.");
    }
    steps.push({
      label: "export policy gap decisions",
      command: compact([
        process.execPath,
        "tool/organizer_intake/export_policy_gap_decisions_from_firestore.mjs",
        "--date",
        args.date,
        args.env ? "--env" : null,
        args.env,
        args.project ? "--project" : null,
        args.project,
        args.emulator ? "--emulator" : null,
        args.writeExport ? "--write" : null,
        args.allowEmptyExport ? "--allow-empty" : null,
        args.allowOverwriteExport ? "--allow-overwrite" : null,
      ]),
    });
  }

  if (args.applyDecisionAnswers) {
    if (args.writeDecisionAnswers) {
      steps.push({
        label: "validate reviewed decision answer packet",
        command: compact([
          process.execPath,
          "tool/organizer_intake/reviewed_decision_answer_packets.mjs",
          "--check",
          "--require-ready",
          "--packet",
          args.answerPacket,
          args.allowStaleDecisionAnswerSource ? "--allow-stale-source" : null,
        ]),
      });
    }
    steps.push({
      label: args.writeDecisionAnswers ?
        "apply answered decision packet" :
        "dry-run answered decision packet",
      command: compact([
        process.execPath,
        "tool/organizer_intake/apply_pending_decision_answers.mjs",
        "--packet",
        args.answerPacket,
        args.allowPartialDecisionAnswers ? "--allow-partial" : null,
        args.allowStaleDecisionAnswerSource ? "--allow-stale-source" : null,
        args.writeDecisionAnswers ? "--write" : null,
      ]),
    });
  }

  steps.push({
    label: "generate search-result candidate queue",
    command: [process.execPath, "tool/organizer_intake/ingest_search_results.mjs"],
  });
  steps.push({
    label: "generate external event candidate queue",
    command: [process.execPath, "tool/organizer_intake/ingest_event_sources.mjs"],
  });
  steps.push({
    label: "plan external event location resolution",
    command: [
      process.execPath,
      "tool/organizer_intake/plan_event_location_resolution.mjs",
    ],
  });
  steps.push({
    label: "plan external event imports",
    command: [
      process.execPath,
      "tool/organizer_intake/plan_external_event_imports.mjs",
    ],
  });
  steps.push({
    label: "preflight external event imports",
    command: [
      process.execPath,
      "tool/organizer_intake/preflight_external_event_imports.mjs",
    ],
  });
  steps.push({
    label: "generate organizer intake artifacts",
    command: [process.execPath, "tool/organizer_intake/organizer_intake.mjs"],
  });

  if (args.claimSync === "firestore") {
    steps.push(claimSyncStep(args, {
      receipt: args.claimReadinessReceipt ?? defaultClaimReadinessReceipt,
    }));
  }

  steps.push({
    label: "generate website organizer listings",
    command: args.claimSync === "firestore" ? [
      process.execPath,
      "website/scripts/generateOrganizerListings.mjs",
      "--claim-target-readiness-receipt",
      args.claimReadinessReceipt ?? defaultClaimReadinessReceipt,
    ] : [
      "npm",
      "--workspace",
      "catch-marketing",
      "run",
      "generate:organizer-listings",
    ],
  });
  steps.push({
    label: "validate admin review bridge",
    command: [process.execPath, "tool/organizer_intake/check_admin_review_bridge.mjs"],
  });
  steps.push({
    label: "validate promotion bridge",
    command: [process.execPath, "tool/organizer_intake/check_promotion_bridge.mjs"],
  });

  if (!args.skipWebsiteBuild) {
    steps.push({
      label: "build marketing website",
      command: ["npm", "--workspace", "catch-marketing", "run", "build"],
    });
  }

  if (args.claimSync === "fixture") {
    steps.push(claimSyncStep(args));
  }

  return steps;
}

function claimSyncStep(args, {receipt = null} = {}) {
  const command = [
    process.execPath,
    "tool/organizer_intake/sync_claim_targets_to_firestore.mjs",
  ];
  if (args.claimSync === "fixture") {
    command.push("--fixture", args.fixture);
  } else {
    if (args.env) command.push("--env", args.env);
    if (args.project) command.push("--project", args.project);
    if (args.emulator) command.push("--emulator");
    if (args.writeClaimTargets) command.push("--write");
    if (args.allowProd) command.push("--allow-prod");
    if (args.confirmProd) command.push("--confirm-prod");
    if (receipt) command.push("--receipt", receipt);
  }
  return {
    label: args.claimSync === "fixture" ?
      "preview claim-target sync against empty fixture" :
      "verify claim targets against Firestore",
    command,
  };
}

export function parseArgs(argv) {
  const parsed = {
    allowEmptyExport: false,
    allowOverwriteExport: false,
    allowProd: false,
    allowPartialDecisionAnswers: false,
    allowStaleDecisionAnswerSource: false,
    answerPacket: defaultAnswerPacket,
    applyDecisionAnswers: false,
    claimSync: "fixture",
    claimReadinessReceipt: defaultClaimReadinessReceipt,
    confirmProd: false,
    date: null,
    emulator: false,
    env: null,
    exportCurationDecisions: false,
    exportEventReviewDecisions: false,
    exportEventLocationResolutions: false,
    exportPolicyGapDecisions: false,
    exportReviewDecisions: false,
    fixture: defaultFixture,
    help: false,
    json: false,
    project: null,
    skipWebsiteBuild: false,
    writeDecisionAnswers: false,
    writeClaimTargets: false,
    writeExport: false,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--allow-empty-export") parsed.allowEmptyExport = true;
    else if (arg === "--allow-overwrite-export") parsed.allowOverwriteExport = true;
    else if (arg === "--allow-partial-decision-answers") parsed.allowPartialDecisionAnswers = true;
    else if (arg === "--allow-prod") parsed.allowProd = true;
    else if (arg === "--allow-stale-decision-answer-source") parsed.allowStaleDecisionAnswerSource = true;
    else if (arg === "--apply-decision-answers") parsed.applyDecisionAnswers = true;
    else if (arg === "--confirm-prod") parsed.confirmProd = true;
    else if (arg === "--emulator") parsed.emulator = true;
    else if (arg === "--export-curation-decisions") parsed.exportCurationDecisions = true;
    else if (arg === "--export-event-review-decisions") parsed.exportEventReviewDecisions = true;
    else if (arg === "--export-event-location-resolutions") parsed.exportEventLocationResolutions = true;
    else if (arg === "--export-policy-gap-decisions") parsed.exportPolicyGapDecisions = true;
    else if (arg === "--export-review-decisions") parsed.exportReviewDecisions = true;
    else if (arg === "--json") parsed.json = true;
    else if (arg === "--skip-website-build") parsed.skipWebsiteBuild = true;
    else if (arg === "--write-decision-answers") parsed.writeDecisionAnswers = true;
    else if (arg === "--write-claim-targets") parsed.writeClaimTargets = true;
    else if (arg === "--write-export") parsed.writeExport = true;
    else if (arg === "--claim-sync") {
      parsed.claimSync = requiredValue(argv, ++index, arg);
      if (!["fixture", "firestore", "none"].includes(parsed.claimSync)) {
        throw new Error("--claim-sync must be fixture, firestore, or none.");
      }
    } else if (arg === "--claim-readiness-receipt") {
      parsed.claimReadinessReceipt = path.resolve(requiredValue(argv, ++index, arg));
    } else if (arg === "--date") parsed.date = requiredValue(argv, ++index, arg);
    else if (arg === "--answer-packet") {
      parsed.answerPacket = path.resolve(requiredValue(argv, ++index, arg));
    }
    else if (arg === "--env") parsed.env = requiredValue(argv, ++index, arg);
    else if (arg === "--fixture") parsed.fixture = path.resolve(requiredValue(argv, ++index, arg));
    else if (arg === "--project") parsed.project = requiredValue(argv, ++index, arg);
    else throw new Error(`Unknown argument: ${arg}`);
  }

  if (parsed.writeClaimTargets && parsed.claimSync !== "firestore") {
    throw new Error("--write-claim-targets requires --claim-sync firestore.");
  }
  if (parsed.writeDecisionAnswers && !parsed.applyDecisionAnswers) {
    throw new Error("--write-decision-answers requires --apply-decision-answers.");
  }
  if (parsed.allowPartialDecisionAnswers && !parsed.applyDecisionAnswers) {
    throw new Error("--allow-partial-decision-answers requires --apply-decision-answers.");
  }
  if (parsed.allowStaleDecisionAnswerSource && !parsed.applyDecisionAnswers) {
    throw new Error("--allow-stale-decision-answer-source requires --apply-decision-answers.");
  }
  if (parsed.answerPacket !== defaultAnswerPacket && !parsed.applyDecisionAnswers) {
    throw new Error("--answer-packet requires --apply-decision-answers.");
  }
  if (parsed.applyDecisionAnswers &&
    (parsed.exportReviewDecisions || parsed.exportPolicyGapDecisions)) {
    throw new Error(
      "--apply-decision-answers cannot be combined with review or policy decision export flags."
    );
  }
  if (parsed.writeDecisionAnswers && parsed.answerPacket === defaultAnswerPacket) {
    throw new Error("--write-decision-answers requires --answer-packet <reviewed-copy>.");
  }
  if (parsed.writeExport &&
    !parsed.exportReviewDecisions &&
    !parsed.exportCurationDecisions &&
    !parsed.exportEventReviewDecisions &&
    !parsed.exportEventLocationResolutions &&
    !parsed.exportPolicyGapDecisions) {
    throw new Error(
      "--write-export requires an export flag."
    );
  }
  if (parsed.date && !/^\d{4}-\d{2}-\d{2}$/.test(parsed.date)) {
    throw new Error("--date must use YYYY-MM-DD.");
  }

  return parsed;
}

function requiredValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) throw new Error(`${flag} requires a value.`);
  return value;
}

function compact(values) {
  return values.filter((value) => value !== null && value !== undefined && value !== "");
}

function printHelp() {
  console.log(`Usage: node tool/organizer_intake/run_promotion_pipeline.mjs [options]

Runs the reviewed organizer promotion pipeline in order:
  1. optional Firestore curation-decision export
  2. optional Firestore review-decision export
  3. optional Firestore event-review-decision export
  4. optional Firestore event-location-resolution export
  5. optional Firestore policy-gap-decision export
  6. optional reviewed answer-packet local decision handoff
  7. search-result candidate queue generation
  8. external event candidate queue generation
  9. organizer intake artifact generation
  10. Firestore claim-target verification and receipt (when selected)
  11. website listing generation from that receipt
  12. admin review bridge validation
  13. promotion bridge validation
  14. marketing website build-output validation
  15. local fixture claim-target preview (default mode)

Default mode is local-only: no remote Firestore read or write.

Options:
  --export-curation-decisions     Export curation decisions before generation.
  --export-review-decisions       Export review decisions before generation.
  --export-event-review-decisions Export event-candidate review decisions.
  --export-event-location-resolutions
                                  Export event location resolutions.
  --export-policy-gap-decisions   Export policy-gap review decisions.
  --apply-decision-answers        Apply a reviewed answer packet before local generation.
  --answer-packet <path>          Reviewed answer packet for --apply-decision-answers.
                                  Default for validation only: ${relativeToRepo(defaultAnswerPacket)}
  --allow-partial-decision-answers
                                  Allow unanswered slots when applying answers.
                                  Intended only for generated-packet validation.
  --allow-stale-decision-answer-source
                                  Override reviewed answer-packet source fingerprint checks.
  --write-decision-answers        Write local decision JSON after dry-run preflight.
                                  Requires --apply-decision-answers and --answer-packet.
  --date YYYY-MM-DD               Required with Firestore export flags.
  --write-export                  Write exported decision batches.
  --allow-empty-export            Allow writing an empty export batch.
  --allow-overwrite-export        Allow exporter to overwrite an existing identical batch.
  --claim-sync fixture|firestore|none
                                   Default: fixture.
  --claim-readiness-receipt <path> Read-only Firestore readiness receipt passed to
                                  website listing generation in firestore mode.
                                  Default: ${defaultClaimReadinessReceipt}
  --fixture <path>                Existing-club fixture for fixture claim-sync mode.
                                  Default: ${relativeToRepo(defaultFixture)}
  --env dev|staging|prod          Firebase env for export or Firestore claim-sync.
  --project <projectId>           Firebase project override.
  --emulator                      Use Firestore emulator for export or Firestore claim-sync.
  --write-claim-targets           Write claim targets. Requires --claim-sync firestore.
  --skip-website-build            Skip marketing website build-output validation.
  --allow-prod                    Allow prod write when write flags are used.
  --confirm-prod                  Alias guard for intentional prod write.
  --json                          Emit machine-readable command results.
`);
}

function isMain() {
  return process.argv[1] &&
    fileURLToPath(import.meta.url) === path.resolve(process.argv[1]);
}
