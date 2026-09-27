/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {EventOfferPaymentSnapshot} from "./eventOfferPaymentSnapshot";

/**
 * Server-owned payment attempt created atomically with its 15-minute canonical-seat hold. Routing and issued terms remain frozen through capture, admission, expiry and refund recovery.
 */
export interface OrganizerEventOfferPaymentDocument {
  organizerId: string;
  eventId: string;
  offerId: string;
  responseId: string;
  contactId: string;
  originId: string;
  recipientUid: string;
  grantId: string;
  requestId: string;
  canonicalSeatKey: string;
  offerGeneration: number;
  offerRevision: number;
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
  paymentSnapshot: EventOfferPaymentSnapshot;
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
    | "failed";
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
      | "reviewRequired";
    transferId: string | null;
    nextAttemptAtMillis: number;
    leaseUntilMillis: number;
    leaseId: string | null;
    authorizedAtMillis: number | null;
    completedAtMillis: number | null;
    releasedAtMillis: number | null;
    settledAtMillis: number | null;
  };
}
