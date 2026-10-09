/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const hostEventSummaryDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/host_event_summaries.schema.json",
  "title": "HostEventSummaryDocument",
  "description": "Server-maintained organizer-scoped Host read view. Never identity, permission or mutation authority.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "hostEventSummaries",
  "x-firestore-path": "hostEventSummaries/{eventId}",
  "x-document-id-field": "eventId",
  "x-owner": "Host read model projector",
  "required": [
    "organizerId",
    "eventId",
    "startTimeMillis",
    "status",
    "row",
    "version"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "startTimeMillis": {
      "type": "integer",
      "x-catch-ownership": "server-only"
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "cancelled"
      ],
      "x-catch-ownership": "server-only"
    },
    "row": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "eventId",
        "name",
        "city",
        "localDate",
        "localStartTime",
        "timezone",
        "startTimeMillis",
        "setupRevision",
        "status",
        "detailsConfigured"
      ],
      "properties": {
        "eventId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "city": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "cityId",
            "marketId"
          ],
          "properties": {
            "cityId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "marketId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            }
          }
        },
        "localDate": {
          "type": "string",
          "pattern": "^[0-9]{4}-[0-9]{2}-[0-9]{2}$"
        },
        "localStartTime": {
          "type": "string",
          "pattern": "^[0-9]{2}:[0-9]{2}$"
        },
        "timezone": {
          "type": "string",
          "minLength": 1,
          "maxLength": 100
        },
        "startTimeMillis": {
          "type": "integer"
        },
        "setupRevision": {
          "type": "integer",
          "minimum": 1
        },
        "status": {
          "type": "string",
          "enum": [
            "active",
            "cancelled"
          ]
        },
        "detailsConfigured": {
          "type": "boolean"
        }
      },
      "x-catch-ownership": "server-only"
    },
    "version": {
      "const": 1,
      "x-catch-ownership": "server-only"
    }
  }
} as const;
