import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {
  adminReviewBridgeChannels,
  checkAdminReviewBridge,
} from "./check_admin_review_bridge.mjs";

const adminApiPath = "admin/src/shared/api/adminApi.ts";
const adminBridgePath =
  "admin/src/features/intake/organizer/generated/organizerIntakeBridge.json";
const adminControllerPath =
  "admin/src/features/intake/organizer/controllers/useOrganizerIntakeController.ts";
const adminScreenPath =
  "admin/src/features/intake/organizer/ui/OrganizerIntakeScreen.tsx";
const adminDiagnosticsPath =
  "admin/src/features/intake/organizer/ui/organizerIntakeDiagnostics.tsx";
const adminDiscoveryPanelsPath =
  "admin/src/features/intake/organizer/ui/organizerIntakeDiscoveryPanels.tsx";
const adminEvidencePanelsPath =
  "admin/src/features/intake/organizer/ui/organizerIntakeEvidencePanels.tsx";
const adminTypesPath = "admin/src/shared/types/adminTypes.ts";

test("checkAdminReviewBridge passes for the current organizer review channels", () => {
  const result = checkAdminReviewBridge();
  const generatedRequest = JSON.parse(fs.readFileSync(
    "tool/organizer_intake/generated/organizer_pending_input_request.json",
    "utf8"
  ));
  const generatedCoverage = JSON.parse(fs.readFileSync(
    "tool/organizer_intake/generated/organizer_pending_work_coverage.json",
    "utf8"
  ));
  const generatedReviewedPackets = JSON.parse(fs.readFileSync(
    "tool/organizer_intake/generated/organizer_reviewed_decision_answer_packets.json",
    "utf8"
  ));
  const generatedPromotion = JSON.parse(fs.readFileSync(
    "tool/organizer_intake/generated/organizer_promotion_execution_packet.json",
    "utf8"
  ));

  assert.equal(result.ok, true);
  assert.deepEqual(result.errors, []);
  assert.equal(result.summary.channels, 5);
  assert.equal(
    result.summary.pendingInputRequests,
    generatedRequest.summary.requests
  );
  assert.equal(
    result.summary.pendingInputFollowUps,
    generatedRequest.summary.workflowFollowUps
  );
  assert.equal(
    result.summary.pendingInputCallableSubmissions,
    generatedRequest.requests.filter((request) =>
      request.callableSubmission
    ).length
  );
  assert.equal(
    result.summary.pendingWorkCovered,
    generatedCoverage.summary.coveredWorkstreams
  );
  assert.equal(
    result.summary.pendingWorkUntriaged,
    generatedCoverage.summary.untriagedWorkstreams
  );
  assert.equal(
    result.summary.reviewedAnswerPacketStatus,
    generatedReviewedPackets.summary.status
  );
  assert.equal(
    result.summary.reviewedAnswerPackets,
    generatedReviewedPackets.summary.packets
  );
  assert.equal(
    result.summary.reviewedAnswerPacketsReady,
    generatedReviewedPackets.summary.readyToApply
  );
  assert.equal(
    result.summary.reviewedAnswerPacketsStale,
    generatedReviewedPackets.summary.stale
  );
  assert.equal(
    result.summary.promotionExecutionStatus,
    generatedPromotion.summary.status
  );
  assert.equal(
    result.summary.promotionExecutionPhases,
    generatedPromotion.summary.phases
  );
  assert.equal(
    result.summary.promotionExecutionBlockedPhases,
    generatedPromotion.summary.blockedPhases
  );
  assert.deepEqual(
    result.channels.map((channel) => channel.id),
    [
      "organizer_publication",
      "organizer_curation",
      "external_event_candidate_review",
      "external_event_location_resolution",
      "organizer_policy_gap_review",
    ]
  );
});

test("checkAdminReviewBridge rejects a removed React Query mutation action", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-bridge-"));
  mirrorRequiredFiles(root);

  const controllerPath = path.join(root, adminControllerPath);
  fs.writeFileSync(
    controllerPath,
    fs.readFileSync(controllerPath, "utf8")
      .replaceAll(
        "mutationFn: decideOrganizerIntake",
        "mutationFn: removedOrganizerIntake"
      )
  );

  const result = checkAdminReviewBridge({
    root,
    channels: [adminReviewBridgeChannels[0]],
  });

  assert.equal(result.ok, false);
  assert.match(result.errors.join("\n"), /admin UI action/);
});

