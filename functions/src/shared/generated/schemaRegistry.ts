/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

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
} as const;

export const uploadedPhotoSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/embedded/uploaded_photo.schema.json",
  "title": "UploadedPhoto",
  "description": "Canonical uploaded image object for ordered media galleries, logos, and event photos.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "id",
    "url",
    "storagePath",
    "thumbnailUrl",
    "thumbnailStoragePath",
    "position",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "id": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "pattern": "^[A-Za-z0-9_-]+$"
    },
    "url": {
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
    "thumbnailUrl": {
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
    "thumbnailStoragePath": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 512,
          "pattern": "^[^/\\u0000][^\\u0000]*$"
        },
        {
          "type": "null"
        }
      ]
    },
    "position": {
      "type": "integer",
      "minimum": 0,
      "maximum": 19
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
  }
} as const;

export const activityPreferencesSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/embedded/activity_preferences.schema.json",
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
  }
} as const;

export const configCitiesDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/config_cities.schema.json",
  "title": "ConfigCitiesDocument",
  "description": "Public launch-market configuration stored at config/cities. The app picks from launched markets; canonical market ids disambiguate same-name cities globally.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "config_cities",
  "x-firestore-path": "config/cities",
  "x-document-id-field": "cities",
  "x-owner": "admin city configuration tooling",
  "required": [
    "version",
    "cityNames",
    "marketIds",
    "launchMarketIds",
    "cities",
    "markets"
  ],
  "definitions": {
    "launchStatus": {
      "type": "string",
      "enum": [
        "launched",
        "planned",
        "paused",
        "retired"
      ]
    },
    "cityPickerMarket": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "name",
        "cityId",
        "marketId",
        "slug",
        "label",
        "latitude",
        "longitude",
        "countryIsoCode",
        "currencyCode",
        "dialCode",
        "timeZone",
        "launchStatus",
        "profileSelectable",
        "hostCreatable",
        "eventCreatable",
        "exploreVisible"
      ],
      "properties": {
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120,
          "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$",
          "description": "App-facing selection id. Kept as name for existing CityData JSON, but stores the canonical market id."
        },
        "cityId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120,
          "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
        },
        "marketId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120,
          "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
        },
        "slug": {
          "type": "string",
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
          "type": "number",
          "minimum": -90,
          "maximum": 90
        },
        "longitude": {
          "type": "number",
          "minimum": -180,
          "maximum": 180
        },
        "countryIsoCode": {
          "type": "string",
          "pattern": "^[A-Z]{2}$"
        },
        "currencyCode": {
          "type": "string",
          "pattern": "^[A-Z]{3}$"
        },
        "dialCode": {
          "type": "string",
          "pattern": "^\\+\\d{1,4}$"
        },
        "timeZone": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80
        },
        "launchStatus": {
          "type": "string",
          "enum": [
            "launched",
            "planned",
            "paused",
            "retired"
          ]
        },
        "profileSelectable": {
          "type": "boolean"
        },
        "hostCreatable": {
          "type": "boolean"
        },
        "eventCreatable": {
          "type": "boolean"
        },
        "exploreVisible": {
          "type": "boolean"
        }
      }
    },
    "canonicalMarket": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "marketId",
        "cityId",
        "slug",
        "label",
        "cityLabel",
        "regionCode",
        "regionName",
        "countryIsoCode",
        "countryName",
        "currencyCode",
        "dialCode",
        "timeZone",
        "latitude",
        "longitude",
        "aliases",
        "launchStatus",
        "profileSelectable",
        "hostCreatable",
        "eventCreatable",
        "exploreVisible"
      ],
      "properties": {
        "marketId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120,
          "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
        },
        "cityId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120,
          "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
        },
        "slug": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80,
          "pattern": "^[a-z0-9-]+$"
        },
        "label": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80
        },
        "cityLabel": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80
        },
        "regionCode": {
          "type": "string",
          "minLength": 1,
          "maxLength": 16,
          "pattern": "^[A-Z0-9-]+$"
        },
        "regionName": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "countryIsoCode": {
          "type": "string",
          "pattern": "^[A-Z]{2}$"
        },
        "countryName": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "currencyCode": {
          "type": "string",
          "pattern": "^[A-Z]{3}$"
        },
        "dialCode": {
          "type": "string",
          "pattern": "^\\+\\d{1,4}$"
        },
        "timeZone": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80
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
        },
        "aliases": {
          "type": "array",
          "maxItems": 40,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80,
            "pattern": "^[a-z0-9-]+$"
          }
        },
        "launchStatus": {
          "type": "string",
          "enum": [
            "launched",
            "planned",
            "paused",
            "retired"
          ]
        },
        "profileSelectable": {
          "type": "boolean"
        },
        "hostCreatable": {
          "type": "boolean"
        },
        "eventCreatable": {
          "type": "boolean"
        },
        "exploreVisible": {
          "type": "boolean"
        }
      }
    }
  },
  "properties": {
    "version": {
      "type": "integer",
      "minimum": 2
    },
    "cityNames": {
      "type": "array",
      "description": "Compatibility whitelist used by Firestore rules. Values are launched canonical market ids, not display city names.",
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 120,
        "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
      },
      "minItems": 1,
      "uniqueItems": true,
      "x-catch-ownership": "server-only"
    },
    "marketIds": {
      "type": "array",
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 120,
        "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
      },
      "minItems": 1,
      "uniqueItems": true,
      "x-catch-ownership": "server-only"
    },
    "launchMarketIds": {
      "type": "array",
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 120,
        "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
      },
      "minItems": 1,
      "uniqueItems": true,
      "x-catch-ownership": "server-only"
    },
    "cities": {
      "type": "array",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "name",
          "cityId",
          "marketId",
          "slug",
          "label",
          "latitude",
          "longitude",
          "countryIsoCode",
          "currencyCode",
          "dialCode",
          "timeZone",
          "launchStatus",
          "profileSelectable",
          "hostCreatable",
          "eventCreatable",
          "exploreVisible"
        ],
        "properties": {
          "name": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120,
            "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$",
            "description": "App-facing selection id. Kept as name for existing CityData JSON, but stores the canonical market id."
          },
          "cityId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120,
            "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
          },
          "marketId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120,
            "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
          },
          "slug": {
            "type": "string",
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
            "type": "number",
            "minimum": -90,
            "maximum": 90
          },
          "longitude": {
            "type": "number",
            "minimum": -180,
            "maximum": 180
          },
          "countryIsoCode": {
            "type": "string",
            "pattern": "^[A-Z]{2}$"
          },
          "currencyCode": {
            "type": "string",
            "pattern": "^[A-Z]{3}$"
          },
          "dialCode": {
            "type": "string",
            "pattern": "^\\+\\d{1,4}$"
          },
          "timeZone": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "launchStatus": {
            "type": "string",
            "enum": [
              "launched",
              "planned",
              "paused",
              "retired"
            ]
          },
          "profileSelectable": {
            "type": "boolean"
          },
          "hostCreatable": {
            "type": "boolean"
          },
          "eventCreatable": {
            "type": "boolean"
          },
          "exploreVisible": {
            "type": "boolean"
          }
        }
      },
      "uniqueItems": true,
      "x-catch-ownership": "server-only"
    },
    "markets": {
      "type": "array",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "marketId",
          "cityId",
          "slug",
          "label",
          "cityLabel",
          "regionCode",
          "regionName",
          "countryIsoCode",
          "countryName",
          "currencyCode",
          "dialCode",
          "timeZone",
          "latitude",
          "longitude",
          "aliases",
          "launchStatus",
          "profileSelectable",
          "hostCreatable",
          "eventCreatable",
          "exploreVisible"
        ],
        "properties": {
          "marketId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120,
            "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
          },
          "cityId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120,
            "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
          },
          "slug": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80,
            "pattern": "^[a-z0-9-]+$"
          },
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "cityLabel": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "regionCode": {
            "type": "string",
            "minLength": 1,
            "maxLength": 16,
            "pattern": "^[A-Z0-9-]+$"
          },
          "regionName": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "countryIsoCode": {
            "type": "string",
            "pattern": "^[A-Z]{2}$"
          },
          "countryName": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "currencyCode": {
            "type": "string",
            "pattern": "^[A-Z]{3}$"
          },
          "dialCode": {
            "type": "string",
            "pattern": "^\\+\\d{1,4}$"
          },
          "timeZone": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
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
          },
          "aliases": {
            "type": "array",
            "maxItems": 40,
            "uniqueItems": true,
            "items": {
              "type": "string",
              "minLength": 1,
              "maxLength": 80,
              "pattern": "^[a-z0-9-]+$"
            }
          },
          "launchStatus": {
            "type": "string",
            "enum": [
              "launched",
              "planned",
              "paused",
              "retired"
            ]
          },
          "profileSelectable": {
            "type": "boolean"
          },
          "hostCreatable": {
            "type": "boolean"
          },
          "eventCreatable": {
            "type": "boolean"
          },
          "exploreVisible": {
            "type": "boolean"
          }
        }
      },
      "minItems": 1,
      "uniqueItems": true,
      "x-catch-ownership": "server-only"
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
      "minimum": 0,
      "x-catch-ownership": "client-writable"
    },
    "draftVersion": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "client-writable"
    },
    "firstName": {
      "type": "string",
      "maxLength": 80,
      "x-catch-ownership": "client-writable"
    },
    "lastName": {
      "type": "string",
      "maxLength": 80,
      "x-catch-ownership": "client-writable"
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
      ],
      "x-catch-ownership": "client-writable"
    },
    "phoneNumber": {
      "type": "string",
      "maxLength": 32,
      "x-catch-ownership": "client-writable"
    },
    "countryCode": {
      "type": "string",
      "maxLength": 8,
      "x-catch-ownership": "client-writable"
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
      ],
      "x-catch-ownership": "client-writable"
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
      "uniqueItems": true,
      "x-catch-ownership": "client-writable"
    },
    "instagramHandle": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 80,
      "x-catch-ownership": "client-writable"
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
      "maxItems": 3,
      "x-catch-ownership": "client-writable"
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
    "profilePhotos",
    "interestedInGenders",
    "minAgePreference",
    "maxAgePreference",
    "languages",
    "activityPreferences",
    "prefsNewCatches",
    "prefsMessages",
    "prefsEventReminders",
    "prefsRunStatusUpdates",
    "prefsClubUpdates",
    "prefsWeeklyDigest",
    "prefsShowOnMap"
  ],
  "properties": {
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "x-catch-ownership": "client-writable"
    },
    "firstName": {
      "type": "string",
      "maxLength": 80,
      "x-catch-ownership": "client-writable"
    },
    "lastName": {
      "type": "string",
      "maxLength": 80,
      "x-catch-ownership": "client-writable"
    },
    "displayName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80,
      "pattern": ".*\\S.*",
      "x-catch-ownership": "client-writable"
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
      },
      "x-catch-ownership": "client-writable"
    },
    "gender": {
      "type": "string",
      "enum": [
        "man",
        "woman",
        "nonBinary",
        "other"
      ],
      "x-catch-ownership": "client-writable"
    },
    "phoneNumber": {
      "type": "string",
      "minLength": 1,
      "maxLength": 32,
      "x-catch-ownership": "client-writable"
    },
    "countryCode": {
      "type": "string",
      "pattern": "^\\+\\d{1,4}$",
      "x-catch-ownership": "client-writable"
    },
    "profileComplete": {
      "type": "boolean",
      "x-catch-ownership": "client-writable"
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
      ],
      "x-catch-ownership": "client-writable"
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
      ],
      "x-catch-ownership": "client-writable"
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
      "x-catch-ownership": "client-writable"
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
      "x-catch-ownership": "client-writable"
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
      "x-catch-ownership": "client-writable"
    },
    "latitude": {
      "type": [
        "number",
        "null"
      ],
      "minimum": -90,
      "maximum": 90,
      "x-catch-ownership": "client-writable"
    },
    "longitude": {
      "type": [
        "number",
        "null"
      ],
      "minimum": -180,
      "maximum": 180,
      "x-catch-ownership": "client-writable"
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
      },
      "x-catch-ownership": "client-writable"
    },
    "minAgePreference": {
      "type": "integer",
      "minimum": 18,
      "maximum": 99,
      "x-catch-ownership": "client-writable"
    },
    "maxAgePreference": {
      "type": "integer",
      "minimum": 18,
      "maximum": 99,
      "x-catch-ownership": "client-writable"
    },
    "height": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 120,
      "maximum": 220,
      "x-catch-ownership": "client-writable"
    },
    "occupation": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 120,
      "x-catch-ownership": "client-writable"
    },
    "company": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 120,
      "x-catch-ownership": "client-writable"
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
      "x-catch-ownership": "client-writable"
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
      "x-catch-ownership": "client-writable"
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
      "x-catch-ownership": "client-writable"
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
      "x-catch-ownership": "client-writable"
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
      "x-catch-ownership": "client-writable"
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
      "x-catch-ownership": "client-writable"
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
      "x-catch-ownership": "client-writable"
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
      "x-catch-ownership": "client-writable"
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
      "x-catch-ownership": "client-writable"
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
      "x-catch-ownership": "client-writable"
    },
    "prefsNewCatches": {
      "type": "boolean",
      "x-catch-ownership": "client-writable"
    },
    "prefsMessages": {
      "type": "boolean",
      "x-catch-ownership": "client-writable"
    },
    "prefsEventReminders": {
      "type": "boolean",
      "x-catch-ownership": "client-writable"
    },
    "prefsRunStatusUpdates": {
      "type": "boolean",
      "x-catch-ownership": "client-writable"
    },
    "prefsClubUpdates": {
      "type": "boolean",
      "x-catch-ownership": "client-writable"
    },
    "prefsWeeklyDigest": {
      "type": "boolean",
      "x-catch-ownership": "client-writable"
    },
    "prefsShowOnMap": {
      "type": "boolean",
      "x-catch-ownership": "client-writable"
    },
    "fcmToken": {
      "type": "string",
      "x-catch-ownership": "client-runtime-writable"
    },
    "deleted": {
      "type": "boolean",
      "x-catch-ownership": "server-only"
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
      ],
      "x-catch-ownership": "server-only"
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

export const hostProfileDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/host_profiles.schema.json",
  "title": "HostProfileDocument",
  "description": "Professional host identity stored at hostProfiles/{uid}. This document is separate from users/{uid} dating profile data and publicProfiles/{uid}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "hostProfiles",
  "x-firestore-path": "hostProfiles/{uid}",
  "x-document-id-field": "uid",
  "x-owner": "owner direct write, callable seeded during host club operations",
  "required": [
    "displayName",
    "status",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "displayName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80,
      "pattern": ".*\\S.*",
      "description": "Professional display name for host, club, event, and support-chat surfaces."
    },
    "avatarUrl": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 2048,
      "description": "Professional host avatar or organization logo URL."
    },
    "roleTitle": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 80,
      "description": "Professional title such as Founder, Coach, Organizer, or Community Lead."
    },
    "bio": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 500,
      "description": "Professional host bio. Must not mirror dating-profile prompts."
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "pending",
        "suspended"
      ]
    },
    "verified": {
      "type": "boolean"
    },
    "linkedClubIds": {
      "type": "array",
      "maxItems": 20,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 160
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
  }
} as const;

export const clubDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/clubs.schema.json",
  "title": "ClubDocument",
  "description": "Canonical club document stored at clubs/{clubId}. The club id is the document id and is not stored in document data.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "clubs",
  "x-firestore-path": "clubs/{clubId}",
  "x-document-id-field": "id",
  "x-owner": "create/update/archive/delete club callables; aggregate projections are trigger-owned",
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
    "locationCityId",
    "locationMarketId",
    "area",
    "hostUserId",
    "hostName",
    "hostAvatarUrl",
    "ownerUserId",
    "hostUserIds",
    "hostProfiles",
    "createdAt",
    "imageUrl",
    "profileImageUrl",
    "tags",
    "memberCount",
    "rating",
    "reviewCount",
    "nextEventAt",
    "nextEventLabel",
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
      "maxLength": 120,
      "x-catch-ownership": "callable-owned"
    },
    "description": {
      "type": "string",
      "minLength": 1,
      "maxLength": 2000,
      "x-catch-ownership": "callable-owned"
    },
    "location": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$",
      "description": "Canonical launch market id. Public URL slugs live under publicPage.citySlug.",
      "x-catch-ownership": "callable-owned"
    },
    "locationCityId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$",
      "x-catch-ownership": "callable-owned"
    },
    "locationMarketId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$",
      "x-catch-ownership": "callable-owned"
    },
    "area": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "x-catch-ownership": "callable-owned"
    },
    "hostUserId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ],
      "description": "Legacy primary host user id. Null for programmatically generated, unclaimed organizer profiles.",
      "x-catch-ownership": "callable-owned"
    },
    "hostName": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 120,
      "description": "Legacy host display projection. Null when the organizer has not been claimed by a Catch user.",
      "x-catch-ownership": "callable-owned"
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
      ],
      "x-catch-ownership": "callable-owned"
    },
    "ownerUserId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ],
      "description": "Canonical owner user id after claim or user-created setup. Null for unclaimed programmatic profiles.",
      "x-catch-ownership": "callable-owned"
    },
    "hostUserIds": {
      "type": "array",
      "maxItems": 20,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      },
      "x-catch-ownership": "callable-owned"
    },
    "hostProfiles": {
      "type": "array",
      "maxItems": 20,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "uid",
          "displayName",
          "avatarUrl",
          "role"
        ],
        "properties": {
          "uid": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "displayName": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "avatarUrl": {
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
          "role": {
            "type": "string",
            "enum": [
              "owner",
              "host"
            ]
          }
        }
      },
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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
      ],
      "x-catch-ownership": "callable-owned"
    },
    "profileImageUrl": {
      "anyOf": [
        {
          "type": "string",
          "format": "uri",
          "maxLength": 2048
        },
        {
          "type": "null"
        }
      ],
      "x-catch-ownership": "callable-owned"
    },
    "clubPhotos": {
      "type": "array",
      "maxItems": 12,
      "items": {
        "title": "UploadedPhoto",
        "description": "Canonical uploaded image object for ordered media galleries, logos, and event photos.",
        "type": "object",
        "additionalProperties": false,
        "required": [
          "id",
          "url",
          "storagePath",
          "thumbnailUrl",
          "thumbnailStoragePath",
          "position",
          "createdAt",
          "updatedAt"
        ],
        "properties": {
          "id": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120,
            "pattern": "^[A-Za-z0-9_-]+$"
          },
          "url": {
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
          "thumbnailUrl": {
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
          "thumbnailStoragePath": {
            "anyOf": [
              {
                "type": "string",
                "minLength": 1,
                "maxLength": 512,
                "pattern": "^[^/\\u0000][^\\u0000]*$"
              },
              {
                "type": "null"
              }
            ]
          },
          "position": {
            "type": "integer",
            "minimum": 0,
            "maximum": 19
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
        }
      },
      "x-catch-ownership": "callable-owned"
    },
    "logoPhoto": {
      "anyOf": [
        {
          "title": "UploadedPhoto",
          "description": "Canonical uploaded image object for ordered media galleries, logos, and event photos.",
          "type": "object",
          "additionalProperties": false,
          "required": [
            "id",
            "url",
            "storagePath",
            "thumbnailUrl",
            "thumbnailStoragePath",
            "position",
            "createdAt",
            "updatedAt"
          ],
          "properties": {
            "id": {
              "type": "string",
              "minLength": 1,
              "maxLength": 120,
              "pattern": "^[A-Za-z0-9_-]+$"
            },
            "url": {
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
            "thumbnailUrl": {
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
            "thumbnailStoragePath": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 512,
                  "pattern": "^[^/\\u0000][^\\u0000]*$"
                },
                {
                  "type": "null"
                }
              ]
            },
            "position": {
              "type": "integer",
              "minimum": 0,
              "maximum": 19
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
          }
        },
        {
          "type": "null"
        }
      ],
      "x-catch-ownership": "callable-owned"
    },
    "tags": {
      "type": "array",
      "maxItems": 20,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 80
      },
      "x-catch-ownership": "callable-owned"
    },
    "memberCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "trigger-owned"
    },
    "rating": {
      "type": "number",
      "minimum": 0,
      "maximum": 5,
      "x-catch-ownership": "trigger-owned"
    },
    "reviewCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "trigger-owned"
    },
    "verifiedReviewCount": {
      "type": "integer",
      "minimum": 0,
      "description": "Published reviews that are verified (attended a Catch event). Only these back the headline rating; unverified public reviews cannot move the score.",
      "x-catch-ownership": "trigger-owned"
    },
    "nextEventAt": {
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
      ],
      "x-catch-ownership": "trigger-owned"
    },
    "nextEventLabel": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 240,
      "x-catch-ownership": "trigger-owned"
    },
    "instagramHandle": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 320,
      "x-catch-ownership": "callable-owned"
    },
    "phoneNumber": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 320,
      "x-catch-ownership": "callable-owned"
    },
    "email": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 320,
      "x-catch-ownership": "callable-owned"
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "archived"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "archived": {
      "type": "boolean",
      "x-catch-ownership": "callable-owned"
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
      ],
      "x-catch-ownership": "callable-owned"
    },
    "archiveReason": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 500,
      "x-catch-ownership": "callable-owned"
    },
    "hostDefaults": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "primaryActivityKind": {
          "type": "string",
          "enum": [
            "socialRun",
            "running",
            "walking",
            "pickleball",
            "padel",
            "tennis",
            "badminton",
            "cycling",
            "spinClass",
            "yoga",
            "strengthTraining",
            "pubQuiz",
            "barCrawl",
            "dinner",
            "singlesMixer",
            "openActivity"
          ]
        },
        "supportedActivityKinds": {
          "type": "array",
          "maxItems": 16,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "enum": [
              "socialRun",
              "running",
              "walking",
              "pickleball",
              "padel",
              "tennis",
              "badminton",
              "cycling",
              "spinClass",
              "yoga",
              "strengthTraining",
              "pubQuiz",
              "barCrawl",
              "dinner",
              "singlesMixer",
              "openActivity"
            ]
          }
        },
        "eventPolicy": {
          "type": "object",
          "additionalProperties": false,
          "properties": {
            "admissionPreset": {
              "type": "string",
              "enum": [
                "openCapacity",
                "inviteOnly",
                "balancedSingles",
                "fixedCohortCaps"
              ]
            },
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
            },
            "dynamicPricingEnabled": {
              "type": "boolean"
            },
            "dynamicPricingStepInPaise": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 0,
              "maximum": 100000000
            },
            "dynamicPricingMaxInPaise": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 0,
              "maximum": 100000000
            },
            "cancellationPolicyId": {
              "type": "string",
              "enum": [
                "flexible",
                "standard",
                "strict"
              ]
            }
          }
        },
        "eventSuccess": {
          "type": "object",
          "additionalProperties": false,
          "properties": {
            "enabled": {
              "type": "boolean"
            },
            "playbookId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 120
            },
            "selectedModuleIds": {
              "type": "array",
              "maxItems": 24,
              "items": {
                "type": "string",
                "minLength": 1,
                "maxLength": 120
              }
            },
            "structureConfig": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "unitKind",
                "unitSize",
                "revealCountdownSeconds"
              ],
              "properties": {
                "unitKind": {
                  "type": "string",
                  "enum": [
                    "wholeGroup",
                    "pods",
                    "pairs",
                    "teams",
                    "tables"
                  ]
                },
                "unitSize": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 1000
                },
                "unitCount": {
                  "type": [
                    "integer",
                    "null"
                  ],
                  "minimum": 1,
                  "maximum": 200
                },
                "rotationIntervalMinutes": {
                  "type": [
                    "integer",
                    "null"
                  ],
                  "minimum": 5,
                  "maximum": 180
                },
                "revealCountdownSeconds": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 60
                },
                "rotationRepeatStrategy": {
                  "type": "string",
                  "enum": [
                    "avoid",
                    "allowWhenExhausted"
                  ]
                },
                "maxPairMeetings": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 10
                },
                "balanceActivityAttributes": {
                  "type": "array",
                  "maxItems": 8,
                  "uniqueItems": true,
                  "items": {
                    "type": "string",
                    "enum": [
                      "paceBand",
                      "skillBand",
                      "roleBand"
                    ]
                  }
                },
                "clusterActivityAttributes": {
                  "type": "array",
                  "maxItems": 8,
                  "uniqueItems": true,
                  "items": {
                    "type": "string",
                    "enum": [
                      "paceBand",
                      "skillBand",
                      "roleBand"
                    ]
                  }
                }
              }
            },
            "hostGoal": {
              "type": "string",
              "maxLength": 300
            },
            "wingmanRequestsEnabled": {
              "type": "boolean"
            },
            "contextualOpenersEnabled": {
              "type": "boolean"
            },
            "compatibilityAffectsRanking": {
              "type": "boolean"
            },
            "questionnaireConfig": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "templateId"
              ],
              "properties": {
                "templateId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 120
                },
                "customTitle": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "maxLength": 80
                },
                "customQuestions": {
                  "type": "array",
                  "maxItems": 8,
                  "items": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "id",
                      "prompt",
                      "options"
                    ],
                    "properties": {
                      "id": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 120
                      },
                      "prompt": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 140
                      },
                      "options": {
                        "type": "array",
                        "minItems": 2,
                        "maxItems": 5,
                        "items": {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "id",
                            "label"
                          ],
                          "properties": {
                            "id": {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 120
                            },
                            "label": {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 80
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            },
            "attendeePrompt": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 300
            }
          }
        },
        "eventSuccessByActivityKind": {
          "type": "object",
          "maxProperties": 16,
          "additionalProperties": {
            "type": "object",
            "additionalProperties": false,
            "properties": {
              "enabled": {
                "type": "boolean"
              },
              "playbookId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 120
              },
              "selectedModuleIds": {
                "type": "array",
                "maxItems": 24,
                "items": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 120
                }
              },
              "structureConfig": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "unitKind",
                  "unitSize",
                  "revealCountdownSeconds"
                ],
                "properties": {
                  "unitKind": {
                    "type": "string",
                    "enum": [
                      "wholeGroup",
                      "pods",
                      "pairs",
                      "teams",
                      "tables"
                    ]
                  },
                  "unitSize": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 1000
                  },
                  "unitCount": {
                    "type": [
                      "integer",
                      "null"
                    ],
                    "minimum": 1,
                    "maximum": 200
                  },
                  "rotationIntervalMinutes": {
                    "type": [
                      "integer",
                      "null"
                    ],
                    "minimum": 5,
                    "maximum": 180
                  },
                  "revealCountdownSeconds": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 60
                  },
                  "rotationRepeatStrategy": {
                    "type": "string",
                    "enum": [
                      "avoid",
                      "allowWhenExhausted"
                    ]
                  },
                  "maxPairMeetings": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 10
                  },
                  "balanceActivityAttributes": {
                    "type": "array",
                    "maxItems": 8,
                    "uniqueItems": true,
                    "items": {
                      "type": "string",
                      "enum": [
                        "paceBand",
                        "skillBand",
                        "roleBand"
                      ]
                    }
                  },
                  "clusterActivityAttributes": {
                    "type": "array",
                    "maxItems": 8,
                    "uniqueItems": true,
                    "items": {
                      "type": "string",
                      "enum": [
                        "paceBand",
                        "skillBand",
                        "roleBand"
                      ]
                    }
                  }
                }
              },
              "hostGoal": {
                "type": "string",
                "maxLength": 300
              },
              "wingmanRequestsEnabled": {
                "type": "boolean"
              },
              "contextualOpenersEnabled": {
                "type": "boolean"
              },
              "compatibilityAffectsRanking": {
                "type": "boolean"
              },
              "questionnaireConfig": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "templateId"
                ],
                "properties": {
                  "templateId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 120
                  },
                  "customTitle": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "maxLength": 80
                  },
                  "customQuestions": {
                    "type": "array",
                    "maxItems": 8,
                    "items": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "id",
                        "prompt",
                        "options"
                      ],
                      "properties": {
                        "id": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 120
                        },
                        "prompt": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 140
                        },
                        "options": {
                          "type": "array",
                          "minItems": 2,
                          "maxItems": 5,
                          "items": {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "id",
                              "label"
                            ],
                            "properties": {
                              "id": {
                                "type": "string",
                                "minLength": 1,
                                "maxLength": 120
                              },
                              "label": {
                                "type": "string",
                                "minLength": 1,
                                "maxLength": 80
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              },
              "attendeePrompt": {
                "type": [
                  "string",
                  "null"
                ],
                "maxLength": 300
              }
            }
          }
        }
      },
      "x-catch-ownership": "callable-owned"
    },
    "entityKind": {
      "type": "string",
      "enum": [
        "club",
        "venue",
        "eventOrganizer",
        "creatorCommunity",
        "brand"
      ],
      "description": "Broad organizer identity. Keeps clubs as one subtype rather than forcing every host into club nomenclature.",
      "x-catch-ownership": "callable-owned"
    },
    "entitySubtypes": {
      "type": "array",
      "maxItems": 20,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 80
      },
      "x-catch-ownership": "callable-owned"
    },
    "displayCategory": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 120,
      "description": "Reader-facing category label for web and discovery surfaces.",
      "x-catch-ownership": "callable-owned"
    },
    "cityName": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 120,
      "x-catch-ownership": "callable-owned"
    },
    "regionName": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 120,
      "x-catch-ownership": "callable-owned"
    },
    "countryCode": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^[A-Z]{2}$",
      "x-catch-ownership": "callable-owned"
    },
    "countryName": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 120,
      "x-catch-ownership": "callable-owned"
    },
    "appVisibility": {
      "type": "string",
      "enum": [
        "discoverable",
        "hidden"
      ],
      "description": "Whether the native app should show this organizer in browse surfaces. Scraped unclaimed profiles start hidden.",
      "x-catch-ownership": "callable-owned"
    },
    "ownership": {
      "type": "object",
      "additionalProperties": false,
      "description": "Claim-aware organizer ownership state. This is the forward-looking owner model; legacy host fields are maintained for app compatibility.",
      "required": [
        "state",
        "ownerUserId",
        "primaryHostUserId",
        "hostUserIds",
        "claimedAt",
        "claimedByUid"
      ],
      "properties": {
        "state": {
          "type": "string",
          "enum": [
            "programmatic",
            "userCreated",
            "claimed",
            "transferred"
          ]
        },
        "ownerUserId": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            {
              "type": "null"
            }
          ]
        },
        "primaryHostUserId": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            {
              "type": "null"
            }
          ]
        },
        "hostUserIds": {
          "type": "array",
          "maxItems": 20,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          }
        },
        "claimedAt": {
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
        "claimedByUid": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            {
              "type": "null"
            }
          ]
        }
      },
      "x-catch-ownership": "callable-owned"
    },
    "claim": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "state",
        "claimHref",
        "lastClaimRequestId"
      ],
      "properties": {
        "state": {
          "type": "string",
          "enum": [
            "unclaimed",
            "claimPending",
            "claimed",
            "verified",
            "suppressed"
          ]
        },
        "claimHref": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 240
        },
        "lastClaimRequestId": {
          "anyOf": [
            {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            {
              "type": "null"
            }
          ]
        }
      },
      "x-catch-ownership": "callable-owned"
    },
    "publicPage": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "slug",
        "citySlug",
        "canonicalPath",
        "publishStatus",
        "indexStatus",
        "robots",
        "seoTitle",
        "seoDescription",
        "lastRenderedAt"
      ],
      "properties": {
        "slug": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-z0-9-]+$"
        },
        "citySlug": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80,
          "pattern": "^[a-z0-9-]+$"
        },
        "canonicalPath": {
          "type": "string",
          "minLength": 1,
          "maxLength": 240
        },
        "publishStatus": {
          "type": "string",
          "enum": [
            "draft",
            "qa",
            "published",
            "suppressed",
            "removed"
          ]
        },
        "indexStatus": {
          "type": "string",
          "enum": [
            "noindex",
            "indexReady",
            "indexed"
          ]
        },
        "robots": {
          "type": "string",
          "enum": [
            "noindex, follow",
            "index, follow"
          ]
        },
        "seoTitle": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 120
        },
        "seoDescription": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 320
        },
        "lastRenderedAt": {
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
        "indexReview": {
          "type": [
            "object",
            "null"
          ],
          "additionalProperties": false,
          "required": [
            "reviewedAt",
            "reviewedByUid",
            "indexStatus",
            "checklist",
            "reviewNote"
          ],
          "properties": {
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
            "reviewedByUid": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            },
            "indexStatus": {
              "type": "string",
              "enum": [
                "noindex",
                "indexReady",
                "indexed"
              ]
            },
            "checklist": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "sourceEvidenceVerified",
                "mediaRightsVerified",
                "cadenceVerified",
                "ownerContactVerified"
              ],
              "properties": {
                "sourceEvidenceVerified": {
                  "type": "boolean"
                },
                "mediaRightsVerified": {
                  "type": "boolean"
                },
                "cadenceVerified": {
                  "type": "boolean"
                },
                "ownerContactVerified": {
                  "type": "boolean"
                }
              }
            },
            "reviewNote": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 1000
            }
          }
        }
      },
      "x-catch-ownership": "callable-owned"
    },
    "provenance": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "origin",
        "sourceConfidence",
        "verificationStatus",
        "lastVerifiedAt"
      ],
      "properties": {
        "origin": {
          "type": "string",
          "enum": [
            "userCreated",
            "scraper",
            "adminSeed",
            "import"
          ]
        },
        "sourceConfidence": {
          "type": "string",
          "enum": [
            "seedOnly",
            "low",
            "medium",
            "high",
            "ownerVerified"
          ]
        },
        "verificationStatus": {
          "type": "string",
          "enum": [
            "unverified",
            "sourceBacked",
            "ownerVerified"
          ]
        },
        "lastVerifiedAt": {
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
      "x-catch-ownership": "server-only"
    },
    "adminSearch": {
      "type": "object",
      "additionalProperties": false,
      "description": "Server-owned deterministic search projection used by admin organizer publishing. Rebuildable from canonical club fields; not consumed by the app.",
      "required": [
        "tokens",
        "sortKey",
        "updatedAt",
        "updatedBySource"
      ],
      "properties": {
        "tokens": {
          "type": "array",
          "maxItems": 120,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "minLength": 2,
            "maxLength": 80,
            "pattern": "^[a-z0-9-]+$"
          }
        },
        "sortKey": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-z0-9-]+(?:-[a-z0-9-]+)*$"
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
        "updatedBySource": {
          "type": "string",
          "enum": [
            "adminUpdateClubDetails",
            "adminSetClubIndexStatus",
            "adminOrganizerSearchBackfill"
          ]
        }
      },
      "x-catch-ownership": "server-only"
    },
    "publicProfile": {
      "type": "object",
      "additionalProperties": false,
      "description": "Public, owner-safe organizer listing content derived from sources or owner edits. Raw scrape snapshots belong in private evidence collections.",
      "properties": {
        "headline": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 160
        },
        "summary": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 800
        },
        "sourceSummary": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 800
        },
        "formats": {
          "type": "array",
          "maxItems": 12,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          }
        },
        "facts": {
          "type": "array",
          "maxItems": 20,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "label",
              "value"
            ],
            "properties": {
              "label": {
                "type": "string",
                "minLength": 1,
                "maxLength": 80
              },
              "value": {
                "type": "string",
                "minLength": 1,
                "maxLength": 240
              }
            }
          }
        },
        "fitNotes": {
          "type": "array",
          "maxItems": 8,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 400
          }
        },
        "missingEvidence": {
          "type": "array",
          "maxItems": 12,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 200
          }
        },
        "eventEvidence": {
          "type": "array",
          "maxItems": 12,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "title",
              "date",
              "location",
              "summary",
              "facts",
              "sourceLabel",
              "sourceHref"
            ],
            "properties": {
              "title": {
                "type": "string",
                "minLength": 1,
                "maxLength": 160
              },
              "date": {
                "type": "string",
                "minLength": 1,
                "maxLength": 120
              },
              "location": {
                "type": "string",
                "minLength": 1,
                "maxLength": 240
              },
              "summary": {
                "type": "string",
                "minLength": 1,
                "maxLength": 600
              },
              "facts": {
                "type": "array",
                "maxItems": 12,
                "items": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 240
                }
              },
              "sourceLabel": {
                "type": "string",
                "minLength": 1,
                "maxLength": 120
              },
              "sourceHref": {
                "type": "string",
                "format": "uri",
                "maxLength": 2048
              }
            }
          }
        }
      },
      "x-catch-ownership": "callable-owned"
    },
    "publicSources": {
      "type": "array",
      "maxItems": 20,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "type",
          "label",
          "detail",
          "href",
          "confidence",
          "lastCheckedAt"
        ],
        "properties": {
          "type": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "detail": {
            "type": "string",
            "minLength": 1,
            "maxLength": 600
          },
          "href": {
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
          "confidence": {
            "type": "string",
            "enum": [
              "low",
              "medium",
              "high"
            ]
          },
          "lastCheckedAt": {
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
      "x-catch-ownership": "server-only"
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

export const clubPostDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/club_posts.schema.json",
  "title": "ClubPostDocument",
  "description": "Canonical organizer post stored at clubs/{clubId}/posts/{postId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "club_posts",
  "x-firestore-path": "clubs/{clubId}/posts/{postId}",
  "x-document-id-field": "id",
  "x-owner": "createClubPost callable",
  "required": [
    "authorUid",
    "text",
    "audience",
    "createdAt",
    "status"
  ],
  "properties": {
    "authorUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "text": {
      "type": "string",
      "minLength": 1,
      "maxLength": 500,
      "x-catch-ownership": "callable-owned"
    },
    "photoPath": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 500,
      "x-catch-ownership": "callable-owned"
    },
    "eventId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "audience": {
      "type": "string",
      "enum": [
        "followers"
      ],
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "removed"
      ],
      "x-catch-ownership": "callable-owned"
    }
  }
} as const;

