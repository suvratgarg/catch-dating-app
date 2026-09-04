/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getEventSuccessSpatialLayoutCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_event_success_spatial_layout_payload.schema.json",
  "title": "GetEventSuccessSpatialLayoutCallablePayload",
  "description": "Requests the selected reusable layout for one authorized event participant or manager.",
  "x-callable-aliases": [
    "getEventSuccessSpatialLayout"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;
