/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const syncOrganizerProviderEventCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/sync_organizer_provider_event_response.schema.json",
  "title": "SyncOrganizerProviderEventCallableResponse",
  "description": "Safe result of one provider roster reconciliation.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "runId",
    "status",
    "pageCount",
    "receivedCount",
    "createdCount",
    "updatedCount",
    "skippedCount",
    "truncated",
    "replayed"
  ],
  "properties": {
    "runId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "status": {
      "type": "string",
      "enum": [
        "completed",
        "partial",
        "failed"
      ]
    },
    "pageCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 10
    },
    "receivedCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 250
    },
    "createdCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 250
    },
    "updatedCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 250
    },
    "skippedCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 250
    },
    "truncated": {
      "type": "boolean"
    },
    "replayed": {
      "type": "boolean"
    }
  }
} as const;
