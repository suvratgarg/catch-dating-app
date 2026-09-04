/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const updateClubCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/update_club_payload.schema.json",
  "title": "UpdateClubCallablePayload",
  "description": "Callable payload accepted by updateClub.",
  "x-callable-shape": "patch",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "clubId",
    "fields"
  ],
  "properties": {
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "fields": {
      "type": "object",
      "additionalProperties": false,
      "minProperties": 1,
      "properties": {
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "description": {
          "type": "string",
          "minLength": 1,
          "maxLength": 2000
        },
        "location": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120,
          "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
        },
        "area": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "organizerType": {
          "type": "string",
          "enum": [
            "club",
            "community",
            "individual",
            "eventProducer",
            "venue",
            "brand"
          ],
          "description": "Canonical organizer classification. Club is one organizer subtype; missing legacy values normalize to club during migration."
        },
        "hostName": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "hostAvatarUrl": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 320
        },
        "imageUrl": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 320
        },
        "profileImageUrl": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 320
        },
        "clubPhotos": {
          "type": "array",
          "items": {
            "title": "UploadedPhoto",
            "description": "Canonical uploaded image object for ordered media galleries, logos, and event photos.",
            "type": "object",
            "additionalProperties": false,
            "required": [
              "id",
              "url",
              "storagePath",
              "thumbnailUrl",
              "thumbnailStoragePath",
              "position",
              "createdAt",
              "updatedAt"
            ],
            "properties": {
              "id": {
                "type": "string",
                "minLength": 1,
                "maxLength": 120,
                "pattern": "^[A-Za-z0-9_-]+$"
              },
              "url": {
                "type": "string",
                "format": "uri",
                "maxLength": 2048
              },
              "storagePath": {
                "type": "string",
                "minLength": 1,
                "maxLength": 512,
                "pattern": "^[^/\\u0000][^\\u0000]*$"
              },
              "thumbnailUrl": {
                "anyOf": [
                  {
                    "type": "string",
                    "format": "uri",
                    "maxLength": 2048
                  },
                  {
                    "type": "null"
                  }
                ]
              },
              "thumbnailStoragePath": {
                "anyOf": [
                  {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 512,
                    "pattern": "^[^/\\u0000][^\\u0000]*$"
                  },
                  {
                    "type": "null"
                  }
                ]
              },
              "position": {
                "type": "integer",
                "minimum": 0
              },
              "moderation": {
                "type": [
                  "object",
                  "null"
                ],
                "additionalProperties": false,
                "required": [
                  "status"
                ],
                "properties": {
                  "status": {
                    "type": "string",
                    "enum": [
                      "pending",
                      "approved",
                      "rejected"
                    ]
                  },
                  "reason": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "maxLength": 240
                  },
                  "reviewedAt": {
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
                    ]
                  }
                }
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
                }
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
                }
              }
            },
            "definitions": {
              "storageObjectPath": {
                "type": "string",
                "minLength": 1,
                "maxLength": 512,
                "pattern": "^[^/\\u0000][^\\u0000]*$"
              }
            }
          }
        },
        "logoPhoto": {
          "anyOf": [
            {
              "title": "UploadedPhoto",
              "description": "Canonical uploaded image object for ordered media galleries, logos, and event photos.",
              "type": "object",
              "additionalProperties": false,
              "required": [
                "id",
                "url",
                "storagePath",
                "thumbnailUrl",
                "thumbnailStoragePath",
                "position",
                "createdAt",
                "updatedAt"
              ],
              "properties": {
                "id": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 120,
                  "pattern": "^[A-Za-z0-9_-]+$"
                },
                "url": {
                  "type": "string",
                  "format": "uri",
                  "maxLength": 2048
                },
                "storagePath": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 512,
                  "pattern": "^[^/\\u0000][^\\u0000]*$"
                },
                "thumbnailUrl": {
                  "anyOf": [
                    {
                      "type": "string",
                      "format": "uri",
                      "maxLength": 2048
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "thumbnailStoragePath": {
                  "anyOf": [
                    {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 512,
                      "pattern": "^[^/\\u0000][^\\u0000]*$"
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "position": {
                  "type": "integer",
                  "minimum": 0
                },
                "moderation": {
                  "type": [
                    "object",
                    "null"
                  ],
                  "additionalProperties": false,
                  "required": [
                    "status"
                  ],
                  "properties": {
                    "status": {
                      "type": "string",
                      "enum": [
                        "pending",
                        "approved",
                        "rejected"
                      ]
                    },
                    "reason": {
                      "type": [
                        "string",
                        "null"
                      ],
                      "maxLength": 240
                    },
                    "reviewedAt": {
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
                      ]
                    }
                  }
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
                  }
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
                  }
                }
              },
              "definitions": {
                "storageObjectPath": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 512,
                  "pattern": "^[^/\\u0000][^\\u0000]*$"
                }
              }
            },
            {
              "type": "null"
            }
          ]
        },
        "tags": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 40
          },
          "maxItems": 12,
          "uniqueItems": true
        },
        "instagramHandle": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 320
        },
        "phoneNumber": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 320
        },
        "email": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 320
        },
        "hostDefaults": {
          "type": "object",
          "additionalProperties": false,
          "properties": {
            "primaryActivityKind": {
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
            "supportedActivityKinds": {
              "type": "array",
              "maxItems": 16,
              "uniqueItems": true,
              "items": {
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
              }
            },
            "eventPolicy": {
              "type": "object",
              "additionalProperties": false,
              "properties": {
                "admissionPreset": {
                  "type": "string",
                  "enum": [
                    "openCapacity",
                    "inviteOnly",
                    "balancedSingles",
                    "fixedCohortCaps"
                  ]
                },
                "minAge": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 120
                },
                "maxAge": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 120
                },
                "maxMen": {
                  "type": [
                    "integer",
                    "null"
                  ],
                  "minimum": 0
                },
                "maxWomen": {
                  "type": [
                    "integer",
                    "null"
                  ],
                  "minimum": 0
                },
                "dynamicPricingEnabled": {
                  "type": "boolean"
                },
                "crossPathsPairCapacity": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 100
                },
                "dynamicPricingStepInPaise": {
                  "type": [
                    "integer",
                    "null"
                  ],
                  "minimum": 0,
                  "maximum": 100000000
                },
                "dynamicPricingMaxInPaise": {
                  "type": [
                    "integer",
                    "null"
                  ],
                  "minimum": 0,
                  "maximum": 100000000
                },
                "cancellationPolicyId": {
                  "type": "string",
                  "enum": [
                    "flexible",
                    "standard",
                    "strict"
                  ]
                }
              }
            },
            "eventSuccess": {
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
            "eventSuccessByActivityKind": {
              "type": "object",
              "maxProperties": 16,
              "additionalProperties": {
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
              }
            }
          }
        }
      }
    }
  }
} as const;
