/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type ManageEventOfferCheckoutCallablePayload =
  | {
      action: "claim";
      token: string;
      /**
       * Opt in to additive event access metadata; omitted clients retain the prior paid receipt shape.
       */
      includeEventAccess?: boolean;
    }
  | {
      action: "prepare";
      grantId: string;
      requestId: string;
      cancellationPolicy: {
        refundDeadlineMillis: number;
        eventStartsAtMillis: number;
      };
      /**
       * Opt in to additive event access metadata; omitted clients retain the prior paid receipt shape.
       */
      includeEventAccess?: boolean;
    }
  | {
      action: "find";
      grantId: string;
      /**
       * Opt in to additive event access metadata; omitted clients retain the prior paid receipt shape.
       */
      includeEventAccess?: boolean;
    }
  | {
      action: "status";
      paymentId: string;
      callback: {
        paymentId: string;
        signature: string;
      } | null;
      /**
       * Opt in to additive event access metadata; omitted clients retain the prior paid receipt shape.
       */
      includeEventAccess?: boolean;
    }
  | {
      action: "cancelAdmission";
      paymentId: string;
      expectedRefundAmountPaise: number;
      /**
       * Opt in to additive event access metadata; omitted clients retain the prior paid receipt shape.
       */
      includeEventAccess?: boolean;
    }
  | {
      action: "acceptFree";
      grantId: string;
      requestId: string;
      expectedOfferGeneration: number;
      expectedOfferRevision: number;
      expectedLedgerRevision: number;
      /**
       * Opt in to additive event access metadata; omitted clients retain the prior paid receipt shape.
       */
      includeEventAccess?: boolean;
    };
