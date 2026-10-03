import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import {baseSeed, deps, now, request} from "../shared/testing/programFixtures";
import type {ProgramDataDeps} from "../shared/programDataDeps";
import {FakeFirestore} from "../shared/testing/programFirestore";
import {manageProgramLodgingHandler} from "./programLodgingApi";

import {planImportedMembership} from
  "../workspaces/programMembershipPersistence";

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

test("setup catalog offers native no-travel guests without copying contacts",
  async () => {
    const h = setup();
    h.fake.deleteDoc("programLodgingConfigs/program-1");
    h.fake.setDoc("programGuests/no-travel", {
      ...h.fake.getDoc("programGuests/guest-1"), displayName: "Local guest",
      householdId: "invitation-household", groupIds: ["friends", "family"],
    });
    h.fake.setDoc("programGuests/foreign", {
      ...h.fake.getDoc("programGuests/guest-1"), organizerId: "other",
    });
    h.fake.updateDoc("programHotels/hotel-1", {notes: "Private hotel note"});
    const result = await h.call({action: "readSetup"});
    if (result.kind !== "readSetup") throw new Error("Wrong catalog kind");
    assert.equal(result.configuration, null);
    assert.equal(result.catalog.programId, "program-1");
    const guest = result.catalog.guests.find((g) => g.id === "no-travel");
    assert.deepEqual(guest, {id: "no-travel", label: "Local guest",
      householdId: "invitation-household", groupIds: ["friends", "family"]});
    assert.equal(result.catalog.guests.some((g) => g.id === "foreign"), false);
    assert.equal(result.catalog.contracts[0].totalRooms, 1);
    assert.equal(result.catalog.contracts[0].maxOccupantsPerRoom, 1);
    const text = JSON.stringify(result.catalog);
    for (const field of ["phoneE164", "email", "contactId", "notes",
      "Private hotel note", "requiredFeatures", "parties"]) {
      assert.equal(text.includes(field), false);
    }
  });

test("setup catalog keeps legacy occupancy explicit and omits released stays",
  async () => {
    const h = setup();
    const row = {programId: "program-1", organizerId: "org-1",
      guestId: "guest-1", hotelId: "hotel-1", roomBlockId: "block",
      roomLabel: "101", startsAt: now, endsAt: null,
      status: "checkedIn", revision: 7};
    h.fake.setDoc("programStays/legacy", row);
    h.fake.setDoc("programStays/released", {...row, status: "checkedOut"});
    const result = await h.call({action: "readSetup"});
    if (result.kind !== "readSetup") throw new Error("Wrong catalog kind");
    assert.deepEqual(result.catalog.activeStays, [{id: "legacy",
      guestId: "guest-1", hotelId: "hotel-1", roomBlockId: "block",
      roomLabel: "101", roomOccupancyId: null, lodgingPartyId: null,
      lodgingInventoryId: null, startsAtMillis: now.toMillis(),
      endsAtMillis: null, status: "checkedIn", revision: 7}]);
  });

test("setup catalog rejects partial source rather than hiding excess guests",
  async () => {
    const h = setup();
    const guest = h.fake.getDoc("programGuests/guest-1")!;
    for (let i = 0; i < 501; i++) {
      h.fake.setDoc(`programGuests/catalog-${i}`, {...guest});
    }
    await assert.rejects(h.call({action: "readSetup"}),
      (error: unknown) => (error as {code?: string}).code ===
        "resource-exhausted");
  });

test("setup catalog rechecks coordinator expiry after final native reads",
  async () => {
    const h = setup();
    const expiry = now.toMillis() + 100;
    let clock = now.toMillis();
    h.dependencies.now = () => Timestamp.fromMillis(clock);
    h.fake.updateDoc("programStaffGrants/program-1__hotelier-1", {
      duties: [{duty: "programCoordinator", expiresAtMillis: expiry,
        pickupPointIds: [], hotelIds: []}],
    });
    const read = h.fake.runQuery.bind(h.fake);
    h.fake.runQuery = async (query) => {
      const result = await read(query);
      clock = expiry;
      return result;
    };
    await assert.rejects(h.call({action: "readSetup"}, "hotelier-1"),
      (error: unknown) => (error as {code?: string}).code ===
        "permission-denied");
  });


