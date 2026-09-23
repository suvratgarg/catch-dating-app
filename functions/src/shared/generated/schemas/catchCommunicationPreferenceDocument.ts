/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const catchCommunicationPreferenceDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/catch_communication_preferences.schema.json",
  "title": "CatchCommunicationPreferenceDocument",
  "description": "Server-owned Catch WhatsApp preference. Never usable as organizer messaging permission.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "catchCommunicationPreferences",
  "x-firestore-path": "catchCommunicationPreferences/{uid}",
  "x-document-id-field": "uid",
  "x-owner": "participant consent handlers",
  "required": [
    "uid",
    "whatsapp",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "whatsapp": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "status",
        "evidenceStatus",
        "currentReceiptId",
        "termsVersion",
        "source",
        "sourceEventId",
        "updatedAt"
      ],
      "properties": {
        "status": {
          "type": "string",
          "enum": [
            "unknown",
            "optedIn",
            "optedOut"
          ],
          "x-catch-ownership": "server-only"
        },
        "evidenceStatus": {
          "type": "string",
          "enum": [
            "notApplicable",
            "complete",
            "incomplete"
          ],
          "description": "Only complete evidence may make an opted-in channel eligible for managed delivery.",
          "x-catch-ownership": "server-only"
        },
        "currentReceiptId": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            {
              "type": "null"
            }
          ],
          "x-catch-ownership": "server-only"
        },
        "termsVersion": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 80,
          "x-catch-ownership": "server-only"
        },
        "source": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            null,
            "publicEventRegistration",
            "hostFormResponse",
            "participantSettings",
            "unsubscribeLink",
            "inboundStop",
            "providerWebhook",
            "legacyIncomplete"
          ],
          "x-catch-ownership": "server-only"
        },
        "sourceEventId": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            {
              "type": "null"
            }
          ],
          "x-catch-ownership": "server-only"
        },
        "updatedAt": {
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
          ],
          "x-catch-ownership": "server-only"
        }
      }
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
