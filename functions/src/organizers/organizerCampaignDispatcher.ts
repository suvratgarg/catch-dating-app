import {requireAutomationCampaignAuthority} from "./organizerAutomationSource";
import * as crypto from "node:crypto";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {
  CallableRequest,
  HttpsError,
  onCall,
} from "firebase-functions/v2/https";
import {requireAuth} from "../shared/auth";
import {appCheckCallableOptionsWithSecrets} from "../shared/callableOptions";
import {
  EventDocument,
  OrganizerCampaignDocument,
  OrganizerCampaignRecipientDocument,
  OrganizerCommunicationPreferenceDocument,
  OrganizerContactChannelStateDocument,
  OrganizerContactDocument,
  OrganizerMessageTemplateDocument,
  OrganizerSenderConnectionDocument,
} from "../shared/generated/firestoreAdminTypes";
import {OrganizerCampaignActionCallablePayload} from
  "../shared/generated/organizerCampaignActionCallablePayload";
import {OrganizerCampaignCallableResponse} from
  "../shared/generated/organizerCampaignCallableResponse";
import {validateOrganizerCampaignActionCallablePayload} from
  "../shared/generated/schemaValidators";
import {
  effectiveOrganizerCommunicationStatus,
  organizerCommunicationPreferenceId,
} from
  "../shared/organizerCommunicationPreferences";
import {requireOrganizerManager} from "../shared/organizerManagerAuthority";
import {checkRateLimit} from "../shared/rateLimit";
import {validateCallableWithAjv} from "../shared/validation";
import {
  campaignVariables,
  getOrganizerCampaignReportHandler,
} from "./organizerCampaigns";
import {
  classifyMetaError,
  hashCanonical,
  hashEndpoint,
  organizerCampaignFrequencyCapMillis,
  organizerContactChannelStateId,
} from "./organizerCampaignModel";
import {organizerWhatsappCampaignRoute} from
  "../communications/communicationRoutes";
import {assertOutboundContentAllowed} from
  "../communications/outboundContentPolicy";
import {
  metaWhatsappAppId,
  metaWhatsappAppSecret,
  metaWhatsappConfigId,
  metaWhatsappGraphVersion,
  organizerWhatsappAccessTokens,
} from "./organizerMessagingSetup";
import {
  MetaProviderError,
  MetaWhatsappProvider,
  OrganizerTokenStore,
  metaTemplateFromDocument,
} from "./organizerWhatsappProvider";

const campaignLeaseMillis = 3 * 60 * 1000;
const recipientLeaseMillis = 60 * 1000;

interface DispatcherDeps {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit: typeof checkRateLimit;
  tokenStore: OrganizerTokenStore;
  provider: () => MetaWhatsappProvider;
  now: () => FirebaseFirestore.Timestamp;
}

const defaultDeps: DispatcherDeps = {
  firestore: () => admin.firestore(),
  checkRateLimit,
  tokenStore: new OrganizerTokenStore(),
  provider: () =>
    new MetaWhatsappProvider({
      appId: metaWhatsappAppId.value(),
      appSecret: metaWhatsappAppSecret.value(),
      configId: metaWhatsappConfigId.value(),
      graphVersion: metaWhatsappGraphVersion.value(),
    }),
  now: () => admin.firestore.Timestamp.now(),
};

interface ClaimedRecipient {
  recipientId: string;
  recipient: OrganizerCampaignRecipientDocument;
  campaign: OrganizerCampaignDocument;
  connection: OrganizerSenderConnectionDocument;
  template: OrganizerMessageTemplateDocument;
  event: EventDocument | null;
  inviteToken: string | null;
  variables: Record<string, string>;
}

export async function dispatchOrganizerCampaignHandler(
  request: CallableRequest<unknown>,
  deps: DispatcherDeps = defaultDeps,
): Promise<OrganizerCampaignCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<OrganizerCampaignActionCallablePayload>(
    request,
    validateOrganizerCampaignActionCallablePayload,
    normalizePayload,
  );
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "dispatchOrganizerCampaign");
  await requireOrganizerManager({
    db,
    organizerId: data.organizerId,
    actorUid,
  });
  await dispatchCampaign({
    db,
    organizerId: data.organizerId,
    campaignId: data.campaignId,
    expectedRevision: data.expectedRevision ?? null,
    deps,
  });
  return getOrganizerCampaignReportHandler(request, deps);
}

