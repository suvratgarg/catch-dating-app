/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable participant evidence for Catch WhatsApp, separate from every organizer permission.
 */
export type CatchCommunicationPermissionReceiptDocument = {
  [k: string]: unknown;
} & {
  uid: string;
  channel: "whatsapp";
  decision: "optedIn" | "optedOut";
  evidenceStatus: "complete" | "incomplete";
  termsVersion: string | null;
  consentCopyHash: string | null;
  source:
    | "publicEventRegistration"
    | "hostFormResponse"
    | "participantSettings"
    | "unsubscribeLink"
    | "inboundStop"
    | "providerWebhook"
    | "legacyIncomplete";
  sourceEventId: string | null;
  sourceFormId: string | null;
  sourceResponseId: string | null;
  sourceProviderEventId: string | null;
  actorClass: "participant" | "provider" | "system";
  actorUid: string | null;
  identityStrength:
    | "unknown"
    | "emailVerified"
    | "phoneVerified"
    | "catchAccount";
  grantedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  revokedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  supersedesReceiptId: string | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  sourceOrganizerId: string | null;
};
