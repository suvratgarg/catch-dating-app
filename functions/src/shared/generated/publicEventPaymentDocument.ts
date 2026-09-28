/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned public OTP checkout. Holds and financial recovery share the event payment engine; no application approval or form-offer identity is implied.
 */
export interface PublicEventPaymentDocument {
  organizerId: string;
  eventId: string;
  recipientUid: string;
  requestId: string;
  canonicalSeatKey: string;
  identityRevision: number;
  migrationRevision: number;
  routing: {
    version: 1;
    amountMinor: number;
    transferAmountMinor: number | null;
    settlementHold: boolean | null;
    purpose: "formFee" | "eventAdmission";
    organizerId: string;
    selection: {
      route:
        | "razorpayRoute"
        | "razorpayOAuth"
        | "stripeConnectDirect"
        | "stripeConnectDestination";
      mode: "test" | "live";
      currency: string;
      merchantCountry: string;
    };
    policySource: "app" | "organizer" | "legacy";
    appRevision: number;
    organizerRevision: number;
    bindingId: string;
    merchantAccountId: string;
    destinationAccountId: string | null;
    configurationVersion: string;
    checkoutKey: string | null;
  };
  amountPaise: number;
  currency: "INR";
  receipt: string;
  status:
    | "creatingOrder"
    | "orderUnknown"
    | "checkoutReady"
    | "verifying"
    | "captured"
    | "admitted"
    | "expired"
    | "refundPending"
    | "refunded"
    | "reviewRequired"
    | "failed"
    | "cancelled";
  providerOrderId: string | null;
  providerPaymentId: string | null;
  providerRefundId: string | null;
  refundedAmountPaise: number;
  admissionReceiptId: string | null;
  reservationReleased: boolean;
  leaseUntil: {
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
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  checkoutExpiresAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  capturedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  admittedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  lastErrorCode: string | null;
  /**
   * Durable Route hold-release intent and provider observation. Release is separate from settled funds. Optional only for pre-admission and older attempts.
   */
  settlement?: {
    state:
      | "waiting"
      | "releasePending"
      | "released"
      | "settled"
      | "blocked"
      | "reviewRequired"
      | "reversed";
    transferId: string | null;
    nextAttemptAtMillis: number;
    leaseUntilMillis: number;
    leaseId: string | null;
    authorizedAtMillis: number | null;
    completedAtMillis: number | null;
    releasedAtMillis: number | null;
    settledAtMillis: number | null;
  };
  cancellation?: {
    reason: "eventCancelled" | "guestCancelled";
    requestedAtMillis: number;
    attendeeId: string;
    refundAmountPaise: number;
    seatRetained: boolean;
  };
  cancellationPolicy: {
    refundDeadlineMillis: number;
    eventStartsAtMillis: number;
  };
  registrationRevision: number;
  attendeeId: string;
  phoneE164: string;
  displayName: string;
  eventName: string;
  requestHash: string;
  inviteLinkId: string | null;
}
