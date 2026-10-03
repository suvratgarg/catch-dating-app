import assert from "node:assert/strict";
import test from "node:test";
import {effectiveMemberships, replaceMembershipSuggestions}
  from "./programLodgingGroups";
import {assertLodgingProposalCurrent, immutableLodgingProposal,
  lodgingScore, planLodging} from "./programLodgingPlanner";
import {assertLodgingSnapshot, validateLodgingPlacements}
  from "./programLodgingValidation";
import type {LodgingSnapshot, MembershipDecision}
  from "./programLodgingTypes";

function fixture(parties = 3, rooms = 3): LodgingSnapshot {
  return {
    scope: {organizerId: "organizer", programId: "program"},
    revisions: {source: 1, inventory: 1, layout: 1, published: 0},
    guests: Array.from({length: parties}, (_, n) => ({id: "guest" + n,
      arrival: "2026-10-01", departure: "2026-10-03", beds: 1,
      requiredFeatures: []})),
    parties: Array.from({length: parties}, (_, n) => ({id: "party" + n,
      guestIds: ["guest" + n], confirmed: true, priority: 0,
      requiredRoomType: null, pin: null})),
    groups: [], memberships: [], published: [],
    contracts: [{id: "contract", hotelId: "hotel", nightlyRoomQuota: rooms,
      arrival: "2026-10-01", departure: "2026-10-05"}],
    rooms: Array.from({length: rooms}, (_, n) => ({id: "room" + n,
      hotelId: "hotel", zoneId: "A", building: "main", floor: "1", wing: "A",
      roomType: "standard", beds: 1, maxOccupants: 1, verifiedFeatures: [],
      resourceIds: ["room" + n], position: null})),
    inventory: Array.from({length: rooms}, (_, n) => ({id: "unit" + n,
      contractId: "contract", physicalRoomId: "room" + n, provisional: null,
      availability: [{arrival: "2026-10-01", departure: "2026-10-05"}]})),
  };
}
function members(guestIds: string[], groupId: string): MembershipDecision[] {
  return guestIds.map((guestId) => ({guestId, groupId, included: true,
    authority: "manual", sourceId: null}));
}

test("overlapping groups never duplicate demand or imply sharing", () => {
  const s = fixture();
  s.groups = [{id: "family", parentIds: []},
    {id: "cousins", parentIds: ["family"]}, {id: "friends", parentIds: []}];
  s.memberships = [...members(["guest0", "guest1"], "cousins"),
    ...members(["guest1", "guest2"], "friends")];
  const result = planLodging(s);
  assert.equal(result.placements.length, 3);
  assert.equal(new Set(result.placements.map((r) => r.inventoryId)).size, 3);
  assert.deepEqual([...effectiveMemberships(s.groups, s.memberships)
    .get("guest1")!].sort(), ["cousins", "family", "friends"]);
  s.groups[0].parentIds = ["cousins"];
  assert.throws(() => planLodging(s), /cycle/);
});

test("reimports preserve manual membership decisions", () => {
  const suggestion = {guestId: "guest0", groupId: "family", sourceId: "aunt",
    sourceLabel: "Aunt's guest list"};
  let suggestions = replaceMembershipSuggestions([], "aunt", [suggestion]);
  suggestions = replaceMembershipSuggestions(suggestions, "aunt", [suggestion]);
  assert.equal(suggestions.length, 1);
  const decisions: MembershipDecision[] = [{guestId: "guest0",
    groupId: "family",
    included: false, authority: "manual", sourceId: null},
  {...suggestion, included: true, authority: "acceptedSuggestion"}];
  replaceMembershipSuggestions(suggestions, "aunt", []);
  assert.equal(effectiveMemberships([{id: "family", parentIds: []}], decisions)
    .get("guest0")!.size, 0);
  assert.equal(decisions[0].included, false);
});

test("confirmed roommates count actual overlapping occupants and beds", () => {
  const s = fixture(2, 1);
  s.parties[0].guestIds.push("guest1");
  s.parties.pop();
  s.guests[0].departure = "2026-10-02";
  s.guests[1].arrival = "2026-10-02";
  assert.equal(planLodging(s).placements.length, 1);
  s.guests[1].arrival = "2026-10-01";
  assert.equal(planLodging(s).placements.length, 0);
  s.rooms[0].maxOccupants = 2;
  assert.equal(planLodging(s).placements.length, 0); // Beds still insufficient.
  s.rooms[0].beds = 2;
  assert.equal(planLodging(s).placements.length, 1);
});

