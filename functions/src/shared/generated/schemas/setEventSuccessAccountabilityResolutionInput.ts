/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const setEventSuccessAccountabilityResolutionCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/set_event_success_accountability_resolution_payload.schema.json",
  "title": "SetEventSuccessAccountabilityResolutionCallablePayload",
  "description": "Host resolution for one currently checked-in operational attendee during an Event Success sweep.",
  "x-callable-aliases": [
    "setEventSuccessAccountabilityResolution"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "attendeeId",
    "resolution"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "attendeeId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "resolution": {
      "type": "string",
      "enum": [
        "returned",
        "departed",
        "unresolved"
      ]
    }
  }
} as const;
