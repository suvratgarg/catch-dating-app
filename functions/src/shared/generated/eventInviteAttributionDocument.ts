/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable evidence assigning or reversing one downstream event fact to one invitation link.
 */
export interface EventInviteAttributionDocument {
  eventId: string;
  organizerId: string;
  inviteLinkId: string;
  linkKind:
    | "hostChannel"
    | "directRecipient"
    | "attendeeReferrer"
    | "promoter"
    | "partner";
  ownerContactId: string | null;
  intendedRecipientContactId: string | null;
  subjectContactId: string | null;
  subjectUid: string | null;
  factKind: "registration" | "booking" | "checkIn" | "revenue" | "refund";
  operation: "credit" | "reversal";
  sourceKind:
    | "catchParticipation"
    | "eventAttendee"
    | "provider"
    | "selfReport";
  sourceFactId: string;
  primaryCredit: boolean;
  confidence: "exact" | "reconciled" | "selfReported";
  referralCredit: boolean;
  amountMinor?: number | null;
  currency?: string | null;
  reversalOfAttributionId: string | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  occurredAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