export async function dispatchCampaign(params: {
  db: FirebaseFirestore.Firestore;
  organizerId: string;
  campaignId: string;
  expectedRevision: number | null;
  deps: DispatcherDeps;
}): Promise<void> {
  const leaseOwner = `campaign-${crypto.randomUUID()}`;
  const campaignRef = params.db
    .collection("organizerCampaigns")
    .doc(params.campaignId);
  const now = params.deps.now();
  await params.db.runTransaction(async (tx) => {
    const snapshot = await tx.get(campaignRef);
    const campaign = snapshot.data() as OrganizerCampaignDocument | undefined;
    if (!campaign || campaign.organizerId !== params.organizerId) {
      throw new HttpsError("not-found", "Campaign not found.");
    }
    assertOutboundContentAllowed(
      Object.values(campaign.templateVariables),
      "A WhatsApp template value contains language that cannot be delivered.",
    );
    if (
      params.expectedRevision !== null &&
      campaign.revision !== params.expectedRevision
    ) {
      throw new HttpsError(
        "aborted",
        "Campaign changed. Refresh before sending.",
      );
    }
    if (
      !["approved", "scheduled", "resolving", "sending"].includes(
        campaign.status,
      )
    ) {
      throw new HttpsError(
        "failed-precondition",
        "Campaign is not approved for delivery.",
      );
    }
    if (
      campaign.scheduledAt &&
      campaign.scheduledAt.toMillis() > now.toMillis()
    ) {
      throw new HttpsError(
        "failed-precondition",
        "Campaign is scheduled for a future time.",
      );
    }
    if (
      campaign.leaseExpiresAt &&
      campaign.leaseExpiresAt.toMillis() > now.toMillis()
    ) {
      return;
    }
    tx.update(campaignRef, {
      status: "resolving",
      dispatchedAt: campaign.dispatchedAt ?? now,
      leaseOwner,
      leaseExpiresAt: admin.firestore.Timestamp.fromMillis(
        now.toMillis() + campaignLeaseMillis,
      ),
      updatedAt: now,
      revision: campaign.revision + 1,
    });
  });
  const recipients = await params.db
    .collection("organizerCampaignRecipients")
    .where("campaignId", "==", params.campaignId)
    .where("status", "==", "pending")
    .orderBy(admin.firestore.FieldPath.documentId())
    .limit(100)
    .get();
  for (const recipientDoc of recipients.docs) {
    const claimed = await claimRecipient({
      db: params.db,
      organizerId: params.organizerId,
      campaignId: params.campaignId,
      recipientId: recipientDoc.id,
      campaignLeaseOwner: leaseOwner,
      deps: params.deps,
    });
    if (!claimed) continue;
    await deliverRecipient(claimed, params.deps).catch((error) =>
      recordDeliveryFailure(params.db, claimed, error, params.deps.now()),
    );
    await campaignRef.update({
      leaseExpiresAt: admin.firestore.Timestamp.fromMillis(
        params.deps.now().toMillis() + campaignLeaseMillis,
      ),
      updatedAt: params.deps.now(),
    });
  }
  await finishDispatch(
    params.db,
    params.campaignId,
    leaseOwner,
    params.deps.now(),
  );
}

