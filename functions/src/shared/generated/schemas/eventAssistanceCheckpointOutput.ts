/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceCheckpointCallableResponseSchema: Record<string, unknown> = {
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
        "groupId",
        "checkpointId",
        "progressRevision",
        "serverTime",
        "sourceHash",
        "revision",
        "report",
        "availability",
        "request"
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
        "groupId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "checkpointId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 2000
        },
        "progressRevision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
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
        "revision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "report": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "schemaVersion",
                "reportId",
                "context",
                "groupId",
                "checkpointId",
                "progressRevision",
                "rosterId",
                "rosterHash",
                "revision",
                "accountedFor",
                "reportedBy",
                "reportedAt",
                "correctionReason",
                "createdAt"
              ],
              "properties": {
                "schemaVersion": {
                  "const": 1
                },
                "reportId": {
                  "type": "string",
                  "pattern": "^checkpoint:[a-f0-9]{64}$"
                },
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
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "checkpointId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "progressRevision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 9007199254740991
                },
                "rosterId": {
                  "type": "string",
                  "pattern": "^departure-roster:[a-f0-9]{64}$"
                },
                "rosterHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                },
                "revision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 9007199254740991
                },
                "accountedFor": {
                  "type": "array",
                  "items": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 160,
                    "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                  },
                  "uniqueItems": true,
                  "maxItems": 1000
                },
                "reportedBy": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "reportedAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "correctionReason": {
                  "anyOf": [
                    {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 500,
                      "pattern": "\\S"
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "createdAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                }
              }
            },
            {
              "type": "null"
            }
          ]
        },
        "availability": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "rosterId",
                "label",
                "reportStatus",
                "members"
              ],
              "properties": {
                "kind": {
                  "const": "ready"
                },
                "rosterId": {
                  "type": "string",
                  "pattern": "^departure-roster:[a-f0-9]{64}$"
                },
                "label": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 240
                },
                "reportStatus": {
                  "enum": [
                    "unreported",
                    "partial",
                    "complete"
                  ]
                },
                "members": {
                  "type": "array",
                  "maxItems": 1000,
                  "items": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "attendeeId",
                      "observation",
                      "visit"
                    ],
                    "properties": {
                      "attendeeId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 160,
                        "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                      },
                      "observation": {
                        "enum": [
                          "accountedFor",
                          "unconfirmed"
                        ]
                      },
                      "visit": {
                        "oneOf": [
                          {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "kind"
                            ],
                            "properties": {
                              "kind": {
                                "const": "current"
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
                                  "registrationMissing",
                                  "visitChanged",
                                  "notCheckedIn",
                                  "invalidSource"
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
                    "rosterNotRecorded",
                    "destinationNotRecorded",
                    "differentCheckpoint",
                    "notCheckpoint",
                    "setupChanged"
                  ]
                }
              }
            }
          ]
        },
        "request": {
          "anyOf": [
            {
              "oneOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "responsibleOperatorId",
                    "dueAt",
                    "state",
                    "ownerAvailability"
                  ],
                  "properties": {
                    "responsibleOperatorId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 128,
                      "pattern": "^[^/]+$"
                    },
                    "dueAt": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
                    },
                    "state": {
                      "enum": [
                        "awaitingReport",
                        "overdue",
                        "discrepancy",
                        "sourceUnavailable"
                      ]
                    },
                    "ownerAvailability": {
                      "enum": [
                        "current",
                        "needsReassignment"
                      ]
                    }
                  }
                },
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "responsibleOperatorId",
                    "dueAt",
                    "state",
                    "ownerAvailability"
                  ],
                  "properties": {
                    "responsibleOperatorId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 128,
                      "pattern": "^[^/]+$"
                    },
                    "dueAt": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
                    },
                    "state": {
                      "const": "complete"
                    },
                    "ownerAvailability": {
                      "const": "notRequired"
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
        "assignment": {
          "description": "Present in current responses; null when no durable checkpoint request exists. Independent of the report revision.",
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "revision",
                "sourceHash",
                "change"
              ],
              "properties": {
                "revision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "sourceHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                },
                "change": {
                  "anyOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "revision",
                        "receiptId",
                        "responsibleOperatorId",
                        "previousResponsibleOperatorId",
                        "assignedBy",
                        "assignedAt",
                        "reason"
                      ],
                      "properties": {
                        "revision": {
                          "type": "integer",
                          "minimum": 1,
                          "maximum": 9007199254740991
                        },
                        "receiptId": {
                          "type": "string",
                          "pattern": "^checkpoint-reassignment:[a-f0-9]{64}$"
                        },
                        "responsibleOperatorId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 128,
                          "pattern": "^[^/]+$"
                        },
                        "previousResponsibleOperatorId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 128,
                          "pattern": "^[^/]+$"
                        },
                        "assignedBy": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 128,
                          "pattern": "^[^/]+$"
                        },
                        "assignedAt": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 9007199254740991
                        },
                        "reason": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 500,
                          "pattern": "\\S"
                        }
                      }
                    },
                    {
                      "type": "null"
                    }
                  ]
                }
              }
            },
            {
              "type": "null"
            }
          ]
        }
      }
    }
  },
  "title": "EventAssistanceCheckpointCallableResponse"
} as const;
