import assert from "node:assert/strict";
import test from "node:test";
import {FieldValue, Timestamp} from "firebase-admin/firestore";
import {FakeFirestore} from "./programFirestore";
import {baseSeed, readySeed, transportSettings} from "./programFixtures";

const mutable = () => ({nested: {items: [{value: 1}]}});
type MutableData = ReturnType<typeof mutable>;

for (const kind of ["batch", "transaction"] as const) {
  test(`${kind} restores earlier writes after a later failure`, async () => {
    const db = new FakeFirestore({
      "items/existing": {count: 2, nested: {count: 3}},
      "items/deleted": {value: "keep"},
    });
    await db.runTransaction(async () => undefined);
    const before = new Map(db.docs);
    const write = (tx: ReturnType<FakeFirestore["batch"]>) => {
      tx.set(db.doc("items/new"), {value: "discard"});
      tx.update(db.doc("items/existing"), {
        "count": FieldValue.increment(4),
        "nested.count": FieldValue.increment(-1),
      });
      tx.delete(db.doc("items/deleted"));
      tx.update(db.doc("items/missing"), {value: "fail"});
    };
    if (kind === "batch") {
      const batch = db.batch();
      write(batch);
      await assert.rejects(batch.commit(), /Document missing/);
    } else {
      await assert.rejects(db.runTransaction(async (tx) => {
        // The shared write methods have the same behavior on both adapters.
        tx.set(db.doc("items/new"), {value: "discard"});
        tx.update(db.doc("items/existing"), {
          "count": FieldValue.increment(4),
          "nested.count": FieldValue.increment(-1),
        });
        tx.delete(db.doc("items/deleted"));
        tx.update(db.doc("items/missing"), {value: "fail"});
      }), /Document missing/);
    }
    assert.deepEqual(db.docs, before);
    assert.equal(db.transactionCommits, 1);
  });

  test(`failed ${kind} does not trigger an unrelated retry`, async () => {
    const db = new FakeFirestore({"items/existing": {count: 1}});
    let attempts = 0;
    db.beforeCommit = async () => {
      db.beforeCommit = undefined;
      if (kind === "batch") {
        const batch = db.batch();
        batch.set(db.doc("items/temporary"), {count: 2});
        batch.update(db.doc("items/missing"), {count: 3});
        await assert.rejects(batch.commit());
      } else {
        await assert.rejects(db.runTransaction(async (tx) => {
          tx.set(db.doc("items/temporary"), {count: 2});
          tx.update(db.doc("items/missing"), {count: 3});
        }));
      }
    };
    await db.runTransaction(async (tx) => {
      attempts++;
      await tx.get(db.doc("items/existing"));
      tx.update(db.doc("items/existing"), {count: 2});
    });
    assert.equal(attempts, 1);
    assert.equal(db.transactionCommits, 1);
    assert.equal(db.getDoc("items/temporary"), undefined);
  });
}

test("successful batches and transactions preserve transforms and counters",
  async () => {
    const stamp = new Timestamp(1_800_000_000, 123456789);
    const db = new FakeFirestore({
      "items/existing": {stamp, count: 2, nested: {count: 3}, text: "old"},
      "items/deleted": {value: 1},
    });
    const batch = db.batch();
    batch.set(db.doc("items/new"), {stamp, values: [stamp]});
    batch.update(db.doc("items/existing"), {
      "count": FieldValue.increment(4),
      "nested.count": FieldValue.increment(-2),
      "text": FieldValue.increment(5),
      "absent": FieldValue.increment(7),
    });
    batch.delete(db.doc("items/deleted"));
    await batch.commit();
    assert.equal(db.transactionCommits, 0);
    await db.runTransaction(async (tx) => {
      const snap = await tx.get(db.doc("items/existing"));
      assert.ok("exists" in snap);
      assert.equal(snap.exists, true);
      tx.create(db.doc("items/created"), {stamp});
    });
    assert.equal(db.transactionCommits, 1);
    assert.deepEqual(db.getDoc("items/existing"), {
      stamp, count: 6, nested: {count: 1}, text: 5, absent: 7,
    });
    assert.equal(db.getDoc("items/deleted"), undefined);
    const snap = await db.doc("items/new").get();
    const saved = snap.data()!.stamp as Timestamp;
    assert.equal(saved.isEqual(stamp), true);
    assert.equal(saved.toMillis(), stamp.toMillis());
    assert.deepEqual(saved.toDate(), stamp.toDate());
    assert.equal(saved.nanoseconds, 123456789);
    assert.equal((snap.data()!.values as Timestamp[])[0].isEqual(stamp), true);
  });

for (const mode of ["seed", "set", "update", "batch-set", "batch-update",
  "transaction-set", "transaction-create", "transaction-update"] as const) {
  test(`${mode} detaches nested records and arrays from caller payload`,
    async () => {
      const payload = mutable();
      const db = new FakeFirestore(mode === "seed" ?
        {"items/one": payload} : {"items/one": {}});
      const ref = db.doc("items/one");
      if (mode === "set") await ref.set(payload);
      if (mode === "update") await ref.update(payload);
      if (mode.startsWith("batch-")) {
        const batch = db.batch();
        if (mode === "batch-set") batch.set(ref, payload);
        else batch.update(ref, payload);
        payload.nested.items[0].value = 9;
        await batch.commit();
      }
      if (mode.startsWith("transaction-")) {
        if (mode === "transaction-create") db.docs.delete(ref.path);
        await db.runTransaction(async (tx) => {
          if (mode === "transaction-create") tx.create(ref, payload);
          else if (mode === "transaction-set") tx.set(ref, payload);
          else tx.update(ref, payload);
          payload.nested.items[0].value = 9;
        });
      }
      payload.nested.items[0].value = 10;
      payload.nested.items.push({value: 11});
      assert.deepEqual(db.getDoc(ref.path), mutable());
    });
}

