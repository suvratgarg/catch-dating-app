import assert from "node:assert/strict";
import test from "node:test";
import {AudienceTestStore} from "../organizers/organizerAudienceTestStore";
import {formConversionReceiptId} from
  "../organizers/organizerFormAdmissionIdentity";
import {organizerContactOriginId} from
  "../shared/organizerContactOrigins";
import {FirestoreEventOfferRepository} from
  "./eventOfferFirestoreRepository";
import {commitEventOffers, previewEventOffers} from "./eventOfferService";

const now = 1_800_000_000_000;
const organizerId = "organizer-one";
const eventId = "saturday";
const responseId = "registration-response";
const contactId = "crm-contact";
const actor = {uid: "manager-one"};
const row = {organizerId, eventId, contactId,
  applicationId: responseId, sourceKind: "formResponse" as const,
  expiresAtMillis: now + 600_000, organizerPaymentLink: null};
const input = {organizerId, eventId, mode: "offer" as const, rows: [row]};
const time = (millis: number) => ({toMillis: () => millis});

function fixture(conversionStatus: "completed" | "pending" = "completed",
  resultId = contactId): AudienceTestStore {
  const originId = organizerContactOriginId({organizerId,
    sourceKind: "hostForm", sourceEntityKind: "hostFormResponse",
    sourceEntityId: responseId});
  const receiptId = formConversionReceiptId(responseId, "crmContact");
  return new AudienceTestStore({
    [`organizers/${organizerId}`]: {ownerUserId: actor.uid,
      hostUserId: null, hostUserIds: [], hostProfiles: []},
    [`organizerFormResponses/${responseId}`]: {organizerId,
      formId: "registration-form", versionId: "version-one",
      status: "submitted"},
    "organizerFormVersions/version-one": {organizerId,
      formId: "registration-form", version: 1,
      definition: {purpose: "registration", defaultTargetKind: "event",
        defaultTargetId: eventId}},
    [`organizerFormConversionReceipts/${receiptId}`]: {
      organizerId, formId: "registration-form", responseId,
      kind: "crmContact", status: conversionStatus, resultId},
    [`organizerContactOrigins/${originId}`]: {organizerId,
      sourceEntityId: responseId, sourceEntityKind: "hostFormResponse",
      currentContactId: contactId, originContactId: contactId},
    [`organizerContacts/${contactId}`]: {organizerId, revision: 1,
      deletedAt: null, hiddenAt: null, mergedIntoContactId: null},
    [`eventSetupPreferences/${eventId}`]: {organizerId, eventId,
      revision: 1, paymentTerms: {revision: 1,
        preferredCollection: null, reusablePaymentPage: null,
        paymentInstructions: null, expectedAmountMinor: 0,
        currency: "INR", offerValidityMinutes: 30,
        offerMessageTemplate: null, sourceDefaultsRevision: 1,
        sourceDefaultsHash: "a".repeat(64), fieldSources: {}},
      preferences: {}},
    [`events/${eventId}`]: {organizerId, clubId: organizerId,
      status: "active", startTime: time(now + 3_600_000),
      updatedAt: time(now)},
  });
}

test("actual adapter maps reviewed registration and buffers all writes",
  async () => {
    const store = fixture();
    const repository = new FirestoreEventOfferRepository(
      store.asFirestore(), () => now);
    const preview = await previewEventOffers({repository, actor, input});
    assert.equal(preview.rows.length, 1);
    const receipt = await commitEventOffers({repository, actor,
      input: {...input, requestId: "registration-batch-one",
        planDigest: preview.planDigest}});
    assert.equal(receipt.results.length, 1);
    const stored = store.docs[
      `organizerEventOffers/${receipt.results[0].offerId}`];
    assert.equal(stored.status, "offered");
    assert.equal(Object.keys(store.docs).filter((path) =>
      path.startsWith("organizerEventOfferActionReceipts/")).length, 2);
    assert.equal(Object.keys(store.docs).filter((path) =>
      path.startsWith("organizerEventOfferAudits/")).length, 2);
    const replay = await commitEventOffers({repository, actor,
      input: {...input, requestId: "registration-batch-one",
        planDigest: preview.planDigest}});
    assert.deepEqual(replay, receipt);
  });

test("actual adapter requires completed matching CRM conversion receipt",
  async () => {
    for (const store of [fixture("pending"),
      fixture("completed", "another-contact")]) {
      const repository = new FirestoreEventOfferRepository(
        store.asFirestore(), () => now);
      await assert.rejects(() => previewEventOffers({repository,
        actor, input}));
      assert.equal(Object.keys(store.docs).filter((path) =>
        path.startsWith("organizerEventOffers/")).length, 0);
    }
    const missing = fixture();
    delete missing.docs[`organizerFormConversionReceipts/${
      formConversionReceiptId(responseId, "crmContact")}`];
    await assert.rejects(() => previewEventOffers({repository:
      new FirestoreEventOfferRepository(missing.asFirestore(), () => now),
    actor, input}));
  });
