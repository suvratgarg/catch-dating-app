/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceCheckpointReceiptDocumentSchema: Record<string, unknown> = {
  "oneOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "receiptId",
        "requestHash",
        "report"
      ],
      "properties": {
        "receiptId": {
          "type": "string",
          "pattern": "^checkpoint-action:[a-f0-9]{64}$"
        },
        "requestHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "report": {
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
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "receiptId",
        "requestHash",
        "scope",
        "rosterHash",
        "workItemRevision",
        "assignment"
      ],
      "properties": {
        "receiptId": {
          "type": "string",
          "pattern": "^checkpoint-reassignment:[a-f0-9]{64}$"
        },
        "requestHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "scope": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "context",
            "groupId",
            "checkpointId",
            "progressRevision"
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
            }
          }
        },
        "rosterHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "workItemRevision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "assignment": {
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
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "receiptId",
        "requestHash",
        "scope",
        "rosterHash",
        "workItemRevision",
        "closeout"
      ],
      "properties": {
        "receiptId": {
          "type": "string",
          "pattern": "^checkpoint-closeout:[a-f0-9]{64}$"
        },
        "requestHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "scope": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "context",
            "groupId",
            "checkpointId",
            "progressRevision"
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
            }
          }
        },
        "rosterHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "workItemRevision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "closeout": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "revision",
            "previousRevision",
            "receiptId",
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
            "receiptId": {
              "type": "string",
              "pattern": "^checkpoint-closeout:[a-f0-9]{64}$"
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
                    "dispositions": {
                      "type": "array",
                      "maxItems": 1000,
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
            }
          }
        }
      }
    }
  ],
  "title": "EventAssistanceCheckpointReceiptDocument",
  "x-firestore-collection": "eventAssistanceCheckpointReceipts",
  "x-firestore-path": "eventAssistanceCheckpointReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "event-assistance checkpoint command"
} as const;
