/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceHostGuestsCallableResponseSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "context",
    "serverTime",
    "coverage",
    "workflow",
    "runtimeStatus",
    "guests"
  ],
  "properties": {
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
    "serverTime": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "coverage": {
      "type": "string",
      "const": "selectedAttendees"
    },
    "workflow": {
      "type": "string",
      "const": "lateJoin"
    },
    "runtimeStatus": {
      "type": "string",
      "enum": [
        "unconfigured",
        "paused",
        "sourceChanged",
        "expired",
        "eventClosed",
        "configured"
      ]
    },
    "guests": {
      "type": "array",
      "minItems": 1,
      "maxItems": 50,
      "items": {
        "oneOf": [
          {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "kind",
              "attendeeId"
            ],
            "properties": {
              "kind": {
                "type": "string",
                "const": "unavailable"
              },
              "attendeeId": {
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
              "attendeeId",
              "rosterStatus"
            ],
            "properties": {
              "kind": {
                "type": "string",
                "const": "ineligible"
              },
              "attendeeId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
              },
              "rosterStatus": {
                "type": "string",
                "enum": [
                  "invited",
                  "waitlisted",
                  "cancelled"
                ]
              }
            }
          },
          {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "kind",
              "attendeeId",
              "checkedIn"
            ],
            "properties": {
              "kind": {
                "type": "string",
                "const": "uninitialized"
              },
              "attendeeId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
              },
              "checkedIn": {
                "type": "boolean"
              }
            }
          },
          {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "kind",
              "attendeeId",
              "checkedIn"
            ],
            "properties": {
              "kind": {
                "type": "string",
                "const": "sourceChanged"
              },
              "attendeeId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
              },
              "checkedIn": {
                "type": "boolean"
              }
            }
          },
          {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "kind",
              "attendeeId",
              "checkedIn",
              "episodeId",
              "participation",
              "intention",
              "work"
            ],
            "properties": {
              "kind": {
                "type": "string",
                "const": "current"
              },
              "attendeeId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
              },
              "checkedIn": {
                "type": "boolean"
              },
              "episodeId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160,
                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
              },
              "participation": {
                "oneOf": [
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "state",
                      "resumeAtUnit"
                    ],
                    "properties": {
                      "state": {
                        "const": "active"
                      },
                      "resumeAtUnit": {
                        "type": "null"
                      }
                    }
                  },
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "state",
                      "resumeAtUnit"
                    ],
                    "properties": {
                      "state": {
                        "const": "temporaryBreak"
                      },
                      "resumeAtUnit": {
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
                      }
                    }
                  },
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "state",
                      "resumeAtUnit"
                    ],
                    "properties": {
                      "state": {
                        "const": "departed"
                      },
                      "resumeAtUnit": {
                        "type": "null"
                      }
                    }
                  }
                ]
              },
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
              "work": {
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
                        "const": "notEnrolled"
                      }
                    }
                  },
                  {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "kind",
                      "revision",
                      "runStatus",
                      "configurationBinding",
                      "expiresAt",
                      "nextEvaluationAt",
                      "lastEvaluation",
                      "publishedIntentCount"
                    ],
                    "properties": {
                      "kind": {
                        "type": "string",
                        "const": "recorded"
                      },
                      "revision": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 9007199254740991
                      },
                      "runStatus": {
                        "type": "string",
                        "enum": [
                          "running",
                          "paused",
                          "completed"
                        ]
                      },
                      "configurationBinding": {
                        "type": "string",
                        "enum": [
                          "current",
                          "unbound",
                          "configurationChanged"
                        ]
                      },
                      "expiresAt": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 9007199254740991
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
                      },
                      "lastEvaluation": {
                        "anyOf": [
                          {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "at",
                              "observation"
                            ],
                            "properties": {
                              "at": {
                                "type": "integer",
                                "minimum": 0,
                                "maximum": 9007199254740991
                              },
                              "observation": {
                                "oneOf": [
                                  {
                                    "type": "object",
                                    "additionalProperties": false,
                                    "required": [
                                      "kind",
                                      "decision"
                                    ],
                                    "properties": {
                                      "kind": {
                                        "type": "string",
                                        "const": "decision"
                                      },
                                      "decision": {
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
                                        ],
                                        "title": "EventAssistanceLateJoinDecision"
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
                                        "const": "sourceNotReady"
                                      },
                                      "reason": {
                                        "type": "string",
                                        "enum": [
                                          "episodeMissing",
                                          "guestSourceChanged",
                                          "membershipMissing",
                                          "membershipSourceChanged",
                                          "unconfigured",
                                          "disabled",
                                          "settingSourceChanged",
                                          "eventClosed",
                                          "runtimeNotLive",
                                          "progressUnconfirmed",
                                          "progressSourceChanged",
                                          "destinationUnavailable"
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
                                        "const": "historyUnavailable"
                                      },
                                      "reason": {
                                        "type": "string",
                                        "enum": [
                                          "historyLimit",
                                          "deliveryConflict",
                                          "ambiguousHistory"
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
                                        "const": "responseDeadlineMissing"
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
                                        "const": "episodeChanged"
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
                                        "const": "workExpired"
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
                                        "const": "evaluationLimit"
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
                                        "const": "runtimeUnavailable"
                                      },
                                      "reason": {
                                        "type": "string",
                                        "enum": [
                                          "missing",
                                          "paused",
                                          "configurationChanged",
                                          "sourceChanged",
                                          "expired",
                                          "eventClosed"
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
                      },
                      "publishedIntentCount": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 9007199254740991
                      }
                    }
                  }
                ]
              }
            }
          }
        ]
      }
    }
  },
  "title": "EventAssistanceHostGuestsCallableResponse"
} as const;
