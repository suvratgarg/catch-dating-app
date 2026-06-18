import assert from "node:assert/strict";
import test from "node:test";
import {buildPendingDecisionAnswerPlan} from
  "./lib/pending_decision_answer_plan_core.mjs";

test("answer plan reports pending generated answers without failing", () => {
  const plan = buildPendingDecisionAnswerPlan(packet());

  assert.equal(plan.ok, true);
  assert.equal(plan.summary.status, "awaiting_answers");
  assert.equal(plan.summary.pendingAnswers, 2);
  assert.equal(plan.summary.plannedActions, 0);
});

test("answer plan builds dry-run and write commands for completed answers", () => {
  const payload = packet();
  payload.answerTemplate.reviewer = "admin";
  payload.answerTemplate.decidedAt = "2026-06-18";
  payload.answerTemplate.answers[0] = {
    answerId: "admin-publication:afterfly",
    decision: "approve_public",
    note: "Manual QA approved Afterfly.",
    acknowledgements: {
      crawlDisabledReviewed: true,
      identityReviewed: true,
      manualReportsReviewed: true,
      marketScopeReviewed: true,
      mediaRightsReviewed: true,
      ownerSafeCopyReviewed: true,
      surfaceInventoryReviewed: true,
    },
    requiredInputsReviewed: [],
  };
  payload.answerTemplate.answers[1] = {
    answerId: "policy:recurring_event_crawl_policy",
    decision: "accept",
    note: "Policy accepted with reviewed inputs.",
    acknowledgements: {
      behaviorStillDisabledAcknowledged: true,
      costAndSafetyReviewed: true,
      implementationOwnerReviewed: true,
      requiredInputsReviewed: true,
    },
    requiredInputsReviewed: ["platform allowlist"],
  };

  const plan = buildPendingDecisionAnswerPlan(payload, {requireComplete: true});

  assert.equal(plan.ok, true);
  assert.equal(plan.summary.status, "ready_to_draft_decisions");
  assert.equal(plan.summary.plannedActions, 2);
  assert.match(
    plan.plannedActions[0].dryRunCommand,
    /review_decision\.mjs draft afterfly --decision approve_public/
  );
  assert.match(
    plan.plannedActions[0].dryRunCommand,
    /--confirm-manual-reports-reviewed --dry-run/
  );
  assert.match(
    plan.plannedActions[1].dryRunCommand,
    /policy_gap_decision\.mjs draft recurring_event_crawl_policy/
  );
  assert.match(plan.plannedActions[1].dryRunCommand, /--confirm-required-inputs/);
  assert(!plan.plannedActions[1].writeCommand.includes("--dry-run"));
});

test("answer plan rejects incomplete approval acknowledgements", () => {
  const payload = packet();
  payload.answerTemplate.reviewer = "admin";
  payload.answerTemplate.decidedAt = "2026-06-18";
  payload.answerTemplate.answers[0].decision = "approve_public";
  payload.answerTemplate.answers[0].note = "Approved.";
  payload.answerTemplate.answers[0].acknowledgements.identityReviewed = true;

  const plan = buildPendingDecisionAnswerPlan(payload);

  assert.equal(plan.ok, false);
  assert(
    plan.errors.some((error) =>
      error.includes("manualReportsReviewed acknowledgement is required"))
  );
});

test("answer plan rejects incomplete accepted policy inputs", () => {
  const payload = packet();
  payload.answerTemplate.reviewer = "admin";
  payload.answerTemplate.decidedAt = "2026-06-18";
  payload.answerTemplate.answers[1] = {
    answerId: "policy:recurring_event_crawl_policy",
    decision: "accept",
    note: "Accepted.",
    acknowledgements: {
      behaviorStillDisabledAcknowledged: true,
      costAndSafetyReviewed: true,
      implementationOwnerReviewed: true,
      requiredInputsReviewed: true,
    },
    requiredInputsReviewed: [],
  };

  const plan = buildPendingDecisionAnswerPlan(payload);

  assert.equal(plan.ok, false);
  assert(
    plan.errors.some((error) =>
      error.includes("missing required inputs platform allowlist"))
  );
});

function packet() {
  return {
    schemaVersion: 1,
    answerSlots: [
      {
        answerId: "admin-publication:afterfly",
        requestType: "admin_publication_decision",
        subjectId: "afterfly",
        subjectName: "AFTER FLY",
        decisionOptions: ["approve_public", "hold", "suppress"],
        requiredAcknowledgements: [
          "crawlDisabledReviewed",
          "identityReviewed",
          "manualReportsReviewed",
          "marketScopeReviewed",
          "mediaRightsReviewed",
          "ownerSafeCopyReviewed",
          "surfaceInventoryReviewed",
        ],
        requiredInputs: [],
        safeDefaultPayload: {
          appVisibility: "hidden",
        },
      },
      {
        answerId: "policy:recurring_event_crawl_policy",
        requestType: "policy_decision",
        subjectId: "recurring_event_crawl_policy",
        subjectName: "crawl",
        decisionOptions: ["accept", "hold", "reject"],
        requiredAcknowledgements: [
          "behaviorStillDisabledAcknowledged",
          "costAndSafetyReviewed",
          "implementationOwnerReviewed",
          "requiredInputsReviewed",
        ],
        requiredInputs: [
          {
            input: "platform allowlist",
          },
        ],
      },
    ],
    answerTemplate: {
      reviewer: "",
      decidedAt: "YYYY-MM-DD",
      answers: [
        {
          answerId: "admin-publication:afterfly",
          decision: null,
          note: "",
          acknowledgements: {
            crawlDisabledReviewed: false,
            identityReviewed: false,
            manualReportsReviewed: false,
            marketScopeReviewed: false,
            mediaRightsReviewed: false,
            ownerSafeCopyReviewed: false,
            surfaceInventoryReviewed: false,
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
  };
}
