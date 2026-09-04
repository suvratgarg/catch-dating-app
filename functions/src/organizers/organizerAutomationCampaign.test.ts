import assert from "node:assert/strict";
import test from "node:test";
import {Timestamp} from "firebase-admin/firestore";
import type {OrganizerCampaignDocument} from
  "../shared/generated/firestoreAdminTypes";
import {organizerContactOriginId} from "../shared/organizerContactOrigins";
import {organizerCommunicationPreferenceId} from
  "../shared/organizerCommunicationPreferences";
import {AudienceTestStore} from "./organizerAudienceTestStore";
import {
  emptyCampaignAudienceCounts,
  emptyCampaignDeliveryCounts,
} from "./organizerCampaignModel";
import {prepareAutomatedOrganizerCampaign} from "./organizerCampaigns";
import {requireAutomationCampaignAuthority} from "./organizerAutomationSource";

const now = Timestamp.fromMillis(1800000000000);
function fixture() {
  const recipe = {
    organizerId: "org",
    createdByUid: "host",
    messageClass: "organizerUpdate",
    channel: "whatsapp",
    status: "draft",
    name: "Welcome",
    segmentIds: [],
    savedAudienceId: "audience",
    savedAudienceRevision: 1,
    savedAudienceDefinitionHash: "a".repeat(64),
    connectionId: "connection",
    templateId: "template",
    templateVariables: {},
    eventId: null,
    inviteDestinationKind: null,
    scheduledAt: null,
    recipientSnapshotHash: null,
    contentHash: "b".repeat(64),
    audienceCounts: emptyCampaignAudienceCounts(),
    deliveryCounts: emptyCampaignDeliveryCounts(),
    revision: 1,
    leaseOwner: null,
    leaseExpiresAt: null,
    createdAt: now,
    updatedAt: now,
    approvedAt: null,
    dispatchedAt: null,
    completedAt: null,
    cancelledAt: null,
  };
  const origin = {
    ruleId: "rule",
    ruleRevision: 1,
    actionId: "welcome",
    sourceId: "response",
    eventKind: "submitted" as const,
    contactId: "ada",
  };
  const originId = organizerContactOriginId({
    organizerId: "org",
    sourceKind: "hostForm",
    sourceEntityKind: "hostFormResponse",
    sourceEntityId: "response",
  });
  const store = new AudienceTestStore({
    "organizers/org": {
      ownerUserId: "host",
      hostUserIds: ["host"],
      hostProfiles: [],
    },
    "organizerCampaigns/recipe": recipe,
    "organizerSenderConnections/connection": {
      organizerId: "org",
      status: "active",
    },
    "organizerMessageTemplates/template": {
      organizerId: "org",
      connectionId: "connection",
      status: "APPROVED",
      variableNames: [],
    },
    "organizerAudienceSummaries/org": {
      organizerId: "org",
      sourceCoverage: "exact",
    },
    "organizerSavedAudiences/audience": {
      organizerId: "org",
      audienceId: "audience",
      status: "active",
      scope: "organizerCrm",
      revision: 1,
      definitionHash: "a".repeat(64),
      definition: {
        join: "all",
        predicates: [{kind: "staticMembers", contactIds: ["ada", "grace"]}],
      },
    },
    "organizerFormAutomationRules/rule": {
      organizerId: "org",
      enabled: true,
      revision: 1,
      updatedByUid: "host",
      actions: [
        {
          actionId: "welcome",
          kind: "campaignHandoff",
          campaignId: "recipe",
          campaignRevision: 1,
        },
      ],
    },
    "organizerForms/form": {organizerId: "org"},
    "organizerFormResponses/response": {
      organizerId: "org",
      formId: "form",
      status: "submitted",
      submittedAt: now,
    },
    [`organizerContactOrigins/${originId}`]: {
      organizerId: "org",
      currentContactId: "ada",
    },
  });
  for (const [id, phone] of [
    ["ada", "+919876543210"],
    ["grace", "+919876543211"],
  ]) {
    store.docs[`organizerContacts/${id}`] = {
      organizerId: "org",
      displayName: id,
      linkedUid: id,
      phoneE164: phone,
      identityState: "verified",
      identityConfidence: "verified",
      mergedIntoContactId: null,
      deletedAt: null,
      hiddenAt: null,
      revision: 1,
      updatedAt: now,
      whatsappAdminSuppressed: false,
      ambiguousCandidateContactIds: [],
    };
    store.docs[`organizerContactTraits/${id}`] = {
      organizerId: "org",
      contactId: id,
      segmentIds: [],
      attendedEventCount: 0,
      projectionVersion: 1,
      updatedAt: now,
    };
    store.docs[
      `organizerCommunicationPreferences/${organizerCommunicationPreferenceId(
        "org",
        id,
      )}`
    ] = {
      organizerId: "org",
      uid: id,
      whatsapp: {
        status: "optedIn",
        evidenceStatus: "complete",
        currentReceiptId: "receipt",
        termsVersion: "v1",
        updatedAt: now,
      },
    };
  }
  const params = {
    db: store.asFirestore(),
    organizerId: "org",
    actorUid: "host",
    recipeId: "recipe",
    recipeRevision: 1,
    campaignId: "auto-send",
    name: "Welcome Ada",
    origin,
    now: () => now,
  };
  return {store, params};
}

