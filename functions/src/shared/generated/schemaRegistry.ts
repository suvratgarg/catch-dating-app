/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/generate_schema_contracts.mjs

export const profilePromptAnswerSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/embedded/profile_prompt_answer.schema.json",
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
} as const;

export const photoPromptAnswerSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/embedded/photo_prompt_answer.schema.json",
  "title": "PhotoPromptAnswer",
  "description": "One optional caption prompt for a profile photo slot.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "photoIndex",
    "promptId",
    "prompt",
    "caption"
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
      "maxLength": 140
    }
  },
  "x-catch-catalog": "../catalogs/photo_prompts.json"
} as const;

export const profilePhotoSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/embedded/profile_photo.schema.json",
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
          "description": "One optional caption prompt for a profile photo slot.",
          "type": "object",
          "additionalProperties": false,
          "required": [
            "photoIndex",
            "promptId",
            "prompt",
            "caption"
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
              "maxLength": 140
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
} as const;

export const configCitiesDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/config_cities.schema.json",
  "title": "ConfigCitiesDocument",
  "description": "Public city configuration stored at config/cities.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "config_cities",
  "x-firestore-path": "config/cities",
  "x-document-id-field": "cities",
  "x-owner": "admin city configuration tooling",
  "required": [
    "cityNames"
  ],
  "properties": {
    "cityNames": {
      "type": "array",
      "items": {
        "type": [
          "string",
          "null"
        ],
        "minLength": 1,
        "maxLength": 80,
        "pattern": "^[a-z0-9-]+$"
      },
      "minItems": 1,
      "uniqueItems": true
    },
    "cities": {
      "type": "array",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "name",
          "label",
          "latitude",
          "longitude"
        ],
        "properties": {
          "name": {
            "type": [
              "string",
              "null"
            ],
            "minLength": 1,
            "maxLength": 80,
            "pattern": "^[a-z0-9-]+$"
          },
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "latitude": {
            "type": [
              "number",
              "null"
            ],
            "minimum": -90,
            "maximum": 90
          },
          "longitude": {
            "type": [
              "number",
              "null"
            ],
            "minimum": -180,
            "maximum": 180
          }
        }
      },
      "uniqueItems": true
    }
  }
} as const;

export const onboardingDraftDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/onboarding_drafts.schema.json",
  "title": "OnboardingDraftDocument",
  "description": "Owner-private, intentionally extensible onboarding draft stored at onboarding_drafts/{uid}.",
  "type": "object",
  "additionalProperties": true,
  "x-firestore-collection": "onboarding_drafts",
  "x-firestore-path": "onboarding_drafts/{uid}",
  "x-document-id-field": "uid",
  "x-owner": "authenticated draft owner",
  "required": [
    "step"
  ],
  "properties": {
    "step": {
      "type": "integer",
      "minimum": 0
    },
    "draftVersion": {
      "type": "integer",
      "minimum": 0
    },
    "firstName": {
      "type": "string",
      "maxLength": 80
    },
    "lastName": {
      "type": "string",
      "maxLength": 80
    },
    "dateOfBirth": {
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
    },
    "phoneNumber": {
      "type": "string",
      "maxLength": 32
    },
    "countryCode": {
      "type": "string",
      "maxLength": 8
    },
    "gender": {
      "anyOf": [
        {
          "type": "string",
          "enum": [
            "man",
            "woman",
            "nonBinary",
            "other"
          ]
        },
        {
          "type": "null"
        }
      ]
    },
    "interestedInGenders": {
      "type": "array",
      "items": {
        "type": "string",
        "enum": [
          "man",
          "woman",
          "nonBinary",
          "other"
        ]
      },
      "uniqueItems": true
    },
    "instagramHandle": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 80
    },
    "profilePrompts": {
      "type": "array",
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
      "maxItems": 3
    }
  }
} as const;

export const userProfileDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/users.schema.json",
  "title": "UserProfileDocument",
  "description": "Canonical private profile document stored at users/{uid}. The uid is the document id and is not stored in document data.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "users",
  "x-firestore-path": "users/{uid}",
  "x-document-id-field": "uid",
  "x-owner": "owner initial create, callable-owned profile edits, server-owned projections",
  "required": [
    "name",
    "firstName",
    "lastName",
    "displayName",
    "dateOfBirth",
    "gender",
    "phoneNumber",
    "profileComplete",
    "email",
    "profilePrompts",
    "photoUrls",
    "photoThumbnailUrls",
    "photoPrompts",
    "interestedInGenders",
    "minAgePreference",
    "maxAgePreference",
    "languages",
    "paceMinSecsPerKm",
    "paceMaxSecsPerKm",
    "preferredDistances",
    "runningReasons",
    "preferredRunTimes",
    "prefsNewCatches",
    "prefsMessages",
    "prefsRunReminders",
    "prefsRunStatusUpdates",
    "prefsClubUpdates",
    "prefsWeeklyDigest",
    "prefsShowOnMap"
  ],
  "properties": {
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "firstName": {
      "type": "string",
      "maxLength": 80
    },
    "lastName": {
      "type": "string",
      "maxLength": 80
    },
    "displayName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80,
      "pattern": ".*\\S.*"
    },
    "dateOfBirth": {
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
    "gender": {
      "type": "string",
      "enum": [
        "man",
        "woman",
        "nonBinary",
        "other"
      ]
    },
    "phoneNumber": {
      "type": "string",
      "minLength": 1,
      "maxLength": 32
    },
    "profileComplete": {
      "type": "boolean"
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
    "email": {
      "anyOf": [
        {
          "const": ""
        },
        {
          "type": "string",
          "format": "email",
          "maxLength": 320
        }
      ]
    },
    "instagramHandle": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 30,
          "pattern": "^[A-Za-z0-9._]{1,30}$"
        },
        {
          "type": "null"
        }
      ]
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
      }
    },
    "photoUrls": {
      "type": "array",
      "maxItems": 12,
      "items": {
        "type": "string",
        "format": "uri",
        "maxLength": 2048
      }
    },
    "photoThumbnailUrls": {
      "type": "array",
      "maxItems": 12,
      "items": {
        "type": "string",
        "format": "uri",
        "maxLength": 2048
      }
    },
    "photoPrompts": {
      "type": "array",
      "maxItems": 6,
      "items": {
        "title": "PhotoPromptAnswer",
        "description": "One optional caption prompt for a profile photo slot.",
        "type": "object",
        "additionalProperties": false,
        "required": [
          "photoIndex",
          "promptId",
          "prompt",
          "caption"
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
            "maxLength": 140
          }
        },
        "x-catch-catalog": "../catalogs/photo_prompts.json"
      }
    },
    "city": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 80,
      "pattern": "^[a-z0-9-]+$"
    },
    "latitude": {
      "type": [
        "number",
        "null"
      ],
      "minimum": -90,
      "maximum": 90
    },
    "longitude": {
      "type": [
        "number",
        "null"
      ],
      "minimum": -180,
      "maximum": 180
    },
    "interestedInGenders": {
      "type": "array",
      "minItems": 1,
      "maxItems": 8,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "enum": [
          "man",
          "woman",
          "nonBinary",
          "other"
        ]
      }
    },
    "minAgePreference": {
      "type": "integer",
      "minimum": 18,
      "maximum": 99
    },
    "maxAgePreference": {
      "type": "integer",
      "minimum": 18,
      "maximum": 99
    },
    "height": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 120,
      "maximum": 220
    },
    "occupation": {
      "type": [
        "string",
        "null"
      ]
    },
    "company": {
      "type": [
        "string",
        "null"
      ]
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
      ]
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
      ]
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
      }
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
      ]
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
      ]
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
      ]
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
      ]
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
      ]
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
      ]
    },
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
    "prefsNewCatches": {
      "type": "boolean"
    },
    "prefsMessages": {
      "type": "boolean"
    },
    "prefsRunReminders": {
      "type": "boolean"
    },
    "prefsRunStatusUpdates": {
      "type": "boolean"
    },
    "prefsClubUpdates": {
      "type": "boolean"
    },
    "prefsWeeklyDigest": {
      "type": "boolean"
    },
    "prefsShowOnMap": {
      "type": "boolean"
    },
    "fcmToken": {
      "type": "string"
    },
    "deleted": {
      "type": "boolean"
    },
    "deletedAt": {
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
  "x-denormalized-to": [
    "publicProfiles/{uid}"
  ]
} as const;

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
    "photoUrls",
    "photoThumbnailUrls",
    "photoPrompts",
    "paceMinSecsPerKm",
    "paceMaxSecsPerKm",
    "preferredDistances",
    "runningReasons",
    "preferredRunTimes"
  ],
  "properties": {
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80
    },
    "age": {
      "type": "integer",
      "minimum": 18,
      "maximum": 120
    },
    "gender": {
      "type": "string",
      "enum": [
        "man",
        "woman",
        "nonBinary",
        "other"
      ]
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
      }
    },
    "photoUrls": {
      "type": "array",
      "maxItems": 12,
      "items": {
        "type": "string",
        "format": "uri",
        "maxLength": 2048
      }
    },
    "photoThumbnailUrls": {
      "type": "array",
      "maxItems": 12,
      "items": {
        "type": "string",
        "format": "uri",
        "maxLength": 2048
      }
    },
    "photoPrompts": {
      "type": "array",
      "maxItems": 6,
      "items": {
        "title": "PhotoPromptAnswer",
        "description": "One optional caption prompt for a profile photo slot.",
        "type": "object",
        "additionalProperties": false,
        "required": [
          "photoIndex",
          "promptId",
          "prompt",
          "caption"
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
            "maxLength": 140
          }
        },
        "x-catch-catalog": "../catalogs/photo_prompts.json"
      }
    },
    "city": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 80,
      "pattern": "^[a-z0-9-]+$"
    },
    "height": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 120,
      "maximum": 220
    },
    "occupation": {
      "type": [
        "string",
        "null"
      ]
    },
    "company": {
      "type": [
        "string",
        "null"
      ]
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
      ]
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
      ]
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
      }
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
      ]
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
      ]
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
      ]
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
      ]
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
      ]
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
      ]
    },
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

