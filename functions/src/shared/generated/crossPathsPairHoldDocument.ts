/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned, short-lived companion-seat reservation for an accepted Cross Paths invitation.
 */
export interface CrossPathsPairHoldDocument {
  eventId: string;
  invitationId: string;
  organizerId: string;
  requesterUid: string;
  attendeeUid: string;
  /**
   * @minItems 2
   * @maxItems 2
   */
  participantIds: string[];
  status: "active" | "confirmed" | "expired" | "cancelled" | "invalidated";
  requesterBookingStatus: "held" | "confirmed" | "cancelled";
  attendeeBookingStatus: "confirmed" | "cancelled";
  requesterCohortId: string;
  attendeeCohortId: string;
  requesterPriceInPaise: number;
  attendeePriceInPaise: number;
  currency: string;
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
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  expiresAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  confirmedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  releasedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  releaseReason:
    | null
    | "expired"
    | "cancelled"
    | "event_unavailable"
    | "participation_cancelled"
    | "safety_state_changed"
    | "payment_failed";
  paymentId: string | null;
  conversationId: string | null;
}
