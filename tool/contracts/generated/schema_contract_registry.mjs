// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const profilePromptAnswerSchema = {
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
};

export const photoPromptAnswerSchema = {
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
};

export const profilePhotoSchema = {
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
};

export const configCitiesDocumentSchema = {
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
          "label",
          "latitude",
          "longitude",
          "countryIsoCode",
          "currencyCode",
          "dialCode",
          "timeZone"
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
          }
        }
      },
      "uniqueItems": true,
      "x-catch-ownership": "server-only"
    }
  }
};

export const onboardingDraftDocumentSchema = {
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
};

export const userProfileDocumentSchema = {
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
    "runPreferencesVersion",
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
    "photoUrls": {
      "type": "array",
      "maxItems": 6,
      "items": {
        "type": "string",
        "format": "uri",
        "maxLength": 2048
      },
      "x-catch-ownership": "client-writable"
    },
    "photoThumbnailUrls": {
      "type": "array",
      "maxItems": 6,
      "items": {
        "type": "string",
        "format": "uri",
        "maxLength": 2048
      },
      "x-catch-ownership": "client-writable"
    },
    "photoPrompts": {
      "type": "array",
      "maxItems": 6,
      "items": {
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
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 80,
      "pattern": "^[a-z0-9-]+$",
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
      "x-catch-ownership": "client-writable"
    },
    "company": {
      "type": [
        "string",
        "null"
      ],
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
    "paceMinSecsPerKm": {
      "type": "integer",
      "minimum": 1,
      "x-catch-ownership": "client-writable"
    },
    "paceMaxSecsPerKm": {
      "type": "integer",
      "minimum": 1,
      "x-catch-ownership": "client-writable"
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
      },
      "x-catch-ownership": "client-writable"
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
      },
      "x-catch-ownership": "client-writable"
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
      },
      "x-catch-ownership": "client-writable"
    },
    "runPreferencesVersion": {
      "type": "integer",
      "minimum": 0,
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
};

export const publicProfileDocumentSchema = {
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
    "preferredRunTimes",
    "runPreferencesVersion"
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
    "photoUrls": {
      "type": "array",
      "maxItems": 6,
      "items": {
        "type": "string",
        "format": "uri",
        "maxLength": 2048
      },
      "x-catch-ownership": "trigger-owned"
    },
    "photoThumbnailUrls": {
      "type": "array",
      "maxItems": 6,
      "items": {
        "type": "string",
        "format": "uri",
        "maxLength": 2048
      },
      "x-catch-ownership": "trigger-owned"
    },
    "photoPrompts": {
      "type": "array",
      "maxItems": 6,
      "items": {
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
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 80,
      "pattern": "^[a-z0-9-]+$",
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
      "x-catch-ownership": "trigger-owned"
    },
    "company": {
      "type": [
        "string",
        "null"
      ],
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
    "paceMinSecsPerKm": {
      "type": "integer",
      "minimum": 1,
      "x-catch-ownership": "trigger-owned"
    },
    "paceMaxSecsPerKm": {
      "type": "integer",
      "minimum": 1,
      "x-catch-ownership": "trigger-owned"
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
      },
      "x-catch-ownership": "trigger-owned"
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
      },
      "x-catch-ownership": "trigger-owned"
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
      },
      "x-catch-ownership": "trigger-owned"
    },
    "runPreferencesVersion": {
      "type": "integer",
      "minimum": 0,
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
};

export const clubDocumentSchema = {
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
      "type": [
        "string",
        "null"
      ],
      "minLength": 1,
      "maxLength": 80,
      "pattern": "^[a-z0-9-]+$",
      "x-catch-ownership": "callable-owned"
    },
    "area": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120,
      "x-catch-ownership": "callable-owned"
    },
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
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "callable-owned"
    },
    "hostUserIds": {
      "type": "array",
      "minItems": 1,
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
      "minItems": 1,
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
};

export const clubMembershipDocumentSchema = {
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
};

export const clubHostClaimDocumentSchema = {
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
};

