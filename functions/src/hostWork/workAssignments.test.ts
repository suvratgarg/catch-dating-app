import assert from "node:assert/strict";
import test from "node:test";
import {
  deriveShellEntry,
  resolveWorkAssignments,
  type WorkAssignment,
} from "./workAssignments";
import type {WorkScope} from "./workDestinations";

const NOW = 1_800_000_000_000;

function assignment(
  scope: WorkScope,
  partial?: Partial<WorkAssignment>,
): WorkAssignment {
  return {
    scope,
    title: `${scope.kind}:${scope.id}`,
    organizerName: "Sharma Weddings",
    duties: [{duty: "airportGreeter"}],
    ...partial,
  };
}

test("expired assignments drop out; live and open-ended stay", () => {
  const resolved = resolveWorkAssignments([
    assignment({kind: "program", id: "past"}, {expiresAtMillis: NOW}),
    assignment({kind: "program", id: "live"}, {expiresAtMillis: NOW + 1}),
    assignment({kind: "event", id: "open"}),
  ], NOW);
  assert.deepEqual(resolved.map((item) => item.scope.id), ["open", "live"]);
});

test("ordering is deterministic by scope kind then id", () => {
  const scopes: WorkScope[] = [
    {kind: "program", id: "program-b"},
    {kind: "event", id: "event-b"},
    {kind: "program", id: "program-a"},
    {kind: "event", id: "event-a"},
  ];
  const resolved = resolveWorkAssignments(
    scopes.map((scope) => assignment(scope)), NOW);
  assert.deepEqual(
    resolved.map((item) => `${item.scope.kind}:${item.scope.id}`), [
      "event:event-a", "event:event-b",
      "program:program-a", "program:program-b",
    ]);
  // Input order never matters.
  const reversed = resolveWorkAssignments(
    scopes.map((scope) => assignment(scope)).reverse(), NOW);
  assert.deepEqual(
    reversed.map((item) => item.scope.id),
    resolved.map((item) => item.scope.id));
});

test("each assignment resolves only its own duties", () => {
  const resolved = resolveWorkAssignments([
    assignment({kind: "program", id: "greet"},
      {duties: [{duty: "airportGreeter"}]}),
    assignment({kind: "program", id: "drive"},
      {duties: [{duty: "transportDispatcher"}]}),
  ], NOW);
  const [greet, drive] = [
    resolved.find((item) => item.scope.id === "greet"),
    resolved.find((item) => item.scope.id === "drive"),
  ];
  assert.ok(greet !== undefined && drive !== undefined);
  // The greeter context does not borrow Dispatch from the dispatcher
  // assignment: the switcher changes explicit context, never unions.
  assert.deepEqual(greet.destinations, ["arrivals"]);
  assert.equal(greet.shellMode, "task");
  assert.deepEqual(drive.destinations, ["arrivals", "dispatch"]);
  assert.equal(drive.shellMode, "tabs");
});

test("resolution fields attach to the assignment", () => {
  const [resolved] = resolveWorkAssignments([
    assignment({kind: "event", id: "event-1"}, {
      subtitle: "Baraat",
      duties: [{duty: "eventLead"}],
    }),
  ], NOW);
  assert.equal(resolved.title, "event:event-1");
  assert.equal(resolved.subtitle, "Baraat");
  assert.equal(resolved.organizerName, "Sharma Weddings");
  assert.deepEqual(resolved.destinations, ["nowNext", "door", "attention"]);
  assert.deepEqual(resolved.overflow, []);
  assert.equal(resolved.shellMode, "tabs");
});

test("invalid timing fails fast", () => {
  for (const bad of [-1, 0.5, NaN, Infinity]) {
    assert.throws(() => resolveWorkAssignments([], bad), RangeError);
    assert.throws(() => resolveWorkAssignments([
      assignment({kind: "program", id: "x"}, {expiresAtMillis: bad}),
    ], NOW), RangeError);
  }
});

test("managers always enter the manager shell", () => {
  const entry = deriveShellEntry([], NOW, true);
  assert.equal(entry.kind, "managerShell");
  assert.deepEqual(entry.activeAssignments, []);
  // A manager who also holds staff assignments still keeps them visible.
  const staffed = deriveShellEntry([
    assignment({kind: "program", id: "p1"}),
  ], NOW, true);
  assert.equal(staffed.kind, "managerShell");
  assert.equal(staffed.activeAssignments.length, 1);
});

test("staff enter the work shell only with a live assignment", () => {
  const live = deriveShellEntry([
    assignment({kind: "program", id: "p1"}),
  ], NOW, false);
  assert.equal(live.kind, "workShell");
  assert.equal(live.activeAssignments.length, 1);
  assert.equal(deriveShellEntry([], NOW, false).kind, "none");
  const expiredOnly = deriveShellEntry([
    assignment({kind: "program", id: "p1"}, {expiresAtMillis: NOW}),
  ], NOW, false);
  assert.equal(expiredOnly.kind, "none");
  assert.deepEqual(expiredOnly.activeAssignments, []);
});
