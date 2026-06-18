import assert from "node:assert/strict";
import {execFileSync} from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {fileURLToPath} from "node:url";

const scriptPath = fileURLToPath(new URL("./organizer_intake.mjs", import.meta.url));
const foundationBatchPath = fileURLToPath(
  new URL("./batches/2026-06-17-foundation.json", import.meta.url)
);

test("approved review decisions create public projections and claim targets", () => {
  const tmpRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-organizer-intake-"));
  const reviewRoot = path.join(tmpRoot, "review_decisions");
  const policyGapRoot = path.join(tmpRoot, "policy_gap_decisions");
  const answerPacketsRoot = path.join(tmpRoot, "answer_packets");
  const generatedRoot = path.join(tmpRoot, "generated");
  const adminGeneratedRoot = path.join(tmpRoot, "admin_generated");
  fs.mkdirSync(reviewRoot, {recursive: true});
  fs.writeFileSync(
    path.join(reviewRoot, "2026-06-17-afterfly-approve-public.json"),
    `${JSON.stringify(approvedAfterflyDecision(), null, 2)}\n`
  );

  execFileSync(process.execPath, [
    scriptPath,
    "--review-decisions-root",
    reviewRoot,
    "--policy-gap-decisions-root",
    policyGapRoot,
    "--answer-packets-root",
    answerPacketsRoot,
    "--generated-root",
    generatedRoot,
    "--admin-generated-root",
    adminGeneratedRoot,
  ], {stdio: "pipe"});

  const projectionPlan = readGenerated(generatedRoot, "public_projection_plan.json");
  const afterflyProjection = projectionPlan.entries.find((entry) =>
    entry.entityId === "afterfly"
  );
  assert.equal(afterflyProjection.projectionStatus, "ready");
  assert.equal(afterflyProjection.publishStatus, "published");
  assert.equal(afterflyProjection.indexStatus, "indexed");
  assert.equal(afterflyProjection.appVisibility, "hidden");
  assert.equal(afterflyProjection.canonicalPath, "/organizers/afterfly/");
  assert.deepEqual(afterflyProjection.legacyPaths, [
    "/organizers/indore/afterfly-run-club/",
  ]);
  assert.equal(afterflyProjection.publicListing.id, "afterfly");
  assert.equal(afterflyProjection.publicListing.path, "/organizers/afterfly/");
  assert.equal(afterflyProjection.publicListing.indexing, "index, follow");
  assert.equal(afterflyProjection.publicListing.status, "unclaimed");
  assert.equal(
    afterflyProjection.publicListing.missingEvidence.includes(
      "Manual admin approval for public publication"
    ),
    false
  );

  const claimTargets = readGenerated(generatedRoot, "organizer_claim_targets.json");
  assert.equal(claimTargets.summary.targets, 1);
  assert.equal(claimTargets.targets[0].entityId, "afterfly");
  assert.equal(claimTargets.targets[0].path, "clubs/afterfly");
  assert.equal(claimTargets.targets[0].appVisibility, "hidden");
  assert.equal(claimTargets.targets[0].claimState, "unclaimed");
  assert.equal(
    claimTargets.targets[0].clubDocument.publicPage.canonicalPath,
    "/organizers/afterfly/"
  );
  assert.equal(
    claimTargets.targets[0].clubDocument.publicProfile.missingEvidence.includes(
      "Manual admin approval for public publication"
    ),
    false
  );
  assert.equal(claimTargets.targets[0].clubDocument.claim.state, "unclaimed");
  assert.equal(
    claimTargets.targets[0].clubDocument.ownership.state,
    "programmatic"
  );
  const claimSyncPreview = readGenerated(
    generatedRoot,
    "organizer_claim_target_sync_preview.json"
  );
  assert.equal(claimSyncPreview.summary.targets, 1);
  assert.equal(claimSyncPreview.summary.creates, 1);
  assert.equal(claimSyncPreview.summary.writesNeeded, 1);
  assert.equal(claimSyncPreview.actions[0].path, "clubs/afterfly");
  assert.equal(claimSyncPreview.actions[0].status, "create");
  assert.equal(claimSyncPreview.mode.remoteWrites, 0);

  const adminBridge = readGenerated(adminGeneratedRoot, "organizerIntakeBridge.json");
  assert.equal(adminBridge.summary.approvedPublic, 1);
  assert.equal(adminBridge.summary.claimTargets, 1);
  assert.equal(adminBridge.summary.claimTargetSyncPreviewWrites, 1);
  assert.equal(adminBridge.claimTargetSyncPreview.summary.creates, 1);
  assert.equal(adminBridge.summary.canonicalHostEntities, 2);
  assert.equal(adminBridge.summary.canonicalHostPublicPublished, 1);
  assert.equal(adminBridge.summary.canonicalHostClaimTargets, 1);
  assert.equal(adminBridge.summary.canonicalEvidenceRecords, 9);
  assert.equal(adminBridge.summary.canonicalEvidenceRawProviderArtifacts, 2);
  assert.equal(adminBridge.summary.publicationReviewPackets, 2);
  assert.equal(adminBridge.summary.publicationReviewReady, 1);
  assert.equal(adminBridge.summary.publicationReviewBlockedByData, 0);
  assert.equal(adminBridge.items.find((item) => item.entityId === "afterfly").publishStatus, "published");

  const readiness = readGenerated(generatedRoot, "organizer_workflow_readiness.json");
  assert.equal(readiness.status, "ready_for_claim_sync_review");
  assert.equal(readiness.summary.claimSyncReady, true);
  assert.equal(readiness.summary.canonicalHostEntities, 2);
  assert.equal(readiness.summary.canonicalHostPublicPublished, 1);
  assert.equal(readiness.summary.canonicalEvidenceRecords, 9);
  assert.equal(readiness.summary.publicationReviewPackets, 2);
  assert.equal(readiness.summary.publicationReviewReady, 1);
  assert.equal(readiness.summary.publicProjectionReady, true);
  assert.equal(readiness.summary.policyNeeded, 4);
  assert.equal(readiness.summary.reviewNeeded, 1);
  assert.equal(
    readiness.gates.find((gate) => gate.id === "canonical_host_registry")
      .status,
    "ready"
  );
  assert.equal(
    readiness.gates.find((gate) => gate.id === "canonical_evidence_index")
      .status,
    "ready"
  );
  assert.equal(
    readiness.gates.find((gate) => gate.id === "publication_review_packets")
      .status,
    "review_needed"
  );
  assert.equal(
    readiness.gates.find((gate) => gate.id === "raw_artifact_storage").status,
    "policy_needed"
  );
  assert.equal(
    readiness.gates.find((gate) => gate.id === "policy_decision_packets")
      .status,
    "policy_needed"
  );
  const policyDecisionPackets = readGenerated(
    generatedRoot,
    "organizer_policy_decision_packets.json"
  );
  assert.equal(policyDecisionPackets.summary.packets, 5);
  assert.equal(policyDecisionPackets.summary.unansweredQuestions, 25);
  assert.equal(adminBridge.policyDecisionPackets.summary.packets, 5);
  const operatorActionQueue = readGenerated(
    generatedRoot,
    "organizer_operator_action_queue.json"
  );
  assert.equal(operatorActionQueue.summary.policyDecisionActions, 5);
  assert.equal(
    adminBridge.operatorActionQueue.summary.policyDecisionActions,
    5
  );
  assert.equal(
    adminBridge.summary.operatorActions,
    operatorActionQueue.summary.actions
  );
  const operationalHealth = readGenerated(
    generatedRoot,
    "organizer_operational_health.json"
  );
  assert.equal(operationalHealth.summary.healthStatus, "p0_action_required");
  assert.equal(operationalHealth.summary.workstreams, 9);
  assert.equal(
    adminBridge.operationalHealth.summary.healthStatus,
    operationalHealth.summary.healthStatus
  );
  assert.equal(
    adminBridge.summary.operationalHealthWorkstreams,
    operationalHealth.summary.workstreams
  );
  const reviewedAnswerPackets = readGenerated(
    generatedRoot,
    "organizer_reviewed_decision_answer_packets.json"
  );
  assert.equal(reviewedAnswerPackets.summary.status, "no_reviewed_packets");
  assert.equal(reviewedAnswerPackets.summary.packets, 0);
  assert.equal(adminBridge.summary.reviewedAnswerPacketStatus, "no_reviewed_packets");
  assert.equal(adminBridge.summary.reviewedAnswerPackets, 0);
  assert.equal(
    adminBridge.reviewedDecisionAnswerPackets.summary.packets,
    reviewedAnswerPackets.summary.packets
  );
  assert(
    operationalHealth.workstreams.some((workstream) =>
      workstream.id === "claim_target_sync" &&
      workstream.status === "dry_run_review_required"
    )
  );
  const pendingInputRequest = readGenerated(
    generatedRoot,
    "organizer_pending_input_request.json"
  );
  assert.equal(pendingInputRequest.summary.requests, 6);
  assert.equal(pendingInputRequest.summary.adminPublicationRequests, 1);
  assert.equal(pendingInputRequest.summary.policyDecisionRequests, 5);
  assert.equal(pendingInputRequest.summary.requiredPolicyQuestions, 25);
  assert.equal(
    adminBridge.pendingInputRequest.summary.requests,
    pendingInputRequest.summary.requests
  );
  assert.equal(
    adminBridge.summary.pendingInputRequests,
    pendingInputRequest.summary.requests
  );
  assert.equal(
    pendingInputRequest.requests.some((request) =>
      request.requestId === "admin-publication:bhag"
    ),
    true
  );
  assert.equal(
    pendingInputRequest.requests.some((request) =>
      request.requestId === "admin-publication:afterfly"
    ),
    false
  );
  const pendingWorkCoverage = readGenerated(
    generatedRoot,
    "organizer_pending_work_coverage.json"
  );
  assert.equal(pendingWorkCoverage.summary.status, "awaiting_required_input");
  assert.equal(pendingWorkCoverage.summary.unresolvedWorkstreams, 6);
  assert.equal(pendingWorkCoverage.summary.coveredWorkstreams, 6);
  assert.equal(pendingWorkCoverage.summary.untriagedWorkstreams, 0);
  assert.equal(
    adminBridge.pendingWorkCoverage.summary.untriagedWorkstreams,
    0
  );
  assert.equal(
    adminBridge.summary.pendingWorkCoverageStatus,
    "awaiting_required_input"
  );
  assert(
    operatorActionQueue.actions.some((action) =>
      action.actionId === "publication-review:bhag"
    )
  );
  assert.equal(
    operatorActionQueue.actions.some((action) =>
      action.actionId === "publication-review:afterfly"
    ),
    false
  );
  const canonicalHosts = readGenerated(
    generatedRoot,
    "canonical_host_entities.json"
  );
  assert.equal(canonicalHosts.naming.publicEntityLabel, "Host");
  assert.equal(canonicalHosts.naming.canonicalDataModel, "OrganizerEntity");
  assert.equal(canonicalHosts.summary.entities, 2);
  assert.equal(canonicalHosts.summary.publicPublished, 1);
  assert.equal(canonicalHosts.summary.claimTargets, 1);
  assert.equal(
    canonicalHosts.entries.find((entry) => entry.entityId === "afterfly")
      .legacyClubCompatibility.status,
    "ready_for_unclaimed_projection"
  );
  assert.equal(adminBridge.canonicalHostEntities.summary.entities, 2);
  const canonicalEvidence = readGenerated(
    generatedRoot,
    "canonical_evidence_index.json"
  );
  assert.equal(canonicalEvidence.summary.hosts, 2);
  assert.equal(canonicalEvidence.summary.surfaces, 8);
  assert.equal(canonicalEvidence.summary.records, 9);
  assert.equal(canonicalEvidence.summary.rawProviderArtifacts, 2);
  assert.equal(canonicalEvidence.summary.surfacesWithoutEvidence, 0);
  assert.equal(adminBridge.canonicalEvidenceIndex.summary.records, 9);
  const publicationPackets = readGenerated(
    generatedRoot,
    "publication_review_packets.json"
  );
  assert.equal(publicationPackets.summary.packets, 2);
  assert.equal(publicationPackets.summary.readyForManualPublicationReview, 1);
  assert.equal(publicationPackets.summary.published, 1);
  assert.equal(publicationPackets.summary.blockedByData, 0);
  assert.equal(adminBridge.publicationReviewPackets.summary.packets, 2);
  const rawArtifactStorage = readGenerated(
    generatedRoot,
    "raw_artifact_storage_manifest.json"
  );
  assert.equal(rawArtifactStorage.summary.rawProviderPayloads, 2);
  assert.equal(rawArtifactStorage.summary.firestoreRawStorageAllowed, false);
  assert.equal(adminBridge.workflowReadiness.status, "ready_for_claim_sync_review");

  execFileSync(process.execPath, [
    scriptPath,
    "--review-decisions-root",
    reviewRoot,
    "--policy-gap-decisions-root",
    policyGapRoot,
    "--answer-packets-root",
    answerPacketsRoot,
    "--generated-root",
    generatedRoot,
    "--admin-generated-root",
    adminGeneratedRoot,
    "--check",
  ], {stdio: "pipe"});
});

