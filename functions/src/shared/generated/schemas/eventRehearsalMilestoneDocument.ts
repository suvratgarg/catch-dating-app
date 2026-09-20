/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventRehearsalMilestoneDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_rehearsal_milestones.schema.json",
  "title": "EventRehearsalMilestoneDocument",
  "type": "object",
  "additionalProperties": false,
  "description": "Durable organizer rehearsal completion, stamped only by a successful completion transaction; not deleted with expiring sessions.",
  "x-firestore-collection": "eventRehearsalMilestones",
  "x-firestore-path": "eventRehearsalMilestones/{organizerId}",
  "x-document-id-field": "organizerId",
  "x-owner": "event rehearsal completion callable",
  "required": [
    "organizerId",
    "completedAt"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "completedAt": {
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
      "x-catch-ownership": "callable-owned"
    }
  }
} as const;
