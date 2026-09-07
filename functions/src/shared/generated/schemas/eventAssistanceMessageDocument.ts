/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceMessageDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_assistance_messages.schema.json",
  "title": "EventAssistanceMessageDocument",
  "description": "Private durable event-service outbox. The immutable intent and bounded attempt history survive workflow completion and delayed callbacks. Recipient endpoints are references; transport credentials and guest bearer grants belong to their own private stores.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventAssistanceMessages",
  "x-firestore-path": "eventAssistanceMessages/{messageId}",
  "x-document-id-field": "messageId",
  "x-owner": "trusted event-assistance workers",
  "required": [
    "schemaVersion",
    "messageId",
    "revision",
    "intent",
    "lifecycle",
    "attempts",
    "deliveryConflict",
    "createdAt",
    "updatedAt",
    "response"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1,
      "x-catch-ownership": "server-only"
    },
    "messageId": {
      "type": "string",
      "pattern": "^outbox:[a-f0-9]{64}$",
      "x-catch-ownership": "server-only"
    },
    "revision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991,
      "x-catch-ownership": "server-only"
    },
    "intent": {
      "oneOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "schemaVersion",
            "intentId",
            "revision",
            "context",
            "eventId",
            "attendeeId",
            "episodeId",
            "workflow",
            "createdAt",
            "expiresAt",
            "permittedRoutes",
            "deliveryPolicy",
            "kind",
            "guidance",
            "choices"
          ],
          "properties": {
            "schemaVersion": {
              "const": 1,
              "type": "integer"
            },
            "intentId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
            },
            "revision": {
              "type": "integer",
              "minimum": 1,
              "maximum": 1000000
            },
            "context": {
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
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
            },
            "attendeeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
            },
            "episodeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
            },
            "workflow": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "occurrenceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "enum": [
                    "venueReadiness",
                    "routeReadiness",
                    "formatReadiness",
                    "rosterReadiness",
                    "requiredGuestData",
                    "resourceReadiness",
                    "staffingReadiness",
                    "messagingReadiness",
                    "admissionReview",
                    "financialReadiness",
                    "joiningInstructions",
                    "identityResolution",
                    "guestAdmission",
                    "guestCheckIn",
                    "lateJoin",
                    "participationChange",
                    "guestPrerequisite",
                    "allocationRepair",
                    "placementConfirmation",
                    "resourceRecovery",
                    "fairParticipation",
                    "roundPublication",
                    "unitProgress",
                    "outcomeRecording",
                    "programmeRecovery",
                    "departure",
                    "checkpoint",
                    "groupTransfer",
                    "routeRecovery",
                    "locationFreshness",
                    "accountability",
                    "planChangeCommunication",
                    "deliveryRecovery",
                    "replyOwnership",
                    "guestAssistance",
                    "comfortSafety",
                    "attendanceSync",
                    "concurrencyRecovery",
                    "operationRecovery",
                    "contextBoundary",
                    "overrideReview",
                    "eventClosure",
                    "attendanceReconciliation",
                    "financialReconciliation",
                    "postEventFollowUp",
                    "eventLearning"
                  ],
                  "x-catch-catalog": "../catalogs/event_assistance_workflows.json"
                },
                "occurrenceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                }
              }
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
            "permittedRoutes": {
              "type": "array",
              "minItems": 1,
              "maxItems": 3,
              "items": {
                "type": "string",
                "enum": [
                  "catchEventSms",
                  "catchEventRcs",
                  "organizerEventWhatsapp"
                ]
              },
              "uniqueItems": true
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
            "kind": {
              "const": "joiningUpdate",
              "type": "string"
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
            "choices": {
              "type": "array",
              "minItems": 1,
              "maxItems": 20,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "choiceId",
                  "label",
                  "value"
                ],
                "properties": {
                  "choiceId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 160,
                    "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                  },
                  "label": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 80
                  },
                  "value": {
                    "oneOf": [
                      {
                        "type": "object",
                        "additionalProperties": false,
                        "required": [
                          "kind",
                          "intention"
                        ],
                        "properties": {
                          "kind": {
                            "const": "joinIntent",
                            "type": "string"
                          },
                          "intention": {
                            "oneOf": [
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
                          }
                        }
                      },
                      {
                        "type": "object",
                        "additionalProperties": false,
                        "required": [
                          "kind",
                          "category"
                        ],
                        "properties": {
                          "kind": {
                            "const": "requestHelp",
                            "type": "string"
                          },
                          "category": {
                            "type": "string",
                            "enum": [
                              "eventLogistics",
                              "accessibility",
                              "comfortSafety",
                              "other"
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
            "schemaVersion",
            "intentId",
            "revision",
            "context",
            "eventId",
            "attendeeId",
            "episodeId",
            "workflow",
            "createdAt",
            "expiresAt",
            "permittedRoutes",
            "deliveryPolicy",
            "kind",
            "noticeKind",
            "title",
            "body",
            "instructionRevision",
            "choices"
          ],
          "properties": {
            "schemaVersion": {
              "const": 1,
              "type": "integer"
            },
            "intentId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
            },
            "revision": {
              "type": "integer",
              "minimum": 1,
              "maximum": 1000000
            },
            "context": {
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
            "eventId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
            },
            "attendeeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
            },
            "episodeId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
            },
            "workflow": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "kind",
                "occurrenceId"
              ],
              "properties": {
                "kind": {
                  "type": "string",
                  "enum": [
                    "venueReadiness",
                    "routeReadiness",
                    "formatReadiness",
                    "rosterReadiness",
                    "requiredGuestData",
                    "resourceReadiness",
                    "staffingReadiness",
                    "messagingReadiness",
                    "admissionReview",
                    "financialReadiness",
                    "joiningInstructions",
                    "identityResolution",
                    "guestAdmission",
                    "guestCheckIn",
                    "lateJoin",
                    "participationChange",
                    "guestPrerequisite",
                    "allocationRepair",
                    "placementConfirmation",
                    "resourceRecovery",
                    "fairParticipation",
                    "roundPublication",
                    "unitProgress",
                    "outcomeRecording",
                    "programmeRecovery",
                    "departure",
                    "checkpoint",
                    "groupTransfer",
                    "routeRecovery",
                    "locationFreshness",
                    "accountability",
                    "planChangeCommunication",
                    "deliveryRecovery",
                    "replyOwnership",
                    "guestAssistance",
                    "comfortSafety",
                    "attendanceSync",
                    "concurrencyRecovery",
                    "operationRecovery",
                    "contextBoundary",
                    "overrideReview",
                    "eventClosure",
                    "attendanceReconciliation",
                    "financialReconciliation",
                    "postEventFollowUp",
                    "eventLearning"
                  ],
                  "x-catch-catalog": "../catalogs/event_assistance_workflows.json"
                },
                "occurrenceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                }
              }
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
            "permittedRoutes": {
              "type": "array",
              "minItems": 1,
              "maxItems": 3,
              "items": {
                "type": "string",
                "enum": [
                  "catchEventSms",
                  "catchEventRcs",
                  "organizerEventWhatsapp"
                ]
              },
              "uniqueItems": true
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
            "kind": {
              "const": "operationalNotice",
              "type": "string"
            },
            "noticeKind": {
              "type": "string",
              "enum": [
                "joiningInstructions",
                "planChanged",
                "eventCancelled",
                "eventFinished",
                "guestRequirement",
                "assignmentChanged",
                "participationCheck",
                "followUp"
              ]
            },
            "title": {
              "type": "string",
              "minLength": 1,
              "maxLength": 120
            },
            "body": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000
            },
            "instructionRevision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "choices": {
              "type": "array",
              "minItems": 0,
              "maxItems": 20,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "choiceId",
                  "label",
                  "value"
                ],
                "properties": {
                  "choiceId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 160,
                    "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                  },
                  "label": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 80
                  },
                  "value": {
                    "oneOf": [
                      {
                        "type": "object",
                        "additionalProperties": false,
                        "required": [
                          "kind",
                          "instructionRevision"
                        ],
                        "properties": {
                          "kind": {
                            "const": "acknowledge",
                            "type": "string"
                          },
                          "instructionRevision": {
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
                          "category"
                        ],
                        "properties": {
                          "kind": {
                            "const": "requestHelp",
                            "type": "string"
                          },
                          "category": {
                            "type": "string",
                            "enum": [
                              "eventLogistics",
                              "accessibility",
                              "comfortSafety",
                              "other"
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
        }
      ],
      "x-catch-ownership": "server-only"
    },
    "lifecycle": {
      "type": "string",
      "enum": [
        "active",
        "cancelled",
        "superseded",
        "responded"
      ],
      "x-catch-ownership": "server-only"
    },
    "attempts": {
      "type": "array",
      "maxItems": 6,
      "items": {
        "oneOf": [
          {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "schemaVersion",
              "attemptId",
              "intentId",
              "intentRevision",
              "ordinal",
              "createdAt",
              "state",
              "mode",
              "context",
              "binding",
              "authorization"
            ],
            "properties": {
              "schemaVersion": {
                "const": 1,
                "type": "integer"
              },
              "attemptId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
              },
              "intentId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
              },
              "intentRevision": {
                "type": "integer",
                "minimum": 1,
                "maximum": 1000000
              },
              "ordinal": {
                "type": "integer",
                "minimum": 1,
                "maximum": 6
              },
              "createdAt": {
                "type": "integer",
                "minimum": 0,
                "maximum": 9007199254740991
              },
              "state": {
                "oneOf": [
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "kind",
                      "at",
                      "reconcileAfter"
                    ],
                    "properties": {
                      "kind": {
                        "const": "reserved",
                        "type": "string"
                      },
                      "at": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 9007199254740991
                      },
                      "reconcileAfter": {
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
                      "at",
                      "providerMessageId",
                      "reason",
                      "reconcileAfter"
                    ],
                    "properties": {
                      "kind": {
                        "const": "unknown",
                        "type": "string"
                      },
                      "at": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 9007199254740991
                      },
                      "providerMessageId": {
                        "anyOf": [
                          {
                            "type": "string",
                            "minLength": 1,
                            "maxLength": 512
                          },
                          {
                            "type": "null"
                          }
                        ]
                      },
                      "reason": {
                        "type": "string",
                        "enum": [
                          "timeout",
                          "connectionLost",
                          "workerInterrupted"
                        ]
                      },
                      "reconcileAfter": {
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
                      "at",
                      "providerMessageId"
                    ],
                    "properties": {
                      "kind": {
                        "const": "accepted",
                        "type": "string"
                      },
                      "at": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 9007199254740991
                      },
                      "providerMessageId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 512
                      }
                    }
                  },
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "kind",
                      "at",
                      "providerMessageId"
                    ],
                    "properties": {
                      "kind": {
                        "const": "delivered",
                        "type": "string"
                      },
                      "at": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 9007199254740991
                      },
                      "providerMessageId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 512
                      }
                    }
                  },
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "kind",
                      "at",
                      "providerMessageId"
                    ],
                    "properties": {
                      "kind": {
                        "const": "read",
                        "type": "string"
                      },
                      "at": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 9007199254740991
                      },
                      "providerMessageId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 512
                      }
                    }
                  },
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "kind",
                      "at",
                      "providerMessageId",
                      "classification",
                      "evidenceId"
                    ],
                    "properties": {
                      "kind": {
                        "const": "failed",
                        "type": "string"
                      },
                      "at": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 9007199254740991
                      },
                      "providerMessageId": {
                        "anyOf": [
                          {
                            "type": "string",
                            "minLength": 1,
                            "maxLength": 512
                          },
                          {
                            "type": "null"
                          }
                        ]
                      },
                      "classification": {
                        "type": "string",
                        "enum": [
                          "technical",
                          "invalidRecipient",
                          "policy",
                          "suppressed"
                        ]
                      },
                      "evidenceId": {
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
                      "kind",
                      "at",
                      "providerMessageId",
                      "evidenceId"
                    ],
                    "properties": {
                      "kind": {
                        "const": "revoked",
                        "type": "string"
                      },
                      "at": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 9007199254740991
                      },
                      "providerMessageId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 512
                      },
                      "evidenceId": {
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
                      "kind",
                      "at",
                      "reason"
                    ],
                    "properties": {
                      "kind": {
                        "const": "notDispatched",
                        "type": "string"
                      },
                      "at": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 9007199254740991
                      },
                      "reason": {
                        "type": "string",
                        "enum": [
                          "superseded",
                          "eventClosed",
                          "responded",
                          "expired",
                          "permissionRevoked",
                          "hostStopped",
                          "reservationExpired",
                          "permitExpired"
                        ]
                      }
                    },
                    "description": "No provider request was made. Reservation or permit expiry permits a fresh bounded attempt; the other reasons stop this message."
                  }
                ]
              },
              "mode": {
                "const": "live",
                "type": "string"
              },
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
              "binding": {
                "oneOf": [
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "routeId",
                      "transport",
                      "senderIdentity",
                      "provider",
                      "senderId",
                      "bindingRevision",
                      "recipientEndpointId",
                      "fallbackOwner"
                    ],
                    "properties": {
                      "routeId": {
                        "const": "catchEventSms",
                        "type": "string"
                      },
                      "transport": {
                        "const": "sms",
                        "type": "string"
                      },
                      "senderIdentity": {
                        "const": "catchPlatform",
                        "type": "string"
                      },
                      "provider": {
                        "type": "string",
                        "enum": [
                          "sinch",
                          "gupshup"
                        ]
                      },
                      "senderId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 160,
                        "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                      },
                      "bindingRevision": {
                        "type": "integer",
                        "minimum": 1,
                        "maximum": 9007199254740991
                      },
                      "recipientEndpointId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 160,
                        "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                      },
                      "fallbackOwner": {
                        "type": "string",
                        "enum": [
                          "catch",
                          "provider"
                        ]
                      }
                    }
                  },
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "routeId",
                      "transport",
                      "senderIdentity",
                      "provider",
                      "senderId",
                      "bindingRevision",
                      "recipientEndpointId",
                      "fallbackOwner"
                    ],
                    "properties": {
                      "routeId": {
                        "const": "catchEventRcs",
                        "type": "string"
                      },
                      "transport": {
                        "const": "rcs",
                        "type": "string"
                      },
                      "senderIdentity": {
                        "const": "catchPlatform",
                        "type": "string"
                      },
                      "provider": {
                        "type": "string",
                        "enum": [
                          "sinch",
                          "gupshup"
                        ]
                      },
                      "senderId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 160,
                        "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                      },
                      "bindingRevision": {
                        "type": "integer",
                        "minimum": 1,
                        "maximum": 9007199254740991
                      },
                      "recipientEndpointId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 160,
                        "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                      },
                      "fallbackOwner": {
                        "type": "string",
                        "enum": [
                          "catch",
                          "provider"
                        ]
                      }
                    }
                  },
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "routeId",
                      "transport",
                      "senderIdentity",
                      "provider",
                      "senderId",
                      "bindingRevision",
                      "recipientEndpointId",
                      "fallbackOwner"
                    ],
                    "properties": {
                      "routeId": {
                        "const": "organizerEventWhatsapp",
                        "type": "string"
                      },
                      "transport": {
                        "const": "whatsapp",
                        "type": "string"
                      },
                      "senderIdentity": {
                        "const": "organizerManaged",
                        "type": "string"
                      },
                      "provider": {
                        "type": "string",
                        "enum": [
                          "meta"
                        ]
                      },
                      "senderId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 160,
                        "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                      },
                      "bindingRevision": {
                        "type": "integer",
                        "minimum": 1,
                        "maximum": 9007199254740991
                      },
                      "recipientEndpointId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 160,
                        "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                      },
                      "fallbackOwner": {
                        "type": "string",
                        "enum": [
                          "catch",
                          "provider"
                        ]
                      }
                    }
                  }
                ]
              },
              "authorization": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "permissionRevision",
                  "checkedAt",
                  "validUntil",
                  "instructionRevision"
                ],
                "properties": {
                  "permissionRevision": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 512
                  },
                  "checkedAt": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 9007199254740991
                  },
                  "validUntil": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 9007199254740991
                  },
                  "instructionRevision": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 9007199254740991
                  }
                }
              }
            }
          },
          {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "schemaVersion",
              "attemptId",
              "intentId",
              "intentRevision",
              "ordinal",
              "createdAt",
              "state",
              "mode",
              "context",
              "routeId",
              "authorization"
            ],
            "properties": {
              "schemaVersion": {
                "const": 1,
                "type": "integer"
              },
              "attemptId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
              },
              "intentId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
              },
              "intentRevision": {
                "type": "integer",
                "minimum": 1,
                "maximum": 1000000
              },
              "ordinal": {
                "type": "integer",
                "minimum": 1,
                "maximum": 6
              },
              "createdAt": {
                "type": "integer",
                "minimum": 0,
                "maximum": 9007199254740991
              },
              "state": {
                "oneOf": [
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "kind",
                      "at",
                      "reconcileAfter"
                    ],
                    "properties": {
                      "kind": {
                        "const": "reserved",
                        "type": "string"
                      },
                      "at": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 9007199254740991
                      },
                      "reconcileAfter": {
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
                      "at",
                      "providerMessageId",
                      "reason",
                      "reconcileAfter"
                    ],
                    "properties": {
                      "kind": {
                        "const": "unknown",
                        "type": "string"
                      },
                      "at": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 9007199254740991
                      },
                      "providerMessageId": {
                        "anyOf": [
                          {
                            "type": "string",
                            "minLength": 1,
                            "maxLength": 512
                          },
                          {
                            "type": "null"
                          }
                        ]
                      },
                      "reason": {
                        "type": "string",
                        "enum": [
                          "timeout",
                          "connectionLost",
                          "workerInterrupted"
                        ]
                      },
                      "reconcileAfter": {
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
                      "at",
                      "providerMessageId"
                    ],
                    "properties": {
                      "kind": {
                        "const": "accepted",
                        "type": "string"
                      },
                      "at": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 9007199254740991
                      },
                      "providerMessageId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 512
                      }
                    }
                  },
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "kind",
                      "at",
                      "providerMessageId"
                    ],
                    "properties": {
                      "kind": {
                        "const": "delivered",
                        "type": "string"
                      },
                      "at": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 9007199254740991
                      },
                      "providerMessageId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 512
                      }
                    }
                  },
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "kind",
                      "at",
                      "providerMessageId"
                    ],
                    "properties": {
                      "kind": {
                        "const": "read",
                        "type": "string"
                      },
                      "at": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 9007199254740991
                      },
                      "providerMessageId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 512
                      }
                    }
                  },
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "kind",
                      "at",
                      "providerMessageId",
                      "classification",
                      "evidenceId"
                    ],
                    "properties": {
                      "kind": {
                        "const": "failed",
                        "type": "string"
                      },
                      "at": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 9007199254740991
                      },
                      "providerMessageId": {
                        "anyOf": [
                          {
                            "type": "string",
                            "minLength": 1,
                            "maxLength": 512
                          },
                          {
                            "type": "null"
                          }
                        ]
                      },
                      "classification": {
                        "type": "string",
                        "enum": [
                          "technical",
                          "invalidRecipient",
                          "policy",
                          "suppressed"
                        ]
                      },
                      "evidenceId": {
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
                      "kind",
                      "at",
                      "providerMessageId",
                      "evidenceId"
                    ],
                    "properties": {
                      "kind": {
                        "const": "revoked",
                        "type": "string"
                      },
                      "at": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 9007199254740991
                      },
                      "providerMessageId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 512
                      },
                      "evidenceId": {
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
                      "kind",
                      "at",
                      "reason"
                    ],
                    "properties": {
                      "kind": {
                        "const": "notDispatched",
                        "type": "string"
                      },
                      "at": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 9007199254740991
                      },
                      "reason": {
                        "type": "string",
                        "enum": [
                          "superseded",
                          "eventClosed",
                          "responded",
                          "expired",
                          "permissionRevoked",
                          "hostStopped",
                          "reservationExpired",
                          "permitExpired"
                        ]
                      }
                    },
                    "description": "No provider request was made. Reservation or permit expiry permits a fresh bounded attempt; the other reasons stop this message."
                  }
                ]
              },
              "mode": {
                "const": "rehearsal",
                "type": "string"
              },
              "context": {
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
              },
              "routeId": {
                "type": "string",
                "enum": [
                  "catchEventSms",
                  "catchEventRcs",
                  "organizerEventWhatsapp"
                ]
              },
              "authorization": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "permissionRevision",
                  "checkedAt",
                  "validUntil",
                  "instructionRevision"
                ],
                "properties": {
                  "permissionRevision": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 512
                  },
                  "checkedAt": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 9007199254740991
                  },
                  "validUntil": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 9007199254740991
                  },
                  "instructionRevision": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 9007199254740991
                  }
                }
              }
            }
          }
        ]
      },
      "x-catch-ownership": "server-only"
    },
    "deliveryConflict": {
      "type": "boolean",
      "x-catch-ownership": "server-only"
    },
    "createdAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991,
      "x-catch-ownership": "server-only"
    },
    "updatedAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991,
      "x-catch-ownership": "server-only"
    },
    "response": {
      "anyOf": [
        {
          "oneOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "schemaVersion",
                "responseId",
                "intentId",
                "intentRevision",
                "eventId",
                "attendeeId",
                "episodeId",
                "choiceId",
                "receivedAt",
                "value",
                "context",
                "source"
              ],
              "properties": {
                "schemaVersion": {
                  "const": 1,
                  "type": "integer"
                },
                "responseId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "intentId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "intentRevision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 1000000
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "choiceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "receivedAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "value": {
                  "oneOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "intention"
                      ],
                      "properties": {
                        "kind": {
                          "const": "joinIntent",
                          "type": "string"
                        },
                        "intention": {
                          "oneOf": [
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
                        }
                      }
                    },
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "instructionRevision"
                      ],
                      "properties": {
                        "kind": {
                          "const": "acknowledge",
                          "type": "string"
                        },
                        "instructionRevision": {
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
                        "category"
                      ],
                      "properties": {
                        "kind": {
                          "const": "requestHelp",
                          "type": "string"
                        },
                        "category": {
                          "type": "string",
                          "enum": [
                            "eventLogistics",
                            "accessibility",
                            "comfortSafety",
                            "other"
                          ]
                        }
                      }
                    }
                  ]
                },
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
                "source": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "linkId"
                  ],
                  "properties": {
                    "kind": {
                      "const": "guestWeb",
                      "type": "string"
                    },
                    "linkId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "schemaVersion",
                "responseId",
                "intentId",
                "intentRevision",
                "eventId",
                "attendeeId",
                "episodeId",
                "choiceId",
                "receivedAt",
                "value",
                "context",
                "source"
              ],
              "properties": {
                "schemaVersion": {
                  "const": 1,
                  "type": "integer"
                },
                "responseId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "intentId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "intentRevision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 1000000
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "choiceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "receivedAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "value": {
                  "oneOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "intention"
                      ],
                      "properties": {
                        "kind": {
                          "const": "joinIntent",
                          "type": "string"
                        },
                        "intention": {
                          "oneOf": [
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
                        }
                      }
                    },
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "instructionRevision"
                      ],
                      "properties": {
                        "kind": {
                          "const": "acknowledge",
                          "type": "string"
                        },
                        "instructionRevision": {
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
                        "category"
                      ],
                      "properties": {
                        "kind": {
                          "const": "requestHelp",
                          "type": "string"
                        },
                        "category": {
                          "type": "string",
                          "enum": [
                            "eventLogistics",
                            "accessibility",
                            "comfortSafety",
                            "other"
                          ]
                        }
                      }
                    }
                  ]
                },
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
                "source": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "attemptId",
                    "providerEventId"
                  ],
                  "properties": {
                    "kind": {
                      "const": "provider",
                      "type": "string"
                    },
                    "attemptId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                    },
                    "providerEventId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 512
                    }
                  }
                }
              }
            },
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "schemaVersion",
                "responseId",
                "intentId",
                "intentRevision",
                "eventId",
                "attendeeId",
                "episodeId",
                "choiceId",
                "receivedAt",
                "value",
                "context",
                "source"
              ],
              "properties": {
                "schemaVersion": {
                  "const": 1,
                  "type": "integer"
                },
                "responseId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "intentId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "intentRevision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 1000000
                },
                "eventId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "attendeeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "episodeId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "choiceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                },
                "receivedAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "value": {
                  "oneOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "intention"
                      ],
                      "properties": {
                        "kind": {
                          "const": "joinIntent",
                          "type": "string"
                        },
                        "intention": {
                          "oneOf": [
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
                        }
                      }
                    },
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "instructionRevision"
                      ],
                      "properties": {
                        "kind": {
                          "const": "acknowledge",
                          "type": "string"
                        },
                        "instructionRevision": {
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
                        "category"
                      ],
                      "properties": {
                        "kind": {
                          "const": "requestHelp",
                          "type": "string"
                        },
                        "category": {
                          "type": "string",
                          "enum": [
                            "eventLogistics",
                            "accessibility",
                            "comfortSafety",
                            "other"
                          ]
                        }
                      }
                    }
                  ]
                },
                "context": {
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
                },
                "source": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "actionId"
                  ],
                  "properties": {
                    "kind": {
                      "const": "simulation",
                      "type": "string"
                    },
                    "actionId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 160,
                      "pattern": "^[a-zA-Z0-9][a-zA-Z0-9._:-]*$"
                    }
                  }
                }
              }
            }
          ]
        },
        {
          "type": "null"
        }
      ]
    }
  },
  "allOf": [
    {
      "if": {
        "properties": {
          "lifecycle": {
            "const": "responded"
          }
        }
      },
      "then": {
        "properties": {
          "response": {
            "type": "object"
          }
        }
      },
      "else": {
        "properties": {
          "response": {
            "type": "null"
          }
        }
      }
    }
  ]
} as const;
