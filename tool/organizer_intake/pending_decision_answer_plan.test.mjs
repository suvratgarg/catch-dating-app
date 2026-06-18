import assert from "node:assert/strict";
import test from "node:test";
import {
  checkPendingDecisionAnswerPlan,
  renderPendingDecisionAnswerPlanMarkdown,
} from "./pending_decision_answer_plan.mjs";

test("checker accepts current incomplete generated answer packet", () => {
  const result = checkPendingDecisionAnswerPlan(packet());

  assert.equal(result.ok, true);
  assert.equal(result.summary.status, "awaiting_answers");
  assert.equal(result.summary.pendingAnswers, 1);
  assert.equal(result.summary.plannedActions, 0);
});

test("checker can require completed answers", () => {
  const result = checkPendingDecisionAnswerPlan(packet(), {
    requireComplete: true,
  });

  assert.equal(result.ok, false);
  assert(
    result.errors.some((error) =>
      error.includes("1 answer(s) are still pending"))
  );
});

test("markdown renderer includes commands for filled answers", () => {
  const payload = packet();
  payload.answerTemplate.reviewer = "admin";
  payload.answerTemplate.decidedAt = "2026-06-18";
  payload.answerTemplate.answers[0].decision = "hold";
  payload.answerTemplate.answers[0].note = "Keep held.";
  const plan = checkPendingDecisionAnswerPlan(payload, {
    requireComplete: true,
  });

  const markdown = renderPendingDecisionAnswerPlanMarkdown(plan);

  assert.match(markdown, /# Organizer Pending Decision Answer Plan/);
  assert.match(markdown, /AFTER FLY/);
  assert.match(markdown, /review_decision\.mjs draft afterfly/);
  assert.match(markdown, /--dry-run/);
});

function packet() {
  return {
    answerSlots: [
      {
        answerId: "admin-publication:afterfly",
        requestType: "admin_publication_decision",
        subjectId: "afterfly",
        subjectName: "AFTER FLY",
        decisionOptions: ["approve_public", "hold", "suppress"],
        requiredAcknowledgements: [],
        requiredInputs: [],
        safeDefaultPayload: {
          appVisibility: "hidden",
        },
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
          acknowledgements: {},
          requiredInputsReviewed: [],
        },
      ],
    },
  };
}
