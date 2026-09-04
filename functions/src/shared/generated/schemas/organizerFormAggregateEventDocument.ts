/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerFormAggregateEventDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_form_aggregate_events.schema.json",
  "title": "OrganizerFormAggregateEventDocument",
  "description": "Idempotency marker for one aggregate projection event.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formId",
    "versionId",
    "responseId",
    "eventKind",
    "projectedAt",
    "expiresAt"
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
    "eventKind": {
      "type": "string",
      "enum": [
        "submitted",
        "withdrawn"
      ]
    },
    "projectedAt": {
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
    "expiresAt": {
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
  "x-firestore-collection": "organizerFormAggregateEvents",
  "x-firestore-path": "organizerFormAggregateEvents/{eventId}",
  "x-document-id-field": "eventId",
  "x-owner": "organizer form aggregate projection"
} as const;