export const clubMembershipDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/club_memberships.schema.json",
  "title": "ClubMembershipDocument",
  "description": "Canonical club membership edge stored at clubMemberships/{membershipId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "clubMemberships",
  "x-firestore-path": "clubMemberships/{membershipId}",
  "x-document-id-field": "id",
  "x-owner": "club membership callables; parent member count is trigger-owned",
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
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "role": {
      "type": "string",
      "enum": [
        "owner",
        "host",
        "member"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "left",
        "deleted"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "pushNotificationsEnabled": {
      "type": "boolean",
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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
      ],
      "x-catch-ownership": "callable-owned"
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
      ],
      "x-catch-ownership": "callable-owned"
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

export const clubHostClaimDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/club_host_claims.schema.json",
  "title": "ClubHostClaimDocument",
  "description": "Server-owned singleton claim stored at clubHostClaims/{uid} to enforce one hosted club per user.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "clubHostClaims",
  "x-firestore-path": "clubHostClaims/{uid}",
  "x-document-id-field": "uid",
  "x-owner": "createClub callable",
  "required": [
    "uid",
    "clubId",
    "createdAt"
  ],
  "properties": {
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
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
      },
      "x-catch-ownership": "server-only"
    }
  }
} as const;

export const clubClaimRequestDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/club_claim_requests.schema.json",
  "title": "ClubClaimRequestDocument",
  "description": "Server-owned organizer listing claim request stored at clubClaimRequests/{requestId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "clubClaimRequests",
  "x-firestore-path": "clubClaimRequests/{requestId}",
  "x-document-id-field": "requestId",
  "x-owner": "requestClubClaim and adminDecideClubClaim callables",
  "required": [
    "requestId",
    "clubId",
    "requesterUid",
    "requesterName",
    "requesterRole",
    "businessEmail",
    "businessPhone",
    "proofUrls",
    "message",
    "status",
    "createdAt",
    "updatedAt",
    "decidedAt",
    "decidedByUid",
    "decisionReason",
    "previousRequestId"
  ],
  "properties": {
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "requesterUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "requesterName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "x-catch-ownership": "callable-owned"
    },
    "requesterRole": {
      "type": "string",
      "enum": [
        "owner",
        "founder",
        "manager",
        "marketer",
        "venueManager",
        "other"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "businessEmail": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 320,
      "x-catch-ownership": "callable-owned"
    },
    "businessPhone": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 32,
      "x-catch-ownership": "callable-owned"
    },
    "proofUrls": {
      "type": "array",
      "maxItems": 8,
      "items": {
        "type": "string",
        "format": "uri",
        "maxLength": 2048
      },
      "uniqueItems": true,
      "x-catch-ownership": "callable-owned"
    },
    "message": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000,
      "x-catch-ownership": "callable-owned"
    },
    "status": {
      "type": "string",
      "enum": [
        "pending",
        "approved",
        "rejected",
        "withdrawn",
        "superseded"
      ],
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
    },
    "decidedAt": {
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
      ],
      "x-catch-ownership": "callable-owned"
    },
    "decidedByUid": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ],
      "x-catch-ownership": "callable-owned"
    },
    "decisionReason": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000,
      "x-catch-ownership": "callable-owned"
    },
    "previousRequestId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ],
      "x-catch-ownership": "callable-owned"
    }
  }
} as const;

export const eventDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/events.schema.json",
  "title": "EventDocument",
  "description": "Canonical event document stored at events/{eventId}. The event id is the document id and is not stored in document data.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "events",
  "x-firestore-path": "events/{eventId}",
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
    "clubId",
    "startTime",
    "endTime",
    "meetingPoint",
    "meetingLocation",
    "startingPointLat",
    "startingPointLng",
    "locationDetails",
    "eventFormat",
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
    "genderCounts",
    "cohortCounts",
    "waitlistedCohortCounts",
    "discoveryMarketId",
    "discoveryCityName",
    "discoveryActivityKind",
    "discoveryGeoCell",
    "discoveryHasOpenSpots",
    "discoveryAvailability",
    "discoveryOpenCohorts",
    "discoveryWaitlistCohorts",
    "discoveryInviteRequired",
    "discoveryMembershipRequired",
    "discoveryManualApprovalRequired",
    "discoveryMinAge",
    "discoveryMaxAge"
  ],
  "properties": {
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
    },
    "meetingPoint": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240,
      "x-catch-ownership": "callable-owned"
    },
    "meetingLocation": {
      "type": "object",
      "additionalProperties": false,
      "description": "Canonical meeting location selected from Google Places or a manually pinned map coordinate.",
      "required": [
        "name",
        "latitude",
        "longitude"
      ],
      "properties": {
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 240
        },
        "address": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 500
        },
        "placeId": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 256
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
        },
        "notes": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 1000
        }
      },
      "x-catch-ownership": "callable-owned"
    },
    "startingPointLat": {
      "type": "number",
      "minimum": -90,
      "maximum": 90,
      "x-catch-ownership": "callable-owned"
    },
    "startingPointLng": {
      "type": "number",
      "minimum": -180,
      "maximum": 180,
      "x-catch-ownership": "callable-owned"
    },
    "locationDetails": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000,
      "x-catch-ownership": "callable-owned"
    },
    "photoUrl": {
      "anyOf": [
        {
          "type": "string",
          "format": "uri",
          "maxLength": 2048
        },
        {
          "type": "null"
        }
      ],
      "x-catch-ownership": "callable-owned"
    },
    "eventPhotos": {
      "type": "array",
      "maxItems": 12,
      "items": {
        "title": "UploadedPhoto",
        "description": "Canonical uploaded image object for ordered media galleries, logos, and event photos.",
        "type": "object",
        "additionalProperties": false,
        "required": [
          "id",
          "url",
          "storagePath",
          "thumbnailUrl",
          "thumbnailStoragePath",
          "position",
          "createdAt",
          "updatedAt"
        ],
        "properties": {
          "id": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120,
            "pattern": "^[A-Za-z0-9_-]+$"
          },
          "url": {
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
          "thumbnailUrl": {
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
          "thumbnailStoragePath": {
            "anyOf": [
              {
                "type": "string",
                "minLength": 1,
                "maxLength": 512,
                "pattern": "^[^/\\u0000][^\\u0000]*$"
              },
              {
                "type": "null"
              }
            ]
          },
          "position": {
            "type": "integer",
            "minimum": 0,
            "maximum": 19
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
        }
      },
      "x-catch-ownership": "callable-owned"
    },
    "distanceKm": {
      "type": "number",
      "minimum": 0,
      "maximum": 100,
      "x-catch-ownership": "callable-owned"
    },
    "eventFormat": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "version",
        "activityKind",
        "interactionModel"
      ],
      "properties": {
        "version": {
          "type": "integer",
          "const": 1
        },
        "activityKind": {
          "type": "string",
          "enum": [
            "socialRun",
            "running",
            "walking",
            "pickleball",
            "padel",
            "tennis",
            "badminton",
            "cycling",
            "spinClass",
            "yoga",
            "strengthTraining",
            "pubQuiz",
            "barCrawl",
            "dinner",
            "singlesMixer",
            "openActivity"
          ]
        },
        "interactionModel": {
          "type": "string",
          "enum": [
            "pacePods",
            "pairedRotations",
            "teamRotations",
            "seatedTable",
            "freeFormMixer",
            "hostLedProgram",
            "openFormat"
          ]
        },
        "customActivityLabel": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80
        },
        "defaultPlaybookId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "defaultModuleIds": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "maxItems": 30,
          "uniqueItems": true
        },
        "eventSuccessPrimitives": {
          "type": "object",
          "additionalProperties": false,
          "description": "Optional event-success behavior primitives for custom or unsupported activity formats. These fields translate a saved event format into the small set of primitives event success can reason about.",
          "properties": {
            "phoneAvailability": {
              "type": "string",
              "enum": [
                "continuous",
                "plannedPauses",
                "arrivalAndPostEventOnly",
                "hostOnlyLive",
                "noneDuringActivity"
              ]
            },
            "rotationSuitability": {
              "type": "string",
              "enum": [
                "none",
                "plannedBreaks",
                "continuousRounds"
              ]
            },
            "assignmentAlgorithm": {
              "type": "string",
              "enum": [
                "none",
                "pacePods",
                "socialPods",
                "pairRotations",
                "teamBalancer",
                "tableSeating"
              ]
            },
            "compatibilityPolicy": {
              "type": "string",
              "enum": [
                "none",
                "socialCohortBalance",
                "mutualInterestOnly",
                "questionnaireClueOnly"
              ]
            }
          }
        },
        "activityDetails": {
          "type": "object",
          "additionalProperties": true
        }
      },
      "x-catch-ownership": "callable-owned"
    },
    "pace": {
      "type": "string",
      "enum": [
        "easy",
        "moderate",
        "fast",
        "competitive"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "capacityLimit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000,
      "x-catch-ownership": "callable-owned"
    },
    "description": {
      "type": "string",
      "maxLength": 2000,
      "x-catch-ownership": "callable-owned"
    },
    "priceInPaise": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100000000,
      "x-catch-ownership": "callable-owned"
    },
    "currency": {
      "type": "string",
      "pattern": "^[A-Z]{3}$",
      "x-catch-ownership": "callable-owned"
    },
    "bookedCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "callable-owned"
    },
    "checkedInCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "callable-owned"
    },
    "waitlistedCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "callable-owned"
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "cancelled"
      ],
      "x-catch-ownership": "callable-owned"
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
      ],
      "x-catch-ownership": "callable-owned"
    },
    "cancellationReason": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 500,
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
    },
    "eventPolicy": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "version",
        "admission",
        "pricing",
        "cancellation",
        "settlement"
      ],
      "properties": {
        "version": {
          "type": "integer",
          "const": 1
        },
        "admission": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "format",
            "capacityLimit",
            "waitlistPolicy",
            "inviteRequired",
            "membershipRequired",
            "manualApprovalRequired",
            "privateAccessPolicy",
            "cohortCapacityLimits",
            "balancedRatioPolicy"
          ],
          "properties": {
            "format": {
              "type": "string",
              "enum": [
                "open",
                "inviteOnly",
                "manualApproval",
                "fixedCohortCaps",
                "balancedRatio",
                "membersOnly"
              ]
            },
            "capacityLimit": {
              "type": "integer",
              "minimum": 1,
              "maximum": 1000
            },
            "waitlistPolicy": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode",
                "offerWindowMinutes"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "enum": [
                    "disabled",
                    "rankedOffer",
                    "broadcastFirstComeFirstServed",
                    "manualReview"
                  ]
                },
                "offerWindowMinutes": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10080
                }
              }
            },
            "inviteRequired": {
              "type": "boolean"
            },
            "membershipRequired": {
              "type": "boolean"
            },
            "manualApprovalRequired": {
              "type": "boolean"
            },
            "privateAccessPolicy": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode",
                "inviteCodeHint",
                "privateLinkEnabled"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "enum": [
                    "none",
                    "inviteCode"
                  ]
                },
                "inviteCodeHint": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "maxLength": 64
                },
                "privateLinkEnabled": {
                  "type": "boolean"
                }
              }
            },
            "cohortCapacityLimits": {
              "type": "object",
              "additionalProperties": {
                "type": "integer",
                "minimum": 0
              }
            },
            "balancedRatioPolicy": {
              "type": [
                "object",
                "null"
              ],
              "additionalProperties": false,
              "required": [
                "leftCohortId",
                "rightCohortId",
                "maxSkew",
                "openingBufferPerCohort",
                "outOfRatioCohortPolicy"
              ],
              "properties": {
                "leftCohortId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 120
                },
                "rightCohortId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 120
                },
                "maxSkew": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 1000
                },
                "openingBufferPerCohort": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 1000
                },
                "outOfRatioCohortPolicy": {
                  "type": "string",
                  "enum": [
                    "admitWithinGeneralCapacity",
                    "waitlist",
                    "manualReview",
                    "reject"
                  ]
                }
              }
            }
          }
        },
        "pricing": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "basePriceInPaise",
            "cohortAdjustmentsInPaise",
            "demandPricingRules"
          ],
          "properties": {
            "basePriceInPaise": {
              "type": "integer",
              "minimum": 0,
              "maximum": 100000000
            },
            "cohortAdjustmentsInPaise": {
              "type": "object",
              "additionalProperties": {
                "type": "integer",
                "minimum": -100000000,
                "maximum": 100000000
              }
            },
            "demandPricingRules": {
              "type": "array",
              "maxItems": 20,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "pricedCohortId",
                  "balancingCohortId",
                  "stepAdjustmentInPaise",
                  "maxAdjustmentInPaise",
                  "freeSkew",
                  "demandStep"
                ],
                "properties": {
                  "pricedCohortId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 120
                  },
                  "balancingCohortId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 120
                  },
                  "stepAdjustmentInPaise": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 100000000
                  },
                  "maxAdjustmentInPaise": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 100000000
                  },
                  "freeSkew": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 1000
                  },
                  "demandStep": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 1000
                  }
                }
              }
            }
          }
        },
        "cancellation": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "policyId"
          ],
          "properties": {
            "policyId": {
              "type": "string",
              "enum": [
                "flexible",
                "standard",
                "strict"
              ]
            }
          }
        },
        "settlement": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "hostPayoutTiming"
          ],
          "properties": {
            "hostPayoutTiming": {
              "type": "string",
              "enum": [
                "afterEventCompletion"
              ]
            }
          }
        }
      },
      "x-catch-ownership": "callable-owned"
    },
    "genderCounts": {
      "type": "object",
      "additionalProperties": {
        "type": "integer",
        "minimum": 0
      },
      "x-catch-ownership": "callable-owned"
    },
    "cohortCounts": {
      "type": "object",
      "additionalProperties": {
        "type": "integer",
        "minimum": 0
      },
      "x-catch-ownership": "callable-owned"
    },
    "waitlistedCohortCounts": {
      "type": "object",
      "additionalProperties": {
        "type": "integer",
        "minimum": 0
      },
      "x-catch-ownership": "callable-owned"
    },
    "discoveryMarketId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$",
      "x-catch-ownership": "callable-owned"
    },
    "discoveryCityName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80,
      "pattern": "^[a-z0-9-]+$",
      "x-catch-ownership": "callable-owned"
    },
    "discoveryActivityKind": {
      "type": "string",
      "enum": [
        "socialRun",
        "running",
        "walking",
        "pickleball",
        "padel",
        "tennis",
        "badminton",
        "cycling",
        "spinClass",
        "yoga",
        "strengthTraining",
        "pubQuiz",
        "barCrawl",
        "dinner",
        "singlesMixer",
        "openActivity"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "discoveryGeoCell": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^-?\\d+:-?\\d+$",
      "x-catch-ownership": "callable-owned"
    },
    "discoveryHasOpenSpots": {
      "type": "boolean",
      "x-catch-ownership": "callable-owned"
    },
    "discoveryAvailability": {
      "type": "string",
      "enum": [
        "open",
        "waitlist",
        "gated",
        "full",
        "cancelled"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "discoveryOpenCohorts": {
      "type": "array",
      "maxItems": 4,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "enum": [
          "menInterestedInWomen",
          "womenInterestedInMen",
          "queerOrOpen",
          "nonBinaryOrOther"
        ]
      },
      "x-catch-ownership": "callable-owned"
    },
    "discoveryWaitlistCohorts": {
      "type": "array",
      "maxItems": 4,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "enum": [
          "menInterestedInWomen",
          "womenInterestedInMen",
          "queerOrOpen",
          "nonBinaryOrOther"
        ]
      },
      "x-catch-ownership": "callable-owned"
    },
    "discoveryInviteRequired": {
      "type": "boolean",
      "x-catch-ownership": "callable-owned"
    },
    "discoveryMembershipRequired": {
      "type": "boolean",
      "x-catch-ownership": "callable-owned"
    },
    "discoveryManualApprovalRequired": {
      "type": "boolean",
      "x-catch-ownership": "callable-owned"
    },
    "discoveryMinAge": {
      "type": "integer",
      "minimum": 0,
      "maximum": 120,
      "x-catch-ownership": "callable-owned"
    },
    "discoveryMaxAge": {
      "type": "integer",
      "minimum": 0,
      "maximum": 120,
      "x-catch-ownership": "callable-owned"
    },
    "adminSearch": {
      "type": "object",
      "additionalProperties": false,
      "description": "Server-owned deterministic search projection used by admin event publishing. Rebuildable from canonical event and organizer fields; not consumed by the app.",
      "required": [
        "tokens",
        "sortKey",
        "updatedAt",
        "updatedBySource"
      ],
      "properties": {
        "tokens": {
          "type": "array",
          "maxItems": 120,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "minLength": 2,
            "maxLength": 80,
            "pattern": "^[a-z0-9-]+$"
          }
        },
        "sortKey": {
          "type": "string",
          "minLength": 1,
          "maxLength": 160,
          "pattern": "^[a-z0-9-]+(?:-[a-z0-9-]+)*$"
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
        "updatedBySource": {
          "type": "string",
          "enum": [
            "adminUpdateEventDetails",
            "adminEventSearchBackfill"
          ]
        }
      },
      "x-catch-ownership": "server-only"
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

export const externalEventDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/external_events.schema.json",
  "title": "ExternalEventDocument",
  "description": "Read-only external event document stored at externalEvents/{eventId}. These records are sourced from reviewed organizer intake candidates and may link to external booking platforms, but they never enable Catch booking, payments, reservations, waitlists, attendance, or schedule locks.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "externalEvents",
  "x-firestore-path": "externalEvents/{eventId}",
  "x-document-id-field": "eventId",
  "x-owner": "organizer intake import tooling after admin review; external source corrections and takedowns are admin-owned",
  "required": [
    "schemaVersion",
    "eventId",
    "canonicalHostId",
    "compatibilityClubId",
    "title",
    "description",
    "startTime",
    "endTime",
    "timezone",
    "meetingPoint",
    "meetingLocation",
    "locationDetails",
    "photoUrl",
    "activity",
    "price",
    "status",
    "publicationStatus",
    "booking",
    "discovery",
    "dedupe",
    "externalSource",
    "review",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "canonicalHostId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "compatibilityClubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "title": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "description": {
      "type": "string",
      "minLength": 1,
      "maxLength": 4000
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
    "timezone": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 80
    },
    "meetingPoint": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "meetingLocation": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "name",
        "address",
        "placeId",
        "latitude",
        "longitude",
        "notes"
      ],
      "properties": {
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 240
        },
        "address": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 500
        },
        "placeId": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 256
        },
        "latitude": {
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
        "longitude": {
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
        "notes": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 1000
        }
      }
    },
    "locationDetails": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000
    },
    "photoUrl": {
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
    "activity": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "version",
        "activityKind",
        "interactionModel",
        "source"
      ],
      "properties": {
        "version": {
          "type": "integer",
          "const": 1
        },
        "activityKind": {
          "type": "string",
          "enum": [
            "socialRun",
            "running",
            "walking",
            "pickleball",
            "padel",
            "tennis",
            "badminton",
            "cycling",
            "spinClass",
            "yoga",
            "strengthTraining",
            "pubQuiz",
            "barCrawl",
            "dinner",
            "singlesMixer",
            "openActivity"
          ]
        },
        "interactionModel": {
          "type": "string",
          "enum": [
            "pacePods",
            "pairedRotations",
            "teamRotations",
            "seatedTable",
            "freeFormMixer",
            "hostLedProgram",
            "openFormat"
          ]
        },
        "source": {
          "type": "string",
          "enum": [
            "heuristic",
            "admin",
            "source"
          ]
        }
      }
    },
    "price": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "displayText",
        "parsedPriceInPaise",
        "currency"
      ],
      "properties": {
        "displayText": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 120
        },
        "parsedPriceInPaise": {
          "type": [
            "integer",
            "null"
          ],
          "minimum": 0,
          "maximum": 100000000
        },
        "currency": {
          "type": "string",
          "pattern": "^[A-Z]{3}$"
        }
      }
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "cancelled"
      ]
    },
    "publicationStatus": {
      "type": "string",
      "enum": [
        "draft",
        "public",
        "archived",
        "removed"
      ]
    },
    "booking": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "mode",
        "catchBookingEnabled",
        "catchPaymentsEnabled",
        "catchReservationsEnabled",
        "catchWaitlistEnabled",
        "externalLinks"
      ],
      "properties": {
        "mode": {
          "type": "string",
          "const": "external_outbound_only"
        },
        "catchBookingEnabled": {
          "type": "boolean",
          "const": false
        },
        "catchPaymentsEnabled": {
          "type": "boolean",
          "const": false
        },
        "catchReservationsEnabled": {
          "type": "boolean",
          "const": false
        },
        "catchWaitlistEnabled": {
          "type": "boolean",
          "const": false
        },
        "externalLinks": {
          "type": "array",
          "minItems": 1,
          "maxItems": 12,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "platform",
              "url",
              "linkType",
              "sourceEventKey",
              "candidateId",
              "primary"
            ],
            "properties": {
              "platform": {
                "type": "string",
                "enum": [
                  "bookMyShow",
                  "district",
                  "luma",
                  "partiful",
                  "sortMyScene"
                ]
              },
              "url": {
                "type": "string",
                "format": "uri",
                "maxLength": 2048
              },
              "linkType": {
                "type": "string",
                "enum": [
                  "booking_or_event_page",
                  "source_surface"
                ]
              },
              "sourceEventKey": {
                "type": "string",
                "minLength": 1,
                "maxLength": 240
              },
              "candidateId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 240
              },
              "primary": {
                "type": "boolean"
              }
            }
          }
        }
      }
    },
    "discovery": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "citySlug",
        "countryCode",
        "availability",
        "manualApprovalRequired"
      ],
      "properties": {
        "citySlug": {
          "anyOf": [
            {
              "type": [
                "string",
                "null"
              ],
              "minLength": 1,
              "maxLength": 80,
              "pattern": "^[a-z0-9-]+$"
            },
            {
              "type": "null"
            }
          ]
        },
        "countryCode": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 2,
          "maxLength": 2
        },
        "availability": {
          "type": "string",
          "const": "read_only_external"
        },
        "manualApprovalRequired": {
          "type": "boolean",
          "const": true
        }
      }
    },
    "dedupe": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "normalizedEventKey",
        "primaryCandidateId",
        "duplicateCandidateIds",
        "conflictPolicy"
      ],
      "properties": {
        "normalizedEventKey": {
          "type": "string",
          "minLength": 1,
          "maxLength": 500
        },
        "primaryCandidateId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 240
        },
        "duplicateCandidateIds": {
          "type": "array",
          "maxItems": 24,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 240
          }
        },
        "conflictPolicy": {
          "type": "string",
          "const": "single_read_only_event_with_multiple_outbound_links"
        }
      }
    },
    "externalSource": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "candidateId",
        "sourceEventKey",
        "sourceEventId",
        "platform",
        "eventUrl",
        "sourceUrl"
      ],
      "properties": {
        "candidateId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 240
        },
        "sourceEventKey": {
          "type": "string",
          "minLength": 1,
          "maxLength": 240
        },
        "sourceEventId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "platform": {
          "type": "string",
          "enum": [
            "bookMyShow",
            "district",
            "luma",
            "partiful",
            "sortMyScene"
          ]
        },
        "eventUrl": {
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
        "sourceUrl": {
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
        }
      }
    },
    "review": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "eventReviewBatchId",
        "reviewer",
        "decidedAt",
        "note",
        "importPolicyAcknowledged",
        "ownerSafeCopyReviewed"
      ],
      "properties": {
        "eventReviewBatchId": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 180
        },
        "reviewer": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 180
        },
        "decidedAt": {
          "type": [
            "string",
            "null"
          ],
          "pattern": "^\\d{4}-\\d{2}-\\d{2}$"
        },
        "note": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 1000
        },
        "importPolicyAcknowledged": {
          "type": "boolean"
        },
        "ownerSafeCopyReviewed": {
          "type": "boolean"
        }
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
  }
} as const;

export const eventPrivateAccessDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_private_access.schema.json",
  "title": "EventPrivateAccessDocument",
  "description": "Host-private access material for invite-only events stored at eventPrivateAccess/{eventId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventPrivateAccess",
  "x-firestore-path": "eventPrivateAccess/{eventId}",
  "x-document-id-field": "id",
  "x-owner": "createEvent callable; readable only by the host of the linked event",
  "required": [
    "eventId",
    "clubId",
    "inviteCode",
    "createdAt"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "inviteCode": {
      "type": "string",
      "minLength": 4,
      "maxLength": 64,
      "pattern": "^[A-Za-z0-9_-]+$",
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
    }
  }
} as const;

export const eventInviteLinkDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_invite_links.schema.json",
  "title": "EventInviteLinkDocument",
  "description": "Host-created named invite link stored at eventInviteLinks/{inviteLinkId}. The document tracks live attribution counters while preserving disabled links for historical reporting.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventInviteLinks",
  "x-firestore-path": "eventInviteLinks/{inviteLinkId}",
  "x-document-id-field": "id",
  "x-owner": "event invite link callables and event-success scorecard recomputation",
  "required": [
    "eventId",
    "clubId",
    "hostUid",
    "label",
    "source",
    "tokenHash",
    "openCount",
    "requestCount",
    "confirmedCount",
    "paidCount",
    "checkedInCount",
    "catcherCount",
    "matchCount",
    "chatStartedCount",
    "disabledAt",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "hostUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "label": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80,
      "x-catch-ownership": "callable-owned"
    },
    "source": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 80,
      "x-catch-ownership": "callable-owned"
    },
    "tokenHash": {
      "type": "string",
      "minLength": 64,
      "maxLength": 64,
      "pattern": "^[a-f0-9]{64}$",
      "x-catch-ownership": "callable-owned"
    },
    "openCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "callable-owned"
    },
    "requestCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "callable-owned"
    },
    "confirmedCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "callable-owned"
    },
    "paidCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "callable-owned"
    },
    "checkedInCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "callable-owned"
    },
    "catcherCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "trigger-owned"
    },
    "matchCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "trigger-owned"
    },
    "chatStartedCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "trigger-owned"
    },
    "disabledAt": {
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
      ],
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
    }
  }
} as const;

export const eventParticipationDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_participations.schema.json",
  "title": "EventParticipationDocument",
  "description": "Canonical event roster edge stored at eventParticipations/{participationId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventParticipations",
  "x-firestore-path": "eventParticipations/{participationId}",
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
    "eventId",
    "clubId",
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
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "status": {
      "type": "string",
      "enum": [
        "signedUp",
        "waitlisted",
        "attended",
        "cancelled",
        "deleted"
      ],
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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
      ],
      "x-catch-ownership": "callable-owned"
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
      ],
      "x-catch-ownership": "callable-owned"
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
      ],
      "x-catch-ownership": "callable-owned"
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
      ],
      "x-catch-ownership": "callable-owned"
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
      ],
      "x-catch-ownership": "callable-owned"
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
      ],
      "x-catch-ownership": "callable-owned"
    },
    "cohortAtSignup": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 120,
      "x-catch-ownership": "callable-owned"
    },
    "paymentId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "hostApprovalStatus": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "pending",
        "approved",
        "declined",
        null
      ],
      "description": "Manual-approval request state for request-to-join events. Null for regular waitlist edges.",
      "x-catch-ownership": "callable-owned"
    },
    "hostApprovalDecidedAt": {
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
      ],
      "x-catch-ownership": "callable-owned"
    },
    "hostApprovalDecidedBy": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "waitlistOfferStatus": {
      "anyOf": [
        {
          "type": "string",
          "enum": [
            "active",
            "accepted",
            "declined",
            "expired",
            "cancelled"
          ]
        },
        {
          "type": "null"
        }
      ],
      "description": "Mirror of the current waitlist offer state for cheap roster and attendee CTA reads.",
      "x-catch-ownership": "callable-owned"
    },
    "waitlistOfferedAt": {
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
      ],
      "x-catch-ownership": "callable-owned"
    },
    "waitlistOfferExpiresAt": {
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
      ],
      "x-catch-ownership": "callable-owned"
    },
    "waitlistOfferAcceptedAt": {
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
      ],
      "x-catch-ownership": "callable-owned"
    },
    "waitlistOfferId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 240,
      "x-catch-ownership": "callable-owned"
    },
    "inviteLinkId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "description": "Named host invite link that first attributed this participation, when present.",
      "x-catch-ownership": "callable-owned"
    },
    "inviteSource": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 80,
      "description": "Host-facing source label copied from the invite link for durable reporting.",
      "x-catch-ownership": "callable-owned"
    },
    "inviteCapturedAt": {
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
      ],
      "description": "Server time when invite attribution was first attached to the roster edge.",
      "x-catch-ownership": "callable-owned"
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

