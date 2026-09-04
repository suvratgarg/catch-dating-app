/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const convertOrganizerFormResponseCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/convert_organizer_form_response_payload.schema.json",
  "title": "ConvertOrganizerFormResponseCallablePayload",
  "description": "Idempotently applies one reviewed response conversion.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "responseId",
    "kind",
    "eventId",
    "overrides",
    "requestId"
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
    },
    "requestId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 128
    }
  }
} as const;
