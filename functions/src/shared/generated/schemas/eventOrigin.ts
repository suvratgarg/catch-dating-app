/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventOriginSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/embedded/event_origin.schema.json",
  "title": "EventOrigin",
  "description": "Immutable booking and roster provenance for one operational event.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "mode",
    "bookingAuthority",
    "rosterAuthority",
    "provider",
    "externalEventId",
    "externalEventUrl",
    "sourceExternalEventId",
    "adapterVersion",
    "connectedAt",
    "connectedBy"
  ],
  "properties": {
    "mode": {
      "type": "string",
      "enum": [
        "catchNative",
        "externalCompanion"
      ]
    },
    "bookingAuthority": {
      "type": "string",
      "enum": [
        "catch",
        "external"
      ]
    },
    "rosterAuthority": {
      "type": "string",
      "enum": [
        "catchProjection",
        "hostImport",
        "providerSync"
      ]
    },
    "provider": {
      "type": "string",
      "enum": [
        "catch",
        "generic",
        "luma",
        "eventbrite",
        "partiful",
        "posh",
        "bookmyshow",
        "district",
        "sortmyscene",
        "airbnb"
      ]
    },
    "externalEventId": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 240
    },
    "externalEventUrl": {
      "anyOf": [
        {
          "type": "string",
          "format": "uri",
          "maxLength": 2048
        },
        {
          "type": "null"
        }
      ]
    },
    "sourceExternalEventId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "adapterVersion": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 80
    },
    "connectedAt": {
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
    "connectedBy": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