export const runClubDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/run_clubs.schema.json",
  "title": "RunClubDocument",
  "description": "Canonical run club document stored at runClubs/{clubId}. The club id is the document id and is not stored in document data.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "runClubs",
  "x-firestore-path": "runClubs/{clubId}",
  "x-document-id-field": "id",
  "x-owner": "create/update/archive/delete run-club callables; aggregate projections are trigger-owned",
  "x-internal-demo-fields": [
    "synthetic",
    "seedPrefix",
    "scenario",
    "demoOps",
    "demoOpsId",
    "demoOpsCommand"
  ],
  "required": [
    "name",
    "description",
    "location",
    "area",
    "hostUserId",
    "hostName",
    "hostAvatarUrl",
    "createdAt",
    "imageUrl",
    "tags",
    "memberCount",
    "rating",
    "reviewCount",
    "nextRunAt",
    "nextRunLabel",
    "instagramHandle",
    "phoneNumber",
    "email",
    "status",
    "archived",
    "archivedAt",
    "archiveReason"
  ],
  "properties": {
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "description": {
      "type": "string",
      "minLength": 1,
      "maxLength": 2000
    },
    "location": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 80,
      "pattern": "^[a-z0-9-]+$"
    },
    "area": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "hostUserId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "hostName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "hostAvatarUrl": {
      "anyOf": [
        {
          "type": "string",
          "format": "uri",
          "maxLength": 2048
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
    "imageUrl": {
      "anyOf": [
        {
          "type": "string",
          "format": "uri",
          "maxLength": 2048
        },
        {
          "type": "null"
        }
      ]
    },
    "tags": {
      "type": "array",
      "maxItems": 20,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 80
      }
    },
    "memberCount": {
      "type": "integer",
      "minimum": 0
    },
    "rating": {
      "type": "number",
      "minimum": 0,
      "maximum": 5
    },
    "reviewCount": {
      "type": "integer",
      "minimum": 0
    },
    "nextRunAt": {
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
    },
    "nextRunLabel": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 240
    },
    "instagramHandle": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 320
    },
    "phoneNumber": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 320
    },
    "email": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 320
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "archived"
      ]
    },
    "archived": {
      "type": "boolean"
    },
    "archivedAt": {
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
    },
    "archiveReason": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 500
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
    }
  }
} as const;

export const runClubMembershipDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/run_club_memberships.schema.json",
  "title": "RunClubMembershipDocument",
  "description": "Canonical run club membership edge stored at runClubMemberships/{membershipId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "runClubMemberships",
  "x-firestore-path": "runClubMemberships/{membershipId}",
  "x-document-id-field": "id",
  "x-owner": "run-club membership callables; parent member count is trigger-owned",
  "x-internal-demo-fields": [
    "synthetic",
    "seedPrefix",
    "scenario",
    "demoOps",
    "demoOpsId",
    "demoOpsCommand"
  ],
  "required": [
    "clubId",
    "uid",
    "role",
    "status",
    "pushNotificationsEnabled",
    "joinedAt",
    "leftAt",
    "deletedAt"
  ],
  "properties": {
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "role": {
      "type": "string",
      "enum": [
        "host",
        "member"
      ]
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "left",
        "deleted"
      ]
    },
    "pushNotificationsEnabled": {
      "type": "boolean"
    },
    "joinedAt": {
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
    "leftAt": {
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
    },
    "deletedAt": {
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
    }
  }
} as const;

export const runClubHostClaimDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/run_club_host_claims.schema.json",
  "title": "RunClubHostClaimDocument",
  "description": "Server-owned singleton claim stored at runClubHostClaims/{uid} to enforce one hosted club per user.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "runClubHostClaims",
  "x-firestore-path": "runClubHostClaims/{uid}",
  "x-document-id-field": "uid",
  "x-owner": "createRunClub callable",
  "required": [
    "uid",
    "clubId",
    "createdAt"
  ],
  "properties": {
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
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
    }
  }
} as const;

