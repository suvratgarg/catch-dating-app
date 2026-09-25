/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerMomentCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/organizer_moment_response.schema.json",
  "title": "OrganizerMomentCallableResponse",
  "description": "Single-moment response for upsert/arm/pause/resume.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "moment"
  ],
  "properties": {
    "moment": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "momentId",
        "scope",
        "name",
        "initiation",
        "sense",
        "audience",
        "action",
        "status",
        "approval",
        "origin",
        "revision"
      ],
      "properties": {
        "momentId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "scope": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "enum": [
                "event",
                "program"
              ]
            },
            "eventId": {
              "type": [
                "string",
                "null"
              ],
              "minLength": 1,
              "maxLength": 180,
              "description": "Required when kind=event; must be null otherwise."
            },
            "programId": {
              "type": [
                "string",
                "null"
              ],
              "minLength": 1,
              "maxLength": 180,
              "description": "Required when kind=program; must be null otherwise."
            }
          }
        },
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 140
        },
        "initiation": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "enum": [
                "manual",
                "scheduled",
                "anchored",
                "triggered"
              ]
            },
            "atMillis": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 0,
              "maximum": 9007199254740991,
              "description": "Scheduled fire time; required when kind=scheduled."
            },
            "anchorKind": {
              "anyOf": [
                {
                  "type": "string",
                  "enum": [
                    "scopeStart",
                    "scopeEnd",
                    "functionStart",
                    "functionEnd",
                    "rsvpDeadline",
                    "travelLegTime"
                  ]
                },
                {
                  "type": "null"
                }
              ],
              "description": "Required when kind=anchored."
            },
            "anchorId": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 180,
              "description": "Function/leg id for scoped anchors; null anchors to the scope itself."
            },
            "offsetMinutes": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": -43200,
              "maximum": 43200,
              "description": "Minutes relative to the anchor; negative is before."
            },
            "triggerKind": {
              "anyOf": [
                {
                  "type": "string",
                  "enum": [
                    "lateArrivalAtHotel",
                    "flightDisrupted"
                  ]
                },
                {
                  "type": "null"
                }
              ],
              "description": "Required when kind=triggered."
            },
            "functionId": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 180,
              "description": "Optional function scope for triggered moments."
            }
          }
        },
        "sense": {
          "type": "string",
          "enum": [
            "individual",
            "audience"
          ]
        },
        "audience": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "enum": [
                "subject",
                "eventParticipants",
                "functionGuests",
                "households",
                "staffDuty"
              ]
            },
            "statuses": {
              "type": [
                "array",
                "null"
              ],
              "maxItems": 4,
              "uniqueItems": true,
              "items": {
                "type": "string",
                "enum": [
                  "signedUp"
                ]
              },
              "description": "eventParticipants: participation statuses included."
            },
            "functionId": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 180,
              "description": "functionGuests: the function whose guests resolve."
            },
            "rsvp": {
              "type": [
                "array",
                "null"
              ],
              "maxItems": 4,
              "uniqueItems": true,
              "items": {
                "type": "string",
                "enum": [
                  "attending",
                  "maybe"
                ]
              },
              "description": "functionGuests: RSVP states included."
            },
            "householdDedupe": {
              "type": [
                "boolean",
                "null"
              ],
              "description": "functionGuests: one send per household when true (default)."
            },
            "rsvpPendingOnly": {
              "type": [
                "boolean",
                "null"
              ],
              "description": "households: restrict to households with a pending member."
            },
            "duty": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 80,
              "description": "staffDuty: duty whose grant holders resolve."
            },
            "scopeIds": {
              "type": [
                "array",
                "null"
              ],
              "maxItems": 50,
              "uniqueItems": true,
              "items": {
                "type": "string",
                "maxLength": 180
              },
              "description": "staffDuty: optional function/pickupPoint/hotel ids; null means all."
            }
          }
        },
        "action": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "enum": [
                "sendTemplate",
                "push",
                "staffAttention"
              ]
            },
            "connectionId": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 180,
              "description": "sendTemplate: organizerSenderConnections doc id."
            },
            "templateId": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 180,
              "description": "sendTemplate: organizerMessageTemplates doc id."
            },
            "variables": {
              "type": [
                "object",
                "null"
              ],
              "additionalProperties": {
                "type": "string",
                "maxLength": 1000
              },
              "description": "sendTemplate: template variable substitutions."
            },
            "notificationType": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 80,
              "description": "push: activity/push type written to the feed."
            },
            "preferenceKey": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 80,
              "description": "push: user notification preference gating FCM."
            },
            "duty": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 80,
              "description": "staffAttention: duty the attention item targets."
            },
            "severity": {
              "type": [
                "string",
                "null"
              ],
              "enum": [
                "info",
                "warning",
                "urgent",
                null
              ],
              "description": "staffAttention: attention severity."
            },
            "titleTemplate": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 200,
              "description": "staffAttention: rendered attention title."
            }
          }
        },
        "status": {
          "type": "string",
          "enum": [
            "draft",
            "armed",
            "paused",
            "done"
          ]
        },
        "approval": {
          "type": [
            "object",
            "null"
          ],
          "additionalProperties": false,
          "required": [
            "approvedByUid",
            "approvedAtMillis"
          ],
          "properties": {
            "approvedByUid": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "approvedAtMillis": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            }
          },
          "description": "Approve-the-rule-once record; required while armed."
        },
        "origin": {
          "type": "string",
          "enum": [
            "organizer",
            "systemDefault"
          ]
        },
        "revision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        }
      },
      "description": "The full moment definition returned by moment callables."
    }
  }
} as const;
