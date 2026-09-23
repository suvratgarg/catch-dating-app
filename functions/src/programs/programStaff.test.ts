import assert from "node:assert/strict";
import test from "node:test";
import {baseSeed, deps, now, request} from "../shared/testing/programFixtures";
import {FakeFirestore} from "../shared/testing/programFirestore";
import {getProgramWorkAccessHandler, grantProgramStaffHandler,
  revokeProgramStaffHandler} from
  "./programStaff";

const payload = {programId: "program-1", phoneNumber: "+919900001111",
  expiresAtMillis: now.toMillis() + 60_000,
  duties: [{duty: "airportGreeter", pickupPointIds: ["pp-t3"], hotelIds: []}]};
const code = (expected: string) => (error: unknown) =>
  (error as {code?: string}).code === expected;

for (const patch of [{active: false}, {programId: "foreign"},
  {organizerId: "foreign"}]) {
  test(`direct grants recheck resource changes: ${JSON.stringify(patch)}`,
    async () => {
      const store = new FakeFirestore(baseSeed());
      store.beforeCommit = async () => {
        store.beforeCommit = undefined;
        store.updateDoc("programPickupPoints/pp-t3", patch);
      };
      await assert.rejects(grantProgramStaffHandler(
        request(payload, "manager-1"), deps(store)), code("invalid-argument"));
      assert.equal(store.getDoc("programStaffGrants/program-1__new-staff-1"),
        undefined);
    });
}

for (const duties of [
  [{duty: "hotelDesk", pickupPointIds: ["pp-t3"], hotelIds: ["hotel-1"]}],
  [{duty: "programCoordinator", pickupPointIds: [], hotelIds: ["hotel-1"]}],
]) {
  test("direct grants reject misleading named-duty scope", async () => {
    const store = new FakeFirestore(baseSeed());
    await assert.rejects(grantProgramStaffHandler(
      request({...payload, duties}, "manager-1"), deps(store)),
    code("invalid-argument"));
    assert.equal(store.transactionCommits, 0);
  });
}

test("direct grant retries require current management", async () => {
  const store = new FakeFirestore(baseSeed());
  store.beforeCommit = async () => {
    store.beforeCommit = undefined;
    store.updateDoc("organizers/org-1", {ownerUserId: "other",
      hostUserId: "other", hostUserIds: [], hostProfiles: []});
  };
  await assert.rejects(grantProgramStaffHandler(
    request(payload, "manager-1"), deps(store)), code("permission-denied"));
  assert.equal(store.getDoc("programStaffGrants/program-1__new-staff-1"),
    undefined);
});

for (const patch of [{organizerId: "foreign"}, {programId: "foreign"},
  {uid: "other-user"}]) {
  test(`staff mutations preserve foreign bindings: ${JSON.stringify(patch)}`,
    async () => {
      const store = new FakeFirestore(baseSeed());
      const foreign = {
        ...store.getDoc("programStaffGrants/program-1__greeter-1"),
        ...patch};
      store.setDoc("programStaffGrants/program-1__greeter-1", foreign);
      store.setDoc("programStaffGrants/program-1__new-staff-1",
        {...foreign, uid: "new-staff-1", ...patch});
      await assert.rejects(grantProgramStaffHandler(
        request(payload, "manager-1"), deps(store)),
      code("failed-precondition"));
      await assert.rejects(revokeProgramStaffHandler(request({
        programId: "program-1", uid: "greeter-1", expectedRevision: 1,
      }, "manager-1"), deps(store)), code("not-found"));
      assert.deepEqual(store.getDoc("programStaffGrants/program-1__greeter-1"),
        foreign);
    });
}

for (const [collection, existingId, uid, field] of [
  ["programPickupPoints", "pp-t3", "greeter-1", "pickupPoints"],
  ["programHotels", "hotel-1", "hotelier-1", "hotels"],
] as const) {
  test(`assigned ${collection} cannot be crowded out by unrelated resources`,
    async () => {
      const seed = baseSeed();
      const noise = Object.fromEntries(Array.from({length: 80}, (_, i) =>
        [`${collection}/noise-${i}`, seed[`${collection}/${existingId}`]]));
      const store = new FakeFirestore({...noise, ...seed});
      const access = await getProgramWorkAccessHandler(
        request({programId: "program-1"}, uid), deps(store));
      assert.equal(access[field].length, 1);
      if (field === "pickupPoints") {
        assert.equal(access.pickupPoints[0].pickupPointId, existingId);
      } else {
        assert.equal(access.hotels[0].hotelId, existingId);
        assert.deepEqual(access.pickupPoints, []);
      }
    });

  test(`unrestricted ${collection} overflow is explicit`, async () => {
    const seed = baseSeed();
    const noise = Object.fromEntries(Array.from({length: 80}, (_, i) =>
      [`${collection}/noise-${i}`, seed[`${collection}/${existingId}`]]));
    const store = new FakeFirestore({...noise, ...seed});
    await assert.rejects(getProgramWorkAccessHandler(
      request({programId: "program-1"}, "manager-1"), deps(store)),
    code("resource-exhausted"));
  });

  test(`foreign ${collection} cannot occupy the current owner's page`,
    async () => {
      const seed = baseSeed();
      const noise = Object.fromEntries(Array.from({length: 80}, (_, i) =>
        [`${collection}/noise-${i}`, {...seed[`${collection}/${existingId}`],
          organizerId: "foreign"}]));
      const store = new FakeFirestore({...noise, ...seed});
      const access = await getProgramWorkAccessHandler(
        request({programId: "program-1"}, "manager-1"), deps(store));
      assert.equal(access[field].length, 2);
    });
}

for (const patch of [{active: false}, {organizerId: "foreign"},
  {programId: "foreign"}]) {
  test(`bootstrap omits stale resource bindings: ${JSON.stringify(patch)}`,
    async () => {
      const store = new FakeFirestore(baseSeed());
      store.updateDoc("programPickupPoints/pp-t3", patch);
      const access = await getProgramWorkAccessHandler(
        request({programId: "program-1"}, "greeter-1"), deps(store));
      assert.deepEqual(access.pickupPoints, []);
    });
}

test("the union of individually bounded assignments cannot truncate bootstrap",
  async () => {
    const store = new FakeFirestore(baseSeed());
    const ids = Array.from({length: 33}, (_, i) => `point-${i}`);
    for (const id of ids) {
      store.setDoc(`programPickupPoints/${id}`,
        store.getDoc("programPickupPoints/pp-t3")!);
    }
    store.updateDoc("programStaffGrants/program-1__greeter-1", {duties:
      [ids.slice(0, 16), ids.slice(16)].map((pickupPointIds) => ({
        duty: "airportGreeter", pickupPointIds, hotelIds: [],
        expiresAtMillis: now.toMillis() + 60_000,
      }))});
    await assert.rejects(getProgramWorkAccessHandler(
      request({programId: "program-1"}, "greeter-1"), deps(store)),
    code("resource-exhausted"));
  });
