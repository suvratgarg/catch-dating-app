/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Deterministically resets or forks a rehearsal run.
 */
export interface ResetEventRehearsalCallablePayload {
  sessionId: string;
  fork: boolean;
  seed: number | null;
}
