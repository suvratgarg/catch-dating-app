import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import type {CallableRequest} from "firebase-functions/v2/https";
import {FormPaymentTestStore, createFormPaymentFixture} from
  "../payments/formPayments/formPaymentTestStore";
import {unknownOrganizerCommunicationChannel,
  organizerCommunicationPreferenceId} from
  "../shared/organizerCommunicationPreferences";
import {normalizeFormMessagingDecision} from
  "../organizers/organizerFormMessagingConsent";
import {listParticipantMessagingPreferencesHandler as list,
  withdrawParticipantMessagingPermissionHandler as withdraw} from
  "./participantMessagingPreferences";
import {validateListParticipantMessagingPreferencesCallableResponse as
validPage} from
  "../shared/generated/validators/listParticipantMessagingPreferencesOutput";
import {validateWithdrawParticipantMessagingPermissionCallableResponse as
validResult} from
  "../shared/generated/validators/withdrawParticipantMessagingPermissionOutput";
import {validateCatchCommunicationPermissionReceiptDocument as
validCatchReceipt} from
  "../shared/generated/validators/catchCommunicationPermissionReceiptDocument";

const now = Timestamp.fromMillis(1000);
const request = (data: unknown, uid = "person") =>
  ({auth: {uid, token: {}}, data}) as unknown as CallableRequest<unknown>;
const input = (scope: "catch" | "organizer", expectedReceiptId: string | null
= null,
requestId = "withdraw-1", organizerId = "org") =>
  ({scope, organizerId: scope === "catch" ? null : organizerId,
    expectedReceiptId, requestId});
function fixture() {
  const store = new FormPaymentTestStore();
  store.records.set("organizers/org", {name: "RSVP Demo"});
  const db = store as unknown as FirebaseFirestore.Firestore;
  const deps = {db: () => db, now: () => now, rateLimit: async () => undefined};
  return {store, db, deps};
}
function grant(h: ReturnType<typeof fixture>, scope: "catch" | "organizer",
  uid = "person", organizerId = "org", receiptId = `${scope}-grant`) {
  const whatsapp = {...unknownOrganizerCommunicationChannel(), status:
    "optedIn",
  evidenceStatus: "complete", currentReceiptId: receiptId, termsVersion:
      "form-whatsapp-v1",
  source: "hostFormResponse", updatedAt: Timestamp.fromMillis(500)};
  const channel = {uid, whatsapp, createdAt: now, updatedAt: now};
  const receipt = {uid, channel: "whatsapp", decision: "optedIn",
    evidenceStatus: "complete",
    termsVersion: "form-whatsapp-v1", consentCopyHash: "a".repeat(64),
    grantedAt: Timestamp.fromMillis(500), revokedAt: null};
  if (scope === "catch") {
    h.store.records.set(`catchCommunicationPreferences/${uid}`, channel);
    h.store.records.set(`catchCommunicationPermissionReceipts/${receiptId}`,
      receipt);
  } else {
    h.store.records.set("organizerCommunicationPreferences/" +
      organizerCommunicationPreferenceId(organizerId, uid), {...channel,
      organizerId,
      sms: unknownOrganizerCommunicationChannel()});
    h.store.records.set(`organizerCommunicationPermissionReceipts/${receiptId}`,
      {...receipt, organizerId});
  }
}

test("directory is bounded, account-scoped, and verifies grant evidence",
  async () => {
    const h = fixture();
    grant(h, "catch"); grant(h, "organizer");
    grant(h, "organizer", "foreign", "other", "foreign-grant");
    grant(h, "organizer", "person", "two", "two-grant");
    h.store.records.delete(
      "organizerCommunicationPermissionReceipts/two-grant");
    const first = await list(request({cursor: null, limit: 1}), h.deps);
    assert.equal(validPage(first), true);
    assert.equal(first.catchPreference.status, "optedIn");
    assert.equal(first.organizers.length, 1);
    assert.ok(first.nextCursor);
    const second = await list(request({cursor: first.nextCursor, limit: 1}),
      h.deps);
    const rows = [...first.organizers, ...second.organizers];
    assert.deepEqual(rows.map((r) => r.organizerId).sort(), ["org", "two"]);
    assert.equal(rows.find((r) => r.organizerId === "two")?.preference.status,
      "unknown");
    assert.equal(second.nextCursor, null);
    assert.equal(JSON.stringify(first).includes("foreign"), false);
  });

