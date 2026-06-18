import assert from "node:assert/strict";
import test from "node:test";
import {buildCurationDecisionBatchFromFirestoreDocs} from
  "./export_curation_decisions_from_firestore.mjs";

test("buildCurationDecisionBatchFromFirestoreDocs maps active Firestore docs", () => {
  const batch = buildCurationDecisionBatchFromFirestoreDocs([
    {
      id: "merge-afterfly-old-to-afterfly",
      path: "organizerIntakeCurationDecisions/merge-afterfly-old-to-afterfly",
      data: mergeDoc(),
    },
    {
      id: "attach-afterfly-afterfly-sort-my-scene",
      path: "organizerIntakeCurationDecisions/attach-afterfly-afterfly-sort-my-scene",
      data: attachDoc(),
    },
    {
      id: "suppress-stale-candidate",
      path: "organizerIntakeCurationDecisions/suppress-stale-candidate",
      data: suppressDoc("superseded"),
    },
  ], {
    date: "2026-06-17",
    sourceLabel: "Dev Project",
  });

  assert.equal(batch.curationBatchId, "firestore-dev-project-2026-06-17");
  assert.equal(batch.decidedAt, "2026-06-17");
  assert.equal(batch.reviewer, "firestore:dev-project");
  assert.deepEqual(
    batch.operations.map((operation) => operation.type),
    ["attach_surface", "merge_entity"]
  );
  assert.equal(batch.operations[0].entityId, "afterfly");
  assert.equal(batch.operations[1].targetEntityId, "afterfly");
});

test("buildCurationDecisionBatchFromFirestoreDocs rejects mismatched ids", () => {
  assert.throws(
    () => buildCurationDecisionBatchFromFirestoreDocs([
      {
        id: "wrong-id",
        path: "organizerIntakeCurationDecisions/wrong-id",
        data: attachDoc(),
      },
    ], {
      date: "2026-06-17",
      sourceLabel: "fixture",
    }),
    /document id does not match operationId/
  );
});

test("buildCurationDecisionBatchFromFirestoreDocs rejects crawl-enabled attach ops", () => {
  const doc = attachDoc();
  doc.surface.crawl.eventDiscoveryStatus = "approved";

  assert.throws(
    () => buildCurationDecisionBatchFromFirestoreDocs([
      {
        id: "attach-afterfly-afterfly-sort-my-scene",
        path: "organizerIntakeCurationDecisions/attach-afterfly-afterfly-sort-my-scene",
        data: doc,
      },
    ], {
      date: "2026-06-17",
      sourceLabel: "fixture",
    }),
    /must keep crawl disabled/
  );
});

function attachDoc() {
  return {
    schemaVersion: 1,
    operationId: "attach-afterfly-afterfly-sort-my-scene",
    operationType: "attach_surface",
    operationStatus: "active",
    entityId: "afterfly",
    sourceCandidateId: "2026-06-17-afterfly-search-fixture:sort-my-scene",
    surfaceId: "afterfly-sort-my-scene",
    surface: {
      surfaceId: "afterfly-sort-my-scene",
      platform: "sortMyScene",
      surfaceKind: "organizerProfile",
      url: "https://sortmyscene.com/organizer/afterfly",
      normalizedKey: "sortmyscene:organizer:afterfly",
      role: "secondary",
      status: "candidate",
      confidence: {
        city: "medium",
        entityMatch: "high",
        ownership: "medium",
      },
      crawl: {
        eventDiscoveryStatus: "disabled",
        policy: "manualOnly",
        supportsEventExtraction: false,
      },
      evidenceRefs: [],
      notes: "Search candidate title: Afterfly.",
    },
    reason: "Surface belongs to this organizer.",
    reviewedByUid: "admin-1",
    reviewedAt: {_seconds: 1781654400, _nanoseconds: 0},
    updatedAt: {_seconds: 1781654400, _nanoseconds: 0},
  };
}

function mergeDoc() {
  return {
    schemaVersion: 1,
    operationId: "merge-afterfly-old-to-afterfly",
    operationType: "merge_entity",
    operationStatus: "active",
    sourceEntityId: "afterfly-old",
    targetEntityId: "afterfly",
    reason: "Duplicate organizer candidate for the same host.",
    reviewedByUid: "admin-1",
    reviewedAt: {_seconds: 1781654400, _nanoseconds: 0},
    updatedAt: {_seconds: 1781654400, _nanoseconds: 0},
  };
}

function suppressDoc(operationStatus) {
  return {
    schemaVersion: 1,
    operationId: "suppress-stale-candidate",
    operationType: "suppress_entity",
    operationStatus,
    entityId: "stale-candidate",
    reason: "Superseded decisions remain audited but are not exported.",
    reviewedByUid: "admin-1",
    reviewedAt: {_seconds: 1781654400, _nanoseconds: 0},
    updatedAt: {_seconds: 1781654400, _nanoseconds: 0},
  };
}
