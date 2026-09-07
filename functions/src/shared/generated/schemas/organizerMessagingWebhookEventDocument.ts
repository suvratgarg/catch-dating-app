/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerMessagingWebhookEventDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_messaging_webhook_events.schema.json",
  "title": "OrganizerMessagingWebhookEventDocument",
  "description": "Sanitized durable provider event queued after signature verification. Text and native reply labels follow the existing 30-day queue and 12-month Inbox retention. Native reply identifiers and provider correlation remain in the private queue and never authorize an action by themselves. Optional fields preserve compatibility with previously queued events.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerMessagingWebhookEvents",
  "x-firestore-path": "organizerMessagingWebhookEvents/{eventId}",
  "x-document-id-field": "eventId",
  "x-owner": "WhatsApp webhook ingress and receipt processor",
  "required": [
    "provider",
    "providerEventId",
    "organizerId",
    "connectionId",
    "eventKind",
    "providerMessageId",
    "contextProviderMessageId",
    "deliveryStatus",
    "endpointHash",
    "isStop",
    "hasReply",
    "inboundBody",
    "providerErrorCode",
    "providerOccurredAt",
    "processingStatus",
    "attemptCount",
    "createdAt",
    "processedAt",
    "expiresAt"
  ],
  "properties": {
    "provider": {
      "const": "metaCloudApi"
    },
    "providerEventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "organizerId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "connectionId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "eventKind": {
      "type": "string",
      "enum": [
        "status",
        "inbound",
        "template",
        "quality",
        "account",
        "unmatched"
      ]
    },
    "providerMessageId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 240
    },
    "contextProviderMessageId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 240
    },
    "providerAccountId": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[0-9]{1,32}$"
    },
    "providerPhoneNumberId": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[0-9]{1,32}$"
    },
    "callbackData": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 512
    },
    "inboundReply": {
      "oneOf": [
        {
          "type": "null"
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "payload",
            "label"
          ],
          "properties": {
            "kind": {
              "const": "templateQuickReply"
            },
            "payload": {
              "type": "string",
              "minLength": 1,
              "maxLength": 1024
            },
            "label": {
              "type": "string",
              "minLength": 1,
              "maxLength": 1024
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "id",
            "label"
          ],
          "properties": {
            "kind": {
              "const": "replyButton"
            },
            "id": {
              "type": "string",
              "minLength": 1,
              "maxLength": 1024
            },
            "label": {
              "type": "string",
              "minLength": 1,
              "maxLength": 1024
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "id",
            "label",
            "description"
          ],
          "properties": {
            "kind": {
              "const": "listReply"
            },
            "id": {
              "type": "string",
              "minLength": 1,
              "maxLength": 1024
            },
            "label": {
              "type": "string",
              "minLength": 1,
              "maxLength": 1024
            },
            "description": {
              "type": [
                "string",
                "null"
              ],
              "minLength": 1,
              "maxLength": 4096
            }
          }
        }
      ]
    },
    "deliveryStatus": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        null,
        "sent",
        "delivered",
        "read",
        "failed"
      ]
    },
    "endpointHash": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[a-f0-9]{64}$"
    },
    "isStop": {
      "type": "boolean"
    },
    "hasReply": {
      "type": "boolean"
    },
    "inboundBody": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 4096
    },
    "providerErrorCode": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0,
      "maximum": 999999999
    },
    "providerOccurredAt": {
      "anyOf": [
        {
          "type": "object",
          "description": "Serialized Firestore Timestamp fixture shape.",
          "x-firestore-type": "timestamp",
          "additionalProperties": false,
          "required": [
            "_seconds",
            "_nanoseconds"
          ],
          "properties": {
            "_seconds": {
              "type": "integer"
            },
            "_nanoseconds": {
              "type": "integer",
              "minimum": 0,
              "maximum": 999999999
            }
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "assistanceProcessing": {
      "type": "object",
      "additionalProperties": false,
      "description": "Event Assistance consumer checkpoint, independent from campaign and Inbox processing. Waiting outcomes retry; other outcomes are terminal for this signed event.",
      "required": [
        "sourceHash",
        "attemptCount",
        "updatedAt",
        "outcome"
      ],
      "properties": {
        "sourceHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "attemptCount": {
          "type": "integer",
          "minimum": 1,
          "maximum": 1000000
        },
        "updatedAt": {
          "type": "object",
          "description": "Serialized Firestore Timestamp fixture shape.",
          "x-firestore-type": "timestamp",
          "additionalProperties": false,
          "required": [
            "_seconds",
            "_nanoseconds"
          ],
          "properties": {
            "_seconds": {
              "type": "integer"
            },
            "_nanoseconds": {
              "type": "integer",
              "minimum": 0,
              "maximum": 999999999
            }
          }
        },
        "outcome": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "disposition"
              ],
              "properties": {
                "kind": {
                  "const": "delivery"
                },
                "disposition": {
                  "enum": [
                    "applied",
                    "duplicateOrOlder",
                    "conflictingEvidence",
                    "unconfirmed"
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "disposition"
              ],
              "properties": {
                "kind": {
                  "const": "reply"
                },
                "disposition": {
                  "enum": [
                    "accepted",
                    "replayed"
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
                  "const": "waiting"
                },
                "reason": {
                  "const": "deliveryUnconfirmed"
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
                  "const": "ignored"
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
                  "const": "rejected"
                },
                "reason": {
                  "enum": [
                    "unavailable",
                    "deliveryScope",
                    "scopeMismatch",
                    "staleIntent",
                    "invalidChoice",
                    "expired",
                    "alreadyResponded",
                    "noLongerNeeded",
                    "factsStale",
                    "guestStateChanged"
                  ]
                }
              }
            }
          ]
        }
      }
    },
    "processingStatus": {
      "type": "string",
      "enum": [
        "pending",
        "processed",
        "unmatched",
        "failed"
      ]
    },
    "attemptCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100
    },
    "createdAt": {
      "type": "object",
      "description": "Serialized Firestore Timestamp fixture shape.",
      "x-firestore-type": "timestamp",
      "additionalProperties": false,
      "required": [
        "_seconds",
        "_nanoseconds"
      ],
      "properties": {
        "_seconds": {
          "type": "integer"
        },
        "_nanoseconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      }
    },
    "processedAt": {
      "anyOf": [
        {
          "type": "object",
          "description": "Serialized Firestore Timestamp fixture shape.",
          "x-firestore-type": "timestamp",
          "additionalProperties": false,
          "required": [
            "_seconds",
            "_nanoseconds"
          ],
          "properties": {
            "_seconds": {
              "type": "integer"
            },
            "_nanoseconds": {
              "type": "integer",
              "minimum": 0,
              "maximum": 999999999
            }
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "expiresAt": {
      "type": "object",
      "description": "Serialized Firestore Timestamp fixture shape.",
      "x-firestore-type": "timestamp",
      "additionalProperties": false,
      "required": [
        "_seconds",
        "_nanoseconds"
      ],
      "properties": {
        "_seconds": {
          "type": "integer"
        },
        "_nanoseconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      },
      "x-firestore-ttl": true
    }
  }
} as const;
