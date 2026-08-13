import assert from "node:assert/strict";
import {readFileSync} from "node:fs";
import {join} from "node:path";
import test from "node:test";
import type {OrganizerEventSuccessLayoutDocument} from
  "../shared/generated/firestoreAdminTypes";
import {
  applyEventSuccessSpatialLayout,
  deriveEventSuccessUnitProximity,
  normalizeEventSuccessLayoutUnits,
  persistentSpatialPlanFields,
} from "./spatialLayout";

type LayoutUnit = OrganizerEventSuccessLayoutDocument["units"][number];

const shapes = ["round", "rect", "row", "court", "zone"] as const;

function unit(
  shape: typeof shapes[number],
  index: number,
  gridX: number,
  gridY: number
): LayoutUnit {
  return {
    id: `${shape}-${index}`,
    label: `${shape} ${index}`,
    shape,
    capacity: 4,
    gridX,
    gridY,
    order: index,
  };
}

function layout(units: LayoutUnit[]): OrganizerEventSuccessLayoutDocument {
  return {
    organizerId: "organizer-1",
    layoutId: "layout-1",
    label: "Main room",
    units,
    createdAt: null as never,
    updatedAt: null as never,
  };
}

test("proximity is derived from coordinates for all five layout shapes", () => {
  for (const shape of shapes) {
    const units = [unit(shape, 1, 0, 0), unit(shape, 2, 3, 4)];
    assert.deepEqual(deriveEventSuccessUnitProximity(units), [{
      aUnitId: `${shape}-1`,
      bUnitId: `${shape}-2`,
      distance: 5,
    }], shape);
  }
});

test("proximity is a complete stable graph without a cutoff", () => {
  const edges = deriveEventSuccessUnitProximity([
    unit("round", 1, 0, 0),
    unit("rect", 2, 1, 0),
    unit("zone", 3, 199, 199),
  ]);
  assert.equal(edges.length, 3);
  assert.equal(edges.at(-1)?.distance, Math.hypot(199, 199));
});

test("backend normalization matches the shared all-shapes fixture", () => {
  const catalog = JSON.parse(readFileSync(
    join(__dirname, "../../../contracts/catalogs/event_success_layout.json"),
    "utf8"
  )) as {
    parityFixture: {
      units: LayoutUnit[];
      normalizedUnits: ReturnType<typeof normalizeEventSuccessLayoutUnits>;
    };
  };
  assert.deepEqual(
    normalizeEventSuccessLayoutUnits(catalog.parityFixture.units),
    catalog.parityFixture.normalizedUnits
  );
});

test("whole-group assignments never receive a spatial projection", () => {
  const assignments = new Map([["user-1", {
    uid: "user-1",
    unitKind: "wholeGroup",
    unitIndex: 0,
    layoutUnitId: "stale-unit",
    confirmedLayoutUnitId: "stale-unit",
  }]]);
  const result = applyEventSuccessSpatialLayout(
    assignments,
    layout([unit("zone", 1, 0, 0)]),
    {spatialOverrides: []},
    0
  ).get("user-1");
  assert.equal(result?.layoutUnitId, undefined);
  assert.equal(result?.confirmedLayoutUnitId, undefined);
});

test("pinned survives regeneration while this-round does not", () => {
  const plan = {
    affinityConstraints: [
      {aUid: "user-1", bUid: "user-2", value: "mustPair" as const,
        scope: "pinned" as const},
      {aUid: "user-3", bUid: "user-4", value: "mustPair" as const,
        scope: "thisRound" as const},
    ],
    spatialOverrides: [
      {uid: "user-1", targetPeerUid: "user-2", layoutUnitId: "zone-2",
        scope: "pinned" as const},
      {uid: "user-3", targetPeerUid: "user-4", layoutUnitId: "zone-2",
        scope: "thisRound" as const},
    ],
  };
  assert.deepEqual(persistentSpatialPlanFields(plan), {
    affinityConstraints: [plan.affinityConstraints[0]],
    spatialOverrides: [plan.spatialOverrides[0]],
  });

  const assignments = new Map<string, {
    uid: string;
    unitKind: string;
    unitIndex: number;
    layoutUnitId?: string;
    confirmedLayoutUnitId?: string | null;
  }>([
    ["user-1", {uid: "user-1", unitKind: "pods", unitIndex: 0}],
    ["user-2", {uid: "user-2", unitKind: "pods", unitIndex: 0}],
    ["user-3", {uid: "user-3", unitKind: "pods", unitIndex: 0}],
    ["user-4", {uid: "user-4", unitKind: "pods", unitIndex: 0}],
  ]);
  const result = applyEventSuccessSpatialLayout(
    assignments,
    layout([unit("zone", 1, 0, 0), unit("zone", 2, 1, 0)]),
    plan,
    0
  );
  assert.equal(result.get("user-1")?.layoutUnitId, "zone-2");
  assert.equal(result.get("user-2")?.layoutUnitId, "zone-2");
  assert.equal(result.get("user-3")?.layoutUnitId, "zone-1");
  assert.equal(result.get("user-4")?.layoutUnitId, "zone-1");
});
