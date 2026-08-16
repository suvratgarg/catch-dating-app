/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned organizer-scoped index of one completed event announcement, including bounded contact delivery state for CRM history.
 */
export interface OrganizerBroadcastSummaryDocument {
  organizerId: string;
  broadcastId: string;
  eventId: string;
  eventName: string;
  audience: "booked" | "prospective" | "everyone";
  recipientCount: number;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  sentAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  partialFailure: boolean;
  /**
   * @maxItems 500
   */
  recipientContactIds: string[];
  recipientDeliveryStates: {
    [k: string]: "available" | "failed";
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