export const eventWaitlistOfferDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_waitlist_offers.schema.json",
  "title": "EventWaitlistOfferDocument",
  "description": "Server-owned waitlist offer stored at eventWaitlistOffers/{eventId_uid}. Offers reserve a waitlist slot until accepted, declined, expired, or cancelled.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventWaitlistOffers",
  "x-firestore-path": "eventWaitlistOffers/{offerId}",
  "x-document-id-field": "id",
  "x-owner": "waitlist offer callables and expiry scheduler",
  "x-internal-demo-fields": [
    "synthetic",
    "seedPrefix",
    "scenario",
    "demoOps",
    "demoOpsId",
    "demoOpsCommand"
  ],
  "required": [
    "eventId",
    "clubId",
    "uid",
    "cohortAtOffer",
    "status",
    "source",
    "offeredBy",
    "offeredAt",
    "expiresAt",
    "decidedAt",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "cohortAtOffer": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "x-catch-ownership": "callable-owned"
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "accepted",
        "declined",
        "expired",
        "cancelled"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "source": {
      "type": "string",
      "enum": [
        "host",
        "autoPromotion",
        "ratioBalancing",
        "cancellation"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "offeredBy": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "offeredAt": {
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
      },
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
    },
    "decidedAt": {
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
      ],
      "x-catch-ownership": "callable-owned"
    },
    "expiringNotifiedAt": {
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
      ],
      "x-catch-ownership": "callable-owned"
    },
    "inviteLinkId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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

export const eventSuccessPlanDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_success_plans.schema.json",
  "title": "EventSuccessPlanDocument",
  "description": "Host-owned live event-success setup stored at eventSuccessPlans/{eventId}. The event id is the document id and is also stored for cheap validation and reads.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventSuccessPlans",
  "x-firestore-path": "eventSuccessPlans/{eventId}",
  "x-document-id-field": "id",
  "x-owner": "club host direct write; event participants read",
  "x-internal-demo-fields": [
    "synthetic",
    "seedPrefix",
    "scenario",
    "demoOps",
    "demoOpsId",
    "demoOpsCommand"
  ],
  "required": [
    "eventId",
    "clubId",
    "playbookId",
    "selectedModuleIds",
    "targetAttendeeCount",
    "hostGoal",
    "wingmanRequestsEnabled",
    "contextualOpenersEnabled",
    "activeStepIndex",
    "status",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "playbookId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "x-catch-ownership": "callable-owned"
    },
    "selectedModuleIds": {
      "type": "array",
      "maxItems": 24,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 120
      },
      "x-catch-ownership": "callable-owned"
    },
    "targetAttendeeCount": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000,
      "x-catch-ownership": "callable-owned"
    },
    "structureConfig": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "unitKind",
        "unitSize",
        "revealCountdownSeconds"
      ],
      "properties": {
        "unitKind": {
          "type": "string",
          "enum": [
            "wholeGroup",
            "pods",
            "pairs",
            "teams",
            "tables"
          ]
        },
        "unitSize": {
          "type": "integer",
          "minimum": 1,
          "maximum": 1000
        },
        "unitCount": {
          "type": [
            "integer",
            "null"
          ],
          "minimum": 1,
          "maximum": 200
        },
        "rotationIntervalMinutes": {
          "type": [
            "integer",
            "null"
          ],
          "minimum": 5,
          "maximum": 180
        },
        "revealCountdownSeconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 60
        },
        "rotationRepeatStrategy": {
          "type": "string",
          "enum": [
            "avoid",
            "allowWhenExhausted"
          ]
        },
        "maxPairMeetings": {
          "type": "integer",
          "minimum": 1,
          "maximum": 10
        },
        "balanceActivityAttributes": {
          "type": "array",
          "maxItems": 8,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "enum": [
              "paceBand",
              "skillBand",
              "roleBand"
            ]
          }
        },
        "clusterActivityAttributes": {
          "type": "array",
          "maxItems": 8,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "enum": [
              "paceBand",
              "skillBand",
              "roleBand"
            ]
          }
        }
      },
      "x-catch-ownership": "callable-owned"
    },
    "hostGoal": {
      "type": "string",
      "maxLength": 300,
      "x-catch-ownership": "callable-owned"
    },
    "wingmanRequestsEnabled": {
      "type": "boolean",
      "x-catch-ownership": "callable-owned"
    },
    "contextualOpenersEnabled": {
      "type": "boolean",
      "x-catch-ownership": "callable-owned"
    },
    "compatibilityAffectsRanking": {
      "type": "boolean",
      "x-catch-ownership": "callable-owned"
    },
    "questionnaireConfig": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "templateId"
      ],
      "properties": {
        "templateId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "customTitle": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 80
        },
        "customQuestions": {
          "type": "array",
          "maxItems": 8,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "id",
              "prompt",
              "options"
            ],
            "properties": {
              "id": {
                "type": "string",
                "minLength": 1,
                "maxLength": 120
              },
              "prompt": {
                "type": "string",
                "minLength": 1,
                "maxLength": 140
              },
              "options": {
                "type": "array",
                "minItems": 2,
                "maxItems": 5,
                "items": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "id",
                    "label"
                  ],
                  "properties": {
                    "id": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 120
                    },
                    "label": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 80
                    }
                  }
                }
              }
            }
          }
        }
      },
      "x-catch-ownership": "callable-owned"
    },
    "activeStepIndex": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100,
      "x-catch-ownership": "callable-owned"
    },
    "status": {
      "type": "string",
      "enum": [
        "setup",
        "live",
        "complete"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "revealStatus": {
      "type": "string",
      "enum": [
        "idle",
        "countingDown",
        "revealed"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "activeRevealRoundIndex": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100,
      "x-catch-ownership": "callable-owned"
    },
    "revealStartedAt": {
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
      ],
      "x-catch-ownership": "callable-owned"
    },
    "attendeePrompt": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 300,
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
    },
    "frozenAt": {
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
      ],
      "x-catch-ownership": "callable-owned"
    },
    "completedAt": {
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
      ],
      "x-catch-ownership": "callable-owned"
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

export const eventSuccessFeedbackDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_success_feedback.schema.json",
  "title": "EventSuccessFeedbackDocument",
  "description": "Attendee-owned decomposed post-event feedback stored at eventSuccessFeedback/{eventId_uid}. Raw notes and safety concerns are private to the attendee and backend safety/coaching pipelines.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventSuccessFeedback",
  "x-firestore-path": "eventSuccessFeedback/{feedbackId}",
  "x-document-id-field": "id",
  "x-owner": "attendee direct write after attended event; attendee read; backend aggregate",
  "x-internal-demo-fields": [
    "synthetic",
    "seedPrefix",
    "scenario",
    "demoOps",
    "demoOpsId",
    "demoOpsCommand"
  ],
  "required": [
    "eventId",
    "clubId",
    "uid",
    "welcomeRating",
    "structureRating",
    "metNewPeopleCount",
    "safetyConcern",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "welcomeRating": {
      "type": "integer",
      "minimum": 1,
      "maximum": 5,
      "x-catch-ownership": "callable-owned"
    },
    "structureRating": {
      "type": "integer",
      "minimum": 1,
      "maximum": 5,
      "x-catch-ownership": "callable-owned"
    },
    "metNewPeopleCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100,
      "x-catch-ownership": "callable-owned"
    },
    "safetyConcern": {
      "type": "boolean",
      "x-catch-ownership": "callable-owned"
    },
    "privateNote": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 500,
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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

export const eventSuccessPreferenceDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_success_preferences.schema.json",
  "title": "EventSuccessPreferenceDocument",
  "description": "Attendee-owned opt-out preferences for live event guidance stored at eventSuccessPreferences/{eventId_uid}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventSuccessPreferences",
  "x-firestore-path": "eventSuccessPreferences/{preferenceId}",
  "x-document-id-field": "id",
  "x-owner": "attendee direct write while signed up or attended; host read for assignment generation context",
  "x-internal-demo-fields": [
    "synthetic",
    "seedPrefix",
    "scenario",
    "demoOps",
    "demoOpsId",
    "demoOpsCommand"
  ],
  "required": [
    "eventId",
    "clubId",
    "uid",
    "microPodsOptedOut",
    "guidedRotationsOptedOut",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "microPodsOptedOut": {
      "type": "boolean",
      "x-catch-ownership": "callable-owned"
    },
    "guidedRotationsOptedOut": {
      "type": "boolean",
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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

export const eventSuccessCompatibilityResponseDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_success_compatibility_responses.schema.json",
  "title": "EventSuccessCompatibilityResponseDocument",
  "description": "Attendee-owned compatibility questionnaire answers stored at eventSuccessCompatibilityResponses/{eventId_uid}. Hosts cannot read individual answers.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventSuccessCompatibilityResponses",
  "x-firestore-path": "eventSuccessCompatibilityResponses/{responseId}",
  "x-document-id-field": "id",
  "x-owner": "attendee direct write while signed up or attended; backend read for opted-in assignment generation",
  "x-internal-demo-fields": [
    "synthetic",
    "seedPrefix",
    "scenario",
    "demoOps",
    "demoOpsId",
    "demoOpsCommand"
  ],
  "required": [
    "eventId",
    "clubId",
    "uid",
    "answerIds",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "answerIds": {
      "type": "array",
      "minItems": 1,
      "maxItems": 8,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 120
      },
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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

export const eventSuccessWingmanRequestDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_success_wingman_requests.schema.json",
  "title": "EventSuccessWingmanRequestDocument",
  "description": "Explicit attendee request for host-visible introduction help stored at eventSuccessWingmanRequests/{eventId_uid}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventSuccessWingmanRequests",
  "x-firestore-path": "eventSuccessWingmanRequests/{requestId}",
  "x-document-id-field": "id",
  "x-owner": "attendee direct write after attended event; host read only while active and consented",
  "x-internal-demo-fields": [
    "synthetic",
    "seedPrefix",
    "scenario",
    "demoOps",
    "demoOpsId",
    "demoOpsCommand"
  ],
  "required": [
    "eventId",
    "clubId",
    "requesterUid",
    "targetUid",
    "status",
    "hostVisibleConsent",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "requesterUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "targetUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "withdrawn"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "hostVisibleConsent": {
      "type": "boolean",
      "const": true,
      "x-catch-ownership": "callable-owned"
    },
    "note": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 240,
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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

export const eventSuccessArrivalMissionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_success_arrival_missions.schema.json",
  "title": "EventSuccessArrivalMissionDocument",
  "description": "Server-owned First Hello arrival mission stored at eventSuccessArrivalMissions/{eventId_uid}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventSuccessArrivalMissions",
  "x-firestore-path": "eventSuccessArrivalMissions/{missionId}",
  "x-document-id-field": "id",
  "x-owner": "server-owned; attendee read only for their own mission",
  "x-internal-demo-fields": [
    "synthetic",
    "seedPrefix",
    "scenario",
    "demoOps",
    "demoOpsId",
    "demoOpsCommand"
  ],
  "required": [
    "eventId",
    "clubId",
    "observerUid",
    "targetUid",
    "targetDisplayName",
    "targetContext",
    "question",
    "answerOptions",
    "status",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "observerUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "targetUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "targetDisplayName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80,
      "x-catch-ownership": "callable-owned"
    },
    "targetContext": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "x-catch-ownership": "callable-owned"
    },
    "question": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "x-catch-ownership": "callable-owned"
    },
    "answerOptions": {
      "type": "array",
      "minItems": 2,
      "maxItems": 4,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "id",
          "label"
        ],
        "properties": {
          "id": {
            "type": "string",
            "minLength": 1,
            "maxLength": 64
          },
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          }
        }
      },
      "x-catch-ownership": "callable-owned"
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "completed",
        "skipped"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "selectedAnswerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 64,
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
    },
    "completedAt": {
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
      },
      "x-catch-ownership": "callable-owned"
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

export const eventSuccessAssignmentDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_success_assignments.schema.json",
  "title": "EventSuccessAssignmentDocument",
  "description": "Server-owned live guidance assignment stored at eventSuccessAssignments/{eventId_moduleId_uid}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventSuccessAssignments",
  "x-firestore-path": "eventSuccessAssignments/{assignmentId}",
  "x-document-id-field": "id",
  "x-owner": "event-success assignment callables",
  "x-internal-demo-fields": [
    "synthetic",
    "seedPrefix",
    "scenario",
    "demoOps",
    "demoOpsId",
    "demoOpsCommand"
  ],
  "required": [
    "eventId",
    "clubId",
    "uid",
    "moduleId",
    "label",
    "displayTitle",
    "peerUids",
    "source",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "moduleId": {
      "type": "string",
      "enum": [
        "micro_pods",
        "guided_rotations"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "label": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80,
      "x-catch-ownership": "callable-owned"
    },
    "displayTitle": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "x-catch-ownership": "callable-owned"
    },
    "displaySubtitle": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 240,
      "x-catch-ownership": "callable-owned"
    },
    "peerUids": {
      "type": "array",
      "maxItems": 20,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      },
      "x-catch-ownership": "callable-owned"
    },
    "unitKind": {
      "type": "string",
      "enum": [
        "wholeGroup",
        "pods",
        "pairs",
        "teams",
        "tables"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "unitIndex": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100,
      "x-catch-ownership": "callable-owned"
    },
    "unitLabel": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80,
      "x-catch-ownership": "callable-owned"
    },
    "whySummary": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240,
      "x-catch-ownership": "callable-owned"
    },
    "whyCodes": {
      "type": "array",
      "maxItems": 12,
      "items": {
        "type": "string",
        "enum": [
          "host_override",
          "mutual_interest",
          "one_way_interest",
          "questionnaire_match",
          "social_fallback",
          "balanced_group",
          "fresh_peer",
          "repeat_peer",
          "sit_out",
          "pair_slot",
          "pod_slot",
          "table_slot",
          "team_slot",
          "whole_group_slot"
        ]
      },
      "x-catch-ownership": "callable-owned"
    },
    "rotationFairness": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "assignedRoundCount",
        "sitOutRoundCount",
        "uniquePeerCount",
        "repeatPeerCount"
      ],
      "properties": {
        "assignedRoundCount": {
          "type": "integer",
          "minimum": 0,
          "maximum": 100
        },
        "sitOutRoundCount": {
          "type": "integer",
          "minimum": 0,
          "maximum": 100
        },
        "uniquePeerCount": {
          "type": "integer",
          "minimum": 0,
          "maximum": 100
        },
        "repeatPeerCount": {
          "type": "integer",
          "minimum": 0,
          "maximum": 100
        }
      },
      "x-catch-ownership": "callable-owned"
    },
    "sitOutSlots": {
      "type": "array",
      "maxItems": 24,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "roundIndex",
          "label",
          "startsAt",
          "endsAt",
          "whySummary",
          "whyCodes"
        ],
        "properties": {
          "roundIndex": {
            "type": "integer",
            "minimum": 0,
            "maximum": 100
          },
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "startsAt": {
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
          "endsAt": {
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
          "whySummary": {
            "type": "string",
            "minLength": 1,
            "maxLength": 240
          },
          "whyCodes": {
            "type": "array",
            "maxItems": 12,
            "items": {
              "type": "string",
              "enum": [
                "sit_out"
              ]
            }
          }
        }
      },
      "x-catch-ownership": "callable-owned"
    },
    "rotationSlots": {
      "type": "array",
      "maxItems": 24,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "roundIndex",
          "label",
          "startsAt",
          "endsAt",
          "peerUid",
          "compatibility"
        ],
        "properties": {
          "slotId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "roundIndex": {
            "type": "integer",
            "minimum": 0,
            "maximum": 100
          },
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "startsAt": {
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
          "endsAt": {
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
          "peerUid": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "unitKind": {
            "type": "string",
            "enum": [
              "pairs"
            ]
          },
          "unitIndex": {
            "type": "integer",
            "minimum": 0,
            "maximum": 100
          },
          "peerCount": {
            "type": "integer",
            "minimum": 1,
            "maximum": 20
          },
          "compatibility": {
            "type": "string",
            "enum": [
              "mutual_interest",
              "one_way_interest",
              "questionnaire_match",
              "social",
              "host_override"
            ]
          },
          "whySummary": {
            "type": "string",
            "minLength": 1,
            "maxLength": 240
          },
          "whyCodes": {
            "type": "array",
            "maxItems": 12,
            "items": {
              "type": "string",
              "enum": [
                "host_override",
                "mutual_interest",
                "one_way_interest",
                "questionnaire_match",
                "social_fallback",
                "fresh_peer",
                "repeat_peer",
                "pair_slot"
              ]
            }
          }
        }
      },
      "x-catch-ownership": "callable-owned"
    },
    "groupRotationSlots": {
      "type": "array",
      "maxItems": 24,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "roundIndex",
          "label",
          "unitLabel",
          "startsAt",
          "endsAt",
          "peerUids",
          "compatibility"
        ],
        "properties": {
          "slotId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "roundIndex": {
            "type": "integer",
            "minimum": 0,
            "maximum": 100
          },
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "unitLabel": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "unitKind": {
            "type": "string",
            "enum": [
              "wholeGroup",
              "pods",
              "pairs",
              "teams",
              "tables"
            ]
          },
          "unitIndex": {
            "type": "integer",
            "minimum": 0,
            "maximum": 100
          },
          "startsAt": {
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
          "endsAt": {
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
          "peerUids": {
            "type": "array",
            "maxItems": 20,
            "items": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180
            }
          },
          "peerCount": {
            "type": "integer",
            "minimum": 0,
            "maximum": 20
          },
          "compatibility": {
            "type": "string",
            "enum": [
              "mutual_interest",
              "one_way_interest",
              "questionnaire_match",
              "social",
              "mixed",
              "host_override"
            ]
          },
          "whySummary": {
            "type": "string",
            "minLength": 1,
            "maxLength": 240
          },
          "whyCodes": {
            "type": "array",
            "maxItems": 12,
            "items": {
              "type": "string",
              "enum": [
                "host_override",
                "mutual_interest",
                "questionnaire_match",
                "social_fallback",
                "balanced_group",
                "fresh_peer",
                "repeat_peer",
                "pair_slot",
                "pod_slot",
                "table_slot",
                "team_slot",
                "whole_group_slot"
              ]
            }
          }
        }
      },
      "x-catch-ownership": "callable-owned"
    },
    "source": {
      "type": "string",
      "enum": [
        "server_v1",
        "host_override_v1",
        "server"
      ],
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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

export const eventSuccessScorecardDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_success_scorecards.schema.json",
  "title": "EventSuccessScorecardDocument",
  "description": "Server-owned aggregate event coaching metrics stored at eventSuccessScorecards/{eventId}. Raw attendee feedback remains private.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventSuccessScorecards",
  "x-firestore-path": "eventSuccessScorecards/{eventId}",
  "x-document-id-field": "id",
  "x-owner": "event success feedback and matching triggers",
  "x-internal-demo-fields": [
    "synthetic",
    "seedPrefix",
    "scenario",
    "demoOps",
    "demoOpsId",
    "demoOpsCommand"
  ],
  "required": [
    "eventId",
    "clubId",
    "bookedCount",
    "checkedInCount",
    "feedbackCount",
    "attendeesWhoMetTwoPlusPeople",
    "catchSentCount",
    "attendeesWhoCaughtSomeone",
    "catchRecipientCount",
    "catchRate",
    "mutualMatchCount",
    "chatStartedCount",
    "averageWelcomeRating",
    "averageStructureRating",
    "safetyIncidentCount",
    "funnel",
    "updatedAt"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "trigger-owned"
    },
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "trigger-owned"
    },
    "bookedCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "trigger-owned"
    },
    "checkedInCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "trigger-owned"
    },
    "feedbackCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "trigger-owned"
    },
    "attendeesWhoMetTwoPlusPeople": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "trigger-owned"
    },
    "catchSentCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "trigger-owned"
    },
    "attendeesWhoCaughtSomeone": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "trigger-owned"
    },
    "catchRecipientCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "trigger-owned"
    },
    "catchRate": {
      "type": "number",
      "minimum": 0,
      "maximum": 1,
      "x-catch-ownership": "trigger-owned"
    },
    "mutualMatchCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "trigger-owned"
    },
    "chatStartedCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "trigger-owned"
    },
    "averageWelcomeRating": {
      "type": "number",
      "minimum": 0,
      "maximum": 5,
      "x-catch-ownership": "trigger-owned"
    },
    "averageStructureRating": {
      "type": "number",
      "minimum": 0,
      "maximum": 5,
      "x-catch-ownership": "trigger-owned"
    },
    "safetyIncidentCount": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "trigger-owned"
    },
    "funnel": {
      "type": "object",
      "additionalProperties": false,
      "description": "Host-visible operating funnel from acquisition through connection. Counts are aggregate-only and rebuilt from canonical documents.",
      "required": [
        "inviteLinkCount",
        "inviteOpenCount",
        "totalDemandCount",
        "requestCount",
        "pendingRequestCount",
        "approvedRequestCount",
        "declinedRequestCount",
        "directSignupCount",
        "waitlistJoinCount",
        "waitlistOfferCount",
        "waitlistOfferActiveCount",
        "waitlistOfferAcceptedCount",
        "waitlistOfferDeclinedCount",
        "waitlistOfferExpiredCount",
        "checkoutStartedCount",
        "paymentPendingCount",
        "paymentCompletedCount",
        "paymentFailedCount",
        "paymentRefundedCount",
        "bookedCount",
        "checkedInCount",
        "noShowCount",
        "catchSentCount",
        "attendeesWhoCaughtSomeone",
        "mutualMatchCount",
        "chatStartedCount",
        "repeatAttendeeCount"
      ],
      "properties": {
        "inviteLinkCount": {
          "type": "integer",
          "minimum": 0,
          "x-catch-ownership": "trigger-owned"
        },
        "inviteOpenCount": {
          "type": "integer",
          "minimum": 0,
          "x-catch-ownership": "trigger-owned"
        },
        "totalDemandCount": {
          "type": "integer",
          "minimum": 0,
          "x-catch-ownership": "trigger-owned"
        },
        "requestCount": {
          "type": "integer",
          "minimum": 0,
          "x-catch-ownership": "trigger-owned"
        },
        "pendingRequestCount": {
          "type": "integer",
          "minimum": 0,
          "x-catch-ownership": "trigger-owned"
        },
        "approvedRequestCount": {
          "type": "integer",
          "minimum": 0,
          "x-catch-ownership": "trigger-owned"
        },
        "declinedRequestCount": {
          "type": "integer",
          "minimum": 0,
          "x-catch-ownership": "trigger-owned"
        },
        "directSignupCount": {
          "type": "integer",
          "minimum": 0,
          "x-catch-ownership": "trigger-owned"
        },
        "waitlistJoinCount": {
          "type": "integer",
          "minimum": 0,
          "x-catch-ownership": "trigger-owned"
        },
        "waitlistOfferCount": {
          "type": "integer",
          "minimum": 0,
          "x-catch-ownership": "trigger-owned"
        },
        "waitlistOfferActiveCount": {
          "type": "integer",
          "minimum": 0,
          "x-catch-ownership": "trigger-owned"
        },
        "waitlistOfferAcceptedCount": {
          "type": "integer",
          "minimum": 0,
          "x-catch-ownership": "trigger-owned"
        },
        "waitlistOfferDeclinedCount": {
          "type": "integer",
          "minimum": 0,
          "x-catch-ownership": "trigger-owned"
        },
        "waitlistOfferExpiredCount": {
          "type": "integer",
          "minimum": 0,
          "x-catch-ownership": "trigger-owned"
        },
        "checkoutStartedCount": {
          "type": "integer",
          "minimum": 0,
          "x-catch-ownership": "trigger-owned"
        },
        "paymentPendingCount": {
          "type": "integer",
          "minimum": 0,
          "x-catch-ownership": "trigger-owned"
        },
        "paymentCompletedCount": {
          "type": "integer",
          "minimum": 0,
          "x-catch-ownership": "trigger-owned"
        },
        "paymentFailedCount": {
          "type": "integer",
          "minimum": 0,
          "x-catch-ownership": "trigger-owned"
        },
        "paymentRefundedCount": {
          "type": "integer",
          "minimum": 0,
          "x-catch-ownership": "trigger-owned"
        },
        "bookedCount": {
          "type": "integer",
          "minimum": 0,
          "x-catch-ownership": "trigger-owned"
        },
        "checkedInCount": {
          "type": "integer",
          "minimum": 0,
          "x-catch-ownership": "trigger-owned"
        },
        "noShowCount": {
          "type": "integer",
          "minimum": 0,
          "x-catch-ownership": "trigger-owned"
        },
        "catchSentCount": {
          "type": "integer",
          "minimum": 0,
          "x-catch-ownership": "trigger-owned"
        },
        "attendeesWhoCaughtSomeone": {
          "type": "integer",
          "minimum": 0,
          "x-catch-ownership": "trigger-owned"
        },
        "mutualMatchCount": {
          "type": "integer",
          "minimum": 0,
          "x-catch-ownership": "trigger-owned"
        },
        "chatStartedCount": {
          "type": "integer",
          "minimum": 0,
          "x-catch-ownership": "trigger-owned"
        },
        "repeatAttendeeCount": {
          "type": "integer",
          "minimum": 0,
          "x-catch-ownership": "trigger-owned"
        }
      },
      "x-catch-ownership": "trigger-owned"
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
      },
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
    }
  }
} as const;

export const eventSafetyReportDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_safety_reports.schema.json",
  "title": "EventSafetyReportDocument",
  "description": "Catch-private safety review item materialized from event feedback concerns.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventSafetyReports",
  "x-firestore-path": "eventSafetyReports/{reportId}",
  "x-document-id-field": "id",
  "x-owner": "onEventSuccessFeedbackWritten trigger",
  "required": [
    "eventId",
    "clubId",
    "reporterUserId",
    "feedbackId",
    "source",
    "status",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "reporterUserId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "feedbackId": {
      "type": "string",
      "minLength": 3,
      "maxLength": 256,
      "x-catch-ownership": "callable-owned"
    },
    "source": {
      "type": "string",
      "enum": [
        "event_success_feedback"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "status": {
      "type": "string",
      "enum": [
        "open",
        "reviewed",
        "dismissed"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "note": {
      "type": "string",
      "maxLength": 500,
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
    }
  }
} as const;

export const clubScheduleLockDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/club_schedule_locks.schema.json",
  "title": "ClubScheduleLockDocument",
  "description": "Server-owned time-slot claim stored at clubScheduleLocks/{clubId_slot}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "clubScheduleLocks",
  "x-firestore-path": "clubScheduleLocks/{lockId}",
  "x-document-id-field": "lockId",
  "x-owner": "event schedule conflict callables",
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
    "eventId",
    "clubId",
    "startTimeMillis",
    "endTimeMillis"
  ],
  "properties": {
    "ownerType": {
      "type": "string",
      "const": "club",
      "x-catch-ownership": "callable-owned"
    },
    "ownerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "slot": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "callable-owned"
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "startTimeMillis": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "callable-owned"
    },
    "endTimeMillis": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "callable-owned"
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

export const userEventScheduleLockDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/user_event_schedule_locks.schema.json",
  "title": "UserEventScheduleLockDocument",
  "description": "Server-owned time-slot claim stored at userEventScheduleLocks/{uid_slot}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "userEventScheduleLocks",
  "x-firestore-path": "userEventScheduleLocks/{lockId}",
  "x-document-id-field": "lockId",
  "x-owner": "event signup and waitlist callables",
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
    "eventId",
    "clubId",
    "uid",
    "startTimeMillis",
    "endTimeMillis"
  ],
  "properties": {
    "ownerType": {
      "type": "string",
      "const": "user",
      "x-catch-ownership": "callable-owned"
    },
    "ownerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "slot": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "callable-owned"
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "startTimeMillis": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "callable-owned"
    },
    "endTimeMillis": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "callable-owned"
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

export const savedEventDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/saved_events.schema.json",
  "title": "SavedEventDocument",
  "description": "Canonical saved-event edge stored at savedEvents/{savedEventId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "savedEvents",
  "x-firestore-path": "savedEvents/{savedEventId}",
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
    "eventId",
    "savedAt"
  ],
  "properties": {
    "uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "client-writable"
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "client-writable"
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
      },
      "x-catch-ownership": "client-writable"
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

export const hostAnalyticsEventSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/bigquery/host_analytics_event.schema.json",
  "title": "HostAnalyticsEvent",
  "description": "Raw aggregate-safe BigQuery event for host-visible organizer analytics. This is the source event table for discovery metrics; Firestore must not be the source of truth for these counters.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "analytics_event_id",
    "occurred_at",
    "event_date",
    "event_name",
    "club_id",
    "page_path",
    "ingested_at"
  ],
  "properties": {
    "analytics_event_id": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160
    },
    "occurred_at": {
      "type": "string",
      "format": "date-time"
    },
    "event_date": {
      "type": "string",
      "pattern": "^\\d{4}-\\d{2}-\\d{2}$"
    },
    "event_name": {
      "type": "string",
      "enum": [
        "listingView",
        "searchAppearance",
        "eventView",
        "organizerSave",
        "eventSave",
        "contactClick",
        "claimClick",
        "outboundClick"
      ]
    },
    "club_id": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "target_event_id": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "page_path": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "source": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 80
    },
    "session_hash": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 128
    },
    "platform": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 40
    },
    "ingested_at": {
      "type": "string",
      "format": "date-time"
    }
  }
} as const;

export const userProfileExposureEventSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/bigquery/user_profile_exposure_event.schema.json",
  "title": "UserProfileExposureEvent",
  "description": "Raw BigQuery event for profile impression, dwell, and photo performance analytics. This table is the denominator for user-safe profile analytics and internal composition models.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "analytics_event_id",
    "occurred_at",
    "event_date",
    "subject_uid",
    "event_name",
    "ingested_at"
  ],
  "properties": {
    "analytics_event_id": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160
    },
    "occurred_at": {
      "type": "string",
      "format": "date-time"
    },
    "event_date": {
      "type": "string",
      "pattern": "^\\d{4}-\\d{2}-\\d{2}$"
    },
    "viewer_uid": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "subject_uid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "event_id": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "club_id": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "event_name": {
      "type": "string",
      "enum": [
        "profileImpression",
        "profileView",
        "profileDwell",
        "photoImpression",
        "photoDwell"
      ]
    },
    "surface": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 80
    },
    "photo_id": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 180
    },
    "photo_slot": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0,
      "maximum": 24
    },
    "dwell_ms": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0,
      "maximum": 3600000
    },
    "session_hash": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 128
    },
    "platform": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 40
    },
    "ingested_at": {
      "type": "string",
      "format": "date-time"
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
    "eventId",
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
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "orderId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240,
      "x-catch-ownership": "callable-owned"
    },
    "paymentId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240,
      "x-catch-ownership": "callable-owned"
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "amount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100000000,
      "x-catch-ownership": "callable-owned"
    },
    "amountMinor": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100000000,
      "x-catch-ownership": "callable-owned"
    },
    "currency": {
      "type": "string",
      "minLength": 3,
      "maxLength": 3,
      "x-catch-ownership": "callable-owned"
    },
    "provider": {
      "type": "string",
      "enum": [
        "razorpay",
        "stripe"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "status": {
      "type": "string",
      "enum": [
        "pending",
        "completed",
        "failed",
        "refunded",
        "refundFailed"
      ],
      "description": "refundFailed marks a booking that failed AND whose automatic refund could not be issued, so the charge is stuck and needs manual reconciliation.",
      "x-catch-ownership": "callable-owned"
    },
    "providerPaymentId": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 240,
      "x-catch-ownership": "callable-owned"
    },
    "checkoutSessionId": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 240,
      "x-catch-ownership": "callable-owned"
    },
    "hostUserId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "stripeAccountId": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 120,
      "x-catch-ownership": "callable-owned"
    },
    "applicationFeeAmount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100000000,
      "x-catch-ownership": "callable-owned"
    },
    "inviteLinkId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "description": "Named host invite link attributed to this payment, when present.",
      "x-catch-ownership": "callable-owned"
    },
    "inviteSource": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 80,
      "description": "Host-facing invite source copied from eventInviteLinks.",
      "x-catch-ownership": "callable-owned"
    },
    "signUpFailed": {
      "type": "boolean",
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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

export const hostPaymentAccountDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/host_payment_accounts.schema.json",
  "title": "HostPaymentAccountDocument",
  "description": "Server-owned payment provider account state for a host. Stored at hostPaymentAccounts/{uid}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "hostPaymentAccounts",
  "x-firestore-path": "hostPaymentAccounts/{uid}",
  "x-document-id-field": "id",
  "x-owner": "Stripe Connect onboarding and webhook callables",
  "required": [
    "userId",
    "provider",
    "country",
    "defaultCurrency",
    "stripeAccountId",
    "chargesEnabled",
    "payoutsEnabled",
    "detailsSubmitted",
    "onboardingStatus",
    "requirementsCurrentlyDue",
    "requirementsPastDue",
    "requirementsPendingVerification",
    "createdAt",
    "updatedAt"
  ],
  "properties": {
    "userId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "provider": {
      "type": "string",
      "enum": [
        "stripe"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "country": {
      "type": "string",
      "minLength": 2,
      "maxLength": 2,
      "x-catch-ownership": "callable-owned"
    },
    "defaultCurrency": {
      "type": "string",
      "minLength": 3,
      "maxLength": 3,
      "x-catch-ownership": "callable-owned"
    },
    "stripeAccountId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "x-catch-ownership": "callable-owned"
    },
    "chargesEnabled": {
      "type": "boolean",
      "x-catch-ownership": "callable-owned"
    },
    "payoutsEnabled": {
      "type": "boolean",
      "x-catch-ownership": "callable-owned"
    },
    "detailsSubmitted": {
      "type": "boolean",
      "x-catch-ownership": "callable-owned"
    },
    "onboardingStatus": {
      "type": "string",
      "enum": [
        "notStarted",
        "pending",
        "complete",
        "restricted"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "disabledReason": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 240,
      "x-catch-ownership": "callable-owned"
    },
    "requirementsCurrentlyDue": {
      "type": "array",
      "maxItems": 80,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 160
      },
      "x-catch-ownership": "callable-owned"
    },
    "requirementsPastDue": {
      "type": "array",
      "maxItems": 80,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 160
      },
      "x-catch-ownership": "callable-owned"
    },
    "requirementsPendingVerification": {
      "type": "array",
      "maxItems": 80,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 160
      },
      "x-catch-ownership": "callable-owned"
    },
    "lastStripeEventId": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
    }
  }
} as const;

