/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const convertOrganizerFormResponseCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/convert_organizer_form_response_response.schema.json",
  "title": "ConvertOrganizerFormResponseCallableResponse",
  "description": "Completed reviewed conversion receipt.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "receiptId",
    "organizerId",
    "formId",
    "responseId",
    "kind",
    "status",
    "fields",
    "resultId",
    "undoStatus",
    "completedAtMillis"
  ],
  "properties": {
    "receiptId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
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
    "status": {
      "type": "string",
      "enum": [
        "pending",
        "completed",
        "failed"
      ]
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
    "resultId": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 200
    },
    "undoStatus": {
      "type": "string",
      "enum": [
        "notAvailable",
        "available",
        "used",
        "expired"
      ]
    },
    "completedAtMillis": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0,
      "maximum": 9007199254740991
    }
  }
} as const;
