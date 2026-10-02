import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import {createFormPaymentFixture} from
  "../payments/formPayments/formPaymentTestStore";
import {readParticipantFormActivityPageSource as read} from
  "./participantFormActivitySource";

async function fixture(ids: string[]) {
  const h = createFormPaymentFixture();
  const {paymentId} = await h.reserve();
  h.capture(paymentId);
  await h.finalize(paymentId);
  const original = [...h.store.records.keys()].find((path) =>
    path.startsWith("organizerFormResponses/"))!;
  const response = h.store.records.get(original)!;
  h.store.records.delete(original);
  for (const id of ids) {
    h.store.records.set(`organizerFormResponses/${id}`, {...response});
  }
  const points: string[] = [];
  const filters: unknown[][] = [];
  let queryReads = 0;
  const db = {collection: (name: string) => {
    const collection = h.store.collection(name);
    return name === "organizerFormResponses" ? {...collection,
      where: (field: string, operator: string, value: unknown) => {
        filters.push([field, operator, value]);
        return collection.where(field, operator, value);
      }} : collection;
  }, runTransaction: async <T>(work: (
    tx: FirebaseFirestore.Transaction) => Promise<T>) =>
    h.store.runTransaction(async (tx) => work({...tx,
      get: async (target: {path?: string; get?: () => Promise<unknown>}) => {
        if (target.path) {
          points.push(target.path);
          return tx.get({path: target.path});
        }
        queryReads++;
        assert.ok(target.get);
        return target.get();
      },
    } as unknown as FirebaseFirestore.Transaction)),
  } as unknown as FirebaseFirestore.Firestore;
  return {...h, response, points, filters,
    queryReads: () => queryReads,
    params: {db, uid: "person", limit: 2, cursor: null as string | null,
      nowMillis: 2000}};
}

test("owned pages filter UID and read each version once", async () => {
  const h = await fixture(["a", "b", "c"]);
  h.store.records.set("organizerFormResponses/aaa-foreign",
    {...h.response, respondentUid: "other"});
  const before = JSON.stringify([...h.store.records]);
  const first = await read(h.params);
  assert.deepEqual(first?.sources.map((row) => row.responseId), ["a", "b"]);
  assert.equal(h.store.records.has("users/person"), false);
  assert.deepEqual(h.filters, [["respondentUid", "==", "person"]]);
  assert.equal(h.queryReads(), 1);
  assert.deepEqual(h.points.sort(), ["deletedUsers/person",
    "organizerFormVersions/version", "users/person"]);
  assert.ok(first?.nextCursor);
  const second = await read({...h.params, cursor: first.nextCursor});
  assert.deepEqual(second?.sources.map((row) => row.responseId), ["c"]);
  assert.equal(second?.nextCursor, null);
  assert.equal(JSON.stringify([...h.store.records]), before);
});

test("empty omitted pages advance the scanned-row cursor", async () => {
  const h = await fixture(["a", "b", "c"]);
  h.store.records.set("organizerFormResponses/a", {...h.response,
    status: "withdrawn", withdrawnAt: Timestamp.fromMillis(1500)});
  h.store.records.set("organizerFormResponses/b", {...h.response,
    consentVersion: "different"});
  const first = await read(h.params);
  assert.deepEqual(first?.sources, []);
  assert.ok(first?.nextCursor);
  const second = await read({...h.params, cursor: first.nextCursor});
  assert.deepEqual(second?.sources.map((row) => row.responseId), ["c"]);
  assert.equal(second?.nextCursor, null);
});

test("corrupt long source IDs do not stall pagination", async () => {
  const h = await fixture(["a".repeat(181), "z"]);
  const first = await read({...h.params, limit: 1});
  assert.deepEqual(first?.sources, []);
  assert.ok(first?.nextCursor);
  const second = await read({...h.params, limit: 1, cursor: first.nextCursor});
  assert.deepEqual(second?.sources.map((row) => row.responseId), ["z"]);
  assert.equal(second?.nextCursor, null);
});

test("cached versions check each row's scope and notice", async () => {
  const h = await fixture(["a", "b", "c"]);
  h.store.records.set("organizerFormResponses/a", {...h.response,
    organizerId: "foreign"});
  h.store.records.set("organizerFormResponses/b", {...h.response,
    consentVersion: "changed"});
  const page = await read({...h.params, limit: 3});
  assert.deepEqual(page?.sources.map((row) => row.responseId), ["c"]);
  assert.equal(h.points.filter((path) =>
    path.startsWith("organizerFormVersions/")).length, 1);
  assert.equal(page?.nextCursor, null);
});

test("deleted subjects are unavailable before any history query", async () => {
  const h = await fixture(["a"]);
  for (const status of ["processing", "deleted"]) {
    h.store.records.set("deletedUsers/person", {status});
    assert.equal(await read(h.params), null);
  }
  h.store.records.delete("deletedUsers/person");
  h.store.records.set("users/person", {deleted: true});
  assert.equal(await read(h.params), null);
  assert.equal(h.queryReads(), 0);
});

test("page ceiling and empty history keep honest cursors", async () => {
  const h = await fixture(Array.from({length: 31}, (_, index) =>
    `row-${String(index).padStart(2, "0")}`));
  const page = await read({...h.params, limit: 30});
  assert.equal(page?.sources.length, 30);
  assert.ok(page?.nextCursor);
  const final = await read({...h.params, limit: 30, cursor: page.nextCursor});
  assert.equal(final?.sources.length, 1);
  assert.equal(final?.nextCursor, null);
  assert.deepEqual(await read({...h.params, uid: "empty"}),
    {sources: [], nextCursor: null});
});

test("scoped cursors reject bad input before transactions", async () => {
  const h = await fixture(["a", "b", "c"]);
  const first = await read(h.params);
  assert.ok(first?.nextCursor);
  const db = {runTransaction: () => {
    throw new Error("Unexpected transaction");
  }} as unknown as FirebaseFirestore.Firestore;
  const cursor = JSON.parse(Buffer.from(first.nextCursor, "base64url")
    .toString("utf8"));
  const encode = (value: unknown) =>
    Buffer.from(JSON.stringify(value)).toString("base64url");
  for (const invalid of ["", "invalid", "x".repeat(8193),
    `${first.nextCursor}=`, encode({...cursor, version: 2}),
    encode({...cursor, scope: "different"}), encode({...cursor, extra: true}),
    encode({...cursor, after: "../source"}),
    encode({...cursor, after: "x".repeat(1501)})]) {
    await assert.rejects(read({...h.params, db, cursor: invalid}), RangeError);
  }
  await assert.rejects(read({...h.params, db, uid: "other",
    cursor: first.nextCursor}), RangeError);
  for (const limit of [0, 31, 1.5, NaN]) {
    await assert.rejects(read({...h.params, db, limit}), RangeError);
  }
  await assert.rejects(read({...h.params, db, uid: "../other"}), RangeError);
});

test("backend errors propagate instead of empty history", async () => {
  const h = await fixture(["a"]);
  const db = {runTransaction: async () => {
    throw new Error("History unavailable");
  }} as unknown as FirebaseFirestore.Firestore;
  await assert.rejects(read({...h.params, db}), /History unavailable/);
});