export const runDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/runs.schema.json",
  "title": "RunDocument",
  "description": "Canonical run document stored at runs/{runId}. The run id is the document id and is not stored in document data.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "runs",
  "x-firestore-path": "runs/{runId}",
  "x-document-id-field": "id",
  "x-owner": "host create/update/cancel/delete callables; booking and attendance aggregates are callable-owned",
  "x-internal-demo-fields": [
    "synthetic",
    "seedPrefix",
    "scenario",
    "demoOps",
    "demoOpsId",
    "demoOpsCommand"
  ],
  "required": [
    "runClubId",
    "startTime",
    "endTime",
    "meetingPoint",
    "startingPointLat",
    "startingPointLng",
    "locationDetails",
    "distanceKm",
    "pace",
    "capacityLimit",
    "description",
    "priceInPaise",
    "bookedCount",
    "checkedInCount",
    "waitlistedCount",
    "status",
    "cancelledAt",
    "cancellationReason",
    "constraints",
    "genderCounts"
  ],
  "properties": {
    "runClubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "startTime": {
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
    "endTime": {
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
    "meetingPoint": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "startingPointLat": {
      "type": [
        "number",
        "null"
      ],
      "minimum": -90,
      "maximum": 90
    },
    "startingPointLng": {
      "type": [
        "number",
        "null"
      ],
      "minimum": -180,
      "maximum": 180
    },
    "locationDetails": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000
    },
    "distanceKm": {
      "type": "number",
      "exclusiveMinimum": 0,
      "maximum": 100
    },
    "pace": {
      "type": "string",
      "enum": [
        "easy",
        "moderate",
        "fast",
        "competitive"
      ]
    },
    "capacityLimit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000
    },
    "description": {
      "type": "string",
      "maxLength": 2000
    },
    "priceInPaise": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100000000
    },
    "bookedCount": {
      "type": "integer",
      "minimum": 0
    },
    "checkedInCount": {
      "type": "integer",
      "minimum": 0
    },
    "waitlistedCount": {
      "type": "integer",
      "minimum": 0
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "cancelled"
      ]
    },
    "cancelledAt": {
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
    },
    "cancellationReason": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 500
    },
    "constraints": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "minAge",
        "maxAge",
        "maxMen",
        "maxWomen"
      ],
      "properties": {
        "minAge": {
          "type": "integer",
          "minimum": 0,
          "maximum": 120
        },
        "maxAge": {
          "type": "integer",
          "minimum": 0,
          "maximum": 120
        },
        "maxMen": {
          "type": [
            "integer",
            "null"
          ],
          "minimum": 0
        },
        "maxWomen": {
          "type": [
            "integer",
            "null"
          ],
          "minimum": 0
        }
      }
    },
    "genderCounts": {
      "type": "object",
      "additionalProperties": {
        "type": "integer",
        "minimum": 0
      }
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
    }
  }
} as const;

export const runParticipationDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/run_participations.schema.json",
  "title": "RunParticipationDocument",
  "description": "Canonical run roster edge stored at runParticipations/{participationId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "runParticipations",
  "x-firestore-path": "runParticipations/{participationId}",
  "x-document-id-field": "id",
  "x-owner": "booking, waitlist, attendance, cancellation, and account-deletion callables",
  "x-internal-demo-fields": [
    "synthetic",
    "seedPrefix",
    "scenario",
    "demoOps",
    "demoOpsId",
    "demoOpsCommand"
  ],
  "required": [
    "runId",
    "runClubId",
    "uid",
    "status",
    "createdAt",
    "updatedAt",
    "signedUpAt",
    "waitlistedAt",
    "attendedAt",
    "cancelledAt",
    "deletedAt",
    "genderAtSignup",
    "paymentId"
  ],
  "properties": {
    "runId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "runClubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "status": {
      "type": "string",
      "enum": [
        "signedUp",
        "waitlisted",
        "attended",
        "cancelled",
        "deleted"
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
    "signedUpAt": {
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
    },
    "waitlistedAt": {
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
    },
    "attendedAt": {
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
    },
    "cancelledAt": {
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
    },
    "deletedAt": {
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
    },
    "genderAtSignup": {
      "anyOf": [
        {
          "type": "string",
          "enum": [
            "man",
            "woman",
            "nonBinary",
            "other"
          ]
        },
        {
          "type": "null"
        }
      ]
    },
    "paymentId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
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
    }
  }
} as const;

export const runClubScheduleLockDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/run_club_schedule_locks.schema.json",
  "title": "RunClubScheduleLockDocument",
  "description": "Server-owned time-slot claim stored at runClubScheduleLocks/{clubId_slot}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "runClubScheduleLocks",
  "x-firestore-path": "runClubScheduleLocks/{lockId}",
  "x-document-id-field": "lockId",
  "x-owner": "run schedule conflict callables",
  "x-internal-demo-fields": [
    "synthetic",
    "seedPrefix",
    "scenario",
    "demoOps",
    "demoOpsId",
    "demoOpsCommand"
  ],
  "required": [
    "ownerType",
    "ownerId",
    "slot",
    "runId",
    "runClubId",
    "startTimeMillis",
    "endTimeMillis"
  ],
  "properties": {
    "ownerType": {
      "type": "string",
      "const": "runClub"
    },
    "ownerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "slot": {
      "type": "integer",
      "minimum": 0
    },
    "runId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "runClubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "startTimeMillis": {
      "type": "integer",
      "minimum": 0
    },
    "endTimeMillis": {
      "type": "integer",
      "minimum": 0
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
    }
  }
} as const;

export const userRunScheduleLockDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/user_run_schedule_locks.schema.json",
  "title": "UserRunScheduleLockDocument",
  "description": "Server-owned time-slot claim stored at userRunScheduleLocks/{uid_slot}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "userRunScheduleLocks",
  "x-firestore-path": "userRunScheduleLocks/{lockId}",
  "x-document-id-field": "lockId",
  "x-owner": "run signup and waitlist callables",
  "x-internal-demo-fields": [
    "synthetic",
    "seedPrefix",
    "scenario",
    "demoOps",
    "demoOpsId",
    "demoOpsCommand"
  ],
  "required": [
    "ownerType",
    "ownerId",
    "slot",
    "runId",
    "runClubId",
    "uid",
    "startTimeMillis",
    "endTimeMillis"
  ],
  "properties": {
    "ownerType": {
      "type": "string",
      "const": "user"
    },
    "ownerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "slot": {
      "type": "integer",
      "minimum": 0
    },
    "runId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "runClubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "startTimeMillis": {
      "type": "integer",
      "minimum": 0
    },
    "endTimeMillis": {
      "type": "integer",
      "minimum": 0
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
    }
  }
} as const;

export const savedRunDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/saved_runs.schema.json",
  "title": "SavedRunDocument",
  "description": "Canonical saved-run edge stored at savedRuns/{savedRunId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "savedRuns",
  "x-firestore-path": "savedRuns/{savedRunId}",
  "x-document-id-field": "id",
  "x-owner": "authenticated owner direct create/delete",
  "x-internal-demo-fields": [
    "synthetic",
    "seedPrefix",
    "scenario",
    "demoOps",
    "demoOpsId",
    "demoOpsCommand"
  ],
  "required": [
    "uid",
    "runId",
    "savedAt"
  ],
  "properties": {
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "runId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "savedAt": {
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
    "removedAt": {
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
    }
  }
} as const;

