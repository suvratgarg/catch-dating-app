/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Current permission after an idempotent withdrawal; later consent is never overwritten by an old retry.
 */
export interface WithdrawParticipantMessagingPermissionCallableResponse {
  preference: {
    status: "unknown" | "optedIn" | "optedOut";
    purposes?: {
      eventOperations?: {
        status: "unknown" | "optedIn" | "optedOut";
        receiptId: string | null;
      };
      marketing?: {
        status: "unknown" | "optedIn" | "optedOut";
        receiptId: string | null;
      };
    };
    receiptId: string | null;
  };
  replayed: boolean;
}
