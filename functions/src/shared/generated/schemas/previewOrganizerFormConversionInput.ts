/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const previewOrganizerFormConversionCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/preview_organizer_form_conversion_payload.schema.json",
  "title": "PreviewOrganizerFormConversionCallablePayload",
  "description": "Reviews one proposed downstream conversion without writing.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "responseId",
    "kind",
    "eventId",
    "overrides"
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
    },
    "kind": {
      "type": "string",
      "enum": [
        "crmContact",
        "application",
        "eventAttendeeProposal",
        "followUp"
      ]
    },
    "eventId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "overrides": {
      "type": "object",
      "maxProperties": 20,
      "additionalProperties": {
        "type": [
          "string",
          "number",
          "boolean",
          "null"
        ]
      }
    }
  }
} as const;
