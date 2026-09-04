/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerFormAggregateDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_form_aggregates.schema.json",
  "title": "OrganizerFormAggregateDocument",
  "description": "Precomputed form/version funnel or privacy-aware question aggregate.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formId",
    "versionId",
    "scope",
    "questionId",
    "questionLabel",
    "questionKind",
    "privacyClass",
    "opens",
    "starts",
    "submissions",
    "withdrawals",
    "completionMillisTotal",
    "completionBuckets",
    "choiceCounts",
    "numericCount",
    "numericSum",
    "numericMin",
    "numericMax",
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
    "versionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "scope": {
      "type": "string",
      "enum": [
        "version",
        "question"
      ]
    },
    "questionId": {
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
    "questionLabel": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 240
    },
    "questionKind": {
      "anyOf": [
        {
          "type": "string",
          "enum": [
            "shortText",
            "longText",
            "singleChoice",
            "multiChoice",
            "date",
            "phone",
            "email",
            "url",
            "number",
            "boolean",
            "file",
            "acknowledgement",
            "signature"
          ]
        },
        {
          "type": "null"
        }
      ]
    },
    "privacyClass": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        null,
        "contact",
        "profile",
        "sensitive",
        "organizerCustom"
      ]
    },
    "opens": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1000000000
    },
    "starts": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1000000000
    },
    "submissions": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1000000000
    },
    "withdrawals": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1000000000
    },
    "completionMillisTotal": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "completionBuckets": {
      "type": "array",
      "maxItems": 12,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "upperBoundMillis",
          "count"
        ],
        "properties": {
          "upperBoundMillis": {
            "type": "integer",
            "minimum": 1000,
            "maximum": 604800000
          },
          "count": {
            "type": "integer",
            "minimum": 0,
            "maximum": 1000000000
          }
        }
      }
    },
    "choiceCounts": {
      "type": "array",
      "maxItems": 100,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "value",
          "label",
          "count"
        ],
        "properties": {
          "value": {
            "type": [
              "string",
              "boolean"
            ],
            "maxLength": 160
          },
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160
          },
          "count": {
            "type": "integer",
            "minimum": 0,
            "maximum": 1000000000
          }
        }
      }
    },
    "numericCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 1000000000
    },
    "numericSum": {
      "type": "number",
      "minimum": -1000000000000000000,
      "maximum": 1000000000000000000
    },
    "numericMin": {
      "type": [
        "number",
        "null"
      ]
    },
    "numericMax": {
      "type": [
        "number",
        "null"
      ]
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
  },
  "x-firestore-collection": "organizerFormAggregates",
  "x-firestore-path": "organizerFormAggregates/{aggregateId}",
  "x-document-id-field": "aggregateId",
  "x-owner": "organizer form aggregate projection"
} as const;