export const paymentDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/payments.schema.json",
  "title": "PaymentDocument",
  "description": "Canonical payment record stored at payments/{paymentId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "payments",
  "x-firestore-path": "payments/{paymentId}",
  "x-document-id-field": "id",
  "x-owner": "payments callables",
  "x-internal-demo-fields": [
    "synthetic",
    "seedPrefix",
    "scenario",
    "demoOps",
    "demoOpsId",
    "demoOpsCommand"
  ],
  "required": [
    "userId",
    "orderId",
    "paymentId",
    "runId",
    "amount",
    "currency",
    "status",
    "signUpFailed",
    "createdAt"
  ],
  "properties": {
    "userId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "orderId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "paymentId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "runId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "amount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100000000
    },
    "currency": {
      "type": "string",
      "minLength": 3,
      "maxLength": 3
    },
    "status": {
      "type": "string",
      "enum": [
        "pending",
        "completed",
        "failed",
        "refunded"
      ]
    },
    "signUpFailed": {
      "type": "boolean"
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
    }
  }
} as const;

export const swipeDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/swipes.schema.json",
  "title": "SwipeDocument",
  "description": "Current storage contract for contextual profile decisions stored at swipes/{userId}/outgoing/{targetId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "swipes",
  "x-firestore-path": "swipes/{userId}/outgoing/{targetId}",
  "x-document-id-field": "targetId",
  "x-owner": "authenticated swiper direct create; matching trigger consumes likes",
  "x-logical-name": "profileDecision",
  "x-migration-phase": "observe",
  "x-internal-demo-fields": [
    "synthetic",
    "seedPrefix",
    "scenario",
    "demoOps",
    "demoOpsId",
    "demoOpsCommand"
  ],
  "required": [
    "swiperId",
    "targetId",
    "runId",
    "direction",
    "createdAt"
  ],
  "properties": {
    "swiperId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "targetId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "runId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "direction": {
      "type": "string",
      "enum": [
        "like",
        "pass"
      ]
    },
    "reactionTargetId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 80
    },
    "reactionTargetType": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "heroPhoto",
        "photo",
        "profilePrompt",
        "compatibility",
        "running",
        "details",
        "lifestyle",
        null
      ]
    },
    "reactionTargetLabel": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 80
    },
    "reactionTargetPreview": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 240
    },
    "comment": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 240
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
    }
  }
} as const;

export const matchDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/matches.schema.json",
  "title": "MatchDocument",
  "description": "Canonical match document stored at matches/{matchId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "matches",
  "x-firestore-path": "matches/{matchId}",
  "x-document-id-field": "id",
  "x-owner": "matching triggers own lifecycle; participants may reset only their unread count",
  "x-internal-demo-fields": [
    "synthetic",
    "seedPrefix",
    "scenario",
    "demoOps",
    "demoOpsId",
    "demoOpsCommand"
  ],
  "required": [
    "user1Id",
    "user2Id",
    "runIds",
    "createdAt",
    "lastMessageAt",
    "lastMessagePreview",
    "lastMessageSenderId",
    "unreadCounts",
    "status",
    "blockedBy",
    "blockedAt",
    "participantIds"
  ],
  "properties": {
    "user1Id": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "user2Id": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "runIds": {
      "type": "array",
      "minItems": 1,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      }
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
    "lastMessageAt": {
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
    },
    "lastMessagePreview": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 300
    },
    "lastMessageSenderId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "unreadCounts": {
      "type": "object",
      "additionalProperties": {
        "type": "integer",
        "minimum": 0
      }
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "blocked"
      ]
    },
    "blockedBy": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "blockedAt": {
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
    },
    "participantIds": {
      "type": "array",
      "minItems": 2,
      "maxItems": 2,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      }
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
    }
  }
} as const;

export const chatMessageDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/chat_messages.schema.json",
  "title": "ChatMessageDocument",
  "description": "Canonical chat message document stored at matches/{matchId}/messages/{messageId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "chat_messages",
  "x-firestore-path": "matches/{matchId}/messages/{messageId}",
  "x-document-id-field": "id",
  "x-owner": "active match participant creates message; triggers own moderation and match preview projections",
  "x-internal-demo-fields": [
    "synthetic",
    "seedPrefix",
    "scenario",
    "demoOps",
    "demoOpsId",
    "demoOpsCommand"
  ],
  "required": [
    "senderId",
    "text"
  ],
  "anyOf": [
    {
      "properties": {
        "text": {
          "type": "string",
          "minLength": 1,
          "maxLength": 2000
        }
      }
    },
    {
      "required": [
        "imageUrl"
      ],
      "properties": {
        "imageUrl": {
          "type": "string",
          "format": "uri",
          "maxLength": 2048
        }
      }
    }
  ],
  "properties": {
    "senderId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "text": {
      "type": "string",
      "maxLength": 2000
    },
    "imageUrl": {
      "anyOf": [
        {
          "type": "string",
          "format": "uri",
          "maxLength": 2048
        },
        {
          "type": "null"
        }
      ]
    },
    "sentAt": {
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
    }
  }
} as const;

export const activityNotificationDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/activity_notifications.schema.json",
  "title": "ActivityNotificationDocument",
  "description": "Canonical durable activity notification stored at notifications/{uid}/items/{notificationId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "activity_notifications",
  "x-firestore-path": "notifications/{uid}/items/{notificationId}",
  "x-document-id-field": "id",
  "x-owner": "notification fan-out functions and booking callables",
  "x-internal-demo-fields": [
    "synthetic",
    "seedPrefix",
    "scenario",
    "demoOps",
    "demoOpsId",
    "demoOpsCommand"
  ],
  "required": [
    "uid",
    "type",
    "title",
    "body",
    "createdAt"
  ],
  "properties": {
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "type": {
      "type": "string",
      "enum": [
        "message",
        "match",
        "runReminder",
        "runSignup",
        "waitlistPromotion",
        "runCancelled",
        "runUpdated",
        "clubUpdate"
      ]
    },
    "title": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160
    },
    "body": {
      "type": "string",
      "minLength": 1,
      "maxLength": 500
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
    "readAt": {
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
    },
    "matchId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 240
    },
    "runId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "runClubId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "actorUid": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "actorName": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 120
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
    }
  }
} as const;

export const reviewDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/reviews.schema.json",
  "title": "ReviewDocument",
  "description": "Canonical attended-run review stored at reviews/{reviewId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "reviews",
  "x-firestore-path": "reviews/{reviewId}",
  "x-document-id-field": "id",
  "x-owner": "review mutation callables; aggregate stats are trigger-owned",
  "x-internal-demo-fields": [
    "synthetic",
    "seedPrefix",
    "scenario",
    "demoOps",
    "demoOpsId",
    "demoOpsCommand"
  ],
  "required": [
    "runClubId",
    "reviewerUserId",
    "reviewerName",
    "rating",
    "comment",
    "createdAt"
  ],
  "properties": {
    "runClubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "runId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180
    },
    "reviewerUserId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "reviewerName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "rating": {
      "type": "integer",
      "minimum": 1,
      "maximum": 5
    },
    "comment": {
      "type": "string",
      "maxLength": 1000
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
    }
  }
} as const;

export const blockDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/blocks.schema.json",
  "title": "BlockDocument",
  "description": "Canonical safety block edge stored at blocks/{blockId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "blocks",
  "x-firestore-path": "blocks/{blockId}",
  "x-document-id-field": "id",
  "x-owner": "safety callables and block trigger",
  "required": [
    "blockerUserId",
    "blockedUserId",
    "createdAt",
    "source"
  ],
  "properties": {
    "blockerUserId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "blockedUserId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
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
    "source": {
      "type": "string",
      "enum": [
        "profile",
        "chat",
        "match",
        "support"
      ]
    },
    "reasonCode": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80
    }
  }
} as const;

