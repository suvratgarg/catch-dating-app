import assert from "node:assert/strict";
import test from "node:test";
import {buildOrganizerPromotionExecutionPacket} from
  "./lib/promotion_execution_packet_core.mjs";

test("promotion execution packet models current pending admin and policy gates", () => {
  const packet = buildOrganizerPromotionExecutionPacket(currentPendingFixture());

  assert.equal(packet.summary.status, "waiting_on_admin_publication_review");
  assert.equal(packet.summary.pendingAdminDecisions, 2);
  assert.equal(packet.summary.pendingPolicyDecisions, 5);
  assert.equal(packet.summary.pendingAnswerSlots, 7);
  assert.equal(packet.summary.reviewedAnswerPackets, 0);
  assert.equal(packet.summary.reviewedAnswerPacketsReady, 0);
  assert.equal(packet.summary.reviewedAnswerPacketStatus, "no_reviewed_packets");
  assert.equal(packet.summary.canRunLocalPreview, true);
  assert.equal(packet.summary.canDeployNewPublicPages, false);
  assert.equal(packet.summary.canWriteClaimTargets, false);
  assert.equal(packet.summary.policyInputRequiredBeforeCrawlStorageOrImport, true);
  assert.equal(packet.summary.guardedRemoteReadPhases, 1);
  assert.equal(packet.summary.guardedRemoteWritePhases, 1);

  const admin = packet.phases.find((phase) =>
    phase.phaseId === "review_admin_publication_decisions");
  assert.equal(admin.status, "waiting_on_admin_review");
  assert.match(admin.blockers[0], /2 admin publication/);

  const applyAnswers = packet.phases.find((phase) =>
    phase.phaseId === "apply_answered_decision_packet");
  assert.equal(applyAnswers.status, "waiting_on_answer_packet");
  assert.equal(applyAnswers.executionMode, "local_write_guarded");
  assert.match(applyAnswers.command, /run_promotion_pipeline\.mjs/);
  assert.match(applyAnswers.command, /--apply-decision-answers/);
  assert.match(applyAnswers.command, /--write-decision-answers/);
  assert.match(applyAnswers.blockers.join("\n"), /no reviewed answer packet/);

  const claimWrite = packet.phases.find((phase) =>
    phase.phaseId === "claim_target_firestore_write");
  assert.equal(claimWrite.status, "disabled_until_public_projection_and_dry_run");
  assert.equal(claimWrite.executionMode, "remote_write_guarded");
  assert(claimWrite.blockers.includes("requires explicit --write-claim-targets guard"));
});

test("promotion execution packet distinguishes ready reviewed answer packets", () => {
  const fixture = currentPendingFixture();
  fixture.reviewedDecisionAnswerPackets = {
    summary: {
      awaitingAnswers: 0,
      invalid: 0,
      packets: 1,
      readyToApply: 1,
      stale: 0,
      status: "ready_to_apply",
    },
  };

  const packet = buildOrganizerPromotionExecutionPacket(fixture);
  const applyAnswers = packet.phases.find((phase) =>
    phase.phaseId === "apply_answered_decision_packet");

  assert.equal(packet.summary.reviewedAnswerPackets, 1);
  assert.equal(packet.summary.reviewedAnswerPacketsReady, 1);
  assert.equal(packet.summary.reviewedAnswerPacketStatus, "ready_to_apply");
  assert.equal(applyAnswers.status, "ready_to_apply_reviewed_answer_packet");
  assert.match(
    applyAnswers.blockers.join("\n"),
    /1 reviewed answer packet\(s\) ready to apply/
  );
});

test("promotion execution packet blocks invalid reviewed answer packets", () => {
  const fixture = currentPendingFixture();
  fixture.reviewedDecisionAnswerPackets = {
    summary: {
      awaitingAnswers: 0,
      invalid: 1,
      packets: 1,
      readyToApply: 0,
      stale: 1,
      status: "invalid_packets",
    },
  };

  const packet = buildOrganizerPromotionExecutionPacket(fixture);
  const applyAnswers = packet.phases.find((phase) =>
    phase.phaseId === "apply_answered_decision_packet");

  assert.equal(packet.summary.reviewedAnswerPacketsInvalid, 1);
  assert.equal(packet.summary.reviewedAnswerPacketsStale, 1);
  assert.equal(applyAnswers.status, "blocked_by_invalid_answer_packet");
  assert.match(applyAnswers.blockers.join("\n"), /stale/);
  assert.match(applyAnswers.blockers.join("\n"), /invalid/);
});

