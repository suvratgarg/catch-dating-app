/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerApplicationSourceMappingDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_application_source_mappings.schema.json",
  "title": "OrganizerApplicationSourceMappingDocument",
  "description": "Reusable provider-neutral mapping from external tabular columns to one Catch form version.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerApplicationSourceMappings",
  "x-firestore-path": "organizerApplicationSourceMappings/{mappingId}",
  "x-document-id-field": "mappingId",
  "x-owner": "organizer application import callables",
  "required": [
    "organizerId",
    "formId",
    "formVersionId",
    "name",
    "sourceKind",
    "providerId",
    "externalFormId",
    "headerFingerprint",
    "columns",
    "createdByUid",
    "revision",
    "createdAt",
    "updatedAt"
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
    "formVersionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "sourceKind": {
      "type": "string",
      "enum": [
        "csv",
        "xlsx",
        "connector"
      ]
    },
    "providerId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 80
    },
    "externalFormId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 240
    },
    "headerFingerprint": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "columns": {
      "type": "array",
      "minItems": 1,
      "maxItems": 250,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "sourceHeader",
          "sourceHeaderNormalized",
          "action",
          "questionId",
          "transform"
        ],
        "properties": {
          "sourceHeader": {
            "type": "string",
            "minLength": 1,
            "maxLength": 240
          },
          "sourceHeaderNormalized": {
            "type": "string",
            "minLength": 1,
            "maxLength": 240
          },
          "action": {
            "type": "string",
            "enum": [
              "map",
              "ignore"
            ]
          },
          "questionId": {
            "type": [
              "string",
              "null"
            ],
            "minLength": 1,
            "maxLength": 120
          },
          "transform": {
            "type": "string",
            "enum": [
              "identity",
              "trim",
              "e164",
              "isoDate",
              "number",
              "boolean",
              "splitOptions",
              "assetUrl"
            ]
          }
        }
      }
    },
    "createdByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
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
    },
    "updatedAt": {
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
} as const;
