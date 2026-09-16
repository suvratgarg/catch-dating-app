/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventRehearsalCaseDocumentSchema: Record<string, unknown> = {
  "oneOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "caseId",
        "sessionId",
        "actorId",
        "clockId",
        "source",
        "category",
        "receivedAt",
        "status",
        "handling"
      ],
      "properties": {
        "caseId": {
          "type": "string",
          "pattern": "^practice-case:[a-f0-9]{64}$",
          "x-catch-ownership": "server-only"
        },
        "sessionId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "x-catch-ownership": "server-only"
        },
        "actorId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "x-catch-ownership": "server-only"
        },
        "clockId": {
          "type": "string",
          "pattern": "^clock:[a-f0-9]{64}$",
          "x-catch-ownership": "server-only"
        },
        "source": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "actionId"
              ],
              "properties": {
                "kind": {
                  "const": "guestAction"
                },
                "actionId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180,
                  "x-catch-ownership": "server-only"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "messageId",
                "responseId"
              ],
              "properties": {
                "kind": {
                  "const": "messageResponse"
                },
                "messageId": {
                  "type": "string",
                  "pattern": "^outbox:[a-f0-9]{64}$"
                },
                "responseId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180,
                  "x-catch-ownership": "server-only"
                }
              }
            }
          ],
          "x-catch-ownership": "server-only"
        },
        "category": {
          "enum": [
            "eventLogistics",
            "accessibility",
            "other"
          ],
          "x-catch-ownership": "server-only"
        },
        "receivedAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991,
          "x-catch-ownership": "server-only"
        },
        "status": {
          "const": "open",
          "x-catch-ownership": "server-only"
        },
        "handling": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "revision",
            "assigneeUid",
            "updatedAt",
            "resolution"
          ],
          "properties": {
            "revision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "assigneeUid": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                {
                  "type": "null"
                }
              ]
            },
            "updatedAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "resolution": {
              "type": "null"
            }
          },
          "x-catch-ownership": "server-only"
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "caseId",
        "sessionId",
        "actorId",
        "clockId",
        "source",
        "category",
        "receivedAt",
        "status",
        "handling"
      ],
      "properties": {
        "caseId": {
          "type": "string",
          "pattern": "^practice-case:[a-f0-9]{64}$",
          "x-catch-ownership": "server-only"
        },
        "sessionId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "x-catch-ownership": "server-only"
        },
        "actorId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "x-catch-ownership": "server-only"
        },
        "clockId": {
          "type": "string",
          "pattern": "^clock:[a-f0-9]{64}$",
          "x-catch-ownership": "server-only"
        },
        "source": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "actionId"
              ],
              "properties": {
                "kind": {
                  "const": "guestAction"
                },
                "actionId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180,
                  "x-catch-ownership": "server-only"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "messageId",
                "responseId"
              ],
              "properties": {
                "kind": {
                  "const": "messageResponse"
                },
                "messageId": {
                  "type": "string",
                  "pattern": "^outbox:[a-f0-9]{64}$"
                },
                "responseId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180,
                  "x-catch-ownership": "server-only"
                }
              }
            }
          ],
          "x-catch-ownership": "server-only"
        },
        "category": {
          "enum": [
            "eventLogistics",
            "accessibility",
            "other"
          ],
          "x-catch-ownership": "server-only"
        },
        "receivedAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991,
          "x-catch-ownership": "server-only"
        },
        "status": {
          "const": "resolved",
          "x-catch-ownership": "server-only"
        },
        "handling": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "revision",
            "assigneeUid",
            "updatedAt",
            "resolution"
          ],
          "properties": {
            "revision": {
              "type": "integer",
              "minimum": 1,
              "maximum": 9007199254740991
            },
            "assigneeUid": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                {
                  "type": "null"
                }
              ]
            },
            "updatedAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "resolution": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "outcome",
                "actorUid",
                "at"
              ],
              "properties": {
                "outcome": {
                  "enum": [
                    "resolved",
                    "declined"
                  ]
                },
                "actorUid": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "at": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                }
              }
            }
          },
          "x-catch-ownership": "server-only"
        }
      }
    }
  ],
  "title": "EventRehearsalCaseDocument",
  "description": "Synthetic practical help requests, retained until rehearsal reset or expiry. No live guest or safety case is written.",
  "x-firestore-collection": "eventRehearsalCases",
  "x-firestore-path": "eventRehearsalCases/{caseId}",
  "x-document-id-field": "caseId",
  "x-owner": "event rehearsal callables"
} as const;
