/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Durable form fee ledger. Frozen answers remain in the revision-bound response draft; payment is separate from application review and event admission.
 */
export interface OrganizerFormPaymentDocument {
  routing?: {
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
  organizerId: string;
  formId: string;
  versionId: string;
  draftId: string;
  respondentUid: string;
  connectionId: string | null;
  accountId: string;
  mode: "test" | "live";
  draftRevision: number;
  answersHash: string;
  identity: {
    displayName: string | null;
    email: string | null;
    phoneE164: string | null;
    searchName: string | null;
    origin: "anonymous" | "respondentGranted" | "organizerAcquired";
  };
  amountPaise: number;
  currency: "INR";
  description: string;
  refundPolicy: string;
  receipt: string;
  status:
    | "creatingOrder"
    | "orderUnknown"
    | "checkoutReady"
    | "verifying"
    | "captured"
    | "submitted"
    | "failed"
    | "expired"
    | "refundPending"
    | "refunded"
    | "reviewRequired";
  providerOrderId: string | null;
  providerPaymentId: string | null;
  providerRefundId: string | null;
  refundedAmountPaise: number;
  responseId: string | null;
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
  submittedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  lastErrorCode: string | null;
}
