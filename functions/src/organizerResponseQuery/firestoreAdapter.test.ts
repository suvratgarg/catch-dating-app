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
    {value: "Delhi", label: "Delhi"},
    {value: "Mumbai", label: "Mumbai"}], label: "City"},
  {questionId: "secret", kind: "shortText", options: [],
    privacyClass: "sensitive", label: "Secret"},
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
    "organizerForms/form-1": {organizerId: "org-1", title: "Event signup"},
    "organizerFormVersions/version-1": {organizerId: "org-1",
      formId: "form-1", version: 1, definition},
    "organizerFormResponses/one": {organizerId: "org-1", formId: "form-1",
      versionId: "version-1", status: "submitted", submittedAt: timestamp,
      withdrawnAt: null, identityKind: "phoneVerified",
      identity: {displayName: "Asha", email: "asha@example.test",
        phoneE164: "+919999999999", searchName: "asha",
        origin: "respondentGranted"}, sourceLinkId: null,
      answers: {city: "Delhi", secret: "private one"}},
    "organizerFormResponses/two": {organizerId: "org-1", formId: "form-1",
      versionId: "version-1", status: "submitted",
      submittedAt: admin.firestore.Timestamp.fromMillis(1001),
      withdrawnAt: null, identityKind: "anonymous",
      identity: {displayName: "Guest", email: null, phoneE164: null,
        searchName: "guest", origin: "organizerAcquired"},
      sourceLinkId: null, answers: {city: "Delhi"}},
    "organizerFormResponses/other-version": {organizerId: "org-1",
      formId: "form-1", versionId: "version-2", status: "submitted",
      submittedAt: admin.firestore.Timestamp.fromMillis(1002),
      withdrawnAt: null, identityKind: "anonymous",
      identity: {displayName: null, email: null, phoneE164: null,
        searchName: null, origin: "anonymous"}, sourceLinkId: null,
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
    assert.deepEqual(first.items.map((row) => row.responseId), ["one"]);
    assert.equal(first.items[0].formTitle, "Event signup");
    assert.equal(first.form.version, 1);
    assert.deepEqual(first.items[0].identity,
      {displayName: "Asha", email: "asha@example.test",
        phoneE164: "+919999999999", origin: "respondentGranted"});
    assert.ok(!JSON.stringify(first).includes("private one"));
    assert.ok(!JSON.stringify(first).includes("searchName"));
    assert.deepEqual(first.fieldCatalog.map((field) => field.questionId),
      ["city"]);
    assert.equal(first.total, 2);
    assert.ok(first.nextCursor);
    const second = await runFirestoreResponseQuery(scope,
      {...input, cursor: first.nextCursor});
    assert.deepEqual(second.items.map((row) => row.responseId), ["two"]);
    assert.equal(second.items[0].identityKind, "anonymous");
    assert.equal(second.items[0].identity.origin, "organizerAcquired");
    assert.equal(second.nextCursor, null);
    assert.deepEqual(await resolveFirestoreResponseIds(scope, input,
      ["two"], first.resultHash), ["two"]);
    await assert.rejects(resolveFirestoreResponseIds(scope, input,
      ["other-version"], first.resultHash), {code: "invalid-argument"});
    await assert.rejects(resolveFirestoreResponseIds(scope, input,
      ["one"], "stale"), {code: "aborted", details: {
      reason: "response-query-stale", action: "refresh"}});
    await assert.rejects(runFirestoreResponseQuery({...scope,
      actorUid: "outsider"}, input), {code: "permission-denied"});
    await assert.rejects(runFirestoreResponseQuery(scope,
      {...input, versionId: "version-2"}), {code: "permission-denied"});
  });

test("withdrawn page keeps audit identity but redacts answer content",
  async () => {
    const {store, scope} = fixture();
    store.docs["organizerFormResponses/one"] = {
      ...store.docs["organizerFormResponses/one"], status: "withdrawn",
      withdrawnAt: admin.firestore.Timestamp.fromMillis(2000)};
    const history = await runFirestoreResponseQuery(scope,
      {...input, statuses: ["withdrawn"], predicate: null});
    assert.deepEqual(history.items.map((item) => item.responseId), ["one"]);
    assert.equal(history.items[0].identity.displayName, "Asha");
    assert.equal(history.items[0].status, "withdrawn");
    assert.equal(history.items[0].withdrawnAtMillis, 2000);
    assert.ok(!JSON.stringify(history).includes("private one"));
    assert.ok(!JSON.stringify(history.items).includes("Delhi"));
    const filtered = await runFirestoreResponseQuery(scope,
      {...input, statuses: ["withdrawn"]});
    assert.deepEqual(filtered.items, []);
  });