test("no-travel demand preserves scarce accessible suites", () => {
  const s = fixture();
  s.guests[2].requiredFeatures = ["stepFree", "rollInShower"];
  s.parties[2].requiredRoomType = "suite";
  s.rooms[0].roomType = "suite";
  s.rooms[0].verifiedFeatures = ["stepFree", "rollInShower"];
  const result = planLodging(s);
  assert.equal(result.placements.length, 3);
  assert.equal(result.placements.find((p) => p.partyId === "party2")!
    .inventoryId, "unit0");
  s.rooms[0].verifiedFeatures = ["stepFree"];
  const blocked = planLodging(s);
  assert.deepEqual(blocked.unplacedPartyIds, ["party2"]);
  assert.match(blocked.explanations.join(" "), /accessibility/);
});

test("conflicting pins cannot move checked-in guests", () => {
  const s = fixture(2, 2);
  s.parties.forEach((p) => {
    p.pin = {inventoryId: "unit0"};
  });
  const proposal = planLodging(s);
  assert.equal(proposal.placements.length, 1);
  assert.match(proposal.explanations.join(" "), /compete/);
  s.published = [{partyId: "party0", inventoryId: "unit0",
    checkedIn: true, locked: false}];
  assert.equal(planLodging(s).placements[0].partyId, "party0");
  assert.throws(() => immutableLodgingProposal(s,
    [{partyId: "party0", inventoryId: "unit1"}]), /pin|locked/);
  s.parties[0].pin = {hotelId: "another"};
  assert.throws(() => planLodging(s), /Locked placements/);
});

test("villa components exclude whole-villa use each night", () => {
  const s = fixture(2, 2);
  s.rooms[0].resourceIds = ["bedroomA", "bedroomB"];
  s.rooms[1].resourceIds = ["bedroomA"];
  assert.equal(planLodging(s).placements.length, 1);
  s.guests[1].arrival = "2026-10-03";
  s.guests[1].departure = "2026-10-04";
  assert.equal(planLodging(s).placements.length, 2);
});

test("provisional inventory conserves nightly quotas", () => {
  const s = fixture(2, 2);
  s.inventory = s.inventory.map((unit, n) => {
    const room = s.rooms[n];
    const provisional = {hotelId: room.hotelId, zoneId: room.zoneId,
      building: room.building, floor: room.floor, wing: room.wing,
      roomType: room.roomType, beds: room.beds,
      maxOccupants: room.maxOccupants, verifiedFeatures: room.verifiedFeatures};
    return {...unit, physicalRoomId: null, provisional};
  });
  s.rooms = [];
  assert.equal(planLodging(s).placements.length, 2);
  s.contracts[0].nightlyRoomQuota = 1;
  assert.equal(planLodging(s).placements.length, 1);
  s.guests[1].arrival = "2026-10-03";
  s.guests[1].departure = "2026-10-04";
  assert.equal(planLodging(s).placements.length, 2);
});

test("21-party spillover prefers coherent19+2 to isolated20+1", () => {
  const s = fixture(21, 23);
  s.rooms.forEach((room, index) => {
    if (index >= 20) {
      room.zoneId = "B"; room.wing = "B";
    }
  });
  s.groups = [{id: "friends", parentIds: []}];
  s.memberships = members(s.guests.map((g) => g.id), "friends");
  const started = performance.now();
  const result = planLodging(s, {beamWidth: 4});
  assert.equal(result.placements.length, 21);
  assert.equal(result.score[3], 0);
  assert.equal(result.search.complete, false);
  assert.deepEqual(validateLodgingPlacements(s, result.placements, true), []);
  const counts = new Map<string, number>();
  for (const placement of result.placements) {
    const unit = s.inventory.find((r) => r.id === placement.inventoryId)!;
    const zone = s.rooms.find((r) => r.id === unit.physicalRoomId)!.zoneId;
    counts.set(zone, (counts.get(zone) ?? 0) + 1);
  }
  assert.ok([2, 3].includes(counts.get("B")!));
  console.log(JSON.stringify({benchmark: "21-party coherent overflow",
    elapsedMillis: Math.round(performance.now() - started),
    explored: result.search.explored, zoneCounts: Object.fromEntries(counts)}));
});

