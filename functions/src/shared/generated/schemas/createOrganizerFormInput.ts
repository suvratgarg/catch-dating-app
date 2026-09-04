/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createOrganizerFormCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_organizer_form_payload.schema.json",
  "title": "CreateOrganizerFormCallablePayload",
  "description": "Creates one organizer-owned generic form draft from a versioned template.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "templateId",
    "requestId",
    "title",
    "defaultTargetKind",
    "defaultTargetId"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "templateId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "title": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 160
    },
    "defaultTargetKind": {
      "type": "string",
      "enum": [
        "organizer",
        "event",
        "campaign"
      ]
    },
    "defaultTargetId": {
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
    }
  }
} as const;