async function claimRecipient(params: {
  db: FirebaseFirestore.Firestore;
  organizerId: string;
  campaignId: string;
  recipientId: string;
  campaignLeaseOwner: string;
  deps: DispatcherDeps;
}): Promise<ClaimedRecipient | null> {
  const now = params.deps.now();
  const recipientLeaseOwner = `recipient-${crypto.randomUUID()}`;
  let claimed: ClaimedRecipient | null = null;
  await params.db.runTransaction(async (tx) => {
    const campaignRef = params.db
      .collection("organizerCampaigns")
      .doc(params.campaignId);
    const recipientRef = params.db
      .collection("organizerCampaignRecipients")
      .doc(params.recipientId);
    const [campaignSnap, recipientSnap] = await Promise.all([
      tx.get(campaignRef),
      tx.get(recipientRef),
    ]);
    const campaign = campaignSnap.data() as
      | OrganizerCampaignDocument
      | undefined;
    const recipient = recipientSnap.data() as
      | OrganizerCampaignRecipientDocument
      | undefined;
    if (
      !campaign ||
      !recipient ||
      campaign.organizerId !== params.organizerId ||
      recipient.campaignId !== params.campaignId ||
      recipient.organizerId !== params.organizerId ||
      recipient.status !== "pending" ||
      campaign.leaseOwner !== params.campaignLeaseOwner ||
      !campaign.leaseExpiresAt ||
      campaign.leaseExpiresAt.toMillis() <= now.toMillis()
    ) {
      return;
    }
    const contactRef = params.db
      .collection("organizerContacts")
      .doc(recipient.contactId);
    const contactSnap = await tx.get(contactRef);
    const contact = contactSnap.data() as OrganizerContactDocument | undefined;
    const preferenceRef = contact?.linkedUid ?
      params.db
        .collection("organizerCommunicationPreferences")
        .doc(
          organizerCommunicationPreferenceId(
            params.organizerId,
            contact.linkedUid,
          ),
        ) :
      null;
    const channelRef = params.db
      .collection("organizerContactChannelStates")
      .doc(
        organizerContactChannelStateId(params.organizerId, recipient.contactId),
      );
    const connectionRef = params.db
      .collection("organizerSenderConnections")
      .doc(campaign.connectionId);
    const templateRef = params.db
      .collection("organizerMessageTemplates")
      .doc(campaign.templateId);
    const eventRef = campaign.eventId ?
      params.db.collection("events").doc(campaign.eventId) :
      null;
    const inviteSecretRef = recipient.inviteLinkId ?
      params.db
        .collection("eventInviteLinkSecrets")
        .doc(recipient.inviteLinkId) :
      null;
    const related = await Promise.all([
      preferenceRef ? tx.get(preferenceRef) : null,
      tx.get(channelRef),
      tx.get(connectionRef),
      tx.get(templateRef),
      eventRef ? tx.get(eventRef) : null,
      inviteSecretRef ? tx.get(inviteSecretRef) : null,
    ]);
    const preference = related[0]?.data() as
      | OrganizerCommunicationPreferenceDocument
      | undefined;
    const channelState = related[1].data() as
      | OrganizerContactChannelStateDocument
      | undefined;
    const connection = related[2].data() as
      | OrganizerSenderConnectionDocument
      | undefined;
    const template = related[3].data() as
      | OrganizerMessageTemplateDocument
      | undefined;
    const event = related[4]?.data() as EventDocument | undefined;
    const inviteToken =
      typeof related[5]?.data()?.token === "string" ?
        (related[5]!.data()!.token as string) :
        null;
    const suppression = finalSuppressionReason({
      organizerId: params.organizerId,
      campaign,
      recipient,
      contact,
      preference,
      channelState,
      connection,
      template,
      event,
      inviteToken,
      now,
    });
    if (suppression) {
      tx.update(recipientRef, {
        status: "suppressed",
        exclusionReason: suppression,
        retryEligible: false,
        updatedAt: now,
      });
      tx.update(campaignRef, {
        "deliveryCounts.pending": admin.firestore.FieldValue.increment(-1),
        "deliveryCounts.suppressed": admin.firestore.FieldValue.increment(1),
        "updatedAt": now,
      });
      return;
    }
    const variables = campaignVariables(
      campaign,
      inviteToken,
      event ?? null,
      template?.variableNames ?? [],
    );
    if (hashCanonical(variables) !== recipient.renderedVariablesHash) {
      tx.update(recipientRef, {
        status: "suppressed",
        exclusionReason: "providerBlocked",
        retryEligible: false,
        updatedAt: now,
      });
      tx.update(campaignRef, {
        "deliveryCounts.pending": admin.firestore.FieldValue.increment(-1),
        "deliveryCounts.suppressed": admin.firestore.FieldValue.increment(1),
        "updatedAt": now,
      });
      return;
    }
    tx.update(recipientRef, {
      status: "sending",
      leaseOwner: recipientLeaseOwner,
      leaseExpiresAt: admin.firestore.Timestamp.fromMillis(
        now.toMillis() + recipientLeaseMillis,
      ),
      attemptCount: recipient.attemptCount + 1,
      retryEligible: false,
      updatedAt: now,
    });
    tx.update(campaignRef, {status: "sending", updatedAt: now});
    claimed = {
      recipientId: params.recipientId,
      recipient: {
        ...recipient,
        status: "sending",
        leaseOwner: recipientLeaseOwner,
      },
      campaign,
      connection: connection!,
      template: template!,
      event: event ?? null,
      inviteToken,
      variables,
    };
  });
  return claimed;
}

