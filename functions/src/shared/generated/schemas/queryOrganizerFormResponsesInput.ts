/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const queryOrganizerFormResponsesCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/query_organizer_form_responses_payload.schema.json",
  "title": "QueryOrganizerFormResponsesCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formId",
    "versionId",
    "statuses",
    "predicate",
    "sort",
    "limit",
    "cursor"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{1,128}$"
    },
    "formId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{1,128}$"
    },
    "versionId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{1,128}$"
    },
    "statuses": {
      "type": "array",
      "minItems": 1,
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
    "predicate": {
      "type": [
        "object",
        "null"
      ],
      "maxProperties": 5,
      "additionalProperties": true,
      "description": "Published-version-aware compiler validates ALL/ANY tree, operators, value types, sensitive exclusion, depth 3 and maximum 20 leaves before any response scan."
    },
    "sort": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "questionId",
        "direction",
        "nulls"
      ],
      "properties": {
        "questionId": {
          "anyOf": [
            {
              "type": "string",
              "pattern": "^[A-Za-z0-9_-]{1,128}$"
            },
            {
              "type": "null"
            }
          ]
        },
        "direction": {
          "type": "string",
          "enum": [
            "asc",
            "desc"
          ]
        },
        "nulls": {
          "type": "string",
          "enum": [
            "first",
            "last"
          ]
        }
      }
    },
    "limit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 100
    },
    "cursor": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000
    }
  }
} as const;