test("Catch and each organizer withdraw independently, preserving SMS",
  async () => {
    const h = fixture(); grant(h, "catch"); grant(h, "organizer");
    const orgPath = "organizerCommunicationPreferences/" +
    organizerCommunicationPreferenceId("org", "person");
    const before = h.store.records.get(orgPath);
    const result = await withdraw(
      request(input("catch", "catch-grant")), h.deps);
    assert.equal(validResult(result), true);
    assert.equal(result.preference.status, "optedOut");
    assert.deepEqual(h.store.records.get(orgPath), before);
    const evidence = h.store.records.get(
      "catchCommunicationPermissionReceipts/" +
    result.preference.receiptId)!;
    assert.equal(validCatchReceipt(evidence), true);
    assert.equal(evidence.sourceOrganizerId, null);
    assert.equal(validCatchReceipt({...evidence, source: "hostFormResponse"}),
      false);
    assert.equal(validCatchReceipt({...evidence, source: "hostFormResponse",
      sourceOrganizerId: "org"}), true);
    assert.equal(evidence.actorUid, "person");
    const org = await withdraw(request(input("organizer", "organizer-grant")),
      h.deps);
    assert.equal(org.preference.status, "optedOut");
    assert.deepEqual(h.store.records.get(orgPath)?.sms, before?.sms);
    const saved = h.store.records.get("catchCommunicationPreferences/person")!;
    assert.equal(
      (saved.whatsapp as {currentReceiptId: string}).currentReceiptId,
      result.preference.receiptId);
  });

test("retry is immutable, payload bound, and cannot overwrite a newer grant",
  async () => {
    const h = fixture(); grant(h, "catch");
    const data = input("catch", "catch-grant");
    const first = await withdraw(request(data), h.deps);
    const writes = h.store.records.size;
    assert.equal((await withdraw(request(data), h.deps)).replayed, true);
    assert.equal(h.store.records.size, writes);
    await assert.rejects(withdraw(request({...data, expectedReceiptId: null}),
      h.deps),
    {code: "already-exists"});
    grant(h, "catch", "person", "org", "later-grant");
    const replay = await withdraw(request(data), h.deps);
    assert.equal(replay.replayed, true);
    assert.equal(replay.preference.status, "optedIn");
    assert.equal(replay.preference.receiptId, "later-grant");
    await assert.rejects(withdraw(request({...data, requestId: "new-request"}),
      h.deps),
    {code: "aborted"});
    assert.notEqual(first.preference.receiptId, replay.preference.receiptId);
  });

test("auth, sender scope, deletion and foreign receipts cannot write",
  async () => {
    const h = fixture(); grant(h, "catch");
    const before = h.store.records.size;
    await assert.rejects(withdraw({data: input("catch")} as
    CallableRequest<unknown>, h.deps),
    {code: "unauthenticated"});
    await assert.rejects(withdraw(request({...input("catch"), organizerId:
    "org"}), h.deps),
    {code: "invalid-argument"});
    await assert.rejects(withdraw(request({...input("catch"), uid: "foreign"}),
      h.deps));
    await assert.rejects(withdraw(request(input("catch", "catch-grant"),
      "foreign"), h.deps),
    {code: "aborted"});
    assert.equal(h.store.records.size, before);
    h.store.records.set("deletedUsers/person", {status: "processing"});
    await assert.rejects(withdraw(request(input("catch", "catch-grant")),
      h.deps), {code: "not-found"});
    await assert.rejects(list(request({cursor: null, limit: 10}), h.deps),
      {code: "not-found"});
  });

test("failed commits preserve permission and allow retry", async () => {
  const h = fixture(); grant(h, "catch");
  h.store.failNextCommit = true;
  await assert.rejects(withdraw(request(input("catch", "catch-grant")),
    h.deps));
  assert.equal((await list(request({cursor: null, limit: 10}),
    h.deps)).catchPreference.status, "optedIn");
  assert.equal((await withdraw(request(input("catch", "catch-grant")),
    h.deps)).preference.status, "optedOut");
});

test("actual withdrawals fence both grants from an earlier pending checkout",
  async () => {
    const h = createFormPaymentFixture();
    h.store.records.set("organizers/org", {name: "RSVP Demo"});
    h.version.definition.messagingConsent = {organizerWhatsapp: true,
      catchWhatsapp: true};
    const decision = normalizeFormMessagingDecision({choices: {termsVersion:
    "form-whatsapp-v1",
    organizerWhatsapp: true, catchWhatsapp: true}, previous: undefined,
    definition: h.version.definition, phoneVerified: true, now:
    Timestamp.fromMillis(500)});
    h.store.records.set("organizerFormResponseDrafts/draft", {...h.draft,
      messagingDecision: decision});
    const {paymentId} = await h.reserve();
    const deps = {db: () => h.db, now: () => Timestamp.fromMillis(800),
      rateLimit: async () => undefined};
    const a = await withdraw(request(input("catch")), deps);
    const b = await withdraw(request(input("organizer")), deps);
    h.capture(paymentId);
    assert.equal(await h.finalize(paymentId), "submitted");
    const page = await list(request({cursor: null, limit: 10}), deps);
    assert.deepEqual(page.catchPreference, a.preference);
    assert.deepEqual(page.organizers[0].preference, b.preference);
  });