async function deliverRecipient(
  claimed: ClaimedRecipient,
  deps: DispatcherDeps,
): Promise<void> {
  const credential = claimed.connection.secretVersionResource;
  const phoneNumberId = claimed.connection.phoneNumberId;
  if (!credential || !phoneNumberId || !claimed.recipient.endpointE164) {
    throw new Error("Sender or recipient endpoint is incomplete.");
  }
  await requireAutomationCampaignAuthority(
    deps.firestore(), claimed.campaign, deps.now().toMillis());
  const accessToken = await deps.tokenStore.access(credential);
  const result = await deps.provider().sendTemplate({
    accessToken,
    phoneNumberId,
    toE164: claimed.recipient.endpointE164,
    template: metaTemplateFromDocument(claimed.template),
    variables: claimed.variables,
  });
  const db = deps.firestore();
  const now = deps.now();
  await db.runTransaction(async (tx) => {
    const recipientRef = db
      .collection("organizerCampaignRecipients")
      .doc(claimed.recipientId);
    const campaignRef = db
      .collection("organizerCampaigns")
      .doc(claimed.recipient.campaignId);
    const stateRef = db
      .collection("organizerContactChannelStates")
      .doc(
        organizerContactChannelStateId(
          claimed.recipient.organizerId,
          claimed.recipient.contactId,
        ),
      );
    const [recipientSnap, stateSnap] = await Promise.all([
      tx.get(recipientRef),
      tx.get(stateRef),
    ]);
    const recipient = recipientSnap.data() as
      | OrganizerCampaignRecipientDocument
      | undefined;
    if (
      !recipient ||
      recipient.status !== "sending" ||
      recipient.leaseOwner !== claimed.recipient.leaseOwner
    ) {
      return;
    }
    const existingState = stateSnap.data() as
      | OrganizerContactChannelStateDocument
      | undefined;
    tx.update(recipientRef, {
      status: "accepted",
      providerMessageId: result.providerMessageId,
      acceptedAt: now,
      leaseOwner: null,
      leaseExpiresAt: null,
      updatedAt: now,
    });
    tx.set(
      stateRef,
      {
        organizerId: recipient.organizerId,
        contactId: recipient.contactId,
        channel: organizerWhatsappCampaignRoute.transport,
        endpointHash: recipient.endpointHash,
        suppressionStatus: existingState?.suppressionStatus ?? "none",
        suppressionSource: existingState?.suppressionSource ?? null,
        adminSuppressed: existingState?.adminSuppressed ?? false,
        campaignAcceptedCount: (existingState?.campaignAcceptedCount ?? 0) + 1,
        lastCampaignAcceptedAt: now,
        lastInboundAt: existingState?.lastInboundAt ?? null,
        lastReplyAt: existingState?.lastReplyAt ?? null,
        createdAt: existingState?.createdAt ?? now,
        updatedAt: now,
      },
      {merge: false},
    );
    tx.update(campaignRef, {
      "deliveryCounts.pending": admin.firestore.FieldValue.increment(-1),
      "deliveryCounts.accepted": admin.firestore.FieldValue.increment(1),
      "updatedAt": now,
    });
  });
}

