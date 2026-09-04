/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createOrganizerPostCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/create_organizer_post_response.schema.json",
  "title": "CreateOrganizerPostCallableResponse",
  "description": "Callable response returned by createOrganizerPost.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "postId",
    "remainingWeeklyQuota",
    "deliveryStatus",
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
    "postId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "remainingWeeklyQuota": {
      "type": "integer",
      "minimum": 0,
      "maximum": 3
    },
    "deliveryStatus": {
      "type": "string",
      "enum": [
        "pending",
        "completed",
        "partial"
      ]
    },
    "recipientCount": {
      "type": "integer",
      "minimum": 0
    },
    "excludedCount": {
      "type": "integer",
      "minimum": 0
    },
    "activityAvailableCount": {
      "type": "integer",
      "minimum": 0
    },
    "pushAttemptedCount": {
      "type": "integer",
      "minimum": 0
    },
    "pushAcceptedCount": {
      "type": "integer",
      "minimum": 0
    },
    "pushFailedCount": {
      "type": "integer",
      "minimum": 0
    },
    "pushUnknownCount": {
      "type": "integer",
      "minimum": 0
    },
    "idempotentReplay": {
      "type": "boolean"
    }
  }
} as const;
