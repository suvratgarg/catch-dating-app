/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Persists one queued individual external handoff before the client attempts to open the external application.
 */
export interface PrepareOrganizerManualSendTaskCallablePayload {
  organizerId: string;
  contactId: string;
  requestId: string;
  intent: "individualConversation";
  prefillText: string;
}
