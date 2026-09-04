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
        "guestSource": {
          "type": "string",
          "enum": [
            "simulated",
            "event"
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
              "maxLength": 300
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
            "eventFormat": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "version",
                "activityKind",
                "interactionModel"
              ],
              "properties": {
                "version": {
                  "type": "integer",
                  "const": 1
                },
                "activityKind": {
                  "type": "string",
                  "enum": [
                    "socialRun",
                    "running",
                    "walking",
                    "pickleball",
                    "padel",
                    "tennis",
                    "badminton",
                    "cycling",
                    "spinClass",
                    "yoga",
                    "strengthTraining",
                    "pubQuiz",
                    "barCrawl",
                    "dinner",
                    "singlesMixer",
                    "openActivity"
                  ]
                },
                "interactionModel": {
                  "type": "string",
                  "enum": [
                    "pacePods",
                    "pairedRotations",
                    "teamRotations",
                    "seatedTable",
                    "freeFormMixer",
                    "hostLedProgram",
                    "openFormat"
                  ]
                },
                "customActivityLabel": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 80
                },
                "defaultPlaybookId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 120
                },
                "defaultModuleIds": {
                  "type": "array",
                  "items": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 120
                  },
                  "maxItems": 30,
                  "uniqueItems": true
                },
                "eventSuccessPrimitives": {
                  "type": "object",
                  "additionalProperties": false,
                  "description": "Optional event-success behavior primitives for custom or unsupported activity formats. These fields translate a saved event format into the small set of primitives event success can reason about.",
                  "properties": {
                    "phoneAvailability": {
                      "type": "string",
                      "enum": [
                        "continuous",
                        "plannedPauses",
                        "arrivalAndPostEventOnly",
                        "hostOnlyLive",
                        "noneDuringActivity"
                      ]
                    },
                    "rotationSuitability": {
                      "type": "string",
                      "enum": [
                        "none",
                        "plannedBreaks",
                        "continuousRounds"
                      ]
                    },
                    "assignmentAlgorithm": {
                      "type": "string",
                      "enum": [
                        "none",
                        "pacePods",
                        "socialPods",
                        "pairRotations",
                        "teamBalancer",
                        "tableSeating"
                      ]
                    },
                    "compatibilityPolicy": {
                      "type": "string",
                      "enum": [
                        "none",
                        "socialCohortBalance",
                        "mutualInterestOnly",
                        "questionnaireClueOnly"
                      ]
                    },
                    "matchingObjective": {
                      "type": "string",
                      "enum": [
                        "coverage",
                        "romantic",
                        "affinity",
                        "novelty",
                        "balance",
                        "spread"
                      ]
                    },
                    "unitOutcome": {
                      "type": "string",
                      "enum": [
                        "none",
                        "completion",
                        "score",
                        "rank"
                      ]
                    },
                    "accountability": {
                      "type": "string",
                      "enum": [
                        "none",
                        "rollCall",
                        "sweep"
                      ]
                    },
                    "durationShape": {
                      "type": "string",
                      "enum": [
                        "continuous",
                        "rounds",
                        "courses",
                        "segments"
                      ]
                    }
                  }
                },
                "activityDetails": {
                  "type": "object",
                  "additionalProperties": true,
                  "properties": {
                    "routePlan": {
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
                  }
                }
              }
            },
            "successDefaults": {
              "type": "object",
              "additionalProperties": false,
              "properties": {
                "enabled": {
                  "type": "boolean"
                },
                "layoutId": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$"
                },
                "playbookId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 120
                },
                "selectedModuleIds": {
                  "type": "array",
                  "maxItems": 24,
                  "items": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 120
                  }
                },
                "moduleSelectionConfigured": {
                  "type": "boolean"
                },
                "structureConfig": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "unitKind",
                    "unitSize",
                    "revealCountdownSeconds"
                  ],
                  "properties": {
                    "unitKind": {
                      "type": "string",
                      "enum": [
                        "wholeGroup",
                        "pods",
                        "pairs",
                        "teams",
                        "tables"
                      ]
                    },
                    "unitSize": {
                      "type": "integer",
                      "minimum": 1,
                      "maximum": 1000
                    },
                    "unitCount": {
                      "type": [
                        "integer",
                        "null"
                      ],
                      "minimum": 1,
                      "maximum": 200
                    },
                    "rotationIntervalMinutes": {
                      "type": [
                        "integer",
                        "null"
                      ],
                      "minimum": 5,
                      "maximum": 180
                    },
                    "topology": {
                      "type": "string",
                      "enum": [
                        "set",
                        "sequence",
                        "adjacency"
                      ]
                    },
                    "resourceCapacity": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "concurrentUnits",
                            "resourceLabelId",
                            "seatsPerUnit"
                          ],
                          "properties": {
                            "concurrentUnits": {
                              "type": [
                                "integer",
                                "null"
                              ],
                              "minimum": 1,
                              "maximum": 200
                            },
                            "resourceLabelId": {
                              "type": "string",
                              "enum": [
                                "court",
                                "table",
                                "lane",
                                "board"
                              ]
                            },
                            "seatsPerUnit": {
                              "type": [
                                "integer",
                                "null"
                              ],
                              "minimum": 1,
                              "maximum": 1000
                            }
                          }
                        },
                        {
                          "type": "null"
                        }
                      ]
                    },
                    "revealCountdownSeconds": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 60
                    },
                    "rotationRepeatStrategy": {
                      "type": "string",
                      "enum": [
                        "avoid",
                        "allowWhenExhausted"
                      ]
                    },
                    "maxPairMeetings": {
                      "type": "integer",
                      "minimum": 1,
                      "maximum": 10
                    },
                    "balanceActivityAttributes": {
                      "type": "array",
                      "maxItems": 8,
                      "uniqueItems": true,
                      "items": {
                        "type": "string",
                        "enum": [
                          "paceBand",
                          "skillBand",
                          "roleBand"
                        ]
                      }
                    },
                    "clusterActivityAttributes": {
                      "type": "array",
                      "maxItems": 8,
                      "uniqueItems": true,
                      "items": {
                        "type": "string",
                        "enum": [
                          "paceBand",
                          "skillBand",
                          "roleBand"
                        ]
                      }
                    }
                  },
                  "allOf": [
                    {
                      "if": {
                        "required": [
                          "resourceCapacity"
                        ],
                        "properties": {
                          "resourceCapacity": {
                            "type": "object",
                            "required": [
                              "seatsPerUnit"
                            ],
                            "properties": {
                              "seatsPerUnit": {
                                "type": "integer"
                              }
                            }
                          }
                        }
                      },
                      "then": {
                        "required": [
                          "topology"
                        ],
                        "properties": {
                          "topology": {
                            "const": "adjacency"
                          }
                        }
                      }
                    }
                  ]
                },
                "hostGoal": {
                  "type": "string",
                  "maxLength": 300
                },
                "wingmanRequestsEnabled": {
                  "type": "boolean"
                },
                "contextualOpenersEnabled": {
                  "type": "boolean"
                },
                "compatibilityAffectsRanking": {
                  "type": "boolean"
                },
                "questionnaireConfig": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "templateId"
                  ],
                  "properties": {
                    "templateId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 120
                    },
                    "customTitle": {
                      "type": [
                        "string",
                        "null"
                      ],
                      "maxLength": 80
                    },
                    "customQuestions": {
                      "type": "array",
                      "maxItems": 8,
                      "items": {
                        "type": "object",
                        "additionalProperties": false,
                        "required": [
                          "id",
                          "prompt",
                          "options"
                        ],
                        "properties": {
                          "id": {
                            "type": "string",
                            "minLength": 1,
                            "maxLength": 120
                          },
                          "prompt": {
                            "type": "string",
                            "minLength": 1,
                            "maxLength": 140
                          },
                          "options": {
                            "type": "array",
                            "minItems": 2,
                            "maxItems": 5,
                            "items": {
                              "type": "object",
                              "additionalProperties": false,
                              "required": [
                                "id",
                                "label"
                              ],
                              "properties": {
                                "id": {
                                  "type": "string",
                                  "minLength": 1,
                                  "maxLength": 120
                                },
                                "label": {
                                  "type": "string",
                                  "minLength": 1,
                                  "maxLength": 80
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                },
                "attendeePrompt": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "maxLength": 300
                }
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
        "guestSource": {
          "type": "string",
          "enum": [
            "simulated",
            "event"
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
              "maxLength": 300
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
            "eventFormat": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "version",
                "activityKind",
                "interactionModel"
              ],
              "properties": {
                "version": {
                  "type": "integer",
                  "const": 1
                },
                "activityKind": {
                  "type": "string",
                  "enum": [
                    "socialRun",
                    "running",
                    "walking",
                    "pickleball",
                    "padel",
                    "tennis",
                    "badminton",
                    "cycling",
                    "spinClass",
                    "yoga",
                    "strengthTraining",
                    "pubQuiz",
                    "barCrawl",
                    "dinner",
                    "singlesMixer",
                    "openActivity"
                  ]
                },
                "interactionModel": {
                  "type": "string",
                  "enum": [
                    "pacePods",
                    "pairedRotations",
                    "teamRotations",
                    "seatedTable",
                    "freeFormMixer",
                    "hostLedProgram",
                    "openFormat"
                  ]
                },
                "customActivityLabel": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 80
                },
                "defaultPlaybookId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 120
                },
                "defaultModuleIds": {
                  "type": "array",
                  "items": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 120
                  },
                  "maxItems": 30,
                  "uniqueItems": true
                },
                "eventSuccessPrimitives": {
                  "type": "object",
                  "additionalProperties": false,
                  "description": "Optional event-success behavior primitives for custom or unsupported activity formats. These fields translate a saved event format into the small set of primitives event success can reason about.",
                  "properties": {
                    "phoneAvailability": {
                      "type": "string",
                      "enum": [
                        "continuous",
                        "plannedPauses",
                        "arrivalAndPostEventOnly",
                        "hostOnlyLive",
                        "noneDuringActivity"
                      ]
                    },
                    "rotationSuitability": {
                      "type": "string",
                      "enum": [
                        "none",
                        "plannedBreaks",
                        "continuousRounds"
                      ]
                    },
                    "assignmentAlgorithm": {
                      "type": "string",
                      "enum": [
                        "none",
                        "pacePods",
                        "socialPods",
                        "pairRotations",
                        "teamBalancer",
                        "tableSeating"
                      ]
                    },
                    "compatibilityPolicy": {
                      "type": "string",
                      "enum": [
                        "none",
                        "socialCohortBalance",
                        "mutualInterestOnly",
                        "questionnaireClueOnly"
                      ]
                    },
                    "matchingObjective": {
                      "type": "string",
                      "enum": [
                        "coverage",
                        "romantic",
                        "affinity",
                        "novelty",
                        "balance",
                        "spread"
                      ]
                    },
                    "unitOutcome": {
                      "type": "string",
                      "enum": [
                        "none",
                        "completion",
                        "score",
                        "rank"
                      ]
                    },
                    "accountability": {
                      "type": "string",
                      "enum": [
                        "none",
                        "rollCall",
                        "sweep"
                      ]
                    },
                    "durationShape": {
                      "type": "string",
                      "enum": [
                        "continuous",
                        "rounds",
                        "courses",
                        "segments"
                      ]
                    }
                  }
                },
                "activityDetails": {
                  "type": "object",
                  "additionalProperties": true,
                  "properties": {
                    "routePlan": {
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
                  }
                }
              }
            },
            "successDefaults": {
              "type": "object",
              "additionalProperties": false,
              "properties": {
                "enabled": {
                  "type": "boolean"
                },
                "layoutId": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$"
                },
                "playbookId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 120
                },
                "selectedModuleIds": {
                  "type": "array",
                  "maxItems": 24,
                  "items": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 120
                  }
                },
                "moduleSelectionConfigured": {
                  "type": "boolean"
                },
                "structureConfig": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "unitKind",
                    "unitSize",
                    "revealCountdownSeconds"
                  ],
                  "properties": {
                    "unitKind": {
                      "type": "string",
                      "enum": [
                        "wholeGroup",
                        "pods",
                        "pairs",
                        "teams",
                        "tables"
                      ]
                    },
                    "unitSize": {
                      "type": "integer",
                      "minimum": 1,
                      "maximum": 1000
                    },
                    "unitCount": {
                      "type": [
                        "integer",
                        "null"
                      ],
                      "minimum": 1,
                      "maximum": 200
                    },
                    "rotationIntervalMinutes": {
                      "type": [
                        "integer",
                        "null"
                      ],
                      "minimum": 5,
                      "maximum": 180
                    },
                    "topology": {
                      "type": "string",
                      "enum": [
                        "set",
                        "sequence",
                        "adjacency"
                      ]
                    },
                    "resourceCapacity": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "concurrentUnits",
                            "resourceLabelId",
                            "seatsPerUnit"
                          ],
                          "properties": {
                            "concurrentUnits": {
                              "type": [
                                "integer",
                                "null"
                              ],
                              "minimum": 1,
                              "maximum": 200
                            },
                            "resourceLabelId": {
                              "type": "string",
                              "enum": [
                                "court",
                                "table",
                                "lane",
                                "board"
                              ]
                            },
                            "seatsPerUnit": {
                              "type": [
                                "integer",
                                "null"
                              ],
                              "minimum": 1,
                              "maximum": 1000
                            }
                          }
                        },
                        {
                          "type": "null"
                        }
                      ]
                    },
                    "revealCountdownSeconds": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 60
                    },
                    "rotationRepeatStrategy": {
                      "type": "string",
                      "enum": [
                        "avoid",
                        "allowWhenExhausted"
                      ]
                    },
                    "maxPairMeetings": {
                      "type": "integer",
                      "minimum": 1,
                      "maximum": 10
                    },
                    "balanceActivityAttributes": {
                      "type": "array",
                      "maxItems": 8,
                      "uniqueItems": true,
                      "items": {
                        "type": "string",
                        "enum": [
                          "paceBand",
                          "skillBand",
                          "roleBand"
                        ]
                      }
                    },
                    "clusterActivityAttributes": {
                      "type": "array",
                      "maxItems": 8,
                      "uniqueItems": true,
                      "items": {
                        "type": "string",
                        "enum": [
                          "paceBand",
                          "skillBand",
                          "roleBand"
                        ]
                      }
                    }
                  },
                  "allOf": [
                    {
                      "if": {
                        "required": [
                          "resourceCapacity"
                        ],
                        "properties": {
                          "resourceCapacity": {
                            "type": "object",
                            "required": [
                              "seatsPerUnit"
                            ],
                            "properties": {
                              "seatsPerUnit": {
                                "type": "integer"
                              }
                            }
                          }
                        }
                      },
                      "then": {
                        "required": [
                          "topology"
                        ],
                        "properties": {
                          "topology": {
                            "const": "adjacency"
                          }
                        }
                      }
                    }
                  ]
                },
                "hostGoal": {
                  "type": "string",
                  "maxLength": 300
                },
                "wingmanRequestsEnabled": {
                  "type": "boolean"
                },
                "contextualOpenersEnabled": {
                  "type": "boolean"
                },
                "compatibilityAffectsRanking": {
                  "type": "boolean"
                },
                "questionnaireConfig": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "templateId"
                  ],
                  "properties": {
                    "templateId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 120
                    },
                    "customTitle": {
                      "type": [
                        "string",
                        "null"
                      ],
                      "maxLength": 80
                    },
                    "customQuestions": {
                      "type": "array",
                      "maxItems": 8,
                      "items": {
                        "type": "object",
                        "additionalProperties": false,
                        "required": [
                          "id",
                          "prompt",
                          "options"
                        ],
                        "properties": {
                          "id": {
                            "type": "string",
                            "minLength": 1,
                            "maxLength": 120
                          },
                          "prompt": {
                            "type": "string",
                            "minLength": 1,
                            "maxLength": 140
                          },
                          "options": {
                            "type": "array",
                            "minItems": 2,
                            "maxItems": 5,
                            "items": {
                              "type": "object",
                              "additionalProperties": false,
                              "required": [
                                "id",
                                "label"
                              ],
                              "properties": {
                                "id": {
                                  "type": "string",
                                  "minLength": 1,
                                  "maxLength": 120
                                },
                                "label": {
                                  "type": "string",
                                  "minLength": 1,
                                  "maxLength": 80
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                },
                "attendeePrompt": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "maxLength": 300
                }
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
