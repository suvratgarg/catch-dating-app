/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceLiveWorkSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/operations/event_assistance_live_work.schema.json",
  "title": "EventAssistanceLiveWork",
  "description": "Private normalized payload for one durable live guest episode. Due times and evaluation state are explicit; publication is not provider delivery.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "kind",
    "scope",
    "options",
    "expiresAt",
    "maxEvaluations",
    "checkpoint"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "kind": {
      "type": "string",
      "const": "liveLateJoin"
    },
    "scope": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "context",
        "attendeeId",
        "episodeId"
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
        "attendeeId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "episodeId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        }
      }
    },
    "options": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "routes",
        "responseDeadline",
        "deliveryPolicy"
      ],
      "properties": {
        "routes": {
          "type": "array",
          "minItems": 1,
          "maxItems": 3,
          "uniqueItems": true,
          "items": {
            "oneOf": [
              {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "routeId",
                  "senderId"
                ],
                "properties": {
                  "routeId": {
                    "type": "string",
                    "const": "catchEventSms"
                  },
                  "senderId": {
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
                  "routeId",
                  "senderId"
                ],
                "properties": {
                  "routeId": {
                    "type": "string",
                    "const": "organizerEventWhatsapp"
                  },
                  "senderId": {
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
                  "routeId"
                ],
                "properties": {
                  "routeId": {
                    "type": "string",
                    "const": "catchEventRcs"
                  }
                }
              }
            ]
          }
        },
        "responseDeadline": {
          "anyOf": [
            {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            {
              "type": "null",
              "const": null
            }
          ]
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
      }
    },
    "expiresAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "maxEvaluations": {
      "type": "integer",
      "minimum": 1,
      "maximum": 10000
    },
    "checkpoint": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "dueAt",
        "evaluatedAt",
        "evaluations",
        "sourceHash",
        "observation",
        "publication"
      ],
      "properties": {
        "dueAt": {
          "anyOf": [
            {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            {
              "type": "null",
              "const": null
            }
          ]
        },
        "evaluatedAt": {
          "anyOf": [
            {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            {
              "type": "null",
              "const": null
            }
          ]
        },
        "evaluations": {
          "type": "integer",
          "minimum": 0,
          "maximum": 10000
        },
        "sourceHash": {
          "anyOf": [
            {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            {
              "type": "null",
              "const": null
            }
          ]
        },
        "observation": {
          "anyOf": [
            {
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
            },
            {
              "type": "null",
              "const": null
            }
          ]
        },
        "publication": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "messageId",
                "threadId"
              ],
              "properties": {
                "messageId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "threadId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
    "runtimeBinding": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "runtimeId",
        "revision"
      ],
      "properties": {
        "runtimeId": {
          "type": "string",
          "pattern": "^runtime:lateJoin:[a-f0-9]{64}$"
        },
        "revision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        }
      }
    }
  }
} as const;