test("publication impact preview does not create public projections", () => {
  const tmpRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-organizer-preview-"));
  const reviewRoot = path.join(tmpRoot, "review_decisions");
  const policyGapRoot = path.join(tmpRoot, "policy_gap_decisions");
  const answerPacketsRoot = path.join(tmpRoot, "answer_packets");
  const generatedRoot = path.join(tmpRoot, "generated");
  const adminGeneratedRoot = path.join(tmpRoot, "admin_generated");
  fs.mkdirSync(reviewRoot, {recursive: true});

  execFileSync(process.execPath, [
    scriptPath,
    "--review-decisions-root",
    reviewRoot,
    "--policy-gap-decisions-root",
    policyGapRoot,
    "--answer-packets-root",
    answerPacketsRoot,
    "--generated-root",
    generatedRoot,
    "--admin-generated-root",
    adminGeneratedRoot,
  ], {stdio: "pipe"});

  const projectionPlan = readGenerated(generatedRoot, "public_projection_plan.json");
  assert.equal(projectionPlan.summary.approvedPublic, 0);
  const claimTargets = readGenerated(generatedRoot, "organizer_claim_targets.json");
  assert.equal(claimTargets.summary.targets, 0);
  const claimSyncPreview = readGenerated(
    generatedRoot,
    "organizer_claim_target_sync_preview.json"
  );
  assert.equal(claimSyncPreview.summary.targets, 0);
  assert.equal(claimSyncPreview.summary.writesNeeded, 0);

  const preview = readGenerated(
    generatedRoot,
    "publication_decision_impact_preview.json"
  );
  assert.equal(preview.summary.impacts, 2);
  assert.equal(preview.summary.wouldPublish, 2);
  assert.equal(preview.summary.wouldIndex, 2);
  assert.equal(preview.summary.wouldCreateClaimTargets, 2);
  assert.equal(preview.summary.wouldBeAppDiscoverable, 0);
  assert.equal(preview.summary.reviewerAcknowledgementsRequired, 1);

  const afterfly = preview.entries.find((entry) =>
    entry.entityId === "afterfly"
  );
  assert.equal(afterfly.publicProjection.wouldPublish, true);
  assert.equal(afterfly.publicProjection.wouldIndex, true);
  assert.equal(afterfly.claimTarget.path, "clubs/afterfly");
  assert.equal(afterfly.remoteEffects.writesDuringPreview, 0);
  assert.equal(afterfly.remoteEffects.claimSyncRequired, true);
  assert.equal(
    afterfly.preconditions.reviewerAcknowledgementRequired,
    true
  );
  assert.equal(afterfly.decisionRequired.checklist.manualReportsReviewed, true);

  const adminBridge = readGenerated(
    adminGeneratedRoot,
    "organizerIntakeBridge.json"
  );
  assert.equal(adminBridge.summary.publicationImpactWouldPublish, 2);
  assert.equal(adminBridge.summary.publicationImpactClaimTargets, 2);
  assert.equal(adminBridge.summary.pendingInputRequests, 7);
  assert.equal(adminBridge.summary.pendingAdminPublicationInputs, 2);
  assert.equal(adminBridge.summary.pendingPolicyDecisionInputs, 5);
  assert.equal(adminBridge.summary.pendingRequiredPolicyQuestions, 25);
  assert.equal(adminBridge.summary.pendingWorkCovered, 7);
  assert.equal(adminBridge.summary.pendingWorkUntriaged, 0);
  assert.equal(adminBridge.summary.reviewedAnswerPacketStatus, "no_reviewed_packets");
  assert.equal(adminBridge.summary.reviewedAnswerPacketsReady, 0);
  assert.equal(
    adminBridge.publicationDecisionImpactPreview.summary.wouldIndex,
    2
  );
  assert.equal(
    adminBridge.pendingInputRequest.requests.some((request) =>
      request.requestId === "admin-publication:afterfly"
    ),
    true
  );
  const afterflyBridgeItem = adminBridge.items.find((item) =>
    item.entityId === "afterfly"
  );
  assert.match(
    afterflyBridgeItem.decisionCommands.approvePublic,
    /--app-visibility hidden/
  );
  assert.match(
    afterflyBridgeItem.decisionCommands.approvePublic,
    /--confirm-manual-reports-reviewed/
  );
  assert.match(
    afterflyBridgeItem.decisionCommands.hold,
    /--app-visibility hidden/
  );
  assert.match(
    afterflyBridgeItem.decisionCommands.suppress,
    /--app-visibility hidden/
  );
});

