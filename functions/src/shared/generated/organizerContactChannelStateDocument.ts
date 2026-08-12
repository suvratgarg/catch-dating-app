/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Organizer-contact channel frequency and suppression state rechecked immediately before delivery.
 */
export interface OrganizerContactChannelStateDocument {
  organizerId: string;
  contactId: string;
  channel: "whatsapp";
  endpointHash: string;
  suppressionStatus:
    | "none"
    | "optedOut"
    | "providerBlocked"
    | "invalidEndpoint"
    | "adminSuppressed";
  suppressionSource: null | "preference" | "inboundStop" | "provider" | "admin";
  campaignAcceptedCount: number;
  lastCampaignAcceptedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  lastInboundAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  lastReplyAt: {
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
