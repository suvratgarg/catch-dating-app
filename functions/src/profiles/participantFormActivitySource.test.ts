import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import type {CallableRequest} from "firebase-functions/v2/https";
import {createFormPaymentFixture} from
  "../payments/formPayments/formPaymentTestStore";
import {requireResponseIdentity, submitOrganizerFormResponseHandler} from
  "../organizers/organizerFormResponses";
import {readParticipantFormActivitySource as read} from
  "./participantFormActivitySource";

async function fixture(policy: "phoneVerified" | "emailVerified" |
  "emailOrPhoneVerified" | "catchAccount" = "phoneVerified",
token: Record<string, unknown> = {phone_number: "+919000000001"}) {
  const h = createFormPaymentFixture();
  const identity = requireResponseIdentity({auth: {uid: "person", token}} as
    unknown as CallableRequest<unknown>, policy);
  h.version.definition.identityPolicy = policy;
  h.draft.respondentUid = identity.uid;
  h.draft.identityKind = identity.kind;
  h.store.records.set("organizerFormResponseDrafts/draft", {...h.draft});
  if (policy === "phoneVerified") {
    const {paymentId} = await h.reserve();
    h.capture(paymentId);
    await h.finalize(paymentId);
  } else {
    // Form payment is phone-only; other account identities use the real free
    // submission writer rather than broadening payment eligibility.
    h.version.definition.payment = null;
    await submitOrganizerFormResponseHandler({...h.request,
      auth: {uid: "person", token}} as unknown as CallableRequest<unknown>, {
      firestore: () => h.db, timestamp: () => Timestamp.fromMillis(1000),
      checkRateLimit: async () => undefined,
      storageBucket: () => {
        throw new Error("No upload");
      },
    });
  }
  const key = [...h.store.records.keys()].find((path) =>
    path.startsWith("organizerFormResponses/"))!;
  const params = {db: h.db, uid: "person", responseId: key.split("/")[1],
    nowMillis: 2000};
  return {...h, key, params};
}

test("own source needs no Consumer profile or profile claim", async () => {
  const h = await fixture();
  const before = JSON.stringify([...h.store.records]);
  assert.equal(h.store.records.has("users/person"), false);
  assert.equal([...h.store.records.keys()].some((key) =>
    key.startsWith("participantFormProfileProposals/")), false);
  assert.deepEqual(await read(h.params), {
    responseId: h.params.responseId, organizerId: "org", formId: "form",
    versionId: "version", formTitle: "Application", purpose: "application",
    eventId: null, submittedAtMillis: 1000,
  });
  assert.equal(JSON.stringify([...h.store.records]), before);
});

for (const [policy, token] of [
  ["emailVerified", {email: "synthetic@example.test", email_verified: true}],
  ["emailVerified", {email: "synthetic@example.test", email_verified: true,
    phone_number: "+919000000001"}],
  ["emailOrPhoneVerified", {phone_number: "+919000000001"}],
  ["emailOrPhoneVerified", {email: "synthetic@example.test",
    email_verified: true}],
  ["catchAccount", {}],
] as const) {
  test(`real ${policy} writer identity permits owned metadata: ${
    Object.keys(token).join(",") || "UID only"}`, async () => {
    const h = await fixture(policy, token);
    assert.equal((await read(h.params))?.responseId, h.params.responseId);
  });
}

test("another UID and a CRM link cannot own the source", async () => {
  const h = await fixture();
  h.store.records.set("organizerContacts/contact", {linkedUid: "other"});
  assert.equal(await read({...h.params, uid: "other"}), null);
  assert.equal(await read({...h.params, responseId: "contact"}), null);
});

test("an anonymous or withdrawn response never becomes account activity",
  async () => {
    const h = await fixture();
    const response = h.store.records.get(h.key)!;
    for (const patch of [{identityKind: "anonymous"}, {status: "withdrawn"},
      {withdrawnAt: Timestamp.fromMillis(1500)}]) {
      h.store.records.set(h.key, {...response, ...patch});
      assert.equal(await read(h.params), null);
    }
  });

test("deleted accounts cannot read owned metadata", async () => {
  const h = await fixture();
  for (const status of ["processing", "deleted"]) {
    h.store.records.set("deletedUsers/person", {status});
    assert.equal(await read(h.params), null);
  }
  h.store.records.delete("deletedUsers/person");
  h.store.records.set("users/person", {deleted: true});
  assert.equal(await read(h.params), null);
});

test("version scope and notice mismatches make the source unavailable",
  async () => {
    const h = await fixture();
    const original = h.store.records.get("organizerFormVersions/version")!;
    for (const patch of [{organizerId: "foreign"}, {formId: "foreign"},
      {publishedAt: Timestamp.fromMillis(1500)},
      {definition: {...h.version.definition, identityPolicy: "anonymous"}},
      {definition: {...h.version.definition, consent: {
        ...h.version.definition.consent, consentVersion: "changed"}}}]) {
      h.store.records.set("organizerFormVersions/version",
        {...original, ...patch});
      assert.equal(await read(h.params), null);
    }
    h.store.records.delete("organizerFormVersions/version");
    assert.equal(await read(h.params), null);
  });

test("corrupt sources and future times are unavailable", async () => {
  const h = await fixture();
  const response = h.store.records.get(h.key)!;
  for (const patch of [{organizerId: "foreign"}, {unknown: true},
    {identityKind: "emailVerified"}, {submittedAt: Timestamp.fromMillis(3000)},
    {submittedAt: Timestamp.fromMillis(-1)},
    {submittedAt: {_seconds: 1, _nanoseconds: 0}}]) {
    h.store.records.set(h.key, {...response, ...patch});
    assert.equal(await read(h.params), null);
  }
});

test("today's archived or deleted form does not rewrite the owned version",
  async () => {
    const h = await fixture();
    h.store.records.delete("organizerForms/form");
    assert.equal((await read(h.params))?.versionId, "version");
  });

test("an existing transaction is reused without a nested transaction or writes",
  async () => {
    const h = await fixture();
    const db = {collection: h.db.collection.bind(h.db),
      runTransaction: () => {
        throw new Error("Nested transaction");
      },
    } as unknown as FirebaseFirestore.Firestore;
    await h.db.runTransaction(async (tx) => {
      const source = await read({...h.params, db, tx});
      assert.equal(source?.responseId, h.params.responseId);
    });
  });

test("invalid ids are rejected before any source lookup; read errors propagate",
  async () => {
    const h = await fixture();
    const db = {collection: () => {
      throw new Error("Unexpected lookup");
    }} as
      unknown as FirebaseFirestore.Firestore;
    for (const responseId of ["", ".", "..", "a/b", "a\n", "a".repeat(181)]) {
      assert.equal(await read({...h.params, db, responseId}), null);
    }
    const failed = {runTransaction: async () => {
      throw new Error("Source unavailable");
    }} as unknown as FirebaseFirestore.Firestore;
    await assert.rejects(read({...h.params, db: failed}), /Source unavailable/);
  });
