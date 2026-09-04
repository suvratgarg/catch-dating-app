/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const listOrganizerContactMergeCandidatesCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/list_organizer_contact_merge_candidates_response.schema.json",
  "title": "ListOrganizerContactMergeCandidatesCallableResponse",
  "description": "Manager-only, evidence-bearing duplicate candidates. No candidate is produced from a name match alone.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "candidates",
    "dismissedCandidates",
    "nextCursor",
    "truncated"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "candidates": {
      "type": "array",
      "maxItems": 50,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "candidateId",
          "contacts",
          "matchKinds",
          "confidence",
          "sourceKinds",
          "sharedEventIds",
          "sharedEventCount",
          "updatedAtMillis",
          "decisionState",
          "decisionRevision",
          "canReopen"
        ],
        "properties": {
          "candidateId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "contacts": {
            "type": "array",
            "minItems": 2,
            "maxItems": 2,
            "items": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "contactId",
                "displayName",
                "phoneE164",
                "email",
                "linkedAccount",
                "primarySource",
                "revision"
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
                "phoneE164": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "pattern": "^\\+[1-9][0-9]{7,14}$"
                },
                "email": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "format": "email",
                  "maxLength": 320
                },
                "linkedAccount": {
                  "type": "boolean"
                },
                "primarySource": {
                  "type": "string",
                  "enum": [
                    "catchBooking",
                    "hostImport",
                    "hostManual",
                    "webOtp",
                    "providerSync",
                    "hostForm"
                  ]
                },
                "revision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 9007199254740991
                }
              }
            }
          },
          "matchKinds": {
            "type": "array",
            "minItems": 1,
            "maxItems": 4,
            "uniqueItems": true,
            "items": {
              "type": "string",
              "enum": [
                "sameVerifiedUid",
                "sameVerifiedPhone",
                "sameImportedPhone",
                "sameEmail"
              ]
            }
          },
          "confidence": {
            "type": "string",
            "enum": [
              "verified",
              "proposed"
            ]
          },
          "sourceKinds": {
            "type": "array",
            "minItems": 1,
            "maxItems": 6,
            "uniqueItems": true,
            "items": {
              "type": "string",
              "enum": [
                "catchBooking",
                "hostImport",
                "hostManual",
                "webOtp",
                "providerSync",
                "hostForm"
              ]
            }
          },
          "sharedEventIds": {
            "type": "array",
            "maxItems": 20,
            "uniqueItems": true,
            "items": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            }
          },
          "sharedEventCount": {
            "type": "integer",
            "minimum": 0,
            "maximum": 1000000
          },
          "updatedAtMillis": {
            "type": "integer",
            "minimum": 0
          },
          "decisionState": {
            "type": "string",
            "enum": [
              "none",
              "differentPeople",
              "reopened"
            ]
          },
          "decisionRevision": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 1,
            "maximum": 9007199254740991
          },
          "canReopen": {
            "type": "boolean"
          }
        }
      }
    },
    "dismissedCandidates": {
      "type": "array",
      "maxItems": 50,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "candidateId",
          "contacts",
          "matchKinds",
          "confidence",
          "sourceKinds",
          "sharedEventIds",
          "sharedEventCount",
          "updatedAtMillis",
          "decisionState",
          "decisionRevision",
          "canReopen"
        ],
        "properties": {
          "candidateId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "contacts": {
            "type": "array",
            "minItems": 2,
            "maxItems": 2,
            "items": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "contactId",
                "displayName",
                "phoneE164",
                "email",
                "linkedAccount",
                "primarySource",
                "revision"
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
                "phoneE164": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "pattern": "^\\+[1-9][0-9]{7,14}$"
                },
                "email": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "format": "email",
                  "maxLength": 320
                },
                "linkedAccount": {
                  "type": "boolean"
                },
                "primarySource": {
                  "type": "string",
                  "enum": [
                    "catchBooking",
                    "hostImport",
                    "hostManual",
                    "webOtp",
                    "providerSync",
                    "hostForm"
                  ]
                },
                "revision": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 9007199254740991
                }
              }
            }
          },
          "matchKinds": {
            "type": "array",
            "minItems": 1,
            "maxItems": 4,
            "uniqueItems": true,
            "items": {
              "type": "string",
              "enum": [
                "sameVerifiedUid",
                "sameVerifiedPhone",
                "sameImportedPhone",
                "sameEmail"
              ]
            }
          },
          "confidence": {
            "type": "string",
            "enum": [
              "verified",
              "proposed"
            ]
          },
          "sourceKinds": {
            "type": "array",
            "minItems": 1,
            "maxItems": 6,
            "uniqueItems": true,
            "items": {
              "type": "string",
              "enum": [
                "catchBooking",
                "hostImport",
                "hostManual",
                "webOtp",
                "providerSync",
                "hostForm"
              ]
            }
          },
          "sharedEventIds": {
            "type": "array",
            "maxItems": 20,
            "uniqueItems": true,
            "items": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            }
          },
          "sharedEventCount": {
            "type": "integer",
            "minimum": 0,
            "maximum": 1000000
          },
          "updatedAtMillis": {
            "type": "integer",
            "minimum": 0
          },
          "decisionState": {
            "type": "string",
            "enum": [
              "none",
              "differentPeople",
              "reopened"
            ]
          },
          "decisionRevision": {
            "type": [
              "integer",
              "null"
            ],
            "minimum": 1,
            "maximum": 9007199254740991
          },
          "canReopen": {
            "type": "boolean"
          }
        }
      }
    },
    "nextCursor": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 512
    },
    "truncated": {
      "type": "boolean"
    }
  },
  "definitions": {
    "candidate": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "candidateId",
        "contacts",
        "matchKinds",
        "confidence",
        "sourceKinds",
        "sharedEventIds",
        "sharedEventCount",
        "updatedAtMillis",
        "decisionState",
        "decisionRevision",
        "canReopen"
      ],
      "properties": {
        "candidateId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "contacts": {
          "type": "array",
          "minItems": 2,
          "maxItems": 2,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "contactId",
              "displayName",
              "phoneE164",
              "email",
              "linkedAccount",
              "primarySource",
              "revision"
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
              "phoneE164": {
                "type": [
                  "string",
                  "null"
                ],
                "pattern": "^\\+[1-9][0-9]{7,14}$"
              },
              "email": {
                "type": [
                  "string",
                  "null"
                ],
                "format": "email",
                "maxLength": 320
              },
              "linkedAccount": {
                "type": "boolean"
              },
              "primarySource": {
                "type": "string",
                "enum": [
                  "catchBooking",
                  "hostImport",
                  "hostManual",
                  "webOtp",
                  "providerSync",
                  "hostForm"
                ]
              },
              "revision": {
                "type": "integer",
                "minimum": 1,
                "maximum": 9007199254740991
              }
            }
          }
        },
        "matchKinds": {
          "type": "array",
          "minItems": 1,
          "maxItems": 4,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "enum": [
              "sameVerifiedUid",
              "sameVerifiedPhone",
              "sameImportedPhone",
              "sameEmail"
            ]
          }
        },
        "confidence": {
          "type": "string",
          "enum": [
            "verified",
            "proposed"
          ]
        },
        "sourceKinds": {
          "type": "array",
          "minItems": 1,
          "maxItems": 6,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "enum": [
              "catchBooking",
              "hostImport",
              "hostManual",
              "webOtp",
              "providerSync",
              "hostForm"
            ]
          }
        },
        "sharedEventIds": {
          "type": "array",
          "maxItems": 20,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          }
        },
        "sharedEventCount": {
          "type": "integer",
          "minimum": 0,
          "maximum": 1000000
        },
        "updatedAtMillis": {
          "type": "integer",
          "minimum": 0
        },
        "decisionState": {
          "type": "string",
          "enum": [
            "none",
            "differentPeople",
            "reopened"
          ]
        },
        "decisionRevision": {
          "type": [
            "integer",
            "null"
          ],
          "minimum": 1,
          "maximum": 9007199254740991
        },
        "canReopen": {
          "type": "boolean"
        }
      }
    },
    "contact": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "contactId",
        "displayName",
        "phoneE164",
        "email",
        "linkedAccount",
        "primarySource",
        "revision"
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
        "phoneE164": {
          "type": [
            "string",
            "null"
          ],
          "pattern": "^\\+[1-9][0-9]{7,14}$"
        },
        "email": {
          "type": [
            "string",
            "null"
          ],
          "format": "email",
          "maxLength": 320
        },
        "linkedAccount": {
          "type": "boolean"
        },
        "primarySource": {
          "type": "string",
          "enum": [
            "catchBooking",
            "hostImport",
            "hostManual",
            "webOtp",
            "providerSync",
            "hostForm"
          ]
        },
        "revision": {
          "type": "integer",
          "minimum": 1,
          "maximum": 9007199254740991
        }
      }
    }
  }
} as const;
