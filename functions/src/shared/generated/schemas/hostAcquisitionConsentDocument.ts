/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const hostAcquisitionConsentDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/host_acquisition_consents.schema.json",
  "title": "HostAcquisitionConsentDocument",
  "description": "Private anonymous device permission, keyed by a domain-separated capability hash. Revocation tombstones cannot be reactivated; fresh permission requires a new capability.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "hostAcquisitionConsents",
  "x-firestore-path": "hostAcquisitionConsents/{consentId}",
  "x-document-id-field": "consentId",
  "x-owner": "hostAcquisitionConsent and acquisition expiry worker",
  "required": [
    "schemaVersion",
    "classification",
    "consentId",
    "status",
    "authority",
    "createdAt",
    "updatedAt",
    "expiresAt"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "consentId": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "status": {
      "enum": [
        "active",
        "revoked"
      ]
    },
    "authority": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "version",
            "purpose",
            "analytics",
            "advertising",
            "chosenAt",
            "acceptedAt",
            "expiresAt",
            "revokedAt"
          ],
          "properties": {
            "version": {
              "const": 1
            },
            "purpose": {
              "const": "host_acquisition_measurement"
            },
            "analytics": {
              "const": true
            },
            "advertising": {
              "type": "boolean"
            },
            "chosenAt": {
              "type": "integer",
              "minimum": 1
            },
            "acceptedAt": {
              "type": "integer",
              "minimum": 1
            },
            "expiresAt": {
              "type": "integer",
              "minimum": 1
            },
            "revokedAt": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 1
            }
          }
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
    },
    "expiresAt": {
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
    "attributionCleanupPending": {
      "description": "Withdrawal tombstones only. True until the expiry worker drains every optional attribution snapshot bound to this consent; a revoked capability can never create another.",
      "type": "boolean"
    }
  },
  "allOf": [
    {
      "if": {
        "properties": {
          "status": {
            "const": "revoked"
          }
        }
      },
      "then": {
        "required": [
          "attributionCleanupPending"
        ]
      }
    },
    {
      "if": {
        "properties": {
          "status": {
            "const": "active"
          }
        }
      },
      "then": {
        "properties": {
          "authority": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "version",
              "purpose",
              "analytics",
              "advertising",
              "chosenAt",
              "acceptedAt",
              "expiresAt",
              "revokedAt"
            ],
            "properties": {
              "version": {
                "const": 1
              },
              "purpose": {
                "const": "host_acquisition_measurement"
              },
              "analytics": {
                "const": true
              },
              "advertising": {
                "type": "boolean"
              },
              "chosenAt": {
                "type": "integer",
                "minimum": 1
              },
              "acceptedAt": {
                "type": "integer",
                "minimum": 1
              },
              "expiresAt": {
                "type": "integer",
                "minimum": 1
              },
              "revokedAt": {
                "type": [
                  "integer",
                  "null"
                ],
                "minimum": 1
              }
            }
          }
        }
      }
    }
  ]
} as const;
