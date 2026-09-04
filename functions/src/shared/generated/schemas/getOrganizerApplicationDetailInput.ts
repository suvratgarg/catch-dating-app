/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getOrganizerApplicationDetailCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_organizer_application_detail_payload.schema.json",
  "title": "GetOrganizerApplicationDetailCallablePayload",
  "description": "Manager-authorized organizer application detail lookup.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "applicationId"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "applicationId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
