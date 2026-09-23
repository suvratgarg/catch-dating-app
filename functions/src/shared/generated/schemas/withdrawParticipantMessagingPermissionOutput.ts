/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const withdrawParticipantMessagingPermissionCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/withdraw_participant_messaging_permission_response.schema.json",
  "title": "WithdrawParticipantMessagingPermissionCallableResponse",
  "description": "Current permission after an idempotent withdrawal; later consent is never overwritten by an old retry.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "preference",
    "replayed"
  ],
  "properties": {
    "preference": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "status",
        "receiptId"
      ],
      "properties": {
        "status": {
          "type": "string",
          "enum": [
            "unknown",
            "optedIn",
            "optedOut"
          ]
        },
        "purposes": {
          "type": "object",
          "additionalProperties": false,
          "properties": {
            "eventOperations": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "status",
                "receiptId"
              ],
              "properties": {
                "status": {
                  "type": "string",
                  "enum": [
                    "unknown",
                    "optedIn",
                    "optedOut"
                  ]
                },
                "receiptId": {
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
                }
              }
            },
            "marketing": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "status",
                "receiptId"
              ],
              "properties": {
                "status": {
                  "type": "string",
                  "enum": [
                    "unknown",
                    "optedIn",
                    "optedOut"
                  ]
                },
                "receiptId": {
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
                }
              }
            }
          }
        },
        "receiptId": {
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
        }
      }
    },
    "replayed": {
      "type": "boolean"
    }
  }
} as const;
