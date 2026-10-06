/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const hostRosterIntakeReceiptDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/host_roster_intake_receipts.schema.json",
  "title": "HostRosterIntakeReceiptDocument",
  "description": "Private exact reviewed payload and outcome used for lost-response replay.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "hostRosterIntakeReceipts",
  "x-firestore-path": "hostRosterIntakeSessions/{sessionId}/receipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "manageHostRosterIntake callable; atomically committed with canonical import",
  "required": [
    "importId",
    "appliedAtMillis",
    "preview",
    "payload"
  ],
  "properties": {
    "importId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "appliedAtMillis": {
      "type": "integer",
      "minimum": 0
    },
    "preview": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "sessionId",
        "revision",
        "reviewHash",
        "rows",
        "counts",
        "eligibleForApply"
      ],
      "properties": {
        "sessionId": {
          "type": "string",
          "pattern": "^hri_[a-f0-9]{48}$"
        },
        "revision": {
          "type": "integer",
          "minimum": 1
        },
        "reviewHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "rows": {
          "type": "array",
          "minItems": 1,
          "maxItems": 250,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "rowId",
              "sourceRowNumber",
              "attendeeId",
              "kind",
              "changedFields",
              "issueCode"
            ],
            "properties": {
              "rowId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 120
              },
              "sourceRowNumber": {
                "type": "integer",
                "minimum": 2,
                "maximum": 100000
              },
              "attendeeId": {
                "type": [
                  "string",
                  "null"
                ],
                "minLength": 1,
                "maxLength": 128
              },
              "kind": {
                "type": "string",
                "enum": [
                  "add",
                  "update",
                  "unchanged",
                  "excluded",
                  "needsReview",
                  "identityConflict"
                ]
              },
              "changedFields": {
                "type": "array",
                "maxItems": 11,
                "uniqueItems": true,
                "items": {
                  "type": "string",
                  "enum": [
                    "displayName",
                    "phone",
                    "email",
                    "cityMarketId",
                    "externalReference",
                    "arrivalGroup",
                    "ticketType",
                    "revenueAmountMinor",
                    "revenueCurrency",
                    "revenueSource",
                    "status"
                  ]
                }
              },
              "issueCode": {
                "type": [
                  "string",
                  "null"
                ],
                "minLength": 1,
                "maxLength": 80
              }
            }
          }
        },
        "counts": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "add",
            "update",
            "unchanged",
            "excluded",
            "needsReview",
            "identityConflict"
          ],
          "properties": {
            "add": {
              "type": "integer",
              "minimum": 0,
              "maximum": 250
            },
            "update": {
              "type": "integer",
              "minimum": 0,
              "maximum": 250
            },
            "unchanged": {
              "type": "integer",
              "minimum": 0,
              "maximum": 250
            },
            "excluded": {
              "type": "integer",
              "minimum": 0,
              "maximum": 250
            },
            "needsReview": {
              "type": "integer",
              "minimum": 0,
              "maximum": 250
            },
            "identityConflict": {
              "type": "integer",
              "minimum": 0,
              "maximum": 250
            }
          }
        },
        "eligibleForApply": {
          "type": "boolean"
        }
      }
    },
    "payload": {
      "title": "ImportEventAttendeesCallablePayload",
      "description": "Callable payload accepted by importEventAttendees.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "eventId",
        "importKey",
        "fileName",
        "format",
        "rows"
      ],
      "properties": {
        "eventId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "importKey": {
          "type": "string",
          "minLength": 8,
          "maxLength": 120
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
            "xlsx",
            "manual"
          ]
        },
        "rows": {
          "type": "array",
          "minItems": 1,
          "maxItems": 250,
          "items": {
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
                "minLength": 1,
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
                "anyOf": [
                  {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 120,
                    "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
                  },
                  {
                    "type": "null"
                  }
                ]
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
          }
        }
      }
    }
  },
  "definitions": {
    "previewKind": {
      "type": "string",
      "enum": [
        "add",
        "update",
        "unchanged",
        "excluded",
        "needsReview",
        "identityConflict"
      ]
    },
    "changedField": {
      "type": "string",
      "enum": [
        "displayName",
        "phone",
        "email",
        "cityMarketId",
        "externalReference",
        "arrivalGroup",
        "ticketType",
        "revenueAmountMinor",
        "revenueCurrency",
        "revenueSource",
        "status"
      ]
    },
    "previewRow": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "rowId",
        "sourceRowNumber",
        "attendeeId",
        "kind",
        "changedFields",
        "issueCode"
      ],
      "properties": {
        "rowId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "sourceRowNumber": {
          "type": "integer",
          "minimum": 2,
          "maximum": 100000
        },
        "attendeeId": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 128
        },
        "kind": {
          "type": "string",
          "enum": [
            "add",
            "update",
            "unchanged",
            "excluded",
            "needsReview",
            "identityConflict"
          ]
        },
        "changedFields": {
          "type": "array",
          "maxItems": 11,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "enum": [
              "displayName",
              "phone",
              "email",
              "cityMarketId",
              "externalReference",
              "arrivalGroup",
              "ticketType",
              "revenueAmountMinor",
              "revenueCurrency",
              "revenueSource",
              "status"
            ]
          }
        },
        "issueCode": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 80
        }
      }
    },
    "counts": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "add",
        "update",
        "unchanged",
        "excluded",
        "needsReview",
        "identityConflict"
      ],
      "properties": {
        "add": {
          "type": "integer",
          "minimum": 0,
          "maximum": 250
        },
        "update": {
          "type": "integer",
          "minimum": 0,
          "maximum": 250
        },
        "unchanged": {
          "type": "integer",
          "minimum": 0,
          "maximum": 250
        },
        "excluded": {
          "type": "integer",
          "minimum": 0,
          "maximum": 250
        },
        "needsReview": {
          "type": "integer",
          "minimum": 0,
          "maximum": 250
        },
        "identityConflict": {
          "type": "integer",
          "minimum": 0,
          "maximum": 250
        }
      }
    },
    "preview": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "sessionId",
        "revision",
        "reviewHash",
        "rows",
        "counts",
        "eligibleForApply"
      ],
      "properties": {
        "sessionId": {
          "type": "string",
          "pattern": "^hri_[a-f0-9]{48}$"
        },
        "revision": {
          "type": "integer",
          "minimum": 1
        },
        "reviewHash": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "rows": {
          "type": "array",
          "minItems": 1,
          "maxItems": 250,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "rowId",
              "sourceRowNumber",
              "attendeeId",
              "kind",
              "changedFields",
              "issueCode"
            ],
            "properties": {
              "rowId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 120
              },
              "sourceRowNumber": {
                "type": "integer",
                "minimum": 2,
                "maximum": 100000
              },
              "attendeeId": {
                "type": [
                  "string",
                  "null"
                ],
                "minLength": 1,
                "maxLength": 128
              },
              "kind": {
                "type": "string",
                "enum": [
                  "add",
                  "update",
                  "unchanged",
                  "excluded",
                  "needsReview",
                  "identityConflict"
                ]
              },
              "changedFields": {
                "type": "array",
                "maxItems": 11,
                "uniqueItems": true,
                "items": {
                  "type": "string",
                  "enum": [
                    "displayName",
                    "phone",
                    "email",
                    "cityMarketId",
                    "externalReference",
                    "arrivalGroup",
                    "ticketType",
                    "revenueAmountMinor",
                    "revenueCurrency",
                    "revenueSource",
                    "status"
                  ]
                }
              },
              "issueCode": {
                "type": [
                  "string",
                  "null"
                ],
                "minLength": 1,
                "maxLength": 80
              }
            }
          }
        },
        "counts": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "add",
            "update",
            "unchanged",
            "excluded",
            "needsReview",
            "identityConflict"
          ],
          "properties": {
            "add": {
              "type": "integer",
              "minimum": 0,
              "maximum": 250
            },
            "update": {
              "type": "integer",
              "minimum": 0,
              "maximum": 250
            },
            "unchanged": {
              "type": "integer",
              "minimum": 0,
              "maximum": 250
            },
            "excluded": {
              "type": "integer",
              "minimum": 0,
              "maximum": 250
            },
            "needsReview": {
              "type": "integer",
              "minimum": 0,
              "maximum": 250
            },
            "identityConflict": {
              "type": "integer",
              "minimum": 0,
              "maximum": 250
            }
          }
        },
        "eligibleForApply": {
          "type": "boolean"
        }
      }
    }
  }
} as const;
