/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventApprovalNotificationSettingsDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_approval_notification_settings.schema.json",
  "title": "EventApprovalNotificationSettingsDocument",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "enabled",
    "revision",
    "whatsapp",
    "sms",
    "email",
    "dailyPhoneLimit",
    "monthlyPhoneLimit",
    "dailyCostLimitMicros",
    "monthlyCostLimitMicros"
  ],
  "properties": {
    "enabled": {
      "type": "boolean"
    },
    "revision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "whatsapp": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "connectionId",
            "templateId",
            "maxCostMicros"
          ],
          "properties": {
            "connectionId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "templateId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "maxCostMicros": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            }
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "sms": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "accountId",
            "credentialVersion",
            "senderId",
            "mask",
            "principalEntityId",
            "dltTemplateId",
            "approvedText",
            "maxCostMicros"
          ],
          "properties": {
            "accountId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "credentialVersion": {
              "type": "string",
              "maxLength": 300,
              "pattern": "^projects/[A-Za-z0-9_-]+/secrets/[A-Za-z0-9_-]+/versions/[1-9][0-9]*$"
            },
            "senderId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "mask": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "principalEntityId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "dltTemplateId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "approvedText": {
              "const": "Your event application is approved. View your next steps: {eventUrl}",
              "type": "string"
            },
            "maxCostMicros": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            }
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "email": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "provider",
            "accountId",
            "credentialVersion",
            "from"
          ],
          "properties": {
            "provider": {
              "type": "string",
              "const": "resend"
            },
            "accountId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180,
              "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
            },
            "credentialVersion": {
              "type": "string",
              "maxLength": 300,
              "pattern": "^projects/[A-Za-z0-9_-]+/secrets/[A-Za-z0-9_-]+/versions/[1-9][0-9]*$"
            },
            "from": {
              "type": "string",
              "format": "email",
              "maxLength": 254
            }
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "dailyPhoneLimit": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "monthlyPhoneLimit": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "dailyCostLimitMicros": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "monthlyCostLimitMicros": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    }
  },
  "x-firestore-collection": "eventApprovalNotificationSettings",
  "x-firestore-path": "eventApprovalNotificationSettings/{id}",
  "x-owner": "trusted event approval notification services"
} as const;
