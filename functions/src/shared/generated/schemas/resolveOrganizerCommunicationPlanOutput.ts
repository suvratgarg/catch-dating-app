/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const resolveOrganizerCommunicationPlanCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/resolve_organizer_communication_plan_response.schema.json",
  "title": "ResolveOrganizerCommunicationPlanCallableResponse",
  "description": "Server-derived communication routes and blockers for a named organizer intent at one capability snapshot.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "intent",
    "capabilityVersion",
    "resolvedAtMillis",
    "recipients"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "intent": {
      "type": "string",
      "enum": [
        "individualConversation"
      ]
    },
    "capabilityVersion": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000000
    },
    "resolvedAtMillis": {
      "type": "integer",
      "minimum": 0
    },
    "recipients": {
      "type": "array",
      "minItems": 1,
      "maxItems": 1,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "contactId",
          "displayName",
          "outcome",
          "recommendedRouteId",
          "routes"
        ],
        "properties": {
          "contactId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "displayName": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "outcome": {
            "type": "string",
            "enum": [
              "inCatch",
              "automatic",
              "byHand",
              "unavailable"
            ]
          },
          "recommendedRouteId": {
            "anyOf": [
              {
                "type": "string",
                "enum": [
                  "personalWhatsappHandoff",
                  "organizerWhatsappCampaign",
                  "catchWhatsapp",
                  "catchChat",
                  "catchEventAnnouncement",
                  "organizerFollowerUpdate"
                ]
              },
              {
                "type": "null"
              }
            ]
          },
          "routes": {
            "type": "array",
            "minItems": 2,
            "maxItems": 2,
            "items": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "routeId",
                "executionMode",
                "availability",
                "blocker"
              ],
              "properties": {
                "routeId": {
                  "type": "string",
                  "enum": [
                    "personalWhatsappHandoff",
                    "organizerWhatsappCampaign",
                    "catchWhatsapp",
                    "catchChat",
                    "catchEventAnnouncement",
                    "organizerFollowerUpdate"
                  ]
                },
                "executionMode": {
                  "type": "string",
                  "enum": [
                    "managedDelivery",
                    "externalHandoff"
                  ]
                },
                "availability": {
                  "type": "string",
                  "enum": [
                    "available",
                    "unavailable"
                  ]
                },
                "blocker": {
                  "anyOf": [
                    {
                      "type": "string",
                      "enum": [
                        "catchAccountRequired",
                        "identityAmbiguous",
                        "missingPhone",
                        "organizerSuppressed",
                        "contactOptedOut",
                        "permissionRequired",
                        "senderUnavailable",
                        "intentUnsupported"
                      ]
                    },
                    {
                      "type": "null"
                    }
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
    "routeId": {
      "type": "string",
      "enum": [
        "personalWhatsappHandoff",
        "organizerWhatsappCampaign",
        "catchWhatsapp",
        "catchChat",
        "catchEventAnnouncement",
        "organizerFollowerUpdate"
      ]
    },
    "routeBlocker": {
      "type": "string",
      "enum": [
        "catchAccountRequired",
        "identityAmbiguous",
        "missingPhone",
        "organizerSuppressed",
        "contactOptedOut",
        "permissionRequired",
        "senderUnavailable",
        "intentUnsupported"
      ]
    },
    "routeOption": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "routeId",
        "executionMode",
        "availability",
        "blocker"
      ],
      "properties": {
        "routeId": {
          "type": "string",
          "enum": [
            "personalWhatsappHandoff",
            "organizerWhatsappCampaign",
            "catchWhatsapp",
            "catchChat",
            "catchEventAnnouncement",
            "organizerFollowerUpdate"
          ]
        },
        "executionMode": {
          "type": "string",
          "enum": [
            "managedDelivery",
            "externalHandoff"
          ]
        },
        "availability": {
          "type": "string",
          "enum": [
            "available",
            "unavailable"
          ]
        },
        "blocker": {
          "anyOf": [
            {
              "type": "string",
              "enum": [
                "catchAccountRequired",
                "identityAmbiguous",
                "missingPhone",
                "organizerSuppressed",
                "contactOptedOut",
                "permissionRequired",
                "senderUnavailable",
                "intentUnsupported"
              ]
            },
            {
              "type": "null"
            }
          ]
        }
      }
    },
    "recipientPlan": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "contactId",
        "displayName",
        "outcome",
        "recommendedRouteId",
        "routes"
      ],
      "properties": {
        "contactId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "displayName": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "outcome": {
          "type": "string",
          "enum": [
            "inCatch",
            "automatic",
            "byHand",
            "unavailable"
          ]
        },
        "recommendedRouteId": {
          "anyOf": [
            {
              "type": "string",
              "enum": [
                "personalWhatsappHandoff",
                "organizerWhatsappCampaign",
                "catchWhatsapp",
                "catchChat",
                "catchEventAnnouncement",
                "organizerFollowerUpdate"
              ]
            },
            {
              "type": "null"
            }
          ]
        },
        "routes": {
          "type": "array",
          "minItems": 2,
          "maxItems": 2,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "routeId",
              "executionMode",
              "availability",
              "blocker"
            ],
            "properties": {
              "routeId": {
                "type": "string",
                "enum": [
                  "personalWhatsappHandoff",
                  "organizerWhatsappCampaign",
                  "catchWhatsapp",
                  "catchChat",
                  "catchEventAnnouncement",
                  "organizerFollowerUpdate"
                ]
              },
              "executionMode": {
                "type": "string",
                "enum": [
                  "managedDelivery",
                  "externalHandoff"
                ]
              },
              "availability": {
                "type": "string",
                "enum": [
                  "available",
                  "unavailable"
                ]
              },
              "blocker": {
                "anyOf": [
                  {
                    "type": "string",
                    "enum": [
                      "catchAccountRequired",
                      "identityAmbiguous",
                      "missingPhone",
                      "organizerSuppressed",
                      "contactOptedOut",
                      "permissionRequired",
                      "senderUnavailable",
                      "intentUnsupported"
                    ]
                  },
                  {
                    "type": "null"
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
} as const;
