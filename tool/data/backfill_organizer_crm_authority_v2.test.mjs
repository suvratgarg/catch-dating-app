import assert from "node:assert/strict";
import test from "node:test";
import {
  applyOrganizerCrmAuthorityV2Plan,
  buildOrganizerCrmAuthorityV2Plan,
} from "./backfill_organizer_crm_authority_v2.mjs";

const timestamp = (millis) => ({_seconds: millis / 1000});

test("backfills only source-backed origins and never upgrades legacy grants",
  async () => {
    const firestore = fakeFirestore({
      "eventAttendees/attendee-1": {
        organizerId: "organizer-1",
        eventId: "event-1",
        source: "webOtp",
        linkedUid: "user-1",
        createdAt: timestamp(1000),
      },
      "eventAttendees/attendee-without-edge": {
        organizerId: "organizer-1",
        eventId: "event-2",
        source: "hostImport",
        linkedUid: null,
        createdAt: timestamp(1000),
      },
      "organizerContactEventEdges/attendee-1": {
        contactId: "contact-current",
        originContactId: "contact-origin",
      },
      "organizerContacts/contact-current": {
        organizerId: "organizer-1",
        mergedIntoContactId: null,
      },
      "organizerContacts/contact-origin": {
        organizerId: "organizer-1",
        mergedIntoContactId: "contact-current",
      },
      "organizerContacts/contact-form": {
        organizerId: "organizer-1",
        mergedIntoContactId: "contact-form-current",
      },
      "organizerContacts/contact-form-current": {
        organizerId: "organizer-1",
        mergedIntoContactId: null,
      },
      "organizerFormResponses/response-1": {
        organizerId: "organizer-1",
        formId: "form-1",
        submittedAt: timestamp(1500),
      },
      "organizerFormConversionReceipts/conversion-1": {
        organizerId: "organizer-1",
        formId: "form-1",
        responseId: "response-1",
        kind: "crmContact",
        status: "completed",
        resultId: "contact-form",
        actorUid: "manager-1",
        createdAt: timestamp(1600),
        completedAt: timestamp(1700),
      },
      "organizerCommunicationPreferences/preference-1": {
        organizerId: "organizer-1",
        uid: "user-1",
        whatsapp: {
          status: "optedIn",
          termsVersion: "organizer-updates-v1",
          source: "publicEventRegistration",
          sourceEventId: "event-1",
          updatedAt: timestamp(2000),
        },
        sms: {
          status: "unknown",
          termsVersion: null,
          source: null,
          sourceEventId: null,
          updatedAt: null,
        },
        createdAt: timestamp(1000),
        updatedAt: timestamp(2000),
      },
    });
    const plan = await buildOrganizerCrmAuthorityV2Plan(firestore);
    assert.equal(plan.summary.contactOriginsToCreate, 2);
    assert.equal(plan.summary.attendeeOriginGaps, 1);
    assert.equal(plan.summary.formConversionOriginGaps, 0);
    assert.equal(plan.summary.contactsWithoutAnyOrigin, 0);
    assert.equal(plan.summary.permissionReceiptsToCreate, 1);
    assert.equal(plan.summary.preferencesToUpdate, 1);
    assert.equal(plan.summary.inferredGrants, 0);
    assert.equal(
      plan.receiptCreates[0].document.evidenceStatus,
      "incomplete"
    );
    assert.equal(
      plan.preferenceUpdates[0].patch.whatsapp.evidenceStatus,
      "incomplete"
    );
    assert.equal(
      plan.preferenceUpdates[0].patch.sms.evidenceStatus,
      "notApplicable"
    );
    await applyOrganizerCrmAuthorityV2Plan(firestore, plan);
    assert.equal(
      firestore.data[plan.originCreates[0].path].originContactId,
      "contact-origin"
    );
    const formOrigin = plan.originCreates.find((item) =>
      item.document.sourceKind === "hostForm"
    );
    assert.equal(formOrigin.document.currentContactId, "contact-form-current");
    assert.equal(formOrigin.document.originContactId, "contact-form");
    assert.equal(formOrigin.document.responseId, "response-1");
    assert.equal(formOrigin.document.actorUid, "manager-1");
    assert.equal(
      firestore.data[plan.receiptCreates[0].path].consentCopyHash,
      null
    );
    assert.equal(
      firestore.data[
        "organizerCommunicationPreferences/preference-1"
      ].whatsapp.evidenceStatus,
      "incomplete"
    );
  });

test("leaves already classified preference channels unchanged", async () => {
  const firestore = fakeFirestore({
    "organizerCommunicationPreferences/preference-1": {
      organizerId: "organizer-1",
      uid: "user-1",
      whatsapp: {
        status: "optedIn",
        evidenceStatus: "complete",
        currentReceiptId: "receipt-1",
      },
      sms: {
        status: "unknown",
        evidenceStatus: "notApplicable",
        currentReceiptId: null,
      },
    },
  });
  const plan = await buildOrganizerCrmAuthorityV2Plan(firestore);
  assert.equal(plan.preferenceUpdates.length, 0);
  assert.equal(plan.receiptCreates.length, 0);
});

test("reports unresolved contact and form provenance without inventing it",
  async () => {
    const firestore = fakeFirestore({
      "organizerContacts/contact-without-origin": {
        organizerId: "organizer-1",
        mergedIntoContactId: null,
      },
      "organizerFormConversionReceipts/conversion-without-response": {
        organizerId: "organizer-1",
        formId: "form-1",
        responseId: "response-missing",
        kind: "crmContact",
        status: "completed",
        resultId: "contact-without-origin",
        actorUid: "manager-1",
        completedAt: timestamp(2000),
      },
    });

    const plan = await buildOrganizerCrmAuthorityV2Plan(firestore);

    assert.equal(plan.originCreates.length, 0);
    assert.equal(plan.summary.formConversionOriginGaps, 1);
    assert.deepEqual(plan.summary.formConversionGapPaths, [
      "organizerFormConversionReceipts/conversion-without-response",
    ]);
    assert.equal(plan.summary.contactsWithoutAnyOrigin, 1);
    assert.deepEqual(plan.summary.contactOriginGapPaths, [
      "organizerContacts/contact-without-origin",
    ]);
    assert.equal(plan.summary.inferredGrants, 0);
  });

function fakeFirestore(initial) {
  const data = structuredClone(initial);
  const documentsIn = (collectionName) => Object.entries(data)
    .filter(([documentPath]) =>
      documentPath.startsWith(`${collectionName}/`) &&
      documentPath.split("/").length === 2
    )
    .map(([documentPath, value]) => ({
      id: documentPath.split("/")[1],
      ref: {path: documentPath},
      data: () => structuredClone(value),
    }));
  return {
    data,
    collection: (collectionName) => ({
      get: async () => {
        const docs = documentsIn(collectionName);
        return {docs, size: docs.length};
      },
    }),
    doc: (documentPath) => ({path: documentPath}),
    batch: () => {
      const writes = [];
      return {
        set: (ref, document) => writes.push(() => {
          data[ref.path] = structuredClone(document);
        }),
        update: (ref, patch) => writes.push(() => {
          data[ref.path] = {
            ...data[ref.path],
            ...structuredClone(patch),
          };
        }),
        commit: async () => writes.forEach((write) => write()),
      };
    },
  };
}
