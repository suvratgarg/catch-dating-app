import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import {baseSeed, deps, now, request} from "../shared/testing/programFixtures";
import {FakeFirestore} from "../shared/testing/programFirestore";
import {getProgramWorkAccessHandler, grantProgramStaffHandler,
  revokeProgramStaffHandler, listProgramStaffHandler} from
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

test("staff pages reach older active grants beyond newer history",
  async () => {
    const seed = baseSeed();
    const template = seed["programStaffGrants/program-1__greeter-1"];
    for (const path of Object.keys(seed)) {
      if (path.startsWith("programStaffGrants/")) delete seed[path];
    }
    const expected = Array.from({length: 123}, (_, i) =>
      `staff-${String(i).padStart(3, "0")}`);
    for (const [i, uid] of expected.entries()) {
      seed[`programStaffGrants/program-1__${uid}`] = {...template, uid,
        status: i === 122 ? "active" : "revoked",
        updatedAt: i === 122 ?
          Timestamp.fromMillis(now.toMillis() - 60_000) : now};
    }
    for (let i = 0; i < 130; i++) {
      const uid = `foreign-${i}`;
      seed[`programStaffGrants/program-1__${uid}`] = {...template, uid,
        organizerId: "foreign"};
    }
    const db = new FakeFirestore(seed);
    const seen: string[] = [];
    let cursor: string | null = null;
    do {
      const page = await listProgramStaffHandler(request({
        programId: "program-1", ...(cursor ? {cursor} : {}),
      }, "manager-1"), deps(db));
      assert.ok(page.members.length <= 50);
      seen.push(...page.members.map((member) => member.uid));
      cursor = page.nextCursor;
      assert.ok(seen.length <= expected.length, "cursor must advance");
      if (!cursor) assert.equal(page.members.at(-1)?.status, "active");
    } while (cursor);
    assert.deepEqual(seen, expected);
  });

test("staff continuations survive revocation and deletion of the anchor",
  async () => {
    const db = new FakeFirestore(baseSeed());
    const read = (cursor?: string) => listProgramStaffHandler(request({
      programId: "program-1", limit: 1, ...(cursor ? {cursor} : {}),
    }, "manager-1"), deps(db));
    const first = await read();
    assert.equal(first.nextCursor, "dispatcher-1");
    db.updateDoc("programStaffGrants/program-1__dispatcher-1", {
      status: "revoked", updatedAt: now,
    });
    assert.equal((await read(first.nextCursor!)).members[0].uid, "greeter-1");
    db.docs.delete("programStaffGrants/program-1__dispatcher-1");
    assert.equal((await read(first.nextCursor!)).members[0].uid, "greeter-1");
    db.updateDoc("organizers/org-1", {ownerUserId: "other",
      hostUserId: "other", hostUserIds: [], hostProfiles: []});
    await assert.rejects(read(first.nextCursor!), code("permission-denied"));
  });

test("staff list rejects damaged identity bindings instead of looping pages",
  async () => {
    const db = new FakeFirestore(baseSeed());
    db.updateDoc("programStaffGrants/program-1__dispatcher-1", {uid: "other"});
    await assert.rejects(listProgramStaffHandler(request({
      programId: "program-1", limit: 1,
    }, "manager-1"), deps(db)), code("failed-precondition"));
  });

for (const action of ["grant", "revoke"]) {
  test(`${action} returns the committed receipt without a follow-up read`,
    async () => {
      const db = new FakeFirestore(baseSeed());
      const query = db.runQuery.bind(db);
      const get = db.getDoc.bind(db);
      db.runQuery = async (input) => {
        assert.equal(db.transactionCommits, 0, "no post-commit list query");
        return query(input);
      };
      db.getDoc = (path) => {
        assert.equal(db.transactionCommits, 0, "no post-commit document read");
        return get(path);
      };
      const receipt = action === "grant" ? await grantProgramStaffHandler(
        request(payload, "manager-1"), deps(db)) :
        await revokeProgramStaffHandler(request({
          programId: "program-1", uid: "greeter-1", expectedRevision: 1,
        }, "manager-1"), deps(db));
      const uid = action === "grant" ? "new-staff-1" : "greeter-1";
      const stored = db.docs.get(`programStaffGrants/program-1__${uid}`)!;
      assert.deepEqual(receipt, {entityId: uid, revision: stored.revision,
        alreadyApplied: false});
      assert.equal(stored.status, action === "grant" ? "active" : "revoked");
      assert.equal(db.transactionCommits, 1);
    });
}

