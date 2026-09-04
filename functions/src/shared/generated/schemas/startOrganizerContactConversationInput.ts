/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const startOrganizerContactConversationCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/start_organizer_contact_conversation_payload.schema.json",
  "title": "StartOrganizerContactConversationCallablePayload",
  "description": "Manager-only request to start or reuse an organizer-scoped conversation with one verified linked CRM contact.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "contactId"
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
    }
  }
} as const;
