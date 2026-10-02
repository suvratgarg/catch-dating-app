/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getParticipantActivityCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_participant_activity_payload.schema.json",
  "title": "GetParticipantActivityCallablePayload",
  "description": "Read the authenticated account's owned form submissions without profile claiming.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "sourceKind",
    "sourceId"
  ],
  "properties": {
    "sourceKind": {
      "type": "string",
      "const": "formResponse"
    },
    "sourceId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
