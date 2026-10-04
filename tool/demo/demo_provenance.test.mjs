import assert from "node:assert/strict";
import test from "node:test";
import * as core from "./demo_ops_core.mjs";
import {
  applyDocPlan,
  buildMatchPhonePlan,
  buildResetUserDemoStatePlan,
  writeManifest,
} from "./demo_ops_core.mjs";

const now = new Date("2026-10-04T12:00:00.000Z");
const admin = {firestore: {Timestamp: {fromDate: (date) => date.toISOString()}}};

async function matchPlan(db, overrides = {}) {
  return buildMatchPhonePlan({
    db, admin, phoneA: "+16505550101", phoneB: "+16505550102",
    withMessages: true, viaSwipes: true, now, ...overrides,
  });
}

function syntheticStore(initial = {}) {
  const rows = new Map(Object.entries({
    "users/a": {phoneNumber: "+16505550101"},
    "users/b": {phoneNumber: "+16505550102"},
    "publicProfiles/a": {name: "Synthetic A"},
    "publicProfiles/b": {name: "Synthetic B"},
    "eventParticipations/run_a": {uid: "a", eventId: "run", status: "attended"},
    "eventParticipations/run_b": {uid: "b", eventId: "run", status: "attended"},
    ...initial,
  }));
  const clone = (value) => structuredClone(value);
  const snapshot = (path) => ({id: path.split("/").at(-1), ref: doc(path),
    exists: rows.has(path), data: () => clone(rows.get(path))});
  const doc = (path) => ({path, get: async () => snapshot(path),
    collection: (name) => collection(`${path}/${name}`),
    set: async (data) => rows.set(path, clone(data))});
  function collection(path, filters = []) {
    return {doc: (id) => doc(`${path}/${id}`),
      where: (field, op, value) => collection(path, [...filters, {field, op, value}]),
      limit: () => collection(path, filters),
      get: async () => {
        const docs = [...rows.keys()].filter((key) =>
          key.startsWith(`${path}/`) && key.split("/").length === path.split("/").length + 1
        ).filter((key) => filters.every(({field, op, value}) => op === "array-contains" ?
          rows.get(key)[field]?.includes(value) : rows.get(key)[field] === value)).map(snapshot);
        return {docs, size: docs.length, empty: docs.length === 0};
      }};
  }
  const db = {rows, doc, collection, beforeCommit: null, attempts: 0,
    dump: () => clone([...rows.entries()]),
    batch: () => {
      const writes = [];
      return {set: (ref, data) => writes.push([ref.path, clone(data)]),
        commit: async () => writes.forEach(([path, data]) => rows.set(path, {...rows.get(path), ...data}))};
    },
    runTransaction: async (body) => {
      for (;;) {
        db.attempts += 1;
        const writes = [];
        const tx = {get: async (ref) => snapshot(ref.path),
          create: (ref, data) => writes.push([ref.path, clone(data)]),
          set: (ref, data) => writes.push([ref.path, clone(data)]),
          update: (ref, data) => writes.push([ref.path, clone(data)])};
        const result = await body(tx);
        // Simulate Firestore optimistic retry when another creator changes a
        // document read by this transaction before commit. No staged writes land.
        if (db.beforeCommit) {
          const race = db.beforeCommit; db.beforeCommit = null; race(rows); continue;
        }
        for (const [path, data] of writes) rows.set(path, data);
        return result;
      }
    }};
  return db;
}

for (const status of ["active", "blocked"]) {
  test(`real ${status} pair and original messages remain byte-identical`, async () => {
    const real = {participantIds: ["a", "b"], eventIds: ["real-event"],
      status, blockedBy: status === "blocked" ? "b" : null, unreadCounts: {a: 7}};
    const db = syntheticStore({"matches/a_b": real,
      "matches/a_b/messages/real-history": {text: "Synthetic fixture for real-origin history"}});
    const before = db.dump();
    const plan = await matchPlan(db);
    await assert.rejects(applyDocPlan({db, docs: plan.docs}), /collision/);
    assert.deepEqual(db.dump(), before);
    const reset = await buildResetUserDemoStatePlan({db, uid: "a"});
    assert.equal(reset.paths.some((path) => path.startsWith("matches/")), false);
  });
}

