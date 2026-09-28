/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesTaskDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_tasks.schema.json",
  "title": "SalesTaskDocument",
  "description": "Human-owned follow-up; a task does not authorize contacting or sending.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "salesTasks",
  "x-firestore-path": "salesTasks/{taskId}",
  "x-owner": "private Sales task service and organizer claim projection",
  "required": [
    "schemaVersion",
    "classification",
    "taskId",
    "organizerId",
    "contactId",
    "revision",
    "kind",
    "title",
    "dueAt",
    "ownerUid",
    "status",
    "createdAt",
    "updatedAt",
    "updatedBy"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "taskId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "contactId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        {
          "type": "null"
        }
      ]
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000000
    },
    "kind": {
      "enum": [
        "research",
        "reply",
        "follow_up",
        "demo",
        "pilot",
        "duplicate_review",
        "opt_out",
        "service_commitment"
      ]
    },
    "title": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160
    },
    "dueAt": {
      "anyOf": [
        {
          "type": "string",
          "format": "date-time",
          "maxLength": 48
        },
        {
          "type": "null"
        }
      ]
    },
    "ownerUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "status": {
      "enum": [
        "open",
        "completed",
        "cancelled"
      ]
    },
    "createdAt": {
      "type": "string",
      "format": "date-time",
      "maxLength": 48
    },
    "updatedAt": {
      "type": "string",
      "format": "date-time",
      "maxLength": 48
    },
    "updatedBy": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  },
  "x-document-id-field": "taskId"
} as const;
