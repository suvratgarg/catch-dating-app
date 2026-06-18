import assert from "node:assert/strict";
import test from "node:test";
import {buildOrganizerOperatorActionQueue} from
  "./lib/operator_action_queue_core.mjs";

test("operator action queue consolidates publication, policy, and waiting gates", () => {
  const queue = buildOrganizerOperatorActionQueue({
    claimTargetSyncPreview: claimPreview(),
    policyDecisionPackets: policyPackets(),
    publicationDecisionImpactPreview: impactPreview(),
    publicationReviewPackets: publicationPackets(),
    workflowReadiness: workflowReadiness(),
  });

  assert.equal(queue.summary.actions, 5);
  assert.equal(queue.summary.publicationReviewActions, 1);
  assert.equal(queue.summary.policyDecisionActions, 2);
  assert.equal(queue.summary.workflowGateActions, 2);
  assert.equal(queue.summary.adminDecisionsRequired, 1);
  assert.equal(queue.summary.policyInputsRequired, 2);
  assert.equal(queue.summary.waitingActions, 2);
  assert.equal(queue.summary.highestPriority, "p0");
  assert.deepEqual(queue.summary.actionsByType, {
    policy_decision: 2,
    publication_review: 1,
    workflow_gate: 2,
  });

  const publication = queue.actions.find((action) =>
    action.actionId === "publication-review:afterfly"
  );
  assert.equal(publication.status, "requires_admin_decision");
  assert.equal(publication.requiredAcknowledgements.manualReportsReviewed, true);
  assert.equal(publication.impact.wouldIndex, true);
  assert.equal(publication.impact.claimTargetPath, "clubs/afterfly");
  assert.match(publication.commands[0], /review_decision/);

  const policy = queue.actions.find((action) =>
    action.actionId === "policy-decision:recurring_event_crawl_policy"
  );
  assert.equal(policy.priority, "p0");
  assert.equal(policy.status, "requires_policy_input");
  assert.deepEqual(policy.decisionOptions, ["accept", "hold", "reject"]);
  assert.deepEqual(policy.requiredInputs, ["provider_order"]);

  const waiting = queue.actions.find((action) =>
    action.actionId === "workflow-gate:claim_target_sync"
  );
  assert.equal(waiting.status, "waiting:claim_target_sync");
  assert.match(waiting.commands[0], /sync_claim_targets/);
});

function publicationPackets() {
  return {
    packets: [
      {
        adminDecision: {
          allowedDecisions: ["approve_public", "hold", "suppress"],
          command:
            "node tool/organizer_intake/review_decision.mjs draft afterfly --decision approve_public",
        },
        approvalChecklist: {
          identityReviewed: true,
          mediaRightsReviewed: true,
        },
        dataBlockers: [],
        displayName: "AFTER FLY",
        entityId: "afterfly",
        evidenceBlockers: [],
        evidenceSummary: {manualReportsWithoutArtifacts: 1},
        nextActions: ["record_manual_publication_decision"],
        packetId: "publication-review-afterfly",
        priority: "p0",
        status: "ready_for_manual_publication_review",
        taskType: "promotion_review",
      },
    ],
  };
}

function impactPreview() {
  return {
    entries: [
      {
        app: {appVisibility: "hidden"},
        claimTarget: {
          path: "clubs/afterfly",
          wouldCreateOrRefresh: true,
        },
        commands: [
          "node tool/organizer_intake/review_decision.mjs draft afterfly --decision approve_public",
          "node tool/organizer_intake/organizer_intake.mjs",
        ],
        decisionRequired: {
          command:
            "node tool/organizer_intake/review_decision.mjs draft afterfly --decision approve_public",
        },
        entityId: "afterfly",
        publicProjection: {
          wouldIndex: true,
          wouldPublish: true,
        },
        remoteEffects: {
          sitemapEligible: true,
        },
      },
    ],
  };
}

function policyPackets() {
  return {
    packets: [
      {
        area: "crawl",
        blockedArtifacts: ["event_crawl_plan"],
        decisionPrompt: "Choose crawl policy.",
        decisionStatus: "not_reviewed",
        gapId: "recurring_event_crawl_policy",
        nextAction: "Choose crawl policy.",
        questions: [
          {
            answerState: "needs_input",
            questionId: "provider_order",
          },
        ],
        safeDefaultAction: "keep_crawls_disabled",
        severity: "high",
      },
      {
        area: "naming",
        blockedArtifacts: ["ui_copy"],
        decisionPrompt: "Confirm naming.",
        decisionStatus: "not_reviewed",
        gapId: "organizer_host_naming_migration_policy",
        nextAction: "Confirm naming.",
        questions: [
          {
            answerState: "needs_input",
            questionId: "public_label",
          },
        ],
        safeDefaultAction: "keep_existing_copy",
        severity: "medium",
      },
    ],
  };
}

function workflowReadiness() {
  return {
    commands: {
      localPromotionPreview:
        "node tool/organizer_intake/run_promotion_pipeline.mjs",
    },
    gates: [
      {
        detail: "0 approved public projections.",
        id: "public_projection",
        label: "Public projection",
        nextAction: "Export admin review decisions.",
        status: "waiting",
      },
      {
        detail: "0 claim targets.",
        id: "claim_target_sync",
        label: "Claim target sync",
        nextAction: "Review claim target sync preview.",
        status: "waiting",
      },
    ],
  };
}

function claimPreview() {
  return {
    commands: {
      firestoreDryRun:
        "node tool/organizer_intake/sync_claim_targets_to_firestore.mjs --env dev",
      localFixturePreview:
        "node tool/organizer_intake/sync_claim_targets_to_firestore.mjs --fixture empty.json",
    },
    summary: {writesNeeded: 0},
  };
}