export const eventDocumentSchema = {
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
    "waitlistedCohortCounts"
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
      },
      "x-catch-ownership": "callable-owned"
    },
    "startingPointLat": {
      "type": [
        "number",
        "null"
      ],
      "minimum": -90,
      "maximum": 90,
      "x-catch-ownership": "callable-owned"
    },
    "startingPointLng": {
      "type": [
        "number",
        "null"
      ],
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
};

export const eventPrivateAccessDocumentSchema = {
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
};

export const eventParticipationDocumentSchema = {
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
};

export const eventSuccessPlanDocumentSchema = {
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
};

export const eventSuccessFeedbackDocumentSchema = {
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
};

export const eventSuccessPreferenceDocumentSchema = {
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
};

export const eventSuccessCompatibilityResponseDocumentSchema = {
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
};

export const eventSuccessWingmanRequestDocumentSchema = {
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
};

export const eventSuccessArrivalMissionDocumentSchema = {
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
};

export const eventSuccessAssignmentDocumentSchema = {
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
          "compatibility": {
            "type": "string",
            "enum": [
              "mutual_interest",
              "one_way_interest",
              "questionnaire_match",
              "social",
              "host_override"
            ]
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
};

export const eventSuccessScorecardDocumentSchema = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/event_success_scorecards.schema.json",
  "title": "EventSuccessScorecardDocument",
  "description": "Server-owned aggregate event coaching metrics stored at eventSuccessScorecards/{eventId}. Raw attendee feedback remains private.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "eventSuccessScorecards",
  "x-firestore-path": "eventSuccessScorecards/{eventId}",
  "x-document-id-field": "id",
  "x-owner": "onEventSuccessFeedbackWritten trigger",
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
    "mutualMatchCount",
    "chatStartedCount",
    "averageWelcomeRating",
    "averageStructureRating",
    "safetyIncidentCount",
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
};

export const eventSafetyReportDocumentSchema = {
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
};

export const clubScheduleLockDocumentSchema = {
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
};

export const userEventScheduleLockDocumentSchema = {
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
};

export const savedEventDocumentSchema = {
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
};

export const paymentDocumentSchema = {
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
        "completed",
        "failed",
        "refunded"
      ],
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
};

export const swipeDocumentSchema = {
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
};

export const matchDocumentSchema = {
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
};

export const chatMessageDocumentSchema = {
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
};

export const activityNotificationDocumentSchema = {
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
};

export const reviewDocumentSchema = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/reviews.schema.json",
  "title": "ReviewDocument",
  "description": "Canonical attended-event review stored at reviews/{reviewId}.",
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
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
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
};

export const blockDocumentSchema = {
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
};

export const reportDocumentSchema = {
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
};

export const moderationFlagDocumentSchema = {
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
};

export const deletedUserTombstoneDocumentSchema = {
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
};

export const rateLimitDocumentSchema = {
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
};

export const functionEventReceiptDocumentSchema = {
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
};

export const seedEventManifestDocumentSchema = {
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
};

export const updateUserProfileCallablePayloadSchema = {
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
          "maxItems": 6,
          "items": {
            "type": "string",
            "format": "uri",
            "maxLength": 2048
          }
        },
        "photoThumbnailUrls": {
          "type": "array",
          "maxItems": 6,
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
          }
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
        "runPreferencesVersion": {
          "type": "integer",
          "minimum": 0
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
};

export const createClubCallablePayloadSchema = {
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
    "profileImageUrl": {
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
};

export const createClubCallableResponseSchema = {
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
};

export const updateClubCallablePayloadSchema = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/update_club_payload.schema.json",
  "title": "UpdateClubCallablePayload",
  "description": "Callable payload accepted by updateClub.",
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
        "profileImageUrl": {
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
};

export const addClubHostCallablePayloadSchema = {
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
};

export const removeClubHostCallablePayloadSchema = {
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
};

export const transferClubOwnershipCallablePayloadSchema = {
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
};

export const startClubHostConversationCallablePayloadSchema = {
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
};

export const archiveClubCallablePayloadSchema = {
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
};

export const deleteClubCallablePayloadSchema = {
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
};

export const clubMembershipCallablePayloadSchema = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/club_membership_payload.schema.json",
  "title": "ClubMembershipCallablePayload",
  "description": "Callable payload accepted by joinClub and leaveClub.",
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
};

