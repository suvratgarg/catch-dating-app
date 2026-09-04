/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminSetAdminUserRolesCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/admin_set_admin_user_roles_response.schema.json",
  "title": "Admin Set Admin User Roles Callable Response",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "user",
    "beforeRoles",
    "afterRoles"
  ],
  "properties": {
    "user": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "targetUid",
        "email",
        "displayName",
        "disabled",
        "roles",
        "assignmentPath"
      ],
      "properties": {
        "targetUid": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        "email": {
          "anyOf": [
            {
              "type": "string"
            },
            {
              "type": "null"
            }
          ]
        },
        "displayName": {
          "anyOf": [
            {
              "type": "string"
            },
            {
              "type": "null"
            }
          ]
        },
        "disabled": {
          "type": "boolean"
        },
        "roles": {
          "type": "array",
          "uniqueItems": true,
          "items": {
            "type": "string",
            "enum": [
              "admin",
              "adminOwner",
              "safetyReviewer",
              "support",
              "finance",
              "analyticsViewer"
            ]
          }
        },
        "assignmentPath": {
          "type": "string",
          "pattern": "^adminRoleAssignments/[^/]+$"
        }
      }
    },
    "beforeRoles": {
      "type": "array",
      "uniqueItems": true,
      "items": {
        "type": "string",
        "enum": [
          "admin",
          "adminOwner",
          "safetyReviewer",
          "support",
          "finance",
          "analyticsViewer"
        ]
      }
    },
    "afterRoles": {
      "type": "array",
      "uniqueItems": true,
      "items": {
        "type": "string",
        "enum": [
          "admin",
          "adminOwner",
          "safetyReviewer",
          "support",
          "finance",
          "analyticsViewer"
        ]
      }
    }
  },
  "definitions": {
    "adminRole": {
      "type": "string",
      "enum": [
        "admin",
        "adminOwner",
        "safetyReviewer",
        "support",
        "finance",
        "analyticsViewer"
      ]
    },
    "roles": {
      "type": "array",
      "uniqueItems": true,
      "items": {
        "type": "string",
        "enum": [
          "admin",
          "adminOwner",
          "safetyReviewer",
          "support",
          "finance",
          "analyticsViewer"
        ]
      }
    },
    "nullableText": {
      "anyOf": [
        {
          "type": "string"
        },
        {
          "type": "null"
        }
      ]
    },
    "user": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "targetUid",
        "email",
        "displayName",
        "disabled",
        "roles",
        "assignmentPath"
      ],
      "properties": {
        "targetUid": {
          "type": "string",
          "pattern": "^[A-Za-z0-9_-]{3,128}$"
        },
        "email": {
          "anyOf": [
            {
              "type": "string"
            },
            {
              "type": "null"
            }
          ]
        },
        "displayName": {
          "anyOf": [
            {
              "type": "string"
            },
            {
              "type": "null"
            }
          ]
        },
        "disabled": {
          "type": "boolean"
        },
        "roles": {
          "type": "array",
          "uniqueItems": true,
          "items": {
            "type": "string",
            "enum": [
              "admin",
              "adminOwner",
              "safetyReviewer",
              "support",
              "finance",
              "analyticsViewer"
            ]
          }
        },
        "assignmentPath": {
          "type": "string",
          "pattern": "^adminRoleAssignments/[^/]+$"
        }
      }
    }
  }
} as const;