test("promotion execution packet becomes promotion-ready after public projection", () => {
  const fixture = currentPendingFixture();
  fixture.pendingInputRequest.summary.adminPublicationRequests = 0;
  fixture.pendingInputRequest.summary.policyDecisionRequests = 0;
  fixture.pendingDecisionAnswerPacket.summary.answerSlots = 0;
  fixture.projectionPlan.summary.approvedPublic = 1;
  fixture.publicationDecisionImpactPreview.summary.wouldPublish = 1;
  fixture.claimTargetSyncPreview.summary = {
    targets: 1,
    writesNeeded: 1,
  };
  fixture.workflowReadiness.summary.publicProjectionReady = true;
  fixture.workflowReadiness.summary.claimSyncReady = true;

  const packet = buildOrganizerPromotionExecutionPacket(fixture);

  assert.equal(packet.summary.status, "ready_for_reviewed_promotion");
  assert.equal(packet.summary.canDeployNewPublicPages, true);
  assert.equal(packet.summary.canWriteClaimTargets, true);
  assert.equal(
    packet.phases.find((phase) =>
      phase.phaseId === "validate_promotion_bridge").status,
    "ready"
  );
  assert.equal(
    packet.phases.find((phase) =>
      phase.phaseId === "apply_answered_decision_packet").status,
    "ready"
  );
  assert.equal(
    packet.phases.find((phase) =>
      phase.phaseId === "claim_target_firestore_write").status,
    "ready_after_reviewed_firestore_dry_run"
  );
});

test("promotion execution packet flags untriaged work before preview", () => {
  const fixture = currentPendingFixture();
  fixture.pendingWorkCoverage.summary.untriagedWorkstreams = 1;

  const packet = buildOrganizerPromotionExecutionPacket(fixture);

  assert.equal(packet.summary.status, "untriaged_work");
  assert.equal(packet.summary.canRunLocalPreview, false);
  assert.equal(
    packet.phases.find((phase) =>
      phase.phaseId === "local_promotion_preview").status,
    "blocked_by_untriaged_work"
  );
});

function currentPendingFixture() {
  return {
    pendingInputRequest: {
      summary: {
        adminPublicationRequests: 2,
        policyDecisionRequests: 5,
      },
      requests: [],
    },
    pendingWorkCoverage: {
      summary: {
        untriagedWorkstreams: 0,
      },
    },
    pendingDecisionAnswerPacket: {
      summary: {
        answerSlots: 7,
      },
    },
    workflowReadiness: {
      commands: {
        exportCurationAndReview:
          "node tool/organizer_intake/run_promotion_pipeline.mjs " +
          "--export-curation-decisions --export-review-decisions --date YYYY-MM-DD --write-export",
        localPromotionPreview:
          "node tool/organizer_intake/run_promotion_pipeline.mjs",
        reviewedClaimSync:
          "node tool/organizer_intake/run_promotion_pipeline.mjs " +
          "--claim-sync firestore --env ENV",
        writeClaimTargets:
          "node tool/organizer_intake/run_promotion_pipeline.mjs " +
          "--claim-sync firestore --env ENV --write-claim-targets",
      },
      summary: {
        localPromotionPipelineReady: true,
        publicProjectionReady: false,
        claimSyncReady: false,
      },
    },
    publicationDecisionImpactPreview: {
      summary: {
        impacts: 2,
        wouldPublish: 0,
      },
    },
    claimTargetSyncPreview: {
      summary: {
        targets: 0,
        writesNeeded: 0,
      },
    },
    projectionPlan: {
      summary: {
        approvedPublic: 0,
      },
    },
  };
}
