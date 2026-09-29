/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programStakeholderCountsCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/program_stakeholder_counts_response.schema.json",
  "title": "ProgramStakeholderCountsCallableResponse",
  "description": "Counts-only program overview for stakeholderViewer staff and organizer managers: guest and household headcounts, per-function RSVP/attendance histograms, and per-hotel occupancy. The contract carries no PII — ids and counts only, never names, contacts, or notes.",
  "type": "object",
  "additionalProperties": false,
  "x-callable-aliases": [
    "getProgramStakeholderCounts"
  ],
  "required": [
    "programId",
    "serverTimeMillis",
    "accessExpiresAtMillis",
    "guestCount",
    "householdCount",
    "functions",
    "hotels"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "serverTimeMillis": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "accessExpiresAtMillis": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 1,
      "maximum": 9007199254740991,
      "description": "Exclusive deadline for retaining this scoped projection. Earliest contributing duty expiry; null only for organizer managers. Refresh after expiry even if another narrower duty remains active."
    },
    "guestCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100000
    },
    "householdCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100000
    },
    "functions": {
      "type": "array",
      "maxItems": 500,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "functionId",
          "status",
          "invitedCount",
          "rsvpPending",
          "rsvpAttending",
          "rsvpDeclined",
          "rsvpMaybe",
          "expectedHeads",
          "checkedInHeads",
          "noShowCount"
        ],
        "properties": {
          "functionId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "status": {
            "type": "string",
            "enum": [
              "scheduled",
              "completed",
              "cancelled"
            ]
          },
          "invitedCount": {
            "type": "integer",
            "minimum": 0,
            "maximum": 100000,
            "description": "Guests invited to this function: every program guest for allGuests functions, else invited functionGuests rows."
          },
          "rsvpPending": {
            "type": "integer",
            "minimum": 0,
            "maximum": 100000,
            "description": "Invited guests with no response (or no join row yet on allGuests functions)."
          },
          "rsvpAttending": {
            "type": "integer",
            "minimum": 0,
            "maximum": 100000
          },
          "rsvpDeclined": {
            "type": "integer",
            "minimum": 0,
            "maximum": 100000
          },
          "rsvpMaybe": {
            "type": "integer",
            "minimum": 0,
            "maximum": 100000
          },
          "expectedHeads": {
            "type": "integer",
            "minimum": 0,
            "maximum": 100000,
            "description": "Sum of attending party sizes (null reads as 1)."
          },
          "checkedInHeads": {
            "type": "integer",
            "minimum": 0,
            "maximum": 100000,
            "description": "Heads marked checkedIn at the door."
          },
          "noShowCount": {
            "type": "integer",
            "minimum": 0,
            "maximum": 100000
          }
        }
      }
    },
    "hotels": {
      "type": "array",
      "maxItems": 500,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "hotelId",
          "routedGuestCount",
          "arrivedGuestCount",
          "legCount"
        ],
        "properties": {
          "hotelId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "routedGuestCount": {
            "type": "integer",
            "minimum": 0,
            "maximum": 100000,
            "description": "Distinct guests with at least one leg routed to this hotel."
          },
          "arrivedGuestCount": {
            "type": "integer",
            "minimum": 0,
            "maximum": 100000,
            "description": "Distinct routed guests whose hotel-bound leg already arrived."
          },
          "legCount": {
            "type": "integer",
            "minimum": 0,
            "maximum": 100000
          }
        }
      }
    }
  }
} as const;
