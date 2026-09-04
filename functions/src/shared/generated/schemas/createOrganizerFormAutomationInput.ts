/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createOrganizerFormAutomationCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_organizer_form_automation_payload.schema.json",
  "title": "CreateOrganizerFormAutomationCallablePayload",
  "description": "Creates or replaces an explicit form automation under an optimistic revision guard.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "formId",
    "ruleId",
    "requestId",
    "expectedRevision",
    "name",
    "enabled",
    "trigger",
    "condition",
    "actions"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "formId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "ruleId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "requestId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 128
    },
    "expectedRevision": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "enabled": {
      "type": "boolean"
    },
    "trigger": {
      "type": "string",
      "enum": [
        "responseSubmitted",
        "responseWithdrawn",
        "answerMatches",
        "applicationAccepted",
        "eventAttended"
      ]
    },
    "condition": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "questionId",
            "operator",
            "expectedValues"
          ],
          "properties": {
            "questionId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "operator": {
              "type": "string",
              "enum": [
                "equals",
                "notEquals",
                "contains",
                "notContains",
                "greaterThan",
                "lessThan",
                "answered",
                "notAnswered"
              ]
            },
            "expectedValues": {
              "type": "array",
              "maxItems": 20,
              "items": {
                "type": [
                  "string",
                  "number",
                  "boolean"
                ]
              }
            }
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "actions": {
      "type": "array",
      "minItems": 1,
      "maxItems": 10,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "actionId",
          "kind",
          "tagId",
          "eventId",
          "webhookUrl",
          "webhookSecret",
          "channel"
        ],
        "properties": {
          "actionId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "kind": {
            "type": "string",
            "enum": [
              "notifyTeam",
              "addOrganizerTag",
              "createCrmContact",
              "addApplicationQueue",
              "proposeEventAttendee",
              "signedWebhook",
              "campaignHandoff"
            ]
          },
          "tagId": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 80
          },
          "eventId": {
            "anyOf": [
              {
                "type": "string",
                "minLength": 1,
                "maxLength": 180
              },
              {
                "type": "null"
              }
            ]
          },
          "webhookUrl": {
            "type": [
              "string",
              "null"
            ],
            "format": "uri",
            "maxLength": 2000
          },
          "webhookSecret": {
            "type": [
              "string",
              "null"
            ],
            "minLength": 32,
            "maxLength": 128
          },
          "channel": {
            "type": [
              "string",
              "null"
            ],
            "enum": [
              null,
              "whatsapp",
              "email"
            ]
          },
          "campaignId": {
            "anyOf": [
              {
                "type": "string",
                "minLength": 1,
                "maxLength": 180
              },
              {
                "type": "null"
              }
            ]
          },
          "campaignRevision": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 1,
            "maximum": 9007199254740991
          }
        }
      }
    },
    "triggerEventId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "delayMinutes": {
      "type": "integer",
      "minimum": 0,
      "maximum": 10080
    }
  }
} as const;