test("date-only lodging choices resolve in program timezone across DST",
  async () => {
    const h = setup();
    const resolve = async (timezone: string, arrival: string,
      departure: string) => {
      h.fake.updateDoc("organizerPrograms/program-1", {timezone});
      const result = await h.call({action: "resolveDates", arrival, departure});
      if (result.kind !== "resolvedDates") throw new Error("Wrong date kind");
      assert.equal(result.timezone, timezone);
      return result;
    };
    const india = await resolve("Asia/Kolkata", "2026-10-01", "2026-10-03");
    assert.equal(india.startsAtMillis, Date.parse("2026-10-01T06:30:00Z"));
    const pacific = await resolve("Pacific/Kiritimati", "2026-10-01",
      "2026-10-02");
    assert.equal(pacific.startsAtMillis, Date.parse("2026-09-30T22:00:00Z"));
    const dst = await resolve("America/New_York", "2026-03-07", "2026-03-09");
    assert.equal(dst.endsAtMillis - dst.startsAtMillis, 47 * 3_600_000);
    await assert.rejects(h.call({action: "resolveDates", arrival: "2026-02-30",
      departure: "2026-03-03"}), /Invalid local date/);
    await assert.rejects(h.call({action: "resolveDates", arrival: "2026-10-03",
      departure: "2026-10-01"}), /Checkout must follow/);
    await assert.rejects(h.call({action: "resolveDates", arrival: "2026-10-01",
      departure: "2026-10-03"}, "hotelier-1"), /programCoordinator/);
    await assert.rejects(resolve("Pacific/Apia", "2011-12-30", "2011-12-31"),
      /does not exist/);
  });

function membershipSetup() {
  const h = setup();
  h.fake.setDoc("programGuestGroups/friends", {programId: "program-1",
    organizerId: "org-1", label: "Friends", memberCount: 0, revision: 1,
    createdAt: now, updatedAt: now});
  const guest = h.fake.getDoc("programGuests/guest-1")!;
  const imported = planImportedMembership({guest, programId: "program-1",
    organizerId: "org-1", guestId: "guest-1", groupIds: ["friends"],
    operationId: "import-1", rowIndex: 0, actorUid: "manager-1",
    observedAtMillis: now.toMillis()});
  h.fake.updateDoc("programGuests/guest-1", {groupIds: [],
    membershipSelections: imported.projection.selections,
    membershipSuggestions: imported.projection.suggestions,
    privateAffinityNote: "Private note"});
  for (const write of imported.writes) {
    h.fake.setDoc(write.path, {...write.data});
  }
  const read = () => h.call({action: "readMembership", guestId: "guest-1"});
  return {...h, read, assertionPath: imported.writes[0].path};
}

test("membership review labels suggestions without approving or exposing CRM",
  async () => {
    const h = membershipSetup();
    const result = await h.read();
    if (result.kind !== "membership") throw new Error("Wrong membership kind");
    assert.deepEqual(result.groupIds, []);
    assert.deepEqual(result.groups, [{id: "friends", label: "Friends"}]);
    assert.equal(result.evidence[0].sourceKind, "manifestRow");
    assert.equal(result.evidence[0].sourceLabel, "Manifest row 1");
    assert.equal(result.evidence[0].selected, false);
    assert.equal(result.evidence[0].included, true);
    assert.equal(JSON.stringify(result).includes("Private note"), false);
    assert.equal(JSON.stringify(result).includes("actorUid"), false);
    assert.equal(JSON.stringify(result).includes("phone"), false);
    await assert.rejects(h.call({action: "readMembership", guestId: "guest-1"},
      "hotelier-1"), /programCoordinator/);
  });

test("membership decisions fence revisions and preserve scalar/household data",
  async () => {
    const h = membershipSetup();
    const before = {...h.fake.getDoc("programGuests/guest-1")!};
    const result = await h.call({action: "decideMembership", guestId: "guest-1",
      expectedRevision: before.revision, groupIds: ["friends"]});
    if (result.kind !== "membershipSaved") throw new Error("Wrong save kind");
    const after = h.fake.getDoc("programGuests/guest-1")!;
    assert.equal(after.displayName, before.displayName);
    assert.equal(after.phoneE164, before.phoneE164);
    assert.equal(after.householdId, before.householdId);
    assert.deepEqual(after.groupIds, ["friends"]);
    assert.equal(h.fake.getDoc("programGuestGroups/friends")!.memberCount, 1);
    const reviewed = await h.read();
    if (reviewed.kind !== "membership") throw new Error("Wrong review kind");
    assert.equal(reviewed.evidence.length, 1);
    assert.equal(reviewed.evidence[0].sourceKind, "manualEntry");
    assert.equal(reviewed.evidence[0].selected, true);
    await assert.rejects(h.call({action: "decideMembership", guestId: "guest-1",
      expectedRevision: before.revision, groupIds: []}),
    /Record changed since you loaded it/);
    assert.equal(h.fake.getDoc("programGuestGroups/friends")!.memberCount, 1);
    assert.ok(h.fake.getDoc(h.assertionPath));
  });

