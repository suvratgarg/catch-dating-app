/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type AdminGenerateSalesOutreachDraftResponse =
  | {
      status: "completed";
      result: {
        draftId: string;
        contentHash: string;
      };
      idempotentReplay: boolean;
    }
  | {
      status: "running";
      retryAfterSeconds: number;
    }
  | {
      status: "failed";
      failure: string | null;
    };