test("checkAdminReviewBridge fails when pending input callable payloads drift", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-bridge-"));
  mirrorRequiredFiles(root);

  const bridgePath = path.join(root, adminBridgePath);
  const bridge = JSON.parse(fs.readFileSync(bridgePath, "utf8"));
  const request = bridge.pendingInputRequest.requests.find((item) =>
    item.callableSubmission
  );
  const decision = request.decisionOptions[0];
  delete request.callableSubmission.payloadsByDecision[decision].checklist;
  fs.writeFileSync(bridgePath, JSON.stringify(bridge, null, 2));

  const result = checkAdminReviewBridge({
    root,
    channels: [adminReviewBridgeChannels[0]],
  });

  assert.equal(result.ok, false);
  assert.match(
    result.errors.join("\n"),
    /checklist missing/
  );
});

test("checkAdminReviewBridge fails when embedded pending input drifts", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-bridge-"));
  mirrorRequiredFiles(root);

  const bridgePath = path.join(root, adminBridgePath);
  const bridge = JSON.parse(fs.readFileSync(bridgePath, "utf8"));
  bridge.pendingInputRequest.requests[0].prompt =
    `${bridge.pendingInputRequest.requests[0].prompt} drift`;
  fs.writeFileSync(bridgePath, JSON.stringify(bridge, null, 2));

  const result = checkAdminReviewBridge({
    root,
    channels: [adminReviewBridgeChannels[0]],
  });

  assert.equal(result.ok, false);
  assert.match(
    result.errors.join("\n"),
    /embedded request does not match generated request/
  );
});

test("checkAdminReviewBridge fails when embedded pending work coverage drifts", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-bridge-"));
  mirrorRequiredFiles(root);

  const bridgePath = path.join(root, adminBridgePath);
  const bridge = JSON.parse(fs.readFileSync(bridgePath, "utf8"));
  bridge.pendingWorkCoverage.entries[0].coverageStatus = "stale";
  fs.writeFileSync(bridgePath, JSON.stringify(bridge, null, 2));

  const result = checkAdminReviewBridge({
    root,
    channels: [adminReviewBridgeChannels[0]],
  });

  assert.equal(result.ok, false);
  assert.match(
    result.errors.join("\n"),
    /embedded coverage does not match generated coverage/
  );
});

test("checkAdminReviewBridge fails when embedded reviewed answer packets drift", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-bridge-"));
  mirrorRequiredFiles(root);

  const bridgePath = path.join(root, adminBridgePath);
  const bridge = JSON.parse(fs.readFileSync(bridgePath, "utf8"));
  bridge.reviewedDecisionAnswerPackets.summary.packets += 1;
  fs.writeFileSync(bridgePath, JSON.stringify(bridge, null, 2));

  const result = checkAdminReviewBridge({
    root,
    channels: [adminReviewBridgeChannels[0]],
  });

  assert.equal(result.ok, false);
  assert.match(
    result.errors.join("\n"),
    /reviewed-answer-packets: embedded register does not match generated register/
  );
});

test("checkAdminReviewBridge fails when embedded promotion execution drifts", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-bridge-"));
  mirrorRequiredFiles(root);

  const bridgePath = path.join(root, adminBridgePath);
  const bridge = JSON.parse(fs.readFileSync(bridgePath, "utf8"));
  bridge.promotionExecutionPacket.summary.phases += 1;
  fs.writeFileSync(bridgePath, JSON.stringify(bridge, null, 2));

  const result = checkAdminReviewBridge({
    root,
    channels: [adminReviewBridgeChannels[0]],
  });

  assert.equal(result.ok, false);
  assert.match(
    result.errors.join("\n"),
    /promotion-execution: embedded packet does not match generated packet/
  );
});

