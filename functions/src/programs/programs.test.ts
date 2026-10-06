import assert from "node:assert/strict";
import test from "node:test";
import {baseSeed, deps, request, now} from "../shared/testing/programFixtures";
import {FakeFirestore} from "../shared/testing/programFirestore";
import {createOrganizerProgramHandler, listOrganizerProgramsHandler} from
  "./programs";

const input = (extra: Record<string, unknown> = {}) => ({
  organizerId: "org-1", kind: "wedding", title: "Wedding weekend",
  timezone: "Asia/Kolkata", startsAtMillis: now.toMillis(),
  endsAtMillis: now.toMillis() + 86_400_000,
  capabilities: ["arrivalsTransport"],
  ...extra,
});
const code = (expected: string) => (error: unknown) =>
  (error as {code?: string}).code === expected;
const create = (db: FakeFirestore, extra: Record<string, unknown> = {},
  uid = "manager-1") => createOrganizerProgramHandler(
  request(input(extra), uid), deps(db));
const inventory = (db: FakeFirestore, organizerId = "org-1",
  uid = "manager-1") => listOrganizerProgramsHandler(
  request({organizerId}, uid), deps(db));

test("create receipt persists the same ID in the draft inventory", async () => {
  const db = new FakeFirestore(baseSeed());
  const result = await create(db, {requestId: "program-create-request-1"});
  assert.equal(db.getDoc(`organizerPrograms/${result.entityId}`)!.status,
    "draft");
  const rows = (await inventory(db)).programs;
  const saved = rows.find((row) => row.programId === result.entityId)!;
  assert.equal(saved.title, "Wedding weekend");
  assert.equal(saved.startsAtMillis, input().startsAtMillis);
  assert.equal(saved.endsAtMillis, input().endsAtMillis);
  assert.equal(saved.functionCount, 0);
  assert.ok(rows.some((row) => row.programId === "program-1"));
});

test(
  "missing required fields and equal/reversed dates write nothing",
  async () => {
    for (const extra of [
      {title: " "}, {kind: ""}, {timezone: " "},
      {timezone: "Not/AZone"},
      {startsAtMillis: undefined}, {endsAtMillis: undefined},
      {endsAtMillis: now.toMillis()},
      {endsAtMillis: now.toMillis() - 1},
    ]) {
      const db = new FakeFirestore(baseSeed());
      const before = new Map(db.docs);
      await assert.rejects(create(db, extra), code("invalid-argument"));
      assert.deepEqual(db.docs, before);
    }
  }
);

test(
  "lost-response replay and concurrent duplicate submits create one ID",
  async () => {
    const db = new FakeFirestore(baseSeed());
    const key = {requestId: "program-create-request-1"};
    const first = await create(db, key);
    const replay = await create(db, key);
    assert.equal(replay.entityId, first.entityId);
    assert.equal(replay.alreadyApplied, true);
    const concurrent = await Promise.all([create(db, key), create(db, key)]);
    assert.ok(concurrent.every((row) => row.entityId === first.entityId));
    assert.equal([...db.docs.keys()].filter((path) =>
      path.startsWith("organizerPrograms/")).length, 2);
  }
);

test(
  "request reuse with a changed body cannot overwrite or create",
  async () => {
    const db = new FakeFirestore(baseSeed());
    const key = {requestId: "program-create-request-1"};
    await create(db, key);
    const before = new Map(db.docs);
    await assert.rejects(create(db, {...key, title: "Different program"}),
      code("failed-precondition"));
    assert.deepEqual(db.docs, before);
  }
);

test(
  "same title is allowed for distinct requests; legacy IDs stay intact",
  async () => {
    const db = new FakeFirestore(baseSeed());
    const legacy = db.getDoc("organizerPrograms/program-1");
    const first = await create(db, {requestId: "program-create-request-1"});
    const second = await create(db, {requestId: "program-create-request-2"});
    const oldClient = await create(db);
    assert.notEqual(first.entityId, second.entityId);
    assert.notEqual(first.entityId, oldClient.entityId);
    assert.deepEqual(db.getDoc("organizerPrograms/program-1"), legacy);
  }
);

test(
  "create and receipt replay recheck current organizer authority",
  async () => {
    const db = new FakeFirestore(baseSeed());
    await assert.rejects(create(db, {}, "outsider"), code("permission-denied"));
    const key = {requestId: "program-create-request-1"};
    await create(db, key);
    db.updateDoc("organizers/org-1", {ownerUserId: "other",
      hostUserId: "other", hostUserIds: ["other"], hostProfiles: []});
    const before = new Map(db.docs);
    await assert.rejects(create(db, key), code("permission-denied"));
    assert.deepEqual(db.docs, before);
  }
);

test(
  "deleted accounts cannot create, replay, list, or read an exact program",
  async () => {
    const db = new FakeFirestore(baseSeed());
    const key = {requestId: "program-create-request-1"};
    const created = await create(db, key);
    db.setDoc("deletedUsers/manager-1", {status: "processing"});
    const before = new Map(db.docs);
    await assert.rejects(create(db, key), code("permission-denied"));
    await assert.rejects(inventory(db), code("permission-denied"));
    await assert.rejects(
      listOrganizerProgramsHandler(
        request(
          {organizerId: "org-1", programId: created.entityId},
          "manager-1"
        ),
        deps(db)
      ),
      code("permission-denied")
    );
    assert.deepEqual(db.docs, before);
  }
);