export const razorpayPendingOrderDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/razorpay_pending_orders.schema.json",
  "title": "RazorpayPendingOrderDocument",
  "description": "Server-owned tracking record for a created-but-not-yet-fulfilled Razorpay order, stored at razorpayPendingOrders/{orderId}. Lets the webhook and reconciliation sweep recover bookings when the client verification callback never lands. Deleted once the matching payments/{paymentId} completed record exists.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "razorpayPendingOrders",
  "x-firestore-path": "razorpayPendingOrders/{orderId}",
  "x-document-id-field": "orderId",
  "x-owner": "payments callables and razorpayWebhook",
  "required": [
    "provider",
    "orderId",
    "userId",
    "eventId",
    "amountInPaise",
    "currency",
    "status",
    "createdAt"
  ],
  "properties": {
    "provider": {
      "type": "string",
      "enum": [
        "razorpay"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "orderId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240,
      "x-catch-ownership": "callable-owned"
    },
    "userId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "amountInPaise": {
      "type": "integer",
      "minimum": 0,
      "maximum": 100000000,
      "x-catch-ownership": "callable-owned"
    },
    "currency": {
      "type": "string",
      "minLength": 3,
      "maxLength": 3,
      "x-catch-ownership": "callable-owned"
    },
    "status": {
      "type": "string",
      "enum": [
        "pending",
        "failed",
        "expired"
      ],
      "description": "pending until fulfilled (then the doc is deleted); failed when Razorpay reported payment.failed; expired when the reconciliation sweep found no captured payment after the grace window.",
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
    }
  }
} as const;

export const swipeDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/profile_decisions.schema.json",
  "title": "SwipeDocument",
  "description": "Storage contract for contextual profile decisions stored at profileDecisions/{userId}/outgoing/{targetId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "profileDecisions",
  "x-firestore-path": "profileDecisions/{userId}/outgoing/{targetId}",
  "x-document-id-field": "targetId",
  "x-owner": "authenticated swiper direct create; matching trigger consumes likes",
  "x-logical-name": "profileDecision",
  "x-migration-phase": "new_primary",
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
    "eventId",
    "direction",
    "createdAt"
  ],
  "properties": {
    "swiperId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "client-writable"
    },
    "targetId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "client-writable"
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "client-writable"
    },
    "direction": {
      "type": "string",
      "enum": [
        "like",
        "pass"
      ],
      "x-catch-ownership": "client-writable"
    },
    "reactionTargetId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 80,
      "x-catch-ownership": "client-writable"
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
      ],
      "x-catch-ownership": "client-writable"
    },
    "reactionTargetLabel": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 80,
      "x-catch-ownership": "client-writable"
    },
    "reactionTargetPreview": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 240,
      "x-catch-ownership": "client-writable"
    },
    "comment": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 240,
      "x-catch-ownership": "client-writable"
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
      },
      "x-catch-ownership": "client-writable"
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
    "eventIds",
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
      "maxLength": 180,
      "x-catch-ownership": "trigger-owned"
    },
    "user2Id": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "trigger-owned"
    },
    "eventIds": {
      "type": "array",
      "minItems": 0,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      },
      "x-catch-ownership": "trigger-owned"
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
      },
      "x-catch-ownership": "trigger-owned"
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
      ],
      "x-catch-ownership": "trigger-owned"
    },
    "lastMessagePreview": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 300,
      "x-catch-ownership": "trigger-owned"
    },
    "lastMessageSenderId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "trigger-owned"
    },
    "unreadCounts": {
      "type": "object",
      "additionalProperties": {
        "type": "integer",
        "minimum": 0
      },
      "x-catch-ownership": "client-runtime-writable"
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "blocked"
      ],
      "x-catch-ownership": "trigger-owned"
    },
    "blockedBy": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "trigger-owned"
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
      ],
      "x-catch-ownership": "trigger-owned"
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
      },
      "x-catch-ownership": "trigger-owned"
    },
    "conversationType": {
      "type": "string",
      "enum": [
        "match",
        "clubHostInquiry"
      ],
      "x-catch-ownership": "trigger-owned"
    },
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
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
      "maxLength": 180,
      "x-catch-ownership": "client-writable"
    },
    "text": {
      "type": "string",
      "maxLength": 2000,
      "x-catch-ownership": "client-writable"
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
      ],
      "x-catch-ownership": "client-writable"
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
      ],
      "x-catch-ownership": "client-writable"
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
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "type": {
      "type": "string",
      "enum": [
        "message",
        "match",
        "eventReminder",
        "eventSignup",
        "waitlistPromotion",
        "waitlistOffer",
        "waitlistOfferExpiring",
        "waitlistOfferExpired",
        "eventCancelled",
        "eventUpdated",
        "clubUpdate"
      ],
      "x-catch-ownership": "server-only"
    },
    "title": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "x-catch-ownership": "server-only"
    },
    "body": {
      "type": "string",
      "minLength": 1,
      "maxLength": 500,
      "x-catch-ownership": "server-only"
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
      },
      "x-catch-ownership": "server-only"
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
      ],
      "x-catch-ownership": "client-runtime-writable"
    },
    "matchId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 240,
      "x-catch-ownership": "server-only"
    },
    "eventId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "clubId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "postId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "actorUid": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "actorName": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 120,
      "x-catch-ownership": "server-only"
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
  "description": "Canonical organizer review stored at reviews/{reviewId}. Verified reviews come from attended Catch events; unverified reviews can come from public listing pages.",
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
    "clubId",
    "reviewerUserId",
    "reviewerName",
    "rating",
    "comment",
    "createdAt"
  ],
  "properties": {
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "eventId": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "reviewerUserId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ],
      "description": "Catch user id for signed-in reviewers. Null for anonymous public listing reviews.",
      "x-catch-ownership": "callable-owned"
    },
    "reviewerName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "x-catch-ownership": "callable-owned"
    },
    "rating": {
      "type": "integer",
      "minimum": 1,
      "maximum": 5,
      "x-catch-ownership": "callable-owned"
    },
    "comment": {
      "type": "string",
      "maxLength": 1000,
      "x-catch-ownership": "callable-owned"
    },
    "verificationStatus": {
      "type": "string",
      "enum": [
        "verified",
        "unverified"
      ],
      "description": "Verified reviews are created only after attended Catch events; public listing reviews are unverified.",
      "x-catch-ownership": "callable-owned"
    },
    "source": {
      "type": "string",
      "enum": [
        "catchEvent",
        "publicListing"
      ],
      "description": "Submission surface that created the review.",
      "x-catch-ownership": "callable-owned"
    },
    "moderationStatus": {
      "type": "string",
      "enum": [
        "published",
        "pending",
        "rejected"
      ],
      "description": "Public rendering status for organizer listing pages.",
      "x-catch-ownership": "callable-owned"
    },
    "isAnonymous": {
      "type": "boolean",
      "description": "True when the public display name should be the anonymous fallback rather than a user-supplied or profile name.",
      "x-catch-ownership": "callable-owned"
    },
    "submittedFromPath": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 240,
      "description": "Website path that submitted an unverified public listing review.",
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
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
      ],
      "x-catch-ownership": "callable-owned"
    },
    "ownerResponse": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "hostUserId",
        "hostName",
        "hostAvatarUrl",
        "message",
        "createdAt",
        "updatedAt"
      ],
      "properties": {
        "hostUserId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "x-catch-ownership": "callable-owned"
        },
        "hostName": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120,
          "x-catch-ownership": "callable-owned"
        },
        "hostAvatarUrl": {
          "type": [
            "string",
            "null"
          ],
          "format": "uri",
          "x-catch-ownership": "callable-owned"
        },
        "message": {
          "type": "string",
          "minLength": 1,
          "maxLength": 1000,
          "x-catch-ownership": "callable-owned"
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
          },
          "x-catch-ownership": "callable-owned"
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
          },
          "x-catch-ownership": "callable-owned"
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
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "blockedUserId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
    },
    "source": {
      "type": "string",
      "enum": [
        "profile",
        "chat",
        "match",
        "support"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "reasonCode": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80,
      "x-catch-ownership": "callable-owned"
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
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "targetUserId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
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
      },
      "x-catch-ownership": "callable-owned"
    },
    "source": {
      "type": "string",
      "enum": [
        "profile",
        "chat",
        "match",
        "support"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "status": {
      "type": "string",
      "enum": [
        "open",
        "reviewed",
        "dismissed"
      ],
      "x-catch-ownership": "callable-owned"
    },
    "reasonCode": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80,
      "x-catch-ownership": "callable-owned"
    },
    "contextId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "notes": {
      "type": "string",
      "maxLength": 1000,
      "x-catch-ownership": "callable-owned"
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
      "maxLength": 180,
      "x-catch-ownership": "trigger-owned"
    },
    "flagType": {
      "type": "string",
      "enum": [
        "explicit_photo",
        "banned_text",
        "underage_content"
      ],
      "x-catch-ownership": "trigger-owned"
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
      ],
      "x-catch-ownership": "trigger-owned"
    },
    "status": {
      "type": "string",
      "enum": [
        "pending",
        "reviewed",
        "dismissed"
      ],
      "x-catch-ownership": "trigger-owned"
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
      },
      "x-catch-ownership": "trigger-owned"
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
      },
      "x-catch-ownership": "trigger-owned"
    },
    "contextId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "trigger-owned"
    },
    "context": {
      "type": "string",
      "maxLength": 1000,
      "x-catch-ownership": "trigger-owned"
    },
    "safeSearchResults": {
      "type": "object",
      "additionalProperties": {
        "type": "string"
      },
      "x-catch-ownership": "trigger-owned"
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
      "maxLength": 180,
      "x-catch-ownership": "server-only"
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
      },
      "x-catch-ownership": "server-only"
    },
    "retainedFor": {
      "type": "array",
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 80
      },
      "uniqueItems": true,
      "x-catch-ownership": "server-only"
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
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "action": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "x-catch-ownership": "server-only"
    },
    "windowKey": {
      "type": "integer",
      "minimum": 0,
      "x-catch-ownership": "server-only"
    },
    "count": {
      "type": "integer",
      "minimum": 1,
      "x-catch-ownership": "server-only"
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
      },
      "x-catch-ownership": "server-only"
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
    "createdAt"
  ],
  "properties": {
    "handler": {
      "type": "string",
      "enum": [
        "onMessageCreated",
        "onMatchCreated",
        "moderatePhotoOnUpload"
      ],
      "x-catch-ownership": "server-only"
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240,
      "x-catch-ownership": "server-only"
    },
    "matchId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "messageId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
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
      },
      "x-catch-ownership": "server-only"
    }
  }
} as const;

export const publicRouteReservationDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/public_route_reservations.schema.json",
  "title": "PublicRouteReservationDocument",
  "description": "Server-owned reservation for a public website route. Stored at publicRouteReservations/{routeKey}; routeKey is derived from the normalized route path so route allocation is deterministic and transactionally claimable.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "publicRouteReservations",
  "x-firestore-path": "publicRouteReservations/{routeKey}",
  "x-document-id-field": "routeKey",
  "x-owner": "admin organizer publishing callables",
  "required": [
    "routeKey",
    "routePath",
    "routeKind",
    "routeSegments",
    "status",
    "ownerType",
    "ownerCollection",
    "ownerId",
    "targetPath",
    "slug",
    "citySlug",
    "createdAt",
    "updatedAt",
    "lastVerifiedAt",
    "lastVerifiedByUid",
    "lastVerifiedSource"
  ],
  "properties": {
    "routeKey": {
      "type": "string",
      "minLength": 1,
      "maxLength": 220,
      "pattern": "^[a-z0-9-]+(?:__[a-z0-9-]+)*$",
      "description": "Deterministic document id derived from routePath by removing leading/trailing slash and replacing route separators with double underscores.",
      "x-catch-ownership": "server-only"
    },
    "routePath": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240,
      "pattern": "^/organizers/([a-z0-9-]+/)?[a-z0-9-]+/$",
      "x-catch-ownership": "server-only"
    },
    "routeKind": {
      "type": "string",
      "enum": [
        "organizerCanonical"
      ],
      "x-catch-ownership": "server-only"
    },
    "routeSegments": {
      "type": "array",
      "minItems": 2,
      "maxItems": 3,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 80,
        "pattern": "^[a-z0-9-]+$"
      },
      "x-catch-ownership": "server-only"
    },
    "status": {
      "type": "string",
      "enum": [
        "active",
        "released"
      ],
      "x-catch-ownership": "server-only"
    },
    "ownerType": {
      "type": "string",
      "enum": [
        "club"
      ],
      "x-catch-ownership": "server-only"
    },
    "ownerCollection": {
      "type": "string",
      "enum": [
        "clubs"
      ],
      "x-catch-ownership": "server-only"
    },
    "ownerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "targetPath": {
      "type": "string",
      "minLength": 1,
      "maxLength": 260,
      "pattern": "^clubs/[^/]+$",
      "x-catch-ownership": "server-only"
    },
    "slug": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "pattern": "^[a-z0-9-]+$",
      "x-catch-ownership": "server-only"
    },
    "citySlug": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 120,
      "pattern": "^[a-z0-9-]+$",
      "x-catch-ownership": "server-only"
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
      },
      "x-catch-ownership": "server-only"
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
      },
      "x-catch-ownership": "server-only"
    },
    "lastVerifiedAt": {
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
      },
      "x-catch-ownership": "server-only"
    },
    "lastVerifiedByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "lastVerifiedSource": {
      "type": "string",
      "enum": [
        "adminUpdateClubDetails",
        "adminSetClubIndexStatus"
      ],
      "x-catch-ownership": "server-only"
    },
    "releasedAt": {
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
      ],
      "x-catch-ownership": "server-only"
    },
    "releasedByUid": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ],
      "x-catch-ownership": "server-only"
    },
    "replacementRoutePath": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 240,
      "pattern": "^/organizers/([a-z0-9-]+/)?[a-z0-9-]+/$",
      "x-catch-ownership": "server-only"
    }
  }
} as const;

export const seedEventManifestDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/seed_events.schema.json",
  "title": "SeedEventManifestDocument",
  "description": "Tool-owned synthetic-data manifest stored at seedEvents/{manifestId}.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "seedEvents",
  "x-firestore-path": "seedEvents/{manifestId}",
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
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "manifestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
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
      },
      "x-catch-ownership": "server-only"
    },
    "anchorUserIds": {
      "type": "array",
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      },
      "uniqueItems": true,
      "x-catch-ownership": "server-only"
    },
    "counts": {
      "type": "object",
      "additionalProperties": {
        "type": "integer",
        "minimum": 0
      },
      "x-catch-ownership": "server-only"
    },
    "paths": {
      "type": "array",
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 512
      },
      "uniqueItems": true,
      "x-catch-ownership": "server-only"
    },
    "appendMode": {
      "type": "boolean",
      "x-catch-ownership": "server-only"
    },
    "appendedAnchorUserIds": {
      "type": "array",
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      },
      "uniqueItems": true,
      "x-catch-ownership": "server-only"
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

export const organizerIntakeReviewDecisionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_intake_review_decisions.schema.json",
  "title": "OrganizerIntakeReviewDecisionDocument",
  "description": "Latest admin review decision stored at organizerIntakeReviewDecisions/{entityId}. Raw scrape/search evidence is not stored here.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerIntakeReviewDecisions",
  "x-firestore-path": "organizerIntakeReviewDecisions/{entityId}",
  "x-document-id-field": "entityId",
  "x-owner": "adminDecideOrganizerIntake callable",
  "required": [
    "schemaVersion",
    "entityId",
    "decision",
    "decisionStatus",
    "appVisibility",
    "checklist",
    "note",
    "reviewedByUid",
    "reviewedAt",
    "updatedAt",
    "projectionState"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "entityId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "decision": {
      "type": "string",
      "enum": [
        "approve_public",
        "hold",
        "suppress"
      ]
    },
    "decisionStatus": {
      "type": "string",
      "enum": [
        "approved_public",
        "held",
        "suppressed"
      ]
    },
    "appVisibility": {
      "type": "string",
      "enum": [
        "hidden",
        "discoverable"
      ]
    },
    "checklist": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "identityReviewed",
        "surfaceInventoryReviewed",
        "ownerSafeCopyReviewed",
        "marketScopeReviewed",
        "mediaRightsReviewed",
        "crawlDisabledReviewed"
      ],
      "properties": {
        "identityReviewed": {
          "type": "boolean"
        },
        "surfaceInventoryReviewed": {
          "type": "boolean"
        },
        "ownerSafeCopyReviewed": {
          "type": "boolean"
        },
        "marketScopeReviewed": {
          "type": "boolean"
        },
        "mediaRightsReviewed": {
          "type": "boolean"
        },
        "crawlDisabledReviewed": {
          "type": "boolean"
        },
        "manualReportsReviewed": {
          "type": "boolean",
          "description": "True when the reviewer explicitly inspected manual reports that have no local raw artifact. Raw evidence remains outside Firestore; projection replay decides when this acknowledgement is required."
        }
      }
    },
    "note": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
    },
    "reviewedByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
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
    "projectionState": {
      "type": "string",
      "enum": [
        "pending_static_generation",
        "not_projectable"
      ]
    }
  }
} as const;

export const eventIntakeReviewDecisionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_intake_review_decisions.schema.json",
  "title": "EventIntakeReviewDecisionDocument",
  "description": "Latest admin review decision stored at eventIntakeReviewDecisions/{decisionId}. Source artifacts, marketing content, imported events, and canonical events are not stored here.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventIntakeReviewDecisions",
  "x-firestore-path": "eventIntakeReviewDecisions/{decisionId}",
  "x-document-id-field": "decisionId",
  "x-owner": "adminRecordEventIntakeReviewDecision callable",
  "required": [
    "schemaVersion",
    "decisionId",
    "targetType",
    "targetId",
    "decision",
    "decisionStatus",
    "runId",
    "note",
    "checklist",
    "edits",
    "reviewedByUid",
    "reviewedAt",
    "updatedAt",
    "effect"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "decisionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "targetType": {
      "type": "string",
      "enum": [
        "source_profile",
        "query_template",
        "run_plan",
        "source_result",
        "event_candidate"
      ]
    },
    "targetId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "decision": {
      "type": "string",
      "enum": [
        "approve",
        "needs_changes",
        "hold",
        "reject"
      ]
    },
    "decisionStatus": {
      "type": "string",
      "enum": [
        "approved",
        "needs_changes",
        "held",
        "rejected"
      ]
    },
    "runId": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 180
    },
    "note": {
      "type": "string",
      "minLength": 1,
      "maxLength": 2000
    },
    "checklist": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "sourceReviewed",
        "dateReviewed",
        "venueReviewed",
        "copyReviewed",
        "rightsReviewed",
        "noCatchHostingImplied"
      ],
      "properties": {
        "sourceReviewed": {
          "type": "boolean"
        },
        "dateReviewed": {
          "type": "boolean"
        },
        "venueReviewed": {
          "type": "boolean"
        },
        "copyReviewed": {
          "type": "boolean"
        },
        "rightsReviewed": {
          "type": "boolean"
        },
        "noCatchHostingImplied": {
          "type": "boolean"
        }
      }
    },
    "edits": {
      "type": "object",
      "additionalProperties": true
    },
    "reviewedByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
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
    "effect": {
      "type": "string",
      "const": "decision_only_no_publish"
    }
  }
} as const;

export const organizerIntakeCurationDecisionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_intake_curation_decisions.schema.json",
  "title": "OrganizerIntakeCurationDecisionDocument",
  "description": "One manual organizer-intake curation operation stored at organizerIntakeCurationDecisions/{operationId}. Raw scrape/search evidence is not stored here.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerIntakeCurationDecisions",
  "x-firestore-path": "organizerIntakeCurationDecisions/{operationId}",
  "x-document-id-field": "operationId",
  "x-owner": "adminRecordOrganizerCuration callable",
  "required": [
    "schemaVersion",
    "operationId",
    "operationType",
    "operationStatus",
    "reason",
    "reviewedByUid",
    "reviewedAt",
    "updatedAt"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "operationId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "operationType": {
      "type": "string",
      "enum": [
        "attach_surface",
        "merge_entity",
        "split_surface",
        "suppress_entity",
        "surface_decision"
      ]
    },
    "operationStatus": {
      "type": "string",
      "enum": [
        "active",
        "superseded"
      ]
    },
    "entityId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "sourceEntityId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "targetEntityId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "surfaceId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "newEntityId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "sourceCandidateId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "decision": {
      "type": "string",
      "enum": [
        "accept_primary",
        "accept_secondary",
        "reject_wrong_entity",
        "mark_ambiguous",
        "mark_historical"
      ]
    },
    "surface": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "surfaceId",
        "platform",
        "surfaceKind",
        "url",
        "normalizedKey",
        "role",
        "status",
        "confidence",
        "crawl",
        "evidenceRefs",
        "notes"
      ],
      "properties": {
        "surfaceId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "platform": {
          "type": "string",
          "enum": [
            "bookMyShow",
            "district",
            "instagram",
            "linkedin",
            "luma",
            "news",
            "officialWebsite",
            "partiful",
            "sortMyScene",
            "userReport",
            "other"
          ]
        },
        "surfaceKind": {
          "type": "string",
          "enum": [
            "eventListing",
            "eventCalendar",
            "organizerProfile",
            "personProfile",
            "press",
            "socialProfile",
            "website",
            "wrongEntity"
          ]
        },
        "url": {
          "anyOf": [
            {
              "type": "string",
              "format": "uri"
            },
            {
              "type": "null"
            }
          ]
        },
        "normalizedKey": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 240
        },
        "role": {
          "type": "string",
          "enum": [
            "primary",
            "secondary",
            "backup",
            "historical",
            "ambiguous",
            "rejected"
          ]
        },
        "status": {
          "type": "string",
          "enum": [
            "active",
            "candidate",
            "ambiguous",
            "historical",
            "rejected"
          ]
        },
        "confidence": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "entityMatch",
            "ownership",
            "city"
          ],
          "properties": {
            "entityMatch": {
              "type": "string",
              "enum": [
                "low",
                "medium",
                "high"
              ]
            },
            "ownership": {
              "type": "string",
              "enum": [
                "low",
                "medium",
                "high"
              ]
            },
            "city": {
              "type": "string",
              "enum": [
                "low",
                "medium",
                "high"
              ]
            }
          }
        },
        "crawl": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "eventDiscoveryStatus",
            "policy",
            "supportsEventExtraction"
          ],
          "properties": {
            "eventDiscoveryStatus": {
              "type": "string",
              "enum": [
                "disabled",
                "candidate",
                "approved",
                "paused"
              ]
            },
            "policy": {
              "type": "string",
              "enum": [
                "manualOnly",
                "blocked",
                "apiPreferred"
              ]
            },
            "supportsEventExtraction": {
              "type": "boolean"
            }
          }
        },
        "evidenceRefs": {
          "type": "array",
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "type",
              "ref",
              "description"
            ],
            "properties": {
              "type": {
                "type": "string",
                "enum": [
                  "hostDiscoveryRun",
                  "seedClub",
                  "userReportedSearchResult",
                  "manualNote"
                ]
              },
              "ref": {
                "type": [
                  "string",
                  "null"
                ],
                "maxLength": 240
              },
              "description": {
                "type": "string",
                "minLength": 1,
                "maxLength": 400
              }
            }
          }
        },
        "notes": {
          "type": "string",
          "maxLength": 500
        }
      }
    },
    "reason": {
      "type": "string",
      "minLength": 1,
      "maxLength": 500
    },
    "reviewedByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
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
    "urlOrNull": {
      "anyOf": [
        {
          "type": "string",
          "format": "uri"
        },
        {
          "type": "null"
        }
      ]
    },
    "surface": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "surfaceId",
        "platform",
        "surfaceKind",
        "url",
        "normalizedKey",
        "role",
        "status",
        "confidence",
        "crawl",
        "evidenceRefs",
        "notes"
      ],
      "properties": {
        "surfaceId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "platform": {
          "type": "string",
          "enum": [
            "bookMyShow",
            "district",
            "instagram",
            "linkedin",
            "luma",
            "news",
            "officialWebsite",
            "partiful",
            "sortMyScene",
            "userReport",
            "other"
          ]
        },
        "surfaceKind": {
          "type": "string",
          "enum": [
            "eventListing",
            "eventCalendar",
            "organizerProfile",
            "personProfile",
            "press",
            "socialProfile",
            "website",
            "wrongEntity"
          ]
        },
        "url": {
          "anyOf": [
            {
              "type": "string",
              "format": "uri"
            },
            {
              "type": "null"
            }
          ]
        },
        "normalizedKey": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 240
        },
        "role": {
          "type": "string",
          "enum": [
            "primary",
            "secondary",
            "backup",
            "historical",
            "ambiguous",
            "rejected"
          ]
        },
        "status": {
          "type": "string",
          "enum": [
            "active",
            "candidate",
            "ambiguous",
            "historical",
            "rejected"
          ]
        },
        "confidence": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "entityMatch",
            "ownership",
            "city"
          ],
          "properties": {
            "entityMatch": {
              "type": "string",
              "enum": [
                "low",
                "medium",
                "high"
              ]
            },
            "ownership": {
              "type": "string",
              "enum": [
                "low",
                "medium",
                "high"
              ]
            },
            "city": {
              "type": "string",
              "enum": [
                "low",
                "medium",
                "high"
              ]
            }
          }
        },
        "crawl": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "eventDiscoveryStatus",
            "policy",
            "supportsEventExtraction"
          ],
          "properties": {
            "eventDiscoveryStatus": {
              "type": "string",
              "enum": [
                "disabled",
                "candidate",
                "approved",
                "paused"
              ]
            },
            "policy": {
              "type": "string",
              "enum": [
                "manualOnly",
                "blocked",
                "apiPreferred"
              ]
            },
            "supportsEventExtraction": {
              "type": "boolean"
            }
          }
        },
        "evidenceRefs": {
          "type": "array",
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "type",
              "ref",
              "description"
            ],
            "properties": {
              "type": {
                "type": "string",
                "enum": [
                  "hostDiscoveryRun",
                  "seedClub",
                  "userReportedSearchResult",
                  "manualNote"
                ]
              },
              "ref": {
                "type": [
                  "string",
                  "null"
                ],
                "maxLength": 240
              },
              "description": {
                "type": "string",
                "minLength": 1,
                "maxLength": 400
              }
            }
          }
        },
        "notes": {
          "type": "string",
          "maxLength": 500
        }
      }
    },
    "evidenceRef": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "type",
        "ref",
        "description"
      ],
      "properties": {
        "type": {
          "type": "string",
          "enum": [
            "hostDiscoveryRun",
            "seedClub",
            "userReportedSearchResult",
            "manualNote"
          ]
        },
        "ref": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 240
        },
        "description": {
          "type": "string",
          "minLength": 1,
          "maxLength": 400
        }
      }
    }
  }
} as const;

export const organizerEventCandidateReviewDecisionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_event_candidate_review_decisions.schema.json",
  "title": "OrganizerEventCandidateReviewDecisionDocument",
  "description": "Latest admin event-candidate review decision stored at organizerEventCandidateReviewDecisions/{decisionId}. Raw provider event evidence and imported events are not stored here.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerEventCandidateReviewDecisions",
  "x-firestore-path": "organizerEventCandidateReviewDecisions/{decisionId}",
  "x-document-id-field": "decisionId",
  "x-owner": "adminDecideOrganizerEventCandidate callable",
  "required": [
    "schemaVersion",
    "decisionId",
    "candidateId",
    "decision",
    "decisionStatus",
    "checklist",
    "note",
    "reviewedByUid",
    "reviewedAt",
    "updatedAt",
    "importState"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "decisionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "candidateId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "decision": {
      "type": "string",
      "enum": [
        "approve_for_import",
        "hold",
        "reject"
      ]
    },
    "decisionStatus": {
      "type": "string",
      "enum": [
        "approved_for_import",
        "held",
        "rejected"
      ]
    },
    "checklist": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "identityReviewed",
        "sourceEventReviewed",
        "timeReviewed",
        "locationReviewed",
        "dedupeReviewed",
        "ownerSafeCopyReviewed",
        "importPolicyAcknowledged"
      ],
      "properties": {
        "identityReviewed": {
          "type": "boolean"
        },
        "sourceEventReviewed": {
          "type": "boolean"
        },
        "timeReviewed": {
          "type": "boolean"
        },
        "locationReviewed": {
          "type": "boolean"
        },
        "dedupeReviewed": {
          "type": "boolean"
        },
        "ownerSafeCopyReviewed": {
          "type": "boolean"
        },
        "importPolicyAcknowledged": {
          "type": "boolean"
        }
      }
    },
    "note": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
    },
    "reviewedByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
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
    "importState": {
      "type": "string",
      "enum": [
        "blocked_by_policy",
        "not_importable",
        "pending_import"
      ]
    }
  }
} as const;

export const organizerEventLocationResolutionDecisionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_event_location_resolution_decisions.schema.json",
  "title": "OrganizerEventLocationResolutionDecisionDocument",
  "description": "Latest admin-reviewed event location resolution stored at organizerEventLocationResolutionDecisions/{resolutionId}. Raw provider lookup responses and imported events are not stored here.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerEventLocationResolutionDecisions",
  "x-firestore-path": "organizerEventLocationResolutionDecisions/{resolutionId}",
  "x-document-id-field": "resolutionId",
  "x-owner": "adminResolveOrganizerEventLocation callable",
  "required": [
    "schemaVersion",
    "resolutionId",
    "candidateId",
    "location",
    "checklist",
    "note",
    "reviewedByUid",
    "reviewedAt",
    "updatedAt",
    "resolutionStatus"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "resolutionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "candidateId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "location": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "name",
        "latitude",
        "longitude"
      ],
      "properties": {
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 240
        },
        "address": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 500
        },
        "placeId": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 256
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
        "notes": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 1000
        }
      }
    },
    "checklist": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "sourceLocationReviewed",
        "coordinatesReviewed",
        "placeIdentityReviewed",
        "importSafetyReviewed"
      ],
      "properties": {
        "sourceLocationReviewed": {
          "type": "boolean"
        },
        "coordinatesReviewed": {
          "type": "boolean"
        },
        "placeIdentityReviewed": {
          "type": "boolean"
        },
        "importSafetyReviewed": {
          "type": "boolean"
        }
      }
    },
    "note": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
    },
    "reviewedByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
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
    "resolutionStatus": {
      "type": "string",
      "enum": [
        "resolved"
      ]
    }
  }
} as const;

export const organizerPolicyGapReviewDecisionDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_policy_gap_review_decisions.schema.json",
  "title": "OrganizerPolicyGapReviewDecisionDocument",
  "description": "Latest admin/product policy-gap review decision stored at organizerPolicyGapReviewDecisions/{decisionId}. These decisions are review state only and do not enable organizer crawls, provider lookups, event imports, defaults, or naming migrations.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerPolicyGapReviewDecisions",
  "x-firestore-path": "organizerPolicyGapReviewDecisions/{decisionId}",
  "x-document-id-field": "decisionId",
  "x-owner": "adminDecideOrganizerPolicyGap callable",
  "required": [
    "schemaVersion",
    "decisionId",
    "gapId",
    "decision",
    "decisionStatus",
    "requiredInputsReviewed",
    "checklist",
    "note",
    "reviewedByUid",
    "reviewedAt",
    "updatedAt",
    "operationalState"
  ],
  "properties": {
    "schemaVersion": {
      "type": "integer",
      "const": 1
    },
    "decisionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "gapId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160
    },
    "decision": {
      "type": "string",
      "enum": [
        "accept",
        "hold",
        "reject"
      ]
    },
    "decisionStatus": {
      "type": "string",
      "enum": [
        "accepted",
        "held",
        "rejected"
      ]
    },
    "requiredInputsReviewed": {
      "type": "array",
      "maxItems": 20,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 240
      },
      "uniqueItems": true
    },
    "checklist": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "requiredInputsReviewed",
        "costAndSafetyReviewed",
        "implementationOwnerReviewed",
        "behaviorStillDisabledAcknowledged"
      ],
      "properties": {
        "requiredInputsReviewed": {
          "type": "boolean"
        },
        "costAndSafetyReviewed": {
          "type": "boolean"
        },
        "implementationOwnerReviewed": {
          "type": "boolean"
        },
        "behaviorStillDisabledAcknowledged": {
          "type": "boolean"
        }
      }
    },
    "note": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
    },
    "reviewedByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
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
    "operationalState": {
      "type": "string",
      "enum": [
        "blocked_until_policy_encoded",
        "not_approved"
      ]
    }
  }
} as const;