test("real create racing after dry-run planning wins without demo companions", async () => {
  const db = syntheticStore();
  const plan = await matchPlan(db);
  const real = {participantIds: ["a", "b"], eventIds: ["real-event"], status: "blocked"};
  db.beforeCommit = (rows) => rows.set("matches/a_b", real);
  await assert.rejects(applyDocPlan({db, docs: plan.docs}), /collision/);
  assert.equal(db.attempts, 2);
  assert.deepEqual(db.rows.get("matches/a_b"), real);
  for (const item of plan.docs.filter((doc) => doc.path !== "matches/a_b")) {
    assert.equal(db.rows.has(item.path), false, item.path);
  }
});

test("new owned thread plans removal; same-run replay preserves block and history", async () => {
  const db = syntheticStore();
  const plan = await matchPlan(db);
  const first = await applyDocPlan({db, docs: plan.docs});
  assert.equal(first.written, plan.docs.length);
  const match = db.rows.get("matches/a_b");
  match.status = "blocked"; match.blockedBy = "b"; match.unreadCounts = {a: 4, b: 2};
  db.rows.set("matches/a_b/messages/dogfood", {text: "Synthetic unmarked dogfood fixture"});
  const before = db.dump();
  assert.deepEqual(await applyDocPlan({db, docs: plan.docs}), {written: 0});
  assert.deepEqual(db.dump(), before);
  await writeManifest({db, admin, plan, apply: true, now});
  const reset = await buildResetUserDemoStatePlan({db, uid: "a"});
  assert.ok(reset.paths.includes("matches/a_b"));
  assert.ok(reset.paths.includes("matches/a_b/messages/dogfood"));
  assert.ok(reset.paths.includes(`demoOpsEvents/${plan.operationId}`));
  assert.deepEqual(db.rows.get("matches/a_b"), match);
});

for (const variation of ["foreign-run", "mixed-events", "legacy-marker"]) {
  test(`${variation} pair is refused with no companion writes`, async () => {
    const db = syntheticStore();
    const plan = await matchPlan(db);
    const pair = structuredClone(plan.docs.find((doc) => doc.path === "matches/a_b").data);
    if (variation === "foreign-run") pair.demoOpsId += "__run_2";
    if (variation === "mixed-events") pair.eventIds.push("real-event");
    if (variation === "legacy-marker") pair.demoOpsCommand = "match-phones";
    db.rows.set("matches/a_b", pair);
    const before = db.dump();
    await assert.rejects(applyDocPlan({db, docs: plan.docs}), /collision|mixed/);
    assert.deepEqual(db.dump(), before);
  });
}

test("stale manifest cannot select a replacement generation or shared host root", async () => {
  const db = syntheticStore();
  const plan = await matchPlan(db);
  await applyDocPlan({db, docs: plan.docs});
  await writeManifest({db, admin, plan, apply: true, now});
  const manifest = db.rows.get(`demoOpsEvents/${plan.operationId}`);
  manifest.paths.push("organizers/shared-host");
  db.rows.set("organizers/shared-host", {synthetic: true, displayName: "Shared synthetic analogue"});
  for (const [path, value] of db.rows) {
    if (value.demoOpsId) value.demoOpsId += "__run_2";
  }
  const reset = await buildResetUserDemoStatePlan({db, uid: "a"});
  assert.equal(reset.paths.some((path) => path.startsWith("matches/")), false);
  assert.equal(reset.paths.includes("organizers/shared-host"), false);
  assert.ok(reset.retained.some((row) => row.path === "matches/a_b" && row.reason === "unproven-current-run"));
  assert.ok(reset.retained.some((row) => row.reason === "shared-root"));
});