test("checkAdminReviewBridge fails when exact embedded artifacts drift", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-bridge-"));
  mirrorRequiredFiles(root);

  const bridgePath = path.join(root, adminBridgePath);
  const bridge = JSON.parse(fs.readFileSync(bridgePath, "utf8"));
  bridge.operatorActionQueue.summary.actions += 1;
  fs.writeFileSync(bridgePath, JSON.stringify(bridge, null, 2));

  const result = checkAdminReviewBridge({
    root,
    channels: [adminReviewBridgeChannels[0]],
  });

  assert.equal(result.ok, false);
  assert.match(
    result.errors.join("\n"),
    /embedded-generated:operatorActionQueue/
  );
});

test("checkAdminReviewBridge fails when nested source mention artifacts drift", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-bridge-"));
  mirrorRequiredFiles(root);

  const bridgePath = path.join(root, adminBridgePath);
  const bridge = JSON.parse(fs.readFileSync(bridgePath, "utf8"));
  bridge.sourceMentionResolution.resolutionClusters.summary.clusters += 1;
  fs.writeFileSync(bridgePath, JSON.stringify(bridge, null, 2));

  const result = checkAdminReviewBridge({
    root,
    channels: [adminReviewBridgeChannels[0]],
  });

  assert.equal(result.ok, false);
  assert.match(
    result.errors.join("\n"),
    /embedded-generated:sourceMentionResolution\.resolutionClusters/
  );
});

test("checkAdminReviewBridge fails when source mention review packets are not visible", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-bridge-"));
  mirrorRequiredFiles(root);

  const appPath = path.join(root, adminDiscoveryPanelsPath);
  fs.writeFileSync(
    appPath,
    fs.readFileSync(appPath, "utf8")
      .replaceAll("Resolution review packets", "Removed source packets")
  );

  const result = checkAdminReviewBridge({
    root,
    channels: [adminReviewBridgeChannels[0]],
  });

  assert.equal(result.ok, false);
  assert.match(
    result.errors.join("\n"),
    /source-mention-resolution: review packet UI/
  );
});

test("checkAdminReviewBridge fails when reviewed answer packets are not visible", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-bridge-"));
  mirrorRequiredFiles(root);

  const appPath = path.join(root, adminDiagnosticsPath);
  fs.writeFileSync(
    appPath,
    fs.readFileSync(appPath, "utf8")
      .replaceAll(
        "OrganizerReviewedDecisionAnswerPacketsView",
        "RemovedReviewedPacketsView"
      )
  );

  const result = checkAdminReviewBridge({
    root,
    channels: [adminReviewBridgeChannels[0]],
  });

  assert.equal(result.ok, false);
  assert.match(
    result.errors.join("\n"),
    /reviewed-answer-packets: admin UI view/
  );
});

test("checkAdminReviewBridge fails when promotion execution is not visible", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-bridge-"));
  mirrorRequiredFiles(root);

  const appPath = path.join(root, adminDiagnosticsPath);
  fs.writeFileSync(
    appPath,
    fs.readFileSync(appPath, "utf8")
      .replaceAll("OrganizerPromotionExecutionView", "RemovedPromotionView")
  );

  const result = checkAdminReviewBridge({
    root,
    channels: [adminReviewBridgeChannels[0]],
  });

  assert.equal(result.ok, false);
  assert.match(result.errors.join("\n"), /promotion-execution: admin UI view/);
});

test("checkAdminReviewBridge fails when pending work coverage is not visible", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-bridge-"));
  mirrorRequiredFiles(root);

  const appPath = path.join(root, adminDiagnosticsPath);
  fs.writeFileSync(
    appPath,
    fs.readFileSync(appPath, "utf8")
      .replaceAll("OrganizerPendingWorkCoverageView", "RemovedCoverageView")
  );

  const result = checkAdminReviewBridge({
    root,
    channels: [adminReviewBridgeChannels[0]],
  });

  assert.equal(result.ok, false);
  assert.match(result.errors.join("\n"), /pending-work-coverage: admin UI view/);
});

