/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const prepareOrganizerManualSendTaskCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/prepare_organizer_manual_send_task_payload.schema.json",
  "title": "PrepareOrganizerManualSendTaskCallablePayload",
  "description": "Persists one queued individual external handoff before the client attempts to open the external application.",
  "x-callable-aliases": [
    "prepareOrganizerManualSendTask"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "contactId",
    "requestId",
    "intent",
    "prefillText"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "contactId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "requestId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 120,
      "pattern": "^[A-Za-z0-9._:-]+$"
    },
    "intent": {
      "const": "individualConversation"
    },
    "prefillText": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
    }
  }
} as const;
