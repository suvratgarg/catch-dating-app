/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerIntakeFieldCorrectionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_intake_field_corrections.schema.json",
  "title": "OrganizerIntakeFieldCorrectionDocument",
  "description": "Immutable, server-owned field correction captured when an admin first changes a source-seeded organizer value. Each correction owns a deterministic replay fixture id.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerIntakeFieldCorrections",
  "x-firestore-path": "organizerIntakeFieldCorrections/{correctionId}",
  "x-document-id-field": "correctionId",
  "x-owner": "adminUpdateOrganizerDetails callable",
  "required": [
    "schemaVersion",
    "correctionId",
    "fixtureId",
    "organizerId",
    "sourceProfileId",
    "sourceWorkItemId",
    "sourceCandidateId",
    "field",
    "extractedValue",
    "correctedValue",
    "artifactId",
    "contentHash",
    "locator",
    "extractedBy",
    "extractorVersion",
    "confidence",
    "reviewNote",
    "correctedByUid",
    "correctedAt"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "correctionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "fixtureId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "sourceProfileId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160
    },
    "sourceWorkItemId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "sourceCandidateId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "field": {
      "type": "string",
      "enum": [
        "name",
        "location",
        "tags",
        "publicProfile.sourceSummary",
        "publicProfile.formats"
      ]
    },
    "extractedValue": {
      "anyOf": [
        {
          "type": "string",
          "maxLength": 2000
        },
        {
          "type": "null"
        },
        {
          "type": "array",
          "maxItems": 40,
          "items": {
            "type": "string",
            "maxLength": 500
          }
        }
      ]
    },
    "correctedValue": {
      "anyOf": [
        {
          "type": "string",
          "maxLength": 2000
        },
        {
          "type": "null"
        },
        {
          "type": "array",
          "maxItems": 40,
          "items": {
            "type": "string",
            "maxLength": 500
          }
        }
      ]
    },
    "artifactId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "contentHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "locator": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000
    },
    "extractedBy": {
      "type": "string",
      "enum": [
        "deterministic",
        "model",
        "human"
      ]
    },
    "extractorVersion": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160
    },
    "confidence": {
      "type": [
        "number",
        "null"
      ],
      "minimum": 0,
      "maximum": 1
    },
    "reviewNote": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
    },
    "correctedByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "correctedAt": {
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
  "definitions": {
    "correctionValue": {
      "anyOf": [
        {
          "type": "string",
          "maxLength": 2000
        },
        {
          "type": "null"
        },
        {
          "type": "array",
          "maxItems": 40,
          "items": {
            "type": "string",
            "maxLength": 500
          }
        }
      ]
    }
  }
} as const;