async function recordDeliveryFailure(
  db: FirebaseFirestore.Firestore,
  claimed: ClaimedRecipient,
  error: unknown,
  now: FirebaseFirestore.Timestamp,
): Promise<void> {
  const category = classifyMetaError(
    error instanceof MetaProviderError ? error.providerCode : null,
  );
  logger.error("Organizer campaign delivery failed", {
    organizerId: claimed.recipient.organizerId,
    campaignId: claimed.recipient.campaignId,
    recipientId: claimed.recipientId,
    category,
    providerCode:
      error instanceof MetaProviderError ? error.providerCode : null,
  });
  await db.runTransaction(async (tx) => {
    const recipientRef = db
      .collection("organizerCampaignRecipients")
      .doc(claimed.recipientId);
    const campaignRef = db
      .collection("organizerCampaigns")
      .doc(claimed.recipient.campaignId);
    const snap = await tx.get(recipientRef);
    const recipient = snap.data() as
      | OrganizerCampaignRecipientDocument
      | undefined;
    if (
      !recipient ||
      recipient.status !== "sending" ||
      recipient.leaseOwner !== claimed.recipient.leaseOwner
    ) {
      return;
    }
    tx.update(recipientRef, {
      status: "failed",
      providerErrorCategory: category,
      retryEligible: false,
      failedAt: now,
      leaseOwner: null,
      leaseExpiresAt: null,
      updatedAt: now,
    });
    tx.update(campaignRef, {
      "deliveryCounts.pending": admin.firestore.FieldValue.increment(-1),
      "deliveryCounts.failed": admin.firestore.FieldValue.increment(1),
      "updatedAt": now,
    });
  });
}

async function finishDispatch(
  db: FirebaseFirestore.Firestore,
  campaignId: string,
  leaseOwner: string,
  now: FirebaseFirestore.Timestamp,
): Promise<void> {
  const [pending, failed] = await Promise.all([
    db
      .collection("organizerCampaignRecipients")
      .where("campaignId", "==", campaignId)
      .where("status", "in", ["pending", "sending"])
      .count()
      .get(),
    db
      .collection("organizerCampaignRecipients")
      .where("campaignId", "==", campaignId)
      .where("status", "==", "failed")
      .count()
      .get(),
  ]);
  const campaignRef = db.collection("organizerCampaigns").doc(campaignId);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(campaignRef);
    const campaign = snap.data() as OrganizerCampaignDocument | undefined;
    if (!campaign || campaign.leaseOwner !== leaseOwner) return;
    const remaining = pending.data().count;
    tx.update(campaignRef, {
      status:
        remaining > 0 ?
          "blocked" :
          failed.data().count > 0 ?
            "partiallyFailed" :
            "completed",
      completedAt: remaining > 0 ? null : now,
      leaseOwner: null,
      leaseExpiresAt: null,
      updatedAt: now,
      revision: campaign.revision + 1,
    });
  });
}

