import assert from "node:assert/strict";
import test from "node:test";
import {
  createDecisionAnswerPacketDraft,
  outputPathForDraft,
} from "./create_decision_answer_packet.mjs";

test("createDecisionAnswerPacketDraft stamps reviewer metadata without answering", () => {
  const result = createDecisionAnswerPacketDraft(packet(), {
    date: "2026-06-18",
    reviewer: "Admin Reviewer",
    slug: "Afterfly pass",
    sourcePath:
      "/repo/tool/organizer_intake/generated/organizer_pending_decision_answer_packet.json",
  });

  assert.equal(result.ok, true, result.errors.join("\n"));
  assert.equal(result.summary.answerSlots, 1);
  assert.equal(result.summary.slug, "afterfly-pass");
  assert.equal(result.draft.answerTemplate.reviewer, "Admin Reviewer");
  assert.equal(result.draft.answerTemplate.decidedAt, "2026-06-18");
  assert.equal(result.draft.answerTemplate.answers[0].decision, null);
  assert.equal(result.draft.reviewDraft.createdAt, "2026-06-18");
  assert.equal(result.draft.reviewDraft.sourceFingerprint.algorithm, "sha256");
  assert.match(result.draft.reviewDraft.sourceFingerprint.value, /^[a-f0-9]{64}$/);
  assert.match(
    result.draft.reviewDraft.instructions.join("\n"),
    /pending_decision_answer_plan\.mjs/
  );
});

test("createDecisionAnswerPacketDraft validates required metadata", () => {
  const result = createDecisionAnswerPacketDraft(packet(), {
    date: "2026/06/18",
    reviewer: "",
  });

  assert.equal(result.ok, false);
  assert(result.errors.includes("date must use YYYY-MM-DD."));
  assert(result.errors.includes("reviewer is required."));
});

test("outputPathForDraft creates stable slugged paths", () => {
  assert.equal(
    outputPathForDraft({
      date: "2026-06-18",
      outputRoot: "/tmp/answer_packets",
      slug: "Admin Review: Mumbai",
    }),
    "/tmp/answer_packets/2026-06-18-admin-review-mumbai.json"
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