export const reportDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/reports.schema.json",
  "title": "ReportDocument",
  "description": "Canonical safety report stored at reports/{reportId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "reports",
  "x-firestore-path": "reports/{reportId}",
  "x-document-id-field": "id",
  "x-owner": "reportUser callable",
  "required": [
    "reporterUserId",
    "targetUserId",
    "createdAt",
    "source",
    "status"
  ],
  "properties": {
    "reporterUserId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "targetUserId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
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
    "source": {
      "type": "string",
      "enum": [
        "profile",
        "chat",
        "match",
        "support"
      ]
    },
    "status": {
      "type": "string",
      "enum": [
        "open",
        "reviewed",
        "dismissed"
      ]
    },
    "reasonCode": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80
    },
    "contextId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "notes": {
      "type": "string",
      "maxLength": 1000
    }
  }
} as const;

export const moderationFlagDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/moderation_flags.schema.json",
  "title": "ModerationFlagDocument",
  "description": "Canonical moderation ticket stored at moderationFlags/{flagId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "moderationFlags",
  "x-firestore-path": "moderationFlags/{flagId}",
  "x-document-id-field": "id",
  "x-owner": "moderation triggers",
  "required": [
    "targetUserId",
    "flagType",
    "source",
    "status",
    "createdAt"
  ],
  "properties": {
    "targetUserId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "flagType": {
      "type": "string",
      "enum": [
        "explicit_photo",
        "banned_text",
        "underage_content"
      ]
    },
    "source": {
      "type": "string",
      "enum": [
        "profile_photo",
        "club_image",
        "chat_message",
        "user_bio",
        "club_description",
        "review_comment"
      ]
    },
    "status": {
      "type": "string",
      "enum": [
        "pending",
        "reviewed",
        "dismissed"
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
    "reviewedAt": {
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
    "contextId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "context": {
      "type": "string",
      "maxLength": 1000
    },
    "safeSearchResults": {
      "type": "object",
      "additionalProperties": {
        "type": "string"
      }
    }
  }
} as const;

export const deletedUserTombstoneDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/deleted_users.schema.json",
  "title": "DeletedUserTombstoneDocument",
  "description": "Server-owned account-deletion tombstone stored at deletedUsers/{uid}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "deletedUsers",
  "x-firestore-path": "deletedUsers/{uid}",
  "x-document-id-field": "uid",
  "x-owner": "requestAccountDeletion callable",
  "required": [
    "uid",
    "deletedAt"
  ],
  "properties": {
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "deletedAt": {
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
    "retainedFor": {
      "type": "array",
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 80
      },
      "uniqueItems": true
    }
  }
} as const;

export const rateLimitDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/rate_limits.schema.json",
  "title": "RateLimitDocument",
  "description": "Server-owned callable rate-limit counter stored at rateLimits/{docId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "rateLimits",
  "x-firestore-path": "rateLimits/{docId}",
  "x-document-id-field": "docId",
  "x-owner": "shared callable rate-limit middleware",
  "required": [
    "uid",
    "action",
    "windowKey",
    "count",
    "expiresAt"
  ],
  "properties": {
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "action": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "windowKey": {
      "type": "integer",
      "minimum": 0
    },
    "count": {
      "type": "integer",
      "minimum": 1
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
    }
  }
} as const;

export const functionEventReceiptDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/function_event_receipts.schema.json",
  "title": "FunctionEventReceiptDocument",
  "description": "Server-owned idempotency receipt stored at functionEventReceipts/{receiptId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "functionEventReceipts",
  "x-firestore-path": "functionEventReceipts/{receiptId}",
  "x-document-id-field": "receiptId",
  "x-owner": "idempotent Firestore trigger handlers",
  "required": [
    "handler",
    "eventId",
    "matchId",
    "messageId",
    "createdAt"
  ],
  "properties": {
    "handler": {
      "type": "string",
      "enum": [
        "onMessageCreated"
      ]
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "matchId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "messageId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
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
    }
  }
} as const;

export const seedRunManifestDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/seed_runs.schema.json",
  "title": "SeedRunManifestDocument",
  "description": "Tool-owned synthetic-data manifest stored at seedRuns/{manifestId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "seedRuns",
  "x-firestore-path": "seedRuns/{manifestId}",
  "x-document-id-field": "manifestId",
  "x-owner": "demo data seeding tooling",
  "x-internal-demo-fields": [
    "synthetic",
    "seedPrefix",
    "scenario",
    "demoOps",
    "demoOpsId",
    "demoOpsCommand"
  ],
  "required": [
    "seedId",
    "manifestId",
    "generatedAt",
    "anchorUserIds",
    "counts",
    "paths"
  ],
  "properties": {
    "seedId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "manifestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "generatedAt": {
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
    "anchorUserIds": {
      "type": "array",
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      },
      "uniqueItems": true
    },
    "counts": {
      "type": "object",
      "additionalProperties": {
        "type": "integer",
        "minimum": 0
      }
    },
    "paths": {
      "type": "array",
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 512
      },
      "uniqueItems": true
    },
    "appendMode": {
      "type": "boolean"
    },
    "appendedAnchorUserIds": {
      "type": "array",
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      },
      "uniqueItems": true
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
    }
  }
} as const;

