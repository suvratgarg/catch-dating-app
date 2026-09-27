/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type ManageEventOfferCheckoutCallablePayload =
  | {
      action: "claim";
      token: string;
    }
  | {
      action: "prepare";
      grantId: string;
      requestId: string;
      cancellationPolicy: {
        refundDeadlineMillis: number;
        eventStartsAtMillis: number;
      };
    }
  | {
      action: "find";
      grantId: string;
    }
  | {
      action: "status";
      paymentId: string;
      callback: {
        paymentId: string;
        signature: string;
      } | null;
    }
  | {
      action: "cancelAdmission";
      paymentId: string;
      expectedRefundAmountPaise: number;
    };
