/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listOrganizerManualSendTasksCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/list_organizer_manual_send_tasks_payload.schema.json",
  "title": "ListOrganizerManualSendTasksCallablePayload",
  "description": "Lists a bounded organizer manual-send queue or history page.",
  "x-callable-aliases": [
    "listOrganizerManualSendTasks"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "activeOnly": {
      "type": "boolean",
      "default": true
    },
    "limit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 50,
      "default": 25
    },
    "cursor": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 1000
    }
  }
} as const;
