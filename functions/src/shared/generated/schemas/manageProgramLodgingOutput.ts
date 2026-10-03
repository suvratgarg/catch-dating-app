/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const manageProgramLodgingCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/manage_program_lodging_response.schema.json",
  "title": "ManageProgramLodgingCallableResponse",
  "x-callable-aliases": [
    "manageProgramLodging"
  ],
  "description": "Strict role-specific lodging result. Coordinator context is private; hotelBoard contains only allowlisted operational fields.",
  "type": "object",
  "anyOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "configuration",
        "accessExpiresAtMillis",
        "catalog"
      ],
      "properties": {
        "kind": {
          "const": "readSetup"
        },
        "configuration": {
          "anyOf": [
            {
              "title": "ProgramLodgingConfigDocument",
              "description": "Private event lodging setup referencing canonical program guest/group/hotel/room-block IDs. Contains explicit demand and sharing choices, exact or provisional inventory, and verified layered 2D facts; no copied contact records or public hotel catalog.",
              "x-firestore-collection": "programLodgingConfigs",
              "x-firestore-path": "programLodgingConfigs/{programId}",
              "x-document-id-field": "programId",
              "x-owner": "program lodging coordinator configuration",
              "type": "object",
              "additionalProperties": false,
              "required": [
                "programId",
                "organizerId",
                "revision",
                "demand",
                "parties",
                "groupParents",
                "rooms",
                "inventory",
                "labels"
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
                },
                "revision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 9007199254740991,
                  "x-catch-ownership": "server-only"
                },
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
            {
              "type": "null"
            }
          ]
        },
        "accessExpiresAtMillis": {
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
        "catalog": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "programId",
            "organizerId",
            "timezone",
            "guests",
            "groups",
            "hotels",
            "contracts",
            "activeStays"
          ],
          "properties": {
            "programId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "organizerId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "timezone": {
              "type": "string",
              "minLength": 1,
              "maxLength": 80
            },
            "guests": {
              "type": "array",
              "maxItems": 500,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "id",
                  "label",
                  "householdId",
                  "groupIds"
                ],
                "properties": {
                  "id": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "label": {
                    "type": "string",
                    "maxLength": 200
                  },
                  "householdId": {
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
              }
            },
            "groups": {
              "type": "array",
              "maxItems": 500,
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
                    "maxLength": 180
                  },
                  "label": {
                    "type": "string",
                    "maxLength": 200
                  }
                }
              }
            },
            "hotels": {
              "type": "array",
              "maxItems": 500,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "id",
                  "label",
                  "active"
                ],
                "properties": {
                  "id": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "label": {
                    "type": "string",
                    "maxLength": 200
                  },
                  "active": {
                    "type": "boolean"
                  }
                }
              }
            },
            "contracts": {
              "type": "array",
              "maxItems": 500,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "id",
                  "hotelId",
                  "label",
                  "roomType",
                  "totalRooms",
                  "maxOccupantsPerRoom",
                  "startsAtMillis",
                  "endsAtMillis"
                ],
                "properties": {
                  "id": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "hotelId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "label": {
                    "type": "string",
                    "maxLength": 200
                  },
                  "roomType": {
                    "anyOf": [
                      {
                        "type": "string",
                        "maxLength": 80
                      },
                      {
                        "type": "null"
                      }
                    ]
                  },
                  "totalRooms": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 500
                  },
                  "maxOccupantsPerRoom": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 100
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
                  }
                }
              }
            },
            "activeStays": {
              "type": "array",
              "maxItems": 2000,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "id",
                  "guestId",
                  "hotelId",
                  "roomBlockId",
                  "roomLabel",
                  "roomOccupancyId",
                  "lodgingPartyId",
                  "lodgingInventoryId",
                  "startsAtMillis",
                  "endsAtMillis",
                  "status",
                  "revision"
                ],
                "properties": {
                  "id": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "guestId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "hotelId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "roomBlockId": {
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
                  },
                  "roomLabel": {
                    "anyOf": [
                      {
                        "type": "string",
                        "maxLength": 80
                      },
                      {
                        "type": "null"
                      }
                    ]
                  },
                  "roomOccupancyId": {
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
                  },
                  "lodgingPartyId": {
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
                  },
                  "lodgingInventoryId": {
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
                  },
                  "startsAtMillis": {
                    "anyOf": [
                      {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 8640000000000000
                      },
                      {
                        "type": "null"
                      }
                    ]
                  },
                  "endsAtMillis": {
                    "anyOf": [
                      {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 8640000000000000
                      },
                      {
                        "type": "null"
                      }
                    ]
                  },
                  "status": {
                    "enum": [
                      "held",
                      "confirmed",
                      "checkedIn"
                    ]
                  },
                  "revision": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 9007199254740991
                  }
                }
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
        "revision"
      ],
      "properties": {
        "kind": {
          "const": "setup"
        },
        "revision": {
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
        "proposal",
        "context"
      ],
      "properties": {
        "kind": {
          "const": "proposal"
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
        },
        "context": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "snapshot",
            "configuration",
            "labels",
            "workflow",
            "accessExpiresAtMillis"
          ],
          "properties": {
            "snapshot": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "scope",
                "revisions",
                "guests",
                "parties",
                "groups",
                "memberships",
                "rooms",
                "contracts",
                "inventory",
                "published"
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
                      "maxLength": 180
                    },
                    "organizerId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 180
                    }
                  }
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
                "guests": {
                  "type": "array",
                  "maxItems": 500,
                  "items": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "id",
                      "arrival",
                      "departure",
                      "beds",
                      "requiredFeatures"
                    ],
                    "properties": {
                      "id": {
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
                        }
                      }
                    }
                  }
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
                "groups": {
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
                "memberships": {
                  "type": "array",
                  "maxItems": 10000,
                  "items": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "guestId",
                      "groupId",
                      "included",
                      "authority",
                      "sourceId"
                    ],
                    "properties": {
                      "guestId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 180
                      },
                      "groupId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 180
                      },
                      "included": {
                        "type": "boolean"
                      },
                      "authority": {
                        "type": "string",
                        "enum": [
                          "canonical",
                          "manual",
                          "acceptedSuggestion"
                        ]
                      },
                      "sourceId": {
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
                "contracts": {
                  "type": "array",
                  "maxItems": 500,
                  "items": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "id",
                      "hotelId",
                      "arrival",
                      "departure",
                      "nightlyRoomQuota"
                    ],
                    "properties": {
                      "id": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 180
                      },
                      "hotelId": {
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
                      },
                      "nightlyRoomQuota": {
                        "type": "integer",
                        "minimum": 1,
                        "maximum": 1000000
                      }
                    }
                  }
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
                "published": {
                  "type": "array",
                  "maxItems": 500,
                  "items": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "partyId",
                      "inventoryId",
                      "locked",
                      "checkedIn"
                    ],
                    "properties": {
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
                      "locked": {
                        "type": "boolean"
                      },
                      "checkedIn": {
                        "type": "boolean"
                      }
                    }
                  }
                }
              }
            },
            "configuration": {
              "title": "ProgramLodgingConfigDocument",
              "description": "Private event lodging setup referencing canonical program guest/group/hotel/room-block IDs. Contains explicit demand and sharing choices, exact or provisional inventory, and verified layered 2D facts; no copied contact records or public hotel catalog.",
              "x-firestore-collection": "programLodgingConfigs",
              "x-firestore-path": "programLodgingConfigs/{programId}",
              "x-document-id-field": "programId",
              "x-owner": "program lodging coordinator configuration",
              "type": "object",
              "additionalProperties": false,
              "required": [
                "programId",
                "organizerId",
                "revision",
                "demand",
                "parties",
                "groupParents",
                "rooms",
                "inventory",
                "labels"
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
                },
                "revision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 9007199254740991,
                  "x-catch-ownership": "server-only"
                },
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
            "labels": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "guests",
                "groups",
                "hotels"
              ],
              "properties": {
                "guests": {
                  "type": "object",
                  "maxProperties": 500,
                  "additionalProperties": {
                    "type": "string",
                    "maxLength": 200
                  }
                },
                "groups": {
                  "type": "object",
                  "maxProperties": 500,
                  "additionalProperties": {
                    "type": "string",
                    "maxLength": 200
                  }
                },
                "hotels": {
                  "type": "object",
                  "maxProperties": 500,
                  "additionalProperties": {
                    "type": "string",
                    "maxLength": 200
                  }
                }
              }
            },
            "workflow": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "revision",
                "approvedProposalId",
                "confirmedHotelIds",
                "guestPublishedProposalId"
              ],
              "properties": {
                "revision": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9007199254740991
                },
                "approvedProposalId": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "pattern": "^[a-f0-9]{64}$"
                },
                "confirmedHotelIds": {
                  "type": "array",
                  "maxItems": 500,
                  "items": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180,
                    "x-catch-ownership": "server-only"
                  },
                  "uniqueItems": true
                },
                "guestPublishedProposalId": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "pattern": "^[a-f0-9]{64}$"
                }
              },
              "x-catch-ownership": "server-only"
            },
            "accessExpiresAtMillis": {
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
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "revisions",
        "destinations"
      ],
      "properties": {
        "kind": {
          "const": "destinations"
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
        "destinations": {
          "type": "array",
          "maxItems": 500,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "inventoryId",
              "allowed",
              "explanation"
            ],
            "properties": {
              "inventoryId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180
              },
              "allowed": {
                "type": "boolean"
              },
              "explanation": {
                "type": "string",
                "maxLength": 1000
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
        "proposal"
      ],
      "properties": {
        "kind": {
          "const": "saved"
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
        "kind",
        "workflow",
        "receipt",
        "replayed"
      ],
      "properties": {
        "kind": {
          "const": "transition"
        },
        "workflow": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "revision",
            "approvedProposalId",
            "confirmedHotelIds",
            "guestPublishedProposalId"
          ],
          "properties": {
            "revision": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "approvedProposalId": {
              "type": [
                "string",
                "null"
              ],
              "pattern": "^[a-f0-9]{64}$"
            },
            "confirmedHotelIds": {
              "type": "array",
              "maxItems": 500,
              "items": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180,
                "x-catch-ownership": "server-only"
              },
              "uniqueItems": true
            },
            "guestPublishedProposalId": {
              "type": [
                "string",
                "null"
              ],
              "pattern": "^[a-f0-9]{64}$"
            }
          },
          "x-catch-ownership": "server-only"
        },
        "receipt": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "operationId",
            "requestHash",
            "actorUid",
            "resultingRevision"
          ],
          "properties": {
            "operationId": {
              "type": "string",
              "pattern": "^[A-Za-z0-9_-]{1,100}$"
            },
            "requestHash": {
              "type": "string",
              "pattern": "^[a-f0-9]{64}$"
            },
            "actorUid": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180,
              "x-catch-ownership": "server-only"
            },
            "resultingRevision": {
              "type": "integer",
              "minimum": 1,
              "maximum": 9007199254740991,
              "x-catch-ownership": "server-only"
            }
          },
          "x-catch-ownership": "server-only"
        },
        "replayed": {
          "type": "boolean"
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "kind",
        "rows"
      ],
      "properties": {
        "kind": {
          "const": "hotelBoard"
        },
        "rows": {
          "type": "array",
          "maxItems": 500,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "partyId",
              "inventoryId",
              "physicalRoomId",
              "zoneId",
              "roomType",
              "guests"
            ],
            "properties": {
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
              "physicalRoomId": {
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
              },
              "zoneId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180
              },
              "roomType": {
                "type": "string",
                "minLength": 1,
                "maxLength": 80
              },
              "guests": {
                "type": "array",
                "maxItems": 100,
                "items": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "guestId",
                    "arrival",
                    "departure"
                  ],
                  "properties": {
                    "guestId": {
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
              }
            }
          }
        }
      }
    }
  ]
} as const;
