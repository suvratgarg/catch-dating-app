/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Create a minimal programGuests record for a door walk-in and check it in through the durable door journal in one transaction. The derived guest id is deterministic for the clientOperationId, so retries replay idempotently.
 */
export interface CreateProgramWalkInCallablePayload {
  programId: string;
  /**
   * The function the walk-in is checking into. Staff must hold functionCheckIn or functionLead covering this function.
   */
  functionId: string;
  displayName: string;
  /**
   * Device-observed check-in time; joins the journal idempotency key like every other door action.
   */
  occurredAtMillis: number;
  /**
   * Attending party size for the walk-in; null reads as 1.
   */
  partySize?: number | null;
  note?: string | null;
  deviceId?: string | null;
  clientOperationId: string;
}
