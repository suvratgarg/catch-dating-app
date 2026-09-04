/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const sendEventBroadcastCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/send_event_broadcast_response.schema.json",
  "title": "SendEventBroadcastCallableResponse",
  "description": "Delivery summary returned by sendEventBroadcast.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "broadcastId",
    "status",
    "recipientCount",
    "excludedCount",
    "activityAvailableCount",
    "pushAttemptedCount",
    "pushAcceptedCount",
    "pushFailedCount",
    "pushUnknownCount",
    "idempotentReplay"
  ],
  "properties": {
    "broadcastId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "status": {
      "type": "string",
      "enum": [
        "completed",
        "partial"
      ]
    },
    "recipientCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 500
    },
    "excludedCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 500
    },
    "activityAvailableCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 500
    },
    "pushAttemptedCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 500
    },
    "pushAcceptedCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 500
    },
    "pushFailedCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 500
    },
    "pushUnknownCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 500
    },
    "idempotentReplay": {
      "type": "boolean"
    }
  }
} as const;
