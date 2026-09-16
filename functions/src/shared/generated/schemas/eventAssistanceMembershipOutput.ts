/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceMembershipCallableResponseSchema: Record<string, unknown> = {
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
          "minimum": 0,
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
        "attendeeId",
        "sourceHash",
        "serverTime",
        "revision",
        "episodeId",
        "participationRevision",
        "freshness",
        "ready",
        "accepted",
        "transfer",
        "transferState",
        "groups",
        "actions"
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
        "attendeeId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "sourceHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "serverTime": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "revision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "episodeId": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            {
              "type": "null"
            }
          ]
        },
        "participationRevision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "freshness": {
          "enum": [
            "uninitialized",
            "current",
            "sourceChanged"
          ]
        },
        "ready": {
          "type": "boolean"
        },
        "accepted": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "groupId",
                "groupSourceHash",
                "responsibleOperatorId",
                "acceptedAt"
              ],
              "properties": {
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "groupSourceHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                },
                "responsibleOperatorId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                "acceptedAt": {
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
        "transfer": {
          "anyOf": [
            {
              "oneOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "transferId",
                    "from",
                    "to",
                    "targetSourceHash",
                    "receivingOperatorId",
                    "requestedBy",
                    "requestedAt",
                    "expiresAt",
                    "status",
                    "resolvedAt",
                    "resolvedBy"
                  ],
                  "properties": {
                    "transferId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "from": {
                      "anyOf": [
                        {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 160,
                          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                        },
                        {
                          "type": "null"
                        }
                      ]
                    },
                    "to": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "targetSourceHash": {
                      "type": "string",
                      "pattern": "^[a-f0-9]{64}$"
                    },
                    "receivingOperatorId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180
                    },
                    "requestedBy": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180
                    },
                    "requestedAt": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
                    },
                    "expiresAt": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
                    },
                    "status": {
                      "const": "pending"
                    },
                    "resolvedAt": {
                      "type": "null"
                    },
                    "resolvedBy": {
                      "type": "null"
                    }
                  }
                },
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "transferId",
                    "from",
                    "to",
                    "targetSourceHash",
                    "receivingOperatorId",
                    "requestedBy",
                    "requestedAt",
                    "expiresAt",
                    "status",
                    "resolvedAt",
                    "resolvedBy"
                  ],
                  "properties": {
                    "transferId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "from": {
                      "anyOf": [
                        {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 160,
                          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                        },
                        {
                          "type": "null"
                        }
                      ]
                    },
                    "to": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "targetSourceHash": {
                      "type": "string",
                      "pattern": "^[a-f0-9]{64}$"
                    },
                    "receivingOperatorId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180
                    },
                    "requestedBy": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180
                    },
                    "requestedAt": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
                    },
                    "expiresAt": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
                    },
                    "status": {
                      "enum": [
                        "accepted",
                        "rejected",
                        "cancelled"
                      ]
                    },
                    "resolvedAt": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
                    },
                    "resolvedBy": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180
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
        "transferState": {
          "enum": [
            "none",
            "pending",
            "expired",
            "sourceChanged",
            "accepted",
            "rejected",
            "cancelled"
          ]
        },
        "groups": {
          "type": "array",
          "maxItems": 40,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "groupId",
              "label"
            ],
            "properties": {
              "groupId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
              },
              "label": {
                "type": "string",
                "minLength": 1,
                "maxLength": 240
              }
            }
          }
        },
        "actions": {
          "type": "array",
          "uniqueItems": true,
          "maxItems": 6,
          "items": {
            "enum": [
              "place",
              "propose",
              "accept",
              "reject",
              "cancel",
              "leave"
            ]
          }
        },
        "handoverReview": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "expiresAt",
            "receivers"
          ],
          "properties": {
            "expiresAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "receivers": {
              "type": "array",
              "maxItems": 92,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "operatorId",
                  "displayName",
                  "groups"
                ],
                "properties": {
                  "operatorId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "displayName": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "minLength": 1,
                    "maxLength": 120
                  },
                  "groups": {
                    "type": "array",
                    "minItems": 1,
                    "maxItems": 40,
                    "items": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "groupId",
                        "validUntil"
                      ],
                      "properties": {
                        "groupId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 160,
                          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                        },
                        "validUntil": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 9007199254740991
                        }
                      }
                    }
                  }
                }
              }
            }
          },
          "description": "Bounded receiving-operator choices for the reviewed guest. Read evidence only; the command rechecks current target authority. Omitted when proposing is unavailable or an older server does not provide this projection."
        }
      }
    }
  },
  "title": "EventAssistanceMembershipCallableResponse"
} as const;
