import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import test from "node:test";
import {buildPolicyGapDecisionBatchFromFirestoreDocs} from
  "./export_policy_gap_decisions_from_firestore.mjs";

test("buildPolicyGapDecisionBatchFromFirestoreDocs maps Firestore docs", () => {
  const batch = buildPolicyGapDecisionBatchFromFirestoreDocs([
    {
      id: "policy-recurring-event-crawl-policy",
      path:
        "organizerPolicyGapReviewDecisions/" +
        "policy-recurring-event-crawl-policy",
      data: acceptanceDoc(),
    },
    {
      id: "policy-external-event-import-write-policy",
      path:
        "organizerPolicyGapReviewDecisions/" +
        "policy-external-event-import-write-policy",
      data: holdDoc(),
    },
  ], {
    date: "2026-06-17",
    sourceLabel: "Dev Project",
  });

  assert.equal(
    batch.policyGapDecisionBatchId,
    "firestore-dev-project-2026-06-17"
  );
  assert.equal(batch.decidedAt, "2026-06-17");
  assert.equal(batch.reviewer, "firestore:dev-project");
  assert.deepEqual(
    batch.decisions.map((decision) => decision.gapId),
    [
      "external_event_import_write_policy",
      "recurring_event_crawl_policy",
    ]
  );
  assert.equal(batch.decisions[0].decision, "hold");
  assert.equal(batch.decisions[1].decision, "accept");
});

test("buildPolicyGapDecisionBatchFromFirestoreDocs rejects mismatched ids", () => {
  assert.throws(
    () => buildPolicyGapDecisionBatchFromFirestoreDocs([
      {
        id: "wrong-id",
        path: "organizerPolicyGapReviewDecisions/wrong-id",
        data: acceptanceDoc(),
      },
    ], {
      date: "2026-06-17",
      sourceLabel: "fixture",
    }),
    /document id does not match decisionId/
  );
});

test("buildPolicyGapDecisionBatchFromFirestoreDocs rejects incomplete acceptance", () => {
  const doc = acceptanceDoc();
  doc.checklist.behaviorStillDisabledAcknowledged = false;

  assert.throws(
    () => buildPolicyGapDecisionBatchFromFirestoreDocs([
      {
        id: "policy-recurring-event-crawl-policy",
        path:
          "organizerPolicyGapReviewDecisions/" +
          "policy-recurring-event-crawl-policy",
        data: doc,
      },
    ], {
      date: "2026-06-17",
      sourceLabel: "fixture",
    }),
    /incomplete checklist/
  );
});

test("buildPolicyGapDecisionBatchFromFirestoreDocs rejects bad state mapping", () => {
  const doc = holdDoc();
  doc.operationalState = "not_approved";

  assert.throws(
    () => buildPolicyGapDecisionBatchFromFirestoreDocs([
      {
        id: "policy-external-event-import-write-policy",
        path:
          "organizerPolicyGapReviewDecisions/" +
          "policy-external-event-import-write-policy",
        data: doc,
      },
    ], {
      date: "2026-06-17",
      sourceLabel: "fixture",
    }),
    /operationalState/
  );
});

test("policy gap exporter accepts the shared emulator shorthand", () => {
  const result = spawnSync(process.execPath, [
    "tool/organizer_intake/export_policy_gap_decisions_from_firestore.mjs",
    "--help",
    "--emulator",
  ], {
    cwd: process.cwd(),
    encoding: "utf8",
  });

  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /--emulator/);
});

function acceptanceDoc() {
  return {
    schemaVersion: 1,
    decisionId: "policy-recurring-event-crawl-policy",
    gapId: "recurring_event_crawl_policy",
    decision: "accept",
    decisionStatus: "accepted",
    requiredInputsReviewed: [
      "crawl frequency by platform and organizer tier",
      "platform allowlist and fallback order",
    ],
    checklist: completeChecklist(),
    note: "Policy direction reviewed; implementation remains disabled.",
    reviewedByUid: "admin-1",
    reviewedAt: {_seconds: 1781654400, _nanoseconds: 0},
    updatedAt: {_seconds: 1781654400, _nanoseconds: 0},
    operationalState: "blocked_until_policy_encoded",
  };
}

function holdDoc() {
  return {
    ...acceptanceDoc(),
    decisionId: "policy-external-event-import-write-policy",
    gapId: "external_event_import_write_policy",
    decision: "hold",
    decisionStatus: "held",
    requiredInputsReviewed: [],
    checklist: {
      ...completeChecklist(),
      requiredInputsReviewed: false,
      costAndSafetyReviewed: false,
    },
    note: "Need import authority and rollback policy before accepting.",
    operationalState: "blocked_until_policy_encoded",
  };
}

function completeChecklist() {
  return {
    requiredInputsReviewed: true,
    costAndSafetyReviewed: true,
    implementationOwnerReviewed: true,
    behaviorStillDisabledAcknowledged: true,
  };
}
