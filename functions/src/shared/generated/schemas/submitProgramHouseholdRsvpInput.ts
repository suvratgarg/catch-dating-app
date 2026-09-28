/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const submitProgramHouseholdRsvpCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/submit_program_household_rsvp_payload.schema.json",
  "title": "SubmitProgramHouseholdRsvpCallablePayload",
  "description": "Token-authenticated household RSVP submit. Responses are limited to guests in the token's household and apply atomically. messagingConsent records the explicit checkbox state; it is never implied by submitting.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "token",
    "responses",
    "messagingConsent"
  ],
  "properties": {
    "token": {
      "type": "string",
      "minLength": 16,
      "maxLength": 1024
    },
    "responses": {
      "type": "array",
      "maxItems": 2000,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "guestId",
          "functionId",
          "rsvpStatus"
        ],
        "properties": {
          "guestId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "functionId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "rsvpStatus": {
            "type": "string",
            "enum": [
              "pending",
              "attending",
              "declined",
              "maybe"
            ]
          },
          "partySize": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 1,
            "maximum": 20
          },
          "responseNote": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 500
          }
        }
      }
    },
    "messagingConsent": {
      "type": "boolean",
      "description": "The explicit household messaging-consent checkbox; recorded exactly as ticked."
    },
    "travel": {
      "type": [
        "array",
        "null"
      ],
      "maxItems": 400,
      "description": "Optional per-member travel capture. Each block writes one programTravelLegs row keyed deterministically by household, guest, and journey kind, so resubmits update in place. A block is the complete desired state of that leg; absent blocks never delete planner-owned or previously captured journeys.",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "guestId",
          "kind"
        ],
        "properties": {
          "guestId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "kind": {
            "type": "string",
            "enum": [
              "inbound",
              "outbound",
              "ground"
            ]
          },
          "flightNumber": {
            "anyOf": [
              {
                "type": "string",
                "pattern": "^[A-Z0-9]{2,3}-?[0-9]{1,4}[A-Z]?$"
              },
              {
                "type": "null"
              }
            ]
          },
          "carrierCode": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 3
          },
          "originIata": {
            "anyOf": [
              {
                "type": "string",
                "pattern": "^[A-Z]{3}$"
              },
              {
                "type": "null"
              }
            ]
          },
          "destinationIata": {
            "anyOf": [
              {
                "type": "string",
                "pattern": "^[A-Z]{3}$"
              },
              {
                "type": "null"
              }
            ]
          },
          "scheduledArrivalAtMillis": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 0,
            "maximum": 253402300799999
          },
          "pickupPointId": {
            "type": [
              "string",
              "null"
            ],
            "minLength": 1,
            "maxLength": 180
          },
          "destinationHotelId": {
            "type": [
              "string",
              "null"
            ],
            "minLength": 1,
            "maxLength": 180
          },
          "destinationLabel": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 140
          },
          "passengers": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 1,
            "maximum": 200,
            "description": "Defaults to 1 when omitted."
          },
          "luggageUnits": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 0,
            "maximum": 500,
            "description": "Defaults to 0 when omitted."
          }
        }
      }
    }
  }
} as const;
