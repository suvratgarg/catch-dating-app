/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Minimal organizer fee records. No private credential, draft token, unsubmitted answers or respondent identity is exposed.
 */
export interface ListOrganizerFormPaymentsCallableResponse {
  /**
   * @maxItems 50
   */
  items: {
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
    mode: "test" | "live";
    amountPaise: number;
    currency: "INR";
    refundedAmountPaise: number;
    createdAtMillis: number;
    updatedAtMillis: number;
    capturedAtMillis: number | null;
    submittedAtMillis: number | null;
    responseId: string | null;
    providerOrderId: string | null;
    providerPaymentId: string | null;
    providerRefundId: string | null;
    receipt: string;
  }[];
  nextCursor: string | null;
}
