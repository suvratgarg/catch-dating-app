/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const submitEventRehearsalGuestActionCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/submit_event_rehearsal_guest_action_payload.schema.json",
  "title": "SubmitEventRehearsalGuestActionCallablePayload",
  "description": "Applies a bounded action from an anonymous rehearsal guest slot.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "publicRehearsalId",
    "slotToken",
    "clientActionId",
    "action"
  ],
  "properties": {
    "publicRehearsalId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{20,80}$"
    },
    "slotToken": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{20,180}$"
    },
    "clientActionId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{8,120}$"
    },
    "action": {
      "type": "string",
      "enum": [
        "checkIn",
        "confirmArrival",
        "optOut",
        "optIn",
        "askForHelp",
        "completePrompt",
        "submitRequiredData",
        "respondToAssistance"
      ]
    },
    "messageId": {
      "type": "string",
      "pattern": "^outbox:[a-f0-9]{64}$"
    },
    "intentRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000
    },
    "choiceId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160
    },
    "requiredData": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "fieldIds",
        "expectedProfileRevision",
        "expectedRequestRevision",
        "expectedSourceHash"
      ],
      "properties": {
        "fieldIds": {
          "type": "array",
          "uniqueItems": true,
          "minItems": 1,
          "maxItems": 10,
          "items": {
            "type": "string",
            "enum": [
              "displayName",
              "gender",
              "interestedInGenders",
              "relationshipGoal",
              "dateOfBirth",
              "paceBand",
              "skillBand",
              "dietaryAndSeatingNotes",
              "questionnaireAnswerIds",
              "teamName"
            ]
          }
        },
        "expectedProfileRevision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "expectedRequestRevision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "expectedSourceHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        }
      }
    }
  },
  "allOf": [
    {
      "if": {
        "properties": {
          "action": {
            "const": "respondToAssistance"
          }
        }
      },
      "then": {
        "required": [
          "messageId",
          "intentRevision",
          "choiceId"
        ],
        "not": {
          "required": [
            "requiredData"
          ]
        }
      },
      "else": {
        "not": {
          "anyOf": [
            {
              "required": [
                "messageId"
              ]
            },
            {
              "required": [
                "intentRevision"
              ]
            },
            {
              "required": [
                "choiceId"
              ]
            }
          ]
        }
      }
    },
    {
      "if": {
        "properties": {
          "action": {
            "const": "submitRequiredData"
          }
        }
      },
      "then": {
        "required": [
          "requiredData"
        ]
      },
      "else": {
        "not": {
          "required": [
            "requiredData"
          ]
        }
      }
    }
  ]
} as const;
