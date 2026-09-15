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
        "assistance",
        "movement",
        "staff",
        "settings"
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
                "setting": {
                  "anyOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "authority"
                      ],
                      "properties": {
                        "kind": {
                          "type": "string",
                          "const": "enabled"
                        },
                        "authority": {
                          "type": "string",
                          "enum": [
                            "observe",
                            "prepare",
                            "executeWithinPolicy"
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
                          "type": "string",
                          "const": "disabled"
                        },
                        "reason": {
                          "type": "string",
                          "enum": [
                            "hostChoice",
                            "organizerDefault"
                          ]
                        }
                      }
                    }
                  ],
                  "description": "Explicit observe, prepare, execute or disabled practice mode. Absence preserves earlier executable recipes."
                },
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
                "setting": {
                  "anyOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "authority"
                      ],
                      "properties": {
                        "kind": {
                          "type": "string",
                          "const": "enabled"
                        },
                        "authority": {
                          "type": "string",
                          "enum": [
                            "observe",
                            "prepare",
                            "executeWithinPolicy"
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
                          "type": "string",
                          "const": "disabled"
                        },
                        "reason": {
                          "type": "string",
                          "enum": [
                            "hostChoice",
                            "organizerDefault"
                          ]
                        }
                      }
                    }
                  ],
                  "description": "Explicit observe, prepare, execute or disabled practice mode. Absence preserves earlier executable recipes."
                },
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
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "actorId",
            "payload",
            "expectedMessageRevision",
            "expectedReviewHash"
          ],
          "properties": {
            "kind": {
              "const": "repairDelivery"
            },
            "actorId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "payload": {
              "allOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "deliveryId",
                    "action"
                  ],
                  "properties": {
                    "deliveryId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    },
                    "action": {
                      "type": "string",
                      "enum": [
                        "reconcile",
                        "retryDefiniteFailure",
                        "manualHandoff"
                      ]
                    }
                  }
                },
                {
                  "properties": {
                    "deliveryId": {
                      "type": "string",
                      "pattern": "^outbox:[a-f0-9]{64}$"
                    }
                  }
                }
              ]
            },
            "expectedMessageRevision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "expectedReviewHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
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
              "const": "resolveAccountability"
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
                "attendeeId",
                "episodeId",
                "disposition"
              ],
              "properties": {
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
                  ],
                  "description": "Current assistance episode, or explicit absence. The command adapter separately fences the canonical physical check-in."
                },
                "disposition": {
                  "type": "string",
                  "enum": [
                    "returned",
                    "departed",
                    "unresolved"
                  ]
                }
              }
            },
            "expectedSourceHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "groupId": {
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
              "const": "transferGroup"
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
                "attendeeId",
                "episodeId",
                "expectedParticipationRevision",
                "expectedMembershipRevision",
                "decision"
              ],
              "properties": {
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "expectedParticipationRevision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "expectedMembershipRevision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "decision": {
                  "oneOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "groupId"
                      ],
                      "properties": {
                        "kind": {
                          "const": "place"
                        },
                        "groupId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 160,
                          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                        }
                      }
                    },
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "from",
                        "to",
                        "receivingOperatorId",
                        "expiresAtMillis"
                      ],
                      "properties": {
                        "kind": {
                          "const": "propose"
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
                        "receivingOperatorId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 180
                        },
                        "expiresAtMillis": {
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
                        "transferId"
                      ],
                      "properties": {
                        "kind": {
                          "const": "accept"
                        },
                        "transferId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 160,
                          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                        }
                      }
                    },
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "transferId"
                      ],
                      "properties": {
                        "kind": {
                          "const": "reject"
                        },
                        "transferId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 160,
                          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                        }
                      }
                    },
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "transferId"
                      ],
                      "properties": {
                        "kind": {
                          "const": "cancel"
                        },
                        "transferId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 160,
                          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
                          "const": "leave"
                        }
                      }
                    }
                  ]
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
    },
    "movement": {
      "oneOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "payload"
          ],
          "properties": {
            "kind": {
              "const": "changeRoute"
            },
            "payload": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "routeRevision",
                "groupId",
                "expectedSourceHash",
                "alternativeId",
                "decisionId"
              ],
              "properties": {
                "routeRevision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991,
                  "description": "Nonnegative safe integer revision."
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "expectedSourceHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                },
                "alternativeId": {
                  "type": "string",
                  "pattern": "^alternative:[a-f0-9]{64}$"
                },
                "decisionId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
            "payload",
            "expectedSourceHash"
          ],
          "properties": {
            "kind": {
              "const": "confirmDeparture"
            },
            "payload": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "groupId",
                "destination",
                "expectedProgressRevision"
              ],
              "properties": {
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
                "expectedProgressRevision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991,
                  "description": "Nonnegative safe integer revision."
                },
                "departureRoster": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "attendeeIds",
                    "expectedSourceHash"
                  ],
                  "properties": {
                    "attendeeIds": {
                      "type": "array",
                      "items": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 160,
                        "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                      },
                      "uniqueItems": true,
                      "maxItems": 1000
                    },
                    "expectedSourceHash": {
                      "type": "string",
                      "pattern": "^[a-f0-9]{64}$"
                    }
                  }
                },
                "checkpointRequest": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "responsibleOperatorId",
                    "dueAt"
                  ],
                  "properties": {
                    "responsibleOperatorId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 128,
                      "pattern": "^[^/]+$"
                    },
                    "dueAt": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
                    }
                  }
                }
              }
            },
            "expectedSourceHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "payload",
            "expectedSourceHash"
          ],
          "properties": {
            "kind": {
              "const": "recordCheckpoint"
            },
            "payload": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "groupId",
                "checkpointId",
                "accountedFor",
                "expectedProgressRevision",
                "expectedCheckpointRevision",
                "correctionReason"
              ],
              "properties": {
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
                },
                "accountedFor": {
                  "type": "array",
                  "items": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 160,
                    "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                  },
                  "maxItems": 1000,
                  "uniqueItems": true
                },
                "expectedProgressRevision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 9007199254740991,
                  "description": "Nonnegative safe integer revision."
                },
                "expectedCheckpointRevision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "correctionReason": {
                  "anyOf": [
                    {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 500,
                      "pattern": "\\S"
                    },
                    {
                      "type": "null"
                    }
                  ]
                }
              }
            },
            "expectedSourceHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "payload",
            "expectedSourceHash"
          ],
          "properties": {
            "kind": {
              "const": "reassignCheckpointReporter"
            },
            "payload": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "groupId",
                "checkpointId",
                "expectedProgressRevision",
                "expectedAssignmentRevision",
                "responsibleOperatorId",
                "reason"
              ],
              "properties": {
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
                },
                "expectedProgressRevision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 9007199254740991,
                  "description": "Nonnegative safe integer revision."
                },
                "expectedAssignmentRevision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "responsibleOperatorId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 128,
                  "pattern": "^[^/]+$"
                },
                "reason": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 500,
                  "pattern": "\\S"
                }
              }
            },
            "expectedSourceHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "payload",
            "expectedSourceHash"
          ],
          "properties": {
            "kind": {
              "const": "setCheckpointCloseout"
            },
            "payload": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "groupId",
                "checkpointId",
                "expectedProgressRevision",
                "reason",
                "expectedCloseoutRevision",
                "decision"
              ],
              "properties": {
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
                },
                "expectedProgressRevision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 9007199254740991,
                  "description": "Nonnegative safe integer revision."
                },
                "reason": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 500,
                  "pattern": "\\S"
                },
                "expectedCloseoutRevision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "decision": {
                  "enum": [
                    "close",
                    "reopen"
                  ]
                }
              }
            },
            "expectedSourceHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "payload",
            "expectedSourceHash"
          ],
          "properties": {
            "kind": {
              "const": "resolveAccountability"
            },
            "expectedSourceHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "payload": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "groupId",
                "checkpointId",
                "expectedProgressRevision",
                "attendeeId",
                "expectedAccountabilityRevision",
                "disposition"
              ],
              "properties": {
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                "checkpointId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "expectedProgressRevision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 500
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                "expectedAccountabilityRevision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "disposition": {
                  "enum": [
                    "returned",
                    "departed",
                    "unresolved"
                  ]
                }
              }
            }
          }
        }
      ],
      "type": "object"
    },
    "staff": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "operatorId",
        "displayName",
        "groupId",
        "expectedRevision",
        "expectedSourceHash",
        "decision"
      ],
      "properties": {
        "operatorId": {
          "type": "string",
          "pattern": "^practice-staff:[A-Za-z0-9_-]{1,60}$"
        },
        "displayName": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "groupId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
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
        "decision": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "duty",
                "expiresAtMillis"
              ],
              "properties": {
                "kind": {
                  "const": "assign"
                },
                "duty": {
                  "enum": [
                    "lead",
                    "pacer",
                    "sweep"
                  ]
                },
                "expiresAtMillis": {
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
                "kind"
              ],
              "properties": {
                "kind": {
                  "const": "remove"
                }
              }
            }
          ]
        }
      }
    },
    "practiceOperatorId": {
      "type": "string",
      "pattern": "^practice-staff:[A-Za-z0-9_-]{1,60}$"
    },
    "settings": {
      "oneOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "expectedSourceHash",
            "groupId",
            "preference"
          ],
          "properties": {
            "kind": {
              "const": "setRule"
            },
            "expectedSourceHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "groupId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "preference": {
              "oneOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind"
                  ],
                  "properties": {
                    "kind": {
                      "const": "inherit"
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
                      "const": "disabled"
                    }
                  }
                },
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "template"
                  ],
                  "properties": {
                    "kind": {
                      "const": "configured"
                    },
                    "template": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "version",
                        "setting",
                        "config"
                      ],
                      "properties": {
                        "kind": {
                          "const": "lateJoin"
                        },
                        "version": {
                          "const": 1
                        },
                        "setting": {
                          "anyOf": [
                            {
                              "type": "object",
                              "additionalProperties": false,
                              "required": [
                                "kind",
                                "authority"
                              ],
                              "properties": {
                                "kind": {
                                  "type": "string",
                                  "const": "enabled"
                                },
                                "authority": {
                                  "type": "string",
                                  "enum": [
                                    "observe",
                                    "prepare",
                                    "executeWithinPolicy"
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
                                  "type": "string",
                                  "const": "disabled"
                                },
                                "reason": {
                                  "type": "string",
                                  "enum": [
                                    "hostChoice",
                                    "organizerDefault"
                                  ]
                                }
                              }
                            }
                          ]
                        },
                        "config": {
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
                                    "kind"
                                  ],
                                  "properties": {
                                    "kind": {
                                      "const": "confirmedGroupProgress"
                                    }
                                  }
                                },
                                {
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
                        }
                      }
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
            "expectedSourceHash",
            "configuration"
          ],
          "properties": {
            "kind": {
              "const": "configure"
            },
            "expectedSourceHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "configuration": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "routes",
                "deliveryPolicy",
                "responseDeadline",
                "outcomes"
              ],
              "properties": {
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
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "expectedSourceHash"
          ],
          "properties": {
            "kind": {
              "const": "pause"
            },
            "expectedSourceHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            }
          }
        }
      ],
      "type": "object"
    }
  },
  "allOf": [
    {
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
          "anyOf": [
            {
              "required": [
                "movement"
              ]
            },
            {
              "required": [
                "staff"
              ]
            },
            {
              "required": [
                "minutes"
              ]
            },
            {
              "required": [
                "settings"
              ]
            }
          ]
        }
      },
      "else": {
        "not": {
          "required": [
            "assistance"
          ]
        }
      }
    },
    {
      "if": {
        "properties": {
          "action": {
            "const": "movement"
          }
        }
      },
      "then": {
        "required": [
          "movement",
          "expectedSetupRevision"
        ],
        "not": {
          "anyOf": [
            {
              "required": [
                "assistance"
              ]
            },
            {
              "required": [
                "staff"
              ]
            },
            {
              "required": [
                "minutes"
              ]
            },
            {
              "required": [
                "settings"
              ]
            }
          ]
        }
      },
      "else": {
        "not": {
          "required": [
            "movement"
          ]
        }
      }
    },
    {
      "if": {
        "properties": {
          "action": {
            "const": "staff"
          }
        }
      },
      "then": {
        "required": [
          "staff",
          "expectedSetupRevision"
        ],
        "not": {
          "anyOf": [
            {
              "required": [
                "assistance"
              ]
            },
            {
              "required": [
                "movement"
              ]
            },
            {
              "required": [
                "minutes"
              ]
            },
            {
              "required": [
                "settings"
              ]
            }
          ]
        }
      },
      "else": {
        "not": {
          "required": [
            "staff"
          ]
        }
      }
    },
    {
      "if": {
        "properties": {
          "action": {
            "not": {
              "enum": [
                "assistance",
                "movement",
                "staff",
                "settings"
              ]
            }
          }
        }
      },
      "then": {
        "not": {
          "required": [
            "expectedSetupRevision"
          ]
        }
      }
    },
    {
      "if": {
        "required": [
          "practiceOperatorId"
        ]
      },
      "then": {
        "anyOf": [
          {
            "properties": {
              "action": {
                "const": "movement"
              }
            }
          },
          {
            "properties": {
              "action": {
                "const": "assistance"
              },
              "assistance": {
                "properties": {
                  "kind": {
                    "enum": [
                      "transferGroup",
                      "resolveAccountability"
                    ]
                  }
                }
              }
            }
          }
        ]
      }
    },
    {
      "if": {
        "properties": {
          "action": {
            "const": "settings"
          }
        }
      },
      "then": {
        "required": [
          "settings",
          "expectedSetupRevision"
        ],
        "not": {
          "anyOf": [
            {
              "required": [
                "assistance"
              ]
            },
            {
              "required": [
                "movement"
              ]
            },
            {
              "required": [
                "staff"
              ]
            },
            {
              "required": [
                "minutes"
              ]
            },
            {
              "required": [
                "practiceOperatorId"
              ]
            }
          ]
        }
      },
      "else": {
        "not": {
          "required": [
            "settings"
          ]
        }
      }
    }
  ]
} as const;
