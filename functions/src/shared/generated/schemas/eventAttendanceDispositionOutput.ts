/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAttendanceDispositionCallableResponseSchema: Record<string, unknown> = {
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
          "minimum": 1,
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
        "displayName",
        "serverTime",
        "sourceHash",
        "attendance",
        "closure",
        "declineEvidence",
        "disposition",
        "recordability",
        "canClear"
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
        "displayName": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160
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
        "attendance": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "status",
            "checkedIn",
            "revision"
          ],
          "properties": {
            "status": {
              "enum": [
                "invited",
                "registered",
                "waitlisted",
                "checkedIn",
                "cancelled"
              ]
            },
            "checkedIn": {
              "type": "boolean"
            },
            "revision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            }
          }
        },
        "closure": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind"
              ],
              "properties": {
                "kind": {
                  "enum": [
                    "open",
                    "cancelled"
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "completedAt"
              ],
              "properties": {
                "kind": {
                  "const": "runtimeComplete"
                },
                "completedAt": {
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
                "endedAt"
              ],
              "properties": {
                "kind": {
                  "const": "scheduledEnd"
                },
                "endedAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                }
              }
            }
          ]
        },
        "declineEvidence": {
          "anyOf": [
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
            },
            {
              "type": "null"
            }
          ]
        },
        "disposition": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "revision"
              ],
              "properties": {
                "kind": {
                  "const": "unreviewed"
                },
                "revision": {
                  "const": 0
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "revision",
                "evidence",
                "actorUid",
                "recordedAt"
              ],
              "properties": {
                "kind": {
                  "const": "recorded"
                },
                "revision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 9007199254740991
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
                },
                "actorUid": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "recordedAt": {
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
                "revision",
                "reason",
                "actorUid",
                "recordedAt"
              ],
              "properties": {
                "kind": {
                  "const": "cleared"
                },
                "revision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 9007199254740991
                },
                "reason": {
                  "enum": [
                    "recordingMistake",
                    "attendanceCorrected",
                    "noLongerApplicable"
                  ]
                },
                "actorUid": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "recordedAt": {
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
                "revision"
              ],
              "properties": {
                "kind": {
                  "const": "sourceChanged"
                },
                "revision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 9007199254740991
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "revision",
                "reason"
              ],
              "properties": {
                "kind": {
                  "const": "superseded"
                },
                "revision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 9007199254740991
                },
                "reason": {
                  "enum": [
                    "attendanceChanged",
                    "eventChanged",
                    "guestIntentionChanged"
                  ]
                }
              }
            }
          ]
        },
        "recordability": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind"
              ],
              "properties": {
                "kind": {
                  "const": "allowed"
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
                  "const": "unavailable"
                },
                "reason": {
                  "enum": [
                    "eventNotFinished",
                    "eventCancelled",
                    "notAdmitted",
                    "alreadyAttended"
                  ]
                }
              }
            }
          ]
        },
        "canClear": {
          "type": "boolean"
        }
      }
    }
  },
  "title": "EventAttendanceDispositionCallableResponse"
} as const;
