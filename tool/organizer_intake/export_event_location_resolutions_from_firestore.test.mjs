import assert from "node:assert/strict";
import test from "node:test";
import {buildEventLocationResolutionBatchFromFirestoreDocs} from
  "./export_event_location_resolutions_from_firestore.mjs";

test("buildEventLocationResolutionBatchFromFirestoreDocs maps Firestore docs",
  () => {
    const batch = buildEventLocationResolutionBatchFromFirestoreDocs([
      {
        id: "loc-2026-06-17-afterfly-luma-events-pxgmph3b",
        path:
          "organizerEventLocationResolutionDecisions/" +
          "loc-2026-06-17-afterfly-luma-events-pxgmph3b",
        data: resolutionDoc(),
      },
      {
        id: "loc-later-candidate",
        path:
          "organizerEventLocationResolutionDecisions/loc-later-candidate",
        data: {
          ...resolutionDoc(),
          resolutionId: "loc-later-candidate",
          candidateId: "later-candidate",
        },
      },
    ], {
      date: "2026-06-17",
      sourceLabel: "Dev Project",
    });

    assert.equal(
      batch.locationResolutionBatchId,
      "firestore-dev-project-2026-06-17"
    );
    assert.equal(batch.resolvedAt, "2026-06-17");
    assert.equal(batch.reviewer, "firestore:dev-project");
    assert.deepEqual(
      batch.resolutions.map((resolution) => resolution.candidateId),
      [
        "2026-06-17-afterfly-luma-events:pxgmph3b",
        "later-candidate",
      ]
    );
    assert.equal(batch.resolutions[0].location.name, "Nehru Stadium");
  });

test("buildEventLocationResolutionBatchFromFirestoreDocs rejects bad ids",
  () => {
    assert.throws(
      () => buildEventLocationResolutionBatchFromFirestoreDocs([
        {
          id: "wrong-id",
          path: "organizerEventLocationResolutionDecisions/wrong-id",
          data: resolutionDoc(),
        },
      ], {
        date: "2026-06-17",
        sourceLabel: "fixture",
      }),
      /document id does not match resolutionId/
    );
  });

test("buildEventLocationResolutionBatchFromFirestoreDocs rejects incomplete checks",
  () => {
    const doc = resolutionDoc();
    doc.checklist.coordinatesReviewed = false;

    assert.throws(
      () => buildEventLocationResolutionBatchFromFirestoreDocs([
        {
          id: "loc-2026-06-17-afterfly-luma-events-pxgmph3b",
          path:
            "organizerEventLocationResolutionDecisions/" +
            "loc-2026-06-17-afterfly-luma-events-pxgmph3b",
          data: doc,
        },
      ], {
        date: "2026-06-17",
        sourceLabel: "fixture",
      }),
      /incomplete checklist/
    );
  });

test("buildEventLocationResolutionBatchFromFirestoreDocs rejects null coordinates",
  () => {
    const doc = resolutionDoc();
    doc.location.latitude = null;

    assert.throws(
      () => buildEventLocationResolutionBatchFromFirestoreDocs([
        {
          id: "loc-2026-06-17-afterfly-luma-events-pxgmph3b",
          path:
            "organizerEventLocationResolutionDecisions/" +
            "loc-2026-06-17-afterfly-luma-events-pxgmph3b",
          data: doc,
        },
      ], {
        date: "2026-06-17",
        sourceLabel: "fixture",
      }),
      /requires exact coordinates/
    );
  });

function resolutionDoc() {
  return {
    schemaVersion: 1,
    resolutionId: "loc-2026-06-17-afterfly-luma-events-pxgmph3b",
    candidateId: "2026-06-17-afterfly-luma-events:pxgmph3b",
    location: {
      name: "Nehru Stadium",
      address: "Nehru Stadium, Indore, Madhya Pradesh",
      placeId: "ChIJ-afterfly-indore",
      latitude: 22.7196,
      longitude: 75.8577,
      notes: "Matched to source listing and map result.",
    },
    checklist: completeChecklist(),
    note: "Manual location QA complete.",
    reviewedByUid: "admin-1",
    reviewedAt: {_seconds: 1781654400, _nanoseconds: 0},
    updatedAt: {_seconds: 1781654400, _nanoseconds: 0},
    resolutionStatus: "resolved",
  };
}

function completeChecklist() {
  return {
    sourceLocationReviewed: true,
    coordinatesReviewed: true,
    placeIdentityReviewed: true,
    importSafetyReviewed: true,
  };
}
