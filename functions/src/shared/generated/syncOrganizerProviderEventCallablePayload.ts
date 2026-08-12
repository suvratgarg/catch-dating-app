/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Idempotent manager request to reconcile one mapped external event into the Catch operational roster.
 */
export interface SyncOrganizerProviderEventCallablePayload {
  organizerId: string;
  eventId: string;
  clientOperationId: string;
}
