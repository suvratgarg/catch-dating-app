import assert from "node:assert/strict";
import test from "node:test";
import {HttpsError} from "firebase-functions/v2/https";
import type {OrganizerEventSuccessLayoutDocument} from
  "../shared/generated/firestoreAdminTypes";
import {
  confirmedSpatialUnitId,
  releasedSpatialPlanFields,
  requireSpatialRevision,
  resolveSpatialDestinations,
  spatialReassignmentPlanFields,
} from "./spatialControl";

const layout = {
  organizerId: "organizer-1",
  layoutId: "layout-1",
  label: "Main room",
  units: [
    {id: "source", label: "Source", shape: "round" as const, capacity: 4,
      gridX: 0, gridY: 0, order: 1},
    {id: "full", label: "Full", shape: "rect" as const, capacity: 1,
      gridX: 1, gridY: 0, order: 2},
    {id: "unsafe", label: "Unsafe", shape: "row" as const, capacity: 2,
      gridX: 2, gridY: 0, order: 3},
    {id: "apart", label: "Apart", shape: "court" as const, capacity: 2,
      gridX: 3, gridY: 0, order: 4},
    {id: "valid", label: "Valid", shape: "zone" as const, capacity: 2,
      gridX: 4, gridY: 0, order: 5},
  ],
  createdAt: null as never,
  updatedAt: null as never,
} satisfies OrganizerEventSuccessLayoutDocument;

test("destinations report reasons and default named moves pinned", () => {
  const result = resolveSpatialDestinations({
    layout,
    selectedUid: "selected",
    assignments: [
      {uid: "selected", layoutUnitId: "source"},
      {uid: "full-peer", layoutUnitId: "full"},
      {uid: "blocked-peer", layoutUnitId: "unsafe"},
      {uid: "apart-peer", layoutUnitId: "apart"},
      {uid: "valid-peer", layoutUnitId: "valid"},
    ],
    blockedPairs: new Set(["blocked-peer__selected"]),
    affinityConstraints: [{
      aUid: "selected",
      bUid: "apart-peer",
      value: "mustSplit",
      scope: "pinned",
    }],
  });
  assert.deepEqual(result.map((destination) => [
    destination.unitId,
    destination.valid,
    destination.reason,
    destination.recommendedScope,
  ]), [
    ["source", false, "declaredConstraint", null],
    ["full", false, "capacity", null],
    ["unsafe", false, "safetyKeepApart", null],
    ["apart", false, "declaredConstraint", null],
    ["valid", true, null, "pinned"],
  ]);
});

test("every reassignment persists an explicit scoped T2 constraint", () => {
  for (const scope of ["thisRound", "pinned"] as const) {
    const fields = spatialReassignmentPlanFields({
      plan: {affinityConstraints: [], spatialOverrides: []},
      uid: "selected",
      targetPeerUid: "peer",
      layoutUnitId: "valid",
      scope,
    });
    assert.deepEqual(fields.affinityConstraints, [{
      aUid: "selected",
      bUid: "peer",
      value: "mustPair",
      scope,
    }]);
    assert.deepEqual(fields.spatialOverrides, [{
      uid: "selected",
      targetPeerUid: "peer",
      layoutUnitId: "valid",
      scope,
    }]);
  }
});

test("release removes the selected pinned placement and constraint", () => {
  const retainedConstraint = {
    aUid: "other",
    bUid: "peer-2",
    value: "mustPair" as const,
    scope: "pinned" as const,
  };
  const retainedOverride = {
    uid: "other",
    targetPeerUid: "peer-2",
    layoutUnitId: "valid",
    scope: "pinned" as const,
  };
  assert.deepEqual(releasedSpatialPlanFields({
    uid: "selected",
    plan: {
      affinityConstraints: [{
        aUid: "selected",
        bUid: "peer",
        value: "mustPair",
        scope: "pinned",
      }, retainedConstraint],
      spatialOverrides: [{
        uid: "selected",
        targetPeerUid: "peer",
        layoutUnitId: "valid",
        scope: "pinned",
      }, retainedOverride],
    },
  }), {
    affinityConstraints: [retainedConstraint],
    spatialOverrides: [retainedOverride],
  });
});

test("spatial action and pre-generation share one revision fence", () => {
  const afterReassignment = requireSpatialRevision(7, 7);
  assert.equal(afterReassignment, 8);
  assert.throws(
    () => requireSpatialRevision(afterReassignment, 7),
    (error: unknown) => error instanceof HttpsError && error.code === "aborted"
  );
});

test("Host confirmation copies only the current assigned position", () => {
  assert.equal(
    confirmedSpatialUnitId({uid: "selected", layoutUnitId: "valid"}),
    "valid"
  );
  assert.throws(
    () => confirmedSpatialUnitId({uid: "selected"}),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "failed-precondition"
  );
});
