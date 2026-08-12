/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Frozen recipient eligibility and monotonic delivery receipt for one organizer campaign contact.
 */
export interface OrganizerCampaignRecipientDocument {
  organizerId: string;
  campaignId: string;
  contactId: string;
  channel: "whatsapp";
  eligibility: "eligible" | "excluded";
  exclusionReason:
    | null
    | "optedOut"
    | "noVerifiedEndpoint"
    | "duplicateEndpoint"
    | "frequencyCapped"
    | "providerBlocked"
    | "invalidEndpoint"
    | "unknownPermission"
    | "identityUnresolved"
    | "deleted";
  endpointE164: string | null;
  endpointHash: string | null;
  permissionTermsVersion: string | null;
  permissionUpdatedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  renderedVariablesHash: string;
  inviteLinkId: string | null;
  status:
    | "pending"
    | "sending"
    | "suppressed"
    | "accepted"
    | "sent"
    | "delivered"
    | "read"
    | "failed"
    | "replied"
    | "optedOut";
  providerMessageId: string | null;
  providerErrorCategory:
    | null
    | "authentication"
    | "template"
    | "quality"
    | "rateLimit"
    | "invalidRecipient"
    | "policy"
    | "provider"
    | "unknown";
  retryEligible: boolean;
  attemptCount: number;
  leaseOwner: string | null;
  leaseExpiresAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  acceptedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  sentAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  deliveredAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  readAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  failedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  repliedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  optedOutAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
