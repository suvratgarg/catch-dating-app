/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerEventLocationResolutionDecisionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_event_location_resolution_decisions.schema.json",
  "title": "OrganizerEventLocationResolutionDecisionDocument",
  "description": "Latest admin-reviewed event location resolution stored at organizerEventLocationResolutionDecisions/{resolutionId}. Raw provider lookup responses and imported events are not stored here.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerEventLocationResolutionDecisions",
  "x-firestore-path": "organizerEventLocationResolutionDecisions/{resolutionId}",
  "x-document-id-field": "resolutionId",
  "x-owner": "adminResolveOrganizerEventLocation callable",
  "required": [
    "schemaVersion",
    "resolutionId",
    "candidateId",
    "location",
    "checklist",
    "note",
    "reviewedByUid",
    "reviewedAt",
    "updatedAt",
    "resolutionStatus"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "resolutionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "candidateId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "location": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "name",
        "latitude",
        "longitude"
      ],
      "properties": {
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 240
        },
        "address": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 500
        },
        "placeId": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 256
        },
        "latitude": {
          "type": [
            "number",
            "null"
          ],
          "minimum": -90,
          "maximum": 90
        },
        "longitude": {
          "type": [
            "number",
            "null"
          ],
          "minimum": -180,
          "maximum": 180
        },
        "notes": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 1000
        }
      }
    },
    "checklist": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "sourceLocationReviewed",
        "coordinatesReviewed",
        "placeIdentityReviewed",
        "importSafetyReviewed"
      ],
      "properties": {
        "sourceLocationReviewed": {
          "type": "boolean"
        },
        "coordinatesReviewed": {
          "type": "boolean"
        },
        "placeIdentityReviewed": {
          "type": "boolean"
        },
        "importSafetyReviewed": {
          "type": "boolean"
        }
      }
    },
    "note": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
    },
    "reviewedByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "reviewedAt": {
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
    },
    "resolutionStatus": {
      "type": "string",
      "enum": [
        "resolved"
      ]
    }
  }
} as const;
