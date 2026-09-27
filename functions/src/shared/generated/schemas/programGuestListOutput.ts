/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programGuestListCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/program_guest_list_response.schema.json",
  "title": "ProgramGuestListCallableResponse",
  "description": "Manager/coordinator guest inventory with household labels. Contact fields are present because this surface requires the programCoordinator duty or organizer management.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "programId",
    "guests",
    "households",
    "functionGuests",
    "groups",
    "nextCursor"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "guests": {
      "type": "array",
      "maxItems": 200,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "guestId",
          "displayName",
          "householdId",
          "phoneE164",
          "email",
          "externalReference",
          "groupIds",
          "invitationStatus",
          "rsvpStatus",
          "revision"
        ],
        "properties": {
          "guestId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "displayName": {
            "type": "string",
            "minLength": 1,
            "maxLength": 140
          },
          "householdId": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 180
          },
          "phoneE164": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 20
          },
          "email": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 320
          },
          "externalReference": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 180
          },
          "groupIds": {
            "type": "array",
            "maxItems": 20,
            "items": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "description": "programGuestGroups ids this guest belongs to. Resolve labels via the groups array on this response."
          },
          "invitationStatus": {
            "type": "string",
            "enum": [
              "notInvited",
              "invited",
              "delivered",
              "responded"
            ]
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
          "revision": {
            "type": "integer",
            "minimum": 1
          }
        }
      }
    },
    "households": {
      "type": "array",
      "maxItems": 500,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "householdId",
          "label",
          "memberGuestIds",
          "revision"
        ],
        "properties": {
          "householdId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 140
          },
          "memberGuestIds": {
            "type": "array",
            "maxItems": 50,
            "items": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            }
          },
          "revision": {
            "type": "integer",
            "minimum": 1
          }
        }
      }
    },
    "functionGuests": {
      "type": "array",
      "maxItems": 4000,
      "description": "Per-function invitation/RSVP/attendance join rows covering the paged guests. Rows exist only where a programFunctionGuests document was written; an allGuests function with no row reads as implicitly invited and pending.",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "guestId",
          "functionId",
          "invited",
          "rsvpStatus",
          "attendanceStatus",
          "partySize"
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
          "invited": {
            "type": "boolean"
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
          "attendanceStatus": {
            "type": "string",
            "enum": [
              "expected",
              "checkedIn",
              "noShow"
            ],
            "description": "Door/arrival state for one guest at one function. expected is the default for invited guests; noShow is marked after the function ends."
          },
          "partySize": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 1,
            "maximum": 20
          }
        }
      }
    },
    "groups": {
      "type": "array",
      "maxItems": 500,
      "description": "programGuestGroups documents referenced by groupIds on the paged guests. Page-scoped like households; a group referenced but absent here is corrupt and surfaces as a reconciliation error.",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "groupId",
          "label",
          "dimension",
          "sortOrder",
          "memberCount",
          "revision"
        ],
        "properties": {
          "groupId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 140
          },
          "dimension": {
            "type": "string",
            "minLength": 1,
            "maxLength": 60
          },
          "sortOrder": {
            "type": "integer",
            "minimum": 0,
            "maximum": 10000
          },
          "memberCount": {
            "type": "integer",
            "minimum": 0
          },
          "revision": {
            "type": "integer",
            "minimum": 1
          }
        }
      }
    },
    "nextCursor": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 240
    }
  }
} as const;
