/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listMyHostAssignmentsCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/list_my_host_assignments_response.schema.json",
  "title": "ListMyHostAssignmentsCallableResponse",
  "description": "The caller's host work assignments with server-resolved shell destinations. Assignments sort by scope kind (event before program) then scope id.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "assignments",
    "shellEntry"
  ],
  "properties": {
    "assignments": {
      "type": "array",
      "maxItems": 128,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "kind",
          "scopeId",
          "organizerId",
          "title",
          "subtitle",
          "organizerName",
          "duties",
          "destinations",
          "overflowDestinations",
          "shellMode",
          "grantExpiresAtMillis"
        ],
        "properties": {
          "kind": {
            "type": "string",
            "enum": [
              "event",
              "program"
            ]
          },
          "scopeId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180,
            "description": "The eventId or programId this assignment scopes to."
          },
          "organizerId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "title": {
            "type": "string",
            "minLength": 1,
            "maxLength": 140
          },
          "subtitle": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 140
          },
          "organizerName": {
            "type": "string",
            "minLength": 1,
            "maxLength": 140
          },
          "duties": {
            "type": "array",
            "items": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "duty"
              ],
              "properties": {
                "duty": {
                  "type": "string",
                  "enum": [
                    "programCoordinator",
                    "guestRelations",
                    "communications",
                    "functionCheckIn",
                    "functionLead",
                    "airportGreeter",
                    "transportDispatcher",
                    "hotelDesk",
                    "reconciliationViewer",
                    "stakeholderViewer",
                    "eventLead"
                  ],
                  "description": "Canonical duty across event and program scopes. checkInOperator event grants map to functionCheckIn; eventOperator grants map to eventLead."
                },
                "pickupPointIds": {
                  "type": "array",
                  "maxItems": 32,
                  "items": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "description": "Station scope for airportGreeter/transportDispatcher duties."
                },
                "hotelIds": {
                  "type": "array",
                  "maxItems": 64,
                  "items": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "description": "Hotel scope for hotelDesk duties."
                },
                "functionIds": {
                  "type": "array",
                  "maxItems": 64,
                  "items": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "description": "Function scope for functionCheckIn/functionLead duties."
                }
              }
            }
          },
          "destinations": {
            "type": "array",
            "items": {
              "type": "string",
              "enum": [
                "arrivals",
                "dispatch",
                "inbound",
                "rooms",
                "nowNext",
                "door",
                "walkIns",
                "attention",
                "guests",
                "rsvpInbox",
                "imports",
                "inbox",
                "moments",
                "trips",
                "exceptions",
                "export",
                "overview"
              ],
              "description": "A restricted work-shell destination in canonical bottom-bar order. The server resolves the set from granted duties."
            },
            "description": "Resolved destinations in canonical order; the shell renders the first three plus an overflow entry."
          },
          "overflowDestinations": {
            "type": "array",
            "items": {
              "type": "string",
              "enum": [
                "arrivals",
                "dispatch",
                "inbound",
                "rooms",
                "nowNext",
                "door",
                "walkIns",
                "attention",
                "guests",
                "rsvpInbox",
                "imports",
                "inbox",
                "moments",
                "trips",
                "exceptions",
                "export",
                "overview"
              ],
              "description": "A restricted work-shell destination in canonical bottom-bar order. The server resolves the set from granted duties."
            },
            "description": "Destinations beyond the first three, for the overflow menu."
          },
          "shellMode": {
            "type": "string",
            "enum": [
              "task",
              "tabs",
              "programWorkspace",
              "none"
            ],
            "description": "task = single destination, no bar; tabs = two or three destinations in the bar; programWorkspace = program-locked coordinator workspace; none = no reachable destination."
          },
          "grantExpiresAtMillis": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 0
          }
        },
        "description": "One staff assignment resolved server-side: the grant's canonical duties plus the derived shell destination set. Only live, unexpired grants are returned."
      }
    },
    "shellEntry": {
      "type": "string",
      "enum": [
        "managerShell",
        "workShell",
        "none"
      ],
      "description": "The app shell the caller should land in: managers always get managerShell even when they also hold staff assignments; staff get workShell only while at least one assignment is live."
    }
  }
} as const;