function finalSuppressionReason(params: {
  organizerId: string;
  campaign: OrganizerCampaignDocument;
  recipient: OrganizerCampaignRecipientDocument;
  contact: OrganizerContactDocument | undefined;
  preference: OrganizerCommunicationPreferenceDocument | undefined;
  channelState: OrganizerContactChannelStateDocument | undefined;
  connection: OrganizerSenderConnectionDocument | undefined;
  template: OrganizerMessageTemplateDocument | undefined;
  event: EventDocument | undefined;
  inviteToken: string | null;
  now: FirebaseFirestore.Timestamp;
}): OrganizerCampaignRecipientDocument["exclusionReason"] {
  if (!params.contact || params.contact.deletedAt !== null ||
      params.contact.hiddenAt != null) return "deleted";
  if (
    params.contact.identityState !== "verified" ||
    params.contact.identityConfidence !== "verified" ||
    !params.contact.linkedUid
  ) {
    return "identityUnresolved";
  }
  if (
    !params.contact.phoneE164 ||
    hashEndpoint(params.contact.phoneE164) !== params.recipient.endpointHash
  ) {
    return "invalidEndpoint";
  }
  if (!params.preference ||
      params.preference.organizerId !== params.organizerId ||
      params.preference.uid !== params.contact.linkedUid) {
    return "unknownPermission";
  }
  const permissionStatus = effectiveOrganizerCommunicationStatus(
    params.preference,
    "whatsapp"
  );
  if (permissionStatus === "unknown") return "unknownPermission";
  if (permissionStatus === "optedOut") return "optedOut";
  if (
    params.channelState?.adminSuppressed === true
  ) {
    return "providerBlocked";
  }
  if (
    params.channelState?.suppressionStatus !== undefined &&
    params.channelState.suppressionStatus !== "none"
  ) {
    return params.channelState.suppressionStatus === "invalidEndpoint" ?
      "invalidEndpoint" :
      params.channelState.suppressionStatus === "optedOut" ?
        "optedOut" :
        "providerBlocked";
  }
  if (
    params.channelState?.lastCampaignAcceptedAt &&
    params.now.toMillis() -
      params.channelState.lastCampaignAcceptedAt.toMillis() <
      organizerCampaignFrequencyCapMillis
  ) {
    return "frequencyCapped";
  }
  if (
    !params.connection ||
    params.connection.organizerId !== params.organizerId ||
    params.connection.status !== "active" ||
    !params.connection.secretVersionResource ||
    !params.connection.phoneNumberId
  ) {
    return "providerBlocked";
  }
  if (
    !params.template ||
    params.template.organizerId !== params.organizerId ||
    (params.template.connectionId !== params.connection.phoneNumberId &&
      params.template.connectionId !== params.campaign.connectionId) ||
    params.template.status !== "APPROVED"
  ) {
    return "providerBlocked";
  }
  if (
    params.campaign.eventId &&
    (!params.event ||
      (params.event.organizerId ?? params.event.clubId) !==
        params.organizerId ||
      params.event.status !== "active" ||
      !params.inviteToken)
  ) {
    return "providerBlocked";
  }
  return null;
}

function normalizePayload(data: unknown): unknown {
  if (typeof data !== "object" || data === null || Array.isArray(data)) {
    return data;
  }
  return Object.fromEntries(
    Object.entries(data as Record<string, unknown>).map(([key, value]) => [
      key,
      typeof value === "string" ? value.trim() : value,
    ]),
  );
}

const dispatcherCallableLimits = {
  timeoutSeconds: 540,
  maxInstances: 10,
  concurrency: 1,
};

export const dispatchOrganizerCampaign = onCall(
  appCheckCallableOptionsWithSecrets(
    [metaWhatsappAppSecret, organizerWhatsappAccessTokens],
    dispatcherCallableLimits,
  ),
  (request) => dispatchOrganizerCampaignHandler(request),
);

export const dispatchScheduledOrganizerCampaigns = onSchedule(
  {
    schedule: "every 5 minutes",
    timeZone: "Asia/Kolkata",
    timeoutSeconds: 540,
    maxInstances: 1,
    secrets: [metaWhatsappAppSecret, organizerWhatsappAccessTokens],
  },
  async () => {
    const db = defaultDeps.firestore();
    const now = defaultDeps.now();
    const snapshot = await db
      .collection("organizerCampaigns")
      .where("status", "==", "scheduled")
      .where("scheduledAt", "<=", now)
      .orderBy("scheduledAt")
      .limit(10)
      .get();
    for (const doc of snapshot.docs) {
      const campaign = doc.data() as OrganizerCampaignDocument;
      await dispatchCampaign({
        db,
        organizerId: campaign.organizerId,
        campaignId: doc.id,
        expectedRevision: null,
        deps: defaultDeps,
      }).catch((error) =>
        logger.error("Scheduled organizer campaign dispatch failed", {
          campaignId: doc.id,
          organizerId: campaign.organizerId,
          error,
        }),
      );
    }
  },
);
