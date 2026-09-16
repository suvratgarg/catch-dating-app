/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceParticipationCallableResponseSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "outcome",
    "operationRevision",
    "view"
  ],
  "properties": {
    "outcome": {
      "enum": [
        "read",
        "applied",
        "replayed"
      ]
    },
    "operationRevision": {
      "anyOf": [
        {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        {
          "type": "null"
        }
      ]
    },
    "view": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "context",
        "attendeeId",
        "serverTime",
        "sourceHash",
        "freshness",
        "revision",
        "episodeId",
        "participation",
        "canChange",
        "checkedIn",
        "resumeUnits"
      ],
      "properties": {
        "context": {
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
        "attendeeId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "serverTime": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "sourceHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "freshness": {
          "enum": [
            "uninitialized",
            "current",
            "sourceChanged"
          ]
        },
        "revision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
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
        "participation": {
          "anyOf": [
            {
              "oneOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "state",
                    "resumeAtUnit"
                  ],
                  "properties": {
                    "state": {
                      "const": "active"
                    },
                    "resumeAtUnit": {
                      "type": "null"
                    }
                  }
                },
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "state",
                    "resumeAtUnit"
                  ],
                  "properties": {
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
                    }
                  }
                },
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "state",
                    "resumeAtUnit"
                  ],
                  "properties": {
                    "state": {
                      "const": "departed"
                    },
                    "resumeAtUnit": {
                      "type": "null"
                    }
                  }
                }
              ]
            },
            {
              "type": "null"
            }
          ]
        },
        "canChange": {
          "type": "boolean"
        },
        "checkedIn": {
          "type": "boolean"
        },
        "resumeUnits": {
          "type": "array",
          "maxItems": 40,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "unitId",
              "label"
            ],
            "properties": {
              "unitId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
              },
              "label": {
                "type": "string",
                "minLength": 1,
                "maxLength": 240
              }
            }
          }
        }
      }
    }
  },
  "title": "EventAssistanceParticipationCallableResponse"
} as const;
