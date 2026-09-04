/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createProfileDecisionClientWriteSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/client_writes/create_profile_decision.schema.json",
  "title": "CreateProfileDecisionClientWrite",
  "description": "Client-owned Firestore create operation for the current profileDecisions/{userId}/outgoing/{targetId} storage path.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "path",
    "data"
  ],
  "properties": {
    "path": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "userId",
        "targetId"
      ],
      "properties": {
        "userId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "targetId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        }
      }
    },
    "data": {
      "title": "SwipeDocument",
      "description": "Storage contract for contextual profile decisions stored at profileDecisions/{userId}/outgoing/{targetId}.",
      "type": "object",
      "additionalProperties": false,
      "x-firestore-collection": "profileDecisions",
      "x-firestore-path": "profileDecisions/{userId}/outgoing/{targetId}",
      "x-document-id-field": "targetId",
      "x-owner": "authenticated swiper direct create; matching trigger consumes likes",
      "x-logical-name": "profileDecision",
      "x-migration-phase": "new_primary",
      "x-internal-demo-fields": [
        "synthetic",
        "seedPrefix",
        "scenario",
        "demoOps",
        "demoOpsId",
        "demoOpsCommand"
      ],
      "required": [
        "swiperId",
        "targetId",
        "eventId",
        "direction",
        "createdAt"
      ],
      "properties": {
        "swiperId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "x-catch-ownership": "client-writable"
        },
        "targetId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "x-catch-ownership": "client-writable"
        },
        "eventId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "x-catch-ownership": "client-writable"
        },
        "direction": {
          "type": "string",
          "enum": [
            "like",
            "pass"
          ],
          "x-catch-ownership": "client-writable"
        },
        "reactionTargetId": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 80,
          "x-catch-ownership": "client-writable"
        },
        "reactionTargetType": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "heroPhoto",
            "photo",
            "profilePrompt",
            "compatibility",
            "running",
            "details",
            "lifestyle",
            null
          ],
          "x-catch-ownership": "client-writable"
        },
        "reactionTargetLabel": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 80,
          "x-catch-ownership": "client-writable"
        },
        "reactionTargetPreview": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 240,
          "x-catch-ownership": "client-writable"
        },
        "comment": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 240,
          "x-catch-ownership": "client-writable"
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
          },
          "x-catch-ownership": "client-writable"
        },
        "synthetic": {
          "type": "boolean",
          "description": "Internal demo seed marker used for cleanup and diagnostics."
        },
        "seedPrefix": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120,
          "description": "Internal demo seed prefix used for cleanup and diagnostics."
        },
        "scenario": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120,
          "description": "Internal demo seed scenario name used for cleanup and diagnostics."
        },
        "demoOps": {
          "type": "boolean",
          "description": "Internal demo-operations marker used for cleanup and diagnostics."
        },
        "demoOpsId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "description": "Internal demo-operations id used for cleanup and diagnostics."
        },
        "demoOpsCommand": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80,
          "description": "Internal demo-operations command name used for cleanup and diagnostics."
        }
      }
    }
  },
  "x-firestore-operation": "create",
  "x-firestore-path": "profileDecisions/{userId}/outgoing/{targetId}",
  "x-logical-name": "profileDecision",
  "x-migration-phase": "new_primary",
  "x-owner": "authenticated profile viewer direct create; matching trigger consumes likes"
} as const;
