/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const setEventAssistanceParticipationCallablePayloadSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "command",
    "expectedSourceHash"
  ],
  "properties": {
    "command": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "context",
        "eventId",
        "operationId",
        "payload"
      ],
      "properties": {
        "kind": {
          "type": "string",
          "const": "setParticipation"
        },
        "context": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode",
                "eventId",
                "organizerId"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "live"
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "organizerId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode",
                "rehearsalId",
                "virtualEventId",
                "clockId"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "const": "rehearsal"
                },
                "rehearsalId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "virtualEventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "clockId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                }
              }
            }
          ]
        },
        "eventId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "operationId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "payload": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "attendeeId",
                "state",
                "resumeAtUnit",
                "episodeId",
                "expectedParticipationRevision"
              ],
              "properties": {
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "state": {
                  "const": "active"
                },
                "resumeAtUnit": {
                  "type": "null"
                },
                "episodeId": {
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
                "expectedParticipationRevision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "attendeeId",
                "state",
                "resumeAtUnit",
                "episodeId",
                "expectedParticipationRevision"
              ],
              "properties": {
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "state": {
                  "const": "temporaryBreak"
                },
                "resumeAtUnit": {
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
                "episodeId": {
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
                "expectedParticipationRevision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "attendeeId",
                "state",
                "resumeAtUnit",
                "episodeId",
                "expectedParticipationRevision"
              ],
              "properties": {
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "state": {
                  "const": "departed"
                },
                "resumeAtUnit": {
                  "type": "null"
                },
                "episodeId": {
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
                "expectedParticipationRevision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                }
              }
            }
          ]
        }
      }
    },
    "expectedSourceHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    }
  },
  "allOf": [
    {
      "properties": {
        "command": {
          "properties": {
            "context": {
              "properties": {
                "mode": {
                  "const": "live"
                }
              }
            }
          }
        }
      }
    }
  ],
  "title": "SetEventAssistanceParticipationCallablePayload"
} as const;
