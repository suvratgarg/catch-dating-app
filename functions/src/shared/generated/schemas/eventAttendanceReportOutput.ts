/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAttendanceReportCallableResponseSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "view"
  ],
  "properties": {
    "view": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "context",
        "serverTime",
        "sourceHash",
        "closure",
        "source",
        "coverage",
        "rosterCount",
        "counts",
        "members"
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
        "serverTime": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "sourceHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
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
        "source": {
          "const": "eventAttendees"
        },
        "coverage": {
          "enum": [
            "emptyRoster",
            "completeRoster"
          ]
        },
        "rosterCount": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000
        },
        "counts": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "attended",
            "recordedNoShow",
            "unresolved",
            "notExpected"
          ],
          "properties": {
            "attended": {
              "type": "integer",
              "minimum": 0,
              "maximum": 1000
            },
            "recordedNoShow": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "hostConfirmed",
                "guestDeclined"
              ],
              "properties": {
                "hostConfirmed": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 1000
                },
                "guestDeclined": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 1000
                }
              }
            },
            "unresolved": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "unreviewed",
                "cleared",
                "sourceChanged",
                "superseded"
              ],
              "properties": {
                "unreviewed": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 1000
                },
                "cleared": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 1000
                },
                "sourceChanged": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 1000
                },
                "superseded": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 1000
                }
              }
            },
            "notExpected": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "invited",
                "waitlisted",
                "cancelled",
                "eventCancelled"
              ],
              "properties": {
                "invited": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 1000
                },
                "waitlisted": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 1000
                },
                "cancelled": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 1000
                },
                "eventCancelled": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 1000
                }
              }
            }
          }
        },
        "members": {
          "type": "array",
          "maxItems": 1000,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "attendeeId",
              "classification"
            ],
            "properties": {
              "attendeeId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
              },
              "classification": {
                "oneOf": [
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "kind"
                    ],
                    "properties": {
                      "kind": {
                        "const": "attended"
                      }
                    }
                  },
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "kind",
                      "evidence"
                    ],
                    "properties": {
                      "kind": {
                        "const": "recordedNoShow"
                      },
                      "evidence": {
                        "enum": [
                          "hostConfirmed",
                          "guestDeclined"
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
                        "const": "unresolved"
                      },
                      "reason": {
                        "enum": [
                          "unreviewed",
                          "cleared",
                          "sourceChanged",
                          "superseded"
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
                        "const": "notExpected"
                      },
                      "reason": {
                        "enum": [
                          "invited",
                          "waitlisted",
                          "cancelled",
                          "eventCancelled"
                        ]
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  },
  "title": "EventAttendanceReportCallableResponse"
} as const;
