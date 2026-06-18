import assert from "node:assert/strict";
import test from "node:test";
import {buildOrganizerPendingInputRequest} from
  "./lib/pending_input_request_core.mjs";

test("pending input request combines publication and policy decisions", () => {
  const request = buildOrganizerPendingInputRequest({
    operatorActionQueue: operatorQueue(),
    operationalHealth: operationalHealth(),
    policyDecisionPackets: policyPackets(),
    publicationReviewPackets: publicationPackets(),
  });

  assert.equal(request.schemaVersion, 1);
  assert.equal(request.summary.requests, 3);
  assert.equal(request.summary.adminPublicationRequests, 1);
  assert.equal(request.summary.policyDecisionRequests, 2);
  assert.equal(request.summary.requiredPolicyQuestions, 3);
  assert.equal(request.summary.manualPublicationAcknowledgements, 1);
  assert.equal(request.summary.workflowFollowUps, 3);
  assert.equal(request.summary.highestPriority, "p0");
  assert.deepEqual(request.summary.requestsByType, {
    admin_publication_decision: 1,
    policy_decision: 2,
  });

  const publication = request.requests.find((item) =>
    item.requestId === "admin-publication:afterfly"
  );
  assert.equal(publication.safeDefaultAction, "hold");
  assert.equal(publication.requiredAcknowledgements.manualReportsReviewed, true);
  assert.equal(publication.impact.wouldIndex, true);
  assert.match(publication.commands[0], /review_decision/);
  assert.equal(
    publication.callableSubmission.callableName,
    "adminDecideOrganizerIntake"
  );
  assert.deepEqual(
    publication.callableSubmission.safeDefaultPayload,
    publication.callableSubmission.payloadsByDecision.hold
  );
  assert.deepEqual(
    publication.callableSubmission.payloadsByDecision.approve_public,
    {
      entityId: "afterfly",
      decision: "approve_public",
      appVisibility: "hidden",
      checklist: {
        identityReviewed: true,
        surfaceInventoryReviewed: false,
        ownerSafeCopyReviewed: false,
        marketScopeReviewed: false,
        mediaRightsReviewed: true,
        crawlDisabledReviewed: false,
        manualReportsReviewed: true,
      },
      note: "Manual QA approved AFTER FLY for public website projection.",
    }
  );
  assert.equal(
    publication.callableSubmission.payloadsByDecision.hold.checklist
      .mediaRightsReviewed,
    false
  );

  const policy = request.requests.find((item) =>
    item.requestId === "policy:recurring_event_crawl_policy"
  );
  assert.equal(policy.safeDefaultAction, "keep_scheduler_disabled");
  assert.equal(policy.requiredInputs.length, 2);
  assert.deepEqual(policy.decisionOptions, ["accept", "hold", "reject"]);
  assert.match(policy.currentState.implementationGate, /scheduler/);
  assert.equal(
    policy.callableSubmission.callableName,
    "adminDecideOrganizerPolicyGap"
  );
  assert.deepEqual(
    policy.callableSubmission.safeDefaultPayload,
    policy.callableSubmission.payloadsByDecision.hold
  );
  assert.deepEqual(
    policy.callableSubmission.payloadsByDecision.accept.requiredInputsReviewed,
    ["monthly cap", "platform allowlist"]
  );
  assert.deepEqual(
    policy.callableSubmission.payloadsByDecision.hold.checklist,
    {
      requiredInputsReviewed: false,
      costAndSafetyReviewed: false,
      implementationOwnerReviewed: true,
      behaviorStillDisabledAcknowledged: true,
    }
  );

  const followUp = request.followUps.find((item) =>
    item.followUpId === "workflow:claim_target_sync"
  );
  assert.equal(followUp.status, "waiting_on_public_projection");
  const dryRunFollowUp = request.followUps.find((item) =>
    item.followUpId === "workflow:claim_target_dry_run"
  );
  assert.equal(dryRunFollowUp.status, "dry_run_review_required");
});

