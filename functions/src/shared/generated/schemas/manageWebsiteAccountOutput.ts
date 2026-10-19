/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const manageWebsiteAccountCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/manage_website_account_response.schema.json",
  "title": "ManageWebsiteAccountCallableResponse",
  "description": "Private account identity and optional own organizer-follow state.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "uid",
    "accountReady",
    "displayName",
    "phoneNumber",
    "dateOfBirth",
    "profileRevision",
    "following",
    "eventAge"
  ],
  "properties": {
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "accountReady": {
      "type": "boolean"
    },
    "displayName": {
      "type": "string",
      "maxLength": 120
    },
    "phoneNumber": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 32
    },
    "dateOfBirth": {
      "anyOf": [
        {
          "type": "string",
          "format": "date"
        },
        {
          "type": "null"
        }
      ]
    },
    "profileRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "following": {
      "type": [
        "boolean",
        "null"
      ],
      "description": "Null unless an organizer was requested. Reflects only the authenticated UID relationship."
    },
    "eventAge": {
      "anyOf": [
        {
          "type": "null"
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "minimum",
            "maximum",
            "eligible",
            "needsDateOfBirth"
          ],
          "properties": {
            "minimum": {
              "type": "integer",
              "minimum": 0,
              "maximum": 120
            },
            "maximum": {
              "type": "integer",
              "minimum": 0,
              "maximum": 120
            },
            "eligible": {
              "type": "boolean"
            },
            "needsDateOfBirth": {
              "type": "boolean"
            }
          }
        }
      ]
    }
  }
} as const;
