/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventRehearsalMovementCallableResponseSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "sessionId",
    "organizerId",
    "clockId",
    "setupRevision",
    "runtimeRevision",
    "actorUid",
    "serverTime",
    "groupId",
    "groups",
    "progress",
    "roster",
    "selected",
    "checkpoint",
    "history",
    "nextBeforeRevision"
  ],
  "properties": {
    "sessionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "clockId": {
      "type": "string",
      "pattern": "^clock:[a-f0-9]{64}$"
    },
    "setupRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647
    },
    "runtimeRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647
    },
    "actorUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "serverTime": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "groupId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "groups": {
      "type": "array",
      "maxItems": 41,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "groupId",
          "label"
        ],
        "properties": {
          "groupId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 500
          }
        }
      }
    },
    "progress": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "revision",
        "sourceHash",
        "eventOpen",
        "runtimeLive",
        "destinations",
        "current",
        "guidance"
      ],
      "properties": {
        "revision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 500
        },
        "sourceHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "eventOpen": {
          "type": "boolean"
        },
        "runtimeLive": {
          "type": "boolean"
        },
        "destinations": {
          "type": "array",
          "maxItems": 41,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "target",
              "label",
              "text"
            ],
            "properties": {
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
              },
              "label": {
                "type": "string",
                "minLength": 1,
                "maxLength": 500
              },
              "text": {
                "type": "string",
                "minLength": 1,
                "maxLength": 4000
              }
            }
          }
        },
        "current": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "sessionId",
                "clockId",
                "groupId",
                "progressRevision",
                "departure",
                "report"
              ],
              "properties": {
                "sessionId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                "clockId": {
                  "type": "string",
                  "pattern": "^clock:[a-f0-9]{64}$"
                },
                "groupId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                "progressRevision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 500
                },
                "departure": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "sourceHash",
                    "destination",
                    "confirmedAt",
                    "confirmedBy",
                    "operationId",
                    "roster",
                    "checkpointRequest"
                  ],
                  "properties": {
                    "sourceHash": {
                      "type": "string",
                      "pattern": "^[a-f0-9]{64}$"
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
                    "confirmedAt": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
                    },
                    "confirmedBy": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180
                    },
                    "operationId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180
                    },
                    "roster": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "members",
                            "selectionHash"
                          ],
                          "properties": {
                            "members": {
                              "type": "array",
                              "maxItems": 50,
                              "items": {
                                "type": "object",
                                "additionalProperties": false,
                                "required": [
                                  "attendeeId",
                                  "displayName",
                                  "visitHash",
                                  "episodeId",
                                  "membershipHash"
                                ],
                                "properties": {
                                  "attendeeId": {
                                    "type": "string",
                                    "minLength": 1,
                                    "maxLength": 180
                                  },
                                  "displayName": {
                                    "type": "string",
                                    "minLength": 1,
                                    "maxLength": 180
                                  },
                                  "visitHash": {
                                    "type": "string",
                                    "pattern": "^[a-f0-9]{64}$"
                                  },
                                  "episodeId": {
                                    "anyOf": [
                                      {
                                        "type": "string",
                                        "pattern": "^episode:[a-f0-9]{64}$"
                                      },
                                      {
                                        "type": "null"
                                      }
                                    ]
                                  },
                                  "membershipHash": {
                                    "anyOf": [
                                      {
                                        "type": "string",
                                        "pattern": "^[a-f0-9]{64}$"
                                      },
                                      {
                                        "type": "null"
                                      }
                                    ]
                                  }
                                }
                              }
                            },
                            "selectionHash": {
                              "type": "string",
                              "pattern": "^[a-f0-9]{64}$"
                            }
                          }
                        },
                        {
                          "type": "null"
                        }
                      ]
                    },
                    "checkpointRequest": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "responsibleOperatorId",
                            "dueAt"
                          ],
                          "properties": {
                            "responsibleOperatorId": {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 128,
                              "pattern": "^[^/]+$"
                            },
                            "dueAt": {
                              "type": "integer",
                              "minimum": 0,
                              "maximum": 9007199254740991
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
                "report": {
                  "anyOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "revision",
                        "rosterHash",
                        "accountedFor",
                        "reportedAt",
                        "reportedBy",
                        "correctionReason"
                      ],
                      "properties": {
                        "revision": {
                          "type": "integer",
                          "minimum": 1,
                          "maximum": 9007199254740991
                        },
                        "rosterHash": {
                          "type": "string",
                          "pattern": "^[a-f0-9]{64}$"
                        },
                        "accountedFor": {
                          "type": "array",
                          "maxItems": 50,
                          "uniqueItems": true,
                          "items": {
                            "type": "string",
                            "minLength": 1,
                            "maxLength": 180
                          }
                        },
                        "reportedAt": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 9007199254740991
                        },
                        "reportedBy": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 180
                        },
                        "correctionReason": {
                          "anyOf": [
                            {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 500,
                              "pattern": "\\S"
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
                "assignment": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "revision",
                    "operationId",
                    "responsibleOperatorId",
                    "previousResponsibleOperatorId",
                    "assignedBy",
                    "assignedAt",
                    "reason"
                  ],
                  "properties": {
                    "revision": {
                      "type": "integer",
                      "minimum": 1,
                      "maximum": 9007199254740991
                    },
                    "responsibleOperatorId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 128,
                      "pattern": "^[^/]+$"
                    },
                    "previousResponsibleOperatorId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 128,
                      "pattern": "^[^/]+$"
                    },
                    "assignedBy": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 128,
                      "pattern": "^[^/]+$"
                    },
                    "assignedAt": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
                    },
                    "reason": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 500,
                      "pattern": "\\S"
                    },
                    "operationId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180
                    }
                  }
                },
                "closeout": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "revision",
                    "previousRevision",
                    "operationId",
                    "changedBy",
                    "changedAt",
                    "reason",
                    "decision"
                  ],
                  "properties": {
                    "revision": {
                      "type": "integer",
                      "minimum": 1,
                      "maximum": 9007199254740991
                    },
                    "previousRevision": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
                    },
                    "changedBy": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 128,
                      "pattern": "^[^/]+$"
                    },
                    "changedAt": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
                    },
                    "reason": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 500,
                      "pattern": "\\S"
                    },
                    "decision": {
                      "oneOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "report",
                            "dispositions"
                          ],
                          "properties": {
                            "kind": {
                              "const": "close"
                            },
                            "report": {
                              "type": "object",
                              "additionalProperties": false,
                              "required": [
                                "revision",
                                "rosterHash",
                                "accountedFor",
                                "reportedAt",
                                "reportedBy",
                                "correctionReason"
                              ],
                              "properties": {
                                "revision": {
                                  "type": "integer",
                                  "minimum": 1,
                                  "maximum": 9007199254740991
                                },
                                "rosterHash": {
                                  "type": "string",
                                  "pattern": "^[a-f0-9]{64}$"
                                },
                                "accountedFor": {
                                  "type": "array",
                                  "maxItems": 50,
                                  "uniqueItems": true,
                                  "items": {
                                    "type": "string",
                                    "minLength": 1,
                                    "maxLength": 180
                                  }
                                },
                                "reportedAt": {
                                  "type": "integer",
                                  "minimum": 0,
                                  "maximum": 9007199254740991
                                },
                                "reportedBy": {
                                  "type": "string",
                                  "minLength": 1,
                                  "maxLength": 180
                                },
                                "correctionReason": {
                                  "anyOf": [
                                    {
                                      "type": "string",
                                      "minLength": 1,
                                      "maxLength": 500,
                                      "pattern": "\\S"
                                    },
                                    {
                                      "type": "null"
                                    }
                                  ]
                                }
                              }
                            },
                            "dispositions": {
                              "type": "array",
                              "maxItems": 50,
                              "items": {
                                "type": "object",
                                "additionalProperties": false,
                                "required": [
                                  "kind",
                                  "disposition",
                                  "revision",
                                  "resolvedAt",
                                  "resolvedBy",
                                  "sourceHash",
                                  "attendeeId"
                                ],
                                "properties": {
                                  "kind": {
                                    "const": "resolved"
                                  },
                                  "disposition": {
                                    "enum": [
                                      "returned",
                                      "departed"
                                    ]
                                  },
                                  "revision": {
                                    "type": "integer",
                                    "minimum": 1,
                                    "maximum": 9007199254740991
                                  },
                                  "resolvedAt": {
                                    "type": "integer",
                                    "minimum": 0,
                                    "maximum": 9007199254740991
                                  },
                                  "resolvedBy": {
                                    "type": "string",
                                    "minLength": 1,
                                    "maxLength": 128,
                                    "pattern": "^[^/]+$"
                                  },
                                  "sourceHash": {
                                    "type": "string",
                                    "pattern": "^[a-f0-9]{64}$"
                                  },
                                  "attendeeId": {
                                    "type": "string",
                                    "minLength": 1,
                                    "maxLength": 160,
                                    "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
                            "kind"
                          ],
                          "properties": {
                            "kind": {
                              "const": "reopen"
                            }
                          }
                        }
                      ]
                    },
                    "operationId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180
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
              "type": "null"
            }
          ]
        }
      }
    },
    "roster": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "sourceHash",
        "members",
        "unavailable",
        "coverage"
      ],
      "properties": {
        "sourceHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "members": {
          "type": "array",
          "maxItems": 50,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "attendeeId",
              "displayName",
              "visitHash",
              "episodeId",
              "membershipHash"
            ],
            "properties": {
              "attendeeId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180
              },
              "displayName": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180
              },
              "visitHash": {
                "type": "string",
                "pattern": "^[a-f0-9]{64}$"
              },
              "episodeId": {
                "anyOf": [
                  {
                    "type": "string",
                    "pattern": "^episode:[a-f0-9]{64}$"
                  },
                  {
                    "type": "null"
                  }
                ]
              },
              "membershipHash": {
                "anyOf": [
                  {
                    "type": "string",
                    "pattern": "^[a-f0-9]{64}$"
                  },
                  {
                    "type": "null"
                  }
                ]
              }
            }
          }
        },
        "unavailable": {
          "type": "array",
          "maxItems": 50,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "attendeeId",
              "reason"
            ],
            "properties": {
              "attendeeId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180
              },
              "reason": {
                "enum": [
                  "notCheckedIn",
                  "participationUnavailable",
                  "membershipUnavailable",
                  "invalidSource"
                ]
              }
            }
          }
        },
        "coverage": {
          "const": "boundedSession"
        }
      }
    },
    "checkpoint": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "progressRevision",
            "checkpointId",
            "sourceHash",
            "revision",
            "availability",
            "report",
            "request",
            "departure"
          ],
          "properties": {
            "progressRevision": {
              "type": "integer",
              "minimum": 1,
              "maximum": 500
            },
            "checkpointId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000
            },
            "sourceHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "revision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "availability": {
              "oneOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "rosterId",
                    "label",
                    "reportStatus",
                    "members"
                  ],
                  "properties": {
                    "kind": {
                      "const": "ready"
                    },
                    "rosterId": {
                      "type": "string",
                      "pattern": "^departure-roster:[a-f0-9]{64}$"
                    },
                    "label": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 240
                    },
                    "reportStatus": {
                      "enum": [
                        "unreported",
                        "partial",
                        "complete"
                      ]
                    },
                    "members": {
                      "type": "array",
                      "maxItems": 1000,
                      "items": {
                        "type": "object",
                        "additionalProperties": false,
                        "required": [
                          "attendeeId",
                          "observation",
                          "visit"
                        ],
                        "properties": {
                          "attendeeId": {
                            "type": "string",
                            "minLength": 1,
                            "maxLength": 160,
                            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                          },
                          "observation": {
                            "enum": [
                              "accountedFor",
                              "unconfirmed"
                            ]
                          },
                          "visit": {
                            "oneOf": [
                              {
                                "type": "object",
                                "additionalProperties": false,
                                "required": [
                                  "kind"
                                ],
                                "properties": {
                                  "kind": {
                                    "const": "current"
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
                                    "const": "unavailable"
                                  },
                                  "reason": {
                                    "enum": [
                                      "registrationMissing",
                                      "visitChanged",
                                      "notCheckedIn",
                                      "invalidSource"
                                    ]
                                  }
                                }
                              }
                            ]
                          },
                          "disposition": {
                            "description": "Visit-bound event accountability evidence. A resolved disposition never means arrival at this checkpoint.",
                            "oneOf": [
                              {
                                "type": "object",
                                "additionalProperties": false,
                                "required": [
                                  "kind"
                                ],
                                "properties": {
                                  "kind": {
                                    "const": "unresolved"
                                  }
                                }
                              },
                              {
                                "type": "object",
                                "additionalProperties": false,
                                "required": [
                                  "kind",
                                  "disposition",
                                  "revision",
                                  "resolvedAt",
                                  "resolvedBy",
                                  "sourceHash"
                                ],
                                "properties": {
                                  "kind": {
                                    "const": "resolved"
                                  },
                                  "disposition": {
                                    "enum": [
                                      "returned",
                                      "departed"
                                    ]
                                  },
                                  "revision": {
                                    "type": "integer",
                                    "minimum": 1,
                                    "maximum": 9007199254740991
                                  },
                                  "resolvedAt": {
                                    "type": "integer",
                                    "minimum": 0,
                                    "maximum": 9007199254740991
                                  },
                                  "resolvedBy": {
                                    "type": "string",
                                    "minLength": 1,
                                    "maxLength": 2000
                                  },
                                  "sourceHash": {
                                    "type": "string",
                                    "pattern": "^[a-f0-9]{64}$"
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
                                    "const": "unavailable"
                                  },
                                  "reason": {
                                    "enum": [
                                      "registrationMissing",
                                      "visitChanged",
                                      "notCheckedIn",
                                      "invalidSource",
                                      "beforeDeparture"
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
                    "kind",
                    "reason"
                  ],
                  "properties": {
                    "kind": {
                      "const": "unavailable"
                    },
                    "reason": {
                      "enum": [
                        "rosterNotRecorded",
                        "destinationNotRecorded",
                        "differentCheckpoint",
                        "notCheckpoint",
                        "setupChanged"
                      ]
                    }
                  }
                }
              ]
            },
            "report": {
              "anyOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "revision",
                    "rosterHash",
                    "accountedFor",
                    "reportedAt",
                    "reportedBy",
                    "correctionReason"
                  ],
                  "properties": {
                    "revision": {
                      "type": "integer",
                      "minimum": 1,
                      "maximum": 9007199254740991
                    },
                    "rosterHash": {
                      "type": "string",
                      "pattern": "^[a-f0-9]{64}$"
                    },
                    "accountedFor": {
                      "type": "array",
                      "maxItems": 50,
                      "uniqueItems": true,
                      "items": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 180
                      }
                    },
                    "reportedAt": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
                    },
                    "reportedBy": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180
                    },
                    "correctionReason": {
                      "anyOf": [
                        {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 500,
                          "pattern": "\\S"
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
            "request": {
              "anyOf": [
                {
                  "oneOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "responsibleOperatorId",
                        "dueAt",
                        "state",
                        "ownerAvailability"
                      ],
                      "properties": {
                        "responsibleOperatorId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 128,
                          "pattern": "^[^/]+$"
                        },
                        "dueAt": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 9007199254740991
                        },
                        "state": {
                          "enum": [
                            "awaitingReport",
                            "overdue",
                            "discrepancy",
                            "sourceUnavailable"
                          ]
                        },
                        "ownerAvailability": {
                          "enum": [
                            "current",
                            "needsReassignment"
                          ]
                        }
                      }
                    },
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "responsibleOperatorId",
                        "dueAt",
                        "state",
                        "ownerAvailability"
                      ],
                      "properties": {
                        "responsibleOperatorId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 128,
                          "pattern": "^[^/]+$"
                        },
                        "dueAt": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 9007199254740991
                        },
                        "state": {
                          "enum": [
                            "complete",
                            "closedOut"
                          ]
                        },
                        "ownerAvailability": {
                          "const": "notRequired"
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
            "departure": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "sourceHash",
                "destination",
                "confirmedAt",
                "confirmedBy",
                "operationId",
                "roster",
                "checkpointRequest"
              ],
              "properties": {
                "sourceHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
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
                "confirmedAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "confirmedBy": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                "roster": {
                  "anyOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "members",
                        "selectionHash"
                      ],
                      "properties": {
                        "members": {
                          "type": "array",
                          "maxItems": 50,
                          "items": {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "attendeeId",
                              "displayName",
                              "visitHash",
                              "episodeId",
                              "membershipHash"
                            ],
                            "properties": {
                              "attendeeId": {
                                "type": "string",
                                "minLength": 1,
                                "maxLength": 180
                              },
                              "displayName": {
                                "type": "string",
                                "minLength": 1,
                                "maxLength": 180
                              },
                              "visitHash": {
                                "type": "string",
                                "pattern": "^[a-f0-9]{64}$"
                              },
                              "episodeId": {
                                "anyOf": [
                                  {
                                    "type": "string",
                                    "pattern": "^episode:[a-f0-9]{64}$"
                                  },
                                  {
                                    "type": "null"
                                  }
                                ]
                              },
                              "membershipHash": {
                                "anyOf": [
                                  {
                                    "type": "string",
                                    "pattern": "^[a-f0-9]{64}$"
                                  },
                                  {
                                    "type": "null"
                                  }
                                ]
                              }
                            }
                          }
                        },
                        "selectionHash": {
                          "type": "string",
                          "pattern": "^[a-f0-9]{64}$"
                        }
                      }
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "checkpointRequest": {
                  "anyOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "responsibleOperatorId",
                        "dueAt"
                      ],
                      "properties": {
                        "responsibleOperatorId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 128,
                          "pattern": "^[^/]+$"
                        },
                        "dueAt": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 9007199254740991
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
            "assignment": {
              "anyOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "revision",
                    "sourceHash",
                    "change"
                  ],
                  "properties": {
                    "revision": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
                    },
                    "sourceHash": {
                      "type": "string",
                      "pattern": "^[a-f0-9]{64}$"
                    },
                    "change": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "revision",
                            "operationId",
                            "responsibleOperatorId",
                            "previousResponsibleOperatorId",
                            "assignedBy",
                            "assignedAt",
                            "reason"
                          ],
                          "properties": {
                            "revision": {
                              "type": "integer",
                              "minimum": 1,
                              "maximum": 9007199254740991
                            },
                            "responsibleOperatorId": {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 128,
                              "pattern": "^[^/]+$"
                            },
                            "previousResponsibleOperatorId": {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 128,
                              "pattern": "^[^/]+$"
                            },
                            "assignedBy": {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 128,
                              "pattern": "^[^/]+$"
                            },
                            "assignedAt": {
                              "type": "integer",
                              "minimum": 0,
                              "maximum": 9007199254740991
                            },
                            "reason": {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 500,
                              "pattern": "\\S"
                            },
                            "operationId": {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 180
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
                {
                  "type": "null"
                }
              ]
            },
            "closeout": {
              "anyOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "revision",
                    "sourceHash",
                    "change",
                    "state",
                    "eligibility"
                  ],
                  "properties": {
                    "revision": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
                    },
                    "sourceHash": {
                      "type": "string",
                      "pattern": "^[a-f0-9]{64}$"
                    },
                    "change": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "revision",
                            "previousRevision",
                            "operationId",
                            "changedBy",
                            "changedAt",
                            "reason",
                            "decision"
                          ],
                          "properties": {
                            "revision": {
                              "type": "integer",
                              "minimum": 1,
                              "maximum": 9007199254740991
                            },
                            "previousRevision": {
                              "type": "integer",
                              "minimum": 0,
                              "maximum": 9007199254740991
                            },
                            "changedBy": {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 128,
                              "pattern": "^[^/]+$"
                            },
                            "changedAt": {
                              "type": "integer",
                              "minimum": 0,
                              "maximum": 9007199254740991
                            },
                            "reason": {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 500,
                              "pattern": "\\S"
                            },
                            "decision": {
                              "oneOf": [
                                {
                                  "type": "object",
                                  "additionalProperties": false,
                                  "required": [
                                    "kind",
                                    "report",
                                    "dispositions"
                                  ],
                                  "properties": {
                                    "kind": {
                                      "const": "close"
                                    },
                                    "report": {
                                      "type": "object",
                                      "additionalProperties": false,
                                      "required": [
                                        "revision",
                                        "rosterHash",
                                        "accountedFor",
                                        "reportedAt",
                                        "reportedBy",
                                        "correctionReason"
                                      ],
                                      "properties": {
                                        "revision": {
                                          "type": "integer",
                                          "minimum": 1,
                                          "maximum": 9007199254740991
                                        },
                                        "rosterHash": {
                                          "type": "string",
                                          "pattern": "^[a-f0-9]{64}$"
                                        },
                                        "accountedFor": {
                                          "type": "array",
                                          "maxItems": 50,
                                          "uniqueItems": true,
                                          "items": {
                                            "type": "string",
                                            "minLength": 1,
                                            "maxLength": 180
                                          }
                                        },
                                        "reportedAt": {
                                          "type": "integer",
                                          "minimum": 0,
                                          "maximum": 9007199254740991
                                        },
                                        "reportedBy": {
                                          "type": "string",
                                          "minLength": 1,
                                          "maxLength": 180
                                        },
                                        "correctionReason": {
                                          "anyOf": [
                                            {
                                              "type": "string",
                                              "minLength": 1,
                                              "maxLength": 500,
                                              "pattern": "\\S"
                                            },
                                            {
                                              "type": "null"
                                            }
                                          ]
                                        }
                                      }
                                    },
                                    "dispositions": {
                                      "type": "array",
                                      "maxItems": 50,
                                      "items": {
                                        "type": "object",
                                        "additionalProperties": false,
                                        "required": [
                                          "kind",
                                          "disposition",
                                          "revision",
                                          "resolvedAt",
                                          "resolvedBy",
                                          "sourceHash",
                                          "attendeeId"
                                        ],
                                        "properties": {
                                          "kind": {
                                            "const": "resolved"
                                          },
                                          "disposition": {
                                            "enum": [
                                              "returned",
                                              "departed"
                                            ]
                                          },
                                          "revision": {
                                            "type": "integer",
                                            "minimum": 1,
                                            "maximum": 9007199254740991
                                          },
                                          "resolvedAt": {
                                            "type": "integer",
                                            "minimum": 0,
                                            "maximum": 9007199254740991
                                          },
                                          "resolvedBy": {
                                            "type": "string",
                                            "minLength": 1,
                                            "maxLength": 128,
                                            "pattern": "^[^/]+$"
                                          },
                                          "sourceHash": {
                                            "type": "string",
                                            "pattern": "^[a-f0-9]{64}$"
                                          },
                                          "attendeeId": {
                                            "type": "string",
                                            "minLength": 1,
                                            "maxLength": 160,
                                            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
                                    "kind"
                                  ],
                                  "properties": {
                                    "kind": {
                                      "const": "reopen"
                                    }
                                  }
                                }
                              ]
                            },
                            "operationId": {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 180
                            }
                          }
                        },
                        {
                          "type": "null"
                        }
                      ]
                    },
                    "state": {
                      "oneOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind"
                          ],
                          "properties": {
                            "kind": {
                              "enum": [
                                "open",
                                "reopened",
                                "closedOut",
                                "superseded"
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
                              "const": "needsReview"
                            },
                            "reason": {
                              "enum": [
                                "sourceUnavailable",
                                "reportChanged",
                                "dispositionChanged"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "eligibility": {
                      "oneOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind"
                          ],
                          "properties": {
                            "kind": {
                              "const": "ready"
                            }
                          }
                        },
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "reason",
                            "attendeeIds"
                          ],
                          "properties": {
                            "kind": {
                              "const": "unavailable"
                            },
                            "reason": {
                              "enum": [
                                "sourceUnavailable",
                                "reportMissing",
                                "reportComplete",
                                "unresolvedMembers",
                                "alreadyClosed"
                              ]
                            },
                            "attendeeIds": {
                              "type": "array",
                              "maxItems": 1000,
                              "uniqueItems": true,
                              "items": {
                                "type": "string",
                                "minLength": 1,
                                "maxLength": 160,
                                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                              }
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
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "history": {
      "type": "array",
      "maxItems": 25,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "progressRevision",
          "destination",
          "confirmedAt",
          "rosterSize",
          "reportRevision",
          "accountedForCount",
          "checkpointRequest"
        ],
        "properties": {
          "progressRevision": {
            "type": "integer",
            "minimum": 1,
            "maximum": 500
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
          "confirmedAt": {
            "type": "integer",
            "minimum": 0,
            "maximum": 9007199254740991
          },
          "rosterSize": {
            "anyOf": [
              {
                "type": "integer",
                "minimum": 0,
                "maximum": 50
              },
              {
                "type": "null"
              }
            ]
          },
          "reportRevision": {
            "type": "integer",
            "minimum": 0,
            "maximum": 9007199254740991
          },
          "accountedForCount": {
            "type": "integer",
            "minimum": 0,
            "maximum": 50
          },
          "checkpointRequest": {
            "anyOf": [
              {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "responsibleOperatorId",
                  "dueAt"
                ],
                "properties": {
                  "responsibleOperatorId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 128,
                    "pattern": "^[^/]+$"
                  },
                  "dueAt": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 9007199254740991
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
    "nextBeforeRevision": {
      "anyOf": [
        {
          "type": "integer",
          "minimum": 1,
          "maximum": 501
        },
        {
          "type": "null"
        }
      ]
    },
    "selected": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "sessionId",
            "clockId",
            "groupId",
            "progressRevision",
            "departure",
            "report"
          ],
          "properties": {
            "sessionId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "clockId": {
              "type": "string",
              "pattern": "^clock:[a-f0-9]{64}$"
            },
            "groupId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "progressRevision": {
              "type": "integer",
              "minimum": 1,
              "maximum": 500
            },
            "departure": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "sourceHash",
                "destination",
                "confirmedAt",
                "confirmedBy",
                "operationId",
                "roster",
                "checkpointRequest"
              ],
              "properties": {
                "sourceHash": {
                  "type": "string",
                  "pattern": "^[a-f0-9]{64}$"
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
                "confirmedAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "confirmedBy": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                "roster": {
                  "anyOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "members",
                        "selectionHash"
                      ],
                      "properties": {
                        "members": {
                          "type": "array",
                          "maxItems": 50,
                          "items": {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "attendeeId",
                              "displayName",
                              "visitHash",
                              "episodeId",
                              "membershipHash"
                            ],
                            "properties": {
                              "attendeeId": {
                                "type": "string",
                                "minLength": 1,
                                "maxLength": 180
                              },
                              "displayName": {
                                "type": "string",
                                "minLength": 1,
                                "maxLength": 180
                              },
                              "visitHash": {
                                "type": "string",
                                "pattern": "^[a-f0-9]{64}$"
                              },
                              "episodeId": {
                                "anyOf": [
                                  {
                                    "type": "string",
                                    "pattern": "^episode:[a-f0-9]{64}$"
                                  },
                                  {
                                    "type": "null"
                                  }
                                ]
                              },
                              "membershipHash": {
                                "anyOf": [
                                  {
                                    "type": "string",
                                    "pattern": "^[a-f0-9]{64}$"
                                  },
                                  {
                                    "type": "null"
                                  }
                                ]
                              }
                            }
                          }
                        },
                        "selectionHash": {
                          "type": "string",
                          "pattern": "^[a-f0-9]{64}$"
                        }
                      }
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "checkpointRequest": {
                  "anyOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "responsibleOperatorId",
                        "dueAt"
                      ],
                      "properties": {
                        "responsibleOperatorId": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 128,
                          "pattern": "^[^/]+$"
                        },
                        "dueAt": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 9007199254740991
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
            "report": {
              "anyOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "revision",
                    "rosterHash",
                    "accountedFor",
                    "reportedAt",
                    "reportedBy",
                    "correctionReason"
                  ],
                  "properties": {
                    "revision": {
                      "type": "integer",
                      "minimum": 1,
                      "maximum": 9007199254740991
                    },
                    "rosterHash": {
                      "type": "string",
                      "pattern": "^[a-f0-9]{64}$"
                    },
                    "accountedFor": {
                      "type": "array",
                      "maxItems": 50,
                      "uniqueItems": true,
                      "items": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 180
                      }
                    },
                    "reportedAt": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 9007199254740991
                    },
                    "reportedBy": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180
                    },
                    "correctionReason": {
                      "anyOf": [
                        {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 500,
                          "pattern": "\\S"
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
            "assignment": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "revision",
                "operationId",
                "responsibleOperatorId",
                "previousResponsibleOperatorId",
                "assignedBy",
                "assignedAt",
                "reason"
              ],
              "properties": {
                "revision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 9007199254740991
                },
                "responsibleOperatorId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 128,
                  "pattern": "^[^/]+$"
                },
                "previousResponsibleOperatorId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 128,
                  "pattern": "^[^/]+$"
                },
                "assignedBy": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 128,
                  "pattern": "^[^/]+$"
                },
                "assignedAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "reason": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 500,
                  "pattern": "\\S"
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                }
              }
            },
            "closeout": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "revision",
                "previousRevision",
                "operationId",
                "changedBy",
                "changedAt",
                "reason",
                "decision"
              ],
              "properties": {
                "revision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 9007199254740991
                },
                "previousRevision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "changedBy": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 128,
                  "pattern": "^[^/]+$"
                },
                "changedAt": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "reason": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 500,
                  "pattern": "\\S"
                },
                "decision": {
                  "oneOf": [
                    {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "report",
                        "dispositions"
                      ],
                      "properties": {
                        "kind": {
                          "const": "close"
                        },
                        "report": {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "revision",
                            "rosterHash",
                            "accountedFor",
                            "reportedAt",
                            "reportedBy",
                            "correctionReason"
                          ],
                          "properties": {
                            "revision": {
                              "type": "integer",
                              "minimum": 1,
                              "maximum": 9007199254740991
                            },
                            "rosterHash": {
                              "type": "string",
                              "pattern": "^[a-f0-9]{64}$"
                            },
                            "accountedFor": {
                              "type": "array",
                              "maxItems": 50,
                              "uniqueItems": true,
                              "items": {
                                "type": "string",
                                "minLength": 1,
                                "maxLength": 180
                              }
                            },
                            "reportedAt": {
                              "type": "integer",
                              "minimum": 0,
                              "maximum": 9007199254740991
                            },
                            "reportedBy": {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 180
                            },
                            "correctionReason": {
                              "anyOf": [
                                {
                                  "type": "string",
                                  "minLength": 1,
                                  "maxLength": 500,
                                  "pattern": "\\S"
                                },
                                {
                                  "type": "null"
                                }
                              ]
                            }
                          }
                        },
                        "dispositions": {
                          "type": "array",
                          "maxItems": 50,
                          "items": {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "kind",
                              "disposition",
                              "revision",
                              "resolvedAt",
                              "resolvedBy",
                              "sourceHash",
                              "attendeeId"
                            ],
                            "properties": {
                              "kind": {
                                "const": "resolved"
                              },
                              "disposition": {
                                "enum": [
                                  "returned",
                                  "departed"
                                ]
                              },
                              "revision": {
                                "type": "integer",
                                "minimum": 1,
                                "maximum": 9007199254740991
                              },
                              "resolvedAt": {
                                "type": "integer",
                                "minimum": 0,
                                "maximum": 9007199254740991
                              },
                              "resolvedBy": {
                                "type": "string",
                                "minLength": 1,
                                "maxLength": 128,
                                "pattern": "^[^/]+$"
                              },
                              "sourceHash": {
                                "type": "string",
                                "pattern": "^[a-f0-9]{64}$"
                              },
                              "attendeeId": {
                                "type": "string",
                                "minLength": 1,
                                "maxLength": 160,
                                "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
                        "kind"
                      ],
                      "properties": {
                        "kind": {
                          "const": "reopen"
                        }
                      }
                    }
                  ]
                },
                "operationId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
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
  },
  "title": "EventRehearsalMovementCallableResponse"
} as const;