test("explicit exclusion remains a selected source after repeated import",
  async () => {
    const h = membershipSetup();
    await h.call({action: "decideMembership", guestId: "guest-1",
      expectedRevision: 1, groupIds: []});
    const guest = h.fake.getDoc("programGuests/guest-1")!;
    const imported = planImportedMembership({guest, programId: "program-1",
      organizerId: "org-1", guestId: "guest-1", groupIds: ["friends"],
      operationId: "import-2", rowIndex: 0, actorUid: "manager-1",
      observedAtMillis: now.toMillis()});
    h.fake.updateDoc("programGuests/guest-1", {
      membershipSelections: imported.projection.selections,
      membershipSuggestions: imported.projection.suggestions});
    for (const write of imported.writes) {
      h.fake.setDoc(write.path, {...write.data});
    }
    const reviewed = await h.read();
    if (reviewed.kind !== "membership") throw new Error("Wrong review kind");
    assert.deepEqual(reviewed.groupIds, []);
    assert.equal(reviewed.evidence.find((e) => e.selected)!.included, false);
    assert.equal(reviewed.evidence.find((e) => !e.selected)!.included, true);
    assert.equal(h.fake.getDoc("programGuestGroups/friends")!.memberCount, 0);
  });

test("membership review fails closed for malformed/foreign/altered pointers",
  async () => {
    for (const corruption of ["null", "foreign", "identity", "selected"]) {
      const h = membershipSetup();
      if (corruption === "null") {
        h.fake.updateDoc("programGuests/guest-1",
          {membershipSuggestions: null});
      }
      if (corruption === "foreign") {
        h.fake.updateDoc(h.assertionPath,
          {organizerId: "foreign"});
      }
      if (corruption === "identity") {
        h.fake.updateDoc(h.assertionPath,
          {sourceVersion: 2});
      }
      if (corruption === "selected") {
        h.fake.updateDoc("programGuests/guest-1",
          {membershipSelections: [{groupId: "friends",
            assertionId: h.assertionPath.split("/")[1]}],
          membershipSuggestions: []});
      }
      await assert.rejects(h.read(), /reconciliation/);
    }
  });

test("membership writes reject foreign groups and expiry after evidence reads",
  async () => {
    const h = membershipSetup();
    h.fake.updateDoc("programGuestGroups/friends", {organizerId: "foreign"});
    await assert.rejects(h.call({action: "decideMembership", guestId: "guest-1",
      expectedRevision: 1, groupIds: ["friends"]}), /reconciliation/);
    assert.deepEqual(h.fake.getDoc("programGuests/guest-1")!.groupIds, []);
    const e = membershipSetup();
    const expiry = now.toMillis() + 100;
    let clock = now.toMillis();
    e.dependencies.now = () => Timestamp.fromMillis(clock);
    e.fake.updateDoc("programStaffGrants/program-1__hotelier-1", {
      duties: [{duty: "programCoordinator", expiresAtMillis: expiry,
        pickupPointIds: [], hotelIds: []}]});
    const get = e.fake.getDoc.bind(e.fake);
    e.fake.getDoc = (path) => {
      const result = get(path);
      if (path === e.assertionPath) clock = expiry;
      return result;
    };
    await assert.rejects(e.call({action: "decideMembership", guestId: "guest-1",
      expectedRevision: 1, groupIds: ["friends"]}, "hotelier-1"),
    (error: unknown) => (error as {code?: string}).code ===
      "permission-denied");
    assert.deepEqual(get("programGuests/guest-1")!.groupIds, []);
    assert.equal(get("programGuestGroups/friends")!.memberCount, 0);
  });

test("membership decision invalidates an older native lodging proposal",
  async () => {
    const h = membershipSetup();
    const preview = await h.preview();
    await h.call({action: "decideMembership", guestId: "guest-1",
      expectedRevision: 1, groupIds: ["friends"]});
    await assert.rejects(h.call({action: "propose",
      expectedRevisions: preview.proposal.revisions,
      placements: preview.proposal.placements}), /Stale/);
  });
