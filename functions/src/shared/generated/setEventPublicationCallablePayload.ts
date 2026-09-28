/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface SetEventPublicationCallablePayload {
  organizerId: string;
  requestId: string;
  eventId: string;
  expectedSetupRevision: number;
  publicationState: "private" | "published";
}
