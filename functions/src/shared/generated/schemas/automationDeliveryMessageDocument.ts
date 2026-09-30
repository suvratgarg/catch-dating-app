/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const automationDeliveryMessageDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/automation_delivery_messages.schema.json",
  "title": "AutomationDeliveryMessageDocument",
  "description": "Private durable form-automation delivery outbox. The immutable intent and bounded attempt history survive dispatch interruption and delayed provider callbacks. The companion organizerMomentRuns row remains the organizer-visible journal; this record is the execution authority. Recipient endpoints are references; transport credentials stay in their own private stores.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "automationDeliveryMessages",
  "x-firestore-path": "automationDeliveryMessages/{messageId}",
  "x-document-id-field": "messageId",
  "x-owner": "trusted automation delivery workers",
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
      "type": "integer",
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
        "ruleId",
        "recipient",
        "workflow",
        "createdAt",
        "expiresAt",
        "permittedRoutes",
        "deliveryPolicy",
        "kind",
        "instructionRevision",
        "whatsapp"
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
            "organizerId",
            "ruleId",
            "ruleRevision",
            "actionId",
            "eventKind",
            "sourceId",
            "occurredAtMillis",
            "dueAtMillis",
            "contactId",
            "recipeCampaignId",
            "recipeRevision"
          ],
          "properties": {
            "mode": {
              "type": "string",
              "const": "live"
            },
            "organizerId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000
            },
            "ruleId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "ruleRevision": {
              "type": "integer",
              "minimum": 1,
              "maximum": 1000000,
              "description": "Approved rule revision the intent was authorized under. Claim re-reads the live rule; a changed revision stops the intent as superseded."
            },
            "actionId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "eventKind": {
              "type": "string",
              "enum": [
                "submitted",
                "withdrawn",
                "applicationAccepted",
                "eventAttended"
              ]
            },
            "sourceId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "occurredAtMillis": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991,
              "description": "Source-event occurrence time; part of the durable occurrence identity alongside ruleId/actionId/eventKind/sourceId."
            },
            "dueAtMillis": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991,
              "description": "The business delay horizon the automation engine computed (max(occurredAt, eventEndAt) + delayMinutes). Claim re-derives it from the live event and rule."
            },
            "contactId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$",
              "description": "Contact identity resolved from the source event at handoff. Claim re-derives the current identity from the live source event, so a merge follows the send to the surviving contact."
            },
            "recipeCampaignId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$",
              "description": "organizerCampaigns document id of the recipe the action pinned."
            },
            "recipeRevision": {
              "type": "integer",
              "minimum": 1,
              "maximum": 1000000
            }
          }
        },
        "ruleId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][a-zA-Z0-9._:-]*$"
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
                "organizerContact"
              ]
            },
            "recipientKey": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000,
              "description": "organizerContacts document id resolved at handoff. Endpoint and consent facts resolve at claim time, never in the intent."
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
              "const": "automationSend"
            },
            "momentId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$",
              "description": "The rule's server-managed companion moment."
            },
            "runId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$",
              "description": "The occurrence-keyed moment run journaling this send."
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
          "maxItems": 1,
          "items": {
            "type": "string",
            "enum": [
              "organizerWhatsappAutomation"
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
          "const": "automationMessage"
        },
        "instructionRevision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991,
          "description": "The companion moment's revision at handoff. Reservation authority expires when the synced rule projection changes."
        },
        "whatsapp": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "connectionId",
            "templateId",
            "variables",
            "eventId",
            "inviteLinkId"
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
            },
            "eventId": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                {
                  "type": "null"
                }
              ],
              "description": "Event destination pinned by the recipe; claim re-verifies the event is still active and owned."
            },
            "inviteLinkId": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                {
                  "type": "null"
                }
              ],
              "description": "Per-occurrence invitation link minted at handoff; claim re-reads its secret so a rotated or revoked link fails closed."
            }
          },
          "description": "Approved WhatsApp template content frozen at handoff, including the rendered invite variables; sender credentials never appear here."
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
                      "expired",
                      "permissionRevoked",
                      "reservationExpired",
                      "permitExpired",
                      "campaignEnded",
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
              "organizerId",
              "ruleId",
              "ruleRevision",
              "actionId",
              "eventKind",
              "sourceId",
              "occurredAtMillis",
              "dueAtMillis",
              "contactId",
              "recipeCampaignId",
              "recipeRevision"
            ],
            "properties": {
              "mode": {
                "type": "string",
                "const": "live"
              },
              "organizerId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 2000
              },
              "ruleId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
              },
              "ruleRevision": {
                "type": "integer",
                "minimum": 1,
                "maximum": 1000000,
                "description": "Approved rule revision the intent was authorized under. Claim re-reads the live rule; a changed revision stops the intent as superseded."
              },
              "actionId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
              },
              "eventKind": {
                "type": "string",
                "enum": [
                  "submitted",
                  "withdrawn",
                  "applicationAccepted",
                  "eventAttended"
                ]
              },
              "sourceId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
              },
              "occurredAtMillis": {
                "type": "integer",
                "minimum": 0,
                "maximum": 9007199254740991,
                "description": "Source-event occurrence time; part of the durable occurrence identity alongside ruleId/actionId/eventKind/sourceId."
              },
              "dueAtMillis": {
                "type": "integer",
                "minimum": 0,
                "maximum": 9007199254740991,
                "description": "The business delay horizon the automation engine computed (max(occurredAt, eventEndAt) + delayMinutes). Claim re-derives it from the live event and rule."
              },
              "contactId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$",
                "description": "Contact identity resolved from the source event at handoff. Claim re-derives the current identity from the live source event, so a merge follows the send to the surviving contact."
              },
              "recipeCampaignId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$",
                "description": "organizerCampaigns document id of the recipe the action pinned."
              },
              "recipeRevision": {
                "type": "integer",
                "minimum": 1,
                "maximum": 1000000
              }
            }
          },
          "binding": {
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
                "const": "organizerWhatsappAutomation",
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
                "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$",
                "description": "organizerSenderConnections document id that owns the send."
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