test("checkAdminReviewBridge fails when pending input actions are not wired", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-bridge-"));
  mirrorRequiredFiles(root);

  const appPath = path.join(root, adminControllerPath);
  fs.writeFileSync(
    appPath,
    fs.readFileSync(appPath, "utf8")
      .replaceAll("handlePendingInputDecision", "removedPendingInputDecision")
  );

  const result = checkAdminReviewBridge({
    root,
    channels: [adminReviewBridgeChannels[0]],
  });

  assert.equal(result.ok, false);
  assert.match(result.errors.join("\n"), /admin UI decision handler/);
});

test("checkAdminReviewBridge fails when item decision commands drift", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-bridge-"));
  mirrorRequiredFiles(root);

  const bridgePath = path.join(root, adminBridgePath);
  const bridge = JSON.parse(fs.readFileSync(bridgePath, "utf8"));
  const afterfly = bridge.items.find((item) => item.entityId === "afterfly");
  afterfly.decisionCommands.approvePublic =
    afterfly.decisionCommands.approvePublic.replace(
      " --confirm-manual-reports-reviewed",
      ""
    );
  fs.writeFileSync(bridgePath, JSON.stringify(bridge, null, 2));

  const result = checkAdminReviewBridge({
    root,
    channels: [adminReviewBridgeChannels[0]],
  });

  assert.equal(result.ok, false);
  assert.match(
    result.errors.join("\n"),
    /approvePublic must acknowledge manual reports/
  );
});

test("checkAdminReviewBridge fails when a channel is missing its pipeline flag", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-bridge-"));
  mirrorRequiredFiles(root);

  const pipelinePath = path.join(
    root,
    "tool/organizer_intake/run_promotion_pipeline.mjs"
  );
  fs.writeFileSync(
    pipelinePath,
    fs.readFileSync(pipelinePath, "utf8")
      .replaceAll("--export-review-decisions", "--removed-review-decisions")
  );

  const result = checkAdminReviewBridge({
    root,
    channels: [adminReviewBridgeChannels[0]],
  });

  assert.equal(result.ok, false);
  assert.match(result.errors.join("\n"), /pipeline export flag/);
});

function mirrorRequiredFiles(root) {
  const files = new Set([
    adminApiPath,
    adminBridgePath,
    adminControllerPath,
    adminScreenPath,
    adminDiagnosticsPath,
    adminDiscoveryPanelsPath,
    adminEvidencePanelsPath,
    adminTypesPath,
    "functions/src/index.ts",
    "tool/organizer_intake/README.md",
    "tool/organizer_intake/generated/organizer_pending_input_request.json",
    "tool/organizer_intake/generated/organizer_pending_work_coverage.json",
    "tool/organizer_intake/generated/organizer_reviewed_decision_answer_packets.json",
    "tool/organizer_intake/pending_input_request.mjs",
    "tool/organizer_intake/pending_work_coverage.mjs",
    "tool/organizer_intake/reviewed_decision_answer_packets.mjs",
    "tool/organizer_intake/promotion_execution_packet.mjs",
    "tool/organizer_intake/run_promotion_pipeline.mjs",
    "tool/tools_manifest.json",
    "tool/remote_ops_manifest.json",
  ]);
  const bridge = JSON.parse(
    fs.readFileSync(
      path.resolve(adminBridgePath),
      "utf8"
    )
  );
  for (const file of Object.values(bridge.generatedFrom ?? {})) {
    if (typeof file === "string") files.add(file);
  }
  for (const channel of adminReviewBridgeChannels) {
    files.add(channel.handlerFile);
    files.add(channel.handlerTest);
    files.add(channel.payloadSchema);
    files.add(channel.firestoreSchema);
    files.add(channel.generatedPayload);
    files.add(channel.generatedDocument);
    files.add(channel.exporter);
    files.add(channel.exporterTest);
    files.add(channel.localDecisionRoot);
    if (channel.localDecisionCli) files.add(channel.localDecisionCli);
  }

  for (const file of files) {
    const source = path.resolve(file);
    const destination = path.join(root, file);
    fs.mkdirSync(path.dirname(destination), {recursive: true});
    if (fs.statSync(source).isDirectory()) {
      fs.mkdirSync(destination, {recursive: true});
    } else {
      fs.copyFileSync(source, destination);
    }
  }
}