export const updateUserProfileCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/patches/update_user_profile.schema.json",
  "title": "UpdateUserProfileCallablePayload",
  "description": "Callable request body for updateUserProfile. Values are normalized before Firestore writes.",
  "x-callable-shape": "patch",
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
        "profilePhotos": {
          "type": "array",
          "maxItems": 6,
          "items": {
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
                    "type": [
                      "integer",
                      "null"
                    ],
                    "minimum": 0
                  }
                }
              },
              "position": {
                "type": "integer",
                "minimum": 0,
                "maximum": 11
              },
              "createdAt": {
                "type": "integer",
                "minimum": 0
              },
              "updatedAt": {
                "type": "integer",
                "minimum": 0
              }
            }
          }
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
          ]
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
          ],
          "maxLength": 120
        },
        "company": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 120
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
          }
        },
        "prefsNewCatches": {
          "type": "boolean"
        },
        "prefsMessages": {
          "type": "boolean"
        },
        "prefsEventReminders": {
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
    "fcmToken",
    "deleted",
    "deletedAt",
    "sexualOrientation",
    "bio"
  ]
} as const;

export const createClubCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_club_payload.schema.json",
  "title": "CreateClubCallablePayload",
  "description": "Callable payload accepted by createClub.",
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
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
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
    "profileImageUrl": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 320
    },
    "clubPhotos": {
      "type": "array",
      "maxItems": 12,
      "items": {
        "title": "UploadedPhoto",
        "description": "Canonical uploaded image object for ordered media galleries, logos, and event photos.",
        "type": "object",
        "additionalProperties": false,
        "required": [
          "id",
          "url",
          "storagePath",
          "thumbnailUrl",
          "thumbnailStoragePath",
          "position",
          "createdAt",
          "updatedAt"
        ],
        "properties": {
          "id": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120,
            "pattern": "^[A-Za-z0-9_-]+$"
          },
          "url": {
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
          "thumbnailUrl": {
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
          "thumbnailStoragePath": {
            "anyOf": [
              {
                "type": "string",
                "minLength": 1,
                "maxLength": 512,
                "pattern": "^[^/\\u0000][^\\u0000]*$"
              },
              {
                "type": "null"
              }
            ]
          },
          "position": {
            "type": "integer",
            "minimum": 0,
            "maximum": 19
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
        }
      }
    },
    "logoPhoto": {
      "anyOf": [
        {
          "title": "UploadedPhoto",
          "description": "Canonical uploaded image object for ordered media galleries, logos, and event photos.",
          "type": "object",
          "additionalProperties": false,
          "required": [
            "id",
            "url",
            "storagePath",
            "thumbnailUrl",
            "thumbnailStoragePath",
            "position",
            "createdAt",
            "updatedAt"
          ],
          "properties": {
            "id": {
              "type": "string",
              "minLength": 1,
              "maxLength": 120,
              "pattern": "^[A-Za-z0-9_-]+$"
            },
            "url": {
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
            "thumbnailUrl": {
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
            "thumbnailStoragePath": {
              "anyOf": [
                {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 512,
                  "pattern": "^[^/\\u0000][^\\u0000]*$"
                },
                {
                  "type": "null"
                }
              ]
            },
            "position": {
              "type": "integer",
              "minimum": 0,
              "maximum": 19
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
          }
        },
        {
          "type": "null"
        }
      ]
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
    "hostDefaults": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "primaryActivityKind": {
          "type": "string",
          "enum": [
            "socialRun",
            "running",
            "walking",
            "pickleball",
            "padel",
            "tennis",
            "badminton",
            "cycling",
            "spinClass",
            "yoga",
            "strengthTraining",
            "pubQuiz",
            "barCrawl",
            "dinner",
            "singlesMixer",
            "openActivity"
          ]
        },
        "supportedActivityKinds": {
          "type": "array",
          "maxItems": 16,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "enum": [
              "socialRun",
              "running",
              "walking",
              "pickleball",
              "padel",
              "tennis",
              "badminton",
              "cycling",
              "spinClass",
              "yoga",
              "strengthTraining",
              "pubQuiz",
              "barCrawl",
              "dinner",
              "singlesMixer",
              "openActivity"
            ]
          }
        },
        "eventPolicy": {
          "type": "object",
          "additionalProperties": false,
          "properties": {
            "admissionPreset": {
              "type": "string",
              "enum": [
                "openCapacity",
                "inviteOnly",
                "balancedSingles",
                "fixedCohortCaps"
              ]
            },
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
            },
            "dynamicPricingEnabled": {
              "type": "boolean"
            },
            "dynamicPricingStepInPaise": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 0,
              "maximum": 100000000
            },
            "dynamicPricingMaxInPaise": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 0,
              "maximum": 100000000
            },
            "cancellationPolicyId": {
              "type": "string",
              "enum": [
                "flexible",
                "standard",
                "strict"
              ]
            }
          }
        },
        "eventSuccess": {
          "type": "object",
          "additionalProperties": false,
          "properties": {
            "enabled": {
              "type": "boolean"
            },
            "playbookId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 120
            },
            "selectedModuleIds": {
              "type": "array",
              "maxItems": 24,
              "items": {
                "type": "string",
                "minLength": 1,
                "maxLength": 120
              }
            },
            "structureConfig": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "unitKind",
                "unitSize",
                "revealCountdownSeconds"
              ],
              "properties": {
                "unitKind": {
                  "type": "string",
                  "enum": [
                    "wholeGroup",
                    "pods",
                    "pairs",
                    "teams",
                    "tables"
                  ]
                },
                "unitSize": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 1000
                },
                "unitCount": {
                  "type": [
                    "integer",
                    "null"
                  ],
                  "minimum": 1,
                  "maximum": 200
                },
                "rotationIntervalMinutes": {
                  "type": [
                    "integer",
                    "null"
                  ],
                  "minimum": 5,
                  "maximum": 180
                },
                "revealCountdownSeconds": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 60
                },
                "rotationRepeatStrategy": {
                  "type": "string",
                  "enum": [
                    "avoid",
                    "allowWhenExhausted"
                  ]
                },
                "maxPairMeetings": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 10
                },
                "balanceActivityAttributes": {
                  "type": "array",
                  "maxItems": 8,
                  "uniqueItems": true,
                  "items": {
                    "type": "string",
                    "enum": [
                      "paceBand",
                      "skillBand",
                      "roleBand"
                    ]
                  }
                },
                "clusterActivityAttributes": {
                  "type": "array",
                  "maxItems": 8,
                  "uniqueItems": true,
                  "items": {
                    "type": "string",
                    "enum": [
                      "paceBand",
                      "skillBand",
                      "roleBand"
                    ]
                  }
                }
              }
            },
            "hostGoal": {
              "type": "string",
              "maxLength": 300
            },
            "wingmanRequestsEnabled": {
              "type": "boolean"
            },
            "contextualOpenersEnabled": {
              "type": "boolean"
            },
            "compatibilityAffectsRanking": {
              "type": "boolean"
            },
            "questionnaireConfig": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "templateId"
              ],
              "properties": {
                "templateId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 120
                },
                "customTitle": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "maxLength": 80
                },
                "customQuestions": {
                  "type": "array",
                  "maxItems": 8,
                  "items": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "id",
                      "prompt",
                      "options"
                    ],
                    "properties": {
                      "id": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 120
                      },
                      "prompt": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 140
                      },
                      "options": {
                        "type": "array",
                        "minItems": 2,
                        "maxItems": 5,
                        "items": {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "id",
                            "label"
                          ],
                          "properties": {
                            "id": {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 120
                            },
                            "label": {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 80
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            },
            "attendeePrompt": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 300
            }
          }
        },
        "eventSuccessByActivityKind": {
          "type": "object",
          "maxProperties": 16,
          "additionalProperties": {
            "type": "object",
            "additionalProperties": false,
            "properties": {
              "enabled": {
                "type": "boolean"
              },
              "playbookId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 120
              },
              "selectedModuleIds": {
                "type": "array",
                "maxItems": 24,
                "items": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 120
                }
              },
              "structureConfig": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "unitKind",
                  "unitSize",
                  "revealCountdownSeconds"
                ],
                "properties": {
                  "unitKind": {
                    "type": "string",
                    "enum": [
                      "wholeGroup",
                      "pods",
                      "pairs",
                      "teams",
                      "tables"
                    ]
                  },
                  "unitSize": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 1000
                  },
                  "unitCount": {
                    "type": [
                      "integer",
                      "null"
                    ],
                    "minimum": 1,
                    "maximum": 200
                  },
                  "rotationIntervalMinutes": {
                    "type": [
                      "integer",
                      "null"
                    ],
                    "minimum": 5,
                    "maximum": 180
                  },
                  "revealCountdownSeconds": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 60
                  },
                  "rotationRepeatStrategy": {
                    "type": "string",
                    "enum": [
                      "avoid",
                      "allowWhenExhausted"
                    ]
                  },
                  "maxPairMeetings": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 10
                  },
                  "balanceActivityAttributes": {
                    "type": "array",
                    "maxItems": 8,
                    "uniqueItems": true,
                    "items": {
                      "type": "string",
                      "enum": [
                        "paceBand",
                        "skillBand",
                        "roleBand"
                      ]
                    }
                  },
                  "clusterActivityAttributes": {
                    "type": "array",
                    "maxItems": 8,
                    "uniqueItems": true,
                    "items": {
                      "type": "string",
                      "enum": [
                        "paceBand",
                        "skillBand",
                        "roleBand"
                      ]
                    }
                  }
                }
              },
              "hostGoal": {
                "type": "string",
                "maxLength": 300
              },
              "wingmanRequestsEnabled": {
                "type": "boolean"
              },
              "contextualOpenersEnabled": {
                "type": "boolean"
              },
              "compatibilityAffectsRanking": {
                "type": "boolean"
              },
              "questionnaireConfig": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "templateId"
                ],
                "properties": {
                  "templateId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 120
                  },
                  "customTitle": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "maxLength": 80
                  },
                  "customQuestions": {
                    "type": "array",
                    "maxItems": 8,
                    "items": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "id",
                        "prompt",
                        "options"
                      ],
                      "properties": {
                        "id": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 120
                        },
                        "prompt": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 140
                        },
                        "options": {
                          "type": "array",
                          "minItems": 2,
                          "maxItems": 5,
                          "items": {
                            "type": "object",
                            "additionalProperties": false,
                            "required": [
                              "id",
                              "label"
                            ],
                            "properties": {
                              "id": {
                                "type": "string",
                                "minLength": 1,
                                "maxLength": 120
                              },
                              "label": {
                                "type": "string",
                                "minLength": 1,
                                "maxLength": 80
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              },
              "attendeePrompt": {
                "type": [
                  "string",
                  "null"
                ],
                "maxLength": 300
              }
            }
          }
        }
      }
    }
  }
} as const;

export const createClubCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/create_club_response.schema.json",
  "title": "CreateClubCallableResponse",
  "description": "Callable response returned by createClub.",
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

export const createClubPostCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_club_post_payload.schema.json",
  "title": "CreateClubPostCallablePayload",
  "description": "Callable payload accepted by createClubPost.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "clubId",
    "text"
  ],
  "properties": {
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "text": {
      "type": "string",
      "minLength": 1,
      "maxLength": 500
    },
    "photoPath": {
      "type": "string",
      "minLength": 1,
      "maxLength": 500
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;

export const createClubPostCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/create_club_post_response.schema.json",
  "title": "CreateClubPostCallableResponse",
  "description": "Callable response returned by createClubPost.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "postId",
    "remainingWeeklyQuota"
  ],
  "properties": {
    "postId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "remainingWeeklyQuota": {
      "type": "integer",
      "minimum": 0,
      "maximum": 3
    }
  }
} as const;

export const updateClubCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/update_club_payload.schema.json",
  "title": "UpdateClubCallablePayload",
  "description": "Callable payload accepted by updateClub.",
  "x-callable-shape": "patch",
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
          "type": "string",
          "minLength": 1,
          "maxLength": 120,
          "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
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
        "profileImageUrl": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 320
        },
        "clubPhotos": {
          "type": "array",
          "maxItems": 12,
          "items": {
            "title": "UploadedPhoto",
            "description": "Canonical uploaded image object for ordered media galleries, logos, and event photos.",
            "type": "object",
            "additionalProperties": false,
            "required": [
              "id",
              "url",
              "storagePath",
              "thumbnailUrl",
              "thumbnailStoragePath",
              "position",
              "createdAt",
              "updatedAt"
            ],
            "properties": {
              "id": {
                "type": "string",
                "minLength": 1,
                "maxLength": 120,
                "pattern": "^[A-Za-z0-9_-]+$"
              },
              "url": {
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
              "thumbnailUrl": {
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
              "thumbnailStoragePath": {
                "anyOf": [
                  {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 512,
                    "pattern": "^[^/\\u0000][^\\u0000]*$"
                  },
                  {
                    "type": "null"
                  }
                ]
              },
              "position": {
                "type": "integer",
                "minimum": 0,
                "maximum": 19
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
            }
          }
        },
        "logoPhoto": {
          "anyOf": [
            {
              "title": "UploadedPhoto",
              "description": "Canonical uploaded image object for ordered media galleries, logos, and event photos.",
              "type": "object",
              "additionalProperties": false,
              "required": [
                "id",
                "url",
                "storagePath",
                "thumbnailUrl",
                "thumbnailStoragePath",
                "position",
                "createdAt",
                "updatedAt"
              ],
              "properties": {
                "id": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 120,
                  "pattern": "^[A-Za-z0-9_-]+$"
                },
                "url": {
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
                "thumbnailUrl": {
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
                "thumbnailStoragePath": {
                  "anyOf": [
                    {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 512,
                      "pattern": "^[^/\\u0000][^\\u0000]*$"
                    },
                    {
                      "type": "null"
                    }
                  ]
                },
                "position": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 19
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
              }
            },
            {
              "type": "null"
            }
          ]
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
        },
        "hostDefaults": {
          "type": "object",
          "additionalProperties": false,
          "properties": {
            "primaryActivityKind": {
              "type": "string",
              "enum": [
                "socialRun",
                "running",
                "walking",
                "pickleball",
                "padel",
                "tennis",
                "badminton",
                "cycling",
                "spinClass",
                "yoga",
                "strengthTraining",
                "pubQuiz",
                "barCrawl",
                "dinner",
                "singlesMixer",
                "openActivity"
              ]
            },
            "supportedActivityKinds": {
              "type": "array",
              "maxItems": 16,
              "uniqueItems": true,
              "items": {
                "type": "string",
                "enum": [
                  "socialRun",
                  "running",
                  "walking",
                  "pickleball",
                  "padel",
                  "tennis",
                  "badminton",
                  "cycling",
                  "spinClass",
                  "yoga",
                  "strengthTraining",
                  "pubQuiz",
                  "barCrawl",
                  "dinner",
                  "singlesMixer",
                  "openActivity"
                ]
              }
            },
            "eventPolicy": {
              "type": "object",
              "additionalProperties": false,
              "properties": {
                "admissionPreset": {
                  "type": "string",
                  "enum": [
                    "openCapacity",
                    "inviteOnly",
                    "balancedSingles",
                    "fixedCohortCaps"
                  ]
                },
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
                },
                "dynamicPricingEnabled": {
                  "type": "boolean"
                },
                "dynamicPricingStepInPaise": {
                  "type": [
                    "integer",
                    "null"
                  ],
                  "minimum": 0,
                  "maximum": 100000000
                },
                "dynamicPricingMaxInPaise": {
                  "type": [
                    "integer",
                    "null"
                  ],
                  "minimum": 0,
                  "maximum": 100000000
                },
                "cancellationPolicyId": {
                  "type": "string",
                  "enum": [
                    "flexible",
                    "standard",
                    "strict"
                  ]
                }
              }
            },
            "eventSuccess": {
              "type": "object",
              "additionalProperties": false,
              "properties": {
                "enabled": {
                  "type": "boolean"
                },
                "playbookId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 120
                },
                "selectedModuleIds": {
                  "type": "array",
                  "maxItems": 24,
                  "items": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 120
                  }
                },
                "structureConfig": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "unitKind",
                    "unitSize",
                    "revealCountdownSeconds"
                  ],
                  "properties": {
                    "unitKind": {
                      "type": "string",
                      "enum": [
                        "wholeGroup",
                        "pods",
                        "pairs",
                        "teams",
                        "tables"
                      ]
                    },
                    "unitSize": {
                      "type": "integer",
                      "minimum": 1,
                      "maximum": 1000
                    },
                    "unitCount": {
                      "type": [
                        "integer",
                        "null"
                      ],
                      "minimum": 1,
                      "maximum": 200
                    },
                    "rotationIntervalMinutes": {
                      "type": [
                        "integer",
                        "null"
                      ],
                      "minimum": 5,
                      "maximum": 180
                    },
                    "revealCountdownSeconds": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 60
                    },
                    "rotationRepeatStrategy": {
                      "type": "string",
                      "enum": [
                        "avoid",
                        "allowWhenExhausted"
                      ]
                    },
                    "maxPairMeetings": {
                      "type": "integer",
                      "minimum": 1,
                      "maximum": 10
                    },
                    "balanceActivityAttributes": {
                      "type": "array",
                      "maxItems": 8,
                      "uniqueItems": true,
                      "items": {
                        "type": "string",
                        "enum": [
                          "paceBand",
                          "skillBand",
                          "roleBand"
                        ]
                      }
                    },
                    "clusterActivityAttributes": {
                      "type": "array",
                      "maxItems": 8,
                      "uniqueItems": true,
                      "items": {
                        "type": "string",
                        "enum": [
                          "paceBand",
                          "skillBand",
                          "roleBand"
                        ]
                      }
                    }
                  }
                },
                "hostGoal": {
                  "type": "string",
                  "maxLength": 300
                },
                "wingmanRequestsEnabled": {
                  "type": "boolean"
                },
                "contextualOpenersEnabled": {
                  "type": "boolean"
                },
                "compatibilityAffectsRanking": {
                  "type": "boolean"
                },
                "questionnaireConfig": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "templateId"
                  ],
                  "properties": {
                    "templateId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 120
                    },
                    "customTitle": {
                      "type": [
                        "string",
                        "null"
                      ],
                      "maxLength": 80
                    },
                    "customQuestions": {
                      "type": "array",
                      "maxItems": 8,
                      "items": {
                        "type": "object",
                        "additionalProperties": false,
                        "required": [
                          "id",
                          "prompt",
                          "options"
                        ],
                        "properties": {
                          "id": {
                            "type": "string",
                            "minLength": 1,
                            "maxLength": 120
                          },
                          "prompt": {
                            "type": "string",
                            "minLength": 1,
                            "maxLength": 140
                          },
                          "options": {
                            "type": "array",
                            "minItems": 2,
                            "maxItems": 5,
                            "items": {
                              "type": "object",
                              "additionalProperties": false,
                              "required": [
                                "id",
                                "label"
                              ],
                              "properties": {
                                "id": {
                                  "type": "string",
                                  "minLength": 1,
                                  "maxLength": 120
                                },
                                "label": {
                                  "type": "string",
                                  "minLength": 1,
                                  "maxLength": 80
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                },
                "attendeePrompt": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "maxLength": 300
                }
              }
            },
            "eventSuccessByActivityKind": {
              "type": "object",
              "maxProperties": 16,
              "additionalProperties": {
                "type": "object",
                "additionalProperties": false,
                "properties": {
                  "enabled": {
                    "type": "boolean"
                  },
                  "playbookId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 120
                  },
                  "selectedModuleIds": {
                    "type": "array",
                    "maxItems": 24,
                    "items": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 120
                    }
                  },
                  "structureConfig": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "unitKind",
                      "unitSize",
                      "revealCountdownSeconds"
                    ],
                    "properties": {
                      "unitKind": {
                        "type": "string",
                        "enum": [
                          "wholeGroup",
                          "pods",
                          "pairs",
                          "teams",
                          "tables"
                        ]
                      },
                      "unitSize": {
                        "type": "integer",
                        "minimum": 1,
                        "maximum": 1000
                      },
                      "unitCount": {
                        "type": [
                          "integer",
                          "null"
                        ],
                        "minimum": 1,
                        "maximum": 200
                      },
                      "rotationIntervalMinutes": {
                        "type": [
                          "integer",
                          "null"
                        ],
                        "minimum": 5,
                        "maximum": 180
                      },
                      "revealCountdownSeconds": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 60
                      },
                      "rotationRepeatStrategy": {
                        "type": "string",
                        "enum": [
                          "avoid",
                          "allowWhenExhausted"
                        ]
                      },
                      "maxPairMeetings": {
                        "type": "integer",
                        "minimum": 1,
                        "maximum": 10
                      },
                      "balanceActivityAttributes": {
                        "type": "array",
                        "maxItems": 8,
                        "uniqueItems": true,
                        "items": {
                          "type": "string",
                          "enum": [
                            "paceBand",
                            "skillBand",
                            "roleBand"
                          ]
                        }
                      },
                      "clusterActivityAttributes": {
                        "type": "array",
                        "maxItems": 8,
                        "uniqueItems": true,
                        "items": {
                          "type": "string",
                          "enum": [
                            "paceBand",
                            "skillBand",
                            "roleBand"
                          ]
                        }
                      }
                    }
                  },
                  "hostGoal": {
                    "type": "string",
                    "maxLength": 300
                  },
                  "wingmanRequestsEnabled": {
                    "type": "boolean"
                  },
                  "contextualOpenersEnabled": {
                    "type": "boolean"
                  },
                  "compatibilityAffectsRanking": {
                    "type": "boolean"
                  },
                  "questionnaireConfig": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "templateId"
                    ],
                    "properties": {
                      "templateId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 120
                      },
                      "customTitle": {
                        "type": [
                          "string",
                          "null"
                        ],
                        "maxLength": 80
                      },
                      "customQuestions": {
                        "type": "array",
                        "maxItems": 8,
                        "items": {
                          "type": "object",
                          "additionalProperties": false,
                          "required": [
                            "id",
                            "prompt",
                            "options"
                          ],
                          "properties": {
                            "id": {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 120
                            },
                            "prompt": {
                              "type": "string",
                              "minLength": 1,
                              "maxLength": 140
                            },
                            "options": {
                              "type": "array",
                              "minItems": 2,
                              "maxItems": 5,
                              "items": {
                                "type": "object",
                                "additionalProperties": false,
                                "required": [
                                  "id",
                                  "label"
                                ],
                                "properties": {
                                  "id": {
                                    "type": "string",
                                    "minLength": 1,
                                    "maxLength": 120
                                  },
                                  "label": {
                                    "type": "string",
                                    "minLength": 1,
                                    "maxLength": 80
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  },
                  "attendeePrompt": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "maxLength": 300
                  }
                }
              }
            }
          }
        }
      }
    }
  }
} as const;

export const hostAnalyticsQueryCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/host_analytics_query_payload.schema.json",
  "title": "HostAnalyticsQueryCallablePayload",
  "description": "Callable payload accepted by getHostAnalytics and adminGetHostAnalytics.",
  "x-callable-aliases": [
    "getHostAnalytics",
    "adminGetHostAnalytics"
  ],
  "type": "object",
  "additionalProperties": false,
  "properties": {
    "clubId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "eventId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "rangePreset": {
      "type": "string",
      "enum": [
        "7d",
        "30d",
        "90d",
        "month",
        "custom"
      ]
    },
    "startDate": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^\\d{4}-\\d{2}-\\d{2}$"
    },
    "endDate": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^\\d{4}-\\d{2}-\\d{2}$"
    },
    "granularity": {
      "type": "string",
      "enum": [
        "day",
        "week",
        "month"
      ]
    }
  }
} as const;

export const hostAnalyticsCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/host_analytics_response.schema.json",
  "title": "HostAnalyticsCallableResponse",
  "description": "Shared aggregate analytics response returned by host and admin analytics callables. Values are aggregate-only and host-safe.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "generatedAt",
    "timezone",
    "range",
    "scope",
    "summaryCards",
    "trend",
    "topEvents",
    "reviewSummary",
    "discoverySummary",
    "dataQuality"
  ],
  "properties": {
    "generatedAt": {
      "type": "string",
      "format": "date-time"
    },
    "timezone": {
      "type": "string",
      "minLength": 1,
      "maxLength": 64
    },
    "range": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "startDate",
        "endDate",
        "granularity"
      ],
      "properties": {
        "startDate": {
          "type": "string",
          "format": "date-time"
        },
        "endDate": {
          "type": "string",
          "format": "date-time"
        },
        "granularity": {
          "type": "string",
          "enum": [
            "day",
            "week",
            "month"
          ]
        },
        "preset": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 24
        }
      }
    },
    "scope": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "clubIds",
        "eventIds"
      ],
      "properties": {
        "clubIds": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          }
        },
        "eventIds": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          }
        },
        "clubName": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 160
        },
        "eventTitle": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 160
        }
      }
    },
    "summaryCards": {
      "type": "array",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "id",
          "label",
          "value",
          "unit",
          "status"
        ],
        "properties": {
          "id": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "value": {
            "type": "number"
          },
          "unit": {
            "type": "string",
            "enum": [
              "count",
              "percent",
              "money_minor",
              "rating"
            ]
          },
          "status": {
            "type": "string",
            "enum": [
              "ready",
              "partial",
              "missing"
            ]
          },
          "caption": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 160
          }
        }
      }
    },
    "trend": {
      "type": "array",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "periodStart",
          "periodEnd",
          "metrics"
        ],
        "properties": {
          "periodStart": {
            "type": "string",
            "format": "date-time"
          },
          "periodEnd": {
            "type": "string",
            "format": "date-time"
          },
          "metrics": {
            "type": "object",
            "additionalProperties": {
              "type": "number"
            }
          }
        }
      }
    },
    "topEvents": {
      "type": "array",
      "maxItems": 25,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "eventId",
          "clubId",
          "title",
          "startTime",
          "status",
          "capacityLimit",
          "bookedCount",
          "checkedInCount",
          "waitlistedCount",
          "fillRate",
          "checkInRate",
          "grossRevenueMinor",
          "currency",
          "checkoutStartedCount",
          "checkoutDropoffCount",
          "paymentCompletedCount",
          "paymentFailedCount",
          "paymentRefundedCount",
          "reviewCount",
          "averageRating",
          "demandCount",
          "inviteOpenCount",
          "mutualMatchCount",
          "chatStartedCount",
          "repeatAttendeeCount"
        ],
        "properties": {
          "eventId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "clubId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "title": {
            "type": "string",
            "minLength": 1,
            "maxLength": 160
          },
          "startTime": {
            "type": "string",
            "format": "date-time"
          },
          "status": {
            "type": "string",
            "maxLength": 48
          },
          "capacityLimit": {
            "type": "integer",
            "minimum": 0
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
          "fillRate": {
            "type": "number",
            "minimum": 0
          },
          "checkInRate": {
            "type": "number",
            "minimum": 0
          },
          "grossRevenueMinor": {
            "type": "integer",
            "minimum": 0
          },
          "currency": {
            "type": "string",
            "minLength": 3,
            "maxLength": 3
          },
          "checkoutStartedCount": {
            "type": "integer",
            "minimum": 0
          },
          "checkoutDropoffCount": {
            "type": "integer",
            "minimum": 0
          },
          "paymentCompletedCount": {
            "type": "integer",
            "minimum": 0
          },
          "paymentFailedCount": {
            "type": "integer",
            "minimum": 0
          },
          "paymentRefundedCount": {
            "type": "integer",
            "minimum": 0
          },
          "reviewCount": {
            "type": "integer",
            "minimum": 0
          },
          "averageRating": {
            "type": "number",
            "minimum": 0,
            "maximum": 5
          },
          "demandCount": {
            "type": "integer",
            "minimum": 0
          },
          "inviteOpenCount": {
            "type": "integer",
            "minimum": 0
          },
          "mutualMatchCount": {
            "type": "integer",
            "minimum": 0
          },
          "chatStartedCount": {
            "type": "integer",
            "minimum": 0
          },
          "repeatAttendeeCount": {
            "type": "integer",
            "minimum": 0
          }
        }
      }
    },
    "reviewSummary": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "newReviews",
        "publishedReviews",
        "verifiedReviews",
        "publicReviews",
        "ownerResponseCount",
        "averageRating"
      ],
      "properties": {
        "newReviews": {
          "type": "integer",
          "minimum": 0
        },
        "publishedReviews": {
          "type": "integer",
          "minimum": 0
        },
        "verifiedReviews": {
          "type": "integer",
          "minimum": 0
        },
        "publicReviews": {
          "type": "integer",
          "minimum": 0
        },
        "ownerResponseCount": {
          "type": "integer",
          "minimum": 0
        },
        "averageRating": {
          "type": "number",
          "minimum": 0,
          "maximum": 5
        }
      }
    },
    "discoverySummary": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "listingViews",
        "searchAppearances",
        "eventViews",
        "organizerSaves",
        "eventSaves",
        "contactClicks",
        "claimClicks",
        "outboundClicks"
      ],
      "properties": {
        "listingViews": {
          "type": "integer",
          "minimum": 0
        },
        "searchAppearances": {
          "type": "integer",
          "minimum": 0
        },
        "eventViews": {
          "type": "integer",
          "minimum": 0
        },
        "organizerSaves": {
          "type": "integer",
          "minimum": 0
        },
        "eventSaves": {
          "type": "integer",
          "minimum": 0
        },
        "contactClicks": {
          "type": "integer",
          "minimum": 0
        },
        "claimClicks": {
          "type": "integer",
          "minimum": 0
        },
        "outboundClicks": {
          "type": "integer",
          "minimum": 0
        }
      }
    },
    "dataQuality": {
      "type": "array",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "id",
          "state",
          "detail",
          "owner",
          "runbook",
          "nextAction"
        ],
        "properties": {
          "id": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "state": {
            "type": "string",
            "enum": [
              "ok",
              "partial",
              "missing"
            ]
          },
          "detail": {
            "type": "string",
            "minLength": 1,
            "maxLength": 240
          },
          "owner": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "runbook": {
            "type": "string",
            "minLength": 1,
            "maxLength": 200
          },
          "nextAction": {
            "type": "string",
            "minLength": 1,
            "maxLength": 240
          }
        }
      }
    }
  },
  "definitions": {
    "metricCard": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "id",
        "label",
        "value",
        "unit",
        "status"
      ],
      "properties": {
        "id": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80
        },
        "label": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80
        },
        "value": {
          "type": "number"
        },
        "unit": {
          "type": "string",
          "enum": [
            "count",
            "percent",
            "money_minor",
            "rating"
          ]
        },
        "status": {
          "type": "string",
          "enum": [
            "ready",
            "partial",
            "missing"
          ]
        },
        "caption": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 160
        }
      }
    }
  }
} as const;

export const userAnalyticsQueryCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/user_analytics_query_payload.schema.json",
  "title": "UserAnalyticsQueryCallablePayload",
  "description": "Callable payload accepted by getUserAnalytics and adminGetUserAnalytics.",
  "x-callable-aliases": [
    "getUserAnalytics",
    "adminGetUserAnalytics"
  ],
  "type": "object",
  "additionalProperties": false,
  "properties": {
    "userId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ],
      "description": "Admin-only user scope override. getUserAnalytics always scopes to the signed-in user."
    },
    "rangePreset": {
      "type": "string",
      "enum": [
        "7d",
        "30d",
        "90d",
        "month",
        "custom"
      ]
    },
    "startDate": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^\\d{4}-\\d{2}-\\d{2}$"
    },
    "endDate": {
      "type": [
        "string",
        "null"
      ],
      "pattern": "^\\d{4}-\\d{2}-\\d{2}$"
    },
    "granularity": {
      "type": "string",
      "enum": [
        "day",
        "week",
        "month"
      ]
    }
  }
} as const;

