/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventRehearsalGuestBootstrapCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/event_rehearsal_guest_bootstrap_response.schema.json",
  "title": "EventRehearsalGuestBootstrapCallableResponse",
  "description": "Sanitized anonymous guest projection for a rehearsal.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "slotToken",
    "session",
    "actor",
    "practiceBanner"
  ],
  "properties": {
    "slotToken": {
      "type": "string"
    },
    "practiceBanner": {
      "type": "string"
    },
    "session": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "title",
        "locationName",
        "status",
        "activeStepIndex",
        "virtualNowMillis",
        "attendeePrompt",
        "moduleIds",
        "runtimeRevision",
        "faultId"
      ],
      "properties": {
        "title": {
          "type": "string"
        },
        "locationName": {
          "type": "string"
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
        "activeStepIndex": {
          "type": "integer"
        },
        "virtualNowMillis": {
          "type": "integer"
        },
        "attendeePrompt": {
          "type": "string"
        },
        "moduleIds": {
          "type": "array",
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
        "runtimeRevision": {
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
    "actor": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "actorId",
        "displayName",
        "status",
        "guestMoment",
        "optedOut",
        "helpRequested",
        "promptCompleted"
      ],
      "properties": {
        "actorId": {
          "type": "string"
        },
        "displayName": {
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
        "helpRequested": {
          "type": "boolean"
        },
        "promptCompleted": {
          "type": "boolean"
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
        }
      }
    }
  }
} as const;
