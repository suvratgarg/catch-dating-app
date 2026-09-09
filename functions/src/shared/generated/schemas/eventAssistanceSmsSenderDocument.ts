/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventAssistanceSmsSenderDocumentSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "senderId",
    "revision",
    "provider",
    "senderIdentity",
    "country",
    "status",
    "mask",
    "principalEntityId",
    "credentialVersion",
    "activation",
    "maxSegments",
    "quote",
    "templates"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1,
      "type": "integer"
    },
    "senderId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "provider": {
      "type": "string",
      "const": "gupshup"
    },
    "senderIdentity": {
      "type": "string",
      "const": "catchPlatform"
    },
    "country": {
      "type": "string",
      "const": "IN"
    },
    "status": {
      "type": "string",
      "enum": [
        "inactive",
        "ready",
        "paused"
      ]
    },
    "mask": {
      "type": "string",
      "pattern": "^[A-Za-z]{6}$"
    },
    "principalEntityId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 30,
      "pattern": "^[0-9]+$"
    },
    "credentialVersion": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240,
      "pattern": "^projects/[A-Za-z0-9-]+/secrets/[A-Za-z0-9_-]+/versions/[1-9][0-9]*$"
    },
    "activation": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "useCaseApprovalId",
        "senderApprovalId",
        "approvedAt",
        "validUntil"
      ],
      "properties": {
        "useCaseApprovalId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "senderApprovalId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
        },
        "approvedAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        },
        "validUntil": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        }
      }
    },
    "maxSegments": {
      "type": "integer",
      "minimum": 1,
      "maximum": 6
    },
    "quote": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "revision",
        "currency",
        "maxMicrosPerSegment",
        "validUntil"
      ],
      "properties": {
        "revision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "currency": {
          "type": "string",
          "const": "INR"
        },
        "maxMicrosPerSegment": {
          "type": "integer",
          "minimum": 1,
          "maximum": 1000000000
        },
        "validUntil": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        }
      }
    },
    "templates": {
      "type": "array",
      "minItems": 1,
      "maxItems": 32,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "templateId",
          "revision",
          "purpose",
          "dltTemplateId",
          "status",
          "parts"
        ],
        "properties": {
          "templateId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
          },
          "revision": {
            "type": "integer",
            "minimum": 1,
            "maximum": 9007199254740991
          },
          "purpose": {
            "type": "string",
            "enum": [
              "joiningUpdate",
              "joiningInstructions",
              "planChanged",
              "guestRequirement",
              "assignmentChanged",
              "participationCheck",
              "eventCancelled",
              "eventFinished",
              "followUp"
            ]
          },
          "dltTemplateId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 30,
            "pattern": "^[0-9]+$"
          },
          "status": {
            "type": "string",
            "enum": [
              "pending",
              "approved",
              "paused"
            ]
          },
          "parts": {
            "type": "array",
            "minItems": 1,
            "maxItems": 16,
            "items": {
              "oneOf": [
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "text"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "literal"
                    },
                    "text": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 1200
                    }
                  }
                },
                {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "kind",
                    "name",
                    "maxCharacters"
                  ],
                  "properties": {
                    "kind": {
                      "type": "string",
                      "const": "variable"
                    },
                    "name": {
                      "type": "string",
                      "enum": [
                        "eventTitle",
                        "instruction",
                        "responseUrl"
                      ]
                    },
                    "maxCharacters": {
                      "type": "integer",
                      "minimum": 1,
                      "maximum": 1200
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
  "title": "EventAssistanceSmsSenderDocument",
  "x-firestore-collection": "eventAssistanceSmsSenders",
  "x-firestore-path": "eventAssistanceSmsSenders/{senderId}",
  "x-document-id-field": "senderId",
  "x-owner": "trusted event-assistance SMS worker"
} as const;
