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
    };
