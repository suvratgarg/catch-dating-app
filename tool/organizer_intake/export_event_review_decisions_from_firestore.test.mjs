import assert from "node:assert/strict";
import test from "node:test";
import {buildEventReviewDecisionBatchFromFirestoreDocs} from
  "./export_event_review_decisions_from_firestore.mjs";

test("buildEventReviewDecisionBatchFromFirestoreDocs maps Firestore docs", () => {
  const batch = buildEventReviewDecisionBatchFromFirestoreDocs([
    {
      id: "event-2026-06-17-afterfly-luma-events-pxgmph3b",
      path:
        "organizerEventCandidateReviewDecisions/" +
        "event-2026-06-17-afterfly-luma-events-pxgmph3b",
      data: approvalDoc(),
    },
    {
      id: "event-held-candidate",
      path: "organizerEventCandidateReviewDecisions/event-held-candidate",
      data: holdDoc(),
    },
  ], {
    date: "2026-06-17",
    sourceLabel: "Dev Project",
  });

  assert.equal(batch.eventReviewBatchId, "firestore-dev-project-2026-06-17");
  assert.equal(batch.decidedAt, "2026-06-17");
  assert.equal(batch.reviewer, "firestore:dev-project");
  assert.deepEqual(
    batch.decisions.map((decision) => decision.candidateId),
    [
      "2026-06-17-afterfly-luma-events:pxgmph3b",
      "held-candidate",
    ]
  );
  assert.equal(batch.decisions[0].decision, "approve_for_import");
  assert.equal(batch.decisions[1].decision, "hold");
});

test("buildEventReviewDecisionBatchFromFirestoreDocs rejects mismatched ids", () => {
  assert.throws(
    () => buildEventReviewDecisionBatchFromFirestoreDocs([
      {
        id: "wrong-id",
        path: "organizerEventCandidateReviewDecisions/wrong-id",
        data: approvalDoc(),
      },
    ], {
      date: "2026-06-17",
      sourceLabel: "fixture",
    }),
    /document id does not match decisionId/
  );
});

test("buildEventReviewDecisionBatchFromFirestoreDocs rejects incomplete approvals", () => {
  const doc = approvalDoc();
  doc.checklist.dedupeReviewed = false;

  assert.throws(
    () => buildEventReviewDecisionBatchFromFirestoreDocs([
      {
        id: "event-2026-06-17-afterfly-luma-events-pxgmph3b",
        path:
          "organizerEventCandidateReviewDecisions/" +
          "event-2026-06-17-afterfly-luma-events-pxgmph3b",
        data: doc,
      },
    ], {
      date: "2026-06-17",
      sourceLabel: "fixture",
    }),
    /incomplete checklist/
  );
});

function approvalDoc() {
  return {
    schemaVersion: 1,
    decisionId: "event-2026-06-17-afterfly-luma-events-pxgmph3b",
    candidateId: "2026-06-17-afterfly-luma-events:pxgmph3b",
    decision: "approve_for_import",
    decisionStatus: "approved_for_import",
    checklist: completeChecklist(),
    note: "Manual event QA complete.",
    reviewedByUid: "admin-1",
    reviewedAt: {_seconds: 1781654400, _nanoseconds: 0},
    updatedAt: {_seconds: 1781654400, _nanoseconds: 0},
    importState: "blocked_by_policy",
  };
}

function holdDoc() {
  return {
    ...approvalDoc(),
    decisionId: "event-held-candidate",
    candidateId: "held-candidate",
    decision: "hold",
    decisionStatus: "held",
    checklist: {
      ...completeChecklist(),
      dedupeReviewed: false,
      locationReviewed: false,
    },
    note: "Need location review before import.",
    importState: "not_importable",
  };
}

function completeChecklist() {
  return {
    dedupeReviewed: true,
    identityReviewed: true,
    importPolicyAcknowledged: true,
    locationReviewed: true,
    ownerSafeCopyReviewed: true,
    sourceEventReviewed: true,
    timeReviewed: true,
  };
}
