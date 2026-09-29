/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getProgramHotelRoomsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "callables/get_program_hotel_rooms_payload.schema.json",
  "title": "GetProgramHotelRoomsCallablePayload",
  "description": "Hotel-scoped accommodation view: room blocks with computed capacity, live stays, and guests routed to the hotel with no live stay. Requires the caller's hotelDesk duty to cover the hotel, or program coordinator/manager access.",
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
    }
  }
} as const;
