/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerMessageTemplateDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_message_templates.schema.json",
  "title": "OrganizerMessageTemplateDocument",
  "description": "Sanitized provider template metadata used for preview and send eligibility.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerMessageTemplates",
  "x-firestore-path": "organizerMessageTemplates/{templateId}",
  "x-document-id-field": "templateId",
  "x-owner": "WhatsApp template synchronization",
  "required": [
    "organizerId",
    "connectionId",
    "providerTemplateId",
    "name",
    "language",
    "category",
    "status",
    "variableNames",
    "parameterBindings",
    "hasMediaHeader",
    "buttonKinds",
    "providerUpdatedAt",
    "syncedAt"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "connectionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "providerTemplateId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "name": {
      "type": "string",
      "pattern": "^[a-z0-9_]{1,512}$"
    },
    "language": {
      "type": "string",
      "pattern": "^[A-Za-z]{2,3}(?:_[A-Za-z]{2})?$"
    },
    "category": {
      "type": "string",
      "enum": [
        "MARKETING",
        "UTILITY",
        "AUTHENTICATION",
        "UNKNOWN"
      ]
    },
    "status": {
      "type": "string",
      "enum": [
        "APPROVED",
        "PENDING",
        "REJECTED",
        "PAUSED",
        "DISABLED",
        "DELETED",
        "UNKNOWN"
      ]
    },
    "variableNames": {
      "type": "array",
      "maxItems": 20,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "pattern": "^[A-Za-z][A-Za-z0-9_]{0,63}$"
      }
    },
    "parameterBindings": {
      "type": "array",
      "maxItems": 20,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "variableName",
          "component",
          "position",
          "buttonIndex"
        ],
        "properties": {
          "variableName": {
            "type": "string",
            "pattern": "^[A-Za-z][A-Za-z0-9_]{0,63}$"
          },
          "component": {
            "type": "string",
            "enum": [
              "header",
              "body",
              "button"
            ]
          },
          "position": {
            "type": "integer",
            "minimum": 0,
            "maximum": 19
          },
          "buttonIndex": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 0,
            "maximum": 9
          }
        }
      }
    },
    "hasMediaHeader": {
      "type": "boolean"
    },
    "buttonKinds": {
      "type": "array",
      "maxItems": 10,
      "items": {
        "type": "string",
        "enum": [
          "URL",
          "PHONE_NUMBER",
          "QUICK_REPLY",
          "COPY_CODE",
          "UNKNOWN"
        ]
      }
    },
    "providerUpdatedAt": {
      "anyOf": [
        {
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
        {
          "type": "null"
        }
      ]
    },
    "syncedAt": {
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
