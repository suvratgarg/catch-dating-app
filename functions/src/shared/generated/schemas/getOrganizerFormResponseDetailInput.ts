/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getOrganizerFormResponseDetailCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_organizer_form_response_detail_payload.schema.json",
  "title": "GetOrganizerFormResponseDetailCallablePayload",
  "description": "Manager-authorized response detail request.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "responseId"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "responseId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
