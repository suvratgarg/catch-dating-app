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
    assert.equal(plan.summary.contactOriginsToCreate, 1);
    assert.equal(plan.summary.attendeeOriginGaps, 1);
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