test("the same request key remains isolated to its organizer", async () => {
  const seed = baseSeed();
  seed["organizers/org-2"] = {...seed["organizers/org-1"]};
  const db = new FakeFirestore(seed);
  const key = {requestId: "program-create-request-1"};
  const first = await create(db, key);
  const second = await create(db, {...key, organizerId: "org-2"});
  assert.notEqual(first.entityId, second.entityId);
  const rows = (await inventory(db, "org-2")).programs;
  assert.deepEqual(rows.map((row) => row.programId), [second.entityId]);
});

test(
  "inventory event counts include only listed authorized programs",
  async () => {
    const seed = baseSeed();
    seed["organizerPrograms/foreign"] = {
      ...seed["organizerPrograms/program-1"], organizerId: "org-2",
    };
    seed["programFunctions/one"] = {
      programId: "program-1", organizerId: "org-1",
    };
    seed["programFunctions/two"] = {
      programId: "program-1", organizerId: "org-1",
    };
    seed["programFunctions/foreign"] = {
      programId: "foreign", organizerId: "org-2",
    };
    seed["programFunctions/wrong-owner"] = {
      programId: "program-1", organizerId: "org-2",
    };
    const db = new FakeFirestore(seed);
    const rows = (await inventory(db)).programs;
    assert.deepEqual(rows.map((row) => [row.programId, row.functionCount]),
      [["program-1", 2]]);
    await assert.rejects(inventory(db, "org-1", "outsider"),
      code("permission-denied"));
  }
);

test(
  "incomplete or failed count reads omit counts and preserve programs",
  async () => {
    const seed = baseSeed();
    for (let index = 0; index < 2001; index++) {
      seed[`programFunctions/function-${index}`] = {
        organizerId: "org-1", programId: "program-1",
      };
    }
    const db = new FakeFirestore(seed);
    const capped = (await inventory(db)).programs;
    assert.equal(capped.length, 1);
    assert.equal("functionCount" in capped[0], false);
    const runQuery = db.runQuery.bind(db);
    db.runQuery = async (query) => {
      if (query.collectionPath === "programFunctions") {
        throw new Error("count unavailable");
      }
      return runQuery(query);
    };
    const failed = (await inventory(db)).programs;
    assert.equal(failed[0].programId, "program-1");
    assert.equal("functionCount" in failed[0], false);
  }
);

test(
  "same-start inventory pages use snapshot ties without omissions",
  async () => {
    const seed = baseSeed();
    for (let i = 0; i < 55; i++) {
      seed[`organizerPrograms/tie-${String(i).padStart(2, "0")}`] = {
        ...seed["organizerPrograms/program-1"],
      };
    }
    const db = new FakeFirestore(seed);
    const first = await listOrganizerProgramsHandler(
      request({organizerId: "org-1"}, "manager-1"), deps(db));
    assert.equal(first.programs.length, 50);
    assert.ok(first.nextCursor);
    const second = await listOrganizerProgramsHandler(
      request({organizerId: "org-1", cursor: first.nextCursor}, "manager-1"),
      deps(db));
    assert.equal(second.programs.length, 6);
    assert.equal(second.nextCursor, null);
    const uniqueIds = new Set(
      [...first.programs, ...second.programs].map((row) => row.programId)
    );
    assert.equal(uniqueIds.size, 56);
  }
);

test("cursor and exact-ID requests recheck organizer scope", async () => {
  const seed = baseSeed();
  seed["organizers/org-2"] = {...seed["organizers/org-1"]};
  seed["organizerPrograms/foreign"] = {
    ...seed["organizerPrograms/program-1"], organizerId: "org-2",
  };
  const db = new FakeFirestore(seed);
  const selectors = [
    {cursor: "foreign"},
    {programId: "foreign"},
    {cursor: "missing"},
    {programId: "missing"},
  ];
  for (const selector of selectors) {
    await assert.rejects(listOrganizerProgramsHandler(
      request({organizerId: "org-1", ...selector}, "manager-1"), deps(db)),
    code("not-found"));
  }
  await assert.rejects(listOrganizerProgramsHandler(request({
    organizerId: "org-1", cursor: "program-1", programId: "program-1",
  }, "manager-1"), deps(db)), code("invalid-argument"));
  await assert.rejects(listOrganizerProgramsHandler(request({
    organizerId: "org-1", programId: "program-1",
  }, "outsider"), deps(db)), code("permission-denied"));
});

test(
  "earlier-start creation confirms by exact ID without scanning inventory",
  async () => {
    const seed = baseSeed();
    for (let i = 0; i < 55; i++) {
      seed[`organizerPrograms/recent-${i}`] = {
        ...seed["organizerPrograms/program-1"],
      };
    }
    const db = new FakeFirestore(seed);
    const result = await create(db, {
      requestId: "earlier-start-request", startsAtMillis: 1, endsAtMillis: 2,
    });
    const firstPage = (await inventory(db)).programs;
    assert.equal(
      firstPage.some((row) => row.programId === result.entityId),
      false
    );
    const queryPaths: string[] = [];
    const runQuery = db.runQuery.bind(db);
    db.runQuery = async (query) => {
      queryPaths.push(query.collectionPath); return runQuery(query);
    };
    const exact = await listOrganizerProgramsHandler(request({
      organizerId: "org-1", programId: result.entityId,
    }, "manager-1"), deps(db));
    assert.equal(exact.programs.length, 1);
    assert.equal(exact.programs[0].programId, result.entityId);
    assert.equal(exact.programs[0].functionCount, 0);
    assert.equal(exact.nextCursor, null);
    assert.deepEqual(queryPaths, ["programFunctions"]);
  }
);
