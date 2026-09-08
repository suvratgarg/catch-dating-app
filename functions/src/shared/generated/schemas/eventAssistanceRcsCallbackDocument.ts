/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceRcsCallbackDocumentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "callbackId",
    "evidence",
    "storedAt"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "callbackId": {
      "type": "string",
      "pattern": "^rcs-event:[a-f0-9]{64}$"
    },
    "evidence": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "agentId",
        "endpointHash",
        "providerEventId",
        "eventFamily",
        "providerOccurredAt",
        "receivedAt",
        "receiptKey",
        "payloadHash",
        "observation"
      ],
      "properties": {
        "agentId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 512,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._@-]*$"
        },
        "endpointHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "providerEventId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 512,
          "pattern": "^[^\\s\\u0000-\\u001f\\u007f]+$"
        },
        "eventFamily": {
          "type": "string",
          "enum": [
            "message",
            "userEvent",
            "serverEvent"
          ]
        },
        "providerOccurredAt": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 40,
          "format": "date-time"
        },
        "receivedAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "receiptKey": {
          "type": "string",
          "pattern": "^rcs-callback:[a-f0-9]{64}$"
        },
        "payloadHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "observation": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "providerMessageId",
                "status"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "delivery"
                },
                "providerMessageId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 512,
                  "pattern": "^[^\\s\\u0000-\\u001f\\u007f]+$"
                },
                "status": {
                  "type": "string",
                  "enum": [
                    "delivered",
                    "read"
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "providerMessageId",
                "revocation"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "expiration"
                },
                "providerMessageId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 512,
                  "pattern": "^[^\\s\\u0000-\\u001f\\u007f]+$"
                },
                "revocation": {
                  "type": "string",
                  "enum": [
                    "confirmed",
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
                "source",
                "suggestionType",
                "correlation"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "suggestion"
                },
                "source": {
                  "type": "string",
                  "enum": [
                    "message",
                    "event"
                  ]
                },
                "suggestionType": {
                  "type": "string",
                  "enum": [
                    "reply",
                    "action",
                    "unspecified"
                  ]
                },
                "correlation": {
                  "oneOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "attemptId",
                        "choiceIndex"
                      ],
                      "properties": {
                        "kind": {
                          "type": "string",
                          "const": "choice"
                        },
                        "attemptId": {
                          "type": "string",
                          "pattern": "^attempt:[a-f0-9]{64}$"
                        },
                        "choiceIndex": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 9
                        }
                      }
                    },
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "attemptId"
                      ],
                      "properties": {
                        "kind": {
                          "type": "string",
                          "const": "guestPage"
                        },
                        "attemptId": {
                          "type": "string",
                          "pattern": "^attempt:[a-f0-9]{64}$"
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
                          "type": "string",
                          "const": "unrecognized"
                        }
                      }
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
                "requested",
                "source"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "subscription"
                },
                "requested": {
                  "type": "string",
                  "enum": [
                    "subscribe",
                    "unsubscribe"
                  ]
                },
                "source": {
                  "type": "string",
                  "enum": [
                    "event",
                    "keyword"
                  ]
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "content"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "const": "unstructuredMessage"
                },
                "content": {
                  "type": "string",
                  "enum": [
                    "text",
                    "location",
                    "file"
                  ]
                }
              }
            }
          ]
        }
      }
    },
    "storedAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    }
  },
  "title": "EventAssistanceRcsCallbackDocument",
  "x-firestore-collection": "eventAssistanceRcsCallbacks",
  "x-firestore-path": "eventAssistanceRcsCallbacks/{callbackId}",
  "x-document-id-field": "callbackId",
  "x-owner": "event-assistance authenticated RCS ingress"
} as const;