test("approved review decisions must match pre-approval publication packet readiness", () => {
  const tmpRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-organizer-blocked-approval-"));
  const batchesRoot = path.join(tmpRoot, "batches");
  const curationRoot = path.join(tmpRoot, "curation_decisions");
  const reviewRoot = path.join(tmpRoot, "review_decisions");
  const policyGapRoot = path.join(tmpRoot, "policy_gap_decisions");
  const answerPacketsRoot = path.join(tmpRoot, "answer_packets");
  const generatedRoot = path.join(tmpRoot, "generated");
  const adminGeneratedRoot = path.join(tmpRoot, "admin_generated");
  fs.mkdirSync(batchesRoot, {recursive: true});
  fs.mkdirSync(curationRoot, {recursive: true});
  fs.mkdirSync(reviewRoot, {recursive: true});

  const batch = JSON.parse(fs.readFileSync(foundationBatchPath, "utf8"));
  const afterfly = batch.entities.find((entity) =>
    entity.entityId === "afterfly"
  );
  afterfly.publicDraft.summary = "Too short.";
  afterfly.publicDraft.sourceSummary = "Too short.";
  fs.writeFileSync(
    path.join(batchesRoot, "2026-06-17-foundation.json"),
    `${JSON.stringify(batch, null, 2)}\n`
  );
  fs.writeFileSync(
    path.join(reviewRoot, "2026-06-17-afterfly-approve-public.json"),
    `${JSON.stringify(approvedAfterflyDecision(), null, 2)}\n`
  );

  assert.throws(
    () => execFileSync(process.execPath, [
      scriptPath,
      "--batches-root",
      batchesRoot,
      "--curation-decisions-root",
      curationRoot,
      "--review-decisions-root",
      reviewRoot,
      "--policy-gap-decisions-root",
      policyGapRoot,
      "--answer-packets-root",
      answerPacketsRoot,
      "--generated-root",
      generatedRoot,
      "--admin-generated-root",
      adminGeneratedRoot,
    ], {stdio: "pipe"}),
    (error) => {
      const stderr = error.stderr.toString();
      assert.match(stderr, /approve_public for afterfly/);
      assert.match(stderr, /data:owner_safe_public_draft/);
      assert.equal(fs.existsSync(
        path.join(generatedRoot, "public_projection_plan.json")
      ), false);
      return true;
    }
  );
});

