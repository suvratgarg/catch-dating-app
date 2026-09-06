/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceGuestGrantDocument {
  schemaVersion: 1;
  linkId: string;
  threadId: string;
  guestId: string;
  context: {
    mode: "live";
    eventId: string;
    organizerId: string;
  };
  attendeeId: string;
  episodeId: string;
  tokenHash: string;
  signingKeyId: string;
  issuedAt: number;
  expiresAt: number;
  revokedAt: number | null;
}
