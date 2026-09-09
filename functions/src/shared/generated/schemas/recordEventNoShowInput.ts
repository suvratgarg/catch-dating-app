/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const recordEventNoShowCallablePayloadSchema: Record<string, unknown> = {
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
          "const": "recordNoShow"
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
            "expectedAttendanceRevision",
            "expectedDispositionRevision",
            "decision"
          ],
          "properties": {
            "attendeeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "expectedAttendanceRevision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "expectedDispositionRevision": {
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
                    "evidence"
                  ],
                  "properties": {
                    "kind": {
                      "const": "record"
                    },
                    "evidence": {
                      "oneOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind"
                          ],
                          "properties": {
                            "kind": {
                              "const": "hostConfirmed"
                            }
                          }
                        },
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "guestRevision",
                            "episodeId"
                          ],
                          "properties": {
                            "kind": {
                              "const": "guestDeclined"
                            },
                            "guestRevision": {
                              "type": "integer",
                              "minimum": 0,
                              "maximum": 9007199254740991
                            },
                            "episodeId": {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 160,
                              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                            }
                          }
                        }
                      ]
                    }
                  }
                },
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "reason"
                  ],
                  "properties": {
                    "kind": {
                      "const": "clear"
                    },
                    "reason": {
                      "enum": [
                        "recordingMistake",
                        "attendanceCorrected",
                        "noLongerApplicable"
                      ]
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
  "title": "RecordEventNoShowCallablePayload",
  "x-callable-aliases": [
    "recordEventNoShow"
  ]
} as const;
