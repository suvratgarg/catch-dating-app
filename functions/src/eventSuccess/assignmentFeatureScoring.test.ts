import assert from "node:assert/strict";
import test from "node:test";
import {
  assignmentFeatureBalanceCost,
  assignmentFeaturePairScore,
  normalizeAssignmentFeature,
  validateAssignmentFeatureRules,
  type AssignmentFeatureRule,
  type EventAssignmentFeatureSnapshot,
} from "./assignmentFeatureScoring";

const lineage = {featureId: "pace", formId: "form", versionId: "version-2",
  questionId: "question", transformVersion: 1};
const authority = {eventId: "event", organizerId: "org", uid: "a"};
const ordinal: AssignmentFeatureRule = {...lineage, kind: "ordinal",
  mode: "preferSimilar", weight: 10, optionIds: ["easy", "medium", "fast"],
  scoreByOptionId: {easy: -1, medium: 0, fast: 1}};
function snapshot(uid: string, value: EventAssignmentFeatureSnapshot["value"]):
  EventAssignmentFeatureSnapshot {
  return {...lineage, eventId: "event", organizerId: "org", uid,
    consentReceiptId: "event-assignment-grant", value};
}

test("ordinal similarity and difference use explicit option scores", () => {
  validateAssignmentFeatureRules([ordinal]);
  const easy = normalizeAssignmentFeature(ordinal,
    snapshot("a", {kind: "ordinal", optionId: "easy"}), authority);
  const fast = normalizeAssignmentFeature(ordinal,
    snapshot("b", {kind: "ordinal", optionId: "fast"}),
    {...authority, uid: "b"});
  assert.equal(assignmentFeaturePairScore(ordinal, easy, easy), 10);
  assert.equal(assignmentFeaturePairScore(ordinal, easy, fast), 0);
  assert.equal(assignmentFeaturePairScore({...ordinal, mode: "preferDifferent"},
    easy, fast), 10);
});

test("categories and sets use IDs, equality and Jaccard overlap", () => {
  const category: AssignmentFeatureRule = {...lineage, kind: "category",
    mode: "preferSimilar", weight: 8, optionIds: ["a", "b"]};
  const a = normalizeAssignmentFeature(category,
    snapshot("a", {kind: "category", optionId: "a"}), authority);
  const b = normalizeAssignmentFeature(category,
    snapshot("b", {kind: "category", optionId: "b"}),
    {...authority, uid: "b"});
  assert.equal(assignmentFeaturePairScore(category, a, b), 0);
  assert.equal(assignmentFeaturePairScore(
    {...category, mode: "preferDifferent"}, a, b), 8);
  const set: AssignmentFeatureRule = {...lineage, kind: "set",
    mode: "preferSimilar", weight: 9, optionIds: ["x", "y", "z"]};
  const xy = normalizeAssignmentFeature(set,
    snapshot("a", {kind: "set", optionIds: ["x", "y"]}), authority);
  const yz = normalizeAssignmentFeature(set,
    snapshot("b", {kind: "set", optionIds: ["y", "z"]}),
    {...authority, uid: "b"});
  assert.equal(assignmentFeaturePairScore(set, xy, yz), 3);
});

test("missing consent, foreign source and unmapped values are neutral", () => {
  const source = snapshot("a", {kind: "ordinal", optionId: "easy"});
  for (const bad of [{...source, consentReceiptId: ""},
    {...source, eventId: "another"}, {...source, organizerId: "another"},
    {...source, uid: "another"}, {...source, versionId: "version-1"},
    {...source, value: {kind: "ordinal" as const, optionId: "unmapped"}}]) {
    assert.equal(normalizeAssignmentFeature(ordinal, bad, authority), null);
  }
  assert.equal(assignmentFeaturePairScore(ordinal, null, null), 0);
  const set: AssignmentFeatureRule = {...lineage, kind: "set",
    mode: "preferSimilar", weight: 8, optionIds: ["x", "y"]};
  assert.equal(normalizeAssignmentFeature(set,
    snapshot("a", {kind: "set", optionIds: []}), authority), null);
});

test("invalid ranges, weights and ordinal options fail", () => {
  assert.throws(() => validateAssignmentFeatureRules([
    {...ordinal, kind: "other" as "ordinal"},
  ]));
  assert.throws(() => validateAssignmentFeatureRules([
    {...ordinal, mode: "other" as "preferSimilar"},
  ]));
  assert.throws(() => validateAssignmentFeatureRules([
    {...ordinal, scoreByOptionId: {easy: 1, medium: 1, fast: 1}},
  ]));
  assert.throws(() => validateAssignmentFeatureRules([
    {...ordinal, scoreByOptionId: {easy: 1, medium: 2}},
  ]));
  assert.throws(() => validateAssignmentFeatureRules([
    {...ordinal, weight: Number.POSITIVE_INFINITY},
  ]));
  assert.throws(() => validateAssignmentFeatureRules([
    {...lineage, kind: "number", mode: "preferSimilar", weight: 10,
      minimum: 2, maximum: 2},
  ]));
  assert.throws(() => validateAssignmentFeatureRules([
    {...lineage, kind: "number", mode: "preferSimilar", weight: 10,
      minimum: -Number.MAX_VALUE, maximum: Number.MAX_VALUE},
  ]));
});

test("balance compares group to eligible pool, not pairwise difference", () => {
  const balance: AssignmentFeatureRule = {...lineage, kind: "category",
    mode: "balanceAcrossGroups", weight: 20, optionIds: ["a", "b"]};
  const a = {kind: "category" as const, value: "a"};
  const b = {kind: "category" as const, value: "b"};
  assert.equal(assignmentFeaturePairScore(balance, a, b), 0);
  assert.equal(assignmentFeatureBalanceCost(balance, [a, b], [a, b]), 0);
  assert.equal(assignmentFeatureBalanceCost(balance, [a, a], [a, b]), 10);
  assert.equal(assignmentFeatureBalanceCost(balance, [], [a, b]), 0);
});
