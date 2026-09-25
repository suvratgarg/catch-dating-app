/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerContactMergeReceiptDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_contact_merge_receipts.schema.json",
  "title": "OrganizerContactMergeReceiptDocument",
  "description": "Immutable evidence for a manager-confirmed organizer contact merge or its reversal.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerContactMergeReceipts",
  "x-firestore-path": "organizerContactMergeReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "organizer contact merge and unmerge callables",
  "required": [
    "organizerId",
    "operation",
    "survivorContactId",
    "sourceContactId",
    "evidence",
    "conflicts",
    "actorUid",
    "survivorRevision",
    "sourceRevision",
    "movedEdgeIds",
    "movedIdentityEvidenceIds",
    "movedClaimIds",
    "movedOriginIds",
    "movedEdgeCount",
    "movedIdentityEvidenceCount",
    "movedClaimCount",
    "movedOriginCount",
    "idempotencyKey",
    "reversalOfReceiptId",
    "createdAt"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "operation": {
      "type": "string",
      "enum": [
        "merge",
        "unmerge"
      ]
    },
    "survivorContactId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "sourceContactId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "evidence": {
      "type": "array",
      "maxItems": 20,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "enum": [
          "sameVerifiedUid",
          "sameVerifiedPhone",
          "sameImportedPhone",
          "sameEmail",
          "managerConfirmed"
        ]
      }
    },
    "conflicts": {
      "type": "array",
      "maxItems": 20,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "maxLength": 120
      }
    },
    "actorUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "survivorRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "sourceRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "movedEdgeIds": {
      "type": "array",
      "maxItems": 400,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      }
    },
    "movedIdentityEvidenceIds": {
      "type": "array",
      "maxItems": 400,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      }
    },
    "movedClaimIds": {
      "type": "array",
      "maxItems": 400,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      }
    },
    "movedOriginIds": {
      "type": "array",
      "maxItems": 400,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      }
    },
    "movedEdgeCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 400
    },
    "movedIdentityEvidenceCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 400
    },
    "movedClaimCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 400
    },
    "movedOriginCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 400
    },
    "idempotencyKey": {
      "type": "string",
      "minLength": 8,
      "maxLength": 120
    },
    "reversalOfReceiptId": {
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
    "seatMoves": {
      "type": "array",
      "maxItems": 200,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "eventId",
          "aliasId",
          "kind",
          "valueHash",
          "before",
          "after"
        ],
        "properties": {
          "eventId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "aliasId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "kind": {
            "enum": [
              "contact",
              "contactOrigin"
            ]
          },
          "valueHash": {
            "type": "string",
            "pattern": "^[0-9a-f]{64}$"
          },
          "before": {
            "anyOf": [
              {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "canonicalKey",
                  "identityRevision",
                  "migrationRevision",
                  "state"
                ],
                "properties": {
                  "canonicalKey": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "identityRevision": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 9007199254740991
                  },
                  "migrationRevision": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 9007199254740991
                  },
                  "state": {
                    "const": "ready"
                  }
                }
              },
              {
                "type": "null"
              }
            ]
          },
          "after": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "canonicalKey",
              "identityRevision",
              "migrationRevision",
              "state"
            ],
            "properties": {
              "canonicalKey": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180
              },
              "identityRevision": {
                "type": "integer",
                "minimum": 1,
                "maximum": 9007199254740991
              },
              "migrationRevision": {
                "type": "integer",
                "minimum": 1,
                "maximum": 9007199254740991
              },
              "state": {
                "const": "ready"
              }
            }
          }
        }
      }
    },
    "seatEventGuards": {
      "type": "array",
      "maxItems": 100,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "eventId",
          "ledgerRevision",
          "migrationRevision",
          "sourceReservation",
          "survivorReservation",
          "aliasIdsBefore",
          "sourceAlias",
          "survivorAlias"
        ],
        "properties": {
          "eventId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "ledgerRevision": {
            "type": "integer",
            "minimum": 1,
            "maximum": 9007199254740991
          },
          "migrationRevision": {
            "type": "integer",
            "minimum": 1,
            "maximum": 9007199254740991
          },
          "sourceReservation": {
            "anyOf": [
              {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "canonicalKey",
                  "identityRevision",
                  "revision",
                  "active"
                ],
                "properties": {
                  "canonicalKey": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "identityRevision": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 9007199254740991
                  },
                  "revision": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 9007199254740991
                  },
                  "active": {
                    "type": "boolean"
                  }
                }
              },
              {
                "type": "null"
              }
            ]
          },
          "survivorReservation": {
            "anyOf": [
              {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "canonicalKey",
                  "identityRevision",
                  "revision",
                  "active"
                ],
                "properties": {
                  "canonicalKey": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "identityRevision": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 9007199254740991
                  },
                  "revision": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 9007199254740991
                  },
                  "active": {
                    "type": "boolean"
                  }
                }
              },
              {
                "type": "null"
              }
            ]
          },
          "aliasIdsBefore": {
            "type": "array",
            "maxItems": 200,
            "uniqueItems": true,
            "items": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            }
          },
          "sourceAlias": {
            "anyOf": [
              {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "canonicalKey",
                  "identityRevision",
                  "migrationRevision",
                  "state"
                ],
                "properties": {
                  "canonicalKey": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "identityRevision": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 9007199254740991
                  },
                  "migrationRevision": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 9007199254740991
                  },
                  "state": {
                    "const": "ready"
                  }
                }
              },
              {
                "type": "null"
              }
            ]
          },
          "survivorAlias": {
            "anyOf": [
              {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "canonicalKey",
                  "identityRevision",
                  "migrationRevision",
                  "state"
                ],
                "properties": {
                  "canonicalKey": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  },
                  "identityRevision": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 9007199254740991
                  },
                  "migrationRevision": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 9007199254740991
                  },
                  "state": {
                    "const": "ready"
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
    "seatAdmissionGuards": {
      "type": "array",
      "maxItems": 200,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "eventId",
          "responseId",
          "ownershipId",
          "receiptId"
        ],
        "properties": {
          "eventId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "responseId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "ownershipId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "receiptId": {
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
    "survivorOriginIdsBefore": {
      "type": "array",
      "maxItems": 400,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      }
    },
    "sourceOriginAliasIdsBefore": {
      "type": "array",
      "maxItems": 200,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      }
    }
  }
} as const;
