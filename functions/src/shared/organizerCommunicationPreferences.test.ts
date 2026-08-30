import assert from "node:assert/strict";
import test from "node:test";
import * as admin from "firebase-admin";
import {
  effectiveOrganizerCommunicationStatus,
  hasCompleteOrganizerCommunicationGrant,
  inboundStopPermissionReceipt,
  organizerUpdatesConsentCopyHash,
  publicRegistrationPermissionReceipt,
  unknownOrganizerCommunicationChannel,
} from "./organizerCommunicationPreferences";
import {OrganizerCommunicationPreferenceDocument} from
  "./generated/firestoreAdminTypes";

const now = admin.firestore.Timestamp.fromMillis(1_000);

test("managed grants require complete referenced evidence", () => {
  const complete = preference({
    status: "optedIn",
    evidenceStatus: "complete",
    currentReceiptId: "receipt-1",
  });
  assert.equal(
    hasCompleteOrganizerCommunicationGrant(complete, "whatsapp"),
    true
  );
  assert.equal(
    effectiveOrganizerCommunicationStatus(complete, "whatsapp"),
    "optedIn"
  );
  const incomplete = preference({
    status: "optedIn",
    evidenceStatus: "incomplete",
    currentReceiptId: "receipt-legacy",
  });
  assert.equal(
    hasCompleteOrganizerCommunicationGrant(incomplete, "whatsapp"),
    false
  );
  assert.equal(
    effectiveOrganizerCommunicationStatus(incomplete, "whatsapp"),
    "unknown"
  );
});

test("withdrawal remains effective independently of grant completeness", () => {
  const withdrawn = preference({
    status: "optedOut",
    evidenceStatus: "incomplete",
    currentReceiptId: "legacy-stop",
  });
  assert.equal(
    effectiveOrganizerCommunicationStatus(withdrawn, "whatsapp"),
    "optedOut"
  );
});

test("registration receipt binds reviewed copy and participant identity",
  () => {
    const receipt = publicRegistrationPermissionReceipt({
      organizerId: "organizer-1",
      uid: "user-1",
      channel: "whatsapp",
      eventId: "event-1",
      termsVersion: "organizer-updates-v1",
      supersedesReceiptId: null,
      now,
    });
    assert.ok(receipt);
    assert.equal(receipt.document.evidenceStatus, "complete");
    assert.equal(receipt.document.identityStrength, "phoneVerified");
    assert.equal(receipt.document.actorUid, "user-1");
    assert.equal(
      receipt.document.consentCopyHash,
      organizerUpdatesConsentCopyHash("organizer-updates-v1", "whatsapp")
    );
    assert.equal(
      publicRegistrationPermissionReceipt({
        organizerId: "organizer-1",
        uid: "user-1",
        channel: "whatsapp",
        eventId: "event-1",
        termsVersion: "unreviewed-v2",
        supersedesReceiptId: null,
        now,
      }),
      null
    );
  });

test("STOP appends a withdrawal that supersedes but does not erase a grant",
  () => {
    const receipt = inboundStopPermissionReceipt({
      organizerId: "organizer-1",
      uid: "user-1",
      providerEventId: "inbound:wamid-1",
      supersedesReceiptId: "grant-1",
      now,
    });
    assert.equal(receipt.document.decision, "optedOut");
    assert.equal(receipt.document.source, "inboundStop");
    assert.equal(receipt.document.supersedesReceiptId, "grant-1");
    assert.equal(receipt.document.revokedAt?.toMillis(), 1_000);
  });

function preference(
  whatsapp: Pick<
    OrganizerCommunicationPreferenceDocument["whatsapp"],
    "status" | "evidenceStatus" | "currentReceiptId"
  >
): OrganizerCommunicationPreferenceDocument {
  return {
    organizerId: "organizer-1",
    uid: "user-1",
    whatsapp: {
      ...unknownOrganizerCommunicationChannel(),
      ...whatsapp,
    },
    sms: unknownOrganizerCommunicationChannel(),
    createdAt: now,
    updatedAt: now,
  };
}
