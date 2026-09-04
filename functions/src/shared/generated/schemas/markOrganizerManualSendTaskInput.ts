/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const markOrganizerManualSendTaskCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/mark_organizer_manual_send_task_payload.schema.json",
  "title": "MarkOrganizerManualSendTaskCallablePayload",
  "description": "Revision-bound explicit terminal host action for one manual-send task.",
  "x-callable-aliases": [
    "markOrganizerManualSendTask"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "taskId",
    "expectedRevision",
    "action"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "taskId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "action": {
      "type": "string",
      "enum": [
        "hostMarkedSent",
        "skipped",
        "cancelled"
      ]
    }
  }
} as const;
