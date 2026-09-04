/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerContactTagVocabularyDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_contact_tag_vocabularies.schema.json",
  "title": "OrganizerContactTagVocabularyDocument",
  "description": "Organizer-authored manual CRM tag vocabulary. Tag ids are structurally distinct from computed audience segment ids.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerContactTagVocabularies",
  "x-firestore-path": "organizerContactTagVocabularies/{organizerId}",
  "x-document-id-field": "organizerId",
  "x-owner": "manager-only organizer contact mutation callable",
  "required": [
    "organizerId",
    "tags",
    "updatedAt"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "tags": {
      "type": "array",
      "maxItems": 20,
      "uniqueItems": true,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "tagId",
          "label",
          "normalizedLabel",
          "createdByUid",
          "createdAt"
        ],
        "properties": {
          "tagId": {
            "type": "string",
            "pattern": "^[a-f0-9]{32}$"
          },
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 40
          },
          "normalizedLabel": {
            "type": "string",
            "minLength": 1,
            "maxLength": 40
          },
          "createdByUid": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
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
        }
      },
      "x-catch-ownership": "server-only"
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
      },
      "x-catch-ownership": "server-only"
    }
  },
  "definitions": {
    "tag": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "tagId",
        "label",
        "normalizedLabel",
        "createdByUid",
        "createdAt"
      ],
      "properties": {
        "tagId": {
          "type": "string",
          "pattern": "^[a-f0-9]{32}$"
        },
        "label": {
          "type": "string",
          "minLength": 1,
          "maxLength": 40
        },
        "normalizedLabel": {
          "type": "string",
          "minLength": 1,
          "maxLength": 40
        },
        "createdByUid": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
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
      }
    }
  }
} as const;
