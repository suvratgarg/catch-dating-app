/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const markNotificationReadClientWriteSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/client_writes/mark_notification_read.schema.json",
  "title": "MarkNotificationReadClientWrite",
  "description": "Client-owned Firestore update operation for notifications/{uid}/items/{notificationId}.",
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
        "uid",
        "notificationId"
      ],
      "properties": {
        "uid": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "notificationId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        }
      }
    },
    "data": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "readAt"
      ],
      "properties": {
        "readAt": {
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
  },
  "x-firestore-operation": "update",
  "x-firestore-path": "notifications/{uid}/items/{notificationId}",
  "x-owner": "notification owner direct read-state update"
} as const;
