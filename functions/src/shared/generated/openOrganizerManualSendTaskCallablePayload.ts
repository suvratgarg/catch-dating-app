/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Revision-bound acknowledgement that the device accepted the external handoff.
 */
export interface OpenOrganizerManualSendTaskCallablePayload {
  organizerId: string;
  taskId: string;
  expectedRevision: number;
}
