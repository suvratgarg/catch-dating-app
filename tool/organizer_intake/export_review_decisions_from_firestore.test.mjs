import assert from "node:assert/strict";
import test from "node:test";
import {buildReviewDecisionBatchFromFirestoreDocs} from
  "./export_review_decisions_from_firestore.mjs";

test("buildReviewDecisionBatchFromFirestoreDocs maps Firestore docs to tooling decisions", () => {
  const batch = buildReviewDecisionBatchFromFirestoreDocs([
    {
      id: "bhag",
      path: "organizerIntakeReviewDecisions/bhag",
      data: holdDoc("bhag"),
    },
    {
      id: "afterfly",
      path: "organizerIntakeReviewDecisions/afterfly",
      data: approvalDoc("afterfly"),
    },
  ], {
    date: "2026-06-17",
    sourceLabel: "Dev Project",
  });

  assert.equal(batch.decisionBatchId, "firestore-dev-project-2026-06-17");
  assert.equal(batch.decidedAt, "2026-06-17");
  assert.equal(batch.reviewer, "firestore:dev-project");
  assert.deepEqual(
    batch.decisions.map((decision) => decision.entityId),
    ["afterfly", "bhag"]
  );
  assert.equal(batch.decisions[0].decision, "approve_public");
  assert.equal(batch.decisions[0].checklist.manualReportsReviewed, true);
  assert.equal(batch.decisions[1].decision, "hold");
});

test("buildReviewDecisionBatchFromFirestoreDocs rejects mismatched document ids", () => {
  assert.throws(
    () => buildReviewDecisionBatchFromFirestoreDocs([
      {
        id: "wrong-id",
        path: "organizerIntakeReviewDecisions/wrong-id",
        data: approvalDoc("afterfly"),
      },
    ], {
      date: "2026-06-17",
      sourceLabel: "fixture",
    }),
    /document id does not match entityId/
  );
});

test("buildReviewDecisionBatchFromFirestoreDocs rejects incomplete approvals", () => {
  const doc = approvalDoc("afterfly");
  doc.checklist.mediaRightsReviewed = false;

  assert.throws(
    () => buildReviewDecisionBatchFromFirestoreDocs([
      {
        id: "afterfly",
        path: "organizerIntakeReviewDecisions/afterfly",
        data: doc,
      },
    ], {
      date: "2026-06-17",
      sourceLabel: "fixture",
    }),
    /incomplete checklist/
  );
});

function approvalDoc(entityId) {
  return {
    schemaVersion: 1,
    entityId,
    decision: "approve_public",
    decisionStatus: "approved_public",
    appVisibility: "hidden",
    checklist: {
      crawlDisabledReviewed: true,
      identityReviewed: true,
      marketScopeReviewed: true,
      manualReportsReviewed: true,
      mediaRightsReviewed: true,
      ownerSafeCopyReviewed: true,
      surfaceInventoryReviewed: true,
    },
    note: "Manual QA complete.",
    reviewedByUid: "admin-1",
    reviewedAt: {_seconds: 1781654400, _nanoseconds: 0},
    updatedAt: {_seconds: 1781654400, _nanoseconds: 0},
    projectionState: "pending_static_generation",
  };
}

function holdDoc(entityId) {
  return {
    ...approvalDoc(entityId),
    decision: "hold",
    decisionStatus: "held",
    checklist: {
      crawlDisabledReviewed: false,
      identityReviewed: true,
      marketScopeReviewed: true,
      mediaRightsReviewed: false,
      ownerSafeCopyReviewed: true,
      surfaceInventoryReviewed: true,
    },
    note: "Need stronger source evidence before publication.",
    projectionState: "not_projectable",
  };
}
