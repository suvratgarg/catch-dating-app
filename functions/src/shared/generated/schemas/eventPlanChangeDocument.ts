/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventPlanChangeDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_plan_changes.schema.json",
  "title": "EventPlanChangeDocument",
  "description": "Immutable server-authored event plan change stored at eventPlanChanges/{sourceId}. Each revision captures the attendee-relevant event facts after one committed host edit.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventPlanChanges",
  "x-firestore-path": "eventPlanChanges/{sourceId}",
  "x-document-id-field": "sourceId",
  "x-owner": "updateEvent callable and trusted Event Assistance workers",
  "required": [
    "schemaVersion",
    "sourceId",
    "eventId",
    "organizerId",
    "revision",
    "changedFields",
    "eventTitle",
    "startTime",
    "endTime",
    "meetingPoint",
    "itineraryStopCount",
    "occurredAt",
    "validUntil",
    "createdBy"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "sourceId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 2147483647
    },
    "changedFields": {
      "type": "array",
      "minItems": 1,
      "maxItems": 5,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "enum": [
          "name",
          "schedule",
          "meetingLocation",
          "itinerary",
          "format"
        ]
      }
    },
    "eventTitle": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160
    },
    "startTime": {
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
    "endTime": {
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
    "meetingPoint": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "itineraryStopCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 40
    },
    "occurredAt": {
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
    "validUntil": {
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
    "createdBy": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
