/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const formCommunicationConsentIntentDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/form_communication_consent_intents.schema.json",
  "title": "FormCommunicationConsentIntentDocument",
  "description": "Private, immutable form choice. Never read as dispatch permission; promotion requires response ownership and verified control of the exact endpoint.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formId",
    "versionId",
    "responseId",
    "endpointE164",
    "termsVersion",
    "decisions",
    "createdAt"
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
    "versionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "responseId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "endpointE164": {
      "type": "string",
      "pattern": "^\\+[1-9][0-9]{6,14}$"
    },
    "termsVersion": {
      "const": "form-whatsapp-v2"
    },
    "decisions": {
      "type": "array",
      "minItems": 1,
      "maxItems": 3,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "principal",
          "purpose",
          "copyHash",
          "decidedAt"
        ],
        "properties": {
          "principal": {
            "enum": [
              "organizer",
              "catch"
            ]
          },
          "purpose": {
            "enum": [
              "eventOperations",
              "marketing"
            ]
          },
          "copyHash": {
            "type": "string",
            "pattern": "^[a-f0-9]{64}$"
          },
          "decidedAt": {
            "type": "object",
            "description": "Serialized Firestore Timestamp fixture shape.",
            "x-firestore-type": "timestamp",
            "additionalProperties": false,
            "required": [
              "_seconds",
              "_nanoseconds"
            ],
            "properties": {
              "_seconds": {
                "type": "integer"
              },
              "_nanoseconds": {
                "type": "integer",
                "minimum": 0,
                "maximum": 999999999
              }
            }
          }
        }
      }
    },
    "createdAt": {
      "type": "object",
      "description": "Serialized Firestore Timestamp fixture shape.",
      "x-firestore-type": "timestamp",
      "additionalProperties": false,
      "required": [
        "_seconds",
        "_nanoseconds"
      ],
      "properties": {
        "_seconds": {
          "type": "integer"
        },
        "_nanoseconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      }
    }
  },
  "x-firestore-collection": "formCommunicationConsentIntents",
  "x-firestore-path": "formCommunicationConsentIntents/{responseId}",
  "x-document-id-field": "responseId",
  "x-owner": "organizer form respondent callables"
} as const;