export const userAnalyticsCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/user_analytics_response.schema.json",
  "title": "UserAnalyticsCallableResponse",
  "description": "User-safe profile and connection analytics response. Internal scoring columns stay in BigQuery and are intentionally not exposed here.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "generatedAt",
    "timezone",
    "range",
    "scope",
    "summaryCards",
    "trend",
    "connectionSummary",
    "profileSummary",
    "coachingTipRefs",
    "dataQuality"
  ],
  "properties": {
    "generatedAt": {
      "type": "string",
      "format": "date-time"
    },
    "timezone": {
      "type": "string",
      "minLength": 1,
      "maxLength": 64
    },
    "range": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "startDate",
        "endDate",
        "granularity"
      ],
      "properties": {
        "startDate": {
          "type": "string",
          "format": "date-time"
        },
        "endDate": {
          "type": "string",
          "format": "date-time"
        },
        "granularity": {
          "type": "string",
          "enum": [
            "day",
            "week",
            "month"
          ]
        },
        "preset": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 24
        }
      }
    },
    "scope": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "userId"
      ],
      "properties": {
        "userId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        }
      }
    },
    "summaryCards": {
      "type": "array",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "id",
          "label",
          "value",
          "unit",
          "status"
        ],
        "properties": {
          "id": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "value": {
            "type": "number"
          },
          "unit": {
            "type": "string",
            "enum": [
              "count",
              "percent",
              "duration_seconds"
            ]
          },
          "status": {
            "type": "string",
            "enum": [
              "ready",
              "partial",
              "missing"
            ]
          },
          "caption": {
            "type": [
              "string",
              "null"
            ],
            "maxLength": 160
          }
        }
      }
    },
    "trend": {
      "type": "array",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "periodStart",
          "periodEnd",
          "metrics"
        ],
        "properties": {
          "periodStart": {
            "type": "string",
            "format": "date-time"
          },
          "periodEnd": {
            "type": "string",
            "format": "date-time"
          },
          "metrics": {
            "type": "object",
            "additionalProperties": {
              "type": "number"
            }
          }
        }
      }
    },
    "connectionSummary": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "outgoingLikes",
        "incomingLikes",
        "privateInterestReceived",
        "mutualCatches",
        "chatsStarted",
        "chatMessagesSent",
        "followThroughRate",
        "eventsAttended"
      ],
      "properties": {
        "outgoingLikes": {
          "type": "integer",
          "minimum": 0
        },
        "incomingLikes": {
          "type": "integer",
          "minimum": 0
        },
        "privateInterestReceived": {
          "type": "integer",
          "minimum": 0
        },
        "mutualCatches": {
          "type": "integer",
          "minimum": 0
        },
        "chatsStarted": {
          "type": "integer",
          "minimum": 0
        },
        "chatMessagesSent": {
          "type": "integer",
          "minimum": 0
        },
        "followThroughRate": {
          "type": "number",
          "minimum": 0
        },
        "eventsAttended": {
          "type": "integer",
          "minimum": 0
        }
      }
    },
    "profileSummary": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "profileViews",
        "uniqueViewers",
        "profileDwellSeconds",
        "photoImpressions",
        "topPhotoId",
        "activeMinutes"
      ],
      "properties": {
        "profileViews": {
          "type": "integer",
          "minimum": 0
        },
        "uniqueViewers": {
          "type": "integer",
          "minimum": 0
        },
        "profileDwellSeconds": {
          "type": "integer",
          "minimum": 0
        },
        "photoImpressions": {
          "type": "integer",
          "minimum": 0
        },
        "topPhotoId": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 180
        },
        "activeMinutes": {
          "type": "integer",
          "minimum": 0
        }
      }
    },
    "coachingTipRefs": {
      "type": "array",
      "maxItems": 4,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "id",
          "copyKey",
          "priority",
          "metricIds"
        ],
        "properties": {
          "id": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "copyKey": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "priority": {
            "type": "integer",
            "minimum": 1,
            "maximum": 5
          },
          "metricIds": {
            "type": "array",
            "items": {
              "type": "string",
              "minLength": 1,
              "maxLength": 80
            }
          }
        }
      }
    },
    "dataQuality": {
      "type": "array",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "id",
          "state",
          "detail"
        ],
        "properties": {
          "id": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "state": {
            "type": "string",
            "enum": [
              "ok",
              "partial",
              "missing"
            ]
          },
          "detail": {
            "type": "string",
            "minLength": 1,
            "maxLength": 240
          }
        }
      }
    }
  },
  "definitions": {
    "metricCard": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "id",
        "label",
        "value",
        "unit",
        "status"
      ],
      "properties": {
        "id": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80
        },
        "label": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80
        },
        "value": {
          "type": "number"
        },
        "unit": {
          "type": "string",
          "enum": [
            "count",
            "percent",
            "duration_seconds"
          ]
        },
        "status": {
          "type": "string",
          "enum": [
            "ready",
            "partial",
            "missing"
          ]
        },
        "caption": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 160
        }
      }
    }
  }
} as const;

export const addClubHostCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/add_club_host_payload.schema.json",
  "title": "AddClubHostCallablePayload",
  "description": "Callable payload accepted by addClubHost.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "clubId"
  ],
  "oneOf": [
    {
      "required": [
        "uid"
      ]
    },
    {
      "required": [
        "phoneNumber"
      ]
    }
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
    "phoneNumber": {
      "type": "string",
      "minLength": 6,
      "maxLength": 32
    }
  }
} as const;

export const removeClubHostCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/remove_club_host_payload.schema.json",
  "title": "RemoveClubHostCallablePayload",
  "description": "Callable payload accepted by removeClubHost.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "clubId",
    "uid"
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
    }
  }
} as const;

export const transferClubOwnershipCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/transfer_club_ownership_payload.schema.json",
  "title": "TransferClubOwnershipCallablePayload",
  "description": "Callable payload accepted by transferClubOwnership.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "clubId",
    "uid"
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
    }
  }
} as const;

export const requestClubClaimCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/request_club_claim_payload.schema.json",
  "title": "RequestClubClaimCallablePayload",
  "description": "Callable payload accepted by requestClubClaim.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "clubId",
    "requesterName",
    "requesterRole"
  ],
  "properties": {
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "requesterName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "requesterRole": {
      "type": "string",
      "enum": [
        "owner",
        "founder",
        "manager",
        "marketer",
        "venueManager",
        "other"
      ]
    },
    "businessEmail": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 320
    },
    "businessPhone": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 32
    },
    "proofUrls": {
      "type": "array",
      "maxItems": 8,
      "items": {
        "type": "string",
        "format": "uri",
        "maxLength": 2048
      },
      "uniqueItems": true
    },
    "message": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000
    }
  }
} as const;

export const requestClubClaimCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/request_club_claim_response.schema.json",
  "title": "RequestClubClaimCallableResponse",
  "description": "Callable response returned by requestClubClaim after a public organizer claim request is accepted for review.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "requestId",
    "status"
  ],
  "properties": {
    "requestId": {
      "type": "string",
      "minLength": 1
    },
    "status": {
      "type": "string",
      "enum": [
        "pending"
      ]
    }
  }
} as const;

export const adminDecideClubClaimCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_decide_club_claim_payload.schema.json",
  "title": "AdminDecideClubClaimCallablePayload",
  "description": "Callable payload accepted by adminDecideClubClaim.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "requestId",
    "decision"
  ],
  "properties": {
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "decision": {
      "type": "string",
      "enum": [
        "approve",
        "reject"
      ]
    },
    "decisionReason": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000
    }
  }
} as const;

export const adminDecideOrganizerIntakeCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_decide_organizer_intake_payload.schema.json",
  "title": "AdminDecideOrganizerIntakeCallablePayload",
  "description": "Callable payload accepted by adminDecideOrganizerIntake. This records a manual admin review decision for a private organizer-intake candidate.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "entityId",
    "decision",
    "appVisibility",
    "checklist",
    "note"
  ],
  "properties": {
    "entityId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "decision": {
      "type": "string",
      "enum": [
        "approve_public",
        "hold",
        "suppress"
      ]
    },
    "appVisibility": {
      "type": "string",
      "enum": [
        "hidden",
        "discoverable"
      ]
    },
    "checklist": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "identityReviewed",
        "surfaceInventoryReviewed",
        "ownerSafeCopyReviewed",
        "marketScopeReviewed",
        "mediaRightsReviewed",
        "crawlDisabledReviewed"
      ],
      "properties": {
        "identityReviewed": {
          "type": "boolean"
        },
        "surfaceInventoryReviewed": {
          "type": "boolean"
        },
        "ownerSafeCopyReviewed": {
          "type": "boolean"
        },
        "marketScopeReviewed": {
          "type": "boolean"
        },
        "mediaRightsReviewed": {
          "type": "boolean"
        },
        "crawlDisabledReviewed": {
          "type": "boolean"
        },
        "manualReportsReviewed": {
          "type": "boolean",
          "description": "True when the reviewer explicitly inspected manual reports that have no local raw artifact. Raw evidence remains outside Firestore; replay validation decides when this acknowledgement is required."
        }
      }
    },
    "note": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
    }
  }
} as const;

export const adminRecordOrganizerCurationCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_record_organizer_curation_payload.schema.json",
  "title": "AdminRecordOrganizerCurationCallablePayload",
  "description": "Callable payload accepted by adminRecordOrganizerCuration. This records one low-volume manual organizer-intake curation operation for deterministic export into repo-backed curation batches.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "operationType",
    "reason"
  ],
  "properties": {
    "operationId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "operationType": {
      "type": "string",
      "enum": [
        "attach_surface",
        "merge_entity",
        "split_surface",
        "suppress_entity",
        "surface_decision"
      ]
    },
    "entityId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "sourceEntityId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "targetEntityId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "surfaceId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "newEntityId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "sourceCandidateId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "decision": {
      "type": "string",
      "enum": [
        "accept_primary",
        "accept_secondary",
        "reject_wrong_entity",
        "mark_ambiguous",
        "mark_historical"
      ]
    },
    "surface": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "surfaceId",
        "platform",
        "surfaceKind",
        "url",
        "normalizedKey",
        "role",
        "status",
        "confidence",
        "crawl",
        "evidenceRefs",
        "notes"
      ],
      "properties": {
        "surfaceId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "platform": {
          "type": "string",
          "enum": [
            "bookMyShow",
            "district",
            "instagram",
            "linkedin",
            "luma",
            "news",
            "officialWebsite",
            "partiful",
            "sortMyScene",
            "userReport",
            "other"
          ]
        },
        "surfaceKind": {
          "type": "string",
          "enum": [
            "eventListing",
            "eventCalendar",
            "organizerProfile",
            "personProfile",
            "press",
            "socialProfile",
            "website",
            "wrongEntity"
          ]
        },
        "url": {
          "anyOf": [
            {
              "type": "string",
              "format": "uri"
            },
            {
              "type": "null"
            }
          ]
        },
        "normalizedKey": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 240
        },
        "role": {
          "type": "string",
          "enum": [
            "primary",
            "secondary",
            "backup",
            "historical",
            "ambiguous",
            "rejected"
          ]
        },
        "status": {
          "type": "string",
          "enum": [
            "active",
            "candidate",
            "ambiguous",
            "historical",
            "rejected"
          ]
        },
        "confidence": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "entityMatch",
            "ownership",
            "city"
          ],
          "properties": {
            "entityMatch": {
              "type": "string",
              "enum": [
                "low",
                "medium",
                "high"
              ]
            },
            "ownership": {
              "type": "string",
              "enum": [
                "low",
                "medium",
                "high"
              ]
            },
            "city": {
              "type": "string",
              "enum": [
                "low",
                "medium",
                "high"
              ]
            }
          }
        },
        "crawl": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "eventDiscoveryStatus",
            "policy",
            "supportsEventExtraction"
          ],
          "properties": {
            "eventDiscoveryStatus": {
              "type": "string",
              "enum": [
                "disabled",
                "candidate",
                "approved",
                "paused"
              ]
            },
            "policy": {
              "type": "string",
              "enum": [
                "manualOnly",
                "blocked",
                "apiPreferred"
              ]
            },
            "supportsEventExtraction": {
              "type": "boolean"
            }
          }
        },
        "evidenceRefs": {
          "type": "array",
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "type",
              "ref",
              "description"
            ],
            "properties": {
              "type": {
                "type": "string",
                "enum": [
                  "hostDiscoveryRun",
                  "seedClub",
                  "userReportedSearchResult",
                  "manualNote"
                ]
              },
              "ref": {
                "type": [
                  "string",
                  "null"
                ],
                "maxLength": 240
              },
              "description": {
                "type": "string",
                "minLength": 1,
                "maxLength": 400
              }
            }
          }
        },
        "notes": {
          "type": "string",
          "maxLength": 500
        }
      }
    },
    "reason": {
      "type": "string",
      "minLength": 1,
      "maxLength": 500
    }
  },
  "definitions": {
    "urlOrNull": {
      "anyOf": [
        {
          "type": "string",
          "format": "uri"
        },
        {
          "type": "null"
        }
      ]
    },
    "surface": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "surfaceId",
        "platform",
        "surfaceKind",
        "url",
        "normalizedKey",
        "role",
        "status",
        "confidence",
        "crawl",
        "evidenceRefs",
        "notes"
      ],
      "properties": {
        "surfaceId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "platform": {
          "type": "string",
          "enum": [
            "bookMyShow",
            "district",
            "instagram",
            "linkedin",
            "luma",
            "news",
            "officialWebsite",
            "partiful",
            "sortMyScene",
            "userReport",
            "other"
          ]
        },
        "surfaceKind": {
          "type": "string",
          "enum": [
            "eventListing",
            "eventCalendar",
            "organizerProfile",
            "personProfile",
            "press",
            "socialProfile",
            "website",
            "wrongEntity"
          ]
        },
        "url": {
          "anyOf": [
            {
              "type": "string",
              "format": "uri"
            },
            {
              "type": "null"
            }
          ]
        },
        "normalizedKey": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 240
        },
        "role": {
          "type": "string",
          "enum": [
            "primary",
            "secondary",
            "backup",
            "historical",
            "ambiguous",
            "rejected"
          ]
        },
        "status": {
          "type": "string",
          "enum": [
            "active",
            "candidate",
            "ambiguous",
            "historical",
            "rejected"
          ]
        },
        "confidence": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "entityMatch",
            "ownership",
            "city"
          ],
          "properties": {
            "entityMatch": {
              "type": "string",
              "enum": [
                "low",
                "medium",
                "high"
              ]
            },
            "ownership": {
              "type": "string",
              "enum": [
                "low",
                "medium",
                "high"
              ]
            },
            "city": {
              "type": "string",
              "enum": [
                "low",
                "medium",
                "high"
              ]
            }
          }
        },
        "crawl": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "eventDiscoveryStatus",
            "policy",
            "supportsEventExtraction"
          ],
          "properties": {
            "eventDiscoveryStatus": {
              "type": "string",
              "enum": [
                "disabled",
                "candidate",
                "approved",
                "paused"
              ]
            },
            "policy": {
              "type": "string",
              "enum": [
                "manualOnly",
                "blocked",
                "apiPreferred"
              ]
            },
            "supportsEventExtraction": {
              "type": "boolean"
            }
          }
        },
        "evidenceRefs": {
          "type": "array",
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "type",
              "ref",
              "description"
            ],
            "properties": {
              "type": {
                "type": "string",
                "enum": [
                  "hostDiscoveryRun",
                  "seedClub",
                  "userReportedSearchResult",
                  "manualNote"
                ]
              },
              "ref": {
                "type": [
                  "string",
                  "null"
                ],
                "maxLength": 240
              },
              "description": {
                "type": "string",
                "minLength": 1,
                "maxLength": 400
              }
            }
          }
        },
        "notes": {
          "type": "string",
          "maxLength": 500
        }
      }
    },
    "evidenceRef": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "type",
        "ref",
        "description"
      ],
      "properties": {
        "type": {
          "type": "string",
          "enum": [
            "hostDiscoveryRun",
            "seedClub",
            "userReportedSearchResult",
            "manualNote"
          ]
        },
        "ref": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 240
        },
        "description": {
          "type": "string",
          "minLength": 1,
          "maxLength": 400
        }
      }
    }
  }
} as const;

export const adminRecordEventIntakeReviewDecisionCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_record_event_intake_review_decision_payload.schema.json",
  "title": "AdminRecordEventIntakeReviewDecisionCallablePayload",
  "description": "Callable payload accepted by adminRecordEventIntakeReviewDecision. This records a manual admin decision for private event-intake artifacts without publishing marketing content or creating canonical events.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "targetType",
    "targetId",
    "decision",
    "checklist",
    "note"
  ],
  "properties": {
    "targetType": {
      "type": "string",
      "enum": [
        "source_profile",
        "query_template",
        "run_plan",
        "source_result",
        "event_candidate"
      ]
    },
    "targetId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "decision": {
      "type": "string",
      "enum": [
        "approve",
        "needs_changes",
        "hold",
        "reject"
      ]
    },
    "runId": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 180
    },
    "note": {
      "type": "string",
      "minLength": 1,
      "maxLength": 2000
    },
    "edits": {
      "type": "object",
      "additionalProperties": true
    },
    "checklist": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "sourceReviewed",
        "dateReviewed",
        "venueReviewed",
        "copyReviewed",
        "rightsReviewed",
        "noCatchHostingImplied"
      ],
      "properties": {
        "sourceReviewed": {
          "type": "boolean"
        },
        "dateReviewed": {
          "type": "boolean"
        },
        "venueReviewed": {
          "type": "boolean"
        },
        "copyReviewed": {
          "type": "boolean"
        },
        "rightsReviewed": {
          "type": "boolean"
        },
        "noCatchHostingImplied": {
          "type": "boolean"
        }
      }
    }
  }
} as const;

export const adminDecideOrganizerEventCandidateCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_decide_organizer_event_candidate_payload.schema.json",
  "title": "AdminDecideOrganizerEventCandidateCallablePayload",
  "description": "Callable payload accepted by adminDecideOrganizerEventCandidate. This records a manual admin review decision for a private external event candidate without importing the event.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "candidateId",
    "decision",
    "checklist",
    "note"
  ],
  "properties": {
    "candidateId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "decision": {
      "type": "string",
      "enum": [
        "approve_for_import",
        "hold",
        "reject"
      ]
    },
    "checklist": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "identityReviewed",
        "sourceEventReviewed",
        "timeReviewed",
        "locationReviewed",
        "dedupeReviewed",
        "ownerSafeCopyReviewed",
        "importPolicyAcknowledged"
      ],
      "properties": {
        "identityReviewed": {
          "type": "boolean"
        },
        "sourceEventReviewed": {
          "type": "boolean"
        },
        "timeReviewed": {
          "type": "boolean"
        },
        "locationReviewed": {
          "type": "boolean"
        },
        "dedupeReviewed": {
          "type": "boolean"
        },
        "ownerSafeCopyReviewed": {
          "type": "boolean"
        },
        "importPolicyAcknowledged": {
          "type": "boolean"
        }
      }
    },
    "note": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
    }
  }
} as const;

export const adminDecideOrganizerPolicyGapCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_decide_organizer_policy_gap_payload.schema.json",
  "title": "AdminDecideOrganizerPolicyGapCallablePayload",
  "description": "Callable payload accepted by adminDecideOrganizerPolicyGap. This records a manual product/admin review decision for an organizer intake policy gap without enabling crawls, provider lookups, imports, defaults, or naming migrations.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "gapId",
    "decision",
    "requiredInputsReviewed",
    "checklist",
    "note"
  ],
  "properties": {
    "gapId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160
    },
    "decision": {
      "type": "string",
      "enum": [
        "accept",
        "hold",
        "reject"
      ]
    },
    "requiredInputsReviewed": {
      "type": "array",
      "maxItems": 20,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 240
      },
      "uniqueItems": true
    },
    "checklist": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "requiredInputsReviewed",
        "costAndSafetyReviewed",
        "implementationOwnerReviewed",
        "behaviorStillDisabledAcknowledged"
      ],
      "properties": {
        "requiredInputsReviewed": {
          "type": "boolean"
        },
        "costAndSafetyReviewed": {
          "type": "boolean"
        },
        "implementationOwnerReviewed": {
          "type": "boolean"
        },
        "behaviorStillDisabledAcknowledged": {
          "type": "boolean"
        }
      }
    },
    "note": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
    }
  }
} as const;

export const adminResolveOrganizerEventLocationCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_resolve_organizer_event_location_payload.schema.json",
  "title": "AdminResolveOrganizerEventLocationCallablePayload",
  "description": "Callable payload accepted by adminResolveOrganizerEventLocation. This records reviewed coordinates for a private external event candidate without importing the event.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "candidateId",
    "location",
    "checklist",
    "note"
  ],
  "properties": {
    "candidateId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "location": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "name",
        "latitude",
        "longitude"
      ],
      "properties": {
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 240
        },
        "address": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 500
        },
        "placeId": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 256
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
        "notes": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 1000
        }
      }
    },
    "checklist": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "sourceLocationReviewed",
        "coordinatesReviewed",
        "placeIdentityReviewed",
        "importSafetyReviewed"
      ],
      "properties": {
        "sourceLocationReviewed": {
          "type": "boolean"
        },
        "coordinatesReviewed": {
          "type": "boolean"
        },
        "placeIdentityReviewed": {
          "type": "boolean"
        },
        "importSafetyReviewed": {
          "type": "boolean"
        }
      }
    },
    "note": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
    }
  }
} as const;

export const adminSetClubIndexStatusCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_set_club_index_status_payload.schema.json",
  "title": "AdminSetClubIndexStatusCallablePayload",
  "description": "Callable payload accepted by adminSetClubIndexStatus.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "clubId",
    "indexStatus",
    "checklist"
  ],
  "properties": {
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "indexStatus": {
      "type": "string",
      "enum": [
        "noindex",
        "indexReady",
        "indexed"
      ]
    },
    "checklist": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "sourceEvidenceVerified",
        "mediaRightsVerified",
        "cadenceVerified",
        "ownerContactVerified"
      ],
      "properties": {
        "sourceEvidenceVerified": {
          "type": "boolean"
        },
        "mediaRightsVerified": {
          "type": "boolean"
        },
        "cadenceVerified": {
          "type": "boolean"
        },
        "ownerContactVerified": {
          "type": "boolean"
        }
      }
    },
    "reviewNote": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000
    }
  }
} as const;

export const adminGetClubDetailsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_get_club_details_payload.schema.json",
  "title": "AdminGetClubDetailsCallablePayload",
  "description": "Callable payload accepted by adminGetClubDetails.",
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

export const adminListClubDetailsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_list_club_details_payload.schema.json",
  "title": "AdminListClubDetailsCallablePayload",
  "description": "Callable payload accepted by adminListClubDetails. This lists canonical organizer profile rows from clubs/{clubId} for the admin publishing workspace.",
  "type": "object",
  "additionalProperties": false,
  "properties": {
    "query": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 160
    },
    "citySlug": {
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
      ]
    },
    "citySlugs": {
      "anyOf": [
        {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120,
            "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
          },
          "minItems": 1,
          "maxItems": 10,
          "uniqueItems": true
        },
        {
          "type": "null"
        }
      ]
    },
    "publishStatus": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "draft",
        "qa",
        "published",
        "suppressed",
        "removed",
        null
      ]
    },
    "appVisibility": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "discoverable",
        "hidden",
        null
      ]
    },
    "limit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 100
    }
  }
} as const;

export const adminUpdateClubDetailsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_update_club_details_payload.schema.json",
  "title": "AdminUpdateClubDetailsCallablePayload",
  "description": "Callable payload accepted by adminUpdateClubDetails. This edits owner-safe organizer listing fields through an audited admin callable.",
  "x-callable-shape": "patch",
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
          "type": "string",
          "minLength": 1,
          "maxLength": 120,
          "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
        },
        "area": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
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
        "profileImageUrl": {
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
        "entityKind": {
          "type": "string",
          "enum": [
            "club",
            "venue",
            "eventOrganizer",
            "creatorCommunity",
            "brand"
          ]
        },
        "entitySubtypes": {
          "type": "array",
          "maxItems": 20,
          "uniqueItems": true,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          }
        },
        "displayCategory": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 120
        },
        "cityName": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 120
        },
        "regionName": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 120
        },
        "countryCode": {
          "type": [
            "string",
            "null"
          ],
          "pattern": "^[A-Z]{2}$"
        },
        "countryName": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 120
        },
        "appVisibility": {
          "type": "string",
          "enum": [
            "discoverable",
            "hidden"
          ]
        },
        "publicPage": {
          "type": "object",
          "additionalProperties": false,
          "minProperties": 1,
          "properties": {
            "slug": {
              "type": "string",
              "minLength": 1,
              "maxLength": 160,
              "pattern": "^[a-z0-9-]+$"
            },
            "citySlug": {
              "type": [
                "string",
                "null"
              ],
              "minLength": 1,
              "maxLength": 80,
              "pattern": "^[a-z0-9-]+$"
            },
            "canonicalPath": {
              "type": "string",
              "minLength": 1,
              "maxLength": 240
            },
            "publishStatus": {
              "type": "string",
              "enum": [
                "draft",
                "qa",
                "published",
                "suppressed",
                "removed"
              ]
            },
            "seoTitle": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 120
            },
            "seoDescription": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 320
            }
          }
        },
        "provenance": {
          "type": "object",
          "additionalProperties": false,
          "minProperties": 1,
          "properties": {
            "sourceConfidence": {
              "type": "string",
              "enum": [
                "seedOnly",
                "low",
                "medium",
                "high",
                "ownerVerified"
              ]
            },
            "verificationStatus": {
              "type": "string",
              "enum": [
                "unverified",
                "sourceBacked",
                "ownerVerified"
              ]
            }
          }
        },
        "publicProfile": {
          "type": "object",
          "additionalProperties": false,
          "minProperties": 1,
          "properties": {
            "headline": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 160
            },
            "summary": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 800
            },
            "sourceSummary": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 800
            },
            "formats": {
              "type": "array",
              "maxItems": 12,
              "items": {
                "type": "string",
                "minLength": 1,
                "maxLength": 80
              }
            },
            "fitNotes": {
              "type": "array",
              "maxItems": 8,
              "items": {
                "type": "string",
                "minLength": 1,
                "maxLength": 400
              }
            },
            "missingEvidence": {
              "type": "array",
              "maxItems": 12,
              "items": {
                "type": "string",
                "minLength": 1,
                "maxLength": 200
              }
            }
          }
        }
      }
    },
    "reviewNote": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000
    }
  }
} as const;

export const adminGetEventDetailsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_get_event_details_payload.schema.json",
  "title": "AdminGetEventDetailsCallablePayload",
  "description": "Callable payload accepted by adminGetEventDetails. This loads a canonical events/{eventId} document for the admin event publishing workspace.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;

export const adminListEventDetailsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_list_event_details_payload.schema.json",
  "title": "AdminListEventDetailsCallablePayload",
  "description": "Callable payload accepted by adminListEventDetails. This lists canonical events/{eventId} rows for the admin event publishing workspace.",
  "type": "object",
  "additionalProperties": false,
  "properties": {
    "query": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 160
    },
    "clubId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "citySlug": {
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
      ]
    },
    "citySlugs": {
      "anyOf": [
        {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120,
            "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$"
          },
          "minItems": 1,
          "maxItems": 10,
          "uniqueItems": true
        },
        {
          "type": "null"
        }
      ]
    },
    "activityKind": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "socialRun",
        "running",
        "walking",
        "pickleball",
        "padel",
        "tennis",
        "badminton",
        "cycling",
        "spinClass",
        "yoga",
        "strengthTraining",
        "pubQuiz",
        "barCrawl",
        "dinner",
        "singlesMixer",
        "openActivity",
        null
      ]
    },
    "status": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "active",
        "cancelled",
        null
      ]
    },
    "timeWindow": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "upcoming",
        "past",
        "all",
        null
      ],
      "description": "Optional server-side startTime window used by admin event lists. Upcoming and past are evaluated against callable server time."
    },
    "limit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 100
    }
  }
} as const;

export const adminListExternalEventDetailsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_list_external_event_details_payload.schema.json",
  "title": "AdminListExternalEventDetailsCallablePayload",
  "description": "Callable payload accepted by adminListExternalEventDetails. This lists read-only externalEvents/{eventId} rows for the admin event supply workspace.",
  "type": "object",
  "additionalProperties": false,
  "properties": {
    "query": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 160
    },
    "citySlug": {
      "anyOf": [
        {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 80,
          "pattern": "^[a-z0-9-]+$"
        },
        {
          "type": "null"
        }
      ]
    },
    "citySlugs": {
      "anyOf": [
        {
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
          "maxItems": 10,
          "uniqueItems": true
        },
        {
          "type": "null"
        }
      ]
    },
    "publicationStatus": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "draft",
        "public",
        "archived",
        "removed",
        null
      ]
    },
    "status": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "active",
        "cancelled",
        null
      ]
    },
    "timeWindow": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "upcoming",
        "past",
        "all",
        null
      ],
      "description": "Optional server-side startTime window used by admin external event lists. Upcoming and past are evaluated against callable server time."
    },
    "limit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 100
    }
  }
} as const;

export const adminUpdateEventDetailsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_update_event_details_payload.schema.json",
  "title": "AdminUpdateEventDetailsCallablePayload",
  "description": "Callable payload accepted by adminUpdateEventDetails. This edits low-risk app-facing canonical event fields through an audited admin callable.",
  "x-callable-shape": "patch",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "fields"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "reviewNote": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 1000
    },
    "fields": {
      "type": "object",
      "additionalProperties": false,
      "minProperties": 1,
      "properties": {
        "description": {
          "type": "string",
          "maxLength": 2000
        },
        "photoUrl": {
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
        "distanceKm": {
          "type": "number",
          "minimum": 0,
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
        "eventFormat": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "version",
            "activityKind",
            "interactionModel"
          ],
          "properties": {
            "version": {
              "type": "integer",
              "const": 1
            },
            "activityKind": {
              "type": "string",
              "enum": [
                "socialRun",
                "running",
                "walking",
                "pickleball",
                "padel",
                "tennis",
                "badminton",
                "cycling",
                "spinClass",
                "yoga",
                "strengthTraining",
                "pubQuiz",
                "barCrawl",
                "dinner",
                "singlesMixer",
                "openActivity"
              ]
            },
            "interactionModel": {
              "type": "string",
              "enum": [
                "pacePods",
                "pairedRotations",
                "teamRotations",
                "seatedTable",
                "freeFormMixer",
                "hostLedProgram",
                "openFormat"
              ]
            },
            "customActivityLabel": {
              "type": "string",
              "minLength": 1,
              "maxLength": 80
            },
            "defaultPlaybookId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 120
            },
            "defaultModuleIds": {
              "type": "array",
              "items": {
                "type": "string",
                "minLength": 1,
                "maxLength": 120
              },
              "maxItems": 30,
              "uniqueItems": true
            },
            "eventSuccessPrimitives": {
              "type": "object",
              "additionalProperties": false,
              "description": "Optional event-success behavior primitives for custom or unsupported activity formats. These fields translate a saved event format into the small set of primitives event success can reason about.",
              "properties": {
                "phoneAvailability": {
                  "type": "string",
                  "enum": [
                    "continuous",
                    "plannedPauses",
                    "arrivalAndPostEventOnly",
                    "hostOnlyLive",
                    "noneDuringActivity"
                  ]
                },
                "rotationSuitability": {
                  "type": "string",
                  "enum": [
                    "none",
                    "plannedBreaks",
                    "continuousRounds"
                  ]
                },
                "assignmentAlgorithm": {
                  "type": "string",
                  "enum": [
                    "none",
                    "pacePods",
                    "socialPods",
                    "pairRotations",
                    "teamBalancer",
                    "tableSeating"
                  ]
                },
                "compatibilityPolicy": {
                  "type": "string",
                  "enum": [
                    "none",
                    "socialCohortBalance",
                    "mutualInterestOnly",
                    "questionnaireClueOnly"
                  ]
                }
              }
            },
            "activityDetails": {
              "type": "object",
              "additionalProperties": true
            }
          }
        }
      }
    }
  }
} as const;

export const adminPublishExternalEventCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_publish_external_event_payload.schema.json",
  "title": "AdminPublishExternalEventCallablePayload",
  "description": "Callable payload accepted by adminPublishExternalEvent. This publishes one preflight-approved read-only externalEvents/{eventId} document from eventSupplyReadiness/current.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "sourceActionId",
    "targetPath",
    "reviewNote",
    "checklist"
  ],
  "properties": {
    "sourceActionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "targetPath": {
      "type": "string",
      "pattern": "^externalEvents/[A-Za-z0-9_-]{1,180}$"
    },
    "reviewNote": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
    },
    "checklist": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "preflightActionReviewed",
        "outboundLinksReviewed",
        "noCatchBookingPaymentsWaitlist",
        "ownerSafeCopyReviewed"
      ],
      "properties": {
        "preflightActionReviewed": {
          "type": "boolean"
        },
        "outboundLinksReviewed": {
          "type": "boolean"
        },
        "noCatchBookingPaymentsWaitlist": {
          "type": "boolean"
        },
        "ownerSafeCopyReviewed": {
          "type": "boolean"
        }
      }
    }
  }
} as const;

