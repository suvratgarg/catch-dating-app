import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {AudienceTestStore} from
  "../organizers/organizerAudienceTestStore";
import {firestoreResponseQuerySource, resolveFirestoreResponseIds,
  runFirestoreResponseQuery} from
  "./firestoreAdapter";

const timestamp = admin.firestore.Timestamp.fromMillis(1000);
const definition = {sections: [{questions: [
  {questionId: "city", kind: "singleChoice", options: [
    {value: "Delhi"}, {value: "Mumbai"}]},
]}]};
const input = {organizerId: "org-1", formId: "form-1",
  versionId: "version-1", statuses: ["submitted"],
  predicate: {questionId: "city", op: "choiceAny", values: ["Delhi"]},
  sort: {questionId: null, direction: "asc", nulls: "last"},
  limit: 1, cursor: null};

function fixture() {
  const store = new AudienceTestStore({
    "organizers/org-1": {ownerUserId: "host-1", hostUserIds: ["host-1"],
      hostProfiles: []},
    "organizerFormVersions/version-1": {organizerId: "org-1",
      formId: "form-1", definition},
    "organizerFormResponses/one": {organizerId: "org-1", formId: "form-1",
      versionId: "version-1", status: "submitted", submittedAt: timestamp,
      answers: {city: "Delhi"}},
    "organizerFormResponses/two": {organizerId: "org-1", formId: "form-1",
      versionId: "version-1", status: "submitted",
      submittedAt: admin.firestore.Timestamp.fromMillis(1001),
      answers: {city: "Delhi"}},
    "organizerFormResponses/other-version": {organizerId: "org-1",
      formId: "form-1", versionId: "version-2", status: "submitted",
      submittedAt: admin.firestore.Timestamp.fromMillis(1002),
      answers: {city: "Delhi"}},
  });
  const scope = {db: store.asFirestore(), actorUid: "host-1",
    organizerId: "org-1", formId: "form-1", versionId: "version-1"};
  return {store, scope};
}

test("Firestore adapter authorizes and uses one exact query for IDs/pages",
  async () => {
    const {scope} = fixture();
    const first = await runFirestoreResponseQuery(scope, input);
    assert.deepEqual(first.selectedIds, ["one", "two"]);
    assert.deepEqual(first.items.map((row) => row.id), ["one"]);
    assert.equal(first.total, 2);
    assert.ok(first.nextCursor);
    const second = await runFirestoreResponseQuery(scope,
      {...input, cursor: first.nextCursor});
    assert.deepEqual(second.items.map((row) => row.id), ["two"]);
    assert.equal(second.nextCursor, null);
    assert.deepEqual(await resolveFirestoreResponseIds(scope, input,
      ["two"], first.resultHash), ["two"]);
    await assert.rejects(resolveFirestoreResponseIds(scope, input,
      ["other-version"], first.resultHash), {code: "invalid-argument"});
    await assert.rejects(resolveFirestoreResponseIds(scope, input,
      ["one"], "stale"), {code: "invalid-argument"});
    await assert.rejects(runFirestoreResponseQuery({...scope,
      actorUid: "outsider"}, input), {code: "permission-denied"});
    await assert.rejects(runFirestoreResponseQuery(scope,
      {...input, versionId: "version-2"}), {code: "permission-denied"});
  });

test("Firestore adapter spends scan budget on all form versions", async () => {
  const {scope} = fixture();
  const rows = await firestoreResponseQuerySource(scope).readAll(2);
  assert.equal(rows.length, 3, "third form row is the budget lookahead");
  const complete = await firestoreResponseQuerySource(scope).readAll(3);
  assert.deepEqual(complete.map((row) => row.id), ["one", "two"]);
});

test("other-version rows cannot hide an oversized form scan", async () => {
  const {store, scope} = fixture();
  const other = store.docs["organizerFormResponses/other-version"];
  for (let index = 0; index < 5_000; index++) {
    store.docs[`organizerFormResponses/older-${index}`] = {...other,
      submittedAt: admin.firestore.Timestamp.fromMillis(index + 2000)};
  }
  await assert.rejects(runFirestoreResponseQuery(scope, input),
    {code: "resource-exhausted", message: /5,000-response/u});
});

test("manager revocation between preparation and snapshot scan denies rows",
  async () => {
    const {store, scope} = fixture();
    const original = store.runTransaction.bind(store);
    store.runTransaction = async (body) => {
      store.docs["organizers/org-1"] = {ownerUserId: "other",
        hostUserIds: ["other"], hostProfiles: []};
      return original(body);
    };
    await assert.rejects(runFirestoreResponseQuery(scope, input),
      {code: "permission-denied"});
  });

test("byte ceiling stops after first oversized Firestore page", async () => {
  const {store, scope} = fixture();
  const first = store.docs["organizerFormResponses/one"];
  for (let index = 0; index < 25; index++) {
    store.docs[`organizerFormResponses/big-${index}`] = {...first,
      submittedAt: admin.firestore.Timestamp.fromMillis(index + 2000),
      answers: {city: "Delhi", extra: "x".repeat(400_000)}};
  }
  let responseQueries = 0;
  const original = store.runTransaction.bind(store);
  store.runTransaction = async (body) => original(async (tx) => body({
    ...tx,
    get: async (ref) => {
      if (ref.path === "organizerFormResponses") responseQueries += 1;
      return tx.get(ref);
    },
  }));
  await assert.rejects(runFirestoreResponseQuery(scope, input),
    {code: "resource-exhausted", message: /8 MiB/u});
  assert.equal(responseQueries, 1);
});
