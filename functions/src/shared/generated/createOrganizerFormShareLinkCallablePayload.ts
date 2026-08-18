/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Creates an idempotent source-attributed link for a published form.
 */
export interface CreateOrganizerFormShareLinkCallablePayload {
  organizerId: string;
  formId: string;
  label: string;
  source: string | null;
  requestId: string;
}
