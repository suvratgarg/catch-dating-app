/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const placeDetailsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/place_details_payload.schema.json",
  "title": "PlaceDetailsCallablePayload",
  "description": "Callable payload accepted by placeDetails.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "placeId"
  ],
  "properties": {
    "placeId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 256
    },
    "sessionToken": {
      "type": "string",
      "minLength": 8,
      "maxLength": 128
    }
  }
} as const;
