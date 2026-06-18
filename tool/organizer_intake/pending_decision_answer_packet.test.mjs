import assert from "node:assert/strict";
import test from "node:test";
import {
  checkOrganizerPendingDecisionAnswerPacket,
  renderPendingDecisionAnswerPacketMarkdown,
} from "./pending_decision_answer_packet.mjs";

test("checker accepts coherent pending decision answer packet", () => {
  const result = checkOrganizerPendingDecisionAnswerPacket(answerPacket());

  assert.equal(result.ok, true);
  assert.deepEqual(result.errors, []);
  assert.equal(result.summary.status, "awaiting_user_input");
  assert.equal(result.summary.answerSlots, 2);
  assert.equal(result.summary.adminPublicationDecisions, 1);
  assert.equal(result.summary.policyDecisions, 1);
  assert.equal(result.summary.requiredPolicyQuestions, 2);
  assert.equal(result.summary.safeDefaultDecisions, 2);
  assert.equal(result.summary.workflowFollowUps, 1);
  assert.equal(result.summary.untriagedWorkstreams, 0);
  assert.match(result.warnings[0], /2 decision answer slot/);
});

test("markdown renderer names answer slots and safe defaults", () => {
  const markdown = renderPendingDecisionAnswerPacketMarkdown(answerPacket());

  assert.match(markdown, /# Organizer Pending Decision Answers/);
  assert.match(markdown, /AFTER FLY/);
  assert.match(markdown, /recurring_event_crawl_policy/);
  assert.match(markdown, /Safe default decision: hold/);
  assert.match(markdown, /Blocking workstreams: publication_review/);
  assert.match(markdown, /Dry run: `node tool\/organizer_intake\/review_decision\.mjs/);
});

test("checker rejects stale summary and template counts", () => {
  const packet = answerPacket();
  packet.summary.answerSlots = 7;
  packet.summary.workflowFollowUps = 9;
  packet.answerTemplate.answers.pop();

  const result = checkOrganizerPendingDecisionAnswerPacket(packet);

  assert.equal(result.ok, false);
  assert(
    result.errors.some((error) =>
      error.includes("summary.answerSlots 7 does not match 2"))
  );
  assert(
    result.errors.some((error) =>
      error.includes("answerTemplate.answers length 1 does not match 2"))
  );
  assert(
    result.errors.some((error) =>
      error.includes("summary.workflowFollowUps 9 does not match 1"))
  );
});

test("checker rejects unsafe safe default and filled template decision", () => {
  const packet = answerPacket();
  packet.answerSlots[0].safeDefaultDecision = "approve_public";
  packet.answerSlots[0].decisionOptions = ["hold", "suppress"];
  packet.answerTemplate.answers[0].decision = "hold";

  const result = checkOrganizerPendingDecisionAnswerPacket(packet);

  assert.equal(result.ok, false);
  assert(
    result.errors.some((error) =>
      error.includes("safeDefaultDecision is not allowed"))
  );
  assert(
    result.errors.some((error) =>
      error.includes("decision must remain null in template"))
  );
});

function answerPacket() {
  return {
    schemaVersion: 1,
    summary: {
      status: "awaiting_user_input",
      answerSlots: 2,
      adminPublicationDecisions: 1,
      policyDecisions: 1,
      requiredPolicyQuestions: 2,
      safeDefaultDecisions: 2,
      workflowFollowUps: 1,
      untriagedWorkstreams: 0,
    },
    answerTemplate: {
      reviewer: "",
      decidedAt: "YYYY-MM-DD",
      answers: [
        {
          answerId: "admin-publication:afterfly",
          decision: null,
          note: "",
          acknowledgements: {
            identityReviewed: false,
            manualReportsReviewed: false,
          },
          requiredInputsReviewed: [],
        },
        {
          answerId: "policy:recurring_event_crawl_policy",
          decision: null,
          note: "",
          acknowledgements: {
            behaviorStillDisabledAcknowledged: false,
            costAndSafetyReviewed: false,
            implementationOwnerReviewed: false,
            requiredInputsReviewed: false,
          },
          requiredInputsReviewed: [],
        },
      ],
    },
    answerSlots: [
      {
        answerId: "admin-publication:afterfly",
        requestType: "admin_publication_decision",
        priority: "p0",
        owner: "admin",
        subjectId: "afterfly",
        subjectName: "AFTER FLY",
        prompt: "Should AFTER FLY become public?",
        decisionOptions: ["approve_public", "hold", "suppress"],
        safeDefaultAction: "hold",
        safeDefaultDecision: "hold",
        safeDefaultPayload: {
          entityId: "afterfly",
          decision: "hold",
          appVisibility: "hidden",
        },
        requiredAcknowledgements: [
          "identityReviewed",
          "manualReportsReviewed",
        ],
        requiredInputs: [],
        blockingWorkstreams: ["publication_review"],
        dryRunCommands: [
          "node tool/organizer_intake/review_decision.mjs " +
            "draft afterfly --decision hold --app-visibility hidden " +
            "--reviewer REVIEWER --date YYYY-MM-DD " +
            "--note \"Hold pending admin review.\" --dry-run",
        ],
        sourceArtifacts: ["publication_review_packets.json"],
      },
      {
        answerId: "policy:recurring_event_crawl_policy",
        requestType: "policy_decision",
        priority: "p1",
        owner: "product_ops",
        subjectId: "recurring_event_crawl_policy",
        subjectName: "recurring_event_crawl_policy",
        prompt: "Should recurring event crawling be enabled?",
        decisionOptions: ["accept", "hold", "reject"],
        safeDefaultAction: "keep_scheduler_disabled",
        safeDefaultDecision: "hold",
        safeDefaultPayload: {
          gapId: "recurring_event_crawl_policy",
          decision: "hold",
        },
        requiredAcknowledgements: [
          "behaviorStillDisabledAcknowledged",
          "costAndSafetyReviewed",
          "implementationOwnerReviewed",
          "requiredInputsReviewed",
        ],
        requiredInputs: [
          {
            input: "monthly crawl cap",
            prompt: "What monthly crawl cap should apply?",
            recommendedSafeDefault: "keep disabled",
          },
          {
            input: "platform allowlist",
            prompt: "Which platforms can be crawled?",
            recommendedSafeDefault: "none",
          },
        ],
        blockingWorkstreams: ["policy_decisions"],
        dryRunCommands: [
          "node tool/organizer_intake/policy_gap_decision.mjs " +
            "draft recurring_event_crawl_policy --decision hold " +
            "--reviewer REVIEWER --date YYYY-MM-DD " +
            "--note \"Policy still held.\" --dry-run",
        ],
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
