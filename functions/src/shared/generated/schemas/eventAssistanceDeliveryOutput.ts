/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceDeliveryCallableResponseSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "context",
    "serverTime",
    "outcome",
    "operationRevision",
    "view"
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
    "outcome": {
      "enum": [
        "applied",
        "replayed"
      ]
    },
    "operationRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "view": {
      "oneOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "messageId",
            "revision",
            "reviewHash",
            "createdAt",
            "expiresAt",
            "lifecycle",
            "deliveryStatus",
            "attempts",
            "coordination",
            "handling",
            "availability",
            "attendeeId",
            "actions",
            "purpose"
          ],
          "properties": {
            "messageId": {
              "type": "string",
              "pattern": "^outbox:[a-f0-9]{64}$"
            },
            "revision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "reviewHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "createdAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "expiresAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "lifecycle": {
              "enum": [
                "active",
                "cancelled",
                "superseded",
                "responded"
              ]
            },
            "deliveryStatus": {
              "enum": [
                "notSubmitted",
                "reserved",
                "unknown",
                "accepted",
                "delivered",
                "read",
                "failed",
                "notDispatched",
                "conflictingEvidence",
                "revoked"
              ]
            },
            "attempts": {
              "type": "array",
              "maxItems": 6,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "channel",
                  "state",
                  "at"
                ],
                "properties": {
                  "channel": {
                    "enum": [
                      "sms",
                      "whatsapp",
                      "rcs"
                    ]
                  },
                  "state": {
                    "enum": [
                      "reserved",
                      "unknown",
                      "accepted",
                      "delivered",
                      "read",
                      "failed",
                      "notDispatched",
                      "revoked"
                    ]
                  },
                  "at": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 9007199254740991
                  }
                }
              }
            },
            "coordination": {
              "oneOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind"
                  ],
                  "properties": {
                    "kind": {
                      "const": "untracked"
                    }
                  }
                },
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "phase",
                    "reason",
                    "dueAt"
                  ],
                  "properties": {
                    "kind": {
                      "const": "tracked"
                    },
                    "phase": {
                      "enum": [
                        "queued",
                        "retry",
                        "receipt",
                        "review",
                        "complete"
                      ]
                    },
                    "reason": {
                      "anyOf": [
                        {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 80
                        },
                        {
                          "type": "null"
                        }
                      ]
                    },
                    "dueAt": {
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
                    }
                  }
                }
              ]
            },
            "handling": {
              "oneOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind"
                  ],
                  "properties": {
                    "kind": {
                      "const": "automatic"
                    }
                  }
                },
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "actorUid",
                    "at",
                    "authority"
                  ],
                  "properties": {
                    "kind": {
                      "const": "manual"
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
                    },
                    "authority": {
                      "enum": [
                        "current",
                        "revoked"
                      ]
                    }
                  }
                }
              ]
            },
            "availability": {
              "const": "current"
            },
            "attendeeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "actions": {
              "type": "array",
              "maxItems": 1,
              "uniqueItems": true,
              "items": {
                "const": "manualHandoff"
              }
            },
            "purpose": {
              "enum": [
                "joiningUpdate",
                "joiningInstructions",
                "planChanged",
                "guestRequirement",
                "assignmentChanged",
                "participationCheck",
                "eventCancelled",
                "eventFinished",
                "followUp"
              ]
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "messageId",
            "revision",
            "reviewHash",
            "createdAt",
            "expiresAt",
            "lifecycle",
            "deliveryStatus",
            "attempts",
            "coordination",
            "handling",
            "availability",
            "attendeeId",
            "actions",
            "purpose"
          ],
          "properties": {
            "messageId": {
              "type": "string",
              "pattern": "^outbox:[a-f0-9]{64}$"
            },
            "revision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "reviewHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "createdAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "expiresAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "lifecycle": {
              "enum": [
                "active",
                "cancelled",
                "superseded",
                "responded"
              ]
            },
            "deliveryStatus": {
              "enum": [
                "notSubmitted",
                "reserved",
                "unknown",
                "accepted",
                "delivered",
                "read",
                "failed",
                "notDispatched",
                "conflictingEvidence",
                "revoked"
              ]
            },
            "attempts": {
              "type": "array",
              "maxItems": 6,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "channel",
                  "state",
                  "at"
                ],
                "properties": {
                  "channel": {
                    "enum": [
                      "sms",
                      "whatsapp",
                      "rcs"
                    ]
                  },
                  "state": {
                    "enum": [
                      "reserved",
                      "unknown",
                      "accepted",
                      "delivered",
                      "read",
                      "failed",
                      "notDispatched",
                      "revoked"
                    ]
                  },
                  "at": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 9007199254740991
                  }
                }
              }
            },
            "coordination": {
              "oneOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind"
                  ],
                  "properties": {
                    "kind": {
                      "const": "untracked"
                    }
                  }
                },
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "phase",
                    "reason",
                    "dueAt"
                  ],
                  "properties": {
                    "kind": {
                      "const": "tracked"
                    },
                    "phase": {
                      "enum": [
                        "queued",
                        "retry",
                        "receipt",
                        "review",
                        "complete"
                      ]
                    },
                    "reason": {
                      "anyOf": [
                        {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 80
                        },
                        {
                          "type": "null"
                        }
                      ]
                    },
                    "dueAt": {
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
                    }
                  }
                }
              ]
            },
            "handling": {
              "oneOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind"
                  ],
                  "properties": {
                    "kind": {
                      "const": "automatic"
                    }
                  }
                },
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "actorUid",
                    "at",
                    "authority"
                  ],
                  "properties": {
                    "kind": {
                      "const": "manual"
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
                    },
                    "authority": {
                      "enum": [
                        "current",
                        "revoked"
                      ]
                    }
                  }
                }
              ]
            },
            "availability": {
              "const": "sourceChanged"
            },
            "attendeeId": {
              "type": "null"
            },
            "actions": {
              "type": "array",
              "maxItems": 0,
              "items": {
                "const": "manualHandoff"
              }
            },
            "purpose": {
              "enum": [
                "joiningUpdate",
                "joiningInstructions",
                "planChanged",
                "guestRequirement",
                "assignmentChanged",
                "participationCheck",
                "eventCancelled",
                "eventFinished",
                "followUp"
              ]
            }
          }
        }
      ]
    }
  },
  "title": "EventAssistanceDeliveryCallableResponse"
} as const;
