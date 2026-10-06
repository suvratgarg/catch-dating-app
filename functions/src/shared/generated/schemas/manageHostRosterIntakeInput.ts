/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const manageHostRosterIntakeCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/manage_host_roster_intake_payload.schema.json",
  "title": "ManageHostRosterIntakeCallablePayload",
  "description": "Starts, resumes, revises, previews or applies one private Host roster intake.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "action"
  ],
  "properties": {
    "action": {
      "type": "string",
      "enum": [
        "start",
        "get",
        "revise",
        "preview",
        "apply"
      ]
    },
    "sessionId": {
      "type": "string",
      "pattern": "^hri_[a-f0-9]{48}$"
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "fileFingerprint": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "fileName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 255
    },
    "format": {
      "type": "string",
      "enum": [
        "csv",
        "xlsx"
      ]
    },
    "headers": {
      "type": "array",
      "minItems": 1,
      "maxItems": 40,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 120
      }
    },
    "mapping": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "displayName": {
          "type": "integer",
          "minimum": 0,
          "maximum": 39
        },
        "phone": {
          "type": "integer",
          "minimum": 0,
          "maximum": 39
        },
        "email": {
          "type": "integer",
          "minimum": 0,
          "maximum": 39
        },
        "city": {
          "type": "integer",
          "minimum": 0,
          "maximum": 39
        },
        "externalReference": {
          "type": "integer",
          "minimum": 0,
          "maximum": 39
        },
        "arrivalGroup": {
          "type": "integer",
          "minimum": 0,
          "maximum": 39
        },
        "ticketType": {
          "type": "integer",
          "minimum": 0,
          "maximum": 39
        },
        "revenueAmount": {
          "type": "integer",
          "minimum": 0,
          "maximum": 39
        },
        "revenueCurrency": {
          "type": "integer",
          "minimum": 0,
          "maximum": 39
        },
        "status": {
          "type": "integer",
          "minimum": 0,
          "maximum": 39
        }
      }
    },
    "rows": {
      "type": "array",
      "minItems": 1,
      "maxItems": 250,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "value",
          "sourceRowNumber",
          "fields"
        ],
        "properties": {
          "value": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "rowId",
              "displayName",
              "status"
            ],
            "properties": {
              "rowId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 120
              },
              "displayName": {
                "type": "string",
                "maxLength": 120
              },
              "phone": {
                "type": [
                  "string",
                  "null"
                ],
                "maxLength": 40
              },
              "email": {
                "type": [
                  "string",
                  "null"
                ],
                "maxLength": 320
              },
              "cityMarketId": {
                "type": [
                  "string",
                  "null"
                ],
                "maxLength": 80
              },
              "externalReference": {
                "type": [
                  "string",
                  "null"
                ],
                "maxLength": 180
              },
              "arrivalGroup": {
                "type": [
                  "string",
                  "null"
                ],
                "maxLength": 180
              },
              "ticketType": {
                "type": [
                  "string",
                  "null"
                ],
                "maxLength": 120
              },
              "revenueAmountMinor": {
                "type": [
                  "integer",
                  "null"
                ],
                "minimum": 0,
                "maximum": 9007199254740991
              },
              "revenueCurrency": {
                "type": [
                  "string",
                  "null"
                ],
                "pattern": "^[A-Z]{3}$"
              },
              "revenueSource": {
                "type": [
                  "string",
                  "null"
                ],
                "enum": [
                  "hostImport",
                  "hostEstimate",
                  null
                ]
              },
              "status": {
                "type": "string",
                "enum": [
                  "invited",
                  "registered",
                  "waitlisted"
                ]
              }
            }
          },
          "sourceRowNumber": {
            "type": "integer",
            "minimum": 2,
            "maximum": 100000
          },
          "fields": {
            "type": "object",
            "additionalProperties": false,
            "properties": {
              "displayName": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "column",
                  "header",
                  "origin",
                  "confidence"
                ],
                "properties": {
                  "column": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 39
                  },
                  "header": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 120
                  },
                  "origin": {
                    "type": "string",
                    "enum": [
                      "upload",
                      "hostCorrection",
                      "modelProposal"
                    ]
                  },
                  "confidence": {
                    "type": [
                      "number",
                      "null"
                    ],
                    "minimum": 0,
                    "maximum": 1
                  }
                }
              },
              "phone": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "column",
                  "header",
                  "origin",
                  "confidence"
                ],
                "properties": {
                  "column": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 39
                  },
                  "header": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 120
                  },
                  "origin": {
                    "type": "string",
                    "enum": [
                      "upload",
                      "hostCorrection",
                      "modelProposal"
                    ]
                  },
                  "confidence": {
                    "type": [
                      "number",
                      "null"
                    ],
                    "minimum": 0,
                    "maximum": 1
                  }
                }
              },
              "email": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "column",
                  "header",
                  "origin",
                  "confidence"
                ],
                "properties": {
                  "column": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 39
                  },
                  "header": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 120
                  },
                  "origin": {
                    "type": "string",
                    "enum": [
                      "upload",
                      "hostCorrection",
                      "modelProposal"
                    ]
                  },
                  "confidence": {
                    "type": [
                      "number",
                      "null"
                    ],
                    "minimum": 0,
                    "maximum": 1
                  }
                }
              },
              "cityMarketId": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "column",
                  "header",
                  "origin",
                  "confidence"
                ],
                "properties": {
                  "column": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 39
                  },
                  "header": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 120
                  },
                  "origin": {
                    "type": "string",
                    "enum": [
                      "upload",
                      "hostCorrection",
                      "modelProposal"
                    ]
                  },
                  "confidence": {
                    "type": [
                      "number",
                      "null"
                    ],
                    "minimum": 0,
                    "maximum": 1
                  }
                }
              },
              "externalReference": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "column",
                  "header",
                  "origin",
                  "confidence"
                ],
                "properties": {
                  "column": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 39
                  },
                  "header": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 120
                  },
                  "origin": {
                    "type": "string",
                    "enum": [
                      "upload",
                      "hostCorrection",
                      "modelProposal"
                    ]
                  },
                  "confidence": {
                    "type": [
                      "number",
                      "null"
                    ],
                    "minimum": 0,
                    "maximum": 1
                  }
                }
              },
              "arrivalGroup": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "column",
                  "header",
                  "origin",
                  "confidence"
                ],
                "properties": {
                  "column": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 39
                  },
                  "header": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 120
                  },
                  "origin": {
                    "type": "string",
                    "enum": [
                      "upload",
                      "hostCorrection",
                      "modelProposal"
                    ]
                  },
                  "confidence": {
                    "type": [
                      "number",
                      "null"
                    ],
                    "minimum": 0,
                    "maximum": 1
                  }
                }
              },
              "ticketType": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "column",
                  "header",
                  "origin",
                  "confidence"
                ],
                "properties": {
                  "column": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 39
                  },
                  "header": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 120
                  },
                  "origin": {
                    "type": "string",
                    "enum": [
                      "upload",
                      "hostCorrection",
                      "modelProposal"
                    ]
                  },
                  "confidence": {
                    "type": [
                      "number",
                      "null"
                    ],
                    "minimum": 0,
                    "maximum": 1
                  }
                }
              },
              "revenueAmountMinor": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "column",
                  "header",
                  "origin",
                  "confidence"
                ],
                "properties": {
                  "column": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 39
                  },
                  "header": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 120
                  },
                  "origin": {
                    "type": "string",
                    "enum": [
                      "upload",
                      "hostCorrection",
                      "modelProposal"
                    ]
                  },
                  "confidence": {
                    "type": [
                      "number",
                      "null"
                    ],
                    "minimum": 0,
                    "maximum": 1
                  }
                }
              },
              "revenueCurrency": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "column",
                  "header",
                  "origin",
                  "confidence"
                ],
                "properties": {
                  "column": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 39
                  },
                  "header": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 120
                  },
                  "origin": {
                    "type": "string",
                    "enum": [
                      "upload",
                      "hostCorrection",
                      "modelProposal"
                    ]
                  },
                  "confidence": {
                    "type": [
                      "number",
                      "null"
                    ],
                    "minimum": 0,
                    "maximum": 1
                  }
                }
              },
              "revenueSource": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "column",
                  "header",
                  "origin",
                  "confidence"
                ],
                "properties": {
                  "column": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 39
                  },
                  "header": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 120
                  },
                  "origin": {
                    "type": "string",
                    "enum": [
                      "upload",
                      "hostCorrection",
                      "modelProposal"
                    ]
                  },
                  "confidence": {
                    "type": [
                      "number",
                      "null"
                    ],
                    "minimum": 0,
                    "maximum": 1
                  }
                }
              },
              "status": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "column",
                  "header",
                  "origin",
                  "confidence"
                ],
                "properties": {
                  "column": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 39
                  },
                  "header": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 120
                  },
                  "origin": {
                    "type": "string",
                    "enum": [
                      "upload",
                      "hostCorrection",
                      "modelProposal"
                    ]
                  },
                  "confidence": {
                    "type": [
                      "number",
                      "null"
                    ],
                    "minimum": 0,
                    "maximum": 1
                  }
                }
              }
            }
          },
          "rawCells": {
            "type": "array",
            "maxItems": 40,
            "items": {
              "type": "string",
              "maxLength": 500
            }
          },
          "issues": {
            "type": "array",
            "maxItems": 10,
            "items": {
              "type": "string",
              "pattern": "^[a-z][a-z0-9-]{0,79}$"
            }
          }
        }
      }
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 1
    },
    "excludedRowIds": {
      "type": "array",
      "maxItems": 250,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 120
      }
    },
    "reviewHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    }
  }
} as const;
