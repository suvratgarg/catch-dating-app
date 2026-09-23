/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Owner-only safe payment projection.
 */
export type PrepareOrganizerFormPaymentCallableResponse = {
  paymentId: string;
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
  amountPaise: number;
  currency: "INR";
  mode: "test" | "live";
  refundPolicy: string;
  refundedAmountPaise: number;
  checkout: {
    publicToken: string;
    orderId: string;
    amountPaise: number;
    currency: "INR";
    description: string;
    expiresAtMillis: number;
  } | null;
  receipt: {
    responseId: string;
    formId: string;
    versionId: string;
    status: "submitted" | "withdrawn";
    submittedAtMillis: number;
    withdrawalToken: string | null;
    completion: {
      title: string;
      message: string | null;
      actionKind: "none" | "externalUrl" | "event" | "eventRuntime";
      actionLabel: string | null;
      actionUrl: string | null;
    };
    /**
     * True only when the verified respondent has an active owned profile proposal to review. Not a claim or sharing grant.
     */
    profileReviewAvailable?: boolean;
  } | null;
};
