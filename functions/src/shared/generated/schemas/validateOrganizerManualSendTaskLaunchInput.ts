/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const validateOrganizerManualSendTaskLaunchCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/validate_organizer_manual_send_task_launch_payload.schema.json",
  "title": "ValidateOrganizerManualSendTaskLaunchCallablePayload",
  "description": "Revision-bound, read-only authority check immediately before re-opening an external handoff.",
  "x-callable-aliases": [
    "validateOrganizerManualSendTaskLaunch"
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
