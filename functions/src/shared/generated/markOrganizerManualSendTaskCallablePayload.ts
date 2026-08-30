/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Revision-bound explicit terminal host action for one manual-send task.
 */
export interface MarkOrganizerManualSendTaskCallablePayload {
  organizerId: string;
  taskId: string;
  expectedRevision: number;
  action: "hostMarkedSent" | "skipped" | "cancelled";
}
