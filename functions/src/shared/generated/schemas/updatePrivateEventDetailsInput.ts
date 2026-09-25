/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const updatePrivateEventDetailsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/update_private_event_details_payload.schema.json",
  "title": "UpdatePrivateEventDetailsCallablePayload",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "eventId",
    "requestId",
    "expectedSetupRevision",
    "reviewedDefaultsHash",
    "details"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "requestId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{7,127}$"
    },
    "expectedSetupRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 999999999
    },
    "reviewedDefaultsHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "details": {
      "type": "object",
      "additionalProperties": false,
      "required": [],
      "properties": {
        "durationMinutes": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode",
                "value"
              ],
              "properties": {
                "mode": {
                  "const": "set",
                  "type": "string"
                },
                "value": {
                  "type": "integer",
                  "minimum": 15,
                  "maximum": 240
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode"
              ],
              "properties": {
                "mode": {
                  "const": "clear",
                  "type": "string"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode"
              ],
              "properties": {
                "mode": {
                  "const": "inherit",
                  "type": "string"
                }
              }
            }
          ]
        },
        "venue": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode",
                "value"
              ],
              "properties": {
                "mode": {
                  "const": "set",
                  "type": "string"
                },
                "value": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "name"
                  ],
                  "properties": {
                    "name": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 240
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode"
              ],
              "properties": {
                "mode": {
                  "const": "clear",
                  "type": "string"
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode"
              ],
              "properties": {
                "mode": {
                  "const": "inherit",
                  "type": "string"
                }
              }
            }
          ]
        },
        "eventFormat": {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode",
                "value"
              ],
              "properties": {
                "mode": {
                  "const": "set",
                  "type": "string"
                },
                "value": {
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
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode"
              ],
              "properties": {
                "mode": {
                  "const": "clear",
                  "type": "string"
                }
              }
            }
          ]
        }
      },
      "minProperties": 1
    }
  }
} as const;
