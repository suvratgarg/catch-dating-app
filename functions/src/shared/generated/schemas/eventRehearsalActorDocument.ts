/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventRehearsalActorDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_rehearsal_actors.schema.json",
  "title": "EventRehearsalActorDocument",
  "description": "Synthetic participant state stored only for an isolated rehearsal.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventRehearsalActors",
  "x-firestore-path": "eventRehearsalActors/{actorDocumentId}",
  "x-document-id-field": "id",
  "x-owner": "event rehearsal callables",
  "required": [
    "sessionId",
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
    "confirmedLayoutUnitId",
    "lastActionAt",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "sessionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "actorId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "displayName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80,
      "x-catch-ownership": "callable-owned"
    },
    "persona": {
      "type": "string",
      "enum": [
        "firstTimer",
        "regular",
        "quiet",
        "connector",
        "external",
        "sparseProfile",
        "accessibilityNeeds",
        "walkIn"
      ],
      "x-catch-ownership": "callable-owned"
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
      ],
      "x-catch-ownership": "callable-owned"
    },
    "connectionState": {
      "type": "string",
      "enum": [
        "connected",
        "disconnected"
      ],
      "x-catch-ownership": "callable-owned"
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
      ],
      "x-catch-ownership": "callable-owned"
    },
    "optedOut": {
      "type": "boolean",
      "x-catch-ownership": "callable-owned"
    },
    "keepApartActorIds": {
      "type": "array",
      "maxItems": 10,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      },
      "x-catch-ownership": "callable-owned"
    },
    "helpRequested": {
      "type": "boolean",
      "x-catch-ownership": "callable-owned"
    },
    "promptCompleted": {
      "type": "boolean",
      "x-catch-ownership": "callable-owned"
    },
    "layoutUnitId": {
      "anyOf": [
        {
          "type": "string",
          "pattern": "^table-[1-9][0-9]*$",
          "maxLength": 40
        },
        {
          "type": "null"
        }
      ],
      "x-catch-ownership": "callable-owned"
    },
    "confirmedLayoutUnitId": {
      "anyOf": [
        {
          "type": "string",
          "pattern": "^table-[1-9][0-9]*$",
          "maxLength": 40
        },
        {
          "type": "null"
        }
      ],
      "x-catch-ownership": "callable-owned"
    },
    "lastActionAt": {
      "anyOf": [
        {
          "type": "object",
          "description": "Serialized Firestore Timestamp fixture shape.",
          "x-firestore-type": "timestamp",
          "additionalProperties": false,
          "required": [
            "_seconds",
            "_nanoseconds"
          ],
          "properties": {
            "_seconds": {
              "type": "integer"
            },
            "_nanoseconds": {
              "type": "integer",
              "minimum": 0,
              "maximum": 999999999
            }
          }
        },
        {
          "type": "null"
        }
      ],
      "x-catch-ownership": "callable-owned"
    },
    "createdAt": {
      "type": "object",
      "description": "Serialized Firestore Timestamp fixture shape.",
      "x-firestore-type": "timestamp",
      "additionalProperties": false,
      "required": [
        "_seconds",
        "_nanoseconds"
      ],
      "properties": {
        "_seconds": {
          "type": "integer"
        },
        "_nanoseconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      },
      "x-catch-ownership": "callable-owned"
    },
    "updatedAt": {
      "type": "object",
      "description": "Serialized Firestore Timestamp fixture shape.",
      "x-firestore-type": "timestamp",
      "additionalProperties": false,
      "required": [
        "_seconds",
        "_nanoseconds"
      ],
      "properties": {
        "_seconds": {
          "type": "integer"
        },
        "_nanoseconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      },
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
    }
  }
} as const;
