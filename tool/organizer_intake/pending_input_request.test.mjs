import assert from "node:assert/strict";
import test from "node:test";
import {
  checkOrganizerPendingInputRequest,
  renderPendingInputRequestMarkdown,
} from "./pending_input_request.mjs";

test("checker accepts coherent generated pending input request", () => {
  const request = pendingInputRequest();
  const result = checkOrganizerPendingInputRequest(request);

  assert.equal(result.ok, true);
  assert.deepEqual(result.errors, []);
  assert.equal(result.summary.requests, 2);
  assert.equal(result.summary.adminPublicationRequests, 1);
  assert.equal(result.summary.policyDecisionRequests, 1);
  assert.equal(result.summary.requiredPolicyQuestions, 2);
  assert.equal(result.summary.manualPublicationAcknowledgements, 1);
  assert.equal(result.summary.callableSubmissions, 2);
  assert.equal(result.summary.workflowFollowUps, 1);
  assert.equal(result.summary.highestPriority, "p0");
  assert.match(result.warnings[0], /2 admin\/product input/);
});

test("markdown renderer names publication and policy inputs", () => {
  const markdown = renderPendingInputRequestMarkdown(pendingInputRequest());

  assert.match(markdown, /# Organizer Pending Inputs/);
  assert.match(markdown, /AFTER FLY/);
  assert.match(markdown, /recurring_event_crawl_policy/);
  assert.match(markdown, /Safe default: hold/);
  assert.match(markdown, /manual reports reviewed/);
  assert.match(markdown, /Callable: `adminDecideOrganizerIntake`/);
  assert.match(markdown, /Safe payload: `\{.*"appVisibility":"hidden"/);
});

test("checker rejects stale summary counts and priority", () => {
  const request = pendingInputRequest();
  request.summary.requests = 7;
  request.summary.requiredPolicyQuestions = 4;
  request.summary.highestPriority = "p2";

  const result = checkOrganizerPendingInputRequest(request);

  assert.equal(result.ok, false);
  assert(
    result.errors.some((error) =>
      error.includes("summary.requests 7 does not match requests length 2"))
  );
  assert(
    result.errors.some((error) =>
      error.includes("summary.requiredPolicyQuestions 4 does not match 2"))
  );
  assert(
    result.errors.some((error) =>
      error.includes("summary.highestPriority p2 does not match p0"))
  );
});

test("checker rejects callable submission drift", () => {
  const request = pendingInputRequest();
  delete request.requests[0].callableSubmission.payloadsByDecision
    .approve_public.checklist.manualReportsReviewed;
  request.requests[1].callableSubmission.payloadsByDecision
    .accept.requiredInputsReviewed = ["unknown input"];

  const result = checkOrganizerPendingInputRequest(request);

  assert.equal(result.ok, false);
  assert(
    result.errors.some((error) =>
      error.includes(
        "approve_public.checklist.manualReportsReviewed is required"
      ))
  );
  assert(
    result.errors.some((error) =>
      error.includes("accept.requiredInputsReviewed must match required inputs"))
  );
});

function pendingInputRequest() {
  return {
    schemaVersion: 1,
    summary: {
      requests: 2,
      adminPublicationRequests: 1,
      policyDecisionRequests: 1,
      requiredPolicyQuestions: 2,
      manualPublicationAcknowledgements: 1,
      workflowFollowUps: 1,
      highestPriority: "p0",
      requestsByOwner: {
        admin: 1,
        product_ops: 1,
      },
      requestsByPriority: {
        p0: 1,
        p1: 1,
      },
      requestsByType: {
        admin_publication_decision: 1,
        policy_decision: 1,
      },
      followUpsByStatus: {
        waiting_on_public_projection: 1,
      },
    },
    requests: [
      {
        requestId: "admin-publication:afterfly",
        requestType: "admin_publication_decision",
        priority: "p0",
        owner: "admin",
        subjectId: "afterfly",
        subjectName: "AFTER FLY",
        prompt: "Should AFTER FLY become public?",
        decisionOptions: ["approve_public", "hold", "suppress"],
        safeDefaultAction: "hold",
        requiredAcknowledgements: {
          manualReportsReviewed: true,
        },
        currentState: {
          riskFlags: ["manual_report_without_artifact"],
        },
        impact: {
          claimTargetPath: "clubs/afterfly",
          wouldCreateClaimTarget: true,
          wouldIndex: true,
          wouldPublish: true,
        },
        callableSubmission: {
          callableName: "adminDecideOrganizerIntake",
          adminApiWrapper: "decideOrganizerIntake",
          payloadType: "AdminDecideOrganizerIntakePayload",
          firestoreCollection: "organizerIntakeReviewDecisions",
          payloadsByDecision: {
            approve_public: {
              entityId: "afterfly",
              decision: "approve_public",
              appVisibility: "hidden",
              checklist: {
                identityReviewed: true,
                surfaceInventoryReviewed: true,
                ownerSafeCopyReviewed: true,
                marketScopeReviewed: true,
                mediaRightsReviewed: true,
                crawlDisabledReviewed: true,
                manualReportsReviewed: true,
              },
              note: "Manual QA approved AFTER FLY.",
            },
            hold: {
              entityId: "afterfly",
              decision: "hold",
              appVisibility: "hidden",
              checklist: {
                identityReviewed: true,
                surfaceInventoryReviewed: true,
                ownerSafeCopyReviewed: true,
                marketScopeReviewed: true,
                mediaRightsReviewed: false,
                crawlDisabledReviewed: true,
              },
              note: "Manual QA held AFTER FLY.",
            },
            suppress: {
              entityId: "afterfly",
              decision: "suppress",
              appVisibility: "hidden",
              checklist: {
                identityReviewed: true,
                surfaceInventoryReviewed: true,
                ownerSafeCopyReviewed: true,
                marketScopeReviewed: true,
                mediaRightsReviewed: false,
                crawlDisabledReviewed: true,
              },
              note: "Manual QA suppressed AFTER FLY.",
            },
          },
          safeDefaultPayload: {
            entityId: "afterfly",
            decision: "hold",
            appVisibility: "hidden",
            checklist: {
              identityReviewed: true,
              surfaceInventoryReviewed: true,
              ownerSafeCopyReviewed: true,
              marketScopeReviewed: true,
              mediaRightsReviewed: false,
              crawlDisabledReviewed: true,
            },
            note: "Manual QA held AFTER FLY.",
          },
        },
        commands: [
          "node tool/organizer_intake/review_decision.mjs draft afterfly",
        ],
      },
      {
        requestId: "policy:recurring_event_crawl_policy",
        requestType: "policy_decision",
        priority: "p1",
        owner: "product_ops",
        subjectId: "recurring_event_crawl_policy",
        subjectName: "Crawl Policy",
        prompt: "Should crawls be enabled?",
        decisionOptions: ["accept", "hold", "reject"],
        safeDefaultAction: "keep_scheduler_disabled",
        requiredInputs: [
          {
            input: "platform allowlist",
            prompt: "Which platforms can be crawled?",
            recommendedSafeDefault: "keep_scheduler_disabled",
            requiredForAcceptance: true,
          },
          {
            input: "monthly crawl cap",
            prompt: "What monthly crawl cap should apply?",
            recommendedSafeDefault: "keep_scheduler_disabled",
            requiredForAcceptance: true,
          },
        ],
        currentState: {
          implementationGate: "scheduler policy encoded",
        },
        callableSubmission: {
          callableName: "adminDecideOrganizerPolicyGap",
          adminApiWrapper: "decideOrganizerPolicyGap",
          payloadType: "AdminDecideOrganizerPolicyGapPayload",
          firestoreCollection: "organizerPolicyGapReviewDecisions",
          payloadsByDecision: {
            accept: {
              gapId: "recurring_event_crawl_policy",
              decision: "accept",
              requiredInputsReviewed: [
                "monthly crawl cap",
                "platform allowlist",
              ],
              checklist: {
                requiredInputsReviewed: true,
                costAndSafetyReviewed: true,
                implementationOwnerReviewed: true,
                behaviorStillDisabledAcknowledged: true,
              },
              note: "Product policy accepted.",
            },
            hold: {
              gapId: "recurring_event_crawl_policy",
              decision: "hold",
              requiredInputsReviewed: [],
              checklist: {
                requiredInputsReviewed: false,
                costAndSafetyReviewed: false,
                implementationOwnerReviewed: true,
                behaviorStillDisabledAcknowledged: true,
              },
              note: "Product policy held.",
            },
            reject: {
              gapId: "recurring_event_crawl_policy",
              decision: "reject",
              requiredInputsReviewed: [],
              checklist: {
                requiredInputsReviewed: false,
                costAndSafetyReviewed: false,
                implementationOwnerReviewed: true,
                behaviorStillDisabledAcknowledged: true,
              },
              note: "Product policy rejected.",
            },
          },
          safeDefaultPayload: {
            gapId: "recurring_event_crawl_policy",
            decision: "hold",
            requiredInputsReviewed: [],
            checklist: {
              requiredInputsReviewed: false,
              costAndSafetyReviewed: false,
              implementationOwnerReviewed: true,
              behaviorStillDisabledAcknowledged: true,
            },
            note: "Product policy held.",
          },
        },
        commands: [
          "node tool/organizer_intake/policy_gap_decision.mjs draft recurring_event_crawl_policy",
        ],
      },
    ],
    followUps: [
      {
        followUpId: "workflow:claim_target_sync",
        workstreamId: "claim_target_sync",
        status: "waiting_on_public_projection",
        priority: "p2",
        nextActions: ["Wait for public projection."],
        commands: [
          "node tool/organizer_intake/sync_claim_targets_to_firestore.mjs",
        ],
      },
    ],
  };
}