export const setClubNotificationPreferenceCallablePayloadSchema = {
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
};

export const createEventCallablePayloadSchema = {
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
};

export const updateEventCallablePayloadSchema = {
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
};

export const cancelEventCallablePayloadSchema = {
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
};

export const deleteEventCallablePayloadSchema = {
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
};

export const eventIdCallablePayloadSchema = {
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
    }
  }
};

export const markEventAttendanceCallablePayloadSchema = {
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
};

export const eventJoinRequestDecisionCallablePayloadSchema = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/event_join_request_decision_payload.schema.json",
  "title": "EventJoinRequestDecisionCallablePayload",
  "description": "Callable payload accepted by decideEventJoinRequest.",
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
};

export const overrideEventSuccessRotationsCallablePayloadSchema = {
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
};

export const submitEventSuccessWingmanRequestCallablePayloadSchema = {
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
};

export const startEventSuccessFirstHelloMissionCallablePayloadSchema = {
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
};

export const completeEventSuccessFirstHelloMissionCallablePayloadSchema = {
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
};

export const markEventAttendanceCallableResponseSchema = {
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
};

export const selfCheckInAttendanceCallablePayloadSchema = {
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
};

export const createEventReviewCallablePayloadSchema = {
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
};

export const updateEventReviewCallablePayloadSchema = {
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
};

export const deleteEventReviewCallablePayloadSchema = {
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
};

export const blockUserCallablePayloadSchema = {
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
};

export const unblockUserCallablePayloadSchema = {
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
};

export const reportUserCallablePayloadSchema = {
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
};

export const requestSuvbotDemoOperationCallablePayloadSchema = {
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
};

export const listSuvbotDemoActionsCallableResponseSchema = {
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
};

export const verifyRazorpayPaymentCallablePayloadSchema = {
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
};

export const eventBookingCallablePayloadSchema = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/event_booking_payload.schema.json",
  "title": "EventBookingCallablePayload",
  "description": "Callable payload accepted by signUpForFreeEvent. Same shape as EventIdCallablePayload but distinct so the booking flow can diverge without breaking the generic event-id callables.",
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
    }
  }
};

export const createRazorpayOrderCallablePayloadSchema = {
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
    }
  }
};

export const razorpayOrderCallableResponseSchema = {
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
};

export const placesAutocompleteCallablePayloadSchema = {
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
};

export const placesAutocompleteCallableResponseSchema = {
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
};

export const placeDetailsCallablePayloadSchema = {
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
};

export const placeDetailsCallableResponseSchema = {
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
};

export const fetchEventSuccessWingmanCandidatesCallableResponseSchema = {
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
};

export const createProfileDecisionClientWriteSchema = {
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
  "x-firestore-path": "swipes/{userId}/outgoing/{targetId}",
  "x-logical-name": "profileDecision",
  "x-migration-phase": "observe",
  "x-owner": "authenticated profile viewer direct create; matching trigger consumes likes"
};

export const createChatMessageClientWriteSchema = {
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
};

export const createSavedEventClientWriteSchema = {
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
};

export const deleteSavedEventClientWriteSchema = {
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
};

export const markNotificationReadClientWriteSchema = {
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
};

export const resetMatchUnreadCountClientWriteSchema = {
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
};

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
      "placeholder": "Tell runners what kind of event feels like you."
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
};

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
      "title": "Proof I actually event",
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
};

export const profilePromptLimits = {
  "maxAnswers": 3,
  "maxPromptIdLength": 80,
  "maxPromptTitleLength": 140,
  "maxAnswerLength": 300
};

export const photoPromptLimits = {
  "maxPromptIdLength": 80,
  "maxPromptTitleLength": 140,
  "maxCaptionLength": 140,
  "maxCaptions": 6
};

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
};

export const defaultProfilePromptIds = [
  "perfectRun",
  "afterEvent",
  "greenFlag"
];
