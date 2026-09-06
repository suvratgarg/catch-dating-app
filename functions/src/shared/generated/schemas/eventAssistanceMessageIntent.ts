/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceMessageIntentSchema: Record<string, unknown> = {
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
  "title": "EventAssistanceMessageIntent"
} as const;