export const updateUserProfileCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/patches/update_user_profile.schema.json",
  "title": "UpdateUserProfileCallablePayload",
  "description": "Callable request body for updateUserProfile. Values are normalized before Firestore writes.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "fields"
  ],
  "properties": {
    "fields": {
      "type": "object",
      "additionalProperties": false,
      "minProperties": 1,
      "properties": {
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "displayName": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80,
          "pattern": ".*\\S.*"
        },
        "email": {
          "anyOf": [
            {
              "const": ""
            },
            {
              "type": "string",
              "format": "email",
              "maxLength": 320
            }
          ]
        },
        "instagramHandle": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 30,
              "pattern": "^[A-Za-z0-9._]{1,30}$"
            },
            {
              "type": "null"
            }
          ]
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
          }
        },
        "phoneNumber": {
          "type": "string",
          "minLength": 1,
          "maxLength": 32
        },
        "dateOfBirth": {
          "type": "integer",
          "minimum": 0,
          "description": "Milliseconds since epoch before conversion to Firestore Timestamp."
        },
        "gender": {
          "type": "string",
          "enum": [
            "man",
            "woman",
            "nonBinary",
            "other"
          ]
        },
        "profileComplete": {
          "type": "boolean"
        },
        "photoUrls": {
          "type": "array",
          "maxItems": 12,
          "items": {
            "type": "string",
            "format": "uri",
            "maxLength": 2048
          }
        },
        "photoPrompts": {
          "type": "array",
          "maxItems": 6,
          "items": {
            "title": "PhotoPromptAnswer",
            "description": "One optional caption prompt for a profile photo slot.",
            "type": "object",
            "additionalProperties": false,
            "required": [
              "photoIndex",
              "promptId",
              "prompt",
              "caption"
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
                "maxLength": 140
              }
            },
            "x-catch-catalog": "../catalogs/photo_prompts.json"
          }
        },
        "city": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 80,
          "pattern": "^[a-z0-9-]+$"
        },
        "latitude": {
          "type": [
            "number",
            "null"
          ],
          "minimum": -90,
          "maximum": 90
        },
        "longitude": {
          "type": [
            "number",
            "null"
          ],
          "minimum": -180,
          "maximum": 180
        },
        "interestedInGenders": {
          "type": "array",
          "minItems": 1,
          "maxItems": 8,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "enum": [
              "man",
              "woman",
              "nonBinary",
              "other"
            ]
          }
        },
        "minAgePreference": {
          "type": "integer",
          "minimum": 18,
          "maximum": 99
        },
        "maxAgePreference": {
          "type": "integer",
          "minimum": 18,
          "maximum": 99
        },
        "height": {
          "type": [
            "integer",
            "null"
          ],
          "minimum": 120,
          "maximum": 220
        },
        "occupation": {
          "type": [
            "string",
            "null"
          ]
        },
        "company": {
          "type": [
            "string",
            "null"
          ]
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
          ]
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
          ]
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
          }
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
          ]
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
          ]
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
          ]
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
          ]
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
          ]
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
          ]
        },
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
        "prefsNewCatches": {
          "type": "boolean"
        },
        "prefsMessages": {
          "type": "boolean"
        },
        "prefsRunReminders": {
          "type": "boolean"
        },
        "prefsRunStatusUpdates": {
          "type": "boolean"
        },
        "prefsClubUpdates": {
          "type": "boolean"
        },
        "prefsWeeklyDigest": {
          "type": "boolean"
        },
        "prefsShowOnMap": {
          "type": "boolean"
        }
      }
    }
  },
  "x-normalization": [
    "trim prompt ids and display prompt titles",
    "collapse stacked blank lines in prompt answers and captions",
    "drop empty prompt answers and empty photo captions",
    "convert dateOfBirth millis to Firestore Timestamp"
  ],
  "x-intentionally-excluded-fields": [
    "firstName",
    "lastName",
    "photoThumbnailUrls",
    "fcmToken",
    "deleted",
    "deletedAt",
    "sexualOrientation",
    "bio"
  ]
} as const;

export const createRunClubCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_run_club_payload.schema.json",
  "title": "CreateRunClubCallablePayload",
  "description": "Callable payload accepted by createRunClub.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "name",
    "description",
    "location",
    "area"
  ],
  "properties": {
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "description": {
      "type": "string",
      "minLength": 1,
      "maxLength": 2000
    },
    "location": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 80,
      "pattern": "^[a-z0-9-]+$"
    },
    "area": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "imageUrl": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 320
    },
    "instagramHandle": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 320
    },
    "phoneNumber": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 320
    },
    "email": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 320
    }
  }
} as const;

export const updateRunClubCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/update_run_club_payload.schema.json",
  "title": "UpdateRunClubCallablePayload",
  "description": "Callable payload accepted by updateRunClub.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "clubId",
    "fields"
  ],
  "properties": {
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "fields": {
      "type": "object",
      "additionalProperties": false,
      "minProperties": 1,
      "properties": {
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "description": {
          "type": "string",
          "minLength": 1,
          "maxLength": 2000
        },
        "location": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 80,
          "pattern": "^[a-z0-9-]+$"
        },
        "area": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "hostName": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "hostAvatarUrl": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 320
        },
        "imageUrl": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 320
        },
        "tags": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 40
          },
          "maxItems": 12,
          "uniqueItems": true
        },
        "instagramHandle": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 320
        },
        "phoneNumber": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 320
        },
        "email": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 320
        }
      }
    }
  }
} as const;

export const archiveRunClubCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/archive_run_club_payload.schema.json",
  "title": "ArchiveRunClubCallablePayload",
  "description": "Callable payload accepted by archiveRunClub.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "clubId"
  ],
  "properties": {
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "reason": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 500
    }
  }
} as const;

export const deleteRunClubCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/delete_run_club_payload.schema.json",
  "title": "DeleteRunClubCallablePayload",
  "description": "Callable payload accepted by deleteRunClub.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "clubId"
  ],
  "properties": {
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;

export const runClubMembershipCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/run_club_membership_payload.schema.json",
  "title": "RunClubMembershipCallablePayload",
  "description": "Callable payload accepted by joinRunClub and leaveRunClub.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "clubId"
  ],
  "properties": {
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;

export const setRunClubNotificationPreferenceCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/set_run_club_notification_preference_payload.schema.json",
  "title": "SetRunClubNotificationPreferenceCallablePayload",
  "description": "Callable payload accepted by setRunClubNotificationPreference.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "clubId",
    "enabled"
  ],
  "properties": {
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "enabled": {
      "type": "boolean"
    }
  }
} as const;

export const createRunCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_run_payload.schema.json",
  "title": "CreateRunCallablePayload",
  "description": "Callable payload accepted by createRun.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "runClubId",
    "startTimeMillis",
    "endTimeMillis",
    "meetingPoint",
    "startingPointLat",
    "startingPointLng",
    "distanceKm",
    "pace",
    "capacityLimit",
    "description",
    "priceInPaise"
  ],
  "properties": {
    "runId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "runClubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "startTimeMillis": {
      "type": "integer"
    },
    "endTimeMillis": {
      "type": "integer"
    },
    "meetingPoint": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "startingPointLat": {
      "type": "number",
      "minimum": -90,
      "maximum": 90
    },
    "startingPointLng": {
      "type": "number",
      "minimum": -180,
      "maximum": 180
    },
    "locationDetails": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000
    },
    "distanceKm": {
      "type": "number",
      "exclusiveMinimum": 0,
      "maximum": 100
    },
    "pace": {
      "type": "string",
      "enum": [
        "easy",
        "moderate",
        "fast",
        "competitive"
      ]
    },
    "capacityLimit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000
    },
    "description": {
      "type": "string",
      "maxLength": 2000
    },
    "priceInPaise": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100000000
    },
    "constraints": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "minAge": {
          "type": "integer",
          "minimum": 0,
          "maximum": 120
        },
        "maxAge": {
          "type": "integer",
          "minimum": 0,
          "maximum": 120
        },
        "maxMen": {
          "type": [
            "integer",
            "null"
          ],
          "minimum": 0
        },
        "maxWomen": {
          "type": [
            "integer",
            "null"
          ],
          "minimum": 0
        }
      }
    }
  }
} as const;

export const updateRunCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/update_run_payload.schema.json",
  "title": "UpdateRunCallablePayload",
  "description": "Callable payload accepted by updateRun.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "runId",
    "fields"
  ],
  "properties": {
    "runId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "fields": {
      "type": "object",
      "additionalProperties": false,
      "minProperties": 1,
      "properties": {
        "startTimeMillis": {
          "type": "integer"
        },
        "endTimeMillis": {
          "type": "integer"
        },
        "meetingPoint": {
          "type": "string",
          "minLength": 1,
          "maxLength": 240
        },
        "startingPointLat": {
          "anyOf": [
            {
              "type": [
                "number",
                "null"
              ],
              "minimum": -90,
              "maximum": 90
            },
            {
              "type": "null"
            }
          ]
        },
        "startingPointLng": {
          "anyOf": [
            {
              "type": [
                "number",
                "null"
              ],
              "minimum": -180,
              "maximum": 180
            },
            {
              "type": "null"
            }
          ]
        },
        "locationDetails": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 1000
        },
        "distanceKm": {
          "type": "number",
          "exclusiveMinimum": 0,
          "maximum": 100
        },
        "pace": {
          "type": "string",
          "enum": [
            "easy",
            "moderate",
            "fast",
            "competitive"
          ]
        },
        "description": {
          "type": "string",
          "maxLength": 2000
        }
      }
    }
  }
} as const;

