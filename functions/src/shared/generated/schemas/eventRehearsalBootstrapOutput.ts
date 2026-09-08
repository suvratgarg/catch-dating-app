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
        "expiresAtMillis"
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
        "expiresAtMillis"
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
