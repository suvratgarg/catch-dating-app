/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programDeliveryMessageDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/program_delivery_messages.schema.json",
  "title": "ProgramDeliveryMessageDocument",
  "description": "Private durable program delivery outbox. The immutable intent and bounded attempt history survive moment-run completion and delayed provider callbacks. Recipient endpoints are references; transport credentials and guest bearer grants belong to their own private stores.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "programDeliveryMessages",
  "x-firestore-path": "programDeliveryMessages/{messageId}",
  "x-document-id-field": "messageId",
  "x-owner": "trusted program delivery workers",
  "required": [
    "schemaVersion",
    "messageId",
    "revision",
    "intent",
    "lifecycle",
    "attempts",
    "deliveryConflict",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1,
      "x-catch-ownership": "server-only"
    },
    "messageId": {
      "type": "string",
      "pattern": "^outbox:[a-f0-9]{64}$",
      "x-catch-ownership": "server-only"
    },
    "revision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991,
      "x-catch-ownership": "server-only"
    },
    "intent": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "schemaVersion",
        "intentId",
        "revision",
        "context",
        "programId",
        "recipient",
        "workflow",
        "createdAt",
        "expiresAt",
        "permittedRoutes",
        "deliveryPolicy",
        "kind",
        "title",
        "body",
        "instructionRevision"
      ],
      "properties": {
        "schemaVersion": {
          "const": 1,
          "type": "integer"
        },
        "intentId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
        },
        "revision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 1000000
        },
        "context": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "mode",
            "programId",
            "organizerId"
          ],
          "properties": {
            "mode": {
              "type": "string",
              "const": "live"
            },
            "programId": {
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
        "programId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "recipient": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "recipientKey"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "enum": [
                "guest",
                "household",
                "staff"
              ]
            },
            "recipientKey": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000,
              "description": "Stable recipient identity inside the program (guest id, household id, or staff uid). Endpoint resolution lives in the facts reader, never in the intent."
            }
          }
        },
        "workflow": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "momentId",
            "runId"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "programMoment"
            },
            "momentId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "runId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000,
              "description": "Moment-run occurrence identity. Phase 3 refines this into an explicit occurrence key once anchor revisions exist."
            }
          }
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
        "permittedRoutes": {
          "type": "array",
          "minItems": 1,
          "maxItems": 3,
          "items": {
            "type": "string",
            "enum": [
              "organizerProgramWhatsapp",
              "catchProgramActivity"
            ]
          }
        },
        "deliveryPolicy": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "maxAttempts",
            "maxAttemptsPerRoute",
            "minimumRetrySeconds"
          ],
          "properties": {
            "maxAttempts": {
              "type": "integer",
              "minimum": 1,
              "maximum": 6
            },
            "maxAttemptsPerRoute": {
              "type": "integer",
              "minimum": 1,
              "maximum": 6
            },
            "minimumRetrySeconds": {
              "type": "integer",
              "minimum": 0,
              "maximum": 86400
            }
          }
        },
        "kind": {
          "type": "string",
          "const": "programReminder"
        },
        "title": {
          "type": "string",
          "minLength": 1,
          "maxLength": 2000
        },
        "body": {
          "type": "string",
          "minLength": 1,
          "maxLength": 8000
        },
        "instructionRevision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991,
          "description": "The program/moment fact revision this intent was issued under. Reservation authority expires with it."
        },
        "whatsapp": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "connectionId",
            "templateId",
            "variables"
          ],
          "properties": {
            "connectionId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
            },
            "templateId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
            },
            "variables": {
              "type": "object",
              "maxProperties": 20,
              "additionalProperties": {
                "type": "string",
                "maxLength": 1000
              }
            }
          },
          "description": "Approved WhatsApp template content for organizerProgramWhatsapp routes. Frozen at intent time; sender credentials never appear here."
        }
      },
      "x-catch-ownership": "server-only"
    },
    "lifecycle": {
      "type": "string",
      "enum": [
        "active",
        "cancelled",
        "superseded",
        "responded"
      ],
      "x-catch-ownership": "server-only"
    },
    "attempts": {
      "type": "array",
      "maxItems": 6,
      "items": {
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
                    "type": "string",
                    "enum": [
                      "accepted",
                      "delivered",
                      "read"
                    ]
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
                      "policy",
                      "suppressed",
                      "invalidRecipient"
                    ]
                  },
                  "evidenceId": {
                    "anyOf": [
                      {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 2000
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
                  "evidenceId": {
                    "anyOf": [
                      {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 2000
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
                      "responded",
                      "expired",
                      "permissionRevoked",
                      "reservationExpired",
                      "permitExpired",
                      "programEnded",
                      "rsvpChanged",
                      "recipientWithdrawn"
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
              "programId",
              "organizerId"
            ],
            "properties": {
              "mode": {
                "type": "string",
                "const": "live"
              },
              "programId": {
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
                    "const": "organizerProgramWhatsapp",
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
                      "meta",
                      "gupshup",
                      "twilio"
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
                    "const": "catchProgramActivity",
                    "type": "string"
                  },
                  "transport": {
                    "const": "catchApp",
                    "type": "string"
                  },
                  "senderIdentity": {
                    "const": "catchPlatform",
                    "type": "string"
                  },
                  "provider": {
                    "type": "string",
                    "enum": [
                      "catchActivity",
                      "fcm"
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
                      "catch"
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
      "x-catch-ownership": "server-only"
    },
    "deliveryConflict": {
      "type": "boolean",
      "x-catch-ownership": "server-only"
    },
    "createdAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991,
      "x-catch-ownership": "server-only"
    },
    "updatedAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991,
      "x-catch-ownership": "server-only"
    }
  }
} as const;
