/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const privateEventSetupCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/private_event_setup_response.schema.json",
  "title": "PrivateEventSetupCallableResponse",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "organizerId",
    "setupRevision",
    "name",
    "city",
    "localDate",
    "localStartTime",
    "timezone",
    "startTimeMillis",
    "publicationState",
    "status",
    "setupDefaults",
    "detailsConfigured",
    "eventPreferences",
    "eventDetails"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "setupRevision": {
      "type": "integer",
      "minimum": 1
    },
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "city": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "cityId",
        "marketId"
      ],
      "properties": {
        "cityId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "marketId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        }
      }
    },
    "localDate": {
      "type": "string",
      "pattern": "^[0-9]{4}-[0-9]{2}-[0-9]{2}$"
    },
    "localStartTime": {
      "type": "string",
      "pattern": "^[0-9]{2}:[0-9]{2}$"
    },
    "timezone": {
      "type": "string",
      "minLength": 1,
      "maxLength": 100
    },
    "startTimeMillis": {
      "type": "integer"
    },
    "publicationState": {
      "type": "string",
      "const": "private"
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "cancelled"
      ]
    },
    "setupDefaults": {
      "title": "EventSetupDefaults",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "city",
        "timezone",
        "organizerDefaultsRevision",
        "organizerDefaultsHash"
      ],
      "properties": {
        "city": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "value",
            "source"
          ],
          "properties": {
            "value": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "cityId",
                "marketId"
              ],
              "properties": {
                "cityId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                "marketId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                }
              }
            },
            "source": {
              "type": "string",
              "enum": [
                "organizer",
                "event"
              ]
            }
          }
        },
        "timezone": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "value",
            "source"
          ],
          "properties": {
            "value": {
              "type": "string",
              "minLength": 1,
              "maxLength": 100
            },
            "source": {
              "type": "string",
              "enum": [
                "organizer",
                "event"
              ]
            }
          }
        },
        "organizerDefaultsRevision": {
          "type": [
            "integer",
            "null"
          ],
          "minimum": 0
        },
        "organizerDefaultsHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        }
      },
      "definitions": {
        "basicsInput": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "name",
            "city",
            "localDate",
            "localStartTime",
            "timezone"
          ],
          "properties": {
            "name": {
              "type": "string",
              "minLength": 1,
              "maxLength": 120
            },
            "city": {
              "oneOf": [
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
                },
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
                        "cityId",
                        "marketId"
                      ],
                      "properties": {
                        "cityId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 180
                        },
                        "marketId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 180
                        }
                      }
                    }
                  }
                }
              ]
            },
            "localDate": {
              "type": "string",
              "pattern": "^[0-9]{4}-[0-9]{2}-[0-9]{2}$"
            },
            "localStartTime": {
              "type": "string",
              "pattern": "^[0-9]{2}:[0-9]{2}$"
            },
            "timezone": {
              "oneOf": [
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
                },
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
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 100
                    }
                  }
                }
              ]
            },
            "reviewedDefaultsHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            }
          }
        }
      }
    },
    "detailsConfigured": {
      "type": "boolean"
    },
    "eventPreferences": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "revision",
            "preferences",
            "paymentTerms"
          ],
          "properties": {
            "revision": {
              "type": "integer",
              "minimum": 1,
              "maximum": 1000000000
            },
            "preferences": {
              "title": "ResolvedEventPreferences",
              "type": "object",
              "additionalProperties": false,
              "required": [
                "defaultsRevision",
                "defaultsHash",
                "usualDurationMinutes",
                "preferredVenueId",
                "offerValidityMinutes",
                "collectionPreference",
                "currency",
                "offerMessageTemplate",
                "paymentInstructions",
                "reusablePaymentPage",
                "admissionPreset",
                "expectedAmountMinor"
              ],
              "properties": {
                "defaultsRevision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 1000000000
                },
                "defaultsHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                },
                "usualDurationMinutes": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "value",
                    "source"
                  ],
                  "properties": {
                    "value": {
                      "anyOf": [
                        {
                          "type": "integer",
                          "minimum": 15,
                          "maximum": 240
                        },
                        {
                          "type": "null"
                        }
                      ]
                    },
                    "source": {
                      "type": "string",
                      "enum": [
                        "organizer",
                        "event",
                        "cleared"
                      ]
                    }
                  }
                },
                "preferredVenueId": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "value",
                    "source"
                  ],
                  "properties": {
                    "value": {
                      "anyOf": [
                        {
                          "type": "string",
                          "pattern": "^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$"
                        },
                        {
                          "type": "null"
                        }
                      ]
                    },
                    "source": {
                      "type": "string",
                      "enum": [
                        "organizer",
                        "event",
                        "cleared"
                      ]
                    }
                  }
                },
                "offerValidityMinutes": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "value",
                    "source"
                  ],
                  "properties": {
                    "value": {
                      "anyOf": [
                        {
                          "type": "integer",
                          "minimum": 5,
                          "maximum": 10080
                        },
                        {
                          "type": "null"
                        }
                      ]
                    },
                    "source": {
                      "type": "string",
                      "enum": [
                        "organizer",
                        "event",
                        "cleared"
                      ]
                    }
                  }
                },
                "collectionPreference": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "value",
                    "source"
                  ],
                  "properties": {
                    "value": {
                      "anyOf": [
                        {
                          "type": "string",
                          "enum": [
                            "manualInstructions",
                            "reusablePage",
                            "personalRequest",
                            "catchCheckout"
                          ]
                        },
                        {
                          "type": "null"
                        }
                      ]
                    },
                    "source": {
                      "type": "string",
                      "enum": [
                        "organizer",
                        "event",
                        "cleared"
                      ]
                    }
                  }
                },
                "currency": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "value",
                    "source"
                  ],
                  "properties": {
                    "value": {
                      "anyOf": [
                        {
                          "type": "string",
                          "pattern": "^[A-Z]{3}$"
                        },
                        {
                          "type": "null"
                        }
                      ]
                    },
                    "source": {
                      "type": "string",
                      "enum": [
                        "organizer",
                        "event",
                        "cleared"
                      ]
                    }
                  }
                },
                "offerMessageTemplate": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "value",
                    "source"
                  ],
                  "properties": {
                    "value": {
                      "anyOf": [
                        {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 1000
                        },
                        {
                          "type": "null"
                        }
                      ]
                    },
                    "source": {
                      "type": "string",
                      "enum": [
                        "organizer",
                        "event",
                        "cleared"
                      ]
                    }
                  }
                },
                "paymentInstructions": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "value",
                    "source"
                  ],
                  "properties": {
                    "value": {
                      "anyOf": [
                        {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 1000
                        },
                        {
                          "type": "null"
                        }
                      ]
                    },
                    "source": {
                      "type": "string",
                      "enum": [
                        "organizer",
                        "event",
                        "cleared"
                      ]
                    }
                  }
                },
                "reusablePaymentPage": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "value",
                    "source"
                  ],
                  "properties": {
                    "value": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "url",
                            "reusableForEvents"
                          ],
                          "properties": {
                            "url": {
                              "type": "string",
                              "format": "uri",
                              "maxLength": 2048
                            },
                            "reusableForEvents": {
                              "type": "boolean",
                              "const": true
                            }
                          }
                        },
                        {
                          "type": "null"
                        }
                      ]
                    },
                    "source": {
                      "type": "string",
                      "enum": [
                        "organizer",
                        "event",
                        "cleared"
                      ]
                    }
                  }
                },
                "admissionPreset": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "value",
                    "source"
                  ],
                  "properties": {
                    "value": {
                      "anyOf": [
                        {
                          "type": "string",
                          "enum": [
                            "openCapacity",
                            "inviteOnly",
                            "balancedSingles",
                            "fixedCohortCaps"
                          ]
                        },
                        {
                          "type": "null"
                        }
                      ]
                    },
                    "source": {
                      "type": "string",
                      "enum": [
                        "organizer",
                        "event",
                        "cleared"
                      ]
                    }
                  }
                },
                "expectedAmountMinor": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "value",
                    "source"
                  ],
                  "properties": {
                    "value": {
                      "anyOf": [
                        {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 100000000
                        },
                        {
                          "type": "null"
                        }
                      ]
                    },
                    "source": {
                      "type": "string",
                      "enum": [
                        "organizer",
                        "event",
                        "cleared"
                      ]
                    }
                  }
                }
              }
            },
            "paymentTerms": {
              "title": "EventPaymentTerms",
              "type": "object",
              "additionalProperties": false,
              "required": [
                "revision",
                "preferredCollection",
                "reusablePaymentPage",
                "paymentInstructions",
                "expectedAmountMinor",
                "currency",
                "offerValidityMinutes",
                "offerMessageTemplate",
                "sourceDefaultsRevision",
                "sourceDefaultsHash",
                "fieldSources"
              ],
              "properties": {
                "revision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 1000000000
                },
                "preferredCollection": {
                  "anyOf": [
                    {
                      "type": "string",
                      "enum": [
                        "manualInstructions",
                        "reusablePage",
                        "personalRequest",
                        "catchCheckout"
                      ]
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "reusablePaymentPage": {
                  "anyOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "url",
                        "reusableForEvents"
                      ],
                      "properties": {
                        "url": {
                          "type": "string",
                          "format": "uri",
                          "maxLength": 2048
                        },
                        "reusableForEvents": {
                          "type": "boolean",
                          "const": true
                        }
                      }
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "paymentInstructions": {
                  "anyOf": [
                    {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 1000
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "expectedAmountMinor": {
                  "anyOf": [
                    {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 100000000
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "currency": {
                  "anyOf": [
                    {
                      "type": "string",
                      "pattern": "^[A-Z]{3}$"
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "offerValidityMinutes": {
                  "anyOf": [
                    {
                      "type": "integer",
                      "minimum": 5,
                      "maximum": 10080
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "offerMessageTemplate": {
                  "anyOf": [
                    {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 1000
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "sourceDefaultsRevision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 1000000000
                },
                "sourceDefaultsHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
                },
                "fieldSources": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "preferredCollection",
                    "reusablePaymentPage",
                    "paymentInstructions",
                    "expectedAmountMinor",
                    "currency",
                    "offerValidityMinutes",
                    "offerMessageTemplate"
                  ],
                  "properties": {
                    "preferredCollection": {
                      "type": "string",
                      "enum": [
                        "organizer",
                        "event",
                        "cleared"
                      ]
                    },
                    "reusablePaymentPage": {
                      "type": "string",
                      "enum": [
                        "organizer",
                        "event",
                        "cleared"
                      ]
                    },
                    "paymentInstructions": {
                      "type": "string",
                      "enum": [
                        "organizer",
                        "event",
                        "cleared"
                      ]
                    },
                    "expectedAmountMinor": {
                      "type": "string",
                      "enum": [
                        "organizer",
                        "event",
                        "cleared"
                      ]
                    },
                    "currency": {
                      "type": "string",
                      "enum": [
                        "organizer",
                        "event",
                        "cleared"
                      ]
                    },
                    "offerValidityMinutes": {
                      "type": "string",
                      "enum": [
                        "organizer",
                        "event",
                        "cleared"
                      ]
                    },
                    "offerMessageTemplate": {
                      "type": "string",
                      "enum": [
                        "organizer",
                        "event",
                        "cleared"
                      ]
                    }
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
    "eventDetails": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "endTimeMillis",
        "venueName",
        "sourceVenueId",
        "eventFormat"
      ],
      "properties": {
        "endTimeMillis": {
          "type": [
            "integer",
            "null"
          ]
        },
        "venueName": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 240
        },
        "sourceVenueId": {
          "anyOf": [
            {
              "type": "null"
            },
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            }
          ]
        },
        "eventFormat": {
          "anyOf": [
            {
              "type": "null"
            },
            {
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
          ]
        }
      }
    }
  }
} as const;
