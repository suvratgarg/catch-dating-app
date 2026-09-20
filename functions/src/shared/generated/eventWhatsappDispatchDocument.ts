/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable debit and material identity committed with one outbox dispatch claim. No credentials, body, guest secret or recipient phone.
 */
export interface EventWhatsappDispatchDocument {
  schemaVersion: 1;
  attemptId: string;
  messageId: string;
  context: {
    mode: "live";
    organizerId: string;
    eventId: string;
  };
  senderId: string;
  bindingRevision: number;
  providerAccountId: string;
  providerPhoneNumberId: string;
  senderHash: string;
  policyHash: string;
  policyRevision: number;
  permissionId: string;
  permissionRevision: number;
  permissionHash: string;
  recipientEndpointId: string;
  endpointHash: string;
  templateDocumentId: string;
  templateHash: string;
  payloadHash: string;
  quoteRevision: number;
  grantId: string;
  currency: string;
  maxCostMicros: number;
  /**
   * @minItems 2
   * @maxItems 2
   */
  budgetIds: string[];
  replyBindingId: null | string;
  stopRecordHash: null | string;
  createdAt: number;
}
