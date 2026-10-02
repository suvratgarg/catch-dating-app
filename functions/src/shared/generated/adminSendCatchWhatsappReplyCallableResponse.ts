/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminSendCatchWhatsappReplyCallableResponse {
  operationId: string;
  providerMessageId: string;
  deliveryStatus: "accepted" | "sent" | "delivered" | "read" | "failed";
  replayed: boolean;
}
