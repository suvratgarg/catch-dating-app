/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventWhatsappPolicyDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_assistance_whatsapp_policies.schema.json",
  "title": "EventWhatsappPolicyDocument",
  "description": "Reviewed event-service template and spend policy for one existing organizer-owned WhatsApp sender. This policy alone grants no guest consent or send authority.",
  "x-firestore-collection": "eventAssistanceWhatsappPolicies",
  "x-firestore-path": "eventAssistanceWhatsappPolicies/{senderId}",
  "x-document-id-field": "senderId",
  "x-owner": "trusted event-assistance dispatch",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "senderId",
    "organizerId",
    "revision",
    "status",
    "providerAccountId",
    "providerPhoneNumberId",
    "activation",
    "maxTemplateAgeSeconds",
    "quote",
    "templates"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "senderId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "organizerId": {
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
    "maxTemplateAgeSeconds": {
      "type": "integer",
      "minimum": 60,
      "maximum": 86400
    },
    "status": {
      "enum": [
        "inactive",
        "ready",
        "paused"
      ],
      "type": "string"
    },
    "providerAccountId": {
      "type": "string",
      "pattern": "^[0-9]{5,40}$"
    },
    "providerPhoneNumberId": {
      "type": "string",
      "pattern": "^[0-9]{5,40}$"
    },
    "activation": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "approvalId",
        "approvedAt",
        "validUntil"
      ],
      "properties": {
        "approvalId": {
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
    "quote": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "revision",
        "currency",
        "recipientPrefixes",
        "maxMicrosPerMessage",
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
          "pattern": "^[A-Z]{3}$"
        },
        "recipientPrefixes": {
          "type": "array",
          "minItems": 1,
          "maxItems": 250,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "pattern": "^\\+[1-9][0-9]{0,3}$"
          }
        },
        "maxMicrosPerMessage": {
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
          "templateDocumentId",
          "purpose",
          "templateHash",
          "variables",
          "quickReplies"
        ],
        "properties": {
          "templateDocumentId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160,
            "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
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
          "templateHash": {
            "type": "string",
            "pattern": "^[a-f0-9]{64}$"
          },
          "variables": {
            "type": "array",
            "minItems": 1,
            "maxItems": 20,
            "items": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "providerName",
                "source",
                "maxCharacters"
              ],
              "properties": {
                "providerName": {
                  "type": "string",
                  "pattern": "^[A-Za-z][A-Za-z0-9_]{0,63}$"
                },
                "source": {
                  "type": "string",
                  "enum": [
                    "eventTitle",
                    "instruction",
                    "responseUrl",
                    "responseUrlSuffix"
                  ]
                },
                "maxCharacters": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 4096
                }
              }
            }
          },
          "quickReplies": {
            "type": "array",
            "maxItems": 10,
            "items": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "buttonIndex",
                "choiceId",
                "label",
                "action"
              ],
              "properties": {
                "buttonIndex": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 9
                },
                "choiceId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 160,
                  "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
                },
                "label": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 80
                },
                "action": {
                  "type": "string",
                  "enum": [
                    "onMyWay",
                    "notComing",
                    "joinLater",
                    "helpLogistics",
                    "helpAccessibility",
                    "helpSafety",
                    "helpOther",
                    "acknowledge"
                  ]
                }
              }
            }
          }
        }
      }
    }
  },
  "definitions": {
    "id": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "time": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    }
  }
} as const;
