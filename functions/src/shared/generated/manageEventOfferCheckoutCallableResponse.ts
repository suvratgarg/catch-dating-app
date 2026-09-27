/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface ManageEventOfferCheckoutCallableResponse {
  grant: {
    grantId: string;
    eventName: string;
    eventId: string;
    startTimeMillis: number;
    amountPaise: number;
    currency: "INR";
    expiresAtMillis: number;
    cancellationPolicy: {
      refundDeadlineMillis: number;
      eventStartsAtMillis: number;
    };
  } | null;
  payment: {
    paymentId: string;
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
    amountPaise: number;
    currency: "INR";
    mode: "test" | "live";
    refundedAmountPaise: number;
    expiresAtMillis: number;
    checkout: {
      publicToken: string;
      orderId: string;
      amountPaise: number;
      currency: "INR";
      description: string;
      expiresAtMillis: number;
    } | null;
    cancellationReason: "eventCancelled" | "guestCancelled" | null;
    cancellationPolicy: {
      refundDeadlineMillis: number;
      eventStartsAtMillis: number;
    } | null;
    cancellationQuote: {
      refundAmountPaise: number;
    } | null;
  } | null;
  serverTimeMillis: number;
}
