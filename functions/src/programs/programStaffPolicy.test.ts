import assert from "node:assert/strict";
import test from "node:test";
import {activeProgramDuties, dutyAssignments, dutyCoversTransportRoute,
  requireProgramAccess, requireProgramDuty} from "../shared/programAuthority";
import type {ProgramAccess, ProgramDutyAssignment} from
  "../shared/programAuthority";
import {baseSeed, now} from "../shared/testing/programFixtures";
import {FakeFirestore} from "../shared/testing/programFirestore";
import {dedupeDuties, grantDuties} from "./programStaffPolicy";

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
