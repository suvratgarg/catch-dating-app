/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface GetOrganizerWhatsappThreadCallableResponse {
  organizerId: string;
  threadId: string;
  contactId: string;
  displayName: string;
  lastInboundAtMillis: number;
  serviceWindowExpiresAtMillis: number;
  serviceWindowOpen: boolean;
  /**
   * @maxItems 200
   */
  messages: {
    messageId: string;
    direction: "inbound" | "outbound";
    body: string;
    occurredAtMillis: number;
  }[];
  messagesTruncated: boolean;
}
