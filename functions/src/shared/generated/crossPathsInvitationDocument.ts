/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable-owned event-scoped invitation stored at crossPathsInvitations/{deterministicEventSenderHash}.
 */
export interface CrossPathsInvitationDocument {
  eventId: string;
  senderUid: string;
  recipientUid: string;
  /**
   * @minItems 2
   * @maxItems 2
   */
  participantIds: string[];
  status:
    | "pending"
    | "accepted"
    | "declined"
    | "cancelled"
    | "expired"
    | "invalidated";
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
  respondedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  cancelledAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  invalidatedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  invalidationReason:
    | null
    | "event_unavailable"
    | "participation_cancelled"
    | "consent_revoked"
    | "safety_state_changed"
    | "competing_plan_accepted"
    | "plan_cancelled"
    | "hold_expired";
  conversationId: string | null;
  pairHoldId: string | null;
}
