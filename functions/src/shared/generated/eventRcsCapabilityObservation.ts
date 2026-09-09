/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventRcsCapabilityObservation {
  requestId: string;
  senderId: string;
  agentId: string;
  recipientEndpointId: string;
  configHash: string;
  permissionHash: string;
  checkedAt: number;
  validUntil: number;
  supportsOpenUrl: boolean;
}