test("same-run pair acquiring independent event origin is retained with history", async () => {
  const db = syntheticStore();
  const plan = await matchPlan(db);
  await applyDocPlan({db, docs: plan.docs});
  await writeManifest({db, admin, plan, apply: true, now});
  db.rows.get("matches/a_b").eventIds.push("real-event");
  const reset = await buildResetUserDemoStatePlan({db, uid: "a"});
  assert.equal(reset.paths.some((path) => path.startsWith("matches/")), false);
});

test("substring, orphan, foreign-prefix and old-generation message parents are retained", async () => {
  const owner = {synthetic: true, demoOps: true, seedPrefix: "seed",
    demoOpsId: "fixture__run_1", demoOpsCommand: "owned-match-v1"};
  const parents = {
    "matches/real_audit_seed_backup_pair": {participantIds: ["real-a", "real-b"]},
    "matches/seed_legacy": {synthetic: true, seedPrefix: "seed"},
    "matches/owned": owner,
    "matches/foreign": {...owner, seedPrefix: "other"},
    "matches/replaced": {...owner, demoOpsId: "fixture__run_2"},
  };
  const before = structuredClone(parents);
  const db = {collectionGroup: () => ({get: async () => ({docs:
    [...Object.keys(parents), "matches/orphan", "other/owned"].map((path) => ({ref: {
      path: `${path}/messages/history`, parent: {parent: {path,
        get: async () => ({exists: path in parents, data: () => parents[path]})}},
    }})),
  })})};
  assert.deepEqual(await core.syntheticMatchMessagePaths({db, seedPrefix: "seed", ownership: owner}),
    ["matches/owned/messages/history"]);
  assert.deepEqual(await core.syntheticMatchMessagePaths({db, seedPrefix: "seed"}), []);
  assert.deepEqual(parents, before);
});

test("foreign-run child retains an otherwise owned thread and original history", async () => {
  const db = syntheticStore();
  const plan = await matchPlan(db);
  await applyDocPlan({db, docs: plan.docs});
  await writeManifest({db, admin, plan, apply: true, now});
  db.rows.set("matches/a_b/messages/foreign", {
    ...db.rows.get("matches/a_b"), demoOpsId: "foreign__run_2", text: "Foreign synthetic origin",
  });
  const before = db.dump();
  const reset = await buildResetUserDemoStatePlan({db, uid: "a"});
  assert.equal(reset.paths.some((path) => path.startsWith("matches/")), false);
  assert.ok(reset.retained.some((row) => row.reason === "mixed-message-origin"));
  assert.deepEqual(db.dump(), before);
});

for (const status of ["active", "blocked"]) {
  test(`via-swipes-only preserves real ${status} pair and reciprocal decisions`, async () => {
    const db = syntheticStore({
      "matches/a_b": {participantIds: ["a", "b"], eventIds: ["run"], status, blockedBy: "b"},
      "profileDecisions/a/outgoing/b": {swiperId: "a", targetId: "b", direction: "pass"},
      "profileDecisions/b/outgoing/a": {swiperId: "b", targetId: "a", direction: "pass"},
    });
    const before = db.dump();
    const plan = await matchPlan(db, {direct: false, withMessages: false});
    await assert.rejects(applyDocPlan({db, docs: plan.docs}), /collision/);
    assert.deepEqual(db.dump(), before);
  });
}

test("via-swipes-only permits absent pair but rechecks a racing real creator", async () => {
  const db = syntheticStore();
  const plan = await matchPlan(db, {direct: false, withMessages: false});
  assert.deepEqual(await applyDocPlan({db, docs: plan.docs}), {written: 2});
  const raceDb = syntheticStore();
  const racePlan = await matchPlan(raceDb, {direct: false, withMessages: false});
  const real = {participantIds: ["a", "b"], eventIds: ["run"], status: "blocked"};
  raceDb.beforeCommit = (rows) => rows.set("matches/a_b", real);
  await assert.rejects(applyDocPlan({db: raceDb, docs: racePlan.docs}), /collision/);
  assert.deepEqual(raceDb.rows.get("matches/a_b"), real);
  assert.equal(raceDb.rows.has("profileDecisions/a/outgoing/b"), false);
  assert.equal(raceDb.rows.has("profileDecisions/b/outgoing/a"), false);
});