test("overflow friends remove isolation", () => {
  const s = fixture(3, 3);
  s.rooms[2].zoneId = "B";
  s.rooms[2].wing = "B";
  s.rooms[1].zoneId = "B";
  s.rooms[1].wing = "B";
  s.groups = [{id: "friends", parentIds: []}];
  s.memberships = members(["guest1", "guest2"], "friends");
  s.parties[2].pin = {zoneId: "B"};
  const result = planLodging(s);
  assert.equal(result.score[3], 0);
  assert.ok(result.placements.filter((p) => p.partyId !== "party0")
    .every((p) => p.inventoryId !== "unit0"));
});

test("manual proposals validate and fence all revisions", () => {
  const s = fixture(1, 2);
  const proposal = immutableLodgingProposal(s,
    [{partyId: "party0", inventoryId: "unit1"}]);
  assert.ok(Object.isFrozen(proposal) &&
    Object.isFrozen(proposal.placements[0]));
  assertLodgingProposalCurrent(proposal, s.revisions);
  for (const key of ["source", "inventory", "layout", "published"] as const) {
    assert.throws(() => assertLodgingProposalCurrent(proposal,
      {...s.revisions, [key]: s.revisions[key] + 1}), /Stale/);
  }
  assert.equal(proposal.id,
    immutableLodgingProposal(s, proposal.placements).id);
  s.published = [{partyId: "party0", inventoryId: "unit1",
    locked: false, checkedIn: false}];
  assert.equal(planLodging(s).placements[0].inventoryId, "unit1");
});

test("tiny cases match independent conservation oracle", () => {
  for (let mask = 0; mask < 32; mask++) {
    const s = fixture(3, 2);
    s.contracts[0].nightlyRoomQuota = mask & 1 ? 1 : 2;
    s.guests[1].arrival = mask & 2 ? "2026-10-03" : "2026-10-01";
    s.guests[1].departure = "2026-10-04";
    s.parties[0].pin = mask & 4 ? {inventoryId: "unit0"} : null;
    s.parties[2].pin = mask & 8 ? {inventoryId: "unit0"} : null;
    s.parties[2].priority = mask & 16 ? 5 : 0;
    let best = [Infinity, Infinity];
    for (const a of [-1, 0, 1]) {
      for (const b of [-1, 0, 1]) {
        for (const c of [-1, 0, 1]) {
          const choices = [a, b, c];
          let valid = true;
          for (let day = 1; day <= 3; day++) {
            const occupied: number[] = [];
            choices.forEach((room, i) => {
              if (room < 0) return;
              if (s.parties[i].pin?.inventoryId && room !== 0) valid = false;
              const guest = s.guests[i];
              if (day >= Number(guest.arrival.slice(-2)) &&
                day < Number(guest.departure.slice(-2))) occupied.push(room);
            });
            if (new Set(occupied).size !== occupied.length ||
              occupied.length > s.contracts[0].nightlyRoomQuota) valid = false;
          }
          if (!valid) continue;
          const score = [choices.filter((r) => r < 0).length,
            choices.reduce((sum, r, i) => sum +
            (r < 0 ? s.parties[i].priority : 0), 0)];
          if (score[0] < best[0] ||
              score[0] === best[0] && score[1] < best[1]) {
            best = score;
          }
        }
      }
    }
    const actual = planLodging(s);
    assert.equal(actual.search.complete, true);
    assert.deepEqual(actual.score.slice(0, 2), best, "mask " + mask);
    assert.deepEqual(lodgingScore(s, actual.placements), actual.score);
  }
});

test("invalid demand and dates fail closed", () => {
  const s = fixture();
  s.parties[1].guestIds.push("guest0");
  assert.throws(() => assertLodgingSnapshot(s), /exactly one/);
  s.parties[1].guestIds.pop();
  s.guests[0].arrival = "2026-02-30";
  assert.throws(() => assertLodgingSnapshot(s), /local date/);
  s.guests[0].arrival = "2026-10-01";
  s.inventory[0].availability[0].departure = "2026-10-06";
  assert.throws(() => assertLodgingSnapshot(s), /contracted dates/);
});
