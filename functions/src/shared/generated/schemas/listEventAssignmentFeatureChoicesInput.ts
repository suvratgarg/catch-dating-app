/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listEventAssignmentFeatureChoicesCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/list_event_assignment_feature_choices_payload.schema.json",
  "title": "ListEventAssignmentFeatureChoicesCallablePayload",
  "description": "Private participant discovery of exact event matching answers and prior grants.",
  "x-callable-aliases": [
    "listEventAssignmentFeatureChoices"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
