/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Union of explicit start, exact session read, and bounded synthetic action requests. Auth and App Check are required for every variant.
 */
export type SalesDemoTrialCallablePayload =
  | {
      invitationId: string;
      grantToken: string;
      requestId: string;
    }
  | {
      sessionId: string;
      grantToken: string;
    }
  | {
      sessionId: string;
      grantToken: string;
      requestId: string;
      expectedRevision: number;
      action:
        | "reviewApplication"
        | "prepareReply"
        | "admitGuest"
        | "requestAssistance";
      choice?: "approve" | "needs_info" | "welcome" | "clarify";
    };
