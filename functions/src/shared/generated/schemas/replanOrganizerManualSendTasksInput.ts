/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const replanOrganizerManualSendTasksCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/replan_organizer_manual_send_tasks_payload.schema.json",
  "title": "ReplanOrganizerManualSendTasksCallablePayload",
  "description": "Explicitly rechecks current communication routes for active manual work without mutating, dispatching, or completing it.",
  "x-callable-aliases": [
    "replanOrganizerManualSendTasks"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "taskIds"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "taskIds": {
      "type": "array",
      "minItems": 1,
      "maxItems": 50,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      }
    }
  }
} as const;
