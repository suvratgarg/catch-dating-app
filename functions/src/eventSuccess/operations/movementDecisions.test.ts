import assert from "node:assert/strict";
import test from "node:test";
import {prepareDepartureDecision, prepareCheckpointObservation,
  DepartureReview, DeparturePayload, CheckpointObservationReview,
  CheckpointPayload} from "./movementDecisions";
import type {EventAssistanceCommand} from
  "../../shared/generated/eventAssistanceCommand";
import {validateEventAssistanceCommand} from
  "../../shared/generated/validators/eventAssistanceCommand";
import {assertCommandContext} from "./commands";

type Destination = DeparturePayload["destination"];
const destinations: Destination[] = [
  {kind: "fixedPlace", placeId: "meeting", lateEntry: "allowed"},
  {kind: "itineraryStop", itineraryId: "event-1:itinerary", stopId: "stop-1"},
  {kind: "groupCheckpoint", routeId: "event-1:route", groupId: "pace-1",
    checkpointId: "stop-1"},
];
function departure(): DepartureReview {
  return {revision: 2, sourceHash: "a".repeat(64), eventOpen: true,
    runtimeLive: true, destinations: destinations.map((target) => ({
      target, label: "Confirmed destination",
      location: {name: "Meeting place", latitude: 19, longitude: 72},
    }))};
}
function departurePayload(destination = destinations[0]): DeparturePayload {
  return {groupId: destination.kind === "groupCheckpoint" ?
    destination.groupId : "event:whole", destination,
  expectedProgressRevision: 2};
}
function checkpoint(): CheckpointObservationReview {
  return {revision: 0, sourceHash: "a".repeat(64),
    previouslyAccountedFor: [],
    availability: {kind: "ready", rosterId: "roster-1", label: "Stop 1",
      reportStatus: "unreported", members: ["guest-1", "guest-2"].map(
        (attendeeId) => ({attendeeId, observation: "unconfirmed",
          visit: {kind: "current"}}))}};
}
function observations(accountedFor = ["guest-1"]): CheckpointPayload {
  return {groupId: "event:whole", checkpointId: "stop-1",
    expectedProgressRevision: 2, expectedCheckpointRevision: 0,
    accountedFor, correctionReason: null};
}

for (const destination of destinations) {
  test(destination.kind + " binds the reviewed destination and source", () => {
    const review = departure();
    const payload = departurePayload(destination);
    const before = JSON.stringify([review, payload]);
    const result = prepareDepartureDecision(review, payload, review.sourceHash);
    assert.deepEqual(result.target.target, destination);
    assert.equal(result.selection, undefined);
    assert.equal(result.checkpointRequest, undefined);
    assert.equal(JSON.stringify([review, payload]), before);
    assert.throws(() => prepareDepartureDecision(review, payload,
      "b".repeat(64)),
    {code: "aborted"});
    assert.throws(() => prepareDepartureDecision(review,
      {...payload, expectedProgressRevision: 1}, review.sourceHash),
    {code: "aborted"});
    assert.throws(() => prepareDepartureDecision({...review, destinations: []},
      payload, review.sourceHash), {code: "failed-precondition"});
  });
}

test("departure requires an open live runtime before observing any movement",
  () => {
    const review = departure();
    for (const patch of [{eventOpen: false}, {runtimeLive: false}]) {
      assert.throws(() => prepareDepartureDecision({...review, ...patch},
        departurePayload(), review.sourceHash), {code: "failed-precondition"});
    }
  });

test("an absent roster stays distinct from an explicitly selected empty roster",
  () => {
    const review = departure();
    const payload = {...departurePayload(destinations[1]),
      departureRoster: {attendeeIds: [], expectedSourceHash: "b".repeat(64)},
      checkpointRequest: {responsibleOperatorId: "host-1", dueAt: 1000}};
    assert.deepEqual(prepareDepartureDecision(review, payload,
      review.sourceHash).selection?.attendeeIds, []);
    const {departureRoster: _roster, ...unrecorded} = payload;
    assert.ok(_roster);
    assert.throws(() => prepareDepartureDecision(review, unrecorded,
      review.sourceHash), {code: "failed-precondition"});
    assert.throws(() => prepareDepartureDecision(review, {
      ...payload, destination: destinations[0],
    }, review.sourceHash), {code: "failed-precondition"});
  });

