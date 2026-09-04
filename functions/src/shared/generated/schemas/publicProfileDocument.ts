/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const publicProfileDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/public_profiles.schema.json",
  "title": "PublicProfileDocument",
  "description": "Backend-owned public profile projection stored at publicProfiles/{uid}. The uid is the document id and is not stored in document data.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "publicProfiles",
  "x-firestore-path": "publicProfiles/{uid}",
  "x-document-id-field": "uid",
  "x-owner": "syncPublicProfile trigger",
  "x-source": "users/{uid}",
  "required": [
    "name",
    "age",
    "gender",
    "profilePrompts",
    "profilePhotos",
    "activityPreferences"
  ],
  "properties": {
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80,
      "x-catch-ownership": "trigger-owned"
    },
    "age": {
      "type": "integer",
      "minimum": 18,
      "maximum": 120,
      "x-catch-ownership": "trigger-owned"
    },
    "gender": {
      "type": "string",
      "enum": [
        "man",
        "woman",
        "nonBinary",
        "other"
      ],
      "x-catch-ownership": "trigger-owned"
    },
    "synthetic": {
      "type": "boolean",
      "description": "Internal demo seed marker used for cleanup and diagnostics."
    },
    "seedPrefix": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "description": "Internal demo seed prefix used for cleanup and diagnostics."
    },
    "scenario": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "description": "Internal demo seed scenario name used for cleanup and diagnostics."
    },
    "demoOps": {
      "type": "boolean",
      "description": "Internal demo-operations marker used for cleanup and diagnostics."
    },
    "demoOpsId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "description": "Internal demo-operations id used for cleanup and diagnostics."
    },
    "demoOpsCommand": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80,
      "description": "Internal demo-operations command name used for cleanup and diagnostics."
    },
    "profilePrompts": {
      "type": "array",
      "maxItems": 3,
      "items": {
        "title": "ProfilePromptAnswer",
        "description": "One structured written profile prompt answer stored on users and publicProfiles.",
        "type": "object",
        "additionalProperties": false,
        "required": [
          "promptId",
          "prompt",
          "answer"
        ],
        "properties": {
          "promptId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "prompt": {
            "type": "string",
            "minLength": 1,
            "maxLength": 140
          },
          "answer": {
            "type": "string",
            "maxLength": 300
          }
        },
        "x-catch-catalog": "../catalogs/profile_prompts.json"
      },
      "x-catch-ownership": "trigger-owned"
    },
    "profilePhotos": {
      "type": "array",
      "maxItems": 6,
      "items": {
        "title": "ProfilePhoto",
        "description": "Future canonical profile-photo object that groups display URLs, Firebase Storage object paths, prompt metadata, moderation state, order, and lifecycle timestamps.",
        "type": "object",
        "additionalProperties": false,
        "required": [
          "id",
          "url",
          "thumbnailUrl",
          "storagePath",
          "thumbnailStoragePath",
          "position",
          "createdAt",
          "updatedAt"
        ],
        "properties": {
          "id": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80,
            "pattern": "^[A-Za-z0-9_-]+$"
          },
          "url": {
            "type": "string",
            "format": "uri",
            "maxLength": 2048
          },
          "thumbnailUrl": {
            "type": "string",
            "format": "uri",
            "maxLength": 2048
          },
          "storagePath": {
            "type": "string",
            "minLength": 1,
            "maxLength": 512,
            "pattern": "^[^/\\u0000][^\\u0000]*$"
          },
          "thumbnailStoragePath": {
            "type": "string",
            "minLength": 1,
            "maxLength": 512,
            "pattern": "^[^/\\u0000][^\\u0000]*$"
          },
          "prompt": {
            "anyOf": [
              {
                "title": "PhotoPromptAnswer",
                "description": "One optional display prompt selected for a profile photo slot. The caption field is legacy-only and should no longer be written by clients.",
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "photoIndex",
                  "promptId",
                  "prompt"
                ],
                "properties": {
                  "photoIndex": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 5
                  },
                  "promptId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 80
                  },
                  "prompt": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 140
                  },
                  "caption": {
                    "type": "string",
                    "maxLength": 140,
                    "deprecated": true,
                    "description": "Legacy user-entered caption retained for compatibility with older documents."
                  }
                },
                "x-catch-catalog": "../catalogs/photo_prompts.json"
              },
              {
                "type": "null"
              }
            ]
          },
          "moderation": {
            "type": [
              "object",
              "null"
            ],
            "additionalProperties": false,
            "required": [
              "status"
            ],
            "properties": {
              "status": {
                "type": "string",
                "enum": [
                  "pending",
                  "approved",
                  "rejected"
                ]
              },
              "reason": {
                "type": [
                  "string",
                  "null"
                ],
                "maxLength": 240
              },
              "reviewedAt": {
                "anyOf": [
                  {
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
                  {
                    "type": "null"
                  }
                ]
              }
            }
          },
          "position": {
            "type": "integer",
            "minimum": 0,
            "maximum": 11
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
          }
        },
        "definitions": {
          "storageObjectPath": {
            "type": "string",
            "minLength": 1,
            "maxLength": 512,
            "pattern": "^[^/\\u0000][^\\u0000]*$"
          }
        },
        "x-storage-metadata": true,
        "x-future-field": "profilePhotos",
        "x-migration-contract": "../migrations/profile_photos_storage.json"
      },
      "x-catch-ownership": "trigger-owned"
    },
    "city": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 120,
          "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
        },
        {
          "type": "null"
        }
      ],
      "x-catch-ownership": "trigger-owned"
    },
    "height": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 120,
      "maximum": 220,
      "x-catch-ownership": "trigger-owned"
    },
    "occupation": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 120,
      "x-catch-ownership": "trigger-owned"
    },
    "company": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 120,
      "x-catch-ownership": "trigger-owned"
    },
    "education": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "highSchool",
        "someCollege",
        "bachelors",
        "masters",
        "phd",
        "tradeSchool",
        "other",
        null
      ],
      "x-catch-ownership": "trigger-owned"
    },
    "religion": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "hindu",
        "muslim",
        "christian",
        "sikh",
        "jain",
        "buddhist",
        "other",
        "nonReligious",
        null
      ],
      "x-catch-ownership": "trigger-owned"
    },
    "languages": {
      "type": "array",
      "maxItems": 20,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "enum": [
          "english",
          "hindi",
          "marathi",
          "tamil",
          "telugu",
          "kannada",
          "bengali",
          "gujarati",
          "punjabi",
          "malayalam",
          "odia",
          "other"
        ]
      },
      "x-catch-ownership": "trigger-owned"
    },
    "relationshipGoal": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "relationship",
        "casual",
        "marriage",
        "friendship",
        "unsure",
        null
      ],
      "x-catch-ownership": "trigger-owned"
    },
    "drinking": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "never",
        "socially",
        "often",
        null
      ],
      "x-catch-ownership": "trigger-owned"
    },
    "smoking": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "never",
        "occasionally",
        "often",
        null
      ],
      "x-catch-ownership": "trigger-owned"
    },
    "workout": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "never",
        "sometimes",
        "often",
        "everyday",
        null
      ],
      "x-catch-ownership": "trigger-owned"
    },
    "diet": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "omnivore",
        "vegetarian",
        "vegan",
        "jain",
        "other",
        null
      ],
      "x-catch-ownership": "trigger-owned"
    },
    "children": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "dontHave",
        "haveWantMore",
        "haveNoMore",
        "wantSomeday",
        "dontWant",
        null
      ],
      "x-catch-ownership": "trigger-owned"
    },
    "activityPreferences": {
      "title": "ActivityPreferences",
      "description": "Per-activity user preferences. Running is the first migrated activity-specific preference object; other activity kinds can be added without new root profile fields.",
      "type": "object",
      "additionalProperties": false,
      "required": [
        "running"
      ],
      "properties": {
        "running": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "paceMinSecsPerKm",
            "paceMaxSecsPerKm",
            "preferredDistances",
            "runningReasons",
            "preferredRunTimes",
            "version"
          ],
          "properties": {
            "paceMinSecsPerKm": {
              "type": "integer",
              "minimum": 1
            },
            "paceMaxSecsPerKm": {
              "type": "integer",
              "minimum": 1
            },
            "preferredDistances": {
              "type": "array",
              "maxItems": 12,
              "uniqueItems": true,
              "items": {
                "type": "string",
                "enum": [
                  "fiveK",
                  "tenK",
                  "halfMarathon",
                  "marathon"
                ]
              }
            },
            "runningReasons": {
              "type": "array",
              "maxItems": 12,
              "uniqueItems": true,
              "items": {
                "type": "string",
                "enum": [
                  "fitness",
                  "community",
                  "mindfulness",
                  "challenge",
                  "weightLoss",
                  "raceTraining",
                  "social"
                ]
              }
            },
            "preferredRunTimes": {
              "type": "array",
              "maxItems": 8,
              "uniqueItems": true,
              "items": {
                "type": "string",
                "enum": [
                  "earlyMorning",
                  "morning",
                  "afternoon",
                  "evening",
                  "night"
                ]
              }
            },
            "version": {
              "type": "integer",
              "minimum": 0
            }
          }
        }
      },
      "x-catch-ownership": "trigger-owned"
    }
  },
  "x-internal-demo-fields": [
    "synthetic",
    "seedPrefix",
    "scenario",
    "demoOps",
    "demoOpsId",
    "demoOpsCommand"
  ],
  "x-legacy-tolerated-fields": [
    "bio"
  ],
  "x-hidden-fields": [
    "phoneNumber",
    "email",
    "instagramHandle",
    "latitude",
    "longitude",
    "interestedInGenders",
    "preferences"
  ]
} as const;
