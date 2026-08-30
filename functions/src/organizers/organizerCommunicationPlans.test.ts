import assert from "node:assert/strict";
import test from "node:test";
import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {resolveOrganizerCommunicationPlanHandler} from
  "./organizerCommunicationPlans";
import {organizerContactChannelStateId} from "./organizerCampaignModel";

test("callable authorizes and returns server-derived routes", async () => {
  const actions: string[] = [];
  const result = await resolveOrganizerCommunicationPlanHandler(request(), {
    firestore: () => fakeFirestore({
      "organizerContacts/contact-1": activeContact(),
      [`organizerContactChannelStates/${organizerContactChannelStateId(
        "organizer-1", "contact-1"
      )}`]: {
        organizerId: "organizer-1",
        contactId: "contact-1",
        adminSuppressed: false,
      },
    }),
    checkRateLimit: async (_db, _uid, action) => {
      actions.push(action);
    },
    requireManager: async ({organizerId, actorUid}) => {
      assert.equal(organizerId, "organizer-1");
      assert.equal(actorUid, "manager-1");
    },
    nowMillis: () => 1_700_000_000_000,
  });

  assert.deepEqual(actions, ["resolveOrganizerCommunicationPlan"]);
  assert.equal(result.capabilityVersion, 1);
  assert.equal(result.resolvedAtMillis, 1_700_000_000_000);
  assert.equal(result.recipients[0].recommendedRouteId, "catchChat");
});

test("callable reads organizer suppression authority", async () => {
  const result = await resolveOrganizerCommunicationPlanHandler(request(), {
    firestore: () => fakeFirestore({
      "organizerContacts/contact-1": activeContact(),
      [`organizerContactChannelStates/${organizerContactChannelStateId(
        "organizer-1", "contact-1"
      )}`]: {
        organizerId: "organizer-1",
        contactId: "contact-1",
        adminSuppressed: true,
      },
    }),
    checkRateLimit: async () => undefined,
    requireManager: async () => undefined,
    nowMillis: () => 1,
  });

  assert.equal(result.recipients[0].routes[1].availability, "unavailable");
  assert.equal(result.recipients[0].routes[1].blocker, "organizerSuppressed");
});

test("callable fails closed for a cross-organizer contact", async () => {
  await assert.rejects(
    resolveOrganizerCommunicationPlanHandler(request(), {
      firestore: () => fakeFirestore({
        "organizerContacts/contact-1": {
          ...activeContact(),
          organizerId: "organizer-2",
        },
      }),
      checkRateLimit: async () => undefined,
      requireManager: async () => undefined,
      nowMillis: () => 1,
    }),
    (error: unknown) => error instanceof HttpsError &&
      error.code === "not-found"
  );
});

function request(): CallableRequest<unknown> {
  return {
    data: {
      organizerId: " organizer-1 ",
      intent: " individualConversation ",
      target: {kind: " contact ", contactId: " contact-1 "},
    },
    auth: {uid: "manager-1", token: {}},
  } as CallableRequest<unknown>;
}

function activeContact(): Record<string, unknown> {
  return {
    organizerId: "organizer-1",
    displayName: "Asha",
    displayNameOverride: null,
    linkedUid: "user-1",
    phoneE164: "+919876543210",
    identityState: "verified",
    ambiguousCandidateContactIds: [],
    whatsappStatus: "unknown",
    deletedAt: null,
    hiddenAt: null,
  };
}

function fakeFirestore(
  documents: Record<string, Record<string, unknown>>
): FirebaseFirestore.Firestore {
  return {
    collection: (collectionPath: string) => ({
      doc: (documentId: string) => ({
        get: async () => ({
          data: () => documents[`${collectionPath}/${documentId}`],
        }),
      }),
    }),
  } as unknown as FirebaseFirestore.Firestore;
}
