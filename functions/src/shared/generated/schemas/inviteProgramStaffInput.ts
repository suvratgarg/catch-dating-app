/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const inviteProgramStaffCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/invite_program_staff_payload.schema.json",
  "title": "InviteProgramStaffCallablePayload",
  "description": "Create a single-use, phone-bound staff invite for a program. The invite redeems into a station-scoped grant when a signed-in account with the matching verified phone claims it. Manager-only.",
  "type": "object",
  "additionalProperties": false,
  "x-callable-aliases": [
    "inviteProgramStaff"
  ],
  "required": [
    "programId",
    "phoneNumber",
    "displayName",
    "duties",
    "expiresAtMillis"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "phoneNumber": {
      "type": "string",
      "minLength": 4,
      "maxLength": 32
    },
    "displayName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "duties": {
      "type": "array",
      "minItems": 1,
      "maxItems": 8,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "duty",
          "pickupPointIds",
          "hotelIds"
        ],
        "properties": {
          "duty": {
            "type": "string",
            "enum": [
              "programCoordinator",
              "airportGreeter",
              "hotelDesk",
              "transportDispatcher",
              "reconciliationViewer"
            ]
          },
          "pickupPointIds": {
            "type": "array",
            "maxItems": 32,
            "uniqueItems": true,
            "items": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "description": "Station scope for airportGreeter/transportDispatcher duties. Empty means all pickup points in the program."
          },
          "hotelIds": {
            "type": "array",
            "maxItems": 64,
            "uniqueItems": true,
            "items": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "description": "Hotel scope for hotelDesk duties. Empty means all hotels in the program."
          }
        }
      }
    },
    "expiresAtMillis": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991,
      "description": "Invite redemption deadline and the access-window end for the grant it materializes. Claims after this time fail."
    }
  }
} as const;
