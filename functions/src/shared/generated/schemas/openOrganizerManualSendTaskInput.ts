/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const openOrganizerManualSendTaskCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/open_organizer_manual_send_task_payload.schema.json",
  "title": "OpenOrganizerManualSendTaskCallablePayload",
  "description": "Revision-bound acknowledgement that the device accepted the external handoff.",
  "x-callable-aliases": [
    "openOrganizerManualSendTask"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "taskId",
    "expectedRevision"
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
    }
  }
} as const;
