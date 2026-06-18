import assert from "node:assert/strict";
import test from "node:test";
import {buildSteps, parseArgs} from "./run_promotion_pipeline.mjs";

test("buildSteps defaults to local generation, bridge validation, and fixture claim preview", () => {
  const steps = buildSteps({
    claimSync: "fixture",
    fixture: "/tmp/existing_clubs.empty.json",
  });

  assert.deepEqual(steps.map((step) => step.label), [
    "generate search-result candidate queue",
    "generate external event candidate queue",
    "plan external event location resolution",
    "plan external event imports",
    "preflight external event imports",
    "generate organizer intake artifacts",
    "generate website organizer listings",
    "validate admin review bridge",
    "validate promotion bridge",
    "build marketing website",
    "preview claim-target sync against empty fixture",
  ]);
  assert.deepEqual(steps[9].command, [
    "npm",
    "--workspace",
    "catch-marketing",
    "run",
    "build",
  ]);
  assert.deepEqual(steps[10].command.slice(1), [
    "tool/organizer_intake/sync_claim_targets_to_firestore.mjs",
    "--fixture",
    "/tmp/existing_clubs.empty.json",
  ]);
});

test("buildSteps can skip website build for focused local debugging", () => {
  const steps = buildSteps({
    claimSync: "none",
    fixture: "/tmp/existing_clubs.empty.json",
    skipWebsiteBuild: true,
  });

  assert.equal(
    steps.some((step) => step.label === "build marketing website"),
    false
  );
  assert.equal(
    steps.some((step) => step.label.includes("claim-target sync")),
    false
  );
});

test("buildSteps can apply reviewed decision answers before local generation", () => {
  const steps = buildSteps({
    allowPartialDecisionAnswers: false,
    answerPacket: "/tmp/reviewed-answer-packet.json",
    applyDecisionAnswers: true,
    claimSync: "none",
    fixture: "/tmp/existing_clubs.empty.json",
    skipWebsiteBuild: true,
    writeDecisionAnswers: true,
  });

  assert.equal(steps[0].label, "validate reviewed decision answer packet");
  assert.deepEqual(steps[0].command.slice(1), [
    "tool/organizer_intake/reviewed_decision_answer_packets.mjs",
    "--check",
    "--require-ready",
    "--packet",
    "/tmp/reviewed-answer-packet.json",
  ]);
  assert.equal(steps[1].label, "apply answered decision packet");
  assert.deepEqual(steps[1].command.slice(1), [
    "tool/organizer_intake/apply_pending_decision_answers.mjs",
    "--packet",
    "/tmp/reviewed-answer-packet.json",
    "--write",
  ]);
  assert.equal(steps[2].label, "generate search-result candidate queue");
});

test("buildSteps can dry-run a partial generated decision-answer packet", () => {
  const steps = buildSteps({
    allowPartialDecisionAnswers: true,
    allowStaleDecisionAnswerSource: true,
    answerPacket: "/tmp/generated-answer-packet.json",
    applyDecisionAnswers: true,
    claimSync: "none",
    fixture: "/tmp/existing_clubs.empty.json",
    skipWebsiteBuild: true,
    writeDecisionAnswers: false,
  });

  assert.equal(steps[0].label, "dry-run answered decision packet");
  assert.deepEqual(steps[0].command.slice(1), [
    "tool/organizer_intake/apply_pending_decision_answers.mjs",
    "--packet",
    "/tmp/generated-answer-packet.json",
    "--allow-partial",
    "--allow-stale-source",
  ]);
});

test("parseArgs guards local decision-answer writes", () => {
  assert.throws(
    () => parseArgs(["--write-decision-answers"]),
    /--write-decision-answers requires --apply-decision-answers/
  );
  assert.throws(
    () => parseArgs([
      "--apply-decision-answers",
      "--write-decision-answers",
    ]),
    /--write-decision-answers requires --answer-packet/
  );
  assert.throws(
    () => parseArgs([
      "--apply-decision-answers",
      "--export-review-decisions",
    ]),
    /cannot be combined/
  );
  assert.throws(
    () => parseArgs(["--allow-stale-decision-answer-source"]),
    /--allow-stale-decision-answer-source requires --apply-decision-answers/
  );
});

test("buildSteps can prepend export and target Firestore claim writes explicitly", () => {
  const steps = buildSteps({
    allowEmptyExport: true,
    allowOverwriteExport: true,
    allowProd: false,
    claimSync: "firestore",
    confirmProd: true,
    date: "2026-06-17",
    emulator: false,
    env: "prod",
    exportCurationDecisions: true,
    exportEventLocationResolutions: true,
    exportEventReviewDecisions: true,
    exportPolicyGapDecisions: true,
    exportReviewDecisions: true,
    project: null,
    writeClaimTargets: true,
    writeExport: true,
  });

  assert.equal(steps[0].label, "export curation decisions");
  assert.deepEqual(steps[0].command.slice(1), [
    "tool/organizer_intake/export_curation_decisions_from_firestore.mjs",
    "--date",
    "2026-06-17",
    "--env",
    "prod",
    "--write",
    "--allow-empty",
    "--allow-overwrite",
  ]);
  assert.equal(steps[1].label, "export review decisions");
  assert.deepEqual(steps[1].command.slice(1), [
    "tool/organizer_intake/export_review_decisions_from_firestore.mjs",
    "--date",
    "2026-06-17",
    "--env",
    "prod",
    "--write",
    "--allow-empty",
    "--allow-overwrite",
  ]);
  assert.equal(steps[2].label, "export event review decisions");
  assert.deepEqual(steps[2].command.slice(1), [
    "tool/organizer_intake/export_event_review_decisions_from_firestore.mjs",
    "--date",
    "2026-06-17",
    "--env",
    "prod",
    "--write",
    "--allow-empty",
    "--allow-overwrite",
  ]);
  assert.equal(steps[3].label, "export event location resolutions");
  assert.deepEqual(steps[3].command.slice(1), [
    "tool/organizer_intake/export_event_location_resolutions_from_firestore.mjs",
    "--date",
    "2026-06-17",
    "--env",
    "prod",
    "--write",
    "--allow-empty",
    "--allow-overwrite",
  ]);
  assert.equal(steps[4].label, "export policy gap decisions");
  assert.deepEqual(steps[4].command.slice(1), [
    "tool/organizer_intake/export_policy_gap_decisions_from_firestore.mjs",
    "--date",
    "2026-06-17",
    "--env",
    "prod",
    "--write",
    "--allow-empty",
    "--allow-overwrite",
  ]);
  assert.equal(steps.at(-1).label, "preview claim-target sync against Firestore");
  assert.deepEqual(steps.at(-1).command.slice(1), [
    "tool/organizer_intake/sync_claim_targets_to_firestore.mjs",
    "--env",
    "prod",
    "--write",
    "--confirm-prod",
  ]);
});
