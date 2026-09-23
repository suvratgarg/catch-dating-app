/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getProgramHotelInboundCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_program_hotel_inbound_payload.schema.json",
  "title": "GetProgramHotelInboundCallablePayload",
  "description": "Hotel-desk scoped inbound view: trips en route and expected guests for one hotel only.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "programId",
    "hotelId"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "hotelId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "tripCursor": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[^/]+$",
      "description": "Continuation returned for this hotel list. Omit to read its first page."
    },
    "expectedCursor": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[^/]+$",
      "description": "Continuation returned for this hotel list. Omit to read its first page."
    },
    "limit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 50
    }
  }
} as const;
