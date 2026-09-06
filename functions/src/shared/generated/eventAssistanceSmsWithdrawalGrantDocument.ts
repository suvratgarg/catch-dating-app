/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceSmsWithdrawalGrantDocument {
  schemaVersion: 1;
  linkId: string;
  permissionId: string;
  context: {
    mode: "live";
    organizerId: string;
    eventId: string;
  };
  attendeeId: string;
  attendeeGeneration: string;
  subjectUid: string;
  senderId: string;
  recipientEndpointId: string;
  guestGrantHash: string;
  permissionRevisionAtIssue: number;
  issuedAt: number;
  expiresAt: number;
}
