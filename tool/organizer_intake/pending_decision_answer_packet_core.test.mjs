import assert from "node:assert/strict";
import test from "node:test";
import {buildOrganizerPendingDecisionAnswerPacket} from
  "./lib/pending_decision_answer_packet_core.mjs";

test("pending decision answer packet creates fillable answer slots", () => {
  const packet = buildOrganizerPendingDecisionAnswerPacket({
    pendingInputRequest: pendingInputRequest(),
    pendingWorkCoverage: pendingWorkCoverage(),
  });

  assert.equal(packet.summary.status, "awaiting_user_input");
  assert.equal(packet.summary.answerSlots, 2);
  assert.equal(packet.summary.adminPublicationDecisions, 1);
  assert.equal(packet.summary.policyDecisions, 1);
  assert.equal(packet.summary.requiredPolicyQuestions, 2);
  assert.equal(packet.summary.safeDefaultDecisions, 2);
  assert.equal(packet.summary.workflowFollowUps, 1);
  assert.equal(packet.summary.highestPriority, "p0");
  assert.deepEqual(
    packet.answerTemplate.answers.map((answer) => answer.answerId),
    [
      "admin-publication:afterfly",
      "policy:recurring_event_crawl_policy",
    ]
  );

  const publication = packet.answerSlots.find((slot) =>
    slot.answerId === "admin-publication:afterfly");
  assert.equal(publication.safeDefaultDecision, "hold");
  assert.deepEqual(publication.blockingWorkstreams, ["publication_review"]);
  assert(publication.requiredAcknowledgements.includes("manualReportsReviewed"));
  assert.match(publication.dryRunCommands[0], /review_decision\.mjs draft afterfly/);

  const policy = packet.answerSlots.find((slot) =>
    slot.answerId === "policy:recurring_event_crawl_policy");
  assert.equal(policy.safeDefaultDecision, "hold");
  assert.deepEqual(policy.blockingWorkstreams, ["policy_decisions"]);
  assert.deepEqual(
    policy.requiredInputs.map((input) => input.input),
    ["budget cap", "platform allowlist"]
  );
  assert.match(policy.dryRunCommands[0], /policy_gap_decision\.mjs draft recurring_event_crawl_policy/);
});

test("pending decision answer packet reports untriaged work", () => {
  const packet = buildOrganizerPendingDecisionAnswerPacket({
    pendingInputRequest: pendingInputRequest(),
    pendingWorkCoverage: {
      summary: {untriagedWorkstreams: 1},
      entries: [
        {
          workstreamId: "new_work",
          pendingRequestIds: [],
        },
      ],
    },
  });

  assert.equal(packet.summary.status, "untriaged_work");
  assert.equal(packet.summary.untriagedWorkstreams, 1);
});

function pendingInputRequest() {
  return {
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
          publicationChecklist: ["identityReviewed"],
        },
        callableSubmission: {
          safeDefaultPayload: {
            entityId: "afterfly",
            decision: "hold",
            appVisibility: "hidden",
          },
        },
        sourceArtifacts: ["publication_review_packets.json"],
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
            input: "budget cap",
            prompt: "budget cap for crawl.",
            recommendedSafeDefault: "keep disabled",
            requiredForAcceptance: true,
          },
          {
            input: "platform allowlist",
            prompt: "platform allowlist for crawl.",
            recommendedSafeDefault: "none",
            requiredForAcceptance: true,
          },
        ],
        callableSubmission: {
          safeDefaultPayload: {
            gapId: "recurring_event_crawl_policy",
            decision: "hold",
          },
        },
        sourceArtifacts: ["policy_decision_packets.json"],
      },
    ],
    followUps: [
      {
        followUpId: "workflow:claim_target_sync",
      },
    ],
  };
}

function pendingWorkCoverage() {
  return {
    summary: {untriagedWorkstreams: 0},
    entries: [
      {
        workstreamId: "publication_review",
        pendingRequestIds: ["admin-publication:afterfly"],
      },
      {
        workstreamId: "policy_decisions",
        pendingRequestIds: ["policy:recurring_event_crawl_policy"],
      },
    ],
  };
}
