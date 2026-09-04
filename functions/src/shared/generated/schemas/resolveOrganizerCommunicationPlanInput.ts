/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const resolveOrganizerCommunicationPlanCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/resolve_organizer_communication_plan_payload.schema.json",
  "title": "ResolveOrganizerCommunicationPlanCallablePayload",
  "description": "Manager-authorized request for one intent-aware organizer communication plan.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "intent",
    "target"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "intent": {
      "type": "string",
      "enum": [
        "individualConversation"
      ]
    },
    "target": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "contactId"
      ],
      "properties": {
        "kind": {
          "const": "contact"
        },
        "contactId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        }
      }
    }
  }
} as const;
