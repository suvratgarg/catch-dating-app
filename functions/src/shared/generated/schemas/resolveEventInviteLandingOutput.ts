/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const resolveEventInviteLandingCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/resolve_event_invite_landing_response.schema.json",
  "title": "ResolveEventInviteLandingCallableResponse",
  "description": "Bounded details and handoff for a valid opaque event invitation.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "title",
    "startTimeMillis",
    "endTimeMillis",
    "locationName",
    "destinationKind",
    "destinationUrl",
    "sourceLabel"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "title": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "startTimeMillis": {
      "type": "integer"
    },
    "endTimeMillis": {
      "type": "integer"
    },
    "locationName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "destinationKind": {
      "type": "string",
      "enum": [
        "catchEvent",
        "eventRuntime",
        "externalBooking",
        "marketingLanding"
      ]
    },
    "destinationUrl": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 2048
    },
    "sourceLabel": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80
    }
  }
} as const;
