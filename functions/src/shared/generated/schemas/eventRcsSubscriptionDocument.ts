/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventRcsSubscriptionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_assistance_rcs_subscriptions.schema.json",
  "title": "EventRcsSubscriptionDocument",
  "description": "Authenticated RCS subscription observations scoped to a provider agent and recipient endpoint, across events. Stop observations restrict event-service messages; subscribe requests never grant event consent. No automatic retention deletion.",
  "x-firestore-collection": "eventAssistanceRcsSubscriptions",
  "x-firestore-path": "eventAssistanceRcsSubscriptions/{subscriptionId}",
  "x-document-id-field": "subscriptionId",
  "x-owner": "event-assistance authenticated RCS ingress",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schemaVersion",
    "subscriptionId",
    "routeId",
    "agentId",
    "endpointHash",
    "revision",
    "lastStop",
    "lastSubscribeRequest",
    "updatedAt"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "subscriptionId": {
      "type": "string",
      "pattern": "^rcs-subscription:[a-f0-9]{64}$"
    },
    "routeId": {
      "type": "string",
      "const": "catchEventRcs"
    },
    "agentId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 512,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._@-]*$"
    },
    "endpointHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "revision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "lastStop": {
      "anyOf": [
        {
          "type": "null"
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "callbackId",
            "observedAt"
          ],
          "properties": {
            "callbackId": {
              "type": "string",
              "pattern": "^rcs-event:[a-f0-9]{64}$"
            },
            "observedAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            }
          }
        }
      ]
    },
    "lastSubscribeRequest": {
      "anyOf": [
        {
          "type": "null"
        },
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "callbackId",
            "observedAt"
          ],
          "properties": {
            "callbackId": {
              "type": "string",
              "pattern": "^rcs-event:[a-f0-9]{64}$"
            },
            "observedAt": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            }
          }
        }
      ]
    },
    "updatedAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    }
  },
  "anyOf": [
    {
      "properties": {
        "lastStop": {
          "type": "object"
        }
      }
    },
    {
      "properties": {
        "lastSubscribeRequest": {
          "type": "object"
        }
      }
    }
  ],
  "definitions": {
    "Observation": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "callbackId",
        "observedAt"
      ],
      "properties": {
        "callbackId": {
          "type": "string",
          "pattern": "^rcs-event:[a-f0-9]{64}$"
        },
        "observedAt": {
          "type": "integer",
          "minimum": 0,
          "maximum": 9007199254740991
        }
      }
    }
  }
} as const;
