/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const createOrganizerFormAutomationCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/create_organizer_form_automation_response.schema.json",
  "title": "CreateOrganizerFormAutomationCallableResponse",
  "description": "Saved form automation projection.",
  "allOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "ruleId",
        "organizerId",
        "formId",
        "name",
        "enabled",
        "revision",
        "trigger",
        "condition",
        "actions",
        "updatedAtMillis"
      ],
      "properties": {
        "ruleId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
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
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "enabled": {
          "type": "boolean"
        },
        "revision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
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
              "webhookSecretConfigured",
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
              "webhookSecretConfigured": {
                "type": "boolean"
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
        "updatedAtMillis": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
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
    }
  ]
} as const;
