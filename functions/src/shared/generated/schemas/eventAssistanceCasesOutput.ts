/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceCasesCallableResponseSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "context",
    "serverTime",
    "coverage",
    "status",
    "cases",
    "nextCursor"
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
    "coverage": {
      "const": "page"
    },
    "status": {
      "enum": [
        "open",
        "resolved"
      ]
    },
    "cases": {
      "type": "array",
      "maxItems": 50,
      "items": {
        "oneOf": [
          {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "caseId",
              "revision",
              "sourceHash",
              "availability",
              "attendeeId",
              "category",
              "receivedAt",
              "status",
              "resolution",
              "canChange",
              "assignment"
            ],
            "properties": {
              "caseId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
              },
              "revision": {
                "type": "integer",
                "minimum": 0,
                "maximum": 9007199254740991
              },
              "sourceHash": {
                "type": "string",
                "pattern": "^[a-f0-9]{64}$"
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
              "category": {
                "enum": [
                  "eventLogistics",
                  "accessibility",
                  "other"
                ]
              },
              "receivedAt": {
                "type": "integer",
                "minimum": 0,
                "maximum": 9007199254740991
              },
              "status": {
                "const": "open"
              },
              "resolution": {
                "type": "null"
              },
              "canChange": {
                "const": true
              },
              "assignment": {
                "oneOf": [
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "kind"
                    ],
                    "properties": {
                      "kind": {
                        "const": "unassigned"
                      }
                    }
                  },
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "kind",
                      "uid",
                      "authority"
                    ],
                    "properties": {
                      "kind": {
                        "const": "assigned"
                      },
                      "uid": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 160,
                        "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
              }
            }
          },
          {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "caseId",
              "revision",
              "sourceHash",
              "availability",
              "attendeeId",
              "category",
              "receivedAt",
              "status",
              "resolution",
              "canChange",
              "assignment"
            ],
            "properties": {
              "caseId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
              },
              "revision": {
                "type": "integer",
                "minimum": 1,
                "maximum": 9007199254740991
              },
              "sourceHash": {
                "type": "string",
                "pattern": "^[a-f0-9]{64}$"
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
              "category": {
                "enum": [
                  "eventLogistics",
                  "accessibility",
                  "other"
                ]
              },
              "receivedAt": {
                "type": "integer",
                "minimum": 0,
                "maximum": 9007199254740991
              },
              "status": {
                "const": "resolved"
              },
              "resolution": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "outcome",
                  "actorUid",
                  "at"
                ],
                "properties": {
                  "outcome": {
                    "enum": [
                      "resolved",
                      "declined"
                    ]
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
                  }
                }
              },
              "canChange": {
                "const": false
              },
              "assignment": {
                "oneOf": [
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "kind"
                    ],
                    "properties": {
                      "kind": {
                        "const": "unassigned"
                      }
                    }
                  },
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "kind",
                      "uid",
                      "authority"
                    ],
                    "properties": {
                      "kind": {
                        "const": "assigned"
                      },
                      "uid": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 160,
                        "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
              }
            }
          },
          {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "caseId",
              "revision",
              "sourceHash",
              "availability",
              "attendeeId",
              "category",
              "receivedAt",
              "status",
              "resolution",
              "canChange",
              "assignment"
            ],
            "properties": {
              "caseId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
              },
              "revision": {
                "type": "integer",
                "minimum": 0,
                "maximum": 9007199254740991
              },
              "sourceHash": {
                "type": "string",
                "pattern": "^[a-f0-9]{64}$"
              },
              "availability": {
                "const": "sourceChanged"
              },
              "attendeeId": {
                "type": "null"
              },
              "category": {
                "enum": [
                  "eventLogistics",
                  "accessibility",
                  "other"
                ]
              },
              "receivedAt": {
                "type": "integer",
                "minimum": 0,
                "maximum": 9007199254740991
              },
              "status": {
                "enum": [
                  "open",
                  "resolved"
                ]
              },
              "resolution": {
                "type": "null"
              },
              "canChange": {
                "const": false
              },
              "assignment": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "kind"
                ],
                "properties": {
                  "kind": {
                    "const": "unavailable"
                  }
                }
              }
            }
          },
          {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "caseId",
              "revision",
              "sourceHash",
              "availability",
              "attendeeId",
              "category",
              "receivedAt",
              "status",
              "resolution",
              "canChange",
              "assignment"
            ],
            "properties": {
              "caseId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
              },
              "revision": {
                "type": "null"
              },
              "sourceHash": {
                "type": "string",
                "pattern": "^[a-f0-9]{64}$"
              },
              "availability": {
                "const": "legacy"
              },
              "attendeeId": {
                "type": "null"
              },
              "category": {
                "enum": [
                  "eventLogistics",
                  "accessibility",
                  "other"
                ]
              },
              "receivedAt": {
                "type": "integer",
                "minimum": 0,
                "maximum": 9007199254740991
              },
              "status": {
                "enum": [
                  "open",
                  "resolved"
                ]
              },
              "resolution": {
                "type": "null"
              },
              "canChange": {
                "const": false
              },
              "assignment": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "kind"
                ],
                "properties": {
                  "kind": {
                    "const": "unavailable"
                  }
                }
              }
            }
          }
        ]
      }
    },
    "nextCursor": {
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
    }
  },
  "title": "EventAssistanceCasesCallableResponse"
} as const;