test("campaign approval freezes only the triggering person", async () => {
  const {store, params} = fixture();
  assert.equal(await prepareAutomatedOrganizerCampaign(params), "auto-send");
  const recipients = Object.entries(store.docs).filter(([key]) =>
    key.startsWith("organizerCampaignRecipients/"),
  );
  assert.equal(recipients.length, 1);
  assert.equal(recipients[0][1].contactId, "ada");
  assert.equal(recipients[0][1].status, "pending");
  assert.equal(store.docs["organizerCampaigns/auto-send"].status, "approved");
  assert.equal(store.docs["organizerCampaigns/recipe"].revision, 1);
  await prepareAutomatedOrganizerCampaign(params);
  assert.equal(
    Object.keys(store.docs).filter((key) =>
      key.startsWith("organizerCampaignRecipients/"),
    ).length,
    1,
  );
});

test("unreachable triggers cannot send to other audience members", async () => {
  const {store, params} = fixture();
  store.docs[
    `organizerCommunicationPreferences/${organizerCommunicationPreferenceId(
      "org",
      "ada",
    )}`
  ].whatsapp = {
    status: "optedOut",
    evidenceStatus: "complete",
    currentReceiptId: "receipt",
  };
  await assert.rejects(
    prepareAutomatedOrganizerCampaign(params),
    /noReachableRecipients/,
  );
  assert.equal(
    Object.keys(store.docs).some((key) =>
      key.startsWith("organizerCampaignRecipients/"),
    ),
    false,
  );
});

test("queued sends recheck rules, messages and source authority", async () => {
  for (const mutation of ["pause", "message", "source"]) {
    const {store, params} = fixture();
    await prepareAutomatedOrganizerCampaign(params);
    if (mutation === "pause") {
      store.docs["organizerFormAutomationRules/rule"].enabled = false;
    }
    if (mutation === "message") {
      store.docs["organizerCampaigns/recipe"].revision = 2;
    }
    if (mutation === "source") {
      store.docs["organizerFormResponses/response"].status = "withdrawn";
    }
    await assert.rejects(
      requireAutomationCampaignAuthority(
        store.asFirestore(),
        store.docs[
          "organizerCampaigns/auto-send"
        ] as unknown as OrganizerCampaignDocument,
      ),
      {code: "failed-precondition"},
    );
  }
});

test("an event postponed after queuing blocks premature delivery", async () => {
  const {store, params} = fixture();
  await prepareAutomatedOrganizerCampaign(params);
  const campaign = store.docs["organizerCampaigns/auto-send"];
  campaign.automationOrigin = {
    ...params.origin,
    eventKind: "eventAttended",
    sourceId: "edge",
  };
  store.docs["organizerContactEventEdges/edge"] = {
    organizerId: "org",
    eventId: "event",
    contactId: "ada",
    checkedIn: true,
    cancelled: false,
    checkedInAt: now,
  };
  store.docs["events/event"] = {
    organizerId: "org",
    status: "published",
    endTime: Timestamp.fromMillis(now.toMillis() + 3600000),
  };
  await assert.rejects(
    requireAutomationCampaignAuthority(
      store.asFirestore(),
      campaign as unknown as OrganizerCampaignDocument,
      now.toMillis(),
    ),
    {code: "failed-precondition"},
  );
});

test("endpoint deduplication targets one person", async () => {
  const {store, params} = fixture();
  params.origin.contactId = "grace";
  for (const [path, origin] of Object.entries(store.docs)) {
    if (path.startsWith("organizerContactOrigins/")) {
      origin.currentContactId = "grace";
    }
  }
  store.docs["organizerContacts/grace"].phoneE164 =
    store.docs["organizerContacts/ada"].phoneE164;
  await prepareAutomatedOrganizerCampaign(params);
  const recipients = Object.entries(store.docs).filter(([path]) =>
    path.startsWith("organizerCampaignRecipients/"),
  );
  assert.equal(recipients.length, 1);
  assert.equal(recipients[0][1].contactId, "grace");
});
