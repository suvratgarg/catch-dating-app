/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminSendCatchWhatsappReplyCallablePayload {
  purpose: "serviceSupport";
  inboundEventId: string;
  reviewedInboundTextHash: string;
  confirmSupportRequest: true;
  body: string;
}
