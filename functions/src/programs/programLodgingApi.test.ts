import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import {baseSeed, deps, now, request} from "../shared/testing/programFixtures";
import type {ProgramDataDeps} from "../shared/programDataDeps";
import {FakeFirestore} from "../shared/testing/programFirestore";
import {manageProgramLodgingHandler} from "./programLodgingApi";

function setup() {
  const start = Date.parse("2026-10-01T00:00:00Z");
  const end = Date.parse("2026-10-03T00:00:00Z");
  const scope = {programId: "program-1", organizerId: "org-1"};
  const config = {...scope, revision: 1,
    demand: [{guestId: "guest-1", startsAtMillis: start, endsAtMillis: end,
      beds: 1, requiredFeatures: ["stepFree"]}],
    parties: [{id: "party", guestIds: ["guest-1"], confirmed: true,
      priority: 0, requiredRoomType: null, pin: null}], groupParents: [],
    rooms: [{id: "room", hotelId: "hotel-1", zoneId: "wing", building: null,
      floor: "1", wing: null, roomType: "standard", beds: 1, maxOccupants: 1,
      verifiedFeatures: ["stepFree"], resourceIds: ["room"], position: null}],
    inventory: [{id: "unit", contractId: "block", physicalRoomId: "room",
      provisional: null, availability: [{arrival: "2026-10-01",
        departure: "2026-10-03"}]}], labels: [{inventoryId: "unit",
      roomLabel: "101"}]};
  const fake = new FakeFirestore({...baseSeed(),
    "programLodgingConfigs/program-1": config,
    "programRoomBlocks/block": {...scope, hotelId: "hotel-1", label: "Block",
      roomType: "standard", totalRooms: 1, assignedCount: 0,
      maxOccupantsPerRoom: 1, heldForGroupIds: [],
      startsAt: Timestamp.fromMillis(start), endsAt: Timestamp.fromMillis(end),
      createdAt: now, updatedAt: now, revision: 1}});
  const dependencies = deps(fake) as ProgramDataDeps;
  const call = (data: Record<string, unknown>, uid = "manager-1") =>
    manageProgramLodgingHandler(request({programId: "program-1", ...data}, uid),
      dependencies);
  const preview = async () => {
    const result = await call({action: "preview"});
    if (result.kind !== "proposal") throw new Error("Wrong preview kind");
    return result;
  };
  return {fake, config, dependencies, call, preview};
}

test("callable rejects spoofed actors and hotel access to private review",
  async () => {
    const h = setup();
    await assert.rejects(h.call({action: "preview", actorUid: "manager-1"}),
      /additional properties/);
    await assert.rejects(h.call({action: "preview"}, "hotelier-1"),
      /programCoordinator/);
    await assert.rejects(h.call({action: "readSetup"}, "hotelier-1"),
      /programCoordinator/);
    await assert.rejects(h.call({action: "preview"}, "foreign"),
      /active program access/);
  });

test("proposals share an exact current review context", async () => {
  const h = setup();
  const first = await h.preview();
  assert.deepEqual(first.proposal.revisions, first.context.snapshot.revisions);
  assert.equal(first.context.labels.guests["guest-1"], "Rohan Sharma");
  const manual = await h.call({action: "propose",
    expectedRevisions: first.proposal.revisions,
    placements: first.proposal.placements});
  assert.equal(manual.kind, "proposal");
  const alternatives = await h.call({action: "destinations", partyId: "party",
    expectedRevisions: first.proposal.revisions,
    placements: first.proposal.placements});
  if (alternatives.kind !== "destinations") throw new Error("Wrong kind");
  assert.deepEqual(alternatives.destinations.map((d) => d.allowed), [true]);
  h.fake.updateDoc("programGuests/guest-1", {displayName: "Corrected guest"});
  await assert.rejects(h.call({action: "propose",
    expectedRevisions: first.proposal.revisions,
    placements: first.proposal.placements}), /Stale/);
});

test("manual invalid placements report independent constraints", async () => {
  const h = setup();
  const first = await h.preview();
  await assert.rejects(h.call({action: "propose",
    expectedRevisions: first.proposal.revisions,
    placements: [{partyId: "party", inventoryId: "missing"}]}),
  /Placement conflicts/);
});

test("callable publication is idempotent and hotel output stays operational",
  async () => {
    const h = setup();
    const {proposal} = await h.preview();
    assert.equal((await h.call({action: "save", proposal})).kind, "saved");
    await h.call({action: "transition", command: {proposalId: proposal.id,
      operationId: "approve", expectedWorkflowRevision: 0,
      action: "approve", hotelId: null}});
    const command = {proposalId: proposal.id, operationId: "publish",
      expectedWorkflowRevision: 1, action: "publishGuests", hotelId: null};
    await h.call({action: "transition", command});
    const replay = await h.call({action: "transition", command});
    if (replay.kind !== "transition") throw new Error("Wrong kind");
    assert.equal(replay.replayed, true);
    assert.equal(replay.workflow.revision, 2);
    const board = await h.call({action: "hotelBoard", hotelId: "hotel-1"},
      "hotelier-1");
    if (board.kind !== "hotelBoard") throw new Error("Wrong kind");
    assert.equal(board.rows.length, 1);
    const output = JSON.stringify(board);
    for (const privateValue of ["stepFree", "requiredFeatures", "configuration",
      "labels", "memberships"]) {
      assert.equal(output.includes(privateValue), false);
    }
    await assert.rejects(h.call({action: "hotelBoard", hotelId: "hotel-2"},
      "hotelier-1"), /Hotel duty/);
  });

test("setup derives organizer scope and enforces revision", async () => {
  const h = setup();
  const fields = {demand: h.config.demand, parties: h.config.parties,
    groupParents: h.config.groupParents, rooms: h.config.rooms,
    inventory: h.config.inventory, labels: h.config.labels};
  const response = await h.call({action: "setup", setup: fields,
    expectedConfigurationRevision: 1, adoptions: []});
  if (response.kind !== "setup") throw new Error("Wrong kind");
  assert.equal(response.revision, 2);
  await assert.rejects(h.call({action: "setup", setup: {...fields,
    organizerId: "other"}, expectedConfigurationRevision: 2, adoptions: []}),
  /additional properties/);
  await assert.rejects(h.call({action: "setup", setup: fields,
    expectedConfigurationRevision: 1, adoptions: []}), /changed since/);
  const read = await h.call({action: "readSetup"});
  if (read.kind !== "readSetup") throw new Error("Wrong kind");
  assert.equal(read.configuration?.organizerId, "org-1");
  assert.equal(read.accessExpiresAtMillis, null);
});