function operatorQueue() {
  return {
    actions: [
      {
        actionType: "publication_review",
        commands: [
          "node tool/organizer_intake/review_decision.mjs draft afterfly",
        ],
        decisionOptions: ["approve_public", "hold", "suppress"],
        impact: {
          claimTargetPath: "clubs/afterfly",
          wouldCreateClaimTarget: true,
          wouldIndex: true,
          wouldPublish: true,
        },
        priority: "p0",
        requiredAcknowledgements: {
          manualReportsReviewed: true,
        },
        subjectId: "afterfly",
      },
      {
        actionType: "policy_decision",
        commands: [
          "node tool/organizer_intake/policy_gap_decision.mjs draft recurring_event_crawl_policy",
        ],
        decisionOptions: ["accept", "hold", "reject"],
        priority: "p0",
        subjectId: "recurring_event_crawl_policy",
      },
      {
        actionType: "policy_decision",
        commands: [
          "node tool/organizer_intake/policy_gap_decision.mjs draft organizer_host_naming_migration_policy",
        ],
        decisionOptions: ["accept", "hold", "reject"],
        priority: "p1",
        subjectId: "organizer_host_naming_migration_policy",
      },
    ],
  };
}

function operationalHealth() {
  return {
    workstreams: [
      {
        blockers: ["waiting"],
        commands: ["node tool/organizer_intake/sync_claim_targets_to_firestore.mjs"],
        id: "claim_target_sync",
        label: "Claim Target Sync",
        nextActions: ["Wait for public projection."],
        priority: "p2",
        status: "waiting_on_public_projection",
      },
      {
        blockers: ["retention_policy_missing"],
        commands: ["node tool/organizer_intake/plan_raw_artifact_storage.mjs"],
        id: "raw_artifact_storage",
        label: "Raw Artifact Storage",
        nextActions: ["Choose retention policy."],
        priority: "p1",
        status: "blocked_by_policy",
      },
      {
        blockers: ["dry_run"],
        commands: ["node tool/organizer_intake/sync_claim_targets_to_firestore.mjs"],
        id: "claim_target_dry_run",
        label: "Claim Target Dry Run",
        nextActions: ["Review dry run."],
        priority: "p1",
        status: "dry_run_review_required",
      },
    ],
  };
}

function publicationPackets() {
  return {
    packets: [
      {
        adminDecision: {
          allowedDecisions: ["approve_public", "hold", "suppress"],
          command:
            "node tool/organizer_intake/review_decision.mjs draft afterfly",
        },
        approvalChecklist: {
          identityReviewed: true,
          mediaRightsReviewed: true,
        },
        displayName: "AFTER FLY",
        entityId: "afterfly",
        evidenceSummary: {
          manualReportsWithoutArtifacts: 1,
          records: 4,
          riskFlags: ["manual_report_without_artifact"],
        },
        priority: "p0",
        status: "ready_for_manual_publication_review",
        taskType: "promotion_review",
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
        currentState: "Scheduler disabled.",
        decisionOwner: "product_ops",
        decisionPrompt: "Should recurring crawls be enabled?",
        decisionStatus: "not_reviewed",
        gapId: "recurring_event_crawl_policy",
        implementationGate: "scheduler and budget policy encoded",
        nextAction: "Choose crawl policy.",
        questions: [
          {
            answerState: "needs_input",
            currentDefault: "keep_scheduler_disabled",
            input: "platform allowlist",
            prompt: "platform allowlist for crawl.",
            questionId: "crawl:platform-allowlist",
            recommendedSafeDefault: "keep_scheduler_disabled",
            requiredForAcceptance: true,
          },
          {
            answerState: "needs_input",
            currentDefault: "keep_scheduler_disabled",
            input: "monthly cap",
            prompt: "monthly cap for crawl.",
            questionId: "crawl:monthly-cap",
            recommendedSafeDefault: "keep_scheduler_disabled",
            requiredForAcceptance: true,
          },
        ],
        safeDefaultAction: "keep_scheduler_disabled",
        severity: "high",
        unblockCriteria: ["scheduler enabled"],
      },
      {
        area: "naming",
        blockedArtifacts: ["admin/src/App.tsx"],
        currentState: "Organizer private, Host public.",
        decisionOwner: "product",
        decisionPrompt: "Which label should be public?",
        decisionStatus: "not_reviewed",
        gapId: "organizer_host_naming_migration_policy",
        implementationGate: "copy migration encoded",
        nextAction: "Choose naming.",
        questions: [
          {
            answerState: "needs_input",
            currentDefault: "keep_organizer_entity_with_club_compatibility",
            input: "public label",
            prompt: "public label for naming.",
            questionId: "naming:public-label",
            recommendedSafeDefault:
              "keep_organizer_entity_with_club_compatibility",
            requiredForAcceptance: true,
          },
        ],
        safeDefaultAction: "keep_organizer_entity_with_club_compatibility",
        severity: "medium",
        unblockCriteria: ["copy migration"],
      },
    ],
  };
}