test("both modes share payload rules behind their separate context checks",
  () => {
    const contexts: EventAssistanceCommand["context"][] = [
      {mode: "live", eventId: "event-1", organizerId: "organizer-1"},
      {mode: "rehearsal", rehearsalId: "session-1", virtualEventId: "event-1",
        clockId: "clock-1"},
    ];
    for (const context of contexts) {
      const command: EventAssistanceCommand = {kind: "confirmDeparture",
        context, eventId: "event-1", operationId: "operation-1",
        payload: departurePayload(destinations[2])};
      assert.equal(validateEventAssistanceCommand(command), true);
      assertCommandContext(command, context);
      assert.deepEqual(prepareDepartureDecision(departure(), command.payload,
        "a".repeat(64)).target.target, destinations[2]);
      assert.throws(() => assertCommandContext(command,
        context.mode === "live" ? contexts[1] : contexts[0]));
    }
  });

test("observations sort the complete set without mutating the review", () => {
  const review = checkpoint();
  const payload = observations(["guest-2", "guest-1"]);
  const before = JSON.stringify([review, payload]);
  assert.deepEqual(prepareCheckpointObservation(review, payload,
    review.sourceHash), {accountedFor: ["guest-1", "guest-2"],
    correctionReason: null});
  assert.equal(JSON.stringify([review, payload]), before);
});

test("an unrecorded roster never becomes an empty checkpoint report", () => {
  const review = checkpoint();
  assert.throws(() => prepareCheckpointObservation({...review,
    availability: {kind: "unavailable", reason: "rosterNotRecorded"}},
  observations([]), review.sourceHash), {code: "failed-precondition"});
  assert.equal(review.availability.kind, "ready");
  if (review.availability.kind !== "ready") throw new Error("Fixture");
  review.availability.members = [];
  assert.deepEqual(prepareCheckpointObservation(review, observations([]),
    review.sourceHash), {accountedFor: [], correctionReason: null});
});

test("new proof requires the original visit even if return-sweep is resolved",
  () => {
    const review = checkpoint();
    if (review.availability.kind !== "ready") throw new Error("Fixture");
    const member = review.availability.members[0];
    member.visit = {kind: "unavailable", reason: "visitChanged"};
    member.disposition = {kind: "resolved", disposition: "returned",
      revision: 1, resolvedAt: 1000, resolvedBy: "host-1",
      sourceHash: "c".repeat(64)};
    assert.throws(() => prepareCheckpointObservation(review, observations(),
      review.sourceHash), {code: "failed-precondition"});
    assert.throws(() => prepareCheckpointObservation(review,
      observations(["not-on-roster"]), review.sourceHash),
    {code: "failed-precondition"});
    assert.deepEqual(prepareCheckpointObservation({...review,
      previouslyAccountedFor: ["guest-1"]}, observations(),
    review.sourceHash).accountedFor, ["guest-1"]);
  });

test("removing a prior observation requires a nonblank explanation", () => {
  const review = {...checkpoint(), previouslyAccountedFor: ["guest-1"]};
  for (const correctionReason of [null, "", "  "]) {
    assert.throws(() => prepareCheckpointObservation(review,
      {...observations([]), correctionReason}, review.sourceHash),
    {code: "failed-precondition"});
  }
  assert.deepEqual(prepareCheckpointObservation(review,
    {...observations([]), correctionReason: "  Recorded the wrong guest  "},
    review.sourceHash), {accountedFor: [],
    correctionReason: "Recorded the wrong guest"});
});

test("checkpoint reviews reject both stale reports and stale visit sources",
  () => {
    const review = checkpoint();
    assert.throws(() => prepareCheckpointObservation(review, observations(),
      "b".repeat(64)), {code: "aborted"});
    assert.throws(() => prepareCheckpointObservation({...review, revision: 1},
      observations(), review.sourceHash), {code: "aborted"});
  });
