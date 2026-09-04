/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const previewOrganizerFormConversionCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/preview_organizer_form_conversion_response.schema.json",
  "title": "PreviewOrganizerFormConversionCallableResponse",
  "description": "Exact reviewed fields, conflicts, and permission boundary before conversion.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formId",
    "responseId",
    "kind",
    "eventId",
    "allowed",
    "fields",
    "warnings",
    "existingResultId"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "formId": {
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
    "allowed": {
      "type": "boolean"
    },
    "fields": {
      "type": "array",
      "maxItems": 100,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "destinationField",
          "label",
          "value",
          "origin",
          "conflict"
        ],
        "properties": {
          "destinationField": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160
          },
          "value": {
            "type": [
              "string",
              "number",
              "boolean",
              "null"
            ],
            "maxLength": 1000
          },
          "origin": {
            "type": "string",
            "enum": [
              "verifiedIdentity",
              "formAnswer",
              "hostOverride"
            ]
          },
          "conflict": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 500
          }
        }
      }
    },
    "warnings": {
      "type": "array",
      "maxItems": 20,
      "items": {
        "type": "string",
        "maxLength": 500
      }
    },
    "existingResultId": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 200
    }
  }
} as const;
