/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminReviewCatchWhatsappInboundCallableResponse {
  purpose: "serviceSupport";
  inboundEventId: string;
  inboundText: string;
  reviewedInboundTextHash: string;
  deadlineMillis: number;
}
