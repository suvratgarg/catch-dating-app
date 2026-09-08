/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const controlEventRehearsalCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/control_event_rehearsal_payload.schema.json",
  "title": "ControlEventRehearsalCallablePayload",
  "description": "Host lifecycle or virtual-clock control. Assistance additionally requires the reviewed setup generation so a reset cannot reuse an old runtime revision.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "sessionId",
    "expectedRevision",
    "clientActionId",
    "action"
  ],
  "properties": {
    "sessionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647
    },
    "clientActionId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{8,120}$"
    },
    "action": {
      "type": "string",
      "enum": [
        "markReady",
        "start",
        "pause",
        "resume",
        "advance",
        "previous",
        "advanceClock",
        "complete",
        "assistance"
      ]
    },
    "minutes": {
      "type": "integer",
      "minimum": 1,
      "maximum": 120
    },
    "assistance": {
      "oneOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "actorId",
            "plan"
          ],
          "properties": {
            "kind": {
              "const": "publish"
            },
            "actorId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "plan": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "policy",
                "guidance",
                "departureConfirmed",
                "responseDeadline",
                "routes",
                "deliveryPolicy"
              ],
              "properties": {
                "policy": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "destination",
                    "cutoff",
                    "maxMessagesPerEpisode",
                    "minimumMinutesBetweenMessages",
                    "updateOn",
                    "unanswered"
                  ],
                  "properties": {
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
                            "permittedStopIds"
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
                            "permittedStopIds": {
                              "type": "array",
                              "minItems": 1,
                              "maxItems": 1000,
                              "items": {
                                "type": "string",
                                "minLength": 1,
                                "maxLength": 2000
                              },
                              "uniqueItems": true
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
                            "permittedCheckpointIds"
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
                            "permittedCheckpointIds": {
                              "type": "array",
                              "minItems": 1,
                              "maxItems": 1000,
                              "items": {
                                "type": "string",
                                "minLength": 1,
                                "maxLength": 2000
                              },
                              "uniqueItems": true
                            }
                          }
                        }
                      ]
                    },
                    "cutoff": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "eventEnd"
                            }
                          }
                        },
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "at"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "time"
                            },
                            "at": {
                              "type": "integer",
                              "minimum": 0,
                              "maximum": 9007199254740991,
                              "description": "UTC milliseconds."
                            }
                          }
                        }
                      ]
                    },
                    "maxMessagesPerEpisode": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 100
                    },
                    "minimumMinutesBetweenMessages": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 1440
                    },
                    "updateOn": {
                      "type": "string",
                      "const": "materialGuidanceChange"
                    },
                    "unanswered": {
                      "type": "string",
                      "enum": [
                        "keepUnknownUntilCutoff",
                        "hostReviewAtDeadline"
                      ]
                    }
                  }
                },
                "guidance": {
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
                "departureConfirmed": {
                  "type": "boolean"
                },
                "responseDeadline": {
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
                "routes": {
                  "type": "array",
                  "minItems": 1,
                  "maxItems": 3,
                  "uniqueItems": true,
                  "items": {
                    "type": "string",
                    "enum": [
                      "catchEventSms",
                      "catchEventRcs",
                      "organizerEventWhatsapp"
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
              },
              "if": {
                "properties": {
                  "policy": {
                    "properties": {
                      "unanswered": {
                        "const": "hostReviewAtDeadline"
                      }
                    }
                  }
                }
              },
              "then": {
                "properties": {
                  "responseDeadline": {
                    "type": "integer"
                  }
                }
              }
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "actorId",
            "messageId",
            "outcome"
          ],
          "properties": {
            "kind": {
              "const": "dispatch"
            },
            "actorId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "messageId": {
              "type": "string",
              "pattern": "^outbox:[a-f0-9]{64}$"
            },
            "outcome": {
              "oneOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "enum": [
                        "accepted",
                        "delivered",
                        "read",
                        "revoked"
                      ]
                    }
                  }
                },
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "classification"
                  ],
                  "properties": {
                    "kind": {
                      "const": "failed"
                    },
                    "classification": {
                      "type": "string",
                      "enum": [
                        "technical",
                        "policy",
                        "suppressed",
                        "invalidRecipient"
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
                      "const": "unknown"
                    },
                    "reason": {
                      "type": "string",
                      "enum": [
                        "timeout",
                        "connectionLost",
                        "workerInterrupted"
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
            "kind",
            "actorId",
            "messageId",
            "attemptId",
            "outcome"
          ],
          "properties": {
            "kind": {
              "const": "receipt"
            },
            "actorId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "messageId": {
              "type": "string",
              "pattern": "^outbox:[a-f0-9]{64}$"
            },
            "attemptId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160
            },
            "outcome": {
              "oneOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "enum": [
                        "accepted",
                        "delivered",
                        "read",
                        "revoked"
                      ]
                    }
                  }
                },
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "classification"
                  ],
                  "properties": {
                    "kind": {
                      "const": "failed"
                    },
                    "classification": {
                      "type": "string",
                      "enum": [
                        "technical",
                        "policy",
                        "suppressed",
                        "invalidRecipient"
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
            "kind",
            "actorId",
            "plan",
            "outcomes"
          ],
          "properties": {
            "kind": {
              "const": "configureAutomation"
            },
            "actorId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "plan": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "policy",
                "guidance",
                "departureConfirmed",
                "responseDeadline",
                "routes",
                "deliveryPolicy"
              ],
              "properties": {
                "policy": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "destination",
                    "cutoff",
                    "maxMessagesPerEpisode",
                    "minimumMinutesBetweenMessages",
                    "updateOn",
                    "unanswered"
                  ],
                  "properties": {
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
                            "permittedStopIds"
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
                            "permittedStopIds": {
                              "type": "array",
                              "minItems": 1,
                              "maxItems": 1000,
                              "items": {
                                "type": "string",
                                "minLength": 1,
                                "maxLength": 2000
                              },
                              "uniqueItems": true
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
                            "permittedCheckpointIds"
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
                            "permittedCheckpointIds": {
                              "type": "array",
                              "minItems": 1,
                              "maxItems": 1000,
                              "items": {
                                "type": "string",
                                "minLength": 1,
                                "maxLength": 2000
                              },
                              "uniqueItems": true
                            }
                          }
                        }
                      ]
                    },
                    "cutoff": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "eventEnd"
                            }
                          }
                        },
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "at"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "time"
                            },
                            "at": {
                              "type": "integer",
                              "minimum": 0,
                              "maximum": 9007199254740991,
                              "description": "UTC milliseconds."
                            }
                          }
                        }
                      ]
                    },
                    "maxMessagesPerEpisode": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 100
                    },
                    "minimumMinutesBetweenMessages": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 1440
                    },
                    "updateOn": {
                      "type": "string",
                      "const": "materialGuidanceChange"
                    },
                    "unanswered": {
                      "type": "string",
                      "enum": [
                        "keepUnknownUntilCutoff",
                        "hostReviewAtDeadline"
                      ]
                    }
                  }
                },
                "guidance": {
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
                "departureConfirmed": {
                  "type": "boolean"
                },
                "responseDeadline": {
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
                "routes": {
                  "type": "array",
                  "minItems": 1,
                  "maxItems": 3,
                  "uniqueItems": true,
                  "items": {
                    "type": "string",
                    "enum": [
                      "catchEventSms",
                      "catchEventRcs",
                      "organizerEventWhatsapp"
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
              },
              "if": {
                "properties": {
                  "policy": {
                    "properties": {
                      "unanswered": {
                        "const": "hostReviewAtDeadline"
                      }
                    }
                  }
                }
              },
              "then": {
                "properties": {
                  "responseDeadline": {
                    "type": "integer"
                  }
                }
              }
            },
            "outcomes": {
              "type": "array",
              "minItems": 1,
              "maxItems": 6,
              "items": {
                "oneOf": [
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "kind"
                    ],
                    "properties": {
                      "kind": {
                        "type": "string",
                        "enum": [
                          "accepted",
                          "delivered",
                          "read",
                          "revoked"
                        ]
                      }
                    }
                  },
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "kind",
                      "classification"
                    ],
                    "properties": {
                      "kind": {
                        "const": "failed"
                      },
                      "classification": {
                        "type": "string",
                        "enum": [
                          "technical",
                          "policy",
                          "suppressed",
                          "invalidRecipient"
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
                        "const": "unknown"
                      },
                      "reason": {
                        "type": "string",
                        "enum": [
                          "timeout",
                          "connectionLost",
                          "workerInterrupted"
                        ]
                      }
                    }
                  }
                ]
              }
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "actorId"
          ],
          "properties": {
            "kind": {
              "const": "pauseAutomation"
            },
            "actorId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "actorId"
          ],
          "properties": {
            "kind": {
              "const": "resumeAutomation"
            },
            "actorId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "actorId",
            "payload",
            "expectedSourceHash"
          ],
          "properties": {
            "kind": {
              "const": "resolveAssistance"
            },
            "actorId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "payload": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "caseId",
                "outcome",
                "owner",
                "expectedRevision"
              ],
              "properties": {
                "caseId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "outcome": {
                  "type": "string",
                  "enum": [
                    "resolved",
                    "declined",
                    "transferred"
                  ]
                },
                "owner": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$",
                  "description": "Current organizer manager UID receiving a transferred request; otherwise the authenticated resolving manager UID."
                },
                "expectedRevision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                }
              }
            },
            "expectedSourceHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            }
          }
        }
      ],
      "type": "object"
    },
    "expectedSetupRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647
    }
  },
  "if": {
    "properties": {
      "action": {
        "const": "assistance"
      }
    }
  },
  "then": {
    "required": [
      "assistance",
      "expectedSetupRevision"
    ],
    "not": {
      "required": [
        "minutes"
      ]
    }
  },
  "else": {
    "not": {
      "anyOf": [
        {
          "required": [
            "assistance"
          ]
        },
        {
          "required": [
            "expectedSetupRevision"
          ]
        }
      ]
    }
  }
} as const;
