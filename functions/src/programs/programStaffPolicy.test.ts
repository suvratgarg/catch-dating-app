import assert from "node:assert/strict";
import test from "node:test";
import {activeProgramDuties, dutyAssignments, dutyCoversTransportRoute,
  requireProgramAccess, requireProgramDuty} from "../shared/programAuthority";
import type {ProgramAccess, ProgramDutyAssignment} from
  "../shared/programAuthority";
import {baseSeed, now} from "../shared/testing/programFixtures";
import {FakeFirestore} from "../shared/testing/programFirestore";
import {dedupeDuties, grantDuties, validateDutyStations} from
  "./programStaffPolicy";

const expiry = now.toMillis() + 3600_000;
const assignment = (pickup: string[], hotel: string[], end = expiry):
  ProgramDutyAssignment => ({duty: "transportDispatcher",
  pickupPointIds: pickup, hotelIds: hotel, expiresAtMillis: end});
const code = (expected: string) => (error: unknown) =>
  (error as {code?: string}).code === expected;

async function accessWith(duties: unknown[]) {
  const seed = baseSeed();
  seed["programStaffGrants/program-1__dispatcher-1"].duties = duties;
  const db = new FakeFirestore(seed) as unknown as FirebaseFirestore.Firestore;
  return requireProgramAccess({db, programId: "program-1",
    actorUid: "dispatcher-1", now});
}

test("separate pickup/hotel tuples never create cross-pair authority",
  async () => {
    const duties = dedupeDuties([
      assignment(["A"], ["H1"]), assignment(["B"], ["H2"]),
    ]);
    const access = await accessWith(duties);
    const scopes = dutyAssignments(access, "transportDispatcher");
    assert.equal(scopes.length, 2);
    assert.equal(dutyCoversTransportRoute(scopes, "A", "H1"), true);
    assert.equal(dutyCoversTransportRoute(scopes, "B", "H2"), true);
    assert.equal(dutyCoversTransportRoute(scopes, "A", "H2"), false);
    assert.equal(dutyCoversTransportRoute(scopes, "B", "H1"), false);
  });

test("only identical tuples renew, independent of resource array order", () => {
  const duties = dedupeDuties([
    assignment(["B", "A"], ["H2", "H1"]),
    assignment(["A", "B"], ["H1", "H2"], expiry + 1000),
  ]);
  assert.deepEqual(duties, [assignment(["A", "B"], ["H1", "H2"],
    expiry + 1000)]);
});

test("short unrestricted duty does not absorb a longer narrow duty",
  async () => {
    const access = await accessWith(dedupeDuties([
      assignment([], [], now.toMillis()),
      assignment(["A"], ["H1"]),
    ]));
    assert.equal(dutyCoversTransportRoute(
      requireProgramDuty(access, "transportDispatcher"), "B", "H2"), false);
    assert.equal(dutyCoversTransportRoute(
      requireProgramDuty(access, "transportDispatcher"), "A", "H1"), true);
  });

test("expired airport scope leaves hotel scope usable", async () => {
  const access = await accessWith([
    {...assignment([], [], now.toMillis()), duty: "airportGreeter"},
    {...assignment([], ["H1"]), duty: "hotelDesk"},
  ]);
  assert.throws(() => requireProgramDuty(access, "airportGreeter"),
    code("permission-denied"));
  assert.equal(requireProgramDuty(access, "hotelDesk").length, 1);
  assert.deepEqual(activeProgramDuties(access.grant!, expiry), []);
});

for (const duties of [
  [{duty: "airportGreeter", pickupPointIds: [], hotelIds: []}],
  [assignment([], [], now.toMillis())],
  [assignment([], [], now.toMillis() + 2 * 86_400_000)],
  [{...assignment(["A"], []), duty: "programCoordinator"}],
  [{...assignment(["A"], ["H1"]), duty: "hotelDesk"}],
]) {
  test("invalid assignment expiry or coordinator scope fails closed",
    async () => {
      await assert.rejects(accessWith(duties), code("permission-denied"));
    });
}

test("scoped coordinator input is rejected", () => {
  assert.throws(() => grantDuties([{duty: "programCoordinator",
    pickupPointIds: ["A"], hotelIds: []}], expiry), code("invalid-argument"));
});

test("grant overflow never truncates or widens a scope", () => {
  assert.throws(() => dedupeDuties(Array.from({length: 9}, (_, i) =>
    assignment([`A${i}`], []))), code("resource-exhausted"));
});

test("coordinator and explicit duties are all retained for authorization",
  async () => {
    const access: ProgramAccess = await accessWith([
      {...assignment([], []), duty: "programCoordinator"},
      assignment(["A"], ["H1"]),
    ]);
    assert.equal(dutyAssignments(access, "transportDispatcher").length, 2);
  });

