/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Confirmed revision-fenced publication of one precomputed guided-rotation round.
 */
export interface PublishEventSuccessRotationRoundCallablePayload {
  eventId: string;
  expectedRevision: number;
  roundIndex: number;
  confirmed: boolean;
}