test("manual-report publication approvals must persist reviewer acknowledgement", () => {
  const tmpRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch-organizer-manual-report-"));
  const reviewRoot = path.join(tmpRoot, "review_decisions");
  const policyGapRoot = path.join(tmpRoot, "policy_gap_decisions");
  const answerPacketsRoot = path.join(tmpRoot, "answer_packets");
  const generatedRoot = path.join(tmpRoot, "generated");
  const adminGeneratedRoot = path.join(tmpRoot, "admin_generated");
  fs.mkdirSync(reviewRoot, {recursive: true});
  const decision = approvedAfterflyDecision();
  delete decision.decisions[0].checklist.manualReportsReviewed;
  fs.writeFileSync(
    path.join(reviewRoot, "2026-06-17-afterfly-approve-public.json"),
    `${JSON.stringify(decision, null, 2)}\n`
  );

  assert.throws(
    () => execFileSync(process.execPath, [
      scriptPath,
      "--review-decisions-root",
      reviewRoot,
      "--policy-gap-decisions-root",
      policyGapRoot,
      "--answer-packets-root",
      answerPacketsRoot,
      "--generated-root",
      generatedRoot,
      "--admin-generated-root",
      adminGeneratedRoot,
    ], {stdio: "pipe"}),
    (error) => {
      const stderr = error.stderr.toString();
      assert.match(stderr, /approve_public for afterfly/);
      assert.match(stderr, /manualReportsReviewed/);
      assert.equal(fs.existsSync(
        path.join(generatedRoot, "public_projection_plan.json")
      ), false);
      return true;
    }
  );
});

function readGenerated(root, file) {
  return JSON.parse(fs.readFileSync(path.join(root, file), "utf8"));
}

function approvedAfterflyDecision() {
  return {
    schemaVersion: 1,
    decisionBatchId: "2026-06-17-afterfly-approve-public",
    decidedAt: "2026-06-17",
    reviewer: "test",
    decisions: [
      {
        appVisibility: "hidden",
        checklist: {
          crawlDisabledReviewed: true,
          identityReviewed: true,
          marketScopeReviewed: true,
          manualReportsReviewed: true,
          mediaRightsReviewed: true,
          ownerSafeCopyReviewed: true,
          surfaceInventoryReviewed: true,
        },
        decision: "approve_public",
        entityId: "afterfly",
        note: "Manual QA complete.",
      },
    ],
  };
}