test("hotel desk rejects unenforceable pickup restrictions", () => {
  assert.throws(() => grantDuties([{duty: "hotelDesk", pickupPointIds: ["A"],
    hotelIds: ["H1"]}], expiry), code("invalid-argument"));
});

test("coordinator is operational authority, never program administration",
  async () => {
    const access = await accessWith([
      {...assignment([], []), duty: "programCoordinator"},
    ]);
    assert.equal(requireProgramDuty(access, "guestRelations").length, 1);
    assert.throws(() => requireProgramDuty(access, "programAdmin"),
      code("permission-denied"));
  });

test("exact admin remains staff and confers no operational duty", async () => {
  const access = await accessWith([
    {...assignment([], []), duty: "programAdmin"},
  ]);
  assert.equal(access.role, "staff");
  assert.equal(requireProgramDuty(access, "programAdmin").length, 1);
  assert.throws(() => requireProgramDuty(access, "guestRelations"),
    code("permission-denied"));
});

for (const scope of [
  {pickupPointIds: ["A"], hotelIds: []},
  {pickupPointIds: [], hotelIds: ["H1"]},
  {pickupPointIds: [], hotelIds: [], functionIds: ["F1"]},
]) {
  test("admin scope cannot imply arbitrary resource access", () => {
    assert.throws(() => grantDuties([{duty: "programAdmin", ...scope}],
      expiry), code("invalid-argument"));
  });
}

test("different function scopes never collapse during exact tuple renewal",
  () => {
    const duties = dedupeDuties([
      {...assignment([], []), duty: "functionCheckIn" as const,
        functionIds: ["F1"]},
      {...assignment([], []), duty: "functionCheckIn" as const,
        functionIds: ["F2"]},
    ]);
    assert.equal(duties.length, 2);
    assert.deepEqual(duties.map((duty) => duty.functionIds), [["F1"], ["F2"]]);
  });

for (const patch of [
  {ownerUid: "foreign"}, {approvedByUid: ""}, {approvedAtMillis: expiry},
  {authorizedUntilMillis: 0}, {authorizedUntilMillis: expiry + 86_400_000},
]) {
  test("malformed owner approval never falls back to legacy creator audit",
    async () => {
      const seed = baseSeed();
      const grant = seed["programStaffGrants/program-1__dispatcher-1"];
      grant.programAuthorization = {
        ownerUid: "manager-1", approvedByUid: "manager-1",
        approvedAtMillis: now.toMillis() - 1,
        authorizedUntilMillis: expiry, ...patch,
      };
      const db = new FakeFirestore(seed) as unknown as
        FirebaseFirestore.Firestore;
      await assert.rejects(requireProgramAccess({db, programId: "program-1",
        actorUid: "dispatcher-1", now}), code("permission-denied"));
    });
}

for (const marker of [{revokedAt: now}, {revokedBy: "manager-1"}]) {
  test("active status cannot override a recorded revocation", async () => {
    const seed = baseSeed();
    Object.assign(seed["programStaffGrants/program-1__dispatcher-1"], marker);
    const db = new FakeFirestore(seed) as unknown as
      FirebaseFirestore.Firestore;
    await assert.rejects(requireProgramAccess({db, programId: "program-1",
      actorUid: "dispatcher-1", now}), code("permission-denied"));
  });
}


for (const transactional of [false, true]) {
  const phase = transactional ? "in transaction" : "before grant";
  test(`function scope validates ownership ${phase}`,
    async () => {
      const store = new FakeFirestore({
        "programFunctions/owned": {
          programId: "program-1", organizerId: "org-1"},
        "programFunctions/foreign-program": {
          programId: "program-2", organizerId: "org-1"},
        "programFunctions/foreign-organizer": {
          programId: "program-1", organizerId: "org-2"},
      });
      const db = store as unknown as FirebaseFirestore.Firestore;
      const validate = (functionIds: string[]) => {
        const params = {db, programId: "program-1", organizerId: "org-1",
          duties: [{duty: "functionCheckIn" as const, pickupPointIds: [],
            hotelIds: [], functionIds}]};
        return transactional ? db.runTransaction((transaction) =>
          validateDutyStations({...params, transaction})) :
          validateDutyStations(params);
      };
      for (const ids of [["missing"], ["foreign-program"],
        ["foreign-organizer"], ["owned", "missing"]]) {
        await assert.rejects(validate(ids), (error: unknown) => {
          const failure = error as {code?: string; message?: string};
          return failure.code === "invalid-argument" && failure.message ===
            "Assigned functions must belong to this program.";
        });
      }
      // Functions have a status lifecycle, not the active flag on stations.
      await validate(["owned", "owned"]);
      await validate([]);
    });
}
