/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventRcsDispatchDocument {
  schemaVersion: 1;
  attemptId: string;
  messageId: string;
  context: {
    mode: "live";
    organizerId: string;
    eventId: string;
  };
  senderId: string;
  agentId: string;
  region: "asia" | "europe" | "us";
  bindingRevision: number;
  configHash: string;
  permissionId: string;
  permissionRevision: number;
  permissionHash: string;
  recipientEndpointId: string;
  endpointHash: string;
  capability: {
    requestId: string;
    senderId: string;
    agentId: string;
    recipientEndpointId: string;
    configHash: string;
    permissionHash: string;
    checkedAt: number;
    validUntil: number;
    supportsOpenUrl: boolean;
  };
  grantId: string;
  guestGrantHash: string;
  payloadHash: string;
  authorityHash: string;
  providerMessageId: string;
  expiresAt: number;
  createdAt: number;
  quoteRevision: number;
  currency: string;
  maxCostMicros: number;
  /**
   * @minItems 2
   * @maxItems 2
   */
  budgetDebits: {
    budgetId: string;
    approvalId: string;
    revisionBefore: number;
    revisionAfter: number;
    chargedBeforeMicros: number;
    chargedAfterMicros: number;
  }[];
  attendeeId: string;
}
