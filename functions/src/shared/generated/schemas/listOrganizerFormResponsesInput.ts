/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listOrganizerFormResponsesCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/list_organizer_form_responses_payload.schema.json",
  "title": "ListOrganizerFormResponsesCallablePayload",
  "description": "Manager-authorized bounded response inbox query.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formId",
    "versionId",
    "statuses",
    "identityKinds",
    "sourceLinkId",
    "query",
    "fromMillis",
    "toMillis",
    "cursor",
    "limit"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "formId": {
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
    "versionId": {
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
    "statuses": {
      "type": "array",
      "maxItems": 2,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "enum": [
          "submitted",
          "withdrawn"
        ]
      }
    },
    "identityKinds": {
      "type": "array",
      "maxItems": 4,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "enum": [
          "anonymous",
          "emailVerified",
          "phoneVerified",
          "catchAccount"
        ]
      }
    },
    "sourceLinkId": {
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
    "query": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 160
    },
    "fromMillis": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "toMillis": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "cursor": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000
    },
    "limit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 100
    }
  }
} as const;
