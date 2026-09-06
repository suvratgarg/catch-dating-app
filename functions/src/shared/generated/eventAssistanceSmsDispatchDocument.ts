/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceSmsDispatchDocument {
  schemaVersion: 1;
  attemptId: string;
  messageId: string;
  senderId: string;
  bindingRevision: number;
  configHash: string;
  permissionId: string;
  permissionRevision: number;
  recipientEndpointId: string;
  payloadHash: string;
  templateId: string;
  templateRevision: number;
  quoteRevision: number;
  grantId: string;
  encoding: "gsm7" | "unicode";
  segments: number;
  maxCostMicros: number;
  /**
   * @minItems 2
   * @maxItems 2
   */
  budgetIds: string[];
  createdAt: number;
  reportTokenHash: string;
  senderMask: string;
}