test("display identity and form title changes invalidate continuation",
  async () => {
    const {store, scope} = fixture();
    const first = await runFirestoreResponseQuery(scope, input);
    assert.ok(first.nextCursor);
    store.docs["organizerForms/form-1"] = {
      ...store.docs["organizerForms/form-1"], title: "Renamed signup"};
    await assert.rejects(runFirestoreResponseQuery(scope,
      {...input, cursor: first.nextCursor}),
    {code: "aborted", details: {reason: "response-query-stale",
      action: "refresh"}});
    store.docs["organizerForms/form-1"] = {
      ...store.docs["organizerForms/form-1"], title: "Event signup"};
    const response = store.docs["organizerFormResponses/one"];
    store.docs["organizerFormResponses/one"] = {...response,
      identity: {...response.identity as object, displayName: "Renamed Asha"}};
    await assert.rejects(runFirestoreResponseQuery(scope,
      {...input, cursor: first.nextCursor}),
    {code: "aborted", details: {reason: "response-query-stale",
      action: "refresh"}});
  });

test("field catalog follows only the authorized published version",
  async () => {
    const {store, scope} = fixture();
    store.docs["organizerFormVersions/version-2"] = {
      organizerId: "org-1", formId: "form-1", version: 2,
      definition: {sections: [{questions: [{questionId: "campus",
        label: "Campus", kind: "shortText", options: [],
        privacyClass: "organizerCustom"}]}]},
    };
    const result = await runFirestoreResponseQuery(
      {...scope, versionId: "version-2"}, {...input,
        versionId: "version-2", predicate: null});
    assert.equal(result.form.version, 2);
    assert.deepEqual(result.fieldCatalog.map((field) => field.questionId),
      ["campus"]);
    await assert.rejects(runFirestoreResponseQuery({...scope,
      actorUid: "outsider", versionId: "version-2"}, {...input,
      versionId: "version-2", predicate: null}),
    {code: "permission-denied"});
  });

test("Firestore adapter spends scan budget on all form versions", async () => {
  const {scope} = fixture();
  const snapshot = await firestoreResponseQuerySource(scope).readAll(2);
  assert.equal(snapshot.rows.length, 3,
    "third form row is the budget lookahead");
  const complete = await firestoreResponseQuerySource(scope).readAll(3);
  assert.deepEqual(complete.rows.map((row) => row.id), ["one", "two"]);
});

test("form title and response share a scan snapshot", async () => {
  const {store, scope} = fixture();
  const original = store.runTransaction.bind(store);
  store.runTransaction = async (body) => {
    store.docs["organizerForms/form-1"] = {
      ...store.docs["organizerForms/form-1"], title: "New signup"};
    store.docs["organizerFormResponses/one"] = {
      ...store.docs["organizerFormResponses/one"],
      identity: {displayName: "New Asha", email: "asha@example.test",
        phoneE164: "+919999999999", searchName: "new asha",
        origin: "respondentGranted"}};
    return original(body);
  };
  const result = await runFirestoreResponseQuery(scope, input);
  assert.equal(result.form.title, "New signup");
  assert.equal(result.items[0].formTitle, "New signup");
  assert.equal(result.items[0].identity.displayName, "New Asha");
});

test("changed published definition fails closed", async () => {
  const {store, scope} = fixture();
  const original = store.runTransaction.bind(store);
  store.runTransaction = async (body) => {
    store.docs["organizerFormVersions/version-1"] = {
      ...store.docs["organizerFormVersions/version-1"],
      definition: {sections: [{questions: [{questionId: "other",
        kind: "shortText", label: "Other", options: []}]}]}};
    return original(body);
  };
  await assert.rejects(runFirestoreResponseQuery(scope, input),
    {code: "aborted", details: {reason: "response-query-stale",
      action: "refresh"}});
});

test("other-version rows cannot hide an oversized form scan", async () => {
  const {store, scope} = fixture();
  const other = store.docs["organizerFormResponses/other-version"];
  for (let index = 0; index < 5_000; index++) {
    store.docs[`organizerFormResponses/older-${index}`] = {...other,
      submittedAt: admin.firestore.Timestamp.fromMillis(index + 2000)};
  }
  let fetchedRows = 0;
  const original = store.runTransaction.bind(store);
  store.runTransaction = async (body) => original(async (tx) => body({
    ...tx,
    get: async (ref) => {
      const result = await tx.get(ref);
      if (ref.path === "organizerFormResponses") {
        fetchedRows += (result as {size: number}).size;
      }
      return result;
    },
  }));
  await assert.rejects(runFirestoreResponseQuery(scope, input),
    {code: "resource-exhausted", message: /5,000-response/u});
  assert.equal(fetchedRows, 5_001,
    "only the exact cap plus one lookahead may be fetched");
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

test("account deletion between preparation and scan denies rows", async () => {
  const {store, scope} = fixture();
  const original = store.runTransaction.bind(store);
  store.runTransaction = async (body) => {
    store.docs["deletedUsers/host-1"] = {status: "processing"};
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