export const cancelRunCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/cancel_run_payload.schema.json",
  "title": "CancelRunCallablePayload",
  "description": "Callable payload accepted by cancelRun.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "runId"
  ],
  "properties": {
    "runId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "reason": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 500
    }
  }
} as const;

export const deleteRunCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/delete_run_payload.schema.json",
  "title": "DeleteRunCallablePayload",
  "description": "Callable payload accepted by deleteRun.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "runId"
  ],
  "properties": {
    "runId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;

export const runIdCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/run_id_payload.schema.json",
  "title": "RunIdCallablePayload",
  "description": "Callable payload accepted by simple run actions that need only a runId.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "runId"
  ],
  "properties": {
    "runId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;

export const markRunAttendanceCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/mark_run_attendance_payload.schema.json",
  "title": "MarkRunAttendanceCallablePayload",
  "description": "Callable payload accepted by markRunAttendance.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "runId",
    "userId"
  ],
  "properties": {
    "runId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "userId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;

export const selfCheckInAttendanceCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/self_check_in_attendance_payload.schema.json",
  "title": "SelfCheckInAttendanceCallablePayload",
  "description": "Callable payload accepted by selfCheckInAttendance.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "runId"
  ],
  "properties": {
    "runId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "latitude": {
      "type": [
        "number",
        "null"
      ],
      "minimum": -90,
      "maximum": 90
    },
    "longitude": {
      "type": [
        "number",
        "null"
      ],
      "minimum": -180,
      "maximum": 180
    }
  }
} as const;

export const createRunReviewCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_run_review_payload.schema.json",
  "title": "CreateRunReviewCallablePayload",
  "description": "Callable payload accepted by createRunReview.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "runClubId",
    "runId",
    "rating",
    "comment"
  ],
  "properties": {
    "runClubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "runId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "rating": {
      "type": "integer",
      "minimum": 1,
      "maximum": 5
    },
    "comment": {
      "type": "string",
      "maxLength": 1000
    }
  }
} as const;

export const updateRunReviewCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/update_run_review_payload.schema.json",
  "title": "UpdateRunReviewCallablePayload",
  "description": "Callable payload accepted by updateRunReview.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "reviewId",
    "rating",
    "comment"
  ],
  "properties": {
    "reviewId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "rating": {
      "type": "integer",
      "minimum": 1,
      "maximum": 5
    },
    "comment": {
      "type": "string",
      "maxLength": 1000
    }
  }
} as const;

export const deleteRunReviewCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/delete_run_review_payload.schema.json",
  "title": "DeleteRunReviewCallablePayload",
  "description": "Callable payload accepted by deleteRunReview.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "reviewId"
  ],
  "properties": {
    "reviewId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;

export const blockUserCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/block_user_payload.schema.json",
  "title": "BlockUserCallablePayload",
  "description": "Callable payload accepted by blockUser.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "targetUserId"
  ],
  "properties": {
    "targetUserId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "source": {
      "type": "string",
      "maxLength": 80
    },
    "reasonCode": {
      "type": "string",
      "maxLength": 80
    }
  }
} as const;

export const unblockUserCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/unblock_user_payload.schema.json",
  "title": "UnblockUserCallablePayload",
  "description": "Callable payload accepted by unblockUser.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "targetUserId"
  ],
  "properties": {
    "targetUserId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;

export const reportUserCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/report_user_payload.schema.json",
  "title": "ReportUserCallablePayload",
  "description": "Callable payload accepted by reportUser.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "targetUserId"
  ],
  "properties": {
    "targetUserId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "source": {
      "type": "string",
      "maxLength": 64
    },
    "reasonCode": {
      "type": "string",
      "maxLength": 64
    },
    "contextId": {
      "type": "string",
      "maxLength": 128
    },
    "notes": {
      "type": "string",
      "maxLength": 2000
    }
  }
} as const;

export const verifyRazorpayPaymentCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/verify_razorpay_payment_payload.schema.json",
  "title": "VerifyRazorpayPaymentCallablePayload",
  "description": "Callable payload accepted by verifyRazorpayPayment.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "paymentId",
    "orderId",
    "signature"
  ],
  "properties": {
    "paymentId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "orderId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "signature": {
      "type": "string",
      "minLength": 1,
      "maxLength": 512
    }
  }
} as const;

export const placesAutocompleteCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/places_autocomplete_payload.schema.json",
  "title": "PlacesAutocompleteCallablePayload",
  "description": "Callable payload accepted by placesAutocomplete.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "input"
  ],
  "properties": {
    "input": {
      "type": "string",
      "minLength": 2,
      "maxLength": 120
    },
    "sessionToken": {
      "type": "string",
      "minLength": 8,
      "maxLength": 128
    },
    "latitude": {
      "type": "number",
      "minimum": -90,
      "maximum": 90
    },
    "longitude": {
      "type": "number",
      "minimum": -180,
      "maximum": 180
    }
  }
} as const;

export const placeDetailsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/place_details_payload.schema.json",
  "title": "PlaceDetailsCallablePayload",
  "description": "Callable payload accepted by placeDetails.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "placeId"
  ],
  "properties": {
    "placeId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 256
    },
    "sessionToken": {
      "type": "string",
      "minLength": 8,
      "maxLength": 128
    }
  }
} as const;

export const createProfileDecisionClientWriteSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/client_writes/create_profile_decision.schema.json",
  "title": "CreateProfileDecisionClientWrite",
  "description": "Client-owned Firestore create operation for the current swipes/{userId}/outgoing/{targetId} storage path.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "path",
    "data"
  ],
  "properties": {
    "path": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "userId",
        "targetId"
      ],
      "properties": {
        "userId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "targetId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        }
      }
    },
    "data": {
      "title": "SwipeDocument",
      "description": "Current storage contract for contextual profile decisions stored at swipes/{userId}/outgoing/{targetId}.",
      "type": "object",
      "additionalProperties": false,
      "x-firestore-collection": "swipes",
      "x-firestore-path": "swipes/{userId}/outgoing/{targetId}",
      "x-document-id-field": "targetId",
      "x-owner": "authenticated swiper direct create; matching trigger consumes likes",
      "x-logical-name": "profileDecision",
      "x-migration-phase": "observe",
      "x-internal-demo-fields": [
        "synthetic",
        "seedPrefix",
        "scenario",
        "demoOps",
        "demoOpsId",
        "demoOpsCommand"
      ],
      "required": [
        "swiperId",
        "targetId",
        "runId",
        "direction",
        "createdAt"
      ],
      "properties": {
        "swiperId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "targetId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "runId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "direction": {
          "type": "string",
          "enum": [
            "like",
            "pass"
          ]
        },
        "reactionTargetId": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 80
        },
        "reactionTargetType": {
          "type": [
            "string",
            "null"
          ],
          "enum": [
            "heroPhoto",
            "photo",
            "profilePrompt",
            "compatibility",
            "running",
            "details",
            "lifestyle",
            null
          ]
        },
        "reactionTargetLabel": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 80
        },
        "reactionTargetPreview": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 240
        },
        "comment": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 240
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
        }
      }
    }
  },
  "x-firestore-operation": "create",
  "x-firestore-path": "swipes/{userId}/outgoing/{targetId}",
  "x-logical-name": "profileDecision",
  "x-migration-phase": "observe",
  "x-owner": "authenticated profile viewer direct create; matching trigger consumes likes"
} as const;

