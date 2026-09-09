/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceSettingDocumentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "settingId",
    "context",
    "groupId",
    "workflowKind",
    "revision",
    "preference",
    "sourceHash",
    "updatedBy",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "settingId": {
      "type": "string",
      "pattern": "^setting:[a-f0-9]{64}$"
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
    "groupId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "workflowKind": {
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
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "preference": {
      "oneOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind"
          ],
          "properties": {
            "kind": {
              "const": "inherit"
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
              "const": "disabled"
            }
          }
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "kind",
            "template"
          ],
          "properties": {
            "kind": {
              "const": "configured"
            },
            "template": {
              "oneOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "venueReadiness"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "requirement",
                        "dueBeforeStartMinutes",
                        "disposition"
                      ],
                      "properties": {
                        "requirement": {
                          "type": "string",
                          "const": "meetingPlace"
                        },
                        "dueBeforeStartMinutes": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 10080
                        },
                        "disposition": {
                          "type": "string",
                          "enum": [
                            "blockSelectedOperation",
                            "hostMayAcceptException"
                          ]
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "routeReadiness"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "requirement",
                        "dueBeforeStartMinutes",
                        "disposition"
                      ],
                      "properties": {
                        "requirement": {
                          "type": "string",
                          "const": "route"
                        },
                        "dueBeforeStartMinutes": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 10080
                        },
                        "disposition": {
                          "type": "string",
                          "enum": [
                            "blockSelectedOperation",
                            "hostMayAcceptException"
                          ]
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "formatReadiness"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "requirement",
                        "dueBeforeStartMinutes",
                        "disposition"
                      ],
                      "properties": {
                        "requirement": {
                          "type": "string",
                          "const": "format"
                        },
                        "dueBeforeStartMinutes": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 10080
                        },
                        "disposition": {
                          "type": "string",
                          "enum": [
                            "blockSelectedOperation",
                            "hostMayAcceptException"
                          ]
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "rosterReadiness"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "requirement",
                        "dueBeforeStartMinutes",
                        "disposition"
                      ],
                      "properties": {
                        "requirement": {
                          "type": "string",
                          "const": "roster"
                        },
                        "dueBeforeStartMinutes": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 10080
                        },
                        "disposition": {
                          "type": "string",
                          "enum": [
                            "blockSelectedOperation",
                            "hostMayAcceptException"
                          ]
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "requiredGuestData"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "requirement",
                        "dueBeforeStartMinutes",
                        "disposition"
                      ],
                      "properties": {
                        "requirement": {
                          "type": "string",
                          "const": "guestData"
                        },
                        "dueBeforeStartMinutes": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 10080
                        },
                        "disposition": {
                          "type": "string",
                          "enum": [
                            "blockSelectedOperation",
                            "hostMayAcceptException"
                          ]
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "resourceReadiness"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "requirement",
                        "dueBeforeStartMinutes",
                        "disposition"
                      ],
                      "properties": {
                        "requirement": {
                          "type": "string",
                          "const": "resources"
                        },
                        "dueBeforeStartMinutes": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 10080
                        },
                        "disposition": {
                          "type": "string",
                          "enum": [
                            "blockSelectedOperation",
                            "hostMayAcceptException"
                          ]
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "staffingReadiness"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "requirement",
                        "dueBeforeStartMinutes",
                        "disposition"
                      ],
                      "properties": {
                        "requirement": {
                          "type": "string",
                          "const": "responsibilities"
                        },
                        "dueBeforeStartMinutes": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 10080
                        },
                        "disposition": {
                          "type": "string",
                          "enum": [
                            "blockSelectedOperation",
                            "hostMayAcceptException"
                          ]
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "messagingReadiness"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "requirement",
                        "dueBeforeStartMinutes",
                        "disposition"
                      ],
                      "properties": {
                        "requirement": {
                          "type": "string",
                          "const": "messaging"
                        },
                        "dueBeforeStartMinutes": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 10080
                        },
                        "disposition": {
                          "type": "string",
                          "enum": [
                            "blockSelectedOperation",
                            "hostMayAcceptException"
                          ]
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "admissionReview"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "offerExpiryMinutes",
                        "admission",
                        "releaseCapacity"
                      ],
                      "properties": {
                        "offerExpiryMinutes": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 10080
                        },
                        "admission": {
                          "type": "string",
                          "const": "existingEntitlementPolicy"
                        },
                        "releaseCapacity": {
                          "type": "string",
                          "const": "confirmedOnly"
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "financialReadiness"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "requirement",
                        "dueBeforeStartMinutes",
                        "disposition"
                      ],
                      "properties": {
                        "requirement": {
                          "type": "string",
                          "const": "paymentProvider"
                        },
                        "dueBeforeStartMinutes": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 10080
                        },
                        "disposition": {
                          "type": "string",
                          "enum": [
                            "blockSelectedOperation",
                            "hostMayAcceptException"
                          ]
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "joiningInstructions"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "templateIntent",
                        "audience",
                        "maximumPerGuest",
                        "expiryMinutes"
                      ],
                      "properties": {
                        "templateIntent": {
                          "type": "string",
                          "const": "joining"
                        },
                        "audience": {
                          "type": "string",
                          "const": "affectedGuests"
                        },
                        "maximumPerGuest": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 10080
                        },
                        "expiryMinutes": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 10080
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "identityResolution"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "ambiguousIdentity",
                        "fallback"
                      ],
                      "properties": {
                        "ambiguousIdentity": {
                          "type": "string",
                          "const": "humanResolution"
                        },
                        "fallback": {
                          "type": "string",
                          "const": "hostAssistedOperationalOnly"
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "guestAdmission"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "admission",
                        "overCapacity",
                        "exception"
                      ],
                      "properties": {
                        "admission": {
                          "type": "string",
                          "const": "existingEntitlementPolicy"
                        },
                        "overCapacity": {
                          "type": "string",
                          "const": "deny"
                        },
                        "exception": {
                          "type": "string",
                          "const": "authorizedHost"
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "guestCheckIn"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "operation",
                        "conflict",
                        "attendanceProof"
                      ],
                      "properties": {
                        "operation": {
                          "type": "string",
                          "const": "absolute"
                        },
                        "conflict": {
                          "type": "string",
                          "const": "revisionFence"
                        },
                        "attendanceProof": {
                          "type": "string",
                          "const": "configuredEventPolicy"
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "lateJoin"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
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
                                "kind"
                              ],
                              "properties": {
                                "kind": {
                                  "const": "confirmedGroupProgress"
                                }
                              }
                            },
                            {
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
                    }
                  }
                },
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "participationChange"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "eligibility",
                        "reentry",
                        "guestOptOut"
                      ],
                      "properties": {
                        "eligibility": {
                          "type": "string",
                          "const": "explicitParticipation"
                        },
                        "reentry": {
                          "type": "string",
                          "const": "newEpisode"
                        },
                        "guestOptOut": {
                          "type": "string",
                          "const": "honor"
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "guestPrerequisite"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "requirementsFrom",
                        "fallback"
                      ],
                      "properties": {
                        "requirementsFrom": {
                          "type": "string",
                          "const": "selectedCapabilities"
                        },
                        "fallback": {
                          "type": "string",
                          "const": "explicitlySupportedOnly"
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "allocationRepair"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "scope",
                        "publication",
                        "preserveCompleted",
                        "hardConstraints"
                      ],
                      "properties": {
                        "scope": {
                          "type": "string",
                          "const": "futureOnly"
                        },
                        "publication": {
                          "type": "string",
                          "const": "hostConfirmed"
                        },
                        "preserveCompleted": {
                          "type": "boolean",
                          "const": true
                        },
                        "hardConstraints": {
                          "type": "string",
                          "const": "neverRelax"
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "placementConfirmation"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "observation",
                        "assignmentIsNotObservation"
                      ],
                      "properties": {
                        "observation": {
                          "type": "string",
                          "const": "explicitHost"
                        },
                        "assignmentIsNotObservation": {
                          "type": "boolean",
                          "const": true
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "resourceRecovery"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "scope",
                        "publication",
                        "preserveCompleted",
                        "hardConstraints",
                        "resourceChange"
                      ],
                      "properties": {
                        "scope": {
                          "type": "string",
                          "const": "futureOnly"
                        },
                        "publication": {
                          "type": "string",
                          "const": "hostConfirmed"
                        },
                        "preserveCompleted": {
                          "type": "boolean",
                          "const": true
                        },
                        "hardConstraints": {
                          "type": "string",
                          "const": "neverRelax"
                        },
                        "resourceChange": {
                          "type": "string",
                          "const": "hostConfirmed"
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "fairParticipation"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "objective",
                        "hardConstraints",
                        "publication"
                      ],
                      "properties": {
                        "objective": {
                          "type": "string",
                          "const": "minimizeRepeatedExclusion"
                        },
                        "hardConstraints": {
                          "type": "string",
                          "const": "neverRelax"
                        },
                        "publication": {
                          "type": "string",
                          "const": "hostConfirmed"
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "roundPublication"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "futureDrafts",
                        "publication",
                        "publishedHistory"
                      ],
                      "properties": {
                        "futureDrafts": {
                          "type": "string",
                          "const": "private"
                        },
                        "publication": {
                          "type": "string",
                          "const": "hostConfirmed"
                        },
                        "publishedHistory": {
                          "type": "string",
                          "const": "immutableWithCorrections"
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "unitProgress"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "clock",
                        "progress",
                        "completedResults"
                      ],
                      "properties": {
                        "clock": {
                          "type": "string",
                          "const": "perUnit"
                        },
                        "progress": {
                          "type": "string",
                          "const": "hostConfirmed"
                        },
                        "completedResults": {
                          "type": "string",
                          "const": "preserve"
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "outcomeRecording"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "kind",
                        "correction",
                        "publication"
                      ],
                      "properties": {
                        "kind": {
                          "type": "string",
                          "enum": [
                            "completion",
                            "score",
                            "rank"
                          ]
                        },
                        "correction": {
                          "type": "string",
                          "const": "revisionedFullRound"
                        },
                        "publication": {
                          "type": "string",
                          "const": "existingRevealGate"
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "programmeRecovery"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "scope",
                        "publication",
                        "alreadyPublished"
                      ],
                      "properties": {
                        "scope": {
                          "type": "string",
                          "const": "remainingProgramme"
                        },
                        "publication": {
                          "type": "string",
                          "const": "hostConfirmed"
                        },
                        "alreadyPublished": {
                          "type": "string",
                          "const": "correctExplicitly"
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "departure"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "confirmation",
                        "scope",
                        "plannedTimeIsNotProof"
                      ],
                      "properties": {
                        "confirmation": {
                          "type": "string",
                          "const": "responsibleOperator"
                        },
                        "scope": {
                          "type": "string",
                          "const": "perMovingGroup"
                        },
                        "plannedTimeIsNotProof": {
                          "type": "boolean",
                          "const": true
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "checkpoint"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "reportBy",
                        "scope",
                        "reportDeadlineMinutes"
                      ],
                      "properties": {
                        "reportBy": {
                          "type": "string",
                          "const": "responsibleOperator"
                        },
                        "scope": {
                          "type": "string",
                          "const": "departureRoster"
                        },
                        "reportDeadlineMinutes": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 10080
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "groupTransfer"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "handover",
                        "membership"
                      ],
                      "properties": {
                        "handover": {
                          "type": "string",
                          "const": "receivingOperatorAcknowledges"
                        },
                        "membership": {
                          "type": "string",
                          "const": "singleActiveGroup"
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "routeRecovery"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "scope",
                        "publication",
                        "alreadyPublished",
                        "alternative"
                      ],
                      "properties": {
                        "scope": {
                          "type": "string",
                          "const": "remainingProgramme"
                        },
                        "publication": {
                          "type": "string",
                          "const": "hostConfirmed"
                        },
                        "alreadyPublished": {
                          "type": "string",
                          "const": "correctExplicitly"
                        },
                        "alternative": {
                          "type": "string",
                          "const": "hostApproved"
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "locationFreshness"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "staleAfterSeconds",
                        "fallback",
                        "tracking"
                      ],
                      "properties": {
                        "staleAfterSeconds": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 10080
                        },
                        "fallback": {
                          "type": "string",
                          "const": "confirmedJoiningPoint"
                        },
                        "tracking": {
                          "type": "string",
                          "const": "authorizedOperatorOnly"
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "accountability"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "mode",
                        "evidence",
                        "unknownIsNotIncident"
                      ],
                      "properties": {
                        "mode": {
                          "type": "string",
                          "enum": [
                            "rollCall",
                            "sweep"
                          ]
                        },
                        "evidence": {
                          "type": "string",
                          "const": "explicitDisposition"
                        },
                        "unknownIsNotIncident": {
                          "type": "boolean",
                          "const": true
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "planChangeCommunication"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "templateIntent",
                        "audience",
                        "maximumPerGuest",
                        "expiryMinutes"
                      ],
                      "properties": {
                        "templateIntent": {
                          "type": "string",
                          "const": "planChange"
                        },
                        "audience": {
                          "type": "string",
                          "const": "affectedGuests"
                        },
                        "maximumPerGuest": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 10080
                        },
                        "expiryMinutes": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 10080
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "deliveryRecovery"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "maximumAttempts",
                        "onUnknown",
                        "expiresAfterMinutes"
                      ],
                      "properties": {
                        "maximumAttempts": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 10080
                        },
                        "onUnknown": {
                          "type": "string",
                          "const": "reconcileBeforeRetry"
                        },
                        "expiresAfterMinutes": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 10080
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "replyOwnership"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "owner",
                        "visibility",
                        "dueMinutes"
                      ],
                      "properties": {
                        "owner": {
                          "type": "string",
                          "enum": [
                            "eventLead",
                            "groupLead",
                            "sweep",
                            "checkIn",
                            "specialist"
                          ]
                        },
                        "visibility": {
                          "type": "string",
                          "enum": [
                            "operational",
                            "restricted"
                          ]
                        },
                        "dueMinutes": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 10080
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "guestAssistance"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "owner",
                        "visibility",
                        "dueMinutes"
                      ],
                      "properties": {
                        "owner": {
                          "type": "string",
                          "enum": [
                            "eventLead",
                            "groupLead",
                            "sweep",
                            "checkIn",
                            "specialist"
                          ]
                        },
                        "visibility": {
                          "type": "string",
                          "enum": [
                            "operational",
                            "restricted"
                          ]
                        },
                        "dueMinutes": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 10080
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "comfortSafety"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "owner",
                        "visibility",
                        "dueMinutes"
                      ],
                      "properties": {
                        "owner": {
                          "type": "string",
                          "enum": [
                            "eventLead",
                            "groupLead",
                            "sweep",
                            "checkIn",
                            "specialist"
                          ]
                        },
                        "visibility": {
                          "type": "string",
                          "const": "restricted"
                        },
                        "dueMinutes": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 10080
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "attendanceSync"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "maximumAttempts",
                        "onUnknown",
                        "expiresAfterMinutes"
                      ],
                      "properties": {
                        "maximumAttempts": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 10080
                        },
                        "onUnknown": {
                          "type": "string",
                          "const": "reconcileBeforeRetry"
                        },
                        "expiresAfterMinutes": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 10080
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "concurrencyRecovery"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "staleWrite",
                        "retry"
                      ],
                      "properties": {
                        "staleWrite": {
                          "type": "string",
                          "const": "reject"
                        },
                        "retry": {
                          "type": "string",
                          "const": "revalidateIntent"
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "operationRecovery"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "maximumAttempts",
                        "onUnknown",
                        "expiresAfterMinutes"
                      ],
                      "properties": {
                        "maximumAttempts": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 10080
                        },
                        "onUnknown": {
                          "type": "string",
                          "const": "reconcileBeforeRetry"
                        },
                        "expiresAfterMinutes": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 10080
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "contextBoundary"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "context",
                        "crossContext"
                      ],
                      "properties": {
                        "context": {
                          "type": "string",
                          "const": "eventAndModeBound"
                        },
                        "crossContext": {
                          "type": "string",
                          "const": "deny"
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "overrideReview"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "hardLimits",
                        "permittedOverride"
                      ],
                      "properties": {
                        "hardLimits": {
                          "type": "string",
                          "const": "neverOverride"
                        },
                        "permittedOverride": {
                          "type": "string",
                          "const": "scopedReasonedExpiring"
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "eventClosure"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "pendingLiveWork",
                        "survivingObligations",
                        "unresolvedAccountability"
                      ],
                      "properties": {
                        "pendingLiveWork": {
                          "type": "string",
                          "const": "cancel"
                        },
                        "survivingObligations": {
                          "type": "string",
                          "const": "handoff"
                        },
                        "unresolvedAccountability": {
                          "type": "string",
                          "const": "explicitPolicy"
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "attendanceReconciliation"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "silence",
                        "corrections",
                        "pendingSync"
                      ],
                      "properties": {
                        "silence": {
                          "type": "string",
                          "const": "notEvidence"
                        },
                        "corrections": {
                          "type": "string",
                          "const": "revisioned"
                        },
                        "pendingSync": {
                          "type": "string",
                          "const": "retain"
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "financialReconciliation"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "owner",
                        "moneyMovement"
                      ],
                      "properties": {
                        "owner": {
                          "type": "string",
                          "const": "paymentProviderWorkflow"
                        },
                        "moneyMovement": {
                          "type": "string",
                          "const": "separatelyAuthorized"
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "postEventFollowUp"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "templateIntent",
                        "audience",
                        "maximumPerGuest",
                        "expiryMinutes"
                      ],
                      "properties": {
                        "templateIntent": {
                          "type": "string",
                          "const": "followUp"
                        },
                        "audience": {
                          "type": "string",
                          "const": "affectedGuests"
                        },
                        "maximumPerGuest": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 10080
                        },
                        "expiryMinutes": {
                          "type": "integer",
                          "minimum": 0,
                          "maximum": 10080
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
                    "version",
                    "setting",
                    "config"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "eventLearning"
                    },
                    "version": {
                      "const": 1
                    },
                    "setting": {
                      "anyOf": [
                        {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "kind",
                            "authority"
                          ],
                          "properties": {
                            "kind": {
                              "type": "string",
                              "const": "enabled"
                            },
                            "authority": {
                              "type": "string",
                              "enum": [
                                "observe",
                                "prepare",
                                "executeWithinPolicy"
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
                              "const": "disabled"
                            },
                            "reason": {
                              "type": "string",
                              "enum": [
                                "hostChoice",
                                "organizerDefault"
                              ]
                            }
                          }
                        }
                      ]
                    },
                    "config": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "metrics",
                        "missingCoverage",
                        "sensitiveDetails"
                      ],
                      "properties": {
                        "metrics": {
                          "type": "string",
                          "const": "observedOutcomes"
                        },
                        "missingCoverage": {
                          "type": "string",
                          "const": "explicit"
                        },
                        "sensitiveDetails": {
                          "type": "string",
                          "const": "excluded"
                        }
                      }
                    }
                  }
                }
              ]
            }
          }
        }
      ]
    },
    "sourceHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "updatedBy": {
      "type": "string",
      "minLength": 1,
      "maxLength": 2000
    },
    "createdAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "updatedAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    }
  },
  "title": "EventAssistanceSettingDocument",
  "x-firestore-collection": "eventAssistanceSettings",
  "x-firestore-path": "eventAssistanceSettings/{settingId}",
  "x-document-id-field": "settingId",
  "x-owner": "event-assistance policy configuration"
} as const;
