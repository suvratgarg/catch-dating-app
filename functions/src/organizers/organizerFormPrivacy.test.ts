import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import type {CallableRequest} from "firebase-functions/v2/https";
import {createFormPaymentFixture} from
  "../payments/formPayments/formPaymentTestStore";
import {AudienceTestStore} from "./organizerAudienceTestStore";
import {beginOrganizerFormResponseHandler as begin,
  submitOrganizerFormResponseHandler as submit,
  responseIdentitySnapshot} from "./organizerFormResponses";
import {getOrganizerFormResponseDetailHandler as detail,
  listOrganizerFormResponsesHandler as list} from "./organizerFormOperations";
import {runFirestoreResponseQuery} from
  "../organizerResponseQuery/firestoreAdapter";
import {processOrganizerFormExport} from "./organizerFormExports";

const ambient = {uid: "ambient-person", token: {name: "Ambient Account",
  email: "ambient@example.com", phone_number: "+919876543210",
  email_verified: true}};
const request = (data: unknown, auth: typeof ambient | null = ambient) =>
  ({data, auth}) as unknown as CallableRequest<unknown>;
const emptyIdentity = {displayName: null, email: null, phoneE164: null,
  searchName: null, origin: "anonymous"};

function fixture() {
  const h = createFormPaymentFixture();
  h.version.definition.identityPolicy = "anonymous";
  h.version.definition.payment = null;
  h.version.definition.purpose = "survey";
  h.version.definition.availability.responseLimit = null;
  h.version.definition.sections[0].questions[0].required = false;
  const name = h.version.definition.sections[0].questions[0];
  h.version.definition.sections[0].questions.push(
    {...name, questionId: "email", key: "email",
      canonicalFieldId: "email", kind: "email"},
    {...name, questionId: "phone", key: "phone",
      canonicalFieldId: "phoneNumber", kind: "phone"});
  const db = {collection: (name: string) => {
    const collection = h.store.collection(name);
    return {...collection, where: (field: string, op: string,
      value: unknown) => {
      const query = collection.where(field, op, value);
      return {...query, limit: (limit: number) => ({get: async () => {
        const result = await query.limit(limit).get();
        return {...result, size: result.docs.length};
      }})};
    }};
  }, runTransaction: h.store.runTransaction.bind(h.store),
  } as unknown as FirebaseFirestore.Firestore;
  const deps = {firestore: () => db,
    timestamp: () => Timestamp.fromMillis(2000),
    checkRateLimit: async () => undefined, storageBucket: () => {
      throw new Error("No uploads");
    }};
  return {...h, db, deps};
}

for (const signedIn of [false, true]) {
  for (const volunteered of [false, true]) {
    test(`anonymous signed-in=${signedIn}, contact=${volunteered}`,
      async () => {
        const h = fixture();
        const auth = signedIn ? ambient : null;
        const begun = await begin(request({publicFormId: h.form.publicFormId,
          sourceToken: null, requestId: "anonymous-start-request"}, auth),
        h.deps);
        assert.equal(begun.identityKind, "anonymous");
        assert.deepEqual(begun.prefillSuggestions, {});
        assert.deepEqual(await begin(request({publicFormId: h.form.publicFormId,
          sourceToken: null, requestId: "anonymous-start-request"},
        {...ambient, uid: "changed-account"}), h.deps), begun);
        const answers = volunteered ? {name: "Volunteered Name",
          email: "volunteered@example.com", phone: "+919000000002"} : {};
        const identity = volunteered ? {displayName: "Volunteered Name",
          email: "volunteered@example.com", phoneE164: "+919000000002",
          searchName: "volunteered name", origin: "organizerAcquired"} :
          emptyIdentity;
        const draftPath = `organizerFormResponseDrafts/${begun.draftId}`;
        h.store.records.set(draftPath, {...h.store.records.get(draftPath),
          consentAccepted: true, answers});
        const payload = {draftId: begun.draftId, draftToken: begun.draftToken,
          expectedRevision: begun.revision,
          requestId: "anonymous-submit-request"};
        const receipt = await submit(request(payload, auth), h.deps);
        const persisted = h.store.records.get(
          `organizerFormResponses/${receipt.responseId}`)!;
        assert.deepEqual(persisted.identity, identity);
        assert.equal(persisted.respondentUid, null);
        assert.ok(receipt.withdrawalToken);
        assert.equal(receipt.profileReviewAvailable, false);
        assert.deepEqual(await submit(request(payload,
          {...ambient, uid: "changed-account"}), h.deps), receipt);
        assert.deepEqual(h.store.records.get(
          `organizerFormResponses/${receipt.responseId}`), persisted);
        assert.equal(h.store.records.has(
          "participantIntakeProfiles/ambient-person"), false);

        const store = new AudienceTestStore(
          Object.fromEntries(h.store.records));
        store.docs["organizers/org"] = {ownerUserId: "host", hostUserIds: [],
          hostProfiles: []};
        const views = {firestore: () => store.asFirestore(),
          timestamp: h.deps.timestamp, checkRateLimit: async () => undefined,
          storageBucket: h.deps.storageBucket};
        const host = (data: unknown) => request(data,
          {...ambient, uid: "host"});
        const listed = await list(host({organizerId: "org", formId: "form",
          versionId: "version", statuses: [], identityKinds: [],
          sourceLinkId: null, query: null, fromMillis: null, toMillis: null,
          cursor: null, limit: 10}), views);
        assert.deepEqual(listed.items[0].identity, identity);
        const full = await detail(host({organizerId: "org",
          responseId: receipt.responseId}), views);
        assert.deepEqual(full.response.identity, identity);
        assert.equal(full.applicationId, null);
        assert.equal(full.contactId, null);
        const typed = await runFirestoreResponseQuery({db: store.asFirestore(),
          actorUid: "host", organizerId: "org", formId: "form",
          versionId: "version"},
        {organizerId: "org", formId: "form", versionId: "version",
          statuses: ["submitted"], predicate: null, sort: null,
          limit: 10, cursor: null});
        assert.deepEqual(typed.items[0].identity,
          {displayName: identity.displayName, email: identity.email,
            phoneE164: identity.phoneE164, origin: identity.origin});
        const now = h.deps.timestamp();
        store.docs["organizerFormExports/privacy-export"] = {
          organizerId: "org", formId: "form", status: "pending", format: "csv",
          statuses: ["submitted"], versionId: "version", fromMillis: null,
          toMillis: null, rowCount: 0, storagePath: null, createdAt: now,
          updatedAt: now, expiresAt: Timestamp.fromMillis(86402000)};
        let csv = "";
        await processOrganizerFormExport("privacy-export", {...views,
          storageBucket: () => ({file: () => ({save: async (buffer: Buffer) => {
            csv = buffer.toString("utf8");
          }})}) as never});
        assert.equal(
          store.docs["organizerFormExports/privacy-export"].rowCount, 1);
        assert.ok(csv.includes('"anonymous"'));
        if (volunteered) {
          for (const value of Object.values(answers)) {
            assert.ok(csv.includes(value));
          }
        }
        for (const secret of [ambient.uid, ambient.token.name,
          ambient.token.email, ambient.token.phone_number]) {
          assert.ok(!csv.includes(secret), secret);
        }
      });
  }
}

