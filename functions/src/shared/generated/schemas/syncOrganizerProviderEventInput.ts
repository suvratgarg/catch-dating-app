/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const syncOrganizerProviderEventCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/sync_organizer_provider_event_payload.schema.json",
  "title": "SyncOrganizerProviderEventCallablePayload",
  "description": "Idempotent manager request to reconcile one mapped external event into the Catch operational roster.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "eventId",
    "clientOperationId"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "clientOperationId": {
      "type": "string",
      "minLength": 16,
      "maxLength": 120
    }
  }
} as const;
