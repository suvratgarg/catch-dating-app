import assert from "node:assert/strict";
import test from "node:test";
import {assertMembershipEvidenceCreate, membershipAssertionMatches,
  selectWorkspaceMembership, suggestWorkspaceMembership,
  workspaceMembershipAssertionId} from "./workspaceMembershipAuthority";
import type {WorkspaceMembershipAssertion, WorkspaceMembershipProjection}
  from "./workspaceMembershipAuthority";

function fact(): WorkspaceMembershipAssertion {
  return {schemaVersion: 1, programId: "program",
    workspaceRef: {kind: "program", id: "program"}, organizerId: "organizer",
    relationshipRef: {kind: "programGuest", id: "guest"}, groupId: "family",
    included: true, sourceKind: "contributorList", sourceId: "aunt-row-1",
    sourceVersion: 1, sourceLabel: "Aunt's list", actorUid: "host",
    observedAtMillis: 1};
}
const empty = (): WorkspaceMembershipProjection =>
  ({groupIds: [], selections: [], suggestions: []});

test("membership suggestions are idempotent and program-scoped", () => {
  const source = fact();
  const id = assertMembershipEvidenceCreate(source, undefined);
  assert.equal(assertMembershipEvidenceCreate(source,
    Object.fromEntries(Object.entries(source).reverse()) as unknown as
      WorkspaceMembershipAssertion), id);
  const first = suggestWorkspaceMembership(empty(), source, source);
  assert.deepEqual(first.groupIds, []);
  assert.equal(first.suggestions.length, 1);
  assert.deepEqual(suggestWorkspaceMembership(first, source, source), first);
  assert.equal(membershipAssertionMatches(source, id,
    {...source,
      workspaceRef: {kind: "program", id: "other"}}), false);
  assert.equal(membershipAssertionMatches(source, id,
    {...source, relationshipRef: {kind: "programGuest", id: "other"}}), false);
  assert.throws(() => assertMembershipEvidenceCreate(
    {...source, included: false}, source), /immutable/);
});

test("manual excludes survive repeated import suggestions", () => {
  const source = fact();
  let projection = suggestWorkspaceMembership(empty(), source, source);
  const manual: WorkspaceMembershipAssertion = {...source,
    sourceKind: "manualEntry", sourceId: "choice-1", included: false};
  const selection = selectWorkspaceMembership({context: source, projection,
    assertion: manual, assertionId: workspaceMembershipAssertionId(manual),
    currentRevision: 3, expectedRevision: 3, actorUid: "host",
    observedAtMillis: 2});
  projection = selection.projection;
  for (let version = 2; version <= 5; version++) {
    projection = suggestWorkspaceMembership(projection, source,
      {...source, sourceVersion: version});
  }
  assert.deepEqual(projection.groupIds, []);
  assert.equal(projection.selections[0].assertionId,
    workspaceMembershipAssertionId(manual));
  assert.equal(selection.decision.relationshipRevision, 3);
  assert.equal(selection.decision.previousAssertionId, null);
});

test("acceptance updates groupIds and fences stale choice", () => {
  const source = fact();
  const projection = {...empty(), groupIds: ["friends"]};
  const params = {context: source, projection, assertion: source,
    assertionId: workspaceMembershipAssertionId(source), currentRevision: 4,
    expectedRevision: 4, actorUid: "host", observedAtMillis: 2};
  assert.deepEqual(selectWorkspaceMembership(params).projection.groupIds,
    ["family", "friends"]);
  assert.deepEqual(projection.groupIds, ["friends"]);
  assert.throws(() => selectWorkspaceMembership({...params,
    expectedRevision: 3}), /Stale/);
  assert.throws(() => selectWorkspaceMembership({...params,
    context: {...source, groupId: "foreign-group"}}), /Invalid membership/);
});

test("pending evidence is bounded without discarding manual decisions", () => {
  const source = fact();
  let projection = empty();
  for (let version = 1; version <= 20; version++) {
    projection = suggestWorkspaceMembership(projection, source,
      {...source, sourceVersion: version});
  }
  assert.throws(() => suggestWorkspaceMembership(projection, source,
    {...source, sourceVersion: 21}), /Review membership suggestions/);
  assert.equal(projection.suggestions.length, 20);
});
