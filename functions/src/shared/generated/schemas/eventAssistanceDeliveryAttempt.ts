/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceDeliveryAttemptSchema: Record<string, unknown> = {
  "oneOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "schemaVersion",
        "attemptId",
        "intentId",
        "intentRevision",
        "ordinal",
        "createdAt",
        "state",
        "mode",
        "context",
        "binding",
        "authorization"
      ],
      "properties": {
        "schemaVersion": {
          "const": 1,
          "type": "integer"
        },
        "attemptId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
        },
        "intentId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
        },
        "intentRevision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 1000000
        },
        "ordinal": {
          "type": "integer",
          "minimum": 1,
          "maximum": 6
        },
        "createdAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "state": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "at",
                "reconcileAfter"
              ],
              "properties": {
                "kind": {
                  "const": "reserved",
                  "type": "string"
                },
                "at": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "reconcileAfter": {
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
                "at",
                "providerMessageId",
                "reason",
                "reconcileAfter"
              ],
              "properties": {
                "kind": {
                  "const": "unknown",
                  "type": "string"
                },
                "at": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "providerMessageId": {
                  "anyOf": [
                    {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 512
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "timeout",
                    "connectionLost",
                    "workerInterrupted"
                  ]
                },
                "reconcileAfter": {
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
                "at",
                "providerMessageId"
              ],
              "properties": {
                "kind": {
                  "const": "accepted",
                  "type": "string"
                },
                "at": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "providerMessageId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 512
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "at",
                "providerMessageId"
              ],
              "properties": {
                "kind": {
                  "const": "delivered",
                  "type": "string"
                },
                "at": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "providerMessageId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 512
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "at",
                "providerMessageId"
              ],
              "properties": {
                "kind": {
                  "const": "read",
                  "type": "string"
                },
                "at": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "providerMessageId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 512
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "at",
                "providerMessageId",
                "classification",
                "evidenceId"
              ],
              "properties": {
                "kind": {
                  "const": "failed",
                  "type": "string"
                },
                "at": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "providerMessageId": {
                  "anyOf": [
                    {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 512
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "classification": {
                  "type": "string",
                  "enum": [
                    "technical",
                    "invalidRecipient",
                    "policy",
                    "suppressed"
                  ]
                },
                "evidenceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "at",
                "providerMessageId",
                "evidenceId"
              ],
              "properties": {
                "kind": {
                  "const": "revoked",
                  "type": "string"
                },
                "at": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "providerMessageId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 512
                },
                "evidenceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "at",
                "reason"
              ],
              "properties": {
                "kind": {
                  "const": "notDispatched",
                  "type": "string"
                },
                "at": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "superseded",
                    "eventClosed",
                    "responded",
                    "expired",
                    "permissionRevoked",
                    "hostStopped"
                  ]
                }
              }
            }
          ]
        },
        "mode": {
          "const": "live",
          "type": "string"
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
        "binding": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "routeId",
                "transport",
                "senderIdentity",
                "provider",
                "senderId",
                "bindingRevision",
                "recipientEndpointId",
                "fallbackOwner"
              ],
              "properties": {
                "routeId": {
                  "const": "catchEventSms",
                  "type": "string"
                },
                "transport": {
                  "const": "sms",
                  "type": "string"
                },
                "senderIdentity": {
                  "const": "catchPlatform",
                  "type": "string"
                },
                "provider": {
                  "type": "string",
                  "enum": [
                    "sinch",
                    "gupshup"
                  ]
                },
                "senderId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "bindingRevision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 9007199254740991
                },
                "recipientEndpointId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "fallbackOwner": {
                  "type": "string",
                  "enum": [
                    "catch",
                    "provider"
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "routeId",
                "transport",
                "senderIdentity",
                "provider",
                "senderId",
                "bindingRevision",
                "recipientEndpointId",
                "fallbackOwner"
              ],
              "properties": {
                "routeId": {
                  "const": "catchEventRcs",
                  "type": "string"
                },
                "transport": {
                  "const": "rcs",
                  "type": "string"
                },
                "senderIdentity": {
                  "const": "catchPlatform",
                  "type": "string"
                },
                "provider": {
                  "type": "string",
                  "enum": [
                    "sinch",
                    "gupshup"
                  ]
                },
                "senderId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "bindingRevision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 9007199254740991
                },
                "recipientEndpointId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "fallbackOwner": {
                  "type": "string",
                  "enum": [
                    "catch",
                    "provider"
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "routeId",
                "transport",
                "senderIdentity",
                "provider",
                "senderId",
                "bindingRevision",
                "recipientEndpointId",
                "fallbackOwner"
              ],
              "properties": {
                "routeId": {
                  "const": "organizerEventWhatsapp",
                  "type": "string"
                },
                "transport": {
                  "const": "whatsapp",
                  "type": "string"
                },
                "senderIdentity": {
                  "const": "organizerManaged",
                  "type": "string"
                },
                "provider": {
                  "type": "string",
                  "enum": [
                    "meta"
                  ]
                },
                "senderId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "bindingRevision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 9007199254740991
                },
                "recipientEndpointId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "fallbackOwner": {
                  "type": "string",
                  "enum": [
                    "catch",
                    "provider"
                  ]
                }
              }
            }
          ]
        },
        "authorization": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "permissionRevision",
            "checkedAt",
            "validUntil",
            "instructionRevision"
          ],
          "properties": {
            "permissionRevision": {
              "type": "string",
              "minLength": 1,
              "maxLength": 512
            },
            "checkedAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "validUntil": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "instructionRevision": {
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
        "schemaVersion",
        "attemptId",
        "intentId",
        "intentRevision",
        "ordinal",
        "createdAt",
        "state",
        "mode",
        "context",
        "routeId",
        "authorization"
      ],
      "properties": {
        "schemaVersion": {
          "const": 1,
          "type": "integer"
        },
        "attemptId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
        },
        "intentId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
        },
        "intentRevision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 1000000
        },
        "ordinal": {
          "type": "integer",
          "minimum": 1,
          "maximum": 6
        },
        "createdAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "state": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "at",
                "reconcileAfter"
              ],
              "properties": {
                "kind": {
                  "const": "reserved",
                  "type": "string"
                },
                "at": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "reconcileAfter": {
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
                "at",
                "providerMessageId",
                "reason",
                "reconcileAfter"
              ],
              "properties": {
                "kind": {
                  "const": "unknown",
                  "type": "string"
                },
                "at": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "providerMessageId": {
                  "anyOf": [
                    {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 512
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "timeout",
                    "connectionLost",
                    "workerInterrupted"
                  ]
                },
                "reconcileAfter": {
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
                "at",
                "providerMessageId"
              ],
              "properties": {
                "kind": {
                  "const": "accepted",
                  "type": "string"
                },
                "at": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "providerMessageId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 512
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "at",
                "providerMessageId"
              ],
              "properties": {
                "kind": {
                  "const": "delivered",
                  "type": "string"
                },
                "at": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "providerMessageId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 512
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "at",
                "providerMessageId"
              ],
              "properties": {
                "kind": {
                  "const": "read",
                  "type": "string"
                },
                "at": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "providerMessageId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 512
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "at",
                "providerMessageId",
                "classification",
                "evidenceId"
              ],
              "properties": {
                "kind": {
                  "const": "failed",
                  "type": "string"
                },
                "at": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "providerMessageId": {
                  "anyOf": [
                    {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 512
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "classification": {
                  "type": "string",
                  "enum": [
                    "technical",
                    "invalidRecipient",
                    "policy",
                    "suppressed"
                  ]
                },
                "evidenceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "at",
                "providerMessageId",
                "evidenceId"
              ],
              "properties": {
                "kind": {
                  "const": "revoked",
                  "type": "string"
                },
                "at": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "providerMessageId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 512
                },
                "evidenceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "at",
                "reason"
              ],
              "properties": {
                "kind": {
                  "const": "notDispatched",
                  "type": "string"
                },
                "at": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "reason": {
                  "type": "string",
                  "enum": [
                    "superseded",
                    "eventClosed",
                    "responded",
                    "expired",
                    "permissionRevoked",
                    "hostStopped"
                  ]
                }
              }
            }
          ]
        },
        "mode": {
          "const": "rehearsal",
          "type": "string"
        },
        "context": {
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
        },
        "routeId": {
          "type": "string",
          "enum": [
            "catchEventSms",
            "catchEventRcs",
            "organizerEventWhatsapp"
          ]
        },
        "authorization": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "permissionRevision",
            "checkedAt",
            "validUntil",
            "instructionRevision"
          ],
          "properties": {
            "permissionRevision": {
              "type": "string",
              "minLength": 1,
              "maxLength": 512
            },
            "checkedAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "validUntil": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "instructionRevision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            }
          }
        }
      }
    }
  ],
  "title": "EventAssistanceDeliveryAttempt"
} as const;
