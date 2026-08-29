/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned, organizer-scoped channel consent stored at organizerCommunicationPreferences/{organizerId_uid}.
 */
export interface OrganizerCommunicationPreferenceDocument {
  organizerId: string;
  uid: string;
  whatsapp: {
    status: "unknown" | "optedIn" | "optedOut";
    /**
     * Only complete evidence may make an opted-in channel eligible for managed delivery.
     */
    evidenceStatus: "notApplicable" | "complete" | "incomplete";
    currentReceiptId: string | null;
    termsVersion: string | null;
    source:
      | null
      | "publicEventRegistration"
      | "hostFormResponse"
      | "participantSettings"
      | "unsubscribeLink"
      | "inboundStop"
      | "providerWebhook"
      | "legacyIncomplete";
    sourceEventId: string | null;
    updatedAt: {
      _seconds: number;
      _nanoseconds: number;
    } | null;
  };
  sms: {
    status: "unknown" | "optedIn" | "optedOut";
    /**
     * Only complete evidence may make an opted-in channel eligible for managed delivery.
     */
    evidenceStatus: "notApplicable" | "complete" | "incomplete";
    currentReceiptId: string | null;
    termsVersion: string | null;
    source:
      | null
      | "publicEventRegistration"
      | "hostFormResponse"
      | "participantSettings"
      | "unsubscribeLink"
      | "inboundStop"
      | "providerWebhook"
      | "legacyIncomplete";
    sourceEventId: string | null;
    updatedAt: {
      _seconds: number;
      _nanoseconds: number;
    } | null;
  };
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