export const startClubHostConversationCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/start_club_host_conversation_payload.schema.json",
  "title": "StartClubHostConversationCallablePayload",
  "description": "Callable payload accepted by startClubHostConversation.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "clubId",
    "hostUid"
  ],
  "properties": {
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "hostUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;

export const archiveClubCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/archive_club_payload.schema.json",
  "title": "ArchiveClubCallablePayload",
  "description": "Callable payload accepted by archiveClub.",
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

export const deleteClubCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/delete_club_payload.schema.json",
  "title": "DeleteClubCallablePayload",
  "description": "Callable payload accepted by deleteClub.",
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

export const clubMembershipCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/club_membership_payload.schema.json",
  "title": "ClubMembershipCallablePayload",
  "description": "Callable payload accepted by joinClub and leaveClub.",
  "x-callable-aliases": [
    "joinClub",
    "leaveClub"
  ],
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

export const setClubNotificationPreferenceCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/set_club_notification_preference_payload.schema.json",
  "title": "SetClubNotificationPreferenceCallablePayload",
  "description": "Callable payload accepted by setClubNotificationPreference.",
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

export const createEventCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_event_payload.schema.json",
  "title": "CreateEventCallablePayload",
  "description": "Callable payload accepted by createEvent.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "clubId",
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
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "clubId": {
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
    "meetingLocation": {
      "type": "object",
      "additionalProperties": false,
      "description": "Canonical meeting location selected from Google Places or a manually pinned map coordinate.",
      "required": [
        "name",
        "latitude",
        "longitude"
      ],
      "properties": {
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 240
        },
        "address": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 500
        },
        "placeId": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 256
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
        },
        "notes": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 1000
        }
      }
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
    "photoUrl": {
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
    "eventPhotos": {
      "type": "array",
      "maxItems": 12,
      "items": {
        "title": "UploadedPhoto",
        "description": "Canonical uploaded image object for ordered media galleries, logos, and event photos.",
        "type": "object",
        "additionalProperties": false,
        "required": [
          "id",
          "url",
          "storagePath",
          "thumbnailUrl",
          "thumbnailStoragePath",
          "position",
          "createdAt",
          "updatedAt"
        ],
        "properties": {
          "id": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120,
            "pattern": "^[A-Za-z0-9_-]+$"
          },
          "url": {
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
          "thumbnailUrl": {
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
          "thumbnailStoragePath": {
            "anyOf": [
              {
                "type": "string",
                "minLength": 1,
                "maxLength": 512,
                "pattern": "^[^/\\u0000][^\\u0000]*$"
              },
              {
                "type": "null"
              }
            ]
          },
          "position": {
            "type": "integer",
            "minimum": 0,
            "maximum": 19
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
        }
      }
    },
    "distanceKm": {
      "type": "number",
      "minimum": 0,
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
    "currency": {
      "type": "string",
      "pattern": "^[A-Z]{3}$"
    },
    "eventPolicy": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "version",
        "admission",
        "pricing",
        "cancellation",
        "settlement"
      ],
      "properties": {
        "version": {
          "type": "integer",
          "const": 1
        },
        "admission": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "format",
            "capacityLimit",
            "waitlistPolicy",
            "inviteRequired",
            "membershipRequired",
            "manualApprovalRequired",
            "privateAccessPolicy",
            "cohortCapacityLimits",
            "balancedRatioPolicy"
          ],
          "properties": {
            "format": {
              "type": "string",
              "enum": [
                "open",
                "inviteOnly",
                "manualApproval",
                "fixedCohortCaps",
                "balancedRatio",
                "membersOnly"
              ]
            },
            "capacityLimit": {
              "type": "integer",
              "minimum": 1,
              "maximum": 1000
            },
            "waitlistPolicy": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode",
                "offerWindowMinutes"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "enum": [
                    "disabled",
                    "rankedOffer",
                    "broadcastFirstComeFirstServed",
                    "manualReview"
                  ]
                },
                "offerWindowMinutes": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 10080
                }
              }
            },
            "inviteRequired": {
              "type": "boolean"
            },
            "membershipRequired": {
              "type": "boolean"
            },
            "manualApprovalRequired": {
              "type": "boolean"
            },
            "privateAccessPolicy": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "mode",
                "inviteCodeHint",
                "privateLinkEnabled"
              ],
              "properties": {
                "mode": {
                  "type": "string",
                  "enum": [
                    "none",
                    "inviteCode"
                  ]
                },
                "inviteCodeHint": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "maxLength": 64
                },
                "privateLinkEnabled": {
                  "type": "boolean"
                }
              }
            },
            "cohortCapacityLimits": {
              "type": "object",
              "additionalProperties": {
                "type": "integer",
                "minimum": 0
              }
            },
            "balancedRatioPolicy": {
              "type": [
                "object",
                "null"
              ],
              "additionalProperties": false,
              "required": [
                "leftCohortId",
                "rightCohortId",
                "maxSkew",
                "openingBufferPerCohort",
                "outOfRatioCohortPolicy"
              ],
              "properties": {
                "leftCohortId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 120
                },
                "rightCohortId": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 120
                },
                "maxSkew": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 1000
                },
                "openingBufferPerCohort": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 1000
                },
                "outOfRatioCohortPolicy": {
                  "type": "string",
                  "enum": [
                    "admitWithinGeneralCapacity",
                    "waitlist",
                    "manualReview",
                    "reject"
                  ]
                }
              }
            }
          }
        },
        "pricing": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "basePriceInPaise",
            "cohortAdjustmentsInPaise",
            "demandPricingRules"
          ],
          "properties": {
            "basePriceInPaise": {
              "type": "integer",
              "minimum": 0,
              "maximum": 100000000
            },
            "cohortAdjustmentsInPaise": {
              "type": "object",
              "additionalProperties": {
                "type": "integer",
                "minimum": -100000000,
                "maximum": 100000000
              }
            },
            "demandPricingRules": {
              "type": "array",
              "maxItems": 20,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "pricedCohortId",
                  "balancingCohortId",
                  "stepAdjustmentInPaise",
                  "maxAdjustmentInPaise",
                  "freeSkew",
                  "demandStep"
                ],
                "properties": {
                  "pricedCohortId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 120
                  },
                  "balancingCohortId": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 120
                  },
                  "stepAdjustmentInPaise": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 100000000
                  },
                  "maxAdjustmentInPaise": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 100000000
                  },
                  "freeSkew": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 1000
                  },
                  "demandStep": {
                    "type": "integer",
                    "minimum": 1,
                    "maximum": 1000
                  }
                }
              }
            }
          }
        },
        "cancellation": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "policyId"
          ],
          "properties": {
            "policyId": {
              "type": "string",
              "enum": [
                "flexible",
                "standard",
                "strict"
              ]
            }
          }
        },
        "settlement": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "hostPayoutTiming"
          ],
          "properties": {
            "hostPayoutTiming": {
              "type": "string",
              "enum": [
                "afterEventCompletion"
              ]
            }
          }
        }
      }
    },
    "privateAccess": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "inviteCode": {
          "type": "string",
          "minLength": 4,
          "maxLength": 64,
          "pattern": "^[A-Za-z0-9_-]+$"
        }
      }
    },
    "eventFormat": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "version",
        "activityKind",
        "interactionModel"
      ],
      "properties": {
        "version": {
          "type": "integer",
          "const": 1
        },
        "activityKind": {
          "type": "string",
          "enum": [
            "socialRun",
            "running",
            "walking",
            "pickleball",
            "padel",
            "tennis",
            "badminton",
            "cycling",
            "spinClass",
            "yoga",
            "strengthTraining",
            "pubQuiz",
            "barCrawl",
            "dinner",
            "singlesMixer",
            "openActivity"
          ]
        },
        "interactionModel": {
          "type": "string",
          "enum": [
            "pacePods",
            "pairedRotations",
            "teamRotations",
            "seatedTable",
            "freeFormMixer",
            "hostLedProgram",
            "openFormat"
          ]
        },
        "customActivityLabel": {
          "type": "string",
          "minLength": 1,
          "maxLength": 80
        },
        "defaultPlaybookId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "defaultModuleIds": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "maxItems": 30,
          "uniqueItems": true
        },
        "eventSuccessPrimitives": {
          "type": "object",
          "additionalProperties": false,
          "description": "Optional event-success behavior primitives for custom or unsupported activity formats. These fields translate a saved event format into the small set of primitives event success can reason about.",
          "properties": {
            "phoneAvailability": {
              "type": "string",
              "enum": [
                "continuous",
                "plannedPauses",
                "arrivalAndPostEventOnly",
                "hostOnlyLive",
                "noneDuringActivity"
              ]
            },
            "rotationSuitability": {
              "type": "string",
              "enum": [
                "none",
                "plannedBreaks",
                "continuousRounds"
              ]
            },
            "assignmentAlgorithm": {
              "type": "string",
              "enum": [
                "none",
                "pacePods",
                "socialPods",
                "pairRotations",
                "teamBalancer",
                "tableSeating"
              ]
            },
            "compatibilityPolicy": {
              "type": "string",
              "enum": [
                "none",
                "socialCohortBalance",
                "mutualInterestOnly",
                "questionnaireClueOnly"
              ]
            }
          }
        },
        "activityDetails": {
          "type": "object",
          "additionalProperties": true
        }
      }
    },
    "eventSuccessDefaults": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
        "enabled": {
          "type": "boolean"
        },
        "playbookId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 120
        },
        "selectedModuleIds": {
          "type": "array",
          "maxItems": 24,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          }
        },
        "structureConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "unitKind",
            "unitSize",
            "revealCountdownSeconds"
          ],
          "properties": {
            "unitKind": {
              "type": "string",
              "enum": [
                "wholeGroup",
                "pods",
                "pairs",
                "teams",
                "tables"
              ]
            },
            "unitSize": {
              "type": "integer",
              "minimum": 1,
              "maximum": 1000
            },
            "unitCount": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 1,
              "maximum": 200
            },
            "rotationIntervalMinutes": {
              "type": [
                "integer",
                "null"
              ],
              "minimum": 5,
              "maximum": 180
            },
            "revealCountdownSeconds": {
              "type": "integer",
              "minimum": 0,
              "maximum": 60
            },
            "rotationRepeatStrategy": {
              "type": "string",
              "enum": [
                "avoid",
                "allowWhenExhausted"
              ]
            },
            "maxPairMeetings": {
              "type": "integer",
              "minimum": 1,
              "maximum": 10
            },
            "balanceActivityAttributes": {
              "type": "array",
              "maxItems": 8,
              "uniqueItems": true,
              "items": {
                "type": "string",
                "enum": [
                  "paceBand",
                  "skillBand",
                  "roleBand"
                ]
              }
            },
            "clusterActivityAttributes": {
              "type": "array",
              "maxItems": 8,
              "uniqueItems": true,
              "items": {
                "type": "string",
                "enum": [
                  "paceBand",
                  "skillBand",
                  "roleBand"
                ]
              }
            }
          }
        },
        "hostGoal": {
          "type": "string",
          "maxLength": 300
        },
        "wingmanRequestsEnabled": {
          "type": "boolean"
        },
        "contextualOpenersEnabled": {
          "type": "boolean"
        },
        "compatibilityAffectsRanking": {
          "type": "boolean"
        },
        "questionnaireConfig": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "templateId"
          ],
          "properties": {
            "templateId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 120
            },
            "customTitle": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 80
            },
            "customQuestions": {
              "type": "array",
              "maxItems": 8,
              "items": {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "id",
                  "prompt",
                  "options"
                ],
                "properties": {
                  "id": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 120
                  },
                  "prompt": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 140
                  },
                  "options": {
                    "type": "array",
                    "minItems": 2,
                    "maxItems": 5,
                    "items": {
                      "type": "object",
                      "additionalProperties": false,
                      "required": [
                        "id",
                        "label"
                      ],
                      "properties": {
                        "id": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 120
                        },
                        "label": {
                          "type": "string",
                          "minLength": 1,
                          "maxLength": 80
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        },
        "attendeePrompt": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 300
        }
      }
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

export const updateEventCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/update_event_payload.schema.json",
  "title": "UpdateEventCallablePayload",
  "description": "Callable payload accepted by updateEvent.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "fields"
  ],
  "properties": {
    "eventId": {
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
        "meetingLocation": {
          "type": "object",
          "additionalProperties": false,
          "description": "Canonical meeting location selected from Google Places or a manually pinned map coordinate.",
          "required": [
            "name",
            "latitude",
            "longitude"
          ],
          "properties": {
            "name": {
              "type": "string",
              "minLength": 1,
              "maxLength": 240
            },
            "address": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 500
            },
            "placeId": {
              "type": [
                "string",
                "null"
              ],
              "minLength": 1,
              "maxLength": 256
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
            },
            "notes": {
              "type": [
                "string",
                "null"
              ],
              "maxLength": 1000
            }
          }
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
        "photoUrl": {
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
        "eventPhotos": {
          "type": "array",
          "maxItems": 12,
          "items": {
            "title": "UploadedPhoto",
            "description": "Canonical uploaded image object for ordered media galleries, logos, and event photos.",
            "type": "object",
            "additionalProperties": false,
            "required": [
              "id",
              "url",
              "storagePath",
              "thumbnailUrl",
              "thumbnailStoragePath",
              "position",
              "createdAt",
              "updatedAt"
            ],
            "properties": {
              "id": {
                "type": "string",
                "minLength": 1,
                "maxLength": 120,
                "pattern": "^[A-Za-z0-9_-]+$"
              },
              "url": {
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
              "thumbnailUrl": {
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
              "thumbnailStoragePath": {
                "anyOf": [
                  {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 512,
                    "pattern": "^[^/\\u0000][^\\u0000]*$"
                  },
                  {
                    "type": "null"
                  }
                ]
              },
              "position": {
                "type": "integer",
                "minimum": 0,
                "maximum": 19
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
            }
          }
        },
        "distanceKm": {
          "type": "number",
          "minimum": 0,
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
        },
        "capacityLimit": {
          "type": "integer",
          "minimum": 1,
          "maximum": 1000
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
        },
        "eventPolicy": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "version",
            "admission",
            "pricing",
            "cancellation",
            "settlement"
          ],
          "properties": {
            "version": {
              "type": "integer",
              "const": 1
            },
            "admission": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "format",
                "capacityLimit",
                "waitlistPolicy",
                "inviteRequired",
                "membershipRequired",
                "manualApprovalRequired",
                "privateAccessPolicy",
                "cohortCapacityLimits",
                "balancedRatioPolicy"
              ],
              "properties": {
                "format": {
                  "type": "string",
                  "enum": [
                    "open",
                    "inviteOnly",
                    "manualApproval",
                    "fixedCohortCaps",
                    "balancedRatio",
                    "membersOnly"
                  ]
                },
                "capacityLimit": {
                  "type": "integer",
                  "minimum": 1,
                  "maximum": 1000
                },
                "waitlistPolicy": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "mode",
                    "offerWindowMinutes"
                  ],
                  "properties": {
                    "mode": {
                      "type": "string",
                      "enum": [
                        "disabled",
                        "rankedOffer",
                        "broadcastFirstComeFirstServed",
                        "manualReview"
                      ]
                    },
                    "offerWindowMinutes": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 10080
                    }
                  }
                },
                "inviteRequired": {
                  "type": "boolean"
                },
                "membershipRequired": {
                  "type": "boolean"
                },
                "manualApprovalRequired": {
                  "type": "boolean"
                },
                "privateAccessPolicy": {
                  "type": "object",
                  "additionalProperties": false,
                  "required": [
                    "mode",
                    "inviteCodeHint",
                    "privateLinkEnabled"
                  ],
                  "properties": {
                    "mode": {
                      "type": "string",
                      "enum": [
                        "none",
                        "inviteCode"
                      ]
                    },
                    "inviteCodeHint": {
                      "type": [
                        "string",
                        "null"
                      ],
                      "maxLength": 64
                    },
                    "privateLinkEnabled": {
                      "type": "boolean"
                    }
                  }
                },
                "cohortCapacityLimits": {
                  "type": "object",
                  "additionalProperties": {
                    "type": "integer",
                    "minimum": 0
                  }
                },
                "balancedRatioPolicy": {
                  "type": [
                    "object",
                    "null"
                  ],
                  "additionalProperties": false,
                  "required": [
                    "leftCohortId",
                    "rightCohortId",
                    "maxSkew",
                    "openingBufferPerCohort",
                    "outOfRatioCohortPolicy"
                  ],
                  "properties": {
                    "leftCohortId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 120
                    },
                    "rightCohortId": {
                      "type": "string",
                      "minLength": 1,
                      "maxLength": 120
                    },
                    "maxSkew": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 1000
                    },
                    "openingBufferPerCohort": {
                      "type": "integer",
                      "minimum": 0,
                      "maximum": 1000
                    },
                    "outOfRatioCohortPolicy": {
                      "type": "string",
                      "enum": [
                        "admitWithinGeneralCapacity",
                        "waitlist",
                        "manualReview",
                        "reject"
                      ]
                    }
                  }
                }
              }
            },
            "pricing": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "basePriceInPaise",
                "cohortAdjustmentsInPaise",
                "demandPricingRules"
              ],
              "properties": {
                "basePriceInPaise": {
                  "type": "integer",
                  "minimum": 0,
                  "maximum": 100000000
                },
                "cohortAdjustmentsInPaise": {
                  "type": "object",
                  "additionalProperties": {
                    "type": "integer",
                    "minimum": -100000000,
                    "maximum": 100000000
                  }
                },
                "demandPricingRules": {
                  "type": "array",
                  "maxItems": 20,
                  "items": {
                    "type": "object",
                    "additionalProperties": false,
                    "required": [
                      "pricedCohortId",
                      "balancingCohortId",
                      "stepAdjustmentInPaise",
                      "maxAdjustmentInPaise",
                      "freeSkew",
                      "demandStep"
                    ],
                    "properties": {
                      "pricedCohortId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 120
                      },
                      "balancingCohortId": {
                        "type": "string",
                        "minLength": 1,
                        "maxLength": 120
                      },
                      "stepAdjustmentInPaise": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 100000000
                      },
                      "maxAdjustmentInPaise": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 100000000
                      },
                      "freeSkew": {
                        "type": "integer",
                        "minimum": 0,
                        "maximum": 1000
                      },
                      "demandStep": {
                        "type": "integer",
                        "minimum": 1,
                        "maximum": 1000
                      }
                    }
                  }
                }
              }
            },
            "cancellation": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "policyId"
              ],
              "properties": {
                "policyId": {
                  "type": "string",
                  "enum": [
                    "flexible",
                    "standard",
                    "strict"
                  ]
                }
              }
            },
            "settlement": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "hostPayoutTiming"
              ],
              "properties": {
                "hostPayoutTiming": {
                  "type": "string",
                  "enum": [
                    "afterEventCompletion"
                  ]
                }
              }
            }
          }
        },
        "privateAccess": {
          "type": "object",
          "additionalProperties": false,
          "properties": {
            "inviteCode": {
              "type": [
                "string",
                "null"
              ],
              "minLength": 4,
              "maxLength": 64,
              "pattern": "^[A-Za-z0-9_-]+$"
            }
          }
        }
      }
    }
  }
} as const;

export const cancelEventCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/cancel_event_payload.schema.json",
  "title": "CancelEventCallablePayload",
  "description": "Callable payload accepted by cancelEvent.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId"
  ],
  "properties": {
    "eventId": {
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

export const deleteEventCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/delete_event_payload.schema.json",
  "title": "DeleteEventCallablePayload",
  "description": "Callable payload accepted by deleteEvent.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;

export const eventIdCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/event_id_payload.schema.json",
  "title": "EventIdCallablePayload",
  "description": "Callable payload accepted by simple event actions that need only an eventId (plus optional inviteCode for invite-gated events).",
  "x-callable-aliases": [
    "cancelEventSignUp",
    "deleteEvent",
    "fetchEventSuccessWingmanCandidates",
    "generateEventSuccessPods",
    "generateEventSuccessRotations",
    "acceptEventWaitlistOffer",
    "declineEventWaitlistOffer",
    "joinEventWaitlist",
    "leaveEventWaitlist",
    "withdrawEventSuccessWingmanRequest"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "inviteCode": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 4,
      "maxLength": 64,
      "pattern": "^[A-Za-z0-9_-]+$"
    },
    "inviteLinkId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;

export const createEventWaitlistOffersCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_event_waitlist_offers_payload.schema.json",
  "title": "CreateEventWaitlistOffersCallablePayload",
  "description": "Callable payload accepted by createEventWaitlistOffers.",
  "x-callable-aliases": [
    "createEventWaitlistOffers"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "userIds"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "userIds": {
      "type": "array",
      "minItems": 1,
      "maxItems": 25,
      "uniqueItems": true,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 180
      }
    },
    "expiresInMinutes": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 5,
      "maximum": 1440
    }
  }
} as const;

export const createEventInviteLinkCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_event_invite_link_payload.schema.json",
  "title": "CreateEventInviteLinkCallablePayload",
  "description": "Callable payload accepted by createEventInviteLink. Hosts use this to create named share links such as Instagram bio, WhatsApp alumni, or venue partner.",
  "x-callable-aliases": [
    "createEventInviteLink"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "label"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "label": {
      "type": "string",
      "minLength": 1,
      "maxLength": 80
    },
    "source": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 80
    }
  }
} as const;

export const disableEventInviteLinkCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/disable_event_invite_link_payload.schema.json",
  "title": "DisableEventInviteLinkCallablePayload",
  "description": "Callable payload accepted by disableEventInviteLink. Disabled links stop accepting new attribution but remain in host reporting.",
  "x-callable-aliases": [
    "disableEventInviteLink"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "inviteLinkId"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "inviteLinkId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;

export const recordEventInviteLinkOpenCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/record_event_invite_link_open_payload.schema.json",
  "title": "RecordEventInviteLinkOpenCallablePayload",
  "description": "Callable payload accepted by recordEventInviteLinkOpen. It increments a live open counter and returns whether attribution can be attached to downstream booking actions.",
  "x-callable-aliases": [
    "recordEventInviteLinkOpen"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "inviteLinkId"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "inviteLinkId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;

export const recordOrganizerAnalyticsEventCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/record_organizer_analytics_event_payload.schema.json",
  "title": "RecordOrganizerAnalyticsEventCallablePayload",
  "description": "Public website analytics event for host-visible organizer metrics. The callable validates organizer scope and writes a raw, aggregate-safe event to BigQuery.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "clubId",
    "eventName",
    "pagePath"
  ],
  "properties": {
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "eventId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "eventName": {
      "type": "string",
      "enum": [
        "listingView",
        "searchAppearance",
        "eventView",
        "organizerSave",
        "eventSave",
        "contactClick",
        "claimClick",
        "outboundClick"
      ]
    },
    "pagePath": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "source": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 80
    },
    "sessionId": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 80
    },
    "platform": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 40
    }
  }
} as const;

export const recordOrganizerAnalyticsEventCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/record_organizer_analytics_event_response.schema.json",
  "title": "RecordOrganizerAnalyticsEventCallableResponse",
  "description": "Callable response returned by recordOrganizerAnalyticsEvent after an organizer analytics event is accepted.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "accepted"
  ],
  "properties": {
    "accepted": {
      "type": "boolean"
    }
  }
} as const;

export const markEventAttendanceCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/mark_event_attendance_payload.schema.json",
  "title": "MarkEventAttendanceCallablePayload",
  "description": "Callable payload accepted by markEventAttendance.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "userId"
  ],
  "properties": {
    "eventId": {
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

export const eventJoinRequestDecisionCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/event_join_request_decision_payload.schema.json",
  "title": "EventJoinRequestDecisionCallablePayload",
  "description": "Callable payload accepted by decideEventJoinRequest.",
  "x-callable-aliases": [
    "decideEventJoinRequest"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "userId",
    "decision"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "userId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "decision": {
      "type": "string",
      "enum": [
        "approve",
        "decline"
      ]
    }
  }
} as const;

export const overrideEventSuccessRotationsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/override_event_success_rotations_payload.schema.json",
  "title": "OverrideEventSuccessRotationsCallablePayload",
  "description": "Callable payload accepted by overrideEventSuccessRotations.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "rounds"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "rounds": {
      "type": "array",
      "minItems": 1,
      "maxItems": 32,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "roundIndex",
          "pairings"
        ],
        "properties": {
          "roundIndex": {
            "type": "integer",
            "minimum": 0,
            "maximum": 31
          },
          "pairings": {
            "type": "array",
            "minItems": 0,
            "maxItems": 100,
            "items": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "uidA",
                "uidB"
              ],
              "properties": {
                "uidA": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                },
                "uidB": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 180
                }
              }
            }
          }
        }
      }
    }
  }
} as const;

export const overrideEventSuccessGroupsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/override_event_success_groups_payload.schema.json",
  "title": "OverrideEventSuccessGroupsCallablePayload",
  "description": "Callable payload accepted by overrideEventSuccessGroups.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "rounds"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "rounds": {
      "type": "array",
      "minItems": 1,
      "maxItems": 32,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "roundIndex",
          "groups"
        ],
        "properties": {
          "roundIndex": {
            "type": "integer",
            "minimum": 0,
            "maximum": 31
          },
          "groups": {
            "type": "array",
            "minItems": 1,
            "maxItems": 100,
            "items": {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "label",
                "participantUids"
              ],
              "properties": {
                "label": {
                  "type": "string",
                  "minLength": 1,
                  "maxLength": 80
                },
                "participantUids": {
                  "type": "array",
                  "minItems": 1,
                  "maxItems": 24,
                  "items": {
                    "type": "string",
                    "minLength": 1,
                    "maxLength": 180
                  }
                }
              }
            }
          }
        }
      }
    }
  }
} as const;

export const submitEventSuccessWingmanRequestCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/submit_event_success_wingman_request_payload.schema.json",
  "title": "SubmitEventSuccessWingmanRequestCallablePayload",
  "description": "Callable payload accepted by submitEventSuccessWingmanRequest.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "targetUid"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "targetUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "note": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 240
    }
  }
} as const;

export const startEventSuccessFirstHelloMissionCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/start_event_success_first_hello_mission_payload.schema.json",
  "title": "StartEventSuccessFirstHelloMissionCallablePayload",
  "description": "Callable payload accepted by startEventSuccessFirstHelloMission.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId"
  ],
  "properties": {
    "eventId": {
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

export const completeEventSuccessFirstHelloMissionCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/complete_event_success_first_hello_mission_payload.schema.json",
  "title": "CompleteEventSuccessFirstHelloMissionCallablePayload",
  "description": "Callable payload accepted by completeEventSuccessFirstHelloMission.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId",
    "answerId"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "answerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 64
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

export const markEventAttendanceCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/mark_event_attendance_response.schema.json",
  "title": "MarkEventAttendanceCallableResponse",
  "description": "Callable response returned by markEventAttendance.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "attended"
  ],
  "properties": {
    "attended": {
      "type": "boolean"
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
    "eventId"
  ],
  "properties": {
    "eventId": {
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

export const createEventReviewCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_event_review_payload.schema.json",
  "title": "CreateEventReviewCallablePayload",
  "description": "Callable payload accepted by createEventReview.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "clubId",
    "eventId",
    "rating",
    "comment"
  ],
  "properties": {
    "clubId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "eventId": {
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

export const createPublicClubReviewCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_public_club_review_payload.schema.json",
  "title": "CreatePublicClubReviewCallablePayload",
  "description": "Callable payload accepted by createPublicClubReview for unverified public organizer listing reviews.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "clubId",
    "rating",
    "comment",
    "reviewerName",
    "isAnonymous",
    "submittedFromPath"
  ],
  "properties": {
    "clubId": {
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
      "minLength": 1,
      "maxLength": 1000
    },
    "reviewerName": {
      "type": "string",
      "maxLength": 120
    },
    "isAnonymous": {
      "type": "boolean"
    },
    "submittedFromPath": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    }
  }
} as const;

export const createPublicClubReviewCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/create_public_club_review_response.schema.json",
  "title": "CreatePublicClubReviewCallableResponse",
  "description": "Callable response returned by createPublicClubReview after a public organizer review is accepted.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "reviewId",
    "review"
  ],
  "properties": {
    "reviewId": {
      "type": "string",
      "minLength": 1
    },
    "review": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "id",
        "reviewerName",
        "rating",
        "comment",
        "createdAt",
        "verificationStatus",
        "source",
        "isAnonymous",
        "ownerResponse"
      ],
      "properties": {
        "id": {
          "type": "string",
          "minLength": 1
        },
        "reviewerName": {
          "type": "string",
          "minLength": 1
        },
        "rating": {
          "type": "number",
          "minimum": 0,
          "maximum": 5
        },
        "comment": {
          "type": "string"
        },
        "createdAt": {
          "type": "string",
          "minLength": 1
        },
        "verificationStatus": {
          "type": "string",
          "enum": [
            "verified",
            "unverified"
          ]
        },
        "source": {
          "type": "string",
          "enum": [
            "catchEvent",
            "publicListing"
          ]
        },
        "isAnonymous": {
          "type": "boolean"
        },
        "ownerResponse": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "hostName",
                "hostAvatarUrl",
                "message",
                "updatedAt"
              ],
              "properties": {
                "hostName": {
                  "type": "string",
                  "minLength": 1
                },
                "hostAvatarUrl": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "format": "uri"
                },
                "message": {
                  "type": "string"
                },
                "updatedAt": {
                  "type": "string",
                  "minLength": 1
                }
              }
            },
            {
              "type": "null"
            }
          ]
        }
      }
    }
  },
  "definitions": {
    "publicClubReview": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "id",
        "reviewerName",
        "rating",
        "comment",
        "createdAt",
        "verificationStatus",
        "source",
        "isAnonymous",
        "ownerResponse"
      ],
      "properties": {
        "id": {
          "type": "string",
          "minLength": 1
        },
        "reviewerName": {
          "type": "string",
          "minLength": 1
        },
        "rating": {
          "type": "number",
          "minimum": 0,
          "maximum": 5
        },
        "comment": {
          "type": "string"
        },
        "createdAt": {
          "type": "string",
          "minLength": 1
        },
        "verificationStatus": {
          "type": "string",
          "enum": [
            "verified",
            "unverified"
          ]
        },
        "source": {
          "type": "string",
          "enum": [
            "catchEvent",
            "publicListing"
          ]
        },
        "isAnonymous": {
          "type": "boolean"
        },
        "ownerResponse": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "hostName",
                "hostAvatarUrl",
                "message",
                "updatedAt"
              ],
              "properties": {
                "hostName": {
                  "type": "string",
                  "minLength": 1
                },
                "hostAvatarUrl": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "format": "uri"
                },
                "message": {
                  "type": "string"
                },
                "updatedAt": {
                  "type": "string",
                  "minLength": 1
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
    "ownerResponse": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "hostName",
        "hostAvatarUrl",
        "message",
        "updatedAt"
      ],
      "properties": {
        "hostName": {
          "type": "string",
          "minLength": 1
        },
        "hostAvatarUrl": {
          "type": [
            "string",
            "null"
          ],
          "format": "uri"
        },
        "message": {
          "type": "string"
        },
        "updatedAt": {
          "type": "string",
          "minLength": 1
        }
      }
    }
  }
} as const;

export const listPublicClubReviewsCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/list_public_club_reviews_payload.schema.json",
  "title": "ListPublicClubReviewsCallablePayload",
  "description": "Callable payload accepted by listPublicClubReviews for public organizer listing review hydration.",
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

export const listPublicClubReviewsCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/list_public_club_reviews_response.schema.json",
  "title": "ListPublicClubReviewsCallableResponse",
  "description": "Callable response returned by listPublicClubReviews for public organizer listing review hydration.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "reviews"
  ],
  "properties": {
    "reviews": {
      "type": "array",
      "maxItems": 50,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "id",
          "reviewerName",
          "rating",
          "comment",
          "createdAt",
          "verificationStatus",
          "source",
          "isAnonymous",
          "ownerResponse"
        ],
        "properties": {
          "id": {
            "type": "string",
            "minLength": 1
          },
          "reviewerName": {
            "type": "string",
            "minLength": 1
          },
          "rating": {
            "type": "number",
            "minimum": 0,
            "maximum": 5
          },
          "comment": {
            "type": "string"
          },
          "createdAt": {
            "type": "string",
            "minLength": 1
          },
          "verificationStatus": {
            "type": "string",
            "enum": [
              "verified",
              "unverified"
            ]
          },
          "source": {
            "type": "string",
            "enum": [
              "catchEvent",
              "publicListing"
            ]
          },
          "isAnonymous": {
            "type": "boolean"
          },
          "ownerResponse": {
            "anyOf": [
              {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "hostName",
                  "hostAvatarUrl",
                  "message",
                  "updatedAt"
                ],
                "properties": {
                  "hostName": {
                    "type": "string",
                    "minLength": 1
                  },
                  "hostAvatarUrl": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "format": "uri"
                  },
                  "message": {
                    "type": "string"
                  },
                  "updatedAt": {
                    "type": "string",
                    "minLength": 1
                  }
                }
              },
              {
                "type": "null"
              }
            ]
          }
        }
      }
    }
  },
  "definitions": {
    "publicClubReview": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "id",
        "reviewerName",
        "rating",
        "comment",
        "createdAt",
        "verificationStatus",
        "source",
        "isAnonymous",
        "ownerResponse"
      ],
      "properties": {
        "id": {
          "type": "string",
          "minLength": 1
        },
        "reviewerName": {
          "type": "string",
          "minLength": 1
        },
        "rating": {
          "type": "number",
          "minimum": 0,
          "maximum": 5
        },
        "comment": {
          "type": "string"
        },
        "createdAt": {
          "type": "string",
          "minLength": 1
        },
        "verificationStatus": {
          "type": "string",
          "enum": [
            "verified",
            "unverified"
          ]
        },
        "source": {
          "type": "string",
          "enum": [
            "catchEvent",
            "publicListing"
          ]
        },
        "isAnonymous": {
          "type": "boolean"
        },
        "ownerResponse": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "hostName",
                "hostAvatarUrl",
                "message",
                "updatedAt"
              ],
              "properties": {
                "hostName": {
                  "type": "string",
                  "minLength": 1
                },
                "hostAvatarUrl": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "format": "uri"
                },
                "message": {
                  "type": "string"
                },
                "updatedAt": {
                  "type": "string",
                  "minLength": 1
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
    "ownerResponse": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "hostName",
        "hostAvatarUrl",
        "message",
        "updatedAt"
      ],
      "properties": {
        "hostName": {
          "type": "string",
          "minLength": 1
        },
        "hostAvatarUrl": {
          "type": [
            "string",
            "null"
          ],
          "format": "uri"
        },
        "message": {
          "type": "string"
        },
        "updatedAt": {
          "type": "string",
          "minLength": 1
        }
      }
    }
  }
} as const;

