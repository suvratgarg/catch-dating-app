import {createHash} from "crypto";
import type {
  OrganizerCommunicationPermissionReceiptDocument,
  OrganizerCommunicationPreferenceDocument,
} from "./generated/firestoreAdminTypes";

export type OrganizerCommunicationChannel = "whatsapp" | "sms";

type ChannelPreference = OrganizerCommunicationPreferenceDocument["whatsapp"];

const organizerUpdatesConsentCopy = {
  "organizer-updates-v1": {
    whatsapp:
      "Send me future event announcements from this organizer on WhatsApp",
    sms:
      "Send me future event announcements from this organizer by text message",
  },
} as const;

/** Returns the deterministic organizer-and-user preference document id. */
export function organizerCommunicationPreferenceId(
  organizerId: string,
  uid: string
): string {
  return `orgpref_${sha256(`${organizerId}|${uid}`).slice(0, 48)}`;
}

/** Returns a stable immutable receipt id for one source decision. */
export function organizerCommunicationPermissionReceiptId(params: {
  organizerId: string;
  uid: string;
  channel: OrganizerCommunicationChannel;
  decision: "optedIn" | "optedOut";
  source: OrganizerCommunicationPermissionReceiptDocument["source"];
  sourceIdentity: string;
}): string {
  return `ocpr_${sha256([
    params.organizerId,
    params.uid,
    params.channel,
    params.decision,
    params.source,
    params.sourceIdentity,
  ].join("|")).slice(0, 48)}`;
}

/** Returns the reviewed consent-copy hash, or null for an unknown version. */
export function organizerUpdatesConsentCopyHash(
  termsVersion: string,
  channel: OrganizerCommunicationChannel
): string | null {
  const version = termsVersion as keyof typeof organizerUpdatesConsentCopy;
  const copy = organizerUpdatesConsentCopy[version]?.[channel];
  return copy ? sha256(`${termsVersion}|${channel}|${copy}`) : null;
}

/** Builds complete participant grant evidence for website OTP registration. */
export function publicRegistrationPermissionReceipt(params: {
  organizerId: string;
  uid: string;
  channel: OrganizerCommunicationChannel;
  eventId: string;
  termsVersion: string;
  supersedesReceiptId: string | null;
  now: FirebaseFirestore.Timestamp;
}): {id: string; document: OrganizerCommunicationPermissionReceiptDocument} |
  null {
  const consentCopyHash = organizerUpdatesConsentCopyHash(
    params.termsVersion,
    params.channel
  );
  if (!consentCopyHash) return null;
  const id = organizerCommunicationPermissionReceiptId({
    organizerId: params.organizerId,
    uid: params.uid,
    channel: params.channel,
    decision: "optedIn",
    source: "publicEventRegistration",
    sourceIdentity: `${params.eventId}|${params.termsVersion}`,
  });
  return {
    id,
    document: {
      organizerId: params.organizerId,
      uid: params.uid,
      channel: params.channel,
      decision: "optedIn",
      evidenceStatus: "complete",
      termsVersion: params.termsVersion,
      consentCopyHash,
      source: "publicEventRegistration",
      sourceEventId: params.eventId,
      sourceFormId: null,
      sourceResponseId: null,
      sourceProviderEventId: null,
      actorClass: "participant",
      actorUid: params.uid,
      identityStrength: "phoneVerified",
      grantedAt: params.now,
      revokedAt: null,
      supersedesReceiptId: params.supersedesReceiptId,
      createdAt: params.now,
    },
  };
}

/** Builds complete provider evidence for a participant's WhatsApp STOP. */
export function inboundStopPermissionReceipt(params: {
  organizerId: string;
  uid: string;
  providerEventId: string;
  supersedesReceiptId: string | null;
  now: FirebaseFirestore.Timestamp;
}): {id: string; document: OrganizerCommunicationPermissionReceiptDocument} {
  const id = organizerCommunicationPermissionReceiptId({
    organizerId: params.organizerId,
    uid: params.uid,
    channel: "whatsapp",
    decision: "optedOut",
    source: "inboundStop",
    sourceIdentity: params.providerEventId,
  });
  return {
    id,
    document: {
      organizerId: params.organizerId,
      uid: params.uid,
      channel: "whatsapp",
      decision: "optedOut",
      evidenceStatus: "complete",
      termsVersion: null,
      consentCopyHash: null,
      source: "inboundStop",
      sourceEventId: null,
      sourceFormId: null,
      sourceResponseId: null,
      sourceProviderEventId: params.providerEventId,
      actorClass: "provider",
      actorUid: params.uid,
      identityStrength: "catchAccount",
      grantedAt: null,
      revokedAt: params.now,
      supersedesReceiptId: params.supersedesReceiptId,
      createdAt: params.now,
    },
  };
}

/** New unknown channels cannot accidentally resemble permission. */
export function unknownOrganizerCommunicationChannel(): ChannelPreference {
  return {
    status: "unknown",
    evidenceStatus: "notApplicable",
    currentReceiptId: null,
    termsVersion: null,
    source: null,
    sourceEventId: null,
    updatedAt: null,
  };
}

/** Managed delivery requires a referenced, complete opted-in receipt. */
export function hasCompleteOrganizerCommunicationGrant(
  preference: OrganizerCommunicationPreferenceDocument | null | undefined,
  channel: OrganizerCommunicationChannel
): boolean {
  const value = preference?.[channel];
  return value?.status === "optedIn" &&
    value.evidenceStatus === "complete" &&
    typeof value.currentReceiptId === "string" &&
    value.currentReceiptId.length > 0;
}

/**
 * Projects incomplete legacy grants to unknown while preserving withdrawals.
 */
export function effectiveOrganizerCommunicationStatus(
  preference: OrganizerCommunicationPreferenceDocument | null | undefined,
  channel: OrganizerCommunicationChannel
): "unknown" | "optedIn" | "optedOut" {
  const value = preference?.[channel];
  if (value?.status === "optedOut") return "optedOut";
  return hasCompleteOrganizerCommunicationGrant(preference, channel) ?
    "optedIn" : "unknown";
}

function sha256(value: string): string {
  return createHash("sha256").update(value).digest("hex");
}
