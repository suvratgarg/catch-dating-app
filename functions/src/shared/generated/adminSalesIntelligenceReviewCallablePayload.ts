/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Closed review and manual-copy requests. Each callable accepts only its own variant; none grants send authority.
 */
export type AdminSalesIntelligenceReviewCallablePayload =
  | {
      requestId: string;
      clauseId: string;
      expectedRevision: number;
      decision: "approve" | "withdraw";
    }
  | {
      requestId: string;
      draftId: string;
      expectedContentHash: string;
      factualValidity: "verified";
      tone: "approved";
      channelReadiness: "manual_copy_only";
    }
  | {
      requestId: string;
      draftId: string;
      expectedContentHash: string;
    };
