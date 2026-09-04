/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventOperatorAccessCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/event_operator_access_payload.schema.json",
  "title": "EventOperatorAccessCallablePayload",
  "description": "Authenticated request for one event's sanitized operator workspace access.",
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
