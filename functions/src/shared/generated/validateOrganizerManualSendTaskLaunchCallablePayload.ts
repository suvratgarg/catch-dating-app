/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Revision-bound, read-only authority check immediately before re-opening an external handoff.
 */
export interface ValidateOrganizerManualSendTaskLaunchCallablePayload {
  organizerId: string;
  taskId: string;
  expectedRevision: number;
}