for (const organizerId of ["org-1", "foreign"]) {
  test(`direct staff quota counts current owner only: ${organizerId}`,
    async () => {
      const seed = baseSeed();
      for (let i = 0; i < 100; i++) {
        const uid = `quota-${i}`;
        seed[`programStaffGrants/program-1__${uid}`] = {
          ...seed["programStaffGrants/program-1__greeter-1"], uid, organizerId};
      }
      const db = new FakeFirestore(seed);
      const grant = grantProgramStaffHandler(request(payload, "manager-1"),
        deps(db));
      if (organizerId === "org-1") {
        await assert.rejects(grant, code("resource-exhausted"));
        assert.equal(db.transactionCommits, 0);
      } else {
        assert.equal((await grant).entityId, "new-staff-1");
        assert.equal(db.transactionCommits, 1);
      }
    });
}

const functionDoc = (id: string, patch: Record<string, unknown> = {}) => ({
  programId: "program-1", organizerId: "org-1", name: id,
  startsAt: now, endsAt: now,
  venueName: "Venue", venueNotes: null, venueLocation: null,
  dressCode: null, instructions: null, invitationMode: "selectedGuests",
  checkInEnabled: true, expectedCount: 3, checkedInCount: 1,
  status: "scheduled", createdAt: now, updatedAt: now, revision: 1,
  ...patch,
});

const doorGrant = (uid: string, duty: string, functionIds?: string[]) => ({
  organizerId: "org-1", programId: "program-1", uid, displayName: uid,
  phoneLastFour: "0000",
  duties: [{
    duty, expiresAtMillis: now.toMillis() + 60_000,
    pickupPointIds: [], hotelIds: [],
    ...(functionIds === undefined ? {} : {functionIds}),
  }],
  status: "active", createdBy: "manager-1", createdAt: now,
  expiresAt: Timestamp.fromMillis(now.toMillis() + 86_400_000),
  revokedBy: null, revokedAt: null, updatedAt: now,
  revision: 1,
});

test("work access lists functions only for door duties, scoped by grant",
  async () => {
    const seed = baseSeed();
    seed["programFunctions/fn-sangeet"] = functionDoc("fn-sangeet");
    seed["programFunctions/fn-mehndi"] = functionDoc("fn-mehndi");
    seed["programFunctions/fn-foreign"] = functionDoc("fn-foreign",
      {organizerId: "foreign"});
    seed["programStaffGrants/program-1__door-1"] =
      doorGrant("door-1", "functionCheckIn", ["fn-sangeet"]);
    seed["programStaffGrants/program-1__lead-1"] =
      doorGrant("lead-1", "functionLead");
    const store = new FakeFirestore(seed);

    const scoped = await getProgramWorkAccessHandler(
      request({programId: "program-1"}, "door-1"), deps(store));
    assert.deepEqual(
      scoped.functions.map((f) => f.functionId), ["fn-sangeet"]);
    assert.equal(scoped.functions[0].checkInEnabled, true);
    assert.equal(scoped.functions[0].expectedCount, 3);

    const lead = await getProgramWorkAccessHandler(
      request({programId: "program-1"}, "lead-1"), deps(store));
    assert.deepEqual(
      lead.functions.map((f) => f.functionId).sort(),
      ["fn-mehndi", "fn-sangeet"]);

    const manager = await getProgramWorkAccessHandler(
      request({programId: "program-1"}, "manager-1"), deps(store));
    assert.equal(manager.functions.length, 2);

    const greeter = await getProgramWorkAccessHandler(
      request({programId: "program-1"}, "greeter-1"), deps(store));
    assert.deepEqual(greeter.functions, []);
  });

test("scoped door staff are not crowded out by unrelated functions",
  async () => {
    const seed = baseSeed();
    const noise = Object.fromEntries(Array.from({length: 80}, (_, i) =>
      [`programFunctions/fn-noise-${i}`, functionDoc(`fn-noise-${i}`)]));
    Object.assign(seed, noise);
    seed["programFunctions/fn-mine"] = functionDoc("fn-mine");
    seed["programStaffGrants/program-1__door-1"] =
      doorGrant("door-1", "functionCheckIn", ["fn-mine"]);
    const store = new FakeFirestore(seed);
    const access = await getProgramWorkAccessHandler(
      request({programId: "program-1"}, "door-1"), deps(store));
    assert.deepEqual(
      access.functions.map((f) => f.functionId), ["fn-mine"]);
  });

test("unrestricted function overflow is explicit", async () => {
  const seed = baseSeed();
  for (let i = 0; i < 60; i++) {
    seed[`programFunctions/fn-${i}`] = functionDoc(`fn-${i}`);
  }
  const store = new FakeFirestore(seed);
  await assert.rejects(getProgramWorkAccessHandler(
    request({programId: "program-1"}, "manager-1"), deps(store)),
  code("resource-exhausted"));
});
