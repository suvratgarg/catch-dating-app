/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceGroupProgressCallableResponseSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "outcome",
    "view",
    "operationRevision"
  ],
  "properties": {
    "outcome": {
      "enum": [
        "read",
        "applied",
        "replayed"
      ]
    },
    "view": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "context",
        "groupId",
        "serverTime",
        "revision",
        "sourceHash",
        "eventOpen",
        "runtimeLive",
        "freshness",
        "progress",
        "guidance",
        "destinations"
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
        "sourceHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "eventOpen": {
          "type": "boolean"
        },
        "runtimeLive": {
          "type": "boolean"
        },
        "freshness": {
          "enum": [
            "unconfirmed",
            "current",
            "sourceChanged"
          ]
        },
        "progress": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "schemaVersion",
                "progressId",
                "context",
                "groupId",
                "revision",
                "destination",
                "sourceHash",
                "confirmedBy",
                "confirmedAt",
                "operationId",
                "requestHash",
                "createdAt",
                "updatedAt"
              ],
              "properties": {
                "schemaVersion": {
                  "const": 1
                },
                "progressId": {
                  "type": "string",
                  "pattern": "^progress:[a-f0-9]{64}$"
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
                "revision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 9007199254740991
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
                "sourceHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                },
                "confirmedBy": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "confirmedAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "requestHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                },
                "createdAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "updatedAt": {
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
        "guidance": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "revision",
                "destination",
                "materialKey",
                "text",
                "validUntil"
              ],
              "properties": {
                "revision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991,
                  "description": "Nonnegative safe integer revision."
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
                "materialKey": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "text": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "validUntil": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991,
                  "description": "UTC milliseconds."
                }
              }
            },
            {
              "type": "null"
            }
          ]
        },
        "destinations": {
          "type": "array",
          "maxItems": 41,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "target",
              "label",
              "location"
            ],
            "properties": {
              "target": {
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
              "label": {
                "type": "string",
                "minLength": 1,
                "maxLength": 240
              },
              "location": {
                "type": "object",
                "additionalProperties": false,
                "description": "Canonical meeting location selected from Google Places or a manually pinned map coordinate.",
                "required": [
                  "name",
                  "latitude",
                  "longitude"
                ],
                "properties": {
                  "name": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 240
                  },
                  "address": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "maxLength": 500
                  },
                  "placeId": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "minLength": 1,
                    "maxLength": 256
                  },
                  "latitude": {
                    "type": "number",
                    "minimum": -90,
                    "maximum": 90
                  },
                  "longitude": {
                    "type": "number",
                    "minimum": -180,
                    "maximum": 180
                  },
                  "notes": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "maxLength": 1000
                  }
                }
              }
            }
          }
        }
      }
    },
    "operationRevision": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 1,
      "maximum": 9007199254740991
    }
  },
  "title": "EventAssistanceGroupProgressCallableResponse"
} as const;