export const createChatMessageClientWriteSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/client_writes/create_chat_message.schema.json",
  "title": "CreateChatMessageClientWrite",
  "description": "Client-owned Firestore create operation for matches/{matchId}/messages/{messageId}.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "path",
    "data"
  ],
  "properties": {
    "path": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "matchId",
        "messageId"
      ],
      "properties": {
        "matchId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "messageId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        }
      }
    },
    "data": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "senderId",
        "text",
        "sentAt"
      ],
      "properties": {
        "senderId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "text": {
          "type": "string",
          "maxLength": 2000
        },
        "imageUrl": {
          "anyOf": [
            {
              "type": "string",
              "format": "uri",
              "maxLength": 2048
            },
            {
              "type": "null"
            }
          ]
        },
        "sentAt": {
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
      "anyOf": [
        {
          "properties": {
            "text": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2000
            }
          }
        },
        {
          "required": [
            "imageUrl"
          ],
          "properties": {
            "imageUrl": {
              "type": "string",
              "format": "uri",
              "maxLength": 2048
            }
          }
        }
      ]
    }
  },
  "x-firestore-operation": "create",
  "x-firestore-path": "matches/{matchId}/messages/{messageId}",
  "x-owner": "active match participant direct create; moderation and preview fan-out are trigger-owned"
} as const;

export const createSavedRunClientWriteSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/client_writes/create_saved_run.schema.json",
  "title": "CreateSavedRunClientWrite",
  "description": "Client-owned Firestore create operation for savedRuns/{savedRunId}.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "path",
    "data"
  ],
  "properties": {
    "path": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "savedRunId"
      ],
      "properties": {
        "savedRunId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        }
      }
    },
    "data": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "uid",
        "runId",
        "savedAt"
      ],
      "properties": {
        "uid": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "runId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "savedAt": {
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
      }
    }
  },
  "x-firestore-operation": "create",
  "x-firestore-path": "savedRuns/{savedRunId}",
  "x-owner": "authenticated owner direct create"
} as const;

export const deleteSavedRunClientWriteSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/client_writes/delete_saved_run.schema.json",
  "title": "DeleteSavedRunClientWrite",
  "description": "Client-owned Firestore delete operation for savedRuns/{savedRunId}.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "path"
  ],
  "properties": {
    "path": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "savedRunId"
      ],
      "properties": {
        "savedRunId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        }
      }
    }
  },
  "x-firestore-operation": "delete",
  "x-firestore-path": "savedRuns/{savedRunId}",
  "x-owner": "authenticated owner direct delete"
} as const;

export const markNotificationReadClientWriteSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/client_writes/mark_notification_read.schema.json",
  "title": "MarkNotificationReadClientWrite",
  "description": "Client-owned Firestore update operation for notifications/{uid}/items/{notificationId}.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "path",
    "data"
  ],
  "properties": {
    "path": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "uid",
        "notificationId"
      ],
      "properties": {
        "uid": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "notificationId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        }
      }
    },
    "data": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "readAt"
      ],
      "properties": {
        "readAt": {
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
      }
    }
  },
  "x-firestore-operation": "update",
  "x-firestore-path": "notifications/{uid}/items/{notificationId}",
  "x-owner": "notification owner direct read-state update"
} as const;

export const resetMatchUnreadCountClientWriteSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/client_writes/reset_match_unread_count.schema.json",
  "title": "ResetMatchUnreadCountClientWrite",
  "description": "Client-owned Firestore update operation for a participant resetting only their own unread counter on matches/{matchId}.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "path",
    "data"
  ],
  "properties": {
    "path": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "matchId"
      ],
      "properties": {
        "matchId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        }
      }
    },
    "data": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "unreadCounts"
      ],
      "properties": {
        "unreadCounts": {
          "type": "object",
          "additionalProperties": {
            "type": "integer",
            "minimum": 0
          },
          "minProperties": 1,
          "maxProperties": 1
        }
      }
    }
  },
  "x-firestore-operation": "update",
  "x-firestore-path": "matches/{matchId}",
  "x-owner": "active match participant direct unread reset"
} as const;

export const profilePromptCatalog = {
  "schemaVersion": 1,
  "kind": "profilePrompts",
  "limits": {
    "maxAnswers": 3,
    "maxPromptIdLength": 80,
    "maxPromptTitleLength": 140,
    "maxAnswerLength": 300
  },
  "defaultPromptIds": [
    "perfectRun",
    "afterRun",
    "greenFlag"
  ],
  "prompts": [
    {
      "id": "perfectRun",
      "title": "A perfect run with me looks like...",
      "placeholder": "Tell runners what kind of run feels like you."
    },
    {
      "id": "afterRun",
      "title": "After a run, you can usually find me...",
      "placeholder": "Coffee, dosa, stretching, playlists..."
    },
    {
      "id": "greenFlag",
      "title": "My green flag is...",
      "placeholder": "Share something specific and easy to respond to."
    },
    {
      "id": "getAlongIf",
      "title": "We'll get along if...",
      "placeholder": "Name the energy, habits, or humor you like."
    },
    {
      "id": "favoriteRoute",
      "title": "My favorite running route has...",
      "placeholder": "Shade, chaos, hills, street food, sunrise..."
    }
  ]
} as const;

export const photoPromptCatalog = {
  "schemaVersion": 1,
  "kind": "photoPrompts",
  "limits": {
    "maxCaptions": 6,
    "maxPromptIdLength": 80,
    "maxPromptTitleLength": 140,
    "maxCaptionLength": 140
  },
  "prompts": [
    {
      "id": "proofIRun",
      "title": "Proof I actually run",
      "placeholder": "Add a caption for this running photo."
    },
    {
      "id": "finishLine",
      "title": "After the finish line",
      "placeholder": "What was happening in this moment?"
    },
    {
      "id": "notRunning",
      "title": "When I'm not running",
      "placeholder": "Show another side of your life."
    },
    {
      "id": "favoritePeople",
      "title": "My favorite people know me as",
      "placeholder": "A small detail friends would recognize."
    },
    {
      "id": "weekendEnergy",
      "title": "Weekend energy",
      "placeholder": "What does this photo say about your weekends?"
    },
    {
      "id": "captionThis",
      "title": "Caption this",
      "placeholder": "Give people an easy opening line."
    }
  ]
} as const;

export const profilePromptLimits = {
  "maxAnswers": 3,
  "maxPromptIdLength": 80,
  "maxPromptTitleLength": 140,
  "maxAnswerLength": 300
} as const;

export const photoPromptLimits = {
  "maxCaptions": 6,
  "maxPromptIdLength": 80,
  "maxPromptTitleLength": 140,
  "maxCaptionLength": 140
} as const;

export const defaultProfilePromptIds = [
  "perfectRun",
  "afterRun",
  "greenFlag"
] as const;
