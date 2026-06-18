import assert from "node:assert/strict";
import test from "node:test";
import {
  checkOrganizerPromotionExecutionPacket,
  renderPromotionExecutionPacketMarkdown,
} from "./promotion_execution_packet.mjs";

test("checker accepts coherent promotion execution packet", () => {
  const result = checkOrganizerPromotionExecutionPacket(packet());

  assert.equal(result.ok, true, result.errors.join("\n"));
  assert.deepEqual(result.errors, []);
  assert.equal(result.summary.status, "waiting_on_admin_publication_review");
  assert.equal(result.summary.phases, 4);
  assert.equal(result.summary.blockedPhases, 4);
  assert.equal(result.summary.pendingAdminDecisions, 1);
  assert.equal(result.summary.pendingPolicyDecisions, 1);
  assert.equal(result.summary.canRunLocalPreview, true);
  assert.equal(result.summary.canDeployNewPublicPages, false);
  assert.equal(result.summary.canWriteClaimTargets, false);
  assert.match(result.warnings[0], /1 admin publication/);
  assert.match(result.warnings[1], /1 product policy/);
});

test("markdown renderer names phases and remote write gates", () => {
  const markdown = renderPromotionExecutionPacketMarkdown(packet());

  assert.match(markdown, /# Organizer Promotion Execution/);
  assert.match(markdown, /Review admin publication decisions/);
  assert.match(markdown, /Apply answered decision packet/);
  assert.match(markdown, /Claim target write/);
  assert.match(markdown, /remote_write_guarded/);
  assert.match(markdown, /--write-claim-targets/);
});

test("checker rejects stale summary counts and unsafe write phase", () => {
  const payload = packet();
  payload.summary.phases = 9;
  payload.summary.guardedRemoteWritePhases = 0;
  payload.phases[3].command =
    "node tool/organizer_intake/run_promotion_pipeline.mjs --claim-sync firestore";

  const result = checkOrganizerPromotionExecutionPacket(payload);

  assert.equal(result.ok, false);
  assert(
    result.errors.some((error) =>
      error.includes("summary.phases 9 does not match 4"))
  );
  assert(
    result.errors.some((error) =>
      error.includes("summary.guardedRemoteWritePhases 0 does not match 1"))
  );
  assert(
    result.errors.some((error) =>
      error.includes("guarded write phase must show an explicit write flag"))
  );
});

test("checker rejects contradictory deploy readiness", () => {
  const payload = packet();
  payload.summary.canDeployNewPublicPages = true;
  payload.summary.approvedPublicProjections = 0;

  const result = checkOrganizerPromotionExecutionPacket(payload);

  assert.equal(result.ok, false);
  assert(
    result.errors.some((error) =>
      error.includes("cannot deploy new public pages without approved projections"))
  );
});

function packet() {
  return {
    schemaVersion: 1,
    summary: {
      status: "waiting_on_admin_publication_review",
      localPromotionPipelineReady: true,
      publicProjectionReady: false,
      claimSyncReady: false,
      pendingAdminDecisions: 1,
      pendingPolicyDecisions: 1,
      pendingAnswerSlots: 2,
      pendingWorkUntriaged: 0,
      approvedPublicProjections: 0,
      publicationImpacts: 1,
      publicationImpactWouldPublish: 0,
      claimTargetPreviewTargets: 0,
      claimTargetPreviewWrites: 0,
      canRunLocalPreview: true,
      canDeployNewPublicPages: false,
      canWriteClaimTargets: false,
      policyInputRequiredBeforeCrawlStorageOrImport: true,
      phases: 4,
      phasesByStatus: {
        disabled_until_public_projection_and_dry_run: 1,
        waiting_on_answer_packet: 1,
        waiting_on_admin_review: 1,
        waiting_on_policy_input: 1,
      },
      blockedPhases: 4,
      guardedRemoteReadPhases: 0,
      guardedRemoteWritePhases: 1,
    },
    guardrails: [
      "packet never writes",
    ],
    phases: [
      {
        phaseId: "review_admin_publication_decisions",
        label: "Review admin publication decisions",
        status: "waiting_on_admin_review",
        executionMode: "manual_review",
        command:
          "node tool/organizer_intake/pending_decision_answer_packet.mjs --format markdown",
        blockers: ["1 admin publication decision(s) pending"],
        outputs: ["review_decisions JSON"],
      },
      {
        phaseId: "review_product_policy_decisions",
        label: "Review product policy decisions",
        status: "waiting_on_policy_input",
        executionMode: "manual_review",
        command:
          "node tool/organizer_intake/pending_decision_answer_packet.mjs --format markdown",
        blockers: ["1 product policy decision(s) pending"],
        outputs: ["policy_gap_decisions JSON"],
      },
      {
        phaseId: "apply_answered_decision_packet",
        label: "Apply answered decision packet",
        status: "waiting_on_answer_packet",
        executionMode: "local_write_guarded",
        command:
          "node tool/organizer_intake/run_promotion_pipeline.mjs " +
          "--apply-decision-answers --answer-packet PATH --write-decision-answers",
        blockers: ["requires completed answers"],
        outputs: ["review_decisions JSON"],
      },
      {
        phaseId: "claim_target_firestore_write",
        label: "Claim target write",
        status: "disabled_until_public_projection_and_dry_run",
        executionMode: "remote_write_guarded",
        command:
          "node tool/organizer_intake/run_promotion_pipeline.mjs " +
          "--claim-sync firestore --env ENV --write-claim-targets",
        blockers: ["requires explicit --write-claim-targets guard"],
        outputs: ["clubs/{entityId}"],
      },
    ],
  };
}
