/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const manageProgramLodgingCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/manage_program_lodging_payload.schema.json",
  "title": "ManageProgramLodgingCallablePayload",
  "description": "Authenticated private lodging commands. Current authority comes from the session and canonical program documents, never this payload. Hotel desk may request only its scoped operational board/confirmation.",
  "type": "object",
  "anyOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "action",
        "programId",
        "guestId"
      ],
      "properties": {
        "action": {
          "const": "readMembership"
        },
        "programId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "guestId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "action",
        "programId",
        "guestId",
        "expectedRevision",
        "groupIds"
      ],
      "properties": {
        "action": {
          "const": "decideMembership"
        },
        "programId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "guestId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "expectedRevision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "groupIds": {
          "type": "array",
          "maxItems": 20,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          }
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "action",
        "programId"
      ],
      "properties": {
        "action": {
          "const": "readSetup"
        },
        "programId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "action",
        "programId",
        "setup",
        "expectedConfigurationRevision",
        "adoptions"
      ],
      "properties": {
        "action": {
          "const": "setup"
        },
        "programId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "setup": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "demand",
            "parties",
            "groupParents",
            "rooms",
            "inventory",
            "labels"
          ],
          "properties": {
            "demand": {
              "type": "array",
              "maxItems": 500,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "guestId",
                  "startsAtMillis",
                  "endsAtMillis",
                  "beds",
                  "requiredFeatures"
                ],
                "properties": {
                  "guestId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180,
                    "x-catch-ownership": "server-only"
                  },
                  "startsAtMillis": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 8640000000000000
                  },
                  "endsAtMillis": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 8640000000000000
                  },
                  "beds": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 100
                  },
                  "requiredFeatures": {
                    "type": "array",
                    "maxItems": 30,
                    "items": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 80
                    },
                    "uniqueItems": true
                  }
                }
              },
              "x-catch-ownership": "server-only"
            },
            "parties": {
              "type": "array",
              "maxItems": 500,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "id",
                  "guestIds",
                  "confirmed",
                  "priority",
                  "requiredRoomType",
                  "pin"
                ],
                "properties": {
                  "id": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180,
                    "x-catch-ownership": "server-only"
                  },
                  "guestIds": {
                    "type": "array",
                    "maxItems": 100,
                    "items": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180,
                      "x-catch-ownership": "server-only"
                    },
                    "minItems": 1,
                    "uniqueItems": true
                  },
                  "confirmed": {
                    "type": "boolean"
                  },
                  "priority": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 1000000
                  },
                  "requiredRoomType": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "minLength": 1,
                    "maxLength": 80
                  },
                  "pin": {
                    "anyOf": [
                      {
                        "type": "object",
                        "additionalProperties": false,
                        "required": [],
                        "properties": {
                          "inventoryId": {
                            "type": "string",
                            "minLength": 1,
                            "maxLength": 180,
                            "x-catch-ownership": "server-only"
                          },
                          "hotelId": {
                            "type": "string",
                            "minLength": 1,
                            "maxLength": 180,
                            "x-catch-ownership": "server-only"
                          },
                          "zoneId": {
                            "type": "string",
                            "minLength": 1,
                            "maxLength": 180,
                            "x-catch-ownership": "server-only"
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
              "x-catch-ownership": "server-only"
            },
            "groupParents": {
              "type": "array",
              "maxItems": 500,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "id",
                  "parentIds"
                ],
                "properties": {
                  "id": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180,
                    "x-catch-ownership": "server-only"
                  },
                  "parentIds": {
                    "type": "array",
                    "maxItems": 20,
                    "items": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180,
                      "x-catch-ownership": "server-only"
                    },
                    "uniqueItems": true
                  }
                }
              },
              "x-catch-ownership": "server-only"
            },
            "rooms": {
              "type": "array",
              "maxItems": 500,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "id",
                  "hotelId",
                  "zoneId",
                  "building",
                  "floor",
                  "wing",
                  "roomType",
                  "beds",
                  "maxOccupants",
                  "verifiedFeatures",
                  "resourceIds",
                  "position"
                ],
                "properties": {
                  "id": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180,
                    "x-catch-ownership": "server-only"
                  },
                  "hotelId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180,
                    "x-catch-ownership": "server-only"
                  },
                  "zoneId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180,
                    "x-catch-ownership": "server-only"
                  },
                  "building": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "minLength": 1,
                    "maxLength": 80
                  },
                  "floor": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "minLength": 1,
                    "maxLength": 80
                  },
                  "wing": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "minLength": 1,
                    "maxLength": 80
                  },
                  "roomType": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 80
                  },
                  "beds": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 100
                  },
                  "maxOccupants": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 100
                  },
                  "verifiedFeatures": {
                    "type": "array",
                    "maxItems": 30,
                    "items": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 80
                    },
                    "uniqueItems": true
                  },
                  "resourceIds": {
                    "type": "array",
                    "maxItems": 100,
                    "items": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180,
                      "x-catch-ownership": "server-only"
                    },
                    "minItems": 1,
                    "uniqueItems": true
                  },
                  "position": {
                    "anyOf": [
                      {
                        "type": "object",
                        "additionalProperties": false,
                        "required": [
                          "x",
                          "y"
                        ],
                        "properties": {
                          "x": {
                            "type": "number",
                            "minimum": 0,
                            "maximum": 1
                          },
                          "y": {
                            "type": "number",
                            "minimum": 0,
                            "maximum": 1
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
              "x-catch-ownership": "server-only"
            },
            "inventory": {
              "type": "array",
              "maxItems": 500,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "id",
                  "contractId",
                  "physicalRoomId",
                  "provisional",
                  "availability"
                ],
                "properties": {
                  "id": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180,
                    "x-catch-ownership": "server-only"
                  },
                  "contractId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180,
                    "x-catch-ownership": "server-only"
                  },
                  "physicalRoomId": {
                    "anyOf": [
                      {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 180,
                        "x-catch-ownership": "server-only"
                      },
                      {
                        "type": "null"
                      }
                    ]
                  },
                  "provisional": {
                    "anyOf": [
                      {
                        "type": "object",
                        "additionalProperties": false,
                        "required": [
                          "hotelId",
                          "zoneId",
                          "building",
                          "floor",
                          "wing",
                          "roomType",
                          "beds",
                          "maxOccupants",
                          "verifiedFeatures"
                        ],
                        "properties": {
                          "hotelId": {
                            "type": "string",
                            "minLength": 1,
                            "maxLength": 180,
                            "x-catch-ownership": "server-only"
                          },
                          "zoneId": {
                            "type": "string",
                            "minLength": 1,
                            "maxLength": 180,
                            "x-catch-ownership": "server-only"
                          },
                          "building": {
                            "type": [
                              "string",
                              "null"
                            ],
                            "minLength": 1,
                            "maxLength": 80
                          },
                          "floor": {
                            "type": [
                              "string",
                              "null"
                            ],
                            "minLength": 1,
                            "maxLength": 80
                          },
                          "wing": {
                            "type": [
                              "string",
                              "null"
                            ],
                            "minLength": 1,
                            "maxLength": 80
                          },
                          "roomType": {
                            "type": "string",
                            "minLength": 1,
                            "maxLength": 80
                          },
                          "beds": {
                            "type": "integer",
                            "minimum": 1,
                            "maximum": 100
                          },
                          "maxOccupants": {
                            "type": "integer",
                            "minimum": 1,
                            "maximum": 100
                          },
                          "verifiedFeatures": {
                            "type": "array",
                            "maxItems": 30,
                            "items": {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 80
                            },
                            "uniqueItems": true
                          }
                        }
                      },
                      {
                        "type": "null"
                      }
                    ]
                  },
                  "availability": {
                    "type": "array",
                    "maxItems": 30,
                    "items": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "arrival",
                        "departure"
                      ],
                      "properties": {
                        "arrival": {
                          "type": "string",
                          "pattern": "^\\d{4}-\\d{2}-\\d{2}$"
                        },
                        "departure": {
                          "type": "string",
                          "pattern": "^\\d{4}-\\d{2}-\\d{2}$"
                        }
                      }
                    },
                    "minItems": 1
                  }
                }
              },
              "x-catch-ownership": "server-only"
            },
            "labels": {
              "type": "array",
              "maxItems": 500,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "inventoryId",
                  "roomLabel"
                ],
                "properties": {
                  "inventoryId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180,
                    "x-catch-ownership": "server-only"
                  },
                  "roomLabel": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "minLength": 1,
                    "maxLength": 40
                  }
                }
              },
              "x-catch-ownership": "server-only"
            }
          }
        },
        "expectedConfigurationRevision": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "adoptions": {
          "type": "array",
          "maxItems": 200,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "stayId",
              "partyId",
              "inventoryId",
              "expectedRevision"
            ],
            "properties": {
              "stayId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180
              },
              "partyId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180
              },
              "inventoryId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180
              },
              "expectedRevision": {
                "type": "integer",
                "minimum": 0,
                "maximum": 9007199254740991
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
        "action",
        "programId"
      ],
      "properties": {
        "action": {
          "const": "preview"
        },
        "programId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "action",
        "programId",
        "placements",
        "expectedRevisions"
      ],
      "properties": {
        "action": {
          "const": "propose"
        },
        "programId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "placements": {
          "type": "array",
          "maxItems": 500,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "partyId",
              "inventoryId"
            ],
            "properties": {
              "partyId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180,
                "x-catch-ownership": "server-only"
              },
              "inventoryId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180,
                "x-catch-ownership": "server-only"
              }
            }
          }
        },
        "expectedRevisions": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "source",
            "inventory",
            "layout",
            "published"
          ],
          "properties": {
            "source": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "inventory": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "layout": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "published": {
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
        "action",
        "programId",
        "placements",
        "expectedRevisions",
        "partyId"
      ],
      "properties": {
        "action": {
          "const": "destinations"
        },
        "programId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "placements": {
          "type": "array",
          "maxItems": 500,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "partyId",
              "inventoryId"
            ],
            "properties": {
              "partyId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180,
                "x-catch-ownership": "server-only"
              },
              "inventoryId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180,
                "x-catch-ownership": "server-only"
              }
            }
          }
        },
        "expectedRevisions": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "source",
            "inventory",
            "layout",
            "published"
          ],
          "properties": {
            "source": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "inventory": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "layout": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "published": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            }
          }
        },
        "partyId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "action",
        "programId",
        "proposal"
      ],
      "properties": {
        "action": {
          "const": "save"
        },
        "programId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "proposal": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "scope",
            "id",
            "revisions",
            "placements",
            "unplacedPartyIds",
            "explanations",
            "score",
            "search"
          ],
          "properties": {
            "scope": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "programId",
                "organizerId"
              ],
              "properties": {
                "programId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180,
                  "x-catch-ownership": "server-only"
                },
                "organizerId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180,
                  "x-catch-ownership": "server-only"
                }
              }
            },
            "id": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "revisions": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "source",
                "inventory",
                "layout",
                "published"
              ],
              "properties": {
                "source": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "inventory": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "layout": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "published": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                }
              }
            },
            "placements": {
              "type": "array",
              "maxItems": 500,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "partyId",
                  "inventoryId"
                ],
                "properties": {
                  "partyId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180,
                    "x-catch-ownership": "server-only"
                  },
                  "inventoryId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180,
                    "x-catch-ownership": "server-only"
                  }
                }
              }
            },
            "unplacedPartyIds": {
              "type": "array",
              "maxItems": 500,
              "items": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180,
                "x-catch-ownership": "server-only"
              }
            },
            "explanations": {
              "type": "array",
              "maxItems": 502,
              "items": {
                "type": "string",
                "maxLength": 2000
              }
            },
            "score": {
              "type": "array",
              "minItems": 5,
              "maxItems": 5,
              "items": {
                "type": "number",
                "minimum": 0
              }
            },
            "search": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "complete",
                "explored"
              ],
              "properties": {
                "complete": {
                  "type": "boolean"
                },
                "explored": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                }
              }
            }
          },
          "x-catch-ownership": "server-only"
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "action",
        "programId",
        "command"
      ],
      "properties": {
        "action": {
          "const": "transition"
        },
        "programId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "command": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "proposalId",
            "operationId",
            "expectedWorkflowRevision",
            "action",
            "hotelId"
          ],
          "properties": {
            "proposalId": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "operationId": {
              "type": "string",
              "pattern": "^[A-Za-z0-9_-]{1,100}$"
            },
            "expectedWorkflowRevision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "action": {
              "type": "string",
              "enum": [
                "approve",
                "confirmHotel",
                "publishGuests"
              ]
            },
            "hotelId": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                {
                  "type": "null"
                }
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
        "action",
        "programId",
        "hotelId"
      ],
      "properties": {
        "action": {
          "const": "hotelBoard"
        },
        "programId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "hotelId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "action",
        "programId",
        "arrival",
        "departure"
      ],
      "properties": {
        "action": {
          "const": "resolveDates"
        },
        "programId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "arrival": {
          "type": "string",
          "pattern": "^\\d{4}-\\d{2}-\\d{2}$"
        },
        "departure": {
          "type": "string",
          "pattern": "^\\d{4}-\\d{2}-\\d{2}$"
        }
      }
    }
  ]
} as const;