export const updateEventReviewCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/update_event_review_payload.schema.json",
  "title": "UpdateEventReviewCallablePayload",
  "description": "Callable payload accepted by updateEventReview.",
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

export const deleteEventReviewCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/delete_event_review_payload.schema.json",
  "title": "DeleteEventReviewCallablePayload",
  "description": "Callable payload accepted by deleteEventReview.",
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

export const setReviewResponseCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/set_review_response_payload.schema.json",
  "title": "SetReviewResponseCallablePayload",
  "description": "Callable payload accepted by setReviewResponse.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "reviewId",
    "message"
  ],
  "properties": {
    "reviewId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "message": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
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

export const requestSuvbotDemoOperationCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/request_suvbot_demo_operation_payload.schema.json",
  "title": "RequestSuvbotDemoOperationCallablePayload",
  "description": "Callable payload accepted by requestSuvbotDemoOperation. Demo-only operations triggered from the Suvbot conversation surface.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "action"
  ],
  "properties": {
    "action": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "text": {
      "type": "string",
      "maxLength": 2000
    }
  }
} as const;

export const listSuvbotDemoActionsCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/list_suvbot_demo_actions_response.schema.json",
  "title": "ListSuvbotDemoActionsCallableResponse",
  "description": "Callable response returned by listSuvbotDemoActions. Each action describes a button in the Suvbot demo-operations menu.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "actions"
  ],
  "properties": {
    "actions": {
      "type": "array",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "id",
          "label",
          "description",
          "icon"
        ],
        "properties": {
          "id": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "label": {
            "type": "string",
            "minLength": 1,
            "maxLength": 120
          },
          "description": {
            "type": "string",
            "minLength": 1,
            "maxLength": 500
          },
          "icon": {
            "type": "string",
            "minLength": 1,
            "maxLength": 80
          },
          "destructive": {
            "type": "boolean"
          },
          "requiresText": {
            "type": "boolean"
          }
        }
      }
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

export const eventBookingCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/event_booking_payload.schema.json",
  "title": "EventBookingCallablePayload",
  "description": "Callable payload accepted by signUpForFreeEvent. Same shape as EventIdCallablePayload but distinct so the booking flow can diverge without breaking the generic event-id callables.",
  "x-callable-aliases": [
    "signUpForFreeEvent"
  ],
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "inviteCode": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 4,
      "maxLength": 64,
      "pattern": "^[A-Za-z0-9_-]+$"
    },
    "inviteLinkId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;

export const createRazorpayOrderCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_razorpay_order_payload.schema.json",
  "title": "CreateRazorpayOrderCallablePayload",
  "description": "Callable payload accepted by createRazorpayOrder. Returns a Razorpay order id + amount that the client uses to open the checkout sheet.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "inviteCode": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 4,
      "maxLength": 64,
      "pattern": "^[A-Za-z0-9_-]+$"
    },
    "inviteLinkId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;

export const razorpayOrderCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/razorpay_order_response.schema.json",
  "title": "RazorpayOrderCallableResponse",
  "description": "Callable response returned by createRazorpayOrder.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "orderId",
    "amount",
    "currency"
  ],
  "properties": {
    "orderId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "amount": {
      "type": "integer",
      "minimum": 1,
      "maximum": 100000000
    },
    "currency": {
      "type": "string",
      "pattern": "^[A-Z]{3}$"
    }
  }
} as const;

export const createStripeCheckoutSessionCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_stripe_checkout_session_payload.schema.json",
  "title": "CreateStripeCheckoutSessionCallablePayload",
  "description": "Callable payload accepted by createStripeCheckoutSession. The server derives amount, currency, host account, and booking metadata from Firestore.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "eventId"
  ],
  "properties": {
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "inviteCode": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 80
    },
    "inviteLinkId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    }
  }
} as const;

export const stripeCheckoutSessionCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/stripe_checkout_session_response.schema.json",
  "title": "StripeCheckoutSessionCallableResponse",
  "description": "Callable response returned by createStripeCheckoutSession.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "sessionId",
    "paymentId",
    "amountMinor",
    "currency",
    "checkoutUrl",
    "provider"
  ],
  "properties": {
    "sessionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "paymentId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 240
    },
    "amountMinor": {
      "type": "integer",
      "minimum": 1,
      "maximum": 100000000
    },
    "currency": {
      "type": "string",
      "minLength": 3,
      "maxLength": 3
    },
    "checkoutUrl": {
      "type": "string",
      "format": "uri",
      "maxLength": 2048
    },
    "provider": {
      "type": "string",
      "enum": [
        "stripe"
      ]
    }
  }
} as const;

export const createStripeHostOnboardingLinkCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/create_stripe_host_onboarding_link_payload.schema.json",
  "title": "CreateStripeHostOnboardingLinkCallablePayload",
  "description": "Callable payload accepted by createStripeHostOnboardingLink. Hosts can optionally provide the Stripe account country and default currency for first-time setup.",
  "type": "object",
  "additionalProperties": false,
  "properties": {
    "country": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 2,
      "maxLength": 2
    },
    "defaultCurrency": {
      "type": [
        "string",
        "null"
      ],
      "minLength": 3,
      "maxLength": 3
    }
  }
} as const;

export const refreshStripeHostPaymentAccountCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/refresh_stripe_host_payment_account_payload.schema.json",
  "title": "RefreshStripeHostPaymentAccountCallablePayload",
  "description": "Callable payload accepted by refreshStripeHostPaymentAccount. The authenticated host id determines which Stripe account is refreshed.",
  "type": "object",
  "additionalProperties": false,
  "properties": {}
} as const;

export const stripeHostOnboardingLinkCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/stripe_host_onboarding_link_response.schema.json",
  "title": "StripeHostOnboardingLinkCallableResponse",
  "description": "Callable response returned by createStripeHostOnboardingLink.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "accountId",
    "onboardingUrl"
  ],
  "properties": {
    "accountId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "onboardingUrl": {
      "type": "string",
      "format": "uri",
      "maxLength": 2048
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
    "countryIsoCode": {
      "type": "string",
      "enum": [
        "IN",
        "NP",
        "AU",
        "US",
        "in",
        "np",
        "au",
        "us"
      ]
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

export const placesAutocompleteCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/places_autocomplete_response.schema.json",
  "title": "PlacesAutocompleteCallableResponse",
  "description": "Callable response returned by placesAutocomplete.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "predictions"
  ],
  "properties": {
    "predictions": {
      "type": "array",
      "maxItems": 10,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "placeId",
          "description",
          "mainText",
          "secondaryText"
        ],
        "properties": {
          "placeId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 256
          },
          "description": {
            "type": "string",
            "maxLength": 1000
          },
          "mainText": {
            "type": "string",
            "maxLength": 240
          },
          "secondaryText": {
            "type": "string",
            "maxLength": 1000
          }
        }
      }
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

export const placeDetailsCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/place_details_response.schema.json",
  "title": "PlaceDetailsCallableResponse",
  "description": "Callable response returned by placeDetails.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "place"
  ],
  "properties": {
    "place": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "placeId",
        "displayName",
        "formattedAddress",
        "latitude",
        "longitude"
      ],
      "properties": {
        "placeId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 256
        },
        "displayName": {
          "type": "string",
          "maxLength": 240
        },
        "formattedAddress": {
          "type": "string",
          "maxLength": 1000
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
    }
  }
} as const;

export const exploreSearchCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/explore_search_payload.schema.json",
  "title": "ExploreSearchCallablePayload",
  "description": "Callable payload accepted by exploreSearch.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "query"
  ],
  "properties": {
    "query": {
      "type": "string",
      "minLength": 2,
      "maxLength": 120
    },
    "cityName": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "pattern": "^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*$",
      "description": "Canonical launch market id. The field name is retained for callable compatibility."
    },
    "limit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 50
    }
  }
} as const;

export const exploreSearchCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/explore_search_response.schema.json",
  "title": "ExploreSearchCallableResponse",
  "description": "Callable response returned by exploreSearch.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "clubIds",
    "eventIds"
  ],
  "properties": {
    "clubIds": {
      "type": "array",
      "maxItems": 50,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 256
      }
    },
    "eventIds": {
      "type": "array",
      "maxItems": 50,
      "items": {
        "type": "string",
        "minLength": 1,
        "maxLength": 256
      }
    }
  }
} as const;

export const websiteHostListingProjectionSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/public/website_host_listing_projection.schema.json",
  "title": "WebsiteHostListingProjection",
  "description": "Public organizer listing projection consumed by the marketing website and future shared web/app listing surfaces. It is generated from approved organizer, seed, or demo data and is not the canonical club document.",
  "type": "object",
  "additionalProperties": false,
  "x-owner": "website/scripts/generateOrganizerListings.mjs",
  "required": [
    "id",
    "listingVariant",
    "dataOrigin",
    "name",
    "slug",
    "city",
    "citySlug",
    "region",
    "country",
    "path",
    "category",
    "status",
    "indexing",
    "sourceConfidence",
    "headline",
    "description",
    "sourceSummary",
    "logo",
    "formats",
    "facts",
    "eventEvidence",
    "reviews",
    "fitNotes",
    "missingEvidence",
    "sources",
    "claim",
    "publicApi",
    "lastVerifiedAt",
    "searchText"
  ],
  "properties": {
    "id": {
      "type": "string",
      "minLength": 1
    },
    "listingVariant": {
      "type": "string",
      "enum": [
        "unclaimedScraped",
        "appCreatedClub"
      ]
    },
    "dataOrigin": {
      "type": "string",
      "enum": [
        "scrapedSeed",
        "catchDemo",
        "organizerIntake"
      ]
    },
    "name": {
      "type": "string",
      "minLength": 1
    },
    "slug": {
      "type": "string",
      "minLength": 1
    },
    "city": {
      "type": "string",
      "minLength": 1
    },
    "citySlug": {
      "type": "string",
      "minLength": 1
    },
    "region": {
      "type": "string"
    },
    "country": {
      "type": "string"
    },
    "path": {
      "type": "string",
      "pattern": "^/[^?#]*/$"
    },
    "legacyPaths": {
      "type": "array",
      "items": {
        "type": "string",
        "pattern": "^/[^?#]*/$"
      },
      "uniqueItems": true
    },
    "category": {
      "type": "string",
      "minLength": 1
    },
    "status": {
      "type": "string",
      "minLength": 1
    },
    "indexing": {
      "type": "string",
      "enum": [
        "index, follow",
        "noindex, follow"
      ]
    },
    "sourceConfidence": {
      "type": "string",
      "enum": [
        "first_party",
        "high",
        "medium",
        "low"
      ]
    },
    "headline": {
      "type": "string",
      "minLength": 1
    },
    "description": {
      "type": "string",
      "minLength": 1
    },
    "sourceSummary": {
      "type": "string",
      "minLength": 1
    },
    "logo": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "mode",
        "text",
        "status"
      ],
      "properties": {
        "mode": {
          "type": "string",
          "enum": [
            "monogram"
          ]
        },
        "text": {
          "type": "string",
          "minLength": 1
        },
        "status": {
          "type": "string",
          "minLength": 1
        }
      }
    },
    "formats": {
      "type": "array",
      "items": {
        "type": "string",
        "minLength": 1
      }
    },
    "facts": {
      "type": "array",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "label",
          "value"
        ],
        "properties": {
          "label": {
            "type": "string",
            "minLength": 1
          },
          "value": {
            "type": "string",
            "minLength": 1
          }
        }
      }
    },
    "metrics": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
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
        "nextEventAt": {
          "type": [
            "string",
            "null"
          ]
        },
        "nextEventLabel": {
          "type": [
            "string",
            "null"
          ]
        }
      }
    },
    "host": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "name",
        "role",
        "avatarUrl"
      ],
      "properties": {
        "name": {
          "type": "string",
          "minLength": 1
        },
        "role": {
          "type": "string",
          "minLength": 1
        },
        "avatarUrl": {
          "type": [
            "string",
            "null"
          ],
          "format": "uri"
        }
      }
    },
    "catchEvents": {
      "type": "array",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "id",
          "role",
          "title",
          "activityKind",
          "timeline",
          "startTime",
          "endTime",
          "date",
          "location",
          "summary",
          "capacityLimit",
          "bookedCount",
          "checkedInCount",
          "waitlistedCount",
          "priceLabel"
        ],
        "properties": {
          "id": {
            "type": "string",
            "minLength": 1
          },
          "role": {
            "type": "string",
            "minLength": 1
          },
          "title": {
            "type": "string",
            "minLength": 1
          },
          "activityKind": {
            "type": "string",
            "minLength": 1
          },
          "timeline": {
            "type": "string",
            "enum": [
              "upcoming",
              "past"
            ]
          },
          "startTime": {
            "type": "string",
            "minLength": 1
          },
          "endTime": {
            "type": "string",
            "minLength": 1
          },
          "date": {
            "type": "string",
            "minLength": 1
          },
          "location": {
            "type": "string",
            "minLength": 1
          },
          "summary": {
            "type": "string"
          },
          "capacityLimit": {
            "type": "integer",
            "minimum": 0
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
          "priceLabel": {
            "type": "string",
            "minLength": 1
          },
          "scorecard": {
            "anyOf": [
              {
                "type": "object",
                "additionalProperties": true
              },
              {
                "type": "null"
              }
            ]
          }
        }
      }
    },
    "externalEvents": {
      "type": "array",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "id",
          "title",
          "activityKind",
          "availability",
          "startTime",
          "endTime",
          "date",
          "location",
          "summary",
          "priceLabel",
          "sourceLabel",
          "sourceHref",
          "externalLinkCount",
          "dedupeKey"
        ],
        "properties": {
          "id": {
            "type": "string",
            "minLength": 1
          },
          "title": {
            "type": "string",
            "minLength": 1
          },
          "activityKind": {
            "type": "string",
            "minLength": 1
          },
          "availability": {
            "type": "string",
            "enum": [
              "read_only_external"
            ]
          },
          "startTime": {
            "type": "string",
            "minLength": 1
          },
          "endTime": {
            "type": [
              "string",
              "null"
            ]
          },
          "date": {
            "type": "string",
            "minLength": 1
          },
          "location": {
            "type": "string",
            "minLength": 1
          },
          "summary": {
            "type": "string"
          },
          "priceLabel": {
            "type": "string",
            "minLength": 1
          },
          "sourceLabel": {
            "type": "string",
            "minLength": 1
          },
          "sourceHref": {
            "type": "string",
            "format": "uri"
          },
          "externalLinkCount": {
            "type": "integer",
            "minimum": 1
          },
          "dedupeKey": {
            "type": "string",
            "minLength": 1
          }
        }
      }
    },
    "eventSuccessSummary": {
      "anyOf": [
        {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "bookedCount",
            "checkedInCount",
            "mutualMatchCount",
            "chatStartedCount",
            "catchSentCount",
            "safetyIncidentCount"
          ],
          "properties": {
            "bookedCount": {
              "type": "integer",
              "minimum": 0
            },
            "checkedInCount": {
              "type": "integer",
              "minimum": 0
            },
            "mutualMatchCount": {
              "type": "integer",
              "minimum": 0
            },
            "chatStartedCount": {
              "type": "integer",
              "minimum": 0
            },
            "catchSentCount": {
              "type": "integer",
              "minimum": 0
            },
            "safetyIncidentCount": {
              "type": "integer",
              "minimum": 0
            }
          }
        },
        {
          "type": "null"
        }
      ]
    },
    "eventEvidence": {
      "type": "array",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "title",
          "date",
          "location",
          "summary",
          "facts",
          "sourceLabel",
          "sourceHref"
        ],
        "properties": {
          "title": {
            "type": "string",
            "minLength": 1
          },
          "date": {
            "type": "string",
            "minLength": 1
          },
          "location": {
            "type": "string",
            "minLength": 1
          },
          "summary": {
            "type": "string"
          },
          "facts": {
            "type": "array",
            "items": {
              "type": "string",
              "minLength": 1
            }
          },
          "sourceLabel": {
            "type": "string",
            "minLength": 1
          },
          "sourceHref": {
            "type": "string",
            "format": "uri"
          }
        }
      }
    },
    "reviews": {
      "type": "array",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "id",
          "reviewerName",
          "rating",
          "comment",
          "createdAt",
          "verificationStatus",
          "source",
          "isAnonymous",
          "ownerResponse"
        ],
        "properties": {
          "id": {
            "type": [
              "string",
              "null"
            ]
          },
          "reviewerName": {
            "type": "string",
            "minLength": 1
          },
          "rating": {
            "type": "number",
            "minimum": 0,
            "maximum": 5
          },
          "comment": {
            "type": "string"
          },
          "createdAt": {
            "type": "string",
            "minLength": 1
          },
          "verificationStatus": {
            "type": "string",
            "enum": [
              "verified",
              "unverified"
            ]
          },
          "source": {
            "type": "string",
            "enum": [
              "catchEvent",
              "publicListing"
            ]
          },
          "isAnonymous": {
            "type": "boolean"
          },
          "ownerResponse": {
            "anyOf": [
              {
                "type": "object",
                "additionalProperties": false,
                "required": [
                  "hostName",
                  "hostAvatarUrl",
                  "message",
                  "updatedAt"
                ],
                "properties": {
                  "hostName": {
                    "type": "string",
                    "minLength": 1
                  },
                  "hostAvatarUrl": {
                    "type": [
                      "string",
                      "null"
                    ],
                    "format": "uri"
                  },
                  "message": {
                    "type": "string"
                  },
                  "updatedAt": {
                    "type": "string",
                    "minLength": 1
                  }
                }
              },
              {
                "type": "null"
              }
            ]
          }
        }
      }
    },
    "fitNotes": {
      "type": "array",
      "items": {
        "type": "string",
        "minLength": 1
      }
    },
    "missingEvidence": {
      "type": "array",
      "items": {
        "type": "string",
        "minLength": 1
      }
    },
    "sources": {
      "type": "array",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "type",
          "label",
          "detail",
          "confidence"
        ],
        "properties": {
          "type": {
            "type": "string",
            "minLength": 1
          },
          "label": {
            "type": "string",
            "minLength": 1
          },
          "detail": {
            "type": "string",
            "minLength": 1
          },
          "href": {
            "type": "string",
            "format": "uri"
          },
          "confidence": {
            "type": "string",
            "enum": [
              "high",
              "medium",
              "low"
            ]
          }
        }
      }
    },
    "claim": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "href",
        "label"
      ],
      "properties": {
        "href": {
          "type": "string",
          "minLength": 1
        },
        "label": {
          "type": "string",
          "minLength": 1
        }
      }
    },
    "publicApi": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "state",
        "reason",
        "claimTargetSyncStatus"
      ],
      "properties": {
        "state": {
          "type": "string",
          "enum": [
            "enabled",
            "disabled"
          ]
        },
        "reason": {
          "type": "string",
          "minLength": 1
        },
        "claimTargetSyncStatus": {
          "type": "string",
          "enum": [
            "in_sync",
            "write_needed",
            "static_fixture",
            "unknown"
          ]
        }
      }
    },
    "lastVerifiedAt": {
      "type": "string",
      "minLength": 1
    },
    "searchText": {
      "type": "string",
      "minLength": 1
    }
  },
  "definitions": {
    "nonEmptyString": {
      "type": "string",
      "minLength": 1
    },
    "routePath": {
      "type": "string",
      "pattern": "^/[^?#]*/$"
    },
    "urlOrNull": {
      "type": [
        "string",
        "null"
      ],
      "format": "uri"
    },
    "labelValue": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "label",
        "value"
      ],
      "properties": {
        "label": {
          "type": "string",
          "minLength": 1
        },
        "value": {
          "type": "string",
          "minLength": 1
        }
      }
    },
    "logo": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "mode",
        "text",
        "status"
      ],
      "properties": {
        "mode": {
          "type": "string",
          "enum": [
            "monogram"
          ]
        },
        "text": {
          "type": "string",
          "minLength": 1
        },
        "status": {
          "type": "string",
          "minLength": 1
        }
      }
    },
    "metrics": {
      "type": "object",
      "additionalProperties": false,
      "properties": {
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
        "nextEventAt": {
          "type": [
            "string",
            "null"
          ]
        },
        "nextEventLabel": {
          "type": [
            "string",
            "null"
          ]
        }
      }
    },
    "host": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "name",
        "role",
        "avatarUrl"
      ],
      "properties": {
        "name": {
          "type": "string",
          "minLength": 1
        },
        "role": {
          "type": "string",
          "minLength": 1
        },
        "avatarUrl": {
          "type": [
            "string",
            "null"
          ],
          "format": "uri"
        }
      }
    },
    "catchEvent": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "id",
        "role",
        "title",
        "activityKind",
        "timeline",
        "startTime",
        "endTime",
        "date",
        "location",
        "summary",
        "capacityLimit",
        "bookedCount",
        "checkedInCount",
        "waitlistedCount",
        "priceLabel"
      ],
      "properties": {
        "id": {
          "type": "string",
          "minLength": 1
        },
        "role": {
          "type": "string",
          "minLength": 1
        },
        "title": {
          "type": "string",
          "minLength": 1
        },
        "activityKind": {
          "type": "string",
          "minLength": 1
        },
        "timeline": {
          "type": "string",
          "enum": [
            "upcoming",
            "past"
          ]
        },
        "startTime": {
          "type": "string",
          "minLength": 1
        },
        "endTime": {
          "type": "string",
          "minLength": 1
        },
        "date": {
          "type": "string",
          "minLength": 1
        },
        "location": {
          "type": "string",
          "minLength": 1
        },
        "summary": {
          "type": "string"
        },
        "capacityLimit": {
          "type": "integer",
          "minimum": 0
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
        "priceLabel": {
          "type": "string",
          "minLength": 1
        },
        "scorecard": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": true
            },
            {
              "type": "null"
            }
          ]
        }
      }
    },
    "externalEvent": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "id",
        "title",
        "activityKind",
        "availability",
        "startTime",
        "endTime",
        "date",
        "location",
        "summary",
        "priceLabel",
        "sourceLabel",
        "sourceHref",
        "externalLinkCount",
        "dedupeKey"
      ],
      "properties": {
        "id": {
          "type": "string",
          "minLength": 1
        },
        "title": {
          "type": "string",
          "minLength": 1
        },
        "activityKind": {
          "type": "string",
          "minLength": 1
        },
        "availability": {
          "type": "string",
          "enum": [
            "read_only_external"
          ]
        },
        "startTime": {
          "type": "string",
          "minLength": 1
        },
        "endTime": {
          "type": [
            "string",
            "null"
          ]
        },
        "date": {
          "type": "string",
          "minLength": 1
        },
        "location": {
          "type": "string",
          "minLength": 1
        },
        "summary": {
          "type": "string"
        },
        "priceLabel": {
          "type": "string",
          "minLength": 1
        },
        "sourceLabel": {
          "type": "string",
          "minLength": 1
        },
        "sourceHref": {
          "type": "string",
          "format": "uri"
        },
        "externalLinkCount": {
          "type": "integer",
          "minimum": 1
        },
        "dedupeKey": {
          "type": "string",
          "minLength": 1
        }
      }
    },
    "eventSuccessSummary": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "bookedCount",
        "checkedInCount",
        "mutualMatchCount",
        "chatStartedCount",
        "catchSentCount",
        "safetyIncidentCount"
      ],
      "properties": {
        "bookedCount": {
          "type": "integer",
          "minimum": 0
        },
        "checkedInCount": {
          "type": "integer",
          "minimum": 0
        },
        "mutualMatchCount": {
          "type": "integer",
          "minimum": 0
        },
        "chatStartedCount": {
          "type": "integer",
          "minimum": 0
        },
        "catchSentCount": {
          "type": "integer",
          "minimum": 0
        },
        "safetyIncidentCount": {
          "type": "integer",
          "minimum": 0
        }
      }
    },
    "eventEvidence": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "title",
        "date",
        "location",
        "summary",
        "facts",
        "sourceLabel",
        "sourceHref"
      ],
      "properties": {
        "title": {
          "type": "string",
          "minLength": 1
        },
        "date": {
          "type": "string",
          "minLength": 1
        },
        "location": {
          "type": "string",
          "minLength": 1
        },
        "summary": {
          "type": "string"
        },
        "facts": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1
          }
        },
        "sourceLabel": {
          "type": "string",
          "minLength": 1
        },
        "sourceHref": {
          "type": "string",
          "format": "uri"
        }
      }
    },
    "publicReview": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "id",
        "reviewerName",
        "rating",
        "comment",
        "createdAt",
        "verificationStatus",
        "source",
        "isAnonymous",
        "ownerResponse"
      ],
      "properties": {
        "id": {
          "type": [
            "string",
            "null"
          ]
        },
        "reviewerName": {
          "type": "string",
          "minLength": 1
        },
        "rating": {
          "type": "number",
          "minimum": 0,
          "maximum": 5
        },
        "comment": {
          "type": "string"
        },
        "createdAt": {
          "type": "string",
          "minLength": 1
        },
        "verificationStatus": {
          "type": "string",
          "enum": [
            "verified",
            "unverified"
          ]
        },
        "source": {
          "type": "string",
          "enum": [
            "catchEvent",
            "publicListing"
          ]
        },
        "isAnonymous": {
          "type": "boolean"
        },
        "ownerResponse": {
          "anyOf": [
            {
              "type": "object",
              "additionalProperties": false,
              "required": [
                "hostName",
                "hostAvatarUrl",
                "message",
                "updatedAt"
              ],
              "properties": {
                "hostName": {
                  "type": "string",
                  "minLength": 1
                },
                "hostAvatarUrl": {
                  "type": [
                    "string",
                    "null"
                  ],
                  "format": "uri"
                },
                "message": {
                  "type": "string"
                },
                "updatedAt": {
                  "type": "string",
                  "minLength": 1
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
    "ownerResponse": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "hostName",
        "hostAvatarUrl",
        "message",
        "updatedAt"
      ],
      "properties": {
        "hostName": {
          "type": "string",
          "minLength": 1
        },
        "hostAvatarUrl": {
          "type": [
            "string",
            "null"
          ],
          "format": "uri"
        },
        "message": {
          "type": "string"
        },
        "updatedAt": {
          "type": "string",
          "minLength": 1
        }
      }
    },
    "publicApi": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "state",
        "reason",
        "claimTargetSyncStatus"
      ],
      "properties": {
        "state": {
          "type": "string",
          "enum": [
            "enabled",
            "disabled"
          ]
        },
        "reason": {
          "type": "string",
          "minLength": 1
        },
        "claimTargetSyncStatus": {
          "type": "string",
          "enum": [
            "in_sync",
            "write_needed",
            "static_fixture",
            "unknown"
          ]
        }
      }
    },
    "source": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "type",
        "label",
        "detail",
        "confidence"
      ],
      "properties": {
        "type": {
          "type": "string",
          "minLength": 1
        },
        "label": {
          "type": "string",
          "minLength": 1
        },
        "detail": {
          "type": "string",
          "minLength": 1
        },
        "href": {
          "type": "string",
          "format": "uri"
        },
        "confidence": {
          "type": "string",
          "enum": [
            "high",
            "medium",
            "low"
          ]
        }
      }
    }
  }
} as const;

export const fetchEventSuccessWingmanCandidatesCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/fetch_event_success_wingman_candidates_response.schema.json",
  "title": "FetchEventSuccessWingmanCandidatesCallableResponse",
  "description": "Callable response returned by fetchEventSuccessWingmanCandidates. Each profile is the persisted publicProfiles/{uid} document shape with `uid` injected at the wire boundary so clients can identify the profile owner. Per-field shape is enforced by PublicProfileDocument (contracts/firestore/public_profiles.schema.json) when the Dart side parses each entry.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "profiles"
  ],
  "properties": {
    "profiles": {
      "type": "array",
      "items": {
        "x-wire-shape-extends": "contracts/firestore/public_profiles.schema.json",
        "x-wire-shape-injects": [
          "uid"
        ],
        "type": "object",
        "required": [
          "uid"
        ],
        "properties": {
          "uid": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          }
        }
      }
    }
  }
} as const;

export const createProfileDecisionClientWriteSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/client_writes/create_profile_decision.schema.json",
  "title": "CreateProfileDecisionClientWrite",
  "description": "Client-owned Firestore create operation for the current profileDecisions/{userId}/outgoing/{targetId} storage path.",
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
      "description": "Storage contract for contextual profile decisions stored at profileDecisions/{userId}/outgoing/{targetId}.",
      "type": "object",
      "additionalProperties": false,
      "x-firestore-collection": "profileDecisions",
      "x-firestore-path": "profileDecisions/{userId}/outgoing/{targetId}",
      "x-document-id-field": "targetId",
      "x-owner": "authenticated swiper direct create; matching trigger consumes likes",
      "x-logical-name": "profileDecision",
      "x-migration-phase": "new_primary",
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
        "eventId",
        "direction",
        "createdAt"
      ],
      "properties": {
        "swiperId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "x-catch-ownership": "client-writable"
        },
        "targetId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "x-catch-ownership": "client-writable"
        },
        "eventId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180,
          "x-catch-ownership": "client-writable"
        },
        "direction": {
          "type": "string",
          "enum": [
            "like",
            "pass"
          ],
          "x-catch-ownership": "client-writable"
        },
        "reactionTargetId": {
          "type": [
            "string",
            "null"
          ],
          "minLength": 1,
          "maxLength": 80,
          "x-catch-ownership": "client-writable"
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
          ],
          "x-catch-ownership": "client-writable"
        },
        "reactionTargetLabel": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 80,
          "x-catch-ownership": "client-writable"
        },
        "reactionTargetPreview": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 240,
          "x-catch-ownership": "client-writable"
        },
        "comment": {
          "type": [
            "string",
            "null"
          ],
          "maxLength": 240,
          "x-catch-ownership": "client-writable"
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
          },
          "x-catch-ownership": "client-writable"
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
  "x-firestore-path": "profileDecisions/{userId}/outgoing/{targetId}",
  "x-logical-name": "profileDecision",
  "x-migration-phase": "new_primary",
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

export const createSavedEventClientWriteSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/client_writes/create_saved_event.schema.json",
  "title": "CreateSavedEventClientWrite",
  "description": "Client-owned Firestore create operation for savedEvents/{savedEventId}.",
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
        "savedEventId"
      ],
      "properties": {
        "savedEventId": {
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
        "eventId",
        "savedAt"
      ],
      "properties": {
        "uid": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        "eventId": {
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
  "x-firestore-path": "savedEvents/{savedEventId}",
  "x-owner": "authenticated owner direct create"
} as const;

export const deleteSavedEventClientWriteSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/client_writes/delete_saved_event.schema.json",
  "title": "DeleteSavedEventClientWrite",
  "description": "Client-owned Firestore delete operation for savedEvents/{savedEventId}.",
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
        "savedEventId"
      ],
      "properties": {
        "savedEventId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        }
      }
    }
  },
  "x-firestore-operation": "delete",
  "x-firestore-path": "savedEvents/{savedEventId}",
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
    "afterEvent",
    "greenFlag"
  ],
  "prompts": [
    {
      "id": "perfectRun",
      "title": "A perfect event with me looks like...",
      "placeholder": "Tell people what kind of event feels like you."
    },
    {
      "id": "afterEvent",
      "title": "After an event, you can usually find me...",
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
    "maxPromptIdLength": 80,
    "maxPromptTitleLength": 140,
    "maxCaptionLength": 140,
    "maxCaptions": 6
  },
  "prompts": [
    {
      "id": "proofIRun",
      "title": "Proof I actually run",
      "placeholder": "Choose this when the photo is the proof."
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
      "title": "First thought?",
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
  "maxPromptIdLength": 80,
  "maxPromptTitleLength": 140,
  "maxCaptionLength": 140,
  "maxCaptions": 6
} as const;

export const profilePhotoPolicy = {
  "schemaVersion": 1,
  "kind": "profilePhotoPolicy",
  "minPhotos": 2,
  "maxPhotos": 6,
  "displayAspectRatio": {
    "width": 3,
    "height": 4
  },
  "thumbnailSize": 160,
  "maxUploadBytes": 8388608
} as const;

export const defaultProfilePromptIds = [
  "perfectRun",
  "afterEvent",
  "greenFlag"
] as const;
