/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventRehearsalBootstrapCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/event_rehearsal_bootstrap_response.schema.json",
  "title": "EventRehearsalBootstrapCallableResponse",
  "description": "Host projection of a rehearsal session, synthetic actors, and bounded action history.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "session",
    "actors",
    "actions",
    "guestUrl",
    "canUseInternalFaults"
  ],
  "properties": {
    "session": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "id",
        "organizerId",
        "sourceEventId",
        "scenarioId",
        "seed",
        "actorCount",
        "actionCount",
        "status",
        "setup",
        "setupRevision",
        "runtimeRevision",
        "activeStepIndex",
        "virtualNowMillis",
        "faultId",
        "expiresAtMillis",
        "virtualStartedAtMillis"
      ],
      "properties": {
        "id": {
          "type": "string"
        },
        "organizerId": {
          "type": "string"
        },
        "sourceEventId": {
          "type": [
            "string",
            "null"
          ]
        },
        "scenarioId": {
          "type": "string",
          "enum": [
            "smoothRun",
            "lateAndNoShow",
            "earlyExitAndReturn",
            "rosterAndCapacity",
            "walkInAndAmbiguousClaim",
            "privacyAndKeepApart",
            "lowConnectivity",
            "concurrentHosts",
            "revealInterrupted",
            "externalProfiles",
            "accountabilitySweep"
          ]
        },
        "seed": {
          "type": "integer"
        },
        "actorCount": {
          "type": "integer"
        },
        "actionCount": {
          "type": "integer",
          "minimum": 0,
          "maximum": 500
        },
        "status": {
          "type": "string",
          "enum": [
            "draft",
            "ready",
            "running",
            "paused",
            "complete",
            "expired"
          ]
        },
        "setup": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "title",
            "locationName",
            "durationMinutes",
            "hostGoal",
            "attendeePrompt",
            "moduleIds"
          ],
          "properties": {
            "title": {
              "type": "string",
              "minLength": 1,
              "maxLength": 120
            },
            "locationName": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "durationMinutes": {
              "type": "integer",
              "minimum": 30,
              "maximum": 360
            },
            "hostGoal": {
              "type": "string",
              "minLength": 1,
              "maxLength": 240
            },
            "attendeePrompt": {
              "type": "string",
              "minLength": 1,
              "maxLength": 320
            },
            "moduleIds": {
              "type": "array",
              "minItems": 1,
              "maxItems": 8,
              "uniqueItems": true,
              "items": {
                "type": "string",
                "enum": [
                  "arrival",
                  "firstHello",
                  "pods",
                  "rotations",
                  "conversationCues",
                  "reveal",
                  "afterglow",
                  "accountability"
                ]
              }
            },
            "movementSimulation": {
              "type": "object",
              "additionalProperties": false,
              "description": "Frozen, synthetic-only movement truth used by dress rehearsal. It never reads or writes a real person's live position.",
              "required": [
                "itinerary",
                "routePlan",
                "livePositions",
                "lateArrivalGuidance"
              ],
              "properties": {
                "itinerary": {
                  "type": "array",
                  "maxItems": 40,
                  "items": {
                    "type": "object",
                    "additionalProperties": false,
                    "description": "One public, event-local run-of-show entry. Offset is measured from the event start so rescheduling does not rewrite the itinerary.",
                    "required": [
                      "id",
                      "kind",
                      "offsetMinutes",
                      "title"
                    ],
                    "properties": {
                      "id": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 80,
                        "pattern": "^[A-Za-z0-9_-]+$"
                      },
                      "kind": {
                        "type": "string",
                        "enum": [
                          "gather",
                          "activity",
                          "stop",
                          "break",
                          "transition",
                          "finish"
                        ]
                      },
                      "offsetMinutes": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 1440
                      },
                      "durationMinutes": {
                        "type": [
                          "integer",
                          "null"
                        ],
                        "minimum": 1,
                        "maximum": 1440
                      },
                      "title": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 120
                      },
                      "description": {
                        "type": [
                          "string",
                          "null"
                        ],
                        "maxLength": 500
                      },
                      "location": {
                        "anyOf": [
                          {
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
                          },
                          {
                            "type": "null"
                          }
                        ]
                      },
                      "routeDistanceMeters": {
                        "type": [
                          "integer",
                          "null"
                        ],
                        "minimum": 0,
                        "maximum": 1000000
                      }
                    }
                  }
                },
                "routePlan": {
                  "anyOf": [
                    {
                      "type": "null"
                    },
                    {
                      "type": "object",
                      "description": "Composable operations for an event that moves through a route. Activity kind remains the broader format authority.",
                      "additionalProperties": false,
                      "required": [
                        "version",
                        "movementMode",
                        "routeShape",
                        "groupStrategy",
                        "stopCadence",
                        "stopKinds",
                        "roleKinds"
                      ],
                      "properties": {
                        "version": {
                          "type": "integer",
                          "enum": [
                            1,
                            2
                          ]
                        },
                        "movementMode": {
                          "type": "string",
                          "enum": [
                            "run",
                            "walk",
                            "ride",
                            "mixed"
                          ]
                        },
                        "routeShape": {
                          "type": "string",
                          "enum": [
                            "loop",
                            "outAndBack",
                            "pointToPoint"
                          ]
                        },
                        "groupStrategy": {
                          "type": "string",
                          "enum": [
                            "together",
                            "paceGroups",
                            "selfDirected"
                          ]
                        },
                        "stopCadence": {
                          "type": "string",
                          "enum": [
                            "continuous",
                            "flexibleStops",
                            "hostedStops"
                          ]
                        },
                        "stopKinds": {
                          "type": "array",
                          "minItems": 1,
                          "maxItems": 7,
                          "uniqueItems": true,
                          "items": {
                            "type": "string",
                            "enum": [
                              "water",
                              "regroup",
                              "venue",
                              "photoSpot",
                              "viewpoint",
                              "hazard",
                              "turnaround"
                            ]
                          }
                        },
                        "roleKinds": {
                          "type": "array",
                          "minItems": 1,
                          "maxItems": 6,
                          "uniqueItems": true,
                          "items": {
                            "type": "string",
                            "enum": [
                              "routeLead",
                              "sweep",
                              "pacer",
                              "stopHost",
                              "marshal",
                              "photographer"
                            ]
                          }
                        },
                        "path": {
                          "type": "array",
                          "minItems": 2,
                          "maxItems": 500,
                          "items": {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "latitude",
                              "longitude"
                            ],
                            "properties": {
                              "latitude": {
                                "type": "number",
                                "minimum": -90,
                                "maximum": 90
                              },
                              "longitude": {
                                "type": "number",
                                "minimum": -180,
                                "maximum": 180
                              }
                            }
                          }
                        },
                        "paceGroups": {
                          "type": "array",
                          "maxItems": 12,
                          "items": {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "id",
                              "label",
                              "sortOrder"
                            ],
                            "properties": {
                              "id": {
                                "type": "string",
                                "minLength": 1,
                                "maxLength": 80,
                                "pattern": "^[A-Za-z0-9_-]+$"
                              },
                              "label": {
                                "type": "string",
                                "minLength": 1,
                                "maxLength": 80
                              },
                              "targetPaceSecondsPerKm": {
                                "type": [
                                  "integer",
                                  "null"
                                ],
                                "minimum": 120,
                                "maximum": 1800
                              },
                              "sortOrder": {
                                "type": "integer",
                                "minimum": 0,
                                "maximum": 1000
                              }
                            }
                          }
                        },
                        "liveTrackingPolicy": {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "mode",
                            "staleAfterSeconds",
                            "retentionMinutes"
                          ],
                          "properties": {
                            "mode": {
                              "type": "string",
                              "enum": [
                                "disabled",
                                "hostOnly",
                                "authorizedOperators"
                              ]
                            },
                            "staleAfterSeconds": {
                              "type": "integer",
                              "minimum": 30,
                              "maximum": 600
                            },
                            "retentionMinutes": {
                              "type": "integer",
                              "minimum": 5,
                              "maximum": 1440
                            }
                          }
                        }
                      }
                    }
                  ]
                },
                "livePositions": {
                  "type": "array",
                  "maxItems": 2,
                  "items": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "role",
                      "latitude",
                      "longitude",
                      "recordedOffsetMinutes"
                    ],
                    "properties": {
                      "role": {
                        "type": "string",
                        "enum": [
                          "host",
                          "operator"
                        ]
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
                      "recordedOffsetMinutes": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 360
                      }
                    }
                  }
                },
                "lateArrivalGuidance": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "maxLength": 320
                }
              }
            }
          }
        },
        "setupRevision": {
          "type": "integer"
        },
        "runtimeRevision": {
          "type": "integer"
        },
        "activeStepIndex": {
          "type": "integer"
        },
        "virtualNowMillis": {
          "type": "integer"
        },
        "faultId": {
          "type": "string",
          "enum": [
            "none",
            "latency",
            "oneShotFailure",
            "listenerDisconnect",
            "staleRevision",
            "duplicateDelivery",
            "legacyFixture",
            "reducedMotion",
            "lowBandwidth"
          ]
        },
        "expiresAtMillis": {
          "type": "integer"
        },
        "virtualStartedAtMillis": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        }
      }
    },
    "actors": {
      "type": "array",
      "maxItems": 50,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "actorId",
          "displayName",
          "persona",
          "status",
          "guestMoment",
          "optedOut",
          "keepApartActorIds",
          "helpRequested",
          "promptCompleted",
          "layoutUnitId",
          "confirmedLayoutUnitId"
        ],
        "properties": {
          "actorId": {
            "type": "string"
          },
          "displayName": {
            "type": "string"
          },
          "persona": {
            "type": "string"
          },
          "status": {
            "type": "string",
            "enum": [
              "expected",
              "present",
              "late",
              "noShow",
              "departed",
              "returned",
              "disconnected",
              "walkIn",
              "ambiguousClaim"
            ]
          },
          "connectionState": {
            "type": "string",
            "enum": [
              "connected",
              "disconnected"
            ]
          },
          "guestMoment": {
            "type": "string",
            "enum": [
              "welcome",
              "checkIn",
              "firstHello",
              "assignment",
              "rotation",
              "pause",
              "reveal",
              "afterglow",
              "complete"
            ]
          },
          "optedOut": {
            "type": "boolean"
          },
          "keepApartActorIds": {
            "type": "array",
            "items": {
              "type": "string"
            }
          },
          "helpRequested": {
            "type": "boolean"
          },
          "promptCompleted": {
            "type": "boolean"
          },
          "layoutUnitId": {
            "type": [
              "string",
              "null"
            ]
          },
          "confirmedLayoutUnitId": {
            "type": [
              "string",
              "null"
            ]
          },
          "assistance": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "intention",
              "latestMessageId"
            ],
            "properties": {
              "intention": {
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
                        "const": "unknown"
                      }
                    }
                  },
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "kind",
                      "claimedEta"
                    ],
                    "properties": {
                      "kind": {
                        "type": "string",
                        "const": "onMyWay"
                      },
                      "claimedEta": {
                        "anyOf": [
                          {
                            "type": "integer",
                            "minimum": 0,
                            "maximum": 9007199254740991,
                            "description": "UTC milliseconds."
                          },
                          {
                            "type": "null",
                            "const": null
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
                      "target"
                    ],
                    "properties": {
                      "kind": {
                        "type": "string",
                        "const": "joinLater"
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
                        "const": "notComing"
                      }
                    }
                  }
                ]
              },
              "latestMessageId": {
                "anyOf": [
                  {
                    "type": "string",
                    "pattern": "^outbox:[a-f0-9]{64}$"
                  },
                  {
                    "type": "null"
                  }
                ]
              }
            }
          },
          "assistanceMessage": {
            "anyOf": [
              {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "messageId",
                  "intentId",
                  "intentRevision",
                  "text",
                  "choices",
                  "lifecycle",
                  "expiresAt",
                  "canRespond",
                  "responseChoiceId"
                ],
                "properties": {
                  "messageId": {
                    "type": "string",
                    "pattern": "^outbox:[a-f0-9]{64}$"
                  },
                  "intentId": {
                    "type": "string"
                  },
                  "intentRevision": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 9007199254740991
                  },
                  "text": {
                    "type": "string",
                    "maxLength": 2000
                  },
                  "choices": {
                    "type": "array",
                    "maxItems": 20,
                    "items": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "choiceId",
                        "label"
                      ],
                      "properties": {
                        "choiceId": {
                          "type": "string"
                        },
                        "label": {
                          "type": "string",
                          "maxLength": 80
                        }
                      }
                    }
                  },
                  "lifecycle": {
                    "type": "string",
                    "enum": [
                      "active",
                      "cancelled",
                      "superseded",
                      "responded"
                    ]
                  },
                  "expiresAt": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 9007199254740991
                  },
                  "canRespond": {
                    "type": "boolean"
                  },
                  "responseChoiceId": {
                    "anyOf": [
                      {
                        "type": "string"
                      },
                      {
                        "type": "null"
                      }
                    ]
                  }
                }
              },
              {
                "type": "null"
              }
            ]
          },
          "assistanceDelivery": {
            "anyOf": [
              {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "conflictingEvidence",
                  "attempts"
                ],
                "properties": {
                  "conflictingEvidence": {
                    "type": "boolean"
                  },
                  "attempts": {
                    "type": "array",
                    "maxItems": 6,
                    "items": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "attemptId",
                        "routeId",
                        "status"
                      ],
                      "properties": {
                        "attemptId": {
                          "type": "string"
                        },
                        "routeId": {
                          "type": "string",
                          "enum": [
                            "catchEventSms",
                            "catchEventRcs",
                            "organizerEventWhatsapp"
                          ]
                        },
                        "status": {
                          "type": "string",
                          "enum": [
                            "notDispatched",
                            "reserved",
                            "unknown",
                            "accepted",
                            "delivered",
                            "read",
                            "failed",
                            "revoked"
                          ]
                        }
                      }
                    }
                  }
                }
              },
              {
                "type": "null"
              }
            ]
          },
          "assistanceAutomation": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "clockId",
              "status",
              "plan",
              "outcomes",
              "nextOutcomeIndex",
              "evaluation"
            ],
            "properties": {
              "clockId": {
                "type": "string",
                "pattern": "^clock:[a-f0-9]{64}$"
              },
              "status": {
                "type": "string",
                "enum": [
                  "enabled",
                  "paused"
                ]
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
              },
              "nextOutcomeIndex": {
                "type": "integer",
                "minimum": 0,
                "maximum": 6
              },
              "evaluation": {
                "anyOf": [
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "at",
                      "policy",
                      "delivery"
                    ],
                    "properties": {
                      "at": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 9007199254740991
                      },
                      "policy": {
                        "anyOf": [
                          {
                            "anyOf": [
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
                                    "const": "resolved"
                                  },
                                  "reason": {
                                    "type": "string",
                                    "enum": [
                                      "joined",
                                      "declined"
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
                                    "const": "cancelled"
                                  },
                                  "reason": {
                                    "type": "string",
                                    "enum": [
                                      "eventClosed",
                                      "notAdmitted",
                                      "policyDisabled",
                                      "participationInactive"
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
                                    "const": "expired"
                                  },
                                  "reason": {
                                    "type": "string",
                                    "enum": [
                                      "cutoff",
                                      "lateEntryClosed"
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
                                    "const": "wait"
                                  },
                                  "reason": {
                                    "type": "string",
                                    "enum": [
                                      "departureUnconfirmed",
                                      "attendanceUnknown",
                                      "guidanceUnavailable",
                                      "throttled",
                                      "unchanged",
                                      "participationUnknown"
                                    ]
                                  }
                                }
                              },
                              {
                                "type": "object",
                                "additionalProperties": false,
                                "required": [
                                  "kind",
                                  "reason",
                                  "guidance"
                                ],
                                "properties": {
                                  "kind": {
                                    "type": "string",
                                    "const": "hostDecision"
                                  },
                                  "reason": {
                                    "type": "string",
                                    "enum": [
                                      "unreachable",
                                      "entryDecision",
                                      "missingInformation"
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
                                        "type": "null",
                                        "const": null
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
                                  "guidance",
                                  "messageKey",
                                  "shouldSend",
                                  "nextEvaluationAt"
                                ],
                                "properties": {
                                  "kind": {
                                    "type": "string",
                                    "const": "update"
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
                                  "messageKey": {
                                    "type": "string",
                                    "minLength": 1,
                                    "maxLength": 2000
                                  },
                                  "shouldSend": {
                                    "type": "boolean"
                                  },
                                  "nextEvaluationAt": {
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
                      "delivery": {
                        "oneOf": [
                          {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "kind"
                            ],
                            "properties": {
                              "kind": {
                                "const": "paused"
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
                                "const": "notApplicable"
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
                                "const": "scriptExhausted"
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
                                "const": "stop"
                              },
                              "reason": {
                                "type": "string",
                                "enum": [
                                  "responded",
                                  "cancelled",
                                  "superseded",
                                  "expired",
                                  "eventClosed",
                                  "permissionRevoked",
                                  "guestPresent",
                                  "guestDeclined",
                                  "notAdmitted",
                                  "hostStopped",
                                  "participationInactive"
                                ]
                              }
                            }
                          },
                          {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "kind",
                              "attemptIds"
                            ],
                            "properties": {
                              "kind": {
                                "const": "delivered"
                              },
                              "attemptIds": {
                                "type": "array",
                                "maxItems": 6,
                                "items": {
                                  "type": "string"
                                }
                              }
                            }
                          },
                          {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "kind",
                              "attemptIds",
                              "notBefore"
                            ],
                            "properties": {
                              "kind": {
                                "const": "reconcile"
                              },
                              "attemptIds": {
                                "type": "array",
                                "maxItems": 6,
                                "items": {
                                  "type": "string"
                                }
                              },
                              "notBefore": {
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
                              "reason"
                            ],
                            "properties": {
                              "kind": {
                                "const": "refreshFacts"
                              },
                              "reason": {
                                "type": "string",
                                "enum": [
                                  "eventFactsStale",
                                  "routeFactsStale"
                                ]
                              }
                            }
                          },
                          {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "kind",
                              "notBefore",
                              "reason"
                            ],
                            "properties": {
                              "kind": {
                                "const": "wait"
                              },
                              "notBefore": {
                                "type": "integer",
                                "minimum": 0,
                                "maximum": 9007199254740991
                              },
                              "reason": {
                                "const": "retryBackoff"
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
                                "const": "hostDecision"
                              },
                              "reason": {
                                "type": "string",
                                "enum": [
                                  "noEligibleRoute",
                                  "attemptLimit",
                                  "policyRejected",
                                  "recipientNeedsReview",
                                  "providerOwnsFallback",
                                  "conflictingDeliveryEvidence",
                                  "historyUnavailable"
                                ]
                              }
                            }
                          }
                        ]
                      }
                    }
                  },
                  {
                    "type": "null"
                  }
                ]
              }
            }
          }
        }
      }
    },
    "actions": {
      "type": "array",
      "maxItems": 500,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "clientActionId",
          "actorId",
          "kind",
          "name",
          "runtimeRevision",
          "virtualNowMillis"
        ],
        "properties": {
          "clientActionId": {
            "type": "string"
          },
          "actorId": {
            "type": [
              "string",
              "null"
            ]
          },
          "kind": {
            "type": "string"
          },
          "name": {
            "type": "string"
          },
          "runtimeRevision": {
            "type": "integer"
          },
          "virtualNowMillis": {
            "type": "integer"
          }
        }
      }
    },
    "guestUrl": {
      "type": "string",
      "minLength": 1,
      "maxLength": 500
    },
    "canUseInternalFaults": {
      "type": "boolean"
    },
    "helpRequests": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "clockId",
        "coverage",
        "cases",
        "untrackedActorIds"
      ],
      "properties": {
        "clockId": {
          "type": "string",
          "pattern": "^clock:[a-f0-9]{64}$"
        },
        "coverage": {
          "const": "boundedSession"
        },
        "cases": {
          "type": "array",
          "maxItems": 500,
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
        "untrackedActorIds": {
          "type": "array",
          "maxItems": 50,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          }
        }
      }
    },
    "deliveryReviews": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "context",
        "coverage",
        "deliveries"
      ],
      "properties": {
        "context": {
          "allOf": [
            {
              "anyOf": [
                {
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
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "mode",
                    "rehearsalId",
                    "virtualEventId",
                    "clockId"
                  ],
                  "properties": {
                    "mode": {
                      "type": "string",
                      "const": "rehearsal"
                    },
                    "rehearsalId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    },
                    "virtualEventId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                    },
                    "clockId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 2000
                    }
                  }
                }
              ]
            },
            {
              "properties": {
                "mode": {
                  "const": "rehearsal"
                }
              }
            }
          ]
        },
        "coverage": {
          "const": "currentActorMessages"
        },
        "deliveries": {
          "type": "array",
          "maxItems": 50,
          "items": {
            "allOf": [
              {
                "oneOf": [
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "messageId",
                      "revision",
                      "reviewHash",
                      "createdAt",
                      "expiresAt",
                      "lifecycle",
                      "deliveryStatus",
                      "attempts",
                      "coordination",
                      "handling",
                      "availability",
                      "attendeeId",
                      "actions",
                      "purpose"
                    ],
                    "properties": {
                      "messageId": {
                        "type": "string",
                        "pattern": "^outbox:[a-f0-9]{64}$"
                      },
                      "revision": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 9007199254740991
                      },
                      "reviewHash": {
                        "type": "string",
                        "pattern": "^[a-f0-9]{64}$"
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
                      "lifecycle": {
                        "enum": [
                          "active",
                          "cancelled",
                          "superseded",
                          "responded"
                        ]
                      },
                      "deliveryStatus": {
                        "enum": [
                          "notSubmitted",
                          "reserved",
                          "unknown",
                          "accepted",
                          "delivered",
                          "read",
                          "failed",
                          "notDispatched",
                          "conflictingEvidence",
                          "revoked"
                        ]
                      },
                      "attempts": {
                        "type": "array",
                        "maxItems": 6,
                        "items": {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "channel",
                            "state",
                            "at"
                          ],
                          "properties": {
                            "channel": {
                              "enum": [
                                "sms",
                                "whatsapp",
                                "rcs"
                              ]
                            },
                            "state": {
                              "enum": [
                                "reserved",
                                "unknown",
                                "accepted",
                                "delivered",
                                "read",
                                "failed",
                                "notDispatched",
                                "revoked"
                              ]
                            },
                            "at": {
                              "type": "integer",
                              "minimum": 0,
                              "maximum": 9007199254740991
                            }
                          }
                        }
                      },
                      "coordination": {
                        "oneOf": [
                          {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "kind"
                            ],
                            "properties": {
                              "kind": {
                                "const": "untracked"
                              }
                            }
                          },
                          {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "kind",
                              "phase",
                              "reason",
                              "dueAt"
                            ],
                            "properties": {
                              "kind": {
                                "const": "tracked"
                              },
                              "phase": {
                                "enum": [
                                  "queued",
                                  "retry",
                                  "receipt",
                                  "review",
                                  "complete"
                                ]
                              },
                              "reason": {
                                "anyOf": [
                                  {
                                    "type": "string",
                                    "minLength": 1,
                                    "maxLength": 80
                                  },
                                  {
                                    "type": "null"
                                  }
                                ]
                              },
                              "dueAt": {
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
                              }
                            }
                          }
                        ]
                      },
                      "handling": {
                        "oneOf": [
                          {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "kind"
                            ],
                            "properties": {
                              "kind": {
                                "const": "automatic"
                              }
                            }
                          },
                          {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "kind",
                              "actorUid",
                              "at",
                              "authority"
                            ],
                            "properties": {
                              "kind": {
                                "const": "manual"
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
                      "actions": {
                        "type": "array",
                        "maxItems": 1,
                        "uniqueItems": true,
                        "items": {
                          "const": "manualHandoff"
                        }
                      },
                      "purpose": {
                        "enum": [
                          "joiningUpdate",
                          "joiningInstructions",
                          "planChanged",
                          "guestRequirement",
                          "assignmentChanged",
                          "participationCheck",
                          "eventCancelled",
                          "eventFinished",
                          "followUp"
                        ]
                      }
                    }
                  },
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "messageId",
                      "revision",
                      "reviewHash",
                      "createdAt",
                      "expiresAt",
                      "lifecycle",
                      "deliveryStatus",
                      "attempts",
                      "coordination",
                      "handling",
                      "availability",
                      "attendeeId",
                      "actions",
                      "purpose"
                    ],
                    "properties": {
                      "messageId": {
                        "type": "string",
                        "pattern": "^outbox:[a-f0-9]{64}$"
                      },
                      "revision": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 9007199254740991
                      },
                      "reviewHash": {
                        "type": "string",
                        "pattern": "^[a-f0-9]{64}$"
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
                      "lifecycle": {
                        "enum": [
                          "active",
                          "cancelled",
                          "superseded",
                          "responded"
                        ]
                      },
                      "deliveryStatus": {
                        "enum": [
                          "notSubmitted",
                          "reserved",
                          "unknown",
                          "accepted",
                          "delivered",
                          "read",
                          "failed",
                          "notDispatched",
                          "conflictingEvidence",
                          "revoked"
                        ]
                      },
                      "attempts": {
                        "type": "array",
                        "maxItems": 6,
                        "items": {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "channel",
                            "state",
                            "at"
                          ],
                          "properties": {
                            "channel": {
                              "enum": [
                                "sms",
                                "whatsapp",
                                "rcs"
                              ]
                            },
                            "state": {
                              "enum": [
                                "reserved",
                                "unknown",
                                "accepted",
                                "delivered",
                                "read",
                                "failed",
                                "notDispatched",
                                "revoked"
                              ]
                            },
                            "at": {
                              "type": "integer",
                              "minimum": 0,
                              "maximum": 9007199254740991
                            }
                          }
                        }
                      },
                      "coordination": {
                        "oneOf": [
                          {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "kind"
                            ],
                            "properties": {
                              "kind": {
                                "const": "untracked"
                              }
                            }
                          },
                          {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "kind",
                              "phase",
                              "reason",
                              "dueAt"
                            ],
                            "properties": {
                              "kind": {
                                "const": "tracked"
                              },
                              "phase": {
                                "enum": [
                                  "queued",
                                  "retry",
                                  "receipt",
                                  "review",
                                  "complete"
                                ]
                              },
                              "reason": {
                                "anyOf": [
                                  {
                                    "type": "string",
                                    "minLength": 1,
                                    "maxLength": 80
                                  },
                                  {
                                    "type": "null"
                                  }
                                ]
                              },
                              "dueAt": {
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
                              }
                            }
                          }
                        ]
                      },
                      "handling": {
                        "oneOf": [
                          {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "kind"
                            ],
                            "properties": {
                              "kind": {
                                "const": "automatic"
                              }
                            }
                          },
                          {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "kind",
                              "actorUid",
                              "at",
                              "authority"
                            ],
                            "properties": {
                              "kind": {
                                "const": "manual"
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
                      },
                      "availability": {
                        "const": "sourceChanged"
                      },
                      "attendeeId": {
                        "type": "null"
                      },
                      "actions": {
                        "type": "array",
                        "maxItems": 0,
                        "items": {
                          "const": "manualHandoff"
                        }
                      },
                      "purpose": {
                        "enum": [
                          "joiningUpdate",
                          "joiningInstructions",
                          "planChanged",
                          "guestRequirement",
                          "assignmentChanged",
                          "participationCheck",
                          "eventCancelled",
                          "eventFinished",
                          "followUp"
                        ]
                      }
                    }
                  }
                ]
              },
              {
                "properties": {
                  "availability": {
                    "const": "current"
                  },
                  "purpose": {
                    "const": "joiningUpdate"
                  },
                  "coordination": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "kind"
                    ],
                    "properties": {
                      "kind": {
                        "const": "untracked"
                      }
                    }
                  }
                }
              }
            ]
          }
        }
      }
    },
    "accountabilityReviews": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "clockId",
        "coverage",
        "rows"
      ],
      "properties": {
        "clockId": {
          "type": "string",
          "pattern": "^clock:[a-f0-9]{64}$"
        },
        "coverage": {
          "const": "boundedSession"
        },
        "rows": {
          "type": "array",
          "maxItems": 50,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "attendeeId",
              "episodeId",
              "sourceHash",
              "visitRevision",
              "checkedInAtMillis",
              "revision",
              "disposition",
              "availability",
              "canResolve"
            ],
            "properties": {
              "attendeeId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180
              },
              "episodeId": {
                "type": "string",
                "pattern": "^episode:[a-f0-9]{64}$"
              },
              "sourceHash": {
                "type": "string",
                "pattern": "^[a-f0-9]{64}$"
              },
              "visitRevision": {
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
              "checkedInAtMillis": {
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
              "revision": {
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
              },
              "availability": {
                "oneOf": [
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "kind"
                    ],
                    "properties": {
                      "kind": {
                        "const": "ready"
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
                        "const": "unavailable"
                      },
                      "reason": {
                        "enum": [
                          "notApplicable",
                          "notCheckedIn",
                          "visitNotRecorded",
                          "invalidSource"
                        ]
                      }
                    }
                  }
                ]
              },
              "canResolve": {
                "type": "boolean"
              }
            }
          }
        }
      }
    },
    "membershipReviews": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "clockId",
        "actorUid",
        "coverage",
        "receivingOperatorIds",
        "rows"
      ],
      "properties": {
        "clockId": {
          "type": "string",
          "pattern": "^clock:[a-f0-9]{64}$"
        },
        "actorUid": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "coverage": {
          "const": "boundedSession"
        },
        "receivingOperatorIds": {
          "type": "array",
          "uniqueItems": true,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "maxItems": 42
        },
        "rows": {
          "type": "array",
          "maxItems": 50,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
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
              "actions",
              "availability"
            ],
            "properties": {
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
              "availability": {
                "enum": [
                  "ready",
                  "notApplicable",
                  "participationNotRecorded",
                  "invalidSource"
                ]
              }
            }
          }
        }
      }
    },
    "movementReview": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "sessionId",
        "organizerId",
        "clockId",
        "setupRevision",
        "runtimeRevision",
        "actorUid",
        "serverTime",
        "groupId",
        "groups",
        "progress",
        "roster",
        "selected",
        "checkpoint",
        "history",
        "nextBeforeRevision"
      ],
      "properties": {
        "sessionId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "organizerId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "clockId": {
          "type": "string",
          "pattern": "^clock:[a-f0-9]{64}$"
        },
        "setupRevision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 2147483647
        },
        "runtimeRevision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 2147483647
        },
        "actorUid": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "serverTime": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "groupId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "groups": {
          "type": "array",
          "maxItems": 41,
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
                "maxLength": 180
              },
              "label": {
                "type": "string",
                "minLength": 1,
                "maxLength": 500
              }
            }
          }
        },
        "progress": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "revision",
            "sourceHash",
            "eventOpen",
            "runtimeLive",
            "destinations",
            "current",
            "guidance"
          ],
          "properties": {
            "revision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 500
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
            "destinations": {
              "type": "array",
              "maxItems": 41,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "target",
                  "label",
                  "text"
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
                    "maxLength": 500
                  },
                  "text": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 4000
                  }
                }
              }
            },
            "current": {
              "anyOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "sessionId",
                    "clockId",
                    "groupId",
                    "progressRevision",
                    "departure",
                    "report"
                  ],
                  "properties": {
                    "sessionId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180
                    },
                    "clockId": {
                      "type": "string",
                      "pattern": "^clock:[a-f0-9]{64}$"
                    },
                    "groupId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180
                    },
                    "progressRevision": {
                      "type": "integer",
                      "minimum": 1,
                      "maximum": 500
                    },
                    "departure": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "sourceHash",
                        "destination",
                        "confirmedAt",
                        "confirmedBy",
                        "operationId",
                        "roster",
                        "checkpointRequest"
                      ],
                      "properties": {
                        "sourceHash": {
                          "type": "string",
                          "pattern": "^[a-f0-9]{64}$"
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
                        "confirmedAt": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 9007199254740991
                        },
                        "confirmedBy": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 180
                        },
                        "operationId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 180
                        },
                        "roster": {
                          "anyOf": [
                            {
                              "type": "object",
                              "additionalProperties": false,
                              "required": [
                                "members",
                                "selectionHash"
                              ],
                              "properties": {
                                "members": {
                                  "type": "array",
                                  "maxItems": 50,
                                  "items": {
                                    "type": "object",
                                    "additionalProperties": false,
                                    "required": [
                                      "attendeeId",
                                      "displayName",
                                      "visitHash",
                                      "episodeId",
                                      "membershipHash"
                                    ],
                                    "properties": {
                                      "attendeeId": {
                                        "type": "string",
                                        "minLength": 1,
                                        "maxLength": 180
                                      },
                                      "displayName": {
                                        "type": "string",
                                        "minLength": 1,
                                        "maxLength": 180
                                      },
                                      "visitHash": {
                                        "type": "string",
                                        "pattern": "^[a-f0-9]{64}$"
                                      },
                                      "episodeId": {
                                        "anyOf": [
                                          {
                                            "type": "string",
                                            "pattern": "^episode:[a-f0-9]{64}$"
                                          },
                                          {
                                            "type": "null"
                                          }
                                        ]
                                      },
                                      "membershipHash": {
                                        "anyOf": [
                                          {
                                            "type": "string",
                                            "pattern": "^[a-f0-9]{64}$"
                                          },
                                          {
                                            "type": "null"
                                          }
                                        ]
                                      }
                                    }
                                  }
                                },
                                "selectionHash": {
                                  "type": "string",
                                  "pattern": "^[a-f0-9]{64}$"
                                }
                              }
                            },
                            {
                              "type": "null"
                            }
                          ]
                        },
                        "checkpointRequest": {
                          "anyOf": [
                            {
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
                            },
                            {
                              "type": "null"
                            }
                          ]
                        }
                      }
                    },
                    "report": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "revision",
                            "rosterHash",
                            "accountedFor",
                            "reportedAt",
                            "reportedBy",
                            "correctionReason"
                          ],
                          "properties": {
                            "revision": {
                              "type": "integer",
                              "minimum": 1,
                              "maximum": 9007199254740991
                            },
                            "rosterHash": {
                              "type": "string",
                              "pattern": "^[a-f0-9]{64}$"
                            },
                            "accountedFor": {
                              "type": "array",
                              "maxItems": 50,
                              "uniqueItems": true,
                              "items": {
                                "type": "string",
                                "minLength": 1,
                                "maxLength": 180
                              }
                            },
                            "reportedAt": {
                              "type": "integer",
                              "minimum": 0,
                              "maximum": 9007199254740991
                            },
                            "reportedBy": {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 180
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
                        {
                          "type": "null"
                        }
                      ]
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
            }
          }
        },
        "roster": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "sourceHash",
            "members",
            "unavailable",
            "coverage"
          ],
          "properties": {
            "sourceHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "members": {
              "type": "array",
              "maxItems": 50,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "attendeeId",
                  "displayName",
                  "visitHash",
                  "episodeId",
                  "membershipHash"
                ],
                "properties": {
                  "attendeeId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "displayName": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "visitHash": {
                    "type": "string",
                    "pattern": "^[a-f0-9]{64}$"
                  },
                  "episodeId": {
                    "anyOf": [
                      {
                        "type": "string",
                        "pattern": "^episode:[a-f0-9]{64}$"
                      },
                      {
                        "type": "null"
                      }
                    ]
                  },
                  "membershipHash": {
                    "anyOf": [
                      {
                        "type": "string",
                        "pattern": "^[a-f0-9]{64}$"
                      },
                      {
                        "type": "null"
                      }
                    ]
                  }
                }
              }
            },
            "unavailable": {
              "type": "array",
              "maxItems": 50,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "attendeeId",
                  "reason"
                ],
                "properties": {
                  "attendeeId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "reason": {
                    "enum": [
                      "notCheckedIn",
                      "participationUnavailable",
                      "membershipUnavailable",
                      "invalidSource"
                    ]
                  }
                }
              }
            },
            "coverage": {
              "const": "boundedSession"
            }
          }
        },
        "checkpoint": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "progressRevision",
                "checkpointId",
                "sourceHash",
                "revision",
                "availability",
                "report",
                "request",
                "departure"
              ],
              "properties": {
                "progressRevision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 500
                },
                "checkpointId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 2000
                },
                "sourceHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                },
                "revision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "availability": {
                  "oneOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "rosterId",
                        "label",
                        "reportStatus",
                        "members"
                      ],
                      "properties": {
                        "kind": {
                          "const": "ready"
                        },
                        "rosterId": {
                          "type": "string",
                          "pattern": "^departure-roster:[a-f0-9]{64}$"
                        },
                        "label": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 240
                        },
                        "reportStatus": {
                          "enum": [
                            "unreported",
                            "partial",
                            "complete"
                          ]
                        },
                        "members": {
                          "type": "array",
                          "maxItems": 1000,
                          "items": {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "attendeeId",
                              "observation",
                              "visit"
                            ],
                            "properties": {
                              "attendeeId": {
                                "type": "string",
                                "minLength": 1,
                                "maxLength": 160,
                                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                              },
                              "observation": {
                                "enum": [
                                  "accountedFor",
                                  "unconfirmed"
                                ]
                              },
                              "visit": {
                                "oneOf": [
                                  {
                                    "type": "object",
                                    "additionalProperties": false,
                                    "required": [
                                      "kind"
                                    ],
                                    "properties": {
                                      "kind": {
                                        "const": "current"
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
                                        "const": "unavailable"
                                      },
                                      "reason": {
                                        "enum": [
                                          "registrationMissing",
                                          "visitChanged",
                                          "notCheckedIn",
                                          "invalidSource"
                                        ]
                                      }
                                    }
                                  }
                                ]
                              },
                              "disposition": {
                                "description": "Visit-bound event accountability evidence. A resolved disposition never means arrival at this checkpoint.",
                                "oneOf": [
                                  {
                                    "type": "object",
                                    "additionalProperties": false,
                                    "required": [
                                      "kind"
                                    ],
                                    "properties": {
                                      "kind": {
                                        "const": "unresolved"
                                      }
                                    }
                                  },
                                  {
                                    "type": "object",
                                    "additionalProperties": false,
                                    "required": [
                                      "kind",
                                      "disposition",
                                      "revision",
                                      "resolvedAt",
                                      "resolvedBy",
                                      "sourceHash"
                                    ],
                                    "properties": {
                                      "kind": {
                                        "const": "resolved"
                                      },
                                      "disposition": {
                                        "enum": [
                                          "returned",
                                          "departed"
                                        ]
                                      },
                                      "revision": {
                                        "type": "integer",
                                        "minimum": 1,
                                        "maximum": 9007199254740991
                                      },
                                      "resolvedAt": {
                                        "type": "integer",
                                        "minimum": 0,
                                        "maximum": 9007199254740991
                                      },
                                      "resolvedBy": {
                                        "type": "string",
                                        "minLength": 1,
                                        "maxLength": 2000
                                      },
                                      "sourceHash": {
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
                                      "reason"
                                    ],
                                    "properties": {
                                      "kind": {
                                        "const": "unavailable"
                                      },
                                      "reason": {
                                        "enum": [
                                          "registrationMissing",
                                          "visitChanged",
                                          "notCheckedIn",
                                          "invalidSource",
                                          "beforeDeparture"
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
                        "reason"
                      ],
                      "properties": {
                        "kind": {
                          "const": "unavailable"
                        },
                        "reason": {
                          "enum": [
                            "rosterNotRecorded",
                            "destinationNotRecorded",
                            "differentCheckpoint",
                            "notCheckpoint",
                            "setupChanged"
                          ]
                        }
                      }
                    }
                  ]
                },
                "report": {
                  "anyOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "revision",
                        "rosterHash",
                        "accountedFor",
                        "reportedAt",
                        "reportedBy",
                        "correctionReason"
                      ],
                      "properties": {
                        "revision": {
                          "type": "integer",
                          "minimum": 1,
                          "maximum": 9007199254740991
                        },
                        "rosterHash": {
                          "type": "string",
                          "pattern": "^[a-f0-9]{64}$"
                        },
                        "accountedFor": {
                          "type": "array",
                          "maxItems": 50,
                          "uniqueItems": true,
                          "items": {
                            "type": "string",
                            "minLength": 1,
                            "maxLength": 180
                          }
                        },
                        "reportedAt": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 9007199254740991
                        },
                        "reportedBy": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 180
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
                    {
                      "type": "null"
                    }
                  ]
                },
                "request": {
                  "anyOf": [
                    {
                      "oneOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "responsibleOperatorId",
                            "dueAt",
                            "state",
                            "ownerAvailability"
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
                            },
                            "state": {
                              "enum": [
                                "awaitingReport",
                                "overdue",
                                "discrepancy",
                                "sourceUnavailable"
                              ]
                            },
                            "ownerAvailability": {
                              "enum": [
                                "current",
                                "needsReassignment"
                              ]
                            }
                          }
                        },
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "responsibleOperatorId",
                            "dueAt",
                            "state",
                            "ownerAvailability"
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
                            },
                            "state": {
                              "enum": [
                                "complete",
                                "closedOut"
                              ]
                            },
                            "ownerAvailability": {
                              "const": "notRequired"
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
                "departure": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "sourceHash",
                    "destination",
                    "confirmedAt",
                    "confirmedBy",
                    "operationId",
                    "roster",
                    "checkpointRequest"
                  ],
                  "properties": {
                    "sourceHash": {
                      "type": "string",
                      "pattern": "^[a-f0-9]{64}$"
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
                    "confirmedAt": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
                    },
                    "confirmedBy": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180
                    },
                    "operationId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180
                    },
                    "roster": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "members",
                            "selectionHash"
                          ],
                          "properties": {
                            "members": {
                              "type": "array",
                              "maxItems": 50,
                              "items": {
                                "type": "object",
                                "additionalProperties": false,
                                "required": [
                                  "attendeeId",
                                  "displayName",
                                  "visitHash",
                                  "episodeId",
                                  "membershipHash"
                                ],
                                "properties": {
                                  "attendeeId": {
                                    "type": "string",
                                    "minLength": 1,
                                    "maxLength": 180
                                  },
                                  "displayName": {
                                    "type": "string",
                                    "minLength": 1,
                                    "maxLength": 180
                                  },
                                  "visitHash": {
                                    "type": "string",
                                    "pattern": "^[a-f0-9]{64}$"
                                  },
                                  "episodeId": {
                                    "anyOf": [
                                      {
                                        "type": "string",
                                        "pattern": "^episode:[a-f0-9]{64}$"
                                      },
                                      {
                                        "type": "null"
                                      }
                                    ]
                                  },
                                  "membershipHash": {
                                    "anyOf": [
                                      {
                                        "type": "string",
                                        "pattern": "^[a-f0-9]{64}$"
                                      },
                                      {
                                        "type": "null"
                                      }
                                    ]
                                  }
                                }
                              }
                            },
                            "selectionHash": {
                              "type": "string",
                              "pattern": "^[a-f0-9]{64}$"
                            }
                          }
                        },
                        {
                          "type": "null"
                        }
                      ]
                    },
                    "checkpointRequest": {
                      "anyOf": [
                        {
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
                        },
                        {
                          "type": "null"
                        }
                      ]
                    }
                  }
                }
              }
            },
            {
              "type": "null"
            }
          ]
        },
        "history": {
          "type": "array",
          "maxItems": 25,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "progressRevision",
              "destination",
              "confirmedAt",
              "rosterSize",
              "reportRevision",
              "accountedForCount",
              "checkpointRequest"
            ],
            "properties": {
              "progressRevision": {
                "type": "integer",
                "minimum": 1,
                "maximum": 500
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
              "confirmedAt": {
                "type": "integer",
                "minimum": 0,
                "maximum": 9007199254740991
              },
              "rosterSize": {
                "anyOf": [
                  {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 50
                  },
                  {
                    "type": "null"
                  }
                ]
              },
              "reportRevision": {
                "type": "integer",
                "minimum": 0,
                "maximum": 9007199254740991
              },
              "accountedForCount": {
                "type": "integer",
                "minimum": 0,
                "maximum": 50
              },
              "checkpointRequest": {
                "anyOf": [
                  {
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
                  },
                  {
                    "type": "null"
                  }
                ]
              }
            }
          }
        },
        "nextBeforeRevision": {
          "anyOf": [
            {
              "type": "integer",
              "minimum": 1,
              "maximum": 501
            },
            {
              "type": "null"
            }
          ]
        },
        "selected": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "sessionId",
                "clockId",
                "groupId",
                "progressRevision",
                "departure",
                "report"
              ],
              "properties": {
                "sessionId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                "clockId": {
                  "type": "string",
                  "pattern": "^clock:[a-f0-9]{64}$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                "progressRevision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 500
                },
                "departure": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "sourceHash",
                    "destination",
                    "confirmedAt",
                    "confirmedBy",
                    "operationId",
                    "roster",
                    "checkpointRequest"
                  ],
                  "properties": {
                    "sourceHash": {
                      "type": "string",
                      "pattern": "^[a-f0-9]{64}$"
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
                    "confirmedAt": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
                    },
                    "confirmedBy": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180
                    },
                    "operationId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180
                    },
                    "roster": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "members",
                            "selectionHash"
                          ],
                          "properties": {
                            "members": {
                              "type": "array",
                              "maxItems": 50,
                              "items": {
                                "type": "object",
                                "additionalProperties": false,
                                "required": [
                                  "attendeeId",
                                  "displayName",
                                  "visitHash",
                                  "episodeId",
                                  "membershipHash"
                                ],
                                "properties": {
                                  "attendeeId": {
                                    "type": "string",
                                    "minLength": 1,
                                    "maxLength": 180
                                  },
                                  "displayName": {
                                    "type": "string",
                                    "minLength": 1,
                                    "maxLength": 180
                                  },
                                  "visitHash": {
                                    "type": "string",
                                    "pattern": "^[a-f0-9]{64}$"
                                  },
                                  "episodeId": {
                                    "anyOf": [
                                      {
                                        "type": "string",
                                        "pattern": "^episode:[a-f0-9]{64}$"
                                      },
                                      {
                                        "type": "null"
                                      }
                                    ]
                                  },
                                  "membershipHash": {
                                    "anyOf": [
                                      {
                                        "type": "string",
                                        "pattern": "^[a-f0-9]{64}$"
                                      },
                                      {
                                        "type": "null"
                                      }
                                    ]
                                  }
                                }
                              }
                            },
                            "selectionHash": {
                              "type": "string",
                              "pattern": "^[a-f0-9]{64}$"
                            }
                          }
                        },
                        {
                          "type": "null"
                        }
                      ]
                    },
                    "checkpointRequest": {
                      "anyOf": [
                        {
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
                        },
                        {
                          "type": "null"
                        }
                      ]
                    }
                  }
                },
                "report": {
                  "anyOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "revision",
                        "rosterHash",
                        "accountedFor",
                        "reportedAt",
                        "reportedBy",
                        "correctionReason"
                      ],
                      "properties": {
                        "revision": {
                          "type": "integer",
                          "minimum": 1,
                          "maximum": 9007199254740991
                        },
                        "rosterHash": {
                          "type": "string",
                          "pattern": "^[a-f0-9]{64}$"
                        },
                        "accountedFor": {
                          "type": "array",
                          "maxItems": 50,
                          "uniqueItems": true,
                          "items": {
                            "type": "string",
                            "minLength": 1,
                            "maxLength": 180
                          }
                        },
                        "reportedAt": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 9007199254740991
                        },
                        "reportedBy": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 180
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
                    {
                      "type": "null"
                    }
                  ]
                }
              }
            },
            {
              "type": "null"
            }
          ]
        }
      }
    }
  },
  "definitions": {
    "session": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "id",
        "organizerId",
        "sourceEventId",
        "scenarioId",
        "seed",
        "actorCount",
        "actionCount",
        "status",
        "setup",
        "setupRevision",
        "runtimeRevision",
        "activeStepIndex",
        "virtualNowMillis",
        "faultId",
        "expiresAtMillis",
        "virtualStartedAtMillis"
      ],
      "properties": {
        "id": {
          "type": "string"
        },
        "organizerId": {
          "type": "string"
        },
        "sourceEventId": {
          "type": [
            "string",
            "null"
          ]
        },
        "scenarioId": {
          "type": "string",
          "enum": [
            "smoothRun",
            "lateAndNoShow",
            "earlyExitAndReturn",
            "rosterAndCapacity",
            "walkInAndAmbiguousClaim",
            "privacyAndKeepApart",
            "lowConnectivity",
            "concurrentHosts",
            "revealInterrupted",
            "externalProfiles",
            "accountabilitySweep"
          ]
        },
        "seed": {
          "type": "integer"
        },
        "actorCount": {
          "type": "integer"
        },
        "actionCount": {
          "type": "integer",
          "minimum": 0,
          "maximum": 500
        },
        "status": {
          "type": "string",
          "enum": [
            "draft",
            "ready",
            "running",
            "paused",
            "complete",
            "expired"
          ]
        },
        "setup": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "title",
            "locationName",
            "durationMinutes",
            "hostGoal",
            "attendeePrompt",
            "moduleIds"
          ],
          "properties": {
            "title": {
              "type": "string",
              "minLength": 1,
              "maxLength": 120
            },
            "locationName": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "durationMinutes": {
              "type": "integer",
              "minimum": 30,
              "maximum": 360
            },
            "hostGoal": {
              "type": "string",
              "minLength": 1,
              "maxLength": 240
            },
            "attendeePrompt": {
              "type": "string",
              "minLength": 1,
              "maxLength": 320
            },
            "moduleIds": {
              "type": "array",
              "minItems": 1,
              "maxItems": 8,
              "uniqueItems": true,
              "items": {
                "type": "string",
                "enum": [
                  "arrival",
                  "firstHello",
                  "pods",
                  "rotations",
                  "conversationCues",
                  "reveal",
                  "afterglow",
                  "accountability"
                ]
              }
            },
            "movementSimulation": {
              "type": "object",
              "additionalProperties": false,
              "description": "Frozen, synthetic-only movement truth used by dress rehearsal. It never reads or writes a real person's live position.",
              "required": [
                "itinerary",
                "routePlan",
                "livePositions",
                "lateArrivalGuidance"
              ],
              "properties": {
                "itinerary": {
                  "type": "array",
                  "maxItems": 40,
                  "items": {
                    "type": "object",
                    "additionalProperties": false,
                    "description": "One public, event-local run-of-show entry. Offset is measured from the event start so rescheduling does not rewrite the itinerary.",
                    "required": [
                      "id",
                      "kind",
                      "offsetMinutes",
                      "title"
                    ],
                    "properties": {
                      "id": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 80,
                        "pattern": "^[A-Za-z0-9_-]+$"
                      },
                      "kind": {
                        "type": "string",
                        "enum": [
                          "gather",
                          "activity",
                          "stop",
                          "break",
                          "transition",
                          "finish"
                        ]
                      },
                      "offsetMinutes": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 1440
                      },
                      "durationMinutes": {
                        "type": [
                          "integer",
                          "null"
                        ],
                        "minimum": 1,
                        "maximum": 1440
                      },
                      "title": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 120
                      },
                      "description": {
                        "type": [
                          "string",
                          "null"
                        ],
                        "maxLength": 500
                      },
                      "location": {
                        "anyOf": [
                          {
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
                          },
                          {
                            "type": "null"
                          }
                        ]
                      },
                      "routeDistanceMeters": {
                        "type": [
                          "integer",
                          "null"
                        ],
                        "minimum": 0,
                        "maximum": 1000000
                      }
                    }
                  }
                },
                "routePlan": {
                  "anyOf": [
                    {
                      "type": "null"
                    },
                    {
                      "type": "object",
                      "description": "Composable operations for an event that moves through a route. Activity kind remains the broader format authority.",
                      "additionalProperties": false,
                      "required": [
                        "version",
                        "movementMode",
                        "routeShape",
                        "groupStrategy",
                        "stopCadence",
                        "stopKinds",
                        "roleKinds"
                      ],
                      "properties": {
                        "version": {
                          "type": "integer",
                          "enum": [
                            1,
                            2
                          ]
                        },
                        "movementMode": {
                          "type": "string",
                          "enum": [
                            "run",
                            "walk",
                            "ride",
                            "mixed"
                          ]
                        },
                        "routeShape": {
                          "type": "string",
                          "enum": [
                            "loop",
                            "outAndBack",
                            "pointToPoint"
                          ]
                        },
                        "groupStrategy": {
                          "type": "string",
                          "enum": [
                            "together",
                            "paceGroups",
                            "selfDirected"
                          ]
                        },
                        "stopCadence": {
                          "type": "string",
                          "enum": [
                            "continuous",
                            "flexibleStops",
                            "hostedStops"
                          ]
                        },
                        "stopKinds": {
                          "type": "array",
                          "minItems": 1,
                          "maxItems": 7,
                          "uniqueItems": true,
                          "items": {
                            "type": "string",
                            "enum": [
                              "water",
                              "regroup",
                              "venue",
                              "photoSpot",
                              "viewpoint",
                              "hazard",
                              "turnaround"
                            ]
                          }
                        },
                        "roleKinds": {
                          "type": "array",
                          "minItems": 1,
                          "maxItems": 6,
                          "uniqueItems": true,
                          "items": {
                            "type": "string",
                            "enum": [
                              "routeLead",
                              "sweep",
                              "pacer",
                              "stopHost",
                              "marshal",
                              "photographer"
                            ]
                          }
                        },
                        "path": {
                          "type": "array",
                          "minItems": 2,
                          "maxItems": 500,
                          "items": {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "latitude",
                              "longitude"
                            ],
                            "properties": {
                              "latitude": {
                                "type": "number",
                                "minimum": -90,
                                "maximum": 90
                              },
                              "longitude": {
                                "type": "number",
                                "minimum": -180,
                                "maximum": 180
                              }
                            }
                          }
                        },
                        "paceGroups": {
                          "type": "array",
                          "maxItems": 12,
                          "items": {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "id",
                              "label",
                              "sortOrder"
                            ],
                            "properties": {
                              "id": {
                                "type": "string",
                                "minLength": 1,
                                "maxLength": 80,
                                "pattern": "^[A-Za-z0-9_-]+$"
                              },
                              "label": {
                                "type": "string",
                                "minLength": 1,
                                "maxLength": 80
                              },
                              "targetPaceSecondsPerKm": {
                                "type": [
                                  "integer",
                                  "null"
                                ],
                                "minimum": 120,
                                "maximum": 1800
                              },
                              "sortOrder": {
                                "type": "integer",
                                "minimum": 0,
                                "maximum": 1000
                              }
                            }
                          }
                        },
                        "liveTrackingPolicy": {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "mode",
                            "staleAfterSeconds",
                            "retentionMinutes"
                          ],
                          "properties": {
                            "mode": {
                              "type": "string",
                              "enum": [
                                "disabled",
                                "hostOnly",
                                "authorizedOperators"
                              ]
                            },
                            "staleAfterSeconds": {
                              "type": "integer",
                              "minimum": 30,
                              "maximum": 600
                            },
                            "retentionMinutes": {
                              "type": "integer",
                              "minimum": 5,
                              "maximum": 1440
                            }
                          }
                        }
                      }
                    }
                  ]
                },
                "livePositions": {
                  "type": "array",
                  "maxItems": 2,
                  "items": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "role",
                      "latitude",
                      "longitude",
                      "recordedOffsetMinutes"
                    ],
                    "properties": {
                      "role": {
                        "type": "string",
                        "enum": [
                          "host",
                          "operator"
                        ]
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
                      "recordedOffsetMinutes": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 360
                      }
                    }
                  }
                },
                "lateArrivalGuidance": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "maxLength": 320
                }
              }
            }
          }
        },
        "setupRevision": {
          "type": "integer"
        },
        "runtimeRevision": {
          "type": "integer"
        },
        "activeStepIndex": {
          "type": "integer"
        },
        "virtualNowMillis": {
          "type": "integer"
        },
        "faultId": {
          "type": "string",
          "enum": [
            "none",
            "latency",
            "oneShotFailure",
            "listenerDisconnect",
            "staleRevision",
            "duplicateDelivery",
            "legacyFixture",
            "reducedMotion",
            "lowBandwidth"
          ]
        },
        "expiresAtMillis": {
          "type": "integer"
        },
        "virtualStartedAtMillis": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        }
      }
    },
    "actor": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "actorId",
        "displayName",
        "persona",
        "status",
        "guestMoment",
        "optedOut",
        "keepApartActorIds",
        "helpRequested",
        "promptCompleted",
        "layoutUnitId",
        "confirmedLayoutUnitId"
      ],
      "properties": {
        "actorId": {
          "type": "string"
        },
        "displayName": {
          "type": "string"
        },
        "persona": {
          "type": "string"
        },
        "status": {
          "type": "string",
          "enum": [
            "expected",
            "present",
            "late",
            "noShow",
            "departed",
            "returned",
            "disconnected",
            "walkIn",
            "ambiguousClaim"
          ]
        },
        "connectionState": {
          "type": "string",
          "enum": [
            "connected",
            "disconnected"
          ]
        },
        "guestMoment": {
          "type": "string",
          "enum": [
            "welcome",
            "checkIn",
            "firstHello",
            "assignment",
            "rotation",
            "pause",
            "reveal",
            "afterglow",
            "complete"
          ]
        },
        "optedOut": {
          "type": "boolean"
        },
        "keepApartActorIds": {
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "helpRequested": {
          "type": "boolean"
        },
        "promptCompleted": {
          "type": "boolean"
        },
        "layoutUnitId": {
          "type": [
            "string",
            "null"
          ]
        },
        "confirmedLayoutUnitId": {
          "type": [
            "string",
            "null"
          ]
        },
        "assistance": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "intention",
            "latestMessageId"
          ],
          "properties": {
            "intention": {
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
                      "const": "unknown"
                    }
                  }
                },
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "claimedEta"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "onMyWay"
                    },
                    "claimedEta": {
                      "anyOf": [
                        {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 9007199254740991,
                          "description": "UTC milliseconds."
                        },
                        {
                          "type": "null",
                          "const": null
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
                    "target"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "joinLater"
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
                      "const": "notComing"
                    }
                  }
                }
              ]
            },
            "latestMessageId": {
              "anyOf": [
                {
                  "type": "string",
                  "pattern": "^outbox:[a-f0-9]{64}$"
                },
                {
                  "type": "null"
                }
              ]
            }
          }
        },
        "assistanceMessage": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "messageId",
                "intentId",
                "intentRevision",
                "text",
                "choices",
                "lifecycle",
                "expiresAt",
                "canRespond",
                "responseChoiceId"
              ],
              "properties": {
                "messageId": {
                  "type": "string",
                  "pattern": "^outbox:[a-f0-9]{64}$"
                },
                "intentId": {
                  "type": "string"
                },
                "intentRevision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 9007199254740991
                },
                "text": {
                  "type": "string",
                  "maxLength": 2000
                },
                "choices": {
                  "type": "array",
                  "maxItems": 20,
                  "items": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "choiceId",
                      "label"
                    ],
                    "properties": {
                      "choiceId": {
                        "type": "string"
                      },
                      "label": {
                        "type": "string",
                        "maxLength": 80
                      }
                    }
                  }
                },
                "lifecycle": {
                  "type": "string",
                  "enum": [
                    "active",
                    "cancelled",
                    "superseded",
                    "responded"
                  ]
                },
                "expiresAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "canRespond": {
                  "type": "boolean"
                },
                "responseChoiceId": {
                  "anyOf": [
                    {
                      "type": "string"
                    },
                    {
                      "type": "null"
                    }
                  ]
                }
              }
            },
            {
              "type": "null"
            }
          ]
        },
        "assistanceDelivery": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "conflictingEvidence",
                "attempts"
              ],
              "properties": {
                "conflictingEvidence": {
                  "type": "boolean"
                },
                "attempts": {
                  "type": "array",
                  "maxItems": 6,
                  "items": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "attemptId",
                      "routeId",
                      "status"
                    ],
                    "properties": {
                      "attemptId": {
                        "type": "string"
                      },
                      "routeId": {
                        "type": "string",
                        "enum": [
                          "catchEventSms",
                          "catchEventRcs",
                          "organizerEventWhatsapp"
                        ]
                      },
                      "status": {
                        "type": "string",
                        "enum": [
                          "notDispatched",
                          "reserved",
                          "unknown",
                          "accepted",
                          "delivered",
                          "read",
                          "failed",
                          "revoked"
                        ]
                      }
                    }
                  }
                }
              }
            },
            {
              "type": "null"
            }
          ]
        },
        "assistanceAutomation": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "clockId",
            "status",
            "plan",
            "outcomes",
            "nextOutcomeIndex",
            "evaluation"
          ],
          "properties": {
            "clockId": {
              "type": "string",
              "pattern": "^clock:[a-f0-9]{64}$"
            },
            "status": {
              "type": "string",
              "enum": [
                "enabled",
                "paused"
              ]
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
            },
            "nextOutcomeIndex": {
              "type": "integer",
              "minimum": 0,
              "maximum": 6
            },
            "evaluation": {
              "anyOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "at",
                    "policy",
                    "delivery"
                  ],
                  "properties": {
                    "at": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
                    },
                    "policy": {
                      "anyOf": [
                        {
                          "anyOf": [
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
                                  "const": "resolved"
                                },
                                "reason": {
                                  "type": "string",
                                  "enum": [
                                    "joined",
                                    "declined"
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
                                  "const": "cancelled"
                                },
                                "reason": {
                                  "type": "string",
                                  "enum": [
                                    "eventClosed",
                                    "notAdmitted",
                                    "policyDisabled",
                                    "participationInactive"
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
                                  "const": "expired"
                                },
                                "reason": {
                                  "type": "string",
                                  "enum": [
                                    "cutoff",
                                    "lateEntryClosed"
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
                                  "const": "wait"
                                },
                                "reason": {
                                  "type": "string",
                                  "enum": [
                                    "departureUnconfirmed",
                                    "attendanceUnknown",
                                    "guidanceUnavailable",
                                    "throttled",
                                    "unchanged",
                                    "participationUnknown"
                                  ]
                                }
                              }
                            },
                            {
                              "type": "object",
                              "additionalProperties": false,
                              "required": [
                                "kind",
                                "reason",
                                "guidance"
                              ],
                              "properties": {
                                "kind": {
                                  "type": "string",
                                  "const": "hostDecision"
                                },
                                "reason": {
                                  "type": "string",
                                  "enum": [
                                    "unreachable",
                                    "entryDecision",
                                    "missingInformation"
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
                                      "type": "null",
                                      "const": null
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
                                "guidance",
                                "messageKey",
                                "shouldSend",
                                "nextEvaluationAt"
                              ],
                              "properties": {
                                "kind": {
                                  "type": "string",
                                  "const": "update"
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
                                "messageKey": {
                                  "type": "string",
                                  "minLength": 1,
                                  "maxLength": 2000
                                },
                                "shouldSend": {
                                  "type": "boolean"
                                },
                                "nextEvaluationAt": {
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
                    "delivery": {
                      "oneOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind"
                          ],
                          "properties": {
                            "kind": {
                              "const": "paused"
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
                              "const": "notApplicable"
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
                              "const": "scriptExhausted"
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
                              "const": "stop"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "responded",
                                "cancelled",
                                "superseded",
                                "expired",
                                "eventClosed",
                                "permissionRevoked",
                                "guestPresent",
                                "guestDeclined",
                                "notAdmitted",
                                "hostStopped",
                                "participationInactive"
                              ]
                            }
                          }
                        },
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "attemptIds"
                          ],
                          "properties": {
                            "kind": {
                              "const": "delivered"
                            },
                            "attemptIds": {
                              "type": "array",
                              "maxItems": 6,
                              "items": {
                                "type": "string"
                              }
                            }
                          }
                        },
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "attemptIds",
                            "notBefore"
                          ],
                          "properties": {
                            "kind": {
                              "const": "reconcile"
                            },
                            "attemptIds": {
                              "type": "array",
                              "maxItems": 6,
                              "items": {
                                "type": "string"
                              }
                            },
                            "notBefore": {
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
                            "reason"
                          ],
                          "properties": {
                            "kind": {
                              "const": "refreshFacts"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "eventFactsStale",
                                "routeFactsStale"
                              ]
                            }
                          }
                        },
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "notBefore",
                            "reason"
                          ],
                          "properties": {
                            "kind": {
                              "const": "wait"
                            },
                            "notBefore": {
                              "type": "integer",
                              "minimum": 0,
                              "maximum": 9007199254740991
                            },
                            "reason": {
                              "const": "retryBackoff"
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
                              "const": "hostDecision"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "noEligibleRoute",
                                "attemptLimit",
                                "policyRejected",
                                "recipientNeedsReview",
                                "providerOwnsFallback",
                                "conflictingDeliveryEvidence",
                                "historyUnavailable"
                              ]
                            }
                          }
                        }
                      ]
                    }
                  }
                },
                {
                  "type": "null"
                }
              ]
            }
          }
        }
      }
    },
    "action": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "clientActionId",
        "actorId",
        "kind",
        "name",
        "runtimeRevision",
        "virtualNowMillis"
      ],
      "properties": {
        "clientActionId": {
          "type": "string"
        },
        "actorId": {
          "type": [
            "string",
            "null"
          ]
        },
        "kind": {
          "type": "string"
        },
        "name": {
          "type": "string"
        },
        "runtimeRevision": {
          "type": "integer"
        },
        "virtualNowMillis": {
          "type": "integer"
        }
      }
    }
  }
} as const;
