import assert from "node:assert/strict";
import test from "node:test";
import {
  assertPairRotationTopology,
  resolveAssignmentTopology,
  unitLabel,
  unitSubtitle,
} from "./assignmentTopology";
import {isHttpsError} from "../shared/testUtils";

test("resolves group topology from unit size and clamps group count", () => {
  const topology = resolveAssignmentTopology(
    {
      structureConfig: {
        unitKind: "tables",
        unitSize: 4,
        unitCount: 20,
        rotationIntervalMinutes: 30,
      },
    },
    8,
    {defaultUnitKind: "pods", defaultUnitSize: 5}
  );

  assert.equal(topology.unitKind, "tables");
  assert.equal(topology.unitSize, 4);
  assert.equal(topology.groupCount, 4);
  assert.equal(topology.maxGroupSize, 2);
  assert.equal(topology.rotationsEnabled, true);
  assert.equal(topology.rotationIntervalMinutes, 30);
});

test("uses one whole-group unit when requested", () => {
  const topology = resolveAssignmentTopology(
    {structureConfig: {unitKind: "wholeGroup", unitSize: 999}},
    12,
    {defaultUnitKind: "pods", defaultUnitSize: 5}
  );

  assert.equal(topology.unitKind, "wholeGroup");
  assert.equal(topology.unitSize, 12);
  assert.equal(topology.groupCount, 1);
  assert.equal(topology.maxGroupSize, 12);
  assert.equal(topology.rotationsEnabled, false);
});

test("derives unit labels and copy from unit kind", () => {
  assert.equal(unitLabel("teams", 1), "Team B");
  assert.equal(unitLabel("tables", 27), "Table B2");
  assert.equal(unitSubtitle("teams", 5), "5 people on this team.");
  assert.equal(unitSubtitle("tables", 4), "4 people at this table.");
});

test("pair rotation wrapper accepts only two-person units", () => {
  assert.doesNotThrow(() =>
    assertPairRotationTopology({
      structureConfig: {unitKind: "pairs", unitSize: 2},
    })
  );
  assert.doesNotThrow(() =>
    assertPairRotationTopology({structureConfig: {unitKind: "pairs"}})
  );
  assert.throws(
    () =>
      assertPairRotationTopology({
        structureConfig: {unitKind: "tables", unitSize: 4},
      }),
    (error) => {
      isHttpsError(error, "failed-precondition", "two-person units");
      return true;
    }
  );
  assert.throws(
    () =>
      assertPairRotationTopology({
        structureConfig: {unitKind: "pairs", unitSize: 4},
      }),
    (error) => {
      isHttpsError(error, "failed-precondition", "two-person units");
      return true;
    }
  );
});
