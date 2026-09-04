/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const setOrganizerFormAutomationStateCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/set_organizer_form_automation_state_payload.schema.json",
  "title": "SetOrganizerFormAutomationStateCallablePayload",
  "description": "Enables or disables one form automation revision.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "ruleId",
    "expectedRevision",
    "enabled"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "ruleId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "enabled": {
      "type": "boolean"
    }
  }
} as const;
