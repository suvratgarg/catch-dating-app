/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const transferEventAssistanceGroupCallablePayloadSchema: Record<string, unknown> = {
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
          "const": "transferGroup"
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
          "type": "object",
          "additionalProperties": false,
          "required": [
            "attendeeId",
            "episodeId",
            "expectedParticipationRevision",
            "expectedMembershipRevision",
            "decision"
          ],
          "properties": {
            "attendeeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "episodeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "expectedParticipationRevision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "expectedMembershipRevision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "decision": {
              "oneOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "groupId"
                  ],
                  "properties": {
                    "kind": {
                      "const": "place"
                    },
                    "groupId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    }
                  }
                },
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "from",
                    "to",
                    "receivingOperatorId",
                    "expiresAtMillis"
                  ],
                  "properties": {
                    "kind": {
                      "const": "propose"
                    },
                    "from": {
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
                    "to": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "receivingOperatorId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180
                    },
                    "expiresAtMillis": {
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
                    "kind",
                    "transferId"
                  ],
                  "properties": {
                    "kind": {
                      "const": "accept"
                    },
                    "transferId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    }
                  }
                },
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "transferId"
                  ],
                  "properties": {
                    "kind": {
                      "const": "reject"
                    },
                    "transferId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    }
                  }
                },
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "transferId"
                  ],
                  "properties": {
                    "kind": {
                      "const": "cancel"
                    },
                    "transferId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    }
                  }
                },
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind"
                  ],
                  "properties": {
                    "kind": {
                      "const": "leave"
                    }
                  }
                }
              ]
            }
          }
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
  "title": "TransferEventAssistanceGroupCallablePayload"
} as const;