for (const kind of ["document", "query"] as const) {
  test(`${kind} snapshots isolate captured data and reads`, async () => {
    const db = new FakeFirestore({"items/one": mutable()});
    const snap = kind === "document" ? await db.doc("items/one").get() :
      (await db.collection("items").get()).docs[0];
    const data = snap.data() as MutableData;
    data.nested.items[0].value = 9;
    data.nested.items.push({value: 10});
    assert.deepEqual(db.getDoc("items/one"), mutable());
    assert.deepEqual(snap.data(), mutable());
    // These intentionally mutable setup ports must remain usable, while old
    // public snapshots retain their captured values.
    (db.getDoc("items/one") as MutableData).nested.items[0].value = 5;
    assert.deepEqual(snap.data(), mutable());
    assert.equal(((await db.doc("items/one").get()).data() as MutableData)
      .nested.items[0].value, 5);
    db.docs.delete("items/one");
    assert.equal((await db.doc("items/one").get()).exists, false);
    assert.equal(snap.exists, true);
  });
}

test("dotted updates detach nested payloads and retain snapshot values",
  async () => {
    const db = new FakeFirestore({"items/one": {nested: {value: 1}}});
    const snap = await db.doc("items/one").get();
    const value = [{count: 2}];
    await db.doc("items/one").update({"nested.value": value});
    value[0].count = 9;
    assert.deepEqual(db.getDoc("items/one"), {nested: {value: [{count: 2}]}});
    assert.deepEqual(snap.data(), {nested: {value: 1}});
  });

test("plain null-prototype records copy safely without flattening SDK values",
  async () => {
    const record = Object.create(null) as Record<string, unknown>;
    record.items = [{value: 1}];
    record.__proto__ = {literal: true};
    const stamp = Timestamp.fromMillis(1234);
    const increment = FieldValue.increment(3);
    const db = new FakeFirestore({"items/one": {record, stamp, increment}});
    (record.items as Array<{value: number}>)[0].value = 9;
    const data = (await db.doc("items/one").get()).data()!;
    const copied = data.record as Record<string, unknown>;
    assert.equal(Object.getPrototypeOf(copied), null);
    assert.deepEqual(copied.items, [{value: 1}]);
    assert.equal(Object.hasOwn(copied, "__proto__"), true);
    assert.deepEqual(copied.__proto__, {literal: true});
    assert.equal(data.stamp, stamp);
    assert.equal(data.increment, increment);
  });

test("external committed changes survive conflicts and later failed writes",
  async () => {
    const db = new FakeFirestore({"items/one": {count: 1}});
    let attempts = 0;
    db.beforeCommit = async () => {
      db.beforeCommit = undefined;
      db.updateDoc("items/one", {count: 4});
    };
    await assert.rejects(db.runTransaction(async (tx) => {
      attempts++;
      const doc = await tx.get(db.doc("items/one"));
      assert.ok("data" in doc);
      tx.update(db.doc("items/one"), {count: Number(doc.data()!.count) + 1});
      tx.update(db.doc("items/missing"), {count: 10});
    }), /Document missing/);
    assert.equal(attempts, 2);
    assert.deepEqual(db.getDoc("items/one"), {count: 4});
    assert.equal(db.transactionCommits, 0);
  });

test("callback failures and read-after-write guards leave no commits",
  async () => {
    const db = new FakeFirestore({});
    const first = db.collection("items").doc();
    await assert.rejects(db.runTransaction(async (tx) => {
      tx.set(first, {value: 1});
      throw new Error("callback failed");
    }), /callback failed/);
    await assert.rejects(db.runTransaction(async (tx) => {
      tx.set(first, {value: 2});
      await tx.get(first);
    }), /reads before writes/);
    assert.equal(db.docs.size, 0);
    assert.equal(db.transactionCommits, 0);
    assert.notEqual(db.collection("items").doc().id, first.id);
  });

test("baseSeed and readySeed do not share mutable defaults", () => {
  const settings = (seed: ReturnType<typeof baseSeed>) =>
    seed["organizerPrograms/program-1"].transportSettings as
      typeof transportSettings;
  const original = transportSettings.vehicleClasses[0].passengerCapacity;
  try {
    const first = baseSeed();
    const second = baseSeed();
    settings(first).vehicleClasses[0].passengerCapacity = 99;
    settings(first).vehicleClasses[1].capabilities.push("changed");
    assert.equal(settings(second).vehicleClasses[0].passengerCapacity, 3);
    assert.deepEqual(settings(second).vehicleClasses[1].capabilities,
      ["extraLuggage"]);
    transportSettings.vehicleClasses[0].passengerCapacity = 77;
    assert.equal(settings(baseSeed()).vehicleClasses[0].passengerCapacity, 3);
    assert.equal(settings(readySeed()).vehicleClasses[0].passengerCapacity, 3);
  } finally {
    transportSettings.vehicleClasses[0].passengerCapacity = original;
  }
});
