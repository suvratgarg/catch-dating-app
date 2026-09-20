/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventRehearsalMovementDocumentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "sessionId",
    "clockId",
    "groupId",
    "progressRevision",
    "departure",
    "report"
  ],
  "properties": {
    "sessionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "clockId": {
      "type": "string",
      "pattern": "^clock:[a-f0-9]{64}$"
    },
    "groupId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "progressRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 500
    },
    "departure": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "sourceHash",
        "destination",
        "confirmedAt",
        "confirmedBy",
        "operationId",
        "roster",
        "checkpointRequest"
      ],
      "properties": {
        "sourceHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "destination": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "placeId",
                "lateEntry"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "fixedPlace"
                },
                "placeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "lateEntry": {
                  "type": "string",
                  "enum": [
                    "allowed",
                    "hostDecision",
                    "closed"
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "itineraryId",
                "stopId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "itineraryStop"
                },
                "itineraryId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "stopId": {
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
                "kind",
                "routeId",
                "groupId",
                "checkpointId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "groupCheckpoint"
                },
                "routeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
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
                }
              }
            }
          ]
        },
        "confirmedAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "confirmedBy": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "operationId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "roster": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "members",
                "selectionHash"
              ],
              "properties": {
                "members": {
                  "type": "array",
                  "maxItems": 50,
                  "items": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "attendeeId",
                      "displayName",
                      "visitHash",
                      "episodeId",
                      "membershipHash"
                    ],
                    "properties": {
                      "attendeeId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 180
                      },
                      "displayName": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 180
                      },
                      "visitHash": {
                        "type": "string",
                        "pattern": "^[a-f0-9]{64}$"
                      },
                      "episodeId": {
                        "anyOf": [
                          {
                            "type": "string",
                            "pattern": "^episode:[a-f0-9]{64}$"
                          },
                          {
                            "type": "null"
                          }
                        ]
                      },
                      "membershipHash": {
                        "anyOf": [
                          {
                            "type": "string",
                            "pattern": "^[a-f0-9]{64}$"
                          },
                          {
                            "type": "null"
                          }
                        ]
                      }
                    }
                  }
                },
                "selectionHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                }
              }
            },
            {
              "type": "null"
            }
          ]
        },
        "checkpointRequest": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "responsibleOperatorId",
                "dueAt"
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
    "report": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "revision",
            "rosterHash",
            "accountedFor",
            "reportedAt",
            "reportedBy",
            "correctionReason"
          ],
          "properties": {
            "revision": {
              "type": "integer",
              "minimum": 1,
              "maximum": 9007199254740991
            },
            "rosterHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "accountedFor": {
              "type": "array",
              "maxItems": 50,
              "uniqueItems": true,
              "items": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180
              }
            },
            "reportedAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "reportedBy": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
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
            }
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "assignment": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "revision",
        "operationId",
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
        },
        "operationId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        }
      }
    },
    "closeout": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "revision",
        "previousRevision",
        "operationId",
        "changedBy",
        "changedAt",
        "reason",
        "decision"
      ],
      "properties": {
        "revision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "previousRevision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "changedBy": {
          "type": "string",
          "minLength": 1,
          "maxLength": 128,
          "pattern": "^[^/]+$"
        },
        "changedAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "reason": {
          "type": "string",
          "minLength": 1,
          "maxLength": 500,
          "pattern": "\\S"
        },
        "decision": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "report",
                "dispositions"
              ],
              "properties": {
                "kind": {
                  "const": "close"
                },
                "report": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "revision",
                    "rosterHash",
                    "accountedFor",
                    "reportedAt",
                    "reportedBy",
                    "correctionReason"
                  ],
                  "properties": {
                    "revision": {
                      "type": "integer",
                      "minimum": 1,
                      "maximum": 9007199254740991
                    },
                    "rosterHash": {
                      "type": "string",
                      "pattern": "^[a-f0-9]{64}$"
                    },
                    "accountedFor": {
                      "type": "array",
                      "maxItems": 50,
                      "uniqueItems": true,
                      "items": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 180
                      }
                    },
                    "reportedAt": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
                    },
                    "reportedBy": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180
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
                    }
                  }
                },
                "dispositions": {
                  "type": "array",
                  "maxItems": 50,
                  "items": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "kind",
                      "disposition",
                      "revision",
                      "resolvedAt",
                      "resolvedBy",
                      "sourceHash",
                      "attendeeId"
                    ],
                    "properties": {
                      "kind": {
                        "const": "resolved"
                      },
                      "disposition": {
                        "enum": [
                          "returned",
                          "departed"
                        ]
                      },
                      "revision": {
                        "type": "integer",
                        "minimum": 1,
                        "maximum": 9007199254740991
                      },
                      "resolvedAt": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 9007199254740991
                      },
                      "resolvedBy": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 128,
                        "pattern": "^[^/]+$"
                      },
                      "sourceHash": {
                        "type": "string",
                        "pattern": "^[a-f0-9]{64}$"
                      },
                      "attendeeId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 160,
                        "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
                "kind"
              ],
              "properties": {
                "kind": {
                  "const": "reopen"
                }
              }
            }
          ]
        },
        "operationId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        }
      }
    }
  },
  "title": "EventRehearsalMovementDocument",
  "description": "An immutable synthetic departure manifest with a separately revised checkpoint observation.",
  "x-firestore-collection": "eventRehearsalMovements",
  "x-firestore-path": "eventRehearsalMovements/{movementId}",
  "x-document-id-field": "id",
  "x-owner": "event rehearsal callables"
} as const;
