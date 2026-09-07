/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const setEventAssistanceRuntimeConfigCallablePayloadSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "context",
    "requestId",
    "expectedRevision",
    "expectedSourceHash",
    "command"
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
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "expectedSourceHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "command": {
      "oneOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "configuration"
          ],
          "properties": {
            "kind": {
              "type": "string",
              "const": "configure"
            },
            "configuration": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "options",
                "expiresAt",
                "maxEvaluations"
              ],
              "properties": {
                "options": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "routes",
                    "responseDeadline",
                    "deliveryPolicy"
                  ],
                  "properties": {
                    "routes": {
                      "type": "array",
                      "minItems": 1,
                      "maxItems": 3,
                      "uniqueItems": true,
                      "items": {
                        "oneOf": [
                          {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "routeId",
                              "senderId"
                            ],
                            "properties": {
                              "routeId": {
                                "type": "string",
                                "const": "catchEventSms"
                              },
                              "senderId": {
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
                              "routeId",
                              "senderId"
                            ],
                            "properties": {
                              "routeId": {
                                "type": "string",
                                "const": "organizerEventWhatsapp"
                              },
                              "senderId": {
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
                              "routeId"
                            ],
                            "properties": {
                              "routeId": {
                                "type": "string",
                                "const": "catchEventRcs"
                              }
                            }
                          }
                        ]
                      }
                    },
                    "responseDeadline": {
                      "anyOf": [
                        {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 9007199254740991
                        },
                        {
                          "type": "null",
                          "const": null
                        }
                      ]
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
                          "maximum": 3
                        },
                        "minimumRetrySeconds": {
                          "type": "integer",
                          "minimum": 1,
                          "maximum": 3600
                        }
                      }
                    },
                    "laterChoices": {
                      "type": "array",
                      "maxItems": 17,
                      "items": {
                        "type": "object",
                        "additionalProperties": false,
                        "required": [
                          "label",
                          "target"
                        ],
                        "properties": {
                          "label": {
                            "type": "string",
                            "minLength": 1,
                            "maxLength": 80
                          },
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
                          }
                        }
                      }
                    }
                  }
                },
                "expiresAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "maxEvaluations": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 10000
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
              "type": "string",
              "const": "pause"
            }
          }
        }
      ]
    }
  },
  "title": "SetEventAssistanceRuntimeConfigCallablePayload"
} as const;