test("anonymous canonical contact survives conflicting auth", () => {
  const h = fixture();
  const answers = {name: "Volunteered Name", email: "volunteered@example.com",
    phone: "+919000000002"};
  const expected = {displayName: answers.name, email: answers.email,
    phoneE164: answers.phone, searchName: "volunteered name",
    origin: "organizerAcquired"};
  assert.deepEqual(responseIdentitySnapshot(h.version.definition, answers,
    request({})), expected);
  assert.deepEqual(responseIdentitySnapshot(h.version.definition, answers,
    request({}, null)), expected);
});

test("identified policy retains permitted account snapshot", () => {
  const h = fixture();
  for (const policy of ["catchAccount", "phoneVerified", "emailVerified",
    "emailOrPhoneVerified"] as const) {
    h.version.definition.identityPolicy = policy;
    assert.deepEqual(responseIdentitySnapshot(h.version.definition,
      {name: "Volunteered Name"}, request({})), {
      displayName: ambient.token.name, email: ambient.token.email,
      phoneE164: ambient.token.phone_number, searchName: "ambient account",
      origin: "respondentGranted"});
  }
});

test("anonymous policy denies private response reuse", async () => {
  const h = fixture();
  const before = [...h.store.records.keys()];
  await assert.rejects(begin(request({publicFormId: h.form.publicFormId,
    sourceToken: null, requestId: "anonymous-reuse-request",
    reuseResponseId: "identified-source"}), h.deps), {code: "not-found"});
  assert.deepEqual([...h.store.records.keys()], before);
});


test("anonymous retry discards unreachable contact", async () => {
  const h = fixture();
  h.version.definition.logicRules = [{ruleId: "hide-contact",
    conditionMode: "all",
    conditions: [{questionId: "name", operator: "equals",
      expectedValues: ["Skip"]}],
    action: "hideQuestion", targetQuestionId: "email", targetSectionId: null}];
  const begun = await begin(request({publicFormId: h.form.publicFormId,
    sourceToken: null, requestId: "hidden-contact-start"}), h.deps);
  const path = `organizerFormResponseDrafts/${begun.draftId}`;
  h.store.records.set(path, {...h.store.records.get(path),
    consentAccepted: true,
    answers: {name: "Skip", email: "stale@example.com"}});
  const payload = {draftId: begun.draftId, draftToken: begun.draftToken,
    expectedRevision: begun.revision, requestId: "hidden-contact-submit"};
  h.store.failNextCommit = true;
  await assert.rejects(submit(request(payload), h.deps), /Interrupted commit/u);
  assert.equal([...h.store.records.keys()].some((key) =>
    key.startsWith("organizerFormResponses/")), false);
  const receipt = await submit(request(payload, {...ambient,
    uid: "changed-account"}), h.deps);
  const response = h.store.records.get(
    `organizerFormResponses/${receipt.responseId}`)!;
  assert.deepEqual(response.answers, {name: "Skip"});
  assert.deepEqual(response.identity, {displayName: "Skip", email: null,
    phoneE164: null, searchName: "skip", origin: "organizerAcquired"});
  assert.equal(response.respondentUid, null);
});
