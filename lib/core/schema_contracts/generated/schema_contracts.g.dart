// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names

class SchemaContractDefinition {
  const SchemaContractDefinition({
    required this.name,
    required this.source,
    required this.schema,
  });

  final String name;
  final String source;
  final Map<String, Object?> schema;
}

const schemaProfilePromptAnswerSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/embedded/profile_prompt_answer.schema.json',
  'title': 'ProfilePromptAnswer',
  'description': 'One structured written profile prompt answer stored on users and publicProfiles.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'promptId',
    'prompt',
    'answer',
  ],
  'properties': <String, Object?>{
    'promptId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
    },
    'prompt': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 140,
    },
    'answer': <String, Object?>{
      'type': 'string',
      'maxLength': 300,
    },
  },
  'x-catch-catalog': '../catalogs/profile_prompts.json',
};

const schemaPhotoPromptAnswerSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/embedded/photo_prompt_answer.schema.json',
  'title': 'PhotoPromptAnswer',
  'description': 'One optional display prompt selected for a profile photo slot. The caption field is legacy-only and should no longer be written by clients.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'photoIndex',
    'promptId',
    'prompt',
  ],
  'properties': <String, Object?>{
    'photoIndex': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 5,
    },
    'promptId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
    },
    'prompt': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 140,
    },
    'caption': <String, Object?>{
      'type': 'string',
      'maxLength': 140,
      'deprecated': true,
      'description': 'Legacy user-entered caption retained for compatibility with older documents.',
    },
  },
  'x-catch-catalog': '../catalogs/photo_prompts.json',
};

const schemaProfilePhotoSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/embedded/profile_photo.schema.json',
  'title': 'ProfilePhoto',
  'description': 'Future canonical profile-photo object that groups display URLs, Firebase Storage object paths, prompt metadata, moderation state, order, and lifecycle timestamps.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'id',
    'url',
    'thumbnailUrl',
    'storagePath',
    'thumbnailStoragePath',
    'position',
    'createdAt',
    'updatedAt',
  ],
  'properties': <String, Object?>{
    'id': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'pattern': '^[A-Za-z0-9_-]+\$',
    },
    'url': <String, Object?>{
      'type': 'string',
      'format': 'uri',
      'maxLength': 2048,
    },
    'thumbnailUrl': <String, Object?>{
      'type': 'string',
      'format': 'uri',
      'maxLength': 2048,
    },
    'storagePath': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 512,
      'pattern': '^[^/\\u0000][^\\u0000]*\$',
    },
    'thumbnailStoragePath': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 512,
      'pattern': '^[^/\\u0000][^\\u0000]*\$',
    },
    'prompt': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'title': 'PhotoPromptAnswer',
          'description': 'One optional display prompt selected for a profile photo slot. The caption field is legacy-only and should no longer be written by clients.',
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'photoIndex',
            'promptId',
            'prompt',
          ],
          'properties': <String, Object?>{
            'photoIndex': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 5,
            },
            'promptId': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 80,
            },
            'prompt': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 140,
            },
            'caption': <String, Object?>{
              'type': 'string',
              'maxLength': 140,
              'deprecated': true,
              'description': 'Legacy user-entered caption retained for compatibility with older documents.',
            },
          },
          'x-catch-catalog': '../catalogs/photo_prompts.json',
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'moderation': <String, Object?>{
      'type': <Object?>[
        'object',
        'null',
      ],
      'additionalProperties': false,
      'required': <Object?>[
        'status',
      ],
      'properties': <String, Object?>{
        'status': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'pending',
            'approved',
            'rejected',
          ],
        },
        'reason': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 240,
        },
        'reviewedAt': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'object',
              'description': 'Serialized Firestore Timestamp fixture shape.',
              'x-firestore-type': 'timestamp',
              'additionalProperties': false,
              'required': <Object?>[
                '_seconds',
                '_nanoseconds',
              ],
              'properties': <String, Object?>{
                '_seconds': <String, Object?>{
                  'type': 'integer',
                },
                '_nanoseconds': <String, Object?>{
                  'type': 'integer',
                  'minimum': 0,
                  'maximum': 999999999,
                },
              },
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
      },
    },
    'position': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 11,
    },
    'createdAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'updatedAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
  },
  'definitions': <String, Object?>{
    'storageObjectPath': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 512,
      'pattern': '^[^/\\u0000][^\\u0000]*\$',
    },
  },
  'x-storage-metadata': true,
  'x-future-field': 'profilePhotos',
  'x-migration-contract': '../migrations/profile_photos_storage.json',
};

const schemaConfigCitiesDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/config_cities.schema.json',
  'title': 'ConfigCitiesDocument',
  'description': 'Public city configuration stored at config/cities.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'config_cities',
  'x-firestore-path': 'config/cities',
  'x-document-id-field': 'cities',
  'x-owner': 'admin city configuration tooling',
  'required': <Object?>[
    'cityNames',
  ],
  'properties': <String, Object?>{
    'cityNames': <String, Object?>{
      'type': 'array',
      'items': <String, Object?>{
        'type': <Object?>[
          'string',
          'null',
        ],
        'minLength': 1,
        'maxLength': 80,
        'pattern': '^[a-z0-9-]+\$',
      },
      'minItems': 1,
      'uniqueItems': true,
    },
    'cities': <String, Object?>{
      'type': 'array',
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'name',
          'label',
          'latitude',
          'longitude',
          'countryIsoCode',
          'currencyCode',
          'dialCode',
          'timeZone',
        ],
        'properties': <String, Object?>{
          'name': <String, Object?>{
            'type': <Object?>[
              'string',
              'null',
            ],
            'minLength': 1,
            'maxLength': 80,
            'pattern': '^[a-z0-9-]+\$',
          },
          'label': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 80,
          },
          'latitude': <String, Object?>{
            'type': <Object?>[
              'number',
              'null',
            ],
            'minimum': -90,
            'maximum': 90,
          },
          'longitude': <String, Object?>{
            'type': <Object?>[
              'number',
              'null',
            ],
            'minimum': -180,
            'maximum': 180,
          },
          'countryIsoCode': <String, Object?>{
            'type': 'string',
            'pattern': '^[A-Z]{2}\$',
          },
          'currencyCode': <String, Object?>{
            'type': 'string',
            'pattern': '^[A-Z]{3}\$',
          },
          'dialCode': <String, Object?>{
            'type': 'string',
            'pattern': '^\\+\\d{1,4}\$',
          },
          'timeZone': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 80,
          },
        },
      },
      'uniqueItems': true,
    },
  },
};

const schemaOnboardingDraftDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/onboarding_drafts.schema.json',
  'title': 'OnboardingDraftDocument',
  'description': 'Owner-private, intentionally extensible onboarding draft stored at onboarding_drafts/{uid}.',
  'type': 'object',
  'additionalProperties': true,
  'x-firestore-collection': 'onboarding_drafts',
  'x-firestore-path': 'onboarding_drafts/{uid}',
  'x-document-id-field': 'uid',
  'x-owner': 'authenticated draft owner',
  'required': <Object?>[
    'step',
  ],
  'properties': <String, Object?>{
    'step': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
    'draftVersion': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
    'firstName': <String, Object?>{
      'type': 'string',
      'maxLength': 80,
    },
    'lastName': <String, Object?>{
      'type': 'string',
      'maxLength': 80,
    },
    'dateOfBirth': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'description': 'Serialized Firestore Timestamp fixture shape.',
          'x-firestore-type': 'timestamp',
          'additionalProperties': false,
          'required': <Object?>[
            '_seconds',
            '_nanoseconds',
          ],
          'properties': <String, Object?>{
            '_seconds': <String, Object?>{
              'type': 'integer',
            },
            '_nanoseconds': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 999999999,
            },
          },
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'phoneNumber': <String, Object?>{
      'type': 'string',
      'maxLength': 32,
    },
    'countryCode': <String, Object?>{
      'type': 'string',
      'maxLength': 8,
    },
    'gender': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'man',
            'woman',
            'nonBinary',
            'other',
          ],
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'interestedInGenders': <String, Object?>{
      'type': 'array',
      'items': <String, Object?>{
        'type': 'string',
        'enum': <Object?>[
          'man',
          'woman',
          'nonBinary',
          'other',
        ],
      },
      'uniqueItems': true,
    },
    'instagramHandle': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 80,
    },
    'profilePrompts': <String, Object?>{
      'type': 'array',
      'items': <String, Object?>{
        'title': 'ProfilePromptAnswer',
        'description': 'One structured written profile prompt answer stored on users and publicProfiles.',
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'promptId',
          'prompt',
          'answer',
        ],
        'properties': <String, Object?>{
          'promptId': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 80,
          },
          'prompt': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 140,
          },
          'answer': <String, Object?>{
            'type': 'string',
            'maxLength': 300,
          },
        },
        'x-catch-catalog': '../catalogs/profile_prompts.json',
      },
      'maxItems': 3,
    },
  },
};

const schemaUserProfileDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/users.schema.json',
  'title': 'UserProfileDocument',
  'description': 'Canonical private profile document stored at users/{uid}. The uid is the document id and is not stored in document data.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'users',
  'x-firestore-path': 'users/{uid}',
  'x-document-id-field': 'uid',
  'x-owner': 'owner initial create, callable-owned profile edits, server-owned projections',
  'required': <Object?>[
    'name',
    'firstName',
    'lastName',
    'displayName',
    'dateOfBirth',
    'gender',
    'phoneNumber',
    'profileComplete',
    'email',
    'profilePrompts',
    'photoUrls',
    'photoThumbnailUrls',
    'photoPrompts',
    'interestedInGenders',
    'minAgePreference',
    'maxAgePreference',
    'languages',
    'paceMinSecsPerKm',
    'paceMaxSecsPerKm',
    'preferredDistances',
    'runningReasons',
    'preferredRunTimes',
    'runPreferencesVersion',
    'prefsNewCatches',
    'prefsMessages',
    'prefsEventReminders',
    'prefsRunStatusUpdates',
    'prefsClubUpdates',
    'prefsWeeklyDigest',
    'prefsShowOnMap',
  ],
  'properties': <String, Object?>{
    'name': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
    },
    'firstName': <String, Object?>{
      'type': 'string',
      'maxLength': 80,
    },
    'lastName': <String, Object?>{
      'type': 'string',
      'maxLength': 80,
    },
    'displayName': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'pattern': '.*\\S.*',
    },
    'dateOfBirth': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'gender': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'man',
        'woman',
        'nonBinary',
        'other',
      ],
    },
    'phoneNumber': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 32,
    },
    'countryCode': <String, Object?>{
      'type': 'string',
      'pattern': '^\\+\\d{1,4}\$',
    },
    'profileComplete': <String, Object?>{
      'type': 'boolean',
    },
    'synthetic': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo seed marker used for cleanup and diagnostics.',
    },
    'seedPrefix': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed prefix used for cleanup and diagnostics.',
    },
    'scenario': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed scenario name used for cleanup and diagnostics.',
    },
    'demoOps': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo-operations marker used for cleanup and diagnostics.',
    },
    'demoOpsId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'description': 'Internal demo-operations id used for cleanup and diagnostics.',
    },
    'demoOpsCommand': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'description': 'Internal demo-operations command name used for cleanup and diagnostics.',
    },
    'email': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'const': '',
        },
        <String, Object?>{
          'type': 'string',
          'format': 'email',
          'maxLength': 320,
        },
      ],
    },
    'instagramHandle': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 30,
          'pattern': '^[A-Za-z0-9._]{1,30}\$',
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'profilePrompts': <String, Object?>{
      'type': 'array',
      'maxItems': 3,
      'items': <String, Object?>{
        'title': 'ProfilePromptAnswer',
        'description': 'One structured written profile prompt answer stored on users and publicProfiles.',
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'promptId',
          'prompt',
          'answer',
        ],
        'properties': <String, Object?>{
          'promptId': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 80,
          },
          'prompt': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 140,
          },
          'answer': <String, Object?>{
            'type': 'string',
            'maxLength': 300,
          },
        },
        'x-catch-catalog': '../catalogs/profile_prompts.json',
      },
    },
    'photoUrls': <String, Object?>{
      'type': 'array',
      'maxItems': 6,
      'items': <String, Object?>{
        'type': 'string',
        'format': 'uri',
        'maxLength': 2048,
      },
    },
    'photoThumbnailUrls': <String, Object?>{
      'type': 'array',
      'maxItems': 6,
      'items': <String, Object?>{
        'type': 'string',
        'format': 'uri',
        'maxLength': 2048,
      },
    },
    'photoPrompts': <String, Object?>{
      'type': 'array',
      'maxItems': 6,
      'items': <String, Object?>{
        'title': 'PhotoPromptAnswer',
        'description': 'One optional display prompt selected for a profile photo slot. The caption field is legacy-only and should no longer be written by clients.',
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'photoIndex',
          'promptId',
          'prompt',
        ],
        'properties': <String, Object?>{
          'photoIndex': <String, Object?>{
            'type': 'integer',
            'minimum': 0,
            'maximum': 5,
          },
          'promptId': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 80,
          },
          'prompt': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 140,
          },
          'caption': <String, Object?>{
            'type': 'string',
            'maxLength': 140,
            'deprecated': true,
            'description': 'Legacy user-entered caption retained for compatibility with older documents.',
          },
        },
        'x-catch-catalog': '../catalogs/photo_prompts.json',
      },
    },
    'profilePhotos': <String, Object?>{
      'type': 'array',
      'maxItems': 6,
      'items': <String, Object?>{
        'title': 'ProfilePhoto',
        'description': 'Future canonical profile-photo object that groups display URLs, Firebase Storage object paths, prompt metadata, moderation state, order, and lifecycle timestamps.',
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'id',
          'url',
          'thumbnailUrl',
          'storagePath',
          'thumbnailStoragePath',
          'position',
          'createdAt',
          'updatedAt',
        ],
        'properties': <String, Object?>{
          'id': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 80,
            'pattern': '^[A-Za-z0-9_-]+\$',
          },
          'url': <String, Object?>{
            'type': 'string',
            'format': 'uri',
            'maxLength': 2048,
          },
          'thumbnailUrl': <String, Object?>{
            'type': 'string',
            'format': 'uri',
            'maxLength': 2048,
          },
          'storagePath': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 512,
            'pattern': '^[^/\\u0000][^\\u0000]*\$',
          },
          'thumbnailStoragePath': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 512,
            'pattern': '^[^/\\u0000][^\\u0000]*\$',
          },
          'prompt': <String, Object?>{
            'anyOf': <Object?>[
              <String, Object?>{
                'title': 'PhotoPromptAnswer',
                'description': 'One optional display prompt selected for a profile photo slot. The caption field is legacy-only and should no longer be written by clients.',
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'photoIndex',
                  'promptId',
                  'prompt',
                ],
                'properties': <String, Object?>{
                  'photoIndex': <String, Object?>{
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 5,
                  },
                  'promptId': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 80,
                  },
                  'prompt': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 140,
                  },
                  'caption': <String, Object?>{
                    'type': 'string',
                    'maxLength': 140,
                    'deprecated': true,
                    'description': 'Legacy user-entered caption retained for compatibility with older documents.',
                  },
                },
                'x-catch-catalog': '../catalogs/photo_prompts.json',
              },
              <String, Object?>{
                'type': 'null',
              },
            ],
          },
          'moderation': <String, Object?>{
            'type': <Object?>[
              'object',
              'null',
            ],
            'additionalProperties': false,
            'required': <Object?>[
              'status',
            ],
            'properties': <String, Object?>{
              'status': <String, Object?>{
                'type': 'string',
                'enum': <Object?>[
                  'pending',
                  'approved',
                  'rejected',
                ],
              },
              'reason': <String, Object?>{
                'type': <Object?>[
                  'string',
                  'null',
                ],
                'maxLength': 240,
              },
              'reviewedAt': <String, Object?>{
                'anyOf': <Object?>[
                  <String, Object?>{
                    'type': 'object',
                    'description': 'Serialized Firestore Timestamp fixture shape.',
                    'x-firestore-type': 'timestamp',
                    'additionalProperties': false,
                    'required': <Object?>[
                      '_seconds',
                      '_nanoseconds',
                    ],
                    'properties': <String, Object?>{
                      '_seconds': <String, Object?>{
                        'type': 'integer',
                      },
                      '_nanoseconds': <String, Object?>{
                        'type': 'integer',
                        'minimum': 0,
                        'maximum': 999999999,
                      },
                    },
                  },
                  <String, Object?>{
                    'type': 'null',
                  },
                ],
              },
            },
          },
          'position': <String, Object?>{
            'type': 'integer',
            'minimum': 0,
            'maximum': 11,
          },
          'createdAt': <String, Object?>{
            'type': 'object',
            'description': 'Serialized Firestore Timestamp fixture shape.',
            'x-firestore-type': 'timestamp',
            'additionalProperties': false,
            'required': <Object?>[
              '_seconds',
              '_nanoseconds',
            ],
            'properties': <String, Object?>{
              '_seconds': <String, Object?>{
                'type': 'integer',
              },
              '_nanoseconds': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 999999999,
              },
            },
          },
          'updatedAt': <String, Object?>{
            'type': 'object',
            'description': 'Serialized Firestore Timestamp fixture shape.',
            'x-firestore-type': 'timestamp',
            'additionalProperties': false,
            'required': <Object?>[
              '_seconds',
              '_nanoseconds',
            ],
            'properties': <String, Object?>{
              '_seconds': <String, Object?>{
                'type': 'integer',
              },
              '_nanoseconds': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 999999999,
              },
            },
          },
        },
        'definitions': <String, Object?>{
          'storageObjectPath': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 512,
            'pattern': '^[^/\\u0000][^\\u0000]*\$',
          },
        },
        'x-storage-metadata': true,
        'x-future-field': 'profilePhotos',
        'x-migration-contract': '../migrations/profile_photos_storage.json',
      },
    },
    'city': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'minLength': 1,
      'maxLength': 80,
      'pattern': '^[a-z0-9-]+\$',
    },
    'latitude': <String, Object?>{
      'type': <Object?>[
        'number',
        'null',
      ],
      'minimum': -90,
      'maximum': 90,
    },
    'longitude': <String, Object?>{
      'type': <Object?>[
        'number',
        'null',
      ],
      'minimum': -180,
      'maximum': 180,
    },
    'interestedInGenders': <String, Object?>{
      'type': 'array',
      'minItems': 1,
      'maxItems': 8,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'enum': <Object?>[
          'man',
          'woman',
          'nonBinary',
          'other',
        ],
      },
    },
    'minAgePreference': <String, Object?>{
      'type': 'integer',
      'minimum': 18,
      'maximum': 99,
    },
    'maxAgePreference': <String, Object?>{
      'type': 'integer',
      'minimum': 18,
      'maximum': 99,
    },
    'height': <String, Object?>{
      'type': <Object?>[
        'integer',
        'null',
      ],
      'minimum': 120,
      'maximum': 220,
    },
    'occupation': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
    },
    'company': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
    },
    'education': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'enum': <Object?>[
        'highSchool',
        'someCollege',
        'bachelors',
        'masters',
        'phd',
        'tradeSchool',
        'other',
        null,
      ],
    },
    'religion': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'enum': <Object?>[
        'hindu',
        'muslim',
        'christian',
        'sikh',
        'jain',
        'buddhist',
        'other',
        'nonReligious',
        null,
      ],
    },
    'languages': <String, Object?>{
      'type': 'array',
      'maxItems': 20,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'enum': <Object?>[
          'english',
          'hindi',
          'marathi',
          'tamil',
          'telugu',
          'kannada',
          'bengali',
          'gujarati',
          'punjabi',
          'malayalam',
          'odia',
          'other',
        ],
      },
    },
    'relationshipGoal': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'enum': <Object?>[
        'relationship',
        'casual',
        'marriage',
        'friendship',
        'unsure',
        null,
      ],
    },
    'drinking': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'enum': <Object?>[
        'never',
        'socially',
        'often',
        null,
      ],
    },
    'smoking': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'enum': <Object?>[
        'never',
        'occasionally',
        'often',
        null,
      ],
    },
    'workout': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'enum': <Object?>[
        'never',
        'sometimes',
        'often',
        'everyday',
        null,
      ],
    },
    'diet': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'enum': <Object?>[
        'omnivore',
        'vegetarian',
        'vegan',
        'jain',
        'other',
        null,
      ],
    },
    'children': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'enum': <Object?>[
        'dontHave',
        'haveWantMore',
        'haveNoMore',
        'wantSomeday',
        'dontWant',
        null,
      ],
    },
    'paceMinSecsPerKm': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
    },
    'paceMaxSecsPerKm': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
    },
    'preferredDistances': <String, Object?>{
      'type': 'array',
      'maxItems': 12,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'enum': <Object?>[
          'fiveK',
          'tenK',
          'halfMarathon',
          'marathon',
        ],
      },
    },
    'runningReasons': <String, Object?>{
      'type': 'array',
      'maxItems': 12,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'enum': <Object?>[
          'fitness',
          'community',
          'mindfulness',
          'challenge',
          'weightLoss',
          'raceTraining',
          'social',
        ],
      },
    },
    'preferredRunTimes': <String, Object?>{
      'type': 'array',
      'maxItems': 8,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'enum': <Object?>[
          'earlyMorning',
          'morning',
          'afternoon',
          'evening',
          'night',
        ],
      },
    },
    'runPreferencesVersion': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
    'prefsNewCatches': <String, Object?>{
      'type': 'boolean',
    },
    'prefsMessages': <String, Object?>{
      'type': 'boolean',
    },
    'prefsEventReminders': <String, Object?>{
      'type': 'boolean',
    },
    'prefsRunStatusUpdates': <String, Object?>{
      'type': 'boolean',
    },
    'prefsClubUpdates': <String, Object?>{
      'type': 'boolean',
    },
    'prefsWeeklyDigest': <String, Object?>{
      'type': 'boolean',
    },
    'prefsShowOnMap': <String, Object?>{
      'type': 'boolean',
    },
    'fcmToken': <String, Object?>{
      'type': 'string',
    },
    'deleted': <String, Object?>{
      'type': 'boolean',
    },
    'deletedAt': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'description': 'Serialized Firestore Timestamp fixture shape.',
          'x-firestore-type': 'timestamp',
          'additionalProperties': false,
          'required': <Object?>[
            '_seconds',
            '_nanoseconds',
          ],
          'properties': <String, Object?>{
            '_seconds': <String, Object?>{
              'type': 'integer',
            },
            '_nanoseconds': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 999999999,
            },
          },
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
  },
  'x-internal-demo-fields': <Object?>[
    'synthetic',
    'seedPrefix',
    'scenario',
    'demoOps',
    'demoOpsId',
    'demoOpsCommand',
  ],
  'x-legacy-tolerated-fields': <Object?>[
    'bio',
  ],
  'x-denormalized-to': <Object?>[
    'publicProfiles/{uid}',
  ],
};

const schemaPublicProfileDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/public_profiles.schema.json',
  'title': 'PublicProfileDocument',
  'description': 'Backend-owned public profile projection stored at publicProfiles/{uid}. The uid is the document id and is not stored in document data.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'publicProfiles',
  'x-firestore-path': 'publicProfiles/{uid}',
  'x-document-id-field': 'uid',
  'x-owner': 'syncPublicProfile trigger',
  'x-source': 'users/{uid}',
  'required': <Object?>[
    'name',
    'age',
    'gender',
    'profilePrompts',
    'photoUrls',
    'photoThumbnailUrls',
    'photoPrompts',
    'paceMinSecsPerKm',
    'paceMaxSecsPerKm',
    'preferredDistances',
    'runningReasons',
    'preferredRunTimes',
    'runPreferencesVersion',
  ],
  'properties': <String, Object?>{
    'name': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
    },
    'age': <String, Object?>{
      'type': 'integer',
      'minimum': 18,
      'maximum': 120,
    },
    'gender': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'man',
        'woman',
        'nonBinary',
        'other',
      ],
    },
    'synthetic': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo seed marker used for cleanup and diagnostics.',
    },
    'seedPrefix': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed prefix used for cleanup and diagnostics.',
    },
    'scenario': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed scenario name used for cleanup and diagnostics.',
    },
    'demoOps': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo-operations marker used for cleanup and diagnostics.',
    },
    'demoOpsId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'description': 'Internal demo-operations id used for cleanup and diagnostics.',
    },
    'demoOpsCommand': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'description': 'Internal demo-operations command name used for cleanup and diagnostics.',
    },
    'profilePrompts': <String, Object?>{
      'type': 'array',
      'maxItems': 3,
      'items': <String, Object?>{
        'title': 'ProfilePromptAnswer',
        'description': 'One structured written profile prompt answer stored on users and publicProfiles.',
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'promptId',
          'prompt',
          'answer',
        ],
        'properties': <String, Object?>{
          'promptId': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 80,
          },
          'prompt': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 140,
          },
          'answer': <String, Object?>{
            'type': 'string',
            'maxLength': 300,
          },
        },
        'x-catch-catalog': '../catalogs/profile_prompts.json',
      },
    },
    'photoUrls': <String, Object?>{
      'type': 'array',
      'maxItems': 6,
      'items': <String, Object?>{
        'type': 'string',
        'format': 'uri',
        'maxLength': 2048,
      },
    },
    'photoThumbnailUrls': <String, Object?>{
      'type': 'array',
      'maxItems': 6,
      'items': <String, Object?>{
        'type': 'string',
        'format': 'uri',
        'maxLength': 2048,
      },
    },
    'photoPrompts': <String, Object?>{
      'type': 'array',
      'maxItems': 6,
      'items': <String, Object?>{
        'title': 'PhotoPromptAnswer',
        'description': 'One optional display prompt selected for a profile photo slot. The caption field is legacy-only and should no longer be written by clients.',
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'photoIndex',
          'promptId',
          'prompt',
        ],
        'properties': <String, Object?>{
          'photoIndex': <String, Object?>{
            'type': 'integer',
            'minimum': 0,
            'maximum': 5,
          },
          'promptId': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 80,
          },
          'prompt': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 140,
          },
          'caption': <String, Object?>{
            'type': 'string',
            'maxLength': 140,
            'deprecated': true,
            'description': 'Legacy user-entered caption retained for compatibility with older documents.',
          },
        },
        'x-catch-catalog': '../catalogs/photo_prompts.json',
      },
    },
    'profilePhotos': <String, Object?>{
      'type': 'array',
      'maxItems': 6,
      'items': <String, Object?>{
        'title': 'ProfilePhoto',
        'description': 'Future canonical profile-photo object that groups display URLs, Firebase Storage object paths, prompt metadata, moderation state, order, and lifecycle timestamps.',
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'id',
          'url',
          'thumbnailUrl',
          'storagePath',
          'thumbnailStoragePath',
          'position',
          'createdAt',
          'updatedAt',
        ],
        'properties': <String, Object?>{
          'id': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 80,
            'pattern': '^[A-Za-z0-9_-]+\$',
          },
          'url': <String, Object?>{
            'type': 'string',
            'format': 'uri',
            'maxLength': 2048,
          },
          'thumbnailUrl': <String, Object?>{
            'type': 'string',
            'format': 'uri',
            'maxLength': 2048,
          },
          'storagePath': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 512,
            'pattern': '^[^/\\u0000][^\\u0000]*\$',
          },
          'thumbnailStoragePath': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 512,
            'pattern': '^[^/\\u0000][^\\u0000]*\$',
          },
          'prompt': <String, Object?>{
            'anyOf': <Object?>[
              <String, Object?>{
                'title': 'PhotoPromptAnswer',
                'description': 'One optional display prompt selected for a profile photo slot. The caption field is legacy-only and should no longer be written by clients.',
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'photoIndex',
                  'promptId',
                  'prompt',
                ],
                'properties': <String, Object?>{
                  'photoIndex': <String, Object?>{
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 5,
                  },
                  'promptId': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 80,
                  },
                  'prompt': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 140,
                  },
                  'caption': <String, Object?>{
                    'type': 'string',
                    'maxLength': 140,
                    'deprecated': true,
                    'description': 'Legacy user-entered caption retained for compatibility with older documents.',
                  },
                },
                'x-catch-catalog': '../catalogs/photo_prompts.json',
              },
              <String, Object?>{
                'type': 'null',
              },
            ],
          },
          'moderation': <String, Object?>{
            'type': <Object?>[
              'object',
              'null',
            ],
            'additionalProperties': false,
            'required': <Object?>[
              'status',
            ],
            'properties': <String, Object?>{
              'status': <String, Object?>{
                'type': 'string',
                'enum': <Object?>[
                  'pending',
                  'approved',
                  'rejected',
                ],
              },
              'reason': <String, Object?>{
                'type': <Object?>[
                  'string',
                  'null',
                ],
                'maxLength': 240,
              },
              'reviewedAt': <String, Object?>{
                'anyOf': <Object?>[
                  <String, Object?>{
                    'type': 'object',
                    'description': 'Serialized Firestore Timestamp fixture shape.',
                    'x-firestore-type': 'timestamp',
                    'additionalProperties': false,
                    'required': <Object?>[
                      '_seconds',
                      '_nanoseconds',
                    ],
                    'properties': <String, Object?>{
                      '_seconds': <String, Object?>{
                        'type': 'integer',
                      },
                      '_nanoseconds': <String, Object?>{
                        'type': 'integer',
                        'minimum': 0,
                        'maximum': 999999999,
                      },
                    },
                  },
                  <String, Object?>{
                    'type': 'null',
                  },
                ],
              },
            },
          },
          'position': <String, Object?>{
            'type': 'integer',
            'minimum': 0,
            'maximum': 11,
          },
          'createdAt': <String, Object?>{
            'type': 'object',
            'description': 'Serialized Firestore Timestamp fixture shape.',
            'x-firestore-type': 'timestamp',
            'additionalProperties': false,
            'required': <Object?>[
              '_seconds',
              '_nanoseconds',
            ],
            'properties': <String, Object?>{
              '_seconds': <String, Object?>{
                'type': 'integer',
              },
              '_nanoseconds': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 999999999,
              },
            },
          },
          'updatedAt': <String, Object?>{
            'type': 'object',
            'description': 'Serialized Firestore Timestamp fixture shape.',
            'x-firestore-type': 'timestamp',
            'additionalProperties': false,
            'required': <Object?>[
              '_seconds',
              '_nanoseconds',
            ],
            'properties': <String, Object?>{
              '_seconds': <String, Object?>{
                'type': 'integer',
              },
              '_nanoseconds': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 999999999,
              },
            },
          },
        },
        'definitions': <String, Object?>{
          'storageObjectPath': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 512,
            'pattern': '^[^/\\u0000][^\\u0000]*\$',
          },
        },
        'x-storage-metadata': true,
        'x-future-field': 'profilePhotos',
        'x-migration-contract': '../migrations/profile_photos_storage.json',
      },
    },
    'city': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'minLength': 1,
      'maxLength': 80,
      'pattern': '^[a-z0-9-]+\$',
    },
    'height': <String, Object?>{
      'type': <Object?>[
        'integer',
        'null',
      ],
      'minimum': 120,
      'maximum': 220,
    },
    'occupation': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
    },
    'company': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
    },
    'education': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'enum': <Object?>[
        'highSchool',
        'someCollege',
        'bachelors',
        'masters',
        'phd',
        'tradeSchool',
        'other',
        null,
      ],
    },
    'religion': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'enum': <Object?>[
        'hindu',
        'muslim',
        'christian',
        'sikh',
        'jain',
        'buddhist',
        'other',
        'nonReligious',
        null,
      ],
    },
    'languages': <String, Object?>{
      'type': 'array',
      'maxItems': 20,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'enum': <Object?>[
          'english',
          'hindi',
          'marathi',
          'tamil',
          'telugu',
          'kannada',
          'bengali',
          'gujarati',
          'punjabi',
          'malayalam',
          'odia',
          'other',
        ],
      },
    },
    'relationshipGoal': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'enum': <Object?>[
        'relationship',
        'casual',
        'marriage',
        'friendship',
        'unsure',
        null,
      ],
    },
    'drinking': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'enum': <Object?>[
        'never',
        'socially',
        'often',
        null,
      ],
    },
    'smoking': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'enum': <Object?>[
        'never',
        'occasionally',
        'often',
        null,
      ],
    },
    'workout': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'enum': <Object?>[
        'never',
        'sometimes',
        'often',
        'everyday',
        null,
      ],
    },
    'diet': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'enum': <Object?>[
        'omnivore',
        'vegetarian',
        'vegan',
        'jain',
        'other',
        null,
      ],
    },
    'children': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'enum': <Object?>[
        'dontHave',
        'haveWantMore',
        'haveNoMore',
        'wantSomeday',
        'dontWant',
        null,
      ],
    },
    'paceMinSecsPerKm': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
    },
    'paceMaxSecsPerKm': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
    },
    'preferredDistances': <String, Object?>{
      'type': 'array',
      'maxItems': 12,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'enum': <Object?>[
          'fiveK',
          'tenK',
          'halfMarathon',
          'marathon',
        ],
      },
    },
    'runningReasons': <String, Object?>{
      'type': 'array',
      'maxItems': 12,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'enum': <Object?>[
          'fitness',
          'community',
          'mindfulness',
          'challenge',
          'weightLoss',
          'raceTraining',
          'social',
        ],
      },
    },
    'preferredRunTimes': <String, Object?>{
      'type': 'array',
      'maxItems': 8,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'enum': <Object?>[
          'earlyMorning',
          'morning',
          'afternoon',
          'evening',
          'night',
        ],
      },
    },
    'runPreferencesVersion': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
  },
  'x-internal-demo-fields': <Object?>[
    'synthetic',
    'seedPrefix',
    'scenario',
    'demoOps',
    'demoOpsId',
    'demoOpsCommand',
  ],
  'x-legacy-tolerated-fields': <Object?>[
    'bio',
  ],
  'x-hidden-fields': <Object?>[
    'phoneNumber',
    'email',
    'instagramHandle',
    'latitude',
    'longitude',
    'interestedInGenders',
    'preferences',
  ],
};

const schemaClubDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/clubs.schema.json',
  'title': 'ClubDocument',
  'description': 'Canonical club document stored at clubs/{clubId}. The club id is the document id and is not stored in document data.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'clubs',
  'x-firestore-path': 'clubs/{clubId}',
  'x-document-id-field': 'id',
  'x-owner': 'create/update/archive/delete club callables; aggregate projections are trigger-owned',
  'x-internal-demo-fields': <Object?>[
    'synthetic',
    'seedPrefix',
    'scenario',
    'demoOps',
    'demoOpsId',
    'demoOpsCommand',
  ],
  'required': <Object?>[
    'name',
    'description',
    'location',
    'area',
    'hostUserId',
    'hostName',
    'hostAvatarUrl',
    'ownerUserId',
    'hostUserIds',
    'hostProfiles',
    'createdAt',
    'imageUrl',
    'profileImageUrl',
    'tags',
    'memberCount',
    'rating',
    'reviewCount',
    'nextEventAt',
    'nextEventLabel',
    'instagramHandle',
    'phoneNumber',
    'email',
    'status',
    'archived',
    'archivedAt',
    'archiveReason',
  ],
  'properties': <String, Object?>{
    'name': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
    },
    'description': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 2000,
    },
    'location': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'minLength': 1,
      'maxLength': 80,
      'pattern': '^[a-z0-9-]+\$',
    },
    'area': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
    },
    'hostUserId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'hostName': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
    },
    'hostAvatarUrl': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'string',
          'format': 'uri',
          'maxLength': 2048,
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'ownerUserId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'hostUserIds': <String, Object?>{
      'type': 'array',
      'minItems': 1,
      'maxItems': 20,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
        'maxLength': 180,
      },
    },
    'hostProfiles': <String, Object?>{
      'type': 'array',
      'minItems': 1,
      'maxItems': 20,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'uid',
          'displayName',
          'avatarUrl',
          'role',
        ],
        'properties': <String, Object?>{
          'uid': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 180,
          },
          'displayName': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 120,
          },
          'avatarUrl': <String, Object?>{
            'anyOf': <Object?>[
              <String, Object?>{
                'type': 'string',
                'format': 'uri',
                'maxLength': 2048,
              },
              <String, Object?>{
                'type': 'null',
              },
            ],
          },
          'role': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'owner',
              'host',
            ],
          },
        },
      },
    },
    'createdAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'imageUrl': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'string',
          'format': 'uri',
          'maxLength': 2048,
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'profileImageUrl': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'string',
          'format': 'uri',
          'maxLength': 2048,
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'tags': <String, Object?>{
      'type': 'array',
      'maxItems': 20,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
        'maxLength': 80,
      },
    },
    'memberCount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
    'rating': <String, Object?>{
      'type': 'number',
      'minimum': 0,
      'maximum': 5,
    },
    'reviewCount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
    'nextEventAt': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'description': 'Serialized Firestore Timestamp fixture shape.',
          'x-firestore-type': 'timestamp',
          'additionalProperties': false,
          'required': <Object?>[
            '_seconds',
            '_nanoseconds',
          ],
          'properties': <String, Object?>{
            '_seconds': <String, Object?>{
              'type': 'integer',
            },
            '_nanoseconds': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 999999999,
            },
          },
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'nextEventLabel': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 240,
    },
    'instagramHandle': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 320,
    },
    'phoneNumber': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 320,
    },
    'email': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 320,
    },
    'status': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'active',
        'archived',
      ],
    },
    'archived': <String, Object?>{
      'type': 'boolean',
    },
    'archivedAt': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'description': 'Serialized Firestore Timestamp fixture shape.',
          'x-firestore-type': 'timestamp',
          'additionalProperties': false,
          'required': <Object?>[
            '_seconds',
            '_nanoseconds',
          ],
          'properties': <String, Object?>{
            '_seconds': <String, Object?>{
              'type': 'integer',
            },
            '_nanoseconds': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 999999999,
            },
          },
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'archiveReason': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 500,
    },
    'hostDefaults': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'properties': <String, Object?>{
        'primaryActivityKind': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'socialRun',
            'running',
            'walking',
            'pickleball',
            'padel',
            'tennis',
            'badminton',
            'cycling',
            'spinClass',
            'yoga',
            'strengthTraining',
            'pubQuiz',
            'barCrawl',
            'dinner',
            'singlesMixer',
            'openActivity',
          ],
        },
        'supportedActivityKinds': <String, Object?>{
          'type': 'array',
          'maxItems': 16,
          'uniqueItems': true,
          'items': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'socialRun',
              'running',
              'walking',
              'pickleball',
              'padel',
              'tennis',
              'badminton',
              'cycling',
              'spinClass',
              'yoga',
              'strengthTraining',
              'pubQuiz',
              'barCrawl',
              'dinner',
              'singlesMixer',
              'openActivity',
            ],
          },
        },
        'eventPolicy': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'properties': <String, Object?>{
            'admissionPreset': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'openCapacity',
                'inviteOnly',
                'balancedSingles',
                'fixedCohortCaps',
              ],
            },
            'minAge': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 120,
            },
            'maxAge': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 120,
            },
            'maxMen': <String, Object?>{
              'type': <Object?>[
                'integer',
                'null',
              ],
              'minimum': 0,
            },
            'maxWomen': <String, Object?>{
              'type': <Object?>[
                'integer',
                'null',
              ],
              'minimum': 0,
            },
            'dynamicPricingEnabled': <String, Object?>{
              'type': 'boolean',
            },
            'dynamicPricingStepInPaise': <String, Object?>{
              'type': <Object?>[
                'integer',
                'null',
              ],
              'minimum': 0,
              'maximum': 100000000,
            },
            'dynamicPricingMaxInPaise': <String, Object?>{
              'type': <Object?>[
                'integer',
                'null',
              ],
              'minimum': 0,
              'maximum': 100000000,
            },
            'cancellationPolicyId': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'flexible',
                'standard',
                'strict',
              ],
            },
          },
        },
        'eventSuccess': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'properties': <String, Object?>{
            'enabled': <String, Object?>{
              'type': 'boolean',
            },
            'playbookId': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 120,
            },
            'selectedModuleIds': <String, Object?>{
              'type': 'array',
              'maxItems': 24,
              'items': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 120,
              },
            },
            'structureConfig': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'unitKind',
                'unitSize',
                'revealCountdownSeconds',
              ],
              'properties': <String, Object?>{
                'unitKind': <String, Object?>{
                  'type': 'string',
                  'enum': <Object?>[
                    'wholeGroup',
                    'pods',
                    'pairs',
                    'teams',
                    'tables',
                  ],
                },
                'unitSize': <String, Object?>{
                  'type': 'integer',
                  'minimum': 1,
                  'maximum': 1000,
                },
                'unitCount': <String, Object?>{
                  'type': <Object?>[
                    'integer',
                    'null',
                  ],
                  'minimum': 1,
                  'maximum': 200,
                },
                'rotationIntervalMinutes': <String, Object?>{
                  'type': <Object?>[
                    'integer',
                    'null',
                  ],
                  'minimum': 5,
                  'maximum': 180,
                },
                'revealCountdownSeconds': <String, Object?>{
                  'type': 'integer',
                  'minimum': 0,
                  'maximum': 60,
                },
              },
            },
            'hostGoal': <String, Object?>{
              'type': 'string',
              'maxLength': 300,
            },
            'wingmanRequestsEnabled': <String, Object?>{
              'type': 'boolean',
            },
            'contextualOpenersEnabled': <String, Object?>{
              'type': 'boolean',
            },
            'compatibilityAffectsRanking': <String, Object?>{
              'type': 'boolean',
            },
            'questionnaireConfig': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'templateId',
              ],
              'properties': <String, Object?>{
                'templateId': <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                  'maxLength': 120,
                },
                'customTitle': <String, Object?>{
                  'type': <Object?>[
                    'string',
                    'null',
                  ],
                  'maxLength': 80,
                },
                'customQuestions': <String, Object?>{
                  'type': 'array',
                  'maxItems': 8,
                  'items': <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'id',
                      'prompt',
                      'options',
                    ],
                    'properties': <String, Object?>{
                      'id': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 120,
                      },
                      'prompt': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 140,
                      },
                      'options': <String, Object?>{
                        'type': 'array',
                        'minItems': 2,
                        'maxItems': 5,
                        'items': <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'id',
                            'label',
                          ],
                          'properties': <String, Object?>{
                            'id': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 120,
                            },
                            'label': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 80,
                            },
                          },
                        },
                      },
                    },
                  },
                },
              },
            },
            'attendeePrompt': <String, Object?>{
              'type': <Object?>[
                'string',
                'null',
              ],
              'maxLength': 300,
            },
          },
        },
        'eventSuccessByActivityKind': <String, Object?>{
          'type': 'object',
          'maxProperties': 16,
          'additionalProperties': <String, Object?>{
            'type': 'object',
            'additionalProperties': false,
            'properties': <String, Object?>{
              'enabled': <String, Object?>{
                'type': 'boolean',
              },
              'playbookId': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 120,
              },
              'selectedModuleIds': <String, Object?>{
                'type': 'array',
                'maxItems': 24,
                'items': <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                  'maxLength': 120,
                },
              },
              'structureConfig': <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'unitKind',
                  'unitSize',
                  'revealCountdownSeconds',
                ],
                'properties': <String, Object?>{
                  'unitKind': <String, Object?>{
                    'type': 'string',
                    'enum': <Object?>[
                      'wholeGroup',
                      'pods',
                      'pairs',
                      'teams',
                      'tables',
                    ],
                  },
                  'unitSize': <String, Object?>{
                    'type': 'integer',
                    'minimum': 1,
                    'maximum': 1000,
                  },
                  'unitCount': <String, Object?>{
                    'type': <Object?>[
                      'integer',
                      'null',
                    ],
                    'minimum': 1,
                    'maximum': 200,
                  },
                  'rotationIntervalMinutes': <String, Object?>{
                    'type': <Object?>[
                      'integer',
                      'null',
                    ],
                    'minimum': 5,
                    'maximum': 180,
                  },
                  'revealCountdownSeconds': <String, Object?>{
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 60,
                  },
                },
              },
              'hostGoal': <String, Object?>{
                'type': 'string',
                'maxLength': 300,
              },
              'wingmanRequestsEnabled': <String, Object?>{
                'type': 'boolean',
              },
              'contextualOpenersEnabled': <String, Object?>{
                'type': 'boolean',
              },
              'compatibilityAffectsRanking': <String, Object?>{
                'type': 'boolean',
              },
              'questionnaireConfig': <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'templateId',
                ],
                'properties': <String, Object?>{
                  'templateId': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 120,
                  },
                  'customTitle': <String, Object?>{
                    'type': <Object?>[
                      'string',
                      'null',
                    ],
                    'maxLength': 80,
                  },
                  'customQuestions': <String, Object?>{
                    'type': 'array',
                    'maxItems': 8,
                    'items': <String, Object?>{
                      'type': 'object',
                      'additionalProperties': false,
                      'required': <Object?>[
                        'id',
                        'prompt',
                        'options',
                      ],
                      'properties': <String, Object?>{
                        'id': <String, Object?>{
                          'type': 'string',
                          'minLength': 1,
                          'maxLength': 120,
                        },
                        'prompt': <String, Object?>{
                          'type': 'string',
                          'minLength': 1,
                          'maxLength': 140,
                        },
                        'options': <String, Object?>{
                          'type': 'array',
                          'minItems': 2,
                          'maxItems': 5,
                          'items': <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'id',
                              'label',
                            ],
                            'properties': <String, Object?>{
                              'id': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 120,
                              },
                              'label': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 80,
                              },
                            },
                          },
                        },
                      },
                    },
                  },
                },
              },
              'attendeePrompt': <String, Object?>{
                'type': <Object?>[
                  'string',
                  'null',
                ],
                'maxLength': 300,
              },
            },
          },
        },
      },
    },
    'synthetic': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo seed marker used for cleanup and diagnostics.',
    },
    'seedPrefix': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed prefix used for cleanup and diagnostics.',
    },
    'scenario': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed scenario name used for cleanup and diagnostics.',
    },
    'demoOps': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo-operations marker used for cleanup and diagnostics.',
    },
    'demoOpsId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'description': 'Internal demo-operations id used for cleanup and diagnostics.',
    },
    'demoOpsCommand': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'description': 'Internal demo-operations command name used for cleanup and diagnostics.',
    },
  },
};

const schemaClubMembershipDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/club_memberships.schema.json',
  'title': 'ClubMembershipDocument',
  'description': 'Canonical club membership edge stored at clubMemberships/{membershipId}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'clubMemberships',
  'x-firestore-path': 'clubMemberships/{membershipId}',
  'x-document-id-field': 'id',
  'x-owner': 'club membership callables; parent member count is trigger-owned',
  'x-internal-demo-fields': <Object?>[
    'synthetic',
    'seedPrefix',
    'scenario',
    'demoOps',
    'demoOpsId',
    'demoOpsCommand',
  ],
  'required': <Object?>[
    'clubId',
    'uid',
    'role',
    'status',
    'pushNotificationsEnabled',
    'joinedAt',
    'leftAt',
    'deletedAt',
  ],
  'properties': <String, Object?>{
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'uid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'role': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'owner',
        'host',
        'member',
      ],
    },
    'status': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'active',
        'left',
        'deleted',
      ],
    },
    'pushNotificationsEnabled': <String, Object?>{
      'type': 'boolean',
    },
    'joinedAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'leftAt': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'description': 'Serialized Firestore Timestamp fixture shape.',
          'x-firestore-type': 'timestamp',
          'additionalProperties': false,
          'required': <Object?>[
            '_seconds',
            '_nanoseconds',
          ],
          'properties': <String, Object?>{
            '_seconds': <String, Object?>{
              'type': 'integer',
            },
            '_nanoseconds': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 999999999,
            },
          },
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'deletedAt': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'description': 'Serialized Firestore Timestamp fixture shape.',
          'x-firestore-type': 'timestamp',
          'additionalProperties': false,
          'required': <Object?>[
            '_seconds',
            '_nanoseconds',
          ],
          'properties': <String, Object?>{
            '_seconds': <String, Object?>{
              'type': 'integer',
            },
            '_nanoseconds': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 999999999,
            },
          },
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'synthetic': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo seed marker used for cleanup and diagnostics.',
    },
    'seedPrefix': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed prefix used for cleanup and diagnostics.',
    },
    'scenario': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed scenario name used for cleanup and diagnostics.',
    },
    'demoOps': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo-operations marker used for cleanup and diagnostics.',
    },
    'demoOpsId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'description': 'Internal demo-operations id used for cleanup and diagnostics.',
    },
    'demoOpsCommand': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'description': 'Internal demo-operations command name used for cleanup and diagnostics.',
    },
  },
};

const schemaClubHostClaimDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/club_host_claims.schema.json',
  'title': 'ClubHostClaimDocument',
  'description': 'Server-owned singleton claim stored at clubHostClaims/{uid} to enforce one hosted club per user.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'clubHostClaims',
  'x-firestore-path': 'clubHostClaims/{uid}',
  'x-document-id-field': 'uid',
  'x-owner': 'createClub callable',
  'required': <Object?>[
    'uid',
    'clubId',
    'createdAt',
  ],
  'properties': <String, Object?>{
    'uid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'createdAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
  },
};

const schemaEventDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/events.schema.json',
  'title': 'EventDocument',
  'description': 'Canonical event document stored at events/{eventId}. The event id is the document id and is not stored in document data.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'events',
  'x-firestore-path': 'events/{eventId}',
  'x-document-id-field': 'id',
  'x-owner': 'host create/update/cancel/delete callables; booking and attendance aggregates are callable-owned',
  'x-internal-demo-fields': <Object?>[
    'synthetic',
    'seedPrefix',
    'scenario',
    'demoOps',
    'demoOpsId',
    'demoOpsCommand',
  ],
  'required': <Object?>[
    'clubId',
    'startTime',
    'endTime',
    'meetingPoint',
    'startingPointLat',
    'startingPointLng',
    'locationDetails',
    'eventFormat',
    'distanceKm',
    'pace',
    'capacityLimit',
    'description',
    'priceInPaise',
    'bookedCount',
    'checkedInCount',
    'waitlistedCount',
    'status',
    'cancelledAt',
    'cancellationReason',
    'constraints',
    'genderCounts',
    'cohortCounts',
    'waitlistedCohortCounts',
  ],
  'properties': <String, Object?>{
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'startTime': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'endTime': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'meetingPoint': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 240,
    },
    'meetingLocation': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'description': 'Canonical meeting location selected from Google Places or a manually pinned map coordinate.',
      'required': <Object?>[
        'name',
        'latitude',
        'longitude',
      ],
      'properties': <String, Object?>{
        'name': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 240,
        },
        'address': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 500,
        },
        'placeId': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'minLength': 1,
          'maxLength': 256,
        },
        'latitude': <String, Object?>{
          'type': <Object?>[
            'number',
            'null',
          ],
          'minimum': -90,
          'maximum': 90,
        },
        'longitude': <String, Object?>{
          'type': <Object?>[
            'number',
            'null',
          ],
          'minimum': -180,
          'maximum': 180,
        },
        'notes': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 1000,
        },
      },
    },
    'startingPointLat': <String, Object?>{
      'type': <Object?>[
        'number',
        'null',
      ],
      'minimum': -90,
      'maximum': 90,
    },
    'startingPointLng': <String, Object?>{
      'type': <Object?>[
        'number',
        'null',
      ],
      'minimum': -180,
      'maximum': 180,
    },
    'locationDetails': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 1000,
    },
    'photoUrl': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'string',
          'format': 'uri',
          'maxLength': 2048,
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'distanceKm': <String, Object?>{
      'type': 'number',
      'minimum': 0,
      'maximum': 100,
    },
    'eventFormat': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'version',
        'activityKind',
        'interactionModel',
      ],
      'properties': <String, Object?>{
        'version': <String, Object?>{
          'type': 'integer',
          'const': 1,
        },
        'activityKind': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'socialRun',
            'running',
            'walking',
            'pickleball',
            'padel',
            'tennis',
            'badminton',
            'cycling',
            'spinClass',
            'yoga',
            'strengthTraining',
            'pubQuiz',
            'barCrawl',
            'dinner',
            'singlesMixer',
            'openActivity',
          ],
        },
        'interactionModel': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'pacePods',
            'pairedRotations',
            'teamRotations',
            'seatedTable',
            'freeFormMixer',
            'hostLedProgram',
            'openFormat',
          ],
        },
        'customActivityLabel': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 80,
        },
        'defaultPlaybookId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 120,
        },
        'defaultModuleIds': <String, Object?>{
          'type': 'array',
          'items': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 120,
          },
          'maxItems': 30,
          'uniqueItems': true,
        },
        'activityDetails': <String, Object?>{
          'type': 'object',
          'additionalProperties': true,
        },
      },
    },
    'pace': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'easy',
        'moderate',
        'fast',
        'competitive',
      ],
    },
    'capacityLimit': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 1000,
    },
    'description': <String, Object?>{
      'type': 'string',
      'maxLength': 2000,
    },
    'priceInPaise': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 100000000,
    },
    'currency': <String, Object?>{
      'type': 'string',
      'pattern': '^[A-Z]{3}\$',
    },
    'bookedCount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
    'checkedInCount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
    'waitlistedCount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
    'status': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'active',
        'cancelled',
      ],
    },
    'cancelledAt': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'description': 'Serialized Firestore Timestamp fixture shape.',
          'x-firestore-type': 'timestamp',
          'additionalProperties': false,
          'required': <Object?>[
            '_seconds',
            '_nanoseconds',
          ],
          'properties': <String, Object?>{
            '_seconds': <String, Object?>{
              'type': 'integer',
            },
            '_nanoseconds': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 999999999,
            },
          },
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'cancellationReason': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 500,
    },
    'constraints': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'minAge',
        'maxAge',
        'maxMen',
        'maxWomen',
      ],
      'properties': <String, Object?>{
        'minAge': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 120,
        },
        'maxAge': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 120,
        },
        'maxMen': <String, Object?>{
          'type': <Object?>[
            'integer',
            'null',
          ],
          'minimum': 0,
        },
        'maxWomen': <String, Object?>{
          'type': <Object?>[
            'integer',
            'null',
          ],
          'minimum': 0,
        },
      },
    },
    'eventPolicy': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'version',
        'admission',
        'pricing',
        'cancellation',
        'settlement',
      ],
      'properties': <String, Object?>{
        'version': <String, Object?>{
          'type': 'integer',
          'const': 1,
        },
        'admission': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'format',
            'capacityLimit',
            'waitlistPolicy',
            'inviteRequired',
            'membershipRequired',
            'manualApprovalRequired',
            'privateAccessPolicy',
            'cohortCapacityLimits',
            'balancedRatioPolicy',
          ],
          'properties': <String, Object?>{
            'format': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'open',
                'inviteOnly',
                'manualApproval',
                'fixedCohortCaps',
                'balancedRatio',
                'membersOnly',
              ],
            },
            'capacityLimit': <String, Object?>{
              'type': 'integer',
              'minimum': 1,
              'maximum': 1000,
            },
            'waitlistPolicy': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'mode',
                'offerWindowMinutes',
              ],
              'properties': <String, Object?>{
                'mode': <String, Object?>{
                  'type': 'string',
                  'enum': <Object?>[
                    'disabled',
                    'rankedOffer',
                    'broadcastFirstComeFirstServed',
                    'manualReview',
                  ],
                },
                'offerWindowMinutes': <String, Object?>{
                  'type': 'integer',
                  'minimum': 0,
                  'maximum': 10080,
                },
              },
            },
            'inviteRequired': <String, Object?>{
              'type': 'boolean',
            },
            'membershipRequired': <String, Object?>{
              'type': 'boolean',
            },
            'manualApprovalRequired': <String, Object?>{
              'type': 'boolean',
            },
            'privateAccessPolicy': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'mode',
                'inviteCodeHint',
                'privateLinkEnabled',
              ],
              'properties': <String, Object?>{
                'mode': <String, Object?>{
                  'type': 'string',
                  'enum': <Object?>[
                    'none',
                    'inviteCode',
                  ],
                },
                'inviteCodeHint': <String, Object?>{
                  'type': <Object?>[
                    'string',
                    'null',
                  ],
                  'maxLength': 64,
                },
                'privateLinkEnabled': <String, Object?>{
                  'type': 'boolean',
                },
              },
            },
            'cohortCapacityLimits': <String, Object?>{
              'type': 'object',
              'additionalProperties': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
              },
            },
            'balancedRatioPolicy': <String, Object?>{
              'type': <Object?>[
                'object',
                'null',
              ],
              'additionalProperties': false,
              'required': <Object?>[
                'leftCohortId',
                'rightCohortId',
                'maxSkew',
                'openingBufferPerCohort',
                'outOfRatioCohortPolicy',
              ],
              'properties': <String, Object?>{
                'leftCohortId': <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                  'maxLength': 120,
                },
                'rightCohortId': <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                  'maxLength': 120,
                },
                'maxSkew': <String, Object?>{
                  'type': 'integer',
                  'minimum': 0,
                  'maximum': 1000,
                },
                'openingBufferPerCohort': <String, Object?>{
                  'type': 'integer',
                  'minimum': 0,
                  'maximum': 1000,
                },
                'outOfRatioCohortPolicy': <String, Object?>{
                  'type': 'string',
                  'enum': <Object?>[
                    'admitWithinGeneralCapacity',
                    'waitlist',
                    'manualReview',
                    'reject',
                  ],
                },
              },
            },
          },
        },
        'pricing': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'basePriceInPaise',
            'cohortAdjustmentsInPaise',
            'demandPricingRules',
          ],
          'properties': <String, Object?>{
            'basePriceInPaise': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 100000000,
            },
            'cohortAdjustmentsInPaise': <String, Object?>{
              'type': 'object',
              'additionalProperties': <String, Object?>{
                'type': 'integer',
                'minimum': -100000000,
                'maximum': 100000000,
              },
            },
            'demandPricingRules': <String, Object?>{
              'type': 'array',
              'maxItems': 20,
              'items': <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'pricedCohortId',
                  'balancingCohortId',
                  'stepAdjustmentInPaise',
                  'maxAdjustmentInPaise',
                  'freeSkew',
                  'demandStep',
                ],
                'properties': <String, Object?>{
                  'pricedCohortId': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 120,
                  },
                  'balancingCohortId': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 120,
                  },
                  'stepAdjustmentInPaise': <String, Object?>{
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 100000000,
                  },
                  'maxAdjustmentInPaise': <String, Object?>{
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 100000000,
                  },
                  'freeSkew': <String, Object?>{
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 1000,
                  },
                  'demandStep': <String, Object?>{
                    'type': 'integer',
                    'minimum': 1,
                    'maximum': 1000,
                  },
                },
              },
            },
          },
        },
        'cancellation': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'policyId',
          ],
          'properties': <String, Object?>{
            'policyId': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'flexible',
                'standard',
                'strict',
              ],
            },
          },
        },
        'settlement': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'hostPayoutTiming',
          ],
          'properties': <String, Object?>{
            'hostPayoutTiming': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'afterEventCompletion',
              ],
            },
          },
        },
      },
    },
    'genderCounts': <String, Object?>{
      'type': 'object',
      'additionalProperties': <String, Object?>{
        'type': 'integer',
        'minimum': 0,
      },
    },
    'cohortCounts': <String, Object?>{
      'type': 'object',
      'additionalProperties': <String, Object?>{
        'type': 'integer',
        'minimum': 0,
      },
    },
    'waitlistedCohortCounts': <String, Object?>{
      'type': 'object',
      'additionalProperties': <String, Object?>{
        'type': 'integer',
        'minimum': 0,
      },
    },
    'synthetic': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo seed marker used for cleanup and diagnostics.',
    },
    'seedPrefix': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed prefix used for cleanup and diagnostics.',
    },
    'scenario': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed scenario name used for cleanup and diagnostics.',
    },
    'demoOps': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo-operations marker used for cleanup and diagnostics.',
    },
    'demoOpsId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'description': 'Internal demo-operations id used for cleanup and diagnostics.',
    },
    'demoOpsCommand': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'description': 'Internal demo-operations command name used for cleanup and diagnostics.',
    },
  },
};

const schemaEventPrivateAccessDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/event_private_access.schema.json',
  'title': 'EventPrivateAccessDocument',
  'description': 'Host-private access material for invite-only events stored at eventPrivateAccess/{eventId}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'eventPrivateAccess',
  'x-firestore-path': 'eventPrivateAccess/{eventId}',
  'x-document-id-field': 'id',
  'x-owner': 'createEvent callable; readable only by the host of the linked event',
  'required': <Object?>[
    'eventId',
    'clubId',
    'inviteCode',
    'createdAt',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'inviteCode': <String, Object?>{
      'type': 'string',
      'minLength': 4,
      'maxLength': 64,
      'pattern': '^[A-Za-z0-9_-]+\$',
    },
    'createdAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
  },
};

const schemaEventParticipationDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/event_participations.schema.json',
  'title': 'EventParticipationDocument',
  'description': 'Canonical event roster edge stored at eventParticipations/{participationId}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'eventParticipations',
  'x-firestore-path': 'eventParticipations/{participationId}',
  'x-document-id-field': 'id',
  'x-owner': 'booking, waitlist, attendance, cancellation, and account-deletion callables',
  'x-internal-demo-fields': <Object?>[
    'synthetic',
    'seedPrefix',
    'scenario',
    'demoOps',
    'demoOpsId',
    'demoOpsCommand',
  ],
  'required': <Object?>[
    'eventId',
    'clubId',
    'uid',
    'status',
    'createdAt',
    'updatedAt',
    'signedUpAt',
    'waitlistedAt',
    'attendedAt',
    'cancelledAt',
    'deletedAt',
    'genderAtSignup',
    'paymentId',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'uid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'status': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'signedUp',
        'waitlisted',
        'attended',
        'cancelled',
        'deleted',
      ],
    },
    'createdAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'updatedAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'signedUpAt': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'description': 'Serialized Firestore Timestamp fixture shape.',
          'x-firestore-type': 'timestamp',
          'additionalProperties': false,
          'required': <Object?>[
            '_seconds',
            '_nanoseconds',
          ],
          'properties': <String, Object?>{
            '_seconds': <String, Object?>{
              'type': 'integer',
            },
            '_nanoseconds': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 999999999,
            },
          },
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'waitlistedAt': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'description': 'Serialized Firestore Timestamp fixture shape.',
          'x-firestore-type': 'timestamp',
          'additionalProperties': false,
          'required': <Object?>[
            '_seconds',
            '_nanoseconds',
          ],
          'properties': <String, Object?>{
            '_seconds': <String, Object?>{
              'type': 'integer',
            },
            '_nanoseconds': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 999999999,
            },
          },
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'attendedAt': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'description': 'Serialized Firestore Timestamp fixture shape.',
          'x-firestore-type': 'timestamp',
          'additionalProperties': false,
          'required': <Object?>[
            '_seconds',
            '_nanoseconds',
          ],
          'properties': <String, Object?>{
            '_seconds': <String, Object?>{
              'type': 'integer',
            },
            '_nanoseconds': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 999999999,
            },
          },
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'cancelledAt': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'description': 'Serialized Firestore Timestamp fixture shape.',
          'x-firestore-type': 'timestamp',
          'additionalProperties': false,
          'required': <Object?>[
            '_seconds',
            '_nanoseconds',
          ],
          'properties': <String, Object?>{
            '_seconds': <String, Object?>{
              'type': 'integer',
            },
            '_nanoseconds': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 999999999,
            },
          },
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'deletedAt': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'description': 'Serialized Firestore Timestamp fixture shape.',
          'x-firestore-type': 'timestamp',
          'additionalProperties': false,
          'required': <Object?>[
            '_seconds',
            '_nanoseconds',
          ],
          'properties': <String, Object?>{
            '_seconds': <String, Object?>{
              'type': 'integer',
            },
            '_nanoseconds': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 999999999,
            },
          },
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'genderAtSignup': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'man',
            'woman',
            'nonBinary',
            'other',
          ],
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'cohortAtSignup': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'minLength': 1,
      'maxLength': 120,
    },
    'paymentId': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'minLength': 1,
      'maxLength': 180,
    },
    'synthetic': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo seed marker used for cleanup and diagnostics.',
    },
    'seedPrefix': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed prefix used for cleanup and diagnostics.',
    },
    'scenario': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed scenario name used for cleanup and diagnostics.',
    },
    'demoOps': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo-operations marker used for cleanup and diagnostics.',
    },
    'demoOpsId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'description': 'Internal demo-operations id used for cleanup and diagnostics.',
    },
    'demoOpsCommand': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'description': 'Internal demo-operations command name used for cleanup and diagnostics.',
    },
  },
};

const schemaEventSuccessPlanDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/event_success_plans.schema.json',
  'title': 'EventSuccessPlanDocument',
  'description': 'Host-owned live event-success setup stored at eventSuccessPlans/{eventId}. The event id is the document id and is also stored for cheap validation and reads.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'eventSuccessPlans',
  'x-firestore-path': 'eventSuccessPlans/{eventId}',
  'x-document-id-field': 'id',
  'x-owner': 'club host direct write; event participants read',
  'x-internal-demo-fields': <Object?>[
    'synthetic',
    'seedPrefix',
    'scenario',
    'demoOps',
    'demoOpsId',
    'demoOpsCommand',
  ],
  'required': <Object?>[
    'eventId',
    'clubId',
    'playbookId',
    'selectedModuleIds',
    'targetAttendeeCount',
    'hostGoal',
    'wingmanRequestsEnabled',
    'contextualOpenersEnabled',
    'activeStepIndex',
    'status',
    'createdAt',
    'updatedAt',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'playbookId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
    },
    'selectedModuleIds': <String, Object?>{
      'type': 'array',
      'maxItems': 24,
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
        'maxLength': 120,
      },
    },
    'targetAttendeeCount': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 1000,
    },
    'structureConfig': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'unitKind',
        'unitSize',
        'revealCountdownSeconds',
      ],
      'properties': <String, Object?>{
        'unitKind': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'wholeGroup',
            'pods',
            'pairs',
            'teams',
            'tables',
          ],
        },
        'unitSize': <String, Object?>{
          'type': 'integer',
          'minimum': 1,
          'maximum': 1000,
        },
        'unitCount': <String, Object?>{
          'type': <Object?>[
            'integer',
            'null',
          ],
          'minimum': 1,
          'maximum': 200,
        },
        'rotationIntervalMinutes': <String, Object?>{
          'type': <Object?>[
            'integer',
            'null',
          ],
          'minimum': 5,
          'maximum': 180,
        },
        'revealCountdownSeconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 60,
        },
      },
    },
    'hostGoal': <String, Object?>{
      'type': 'string',
      'maxLength': 300,
    },
    'wingmanRequestsEnabled': <String, Object?>{
      'type': 'boolean',
    },
    'contextualOpenersEnabled': <String, Object?>{
      'type': 'boolean',
    },
    'compatibilityAffectsRanking': <String, Object?>{
      'type': 'boolean',
    },
    'questionnaireConfig': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'templateId',
      ],
      'properties': <String, Object?>{
        'templateId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 120,
        },
        'customTitle': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 80,
        },
        'customQuestions': <String, Object?>{
          'type': 'array',
          'maxItems': 8,
          'items': <String, Object?>{
            'type': 'object',
            'additionalProperties': false,
            'required': <Object?>[
              'id',
              'prompt',
              'options',
            ],
            'properties': <String, Object?>{
              'id': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 120,
              },
              'prompt': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 140,
              },
              'options': <String, Object?>{
                'type': 'array',
                'minItems': 2,
                'maxItems': 5,
                'items': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'id',
                    'label',
                  ],
                  'properties': <String, Object?>{
                    'id': <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 120,
                    },
                    'label': <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 80,
                    },
                  },
                },
              },
            },
          },
        },
      },
    },
    'activeStepIndex': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 100,
    },
    'status': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'setup',
        'live',
        'complete',
      ],
    },
    'revealStatus': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'idle',
        'countingDown',
        'revealed',
      ],
    },
    'activeRevealRoundIndex': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 100,
    },
    'revealStartedAt': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'description': 'Serialized Firestore Timestamp fixture shape.',
          'x-firestore-type': 'timestamp',
          'additionalProperties': false,
          'required': <Object?>[
            '_seconds',
            '_nanoseconds',
          ],
          'properties': <String, Object?>{
            '_seconds': <String, Object?>{
              'type': 'integer',
            },
            '_nanoseconds': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 999999999,
            },
          },
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'attendeePrompt': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 300,
    },
    'createdAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'updatedAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'frozenAt': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'description': 'Serialized Firestore Timestamp fixture shape.',
          'x-firestore-type': 'timestamp',
          'additionalProperties': false,
          'required': <Object?>[
            '_seconds',
            '_nanoseconds',
          ],
          'properties': <String, Object?>{
            '_seconds': <String, Object?>{
              'type': 'integer',
            },
            '_nanoseconds': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 999999999,
            },
          },
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'completedAt': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'description': 'Serialized Firestore Timestamp fixture shape.',
          'x-firestore-type': 'timestamp',
          'additionalProperties': false,
          'required': <Object?>[
            '_seconds',
            '_nanoseconds',
          ],
          'properties': <String, Object?>{
            '_seconds': <String, Object?>{
              'type': 'integer',
            },
            '_nanoseconds': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 999999999,
            },
          },
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'synthetic': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo seed marker used for cleanup and diagnostics.',
    },
    'seedPrefix': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed prefix used for cleanup and diagnostics.',
    },
    'scenario': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed scenario name used for cleanup and diagnostics.',
    },
    'demoOps': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo-operations marker used for cleanup and diagnostics.',
    },
    'demoOpsId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'description': 'Internal demo-operations id used for cleanup and diagnostics.',
    },
    'demoOpsCommand': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'description': 'Internal demo-operations command name used for cleanup and diagnostics.',
    },
  },
};

const schemaEventSuccessFeedbackDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/event_success_feedback.schema.json',
  'title': 'EventSuccessFeedbackDocument',
  'description': 'Attendee-owned decomposed post-event feedback stored at eventSuccessFeedback/{eventId_uid}. Raw notes and safety concerns are private to the attendee and backend safety/coaching pipelines.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'eventSuccessFeedback',
  'x-firestore-path': 'eventSuccessFeedback/{feedbackId}',
  'x-document-id-field': 'id',
  'x-owner': 'attendee direct write after attended event; attendee read; backend aggregate',
  'x-internal-demo-fields': <Object?>[
    'synthetic',
    'seedPrefix',
    'scenario',
    'demoOps',
    'demoOpsId',
    'demoOpsCommand',
  ],
  'required': <Object?>[
    'eventId',
    'clubId',
    'uid',
    'welcomeRating',
    'structureRating',
    'metNewPeopleCount',
    'safetyConcern',
    'createdAt',
    'updatedAt',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'uid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'welcomeRating': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 5,
    },
    'structureRating': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 5,
    },
    'metNewPeopleCount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 100,
    },
    'safetyConcern': <String, Object?>{
      'type': 'boolean',
    },
    'privateNote': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 500,
    },
    'createdAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'updatedAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'synthetic': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo seed marker used for cleanup and diagnostics.',
    },
    'seedPrefix': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed prefix used for cleanup and diagnostics.',
    },
    'scenario': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed scenario name used for cleanup and diagnostics.',
    },
    'demoOps': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo-operations marker used for cleanup and diagnostics.',
    },
    'demoOpsId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'description': 'Internal demo-operations id used for cleanup and diagnostics.',
    },
    'demoOpsCommand': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'description': 'Internal demo-operations command name used for cleanup and diagnostics.',
    },
  },
};

const schemaEventSuccessPreferenceDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/event_success_preferences.schema.json',
  'title': 'EventSuccessPreferenceDocument',
  'description': 'Attendee-owned opt-out preferences for live event guidance stored at eventSuccessPreferences/{eventId_uid}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'eventSuccessPreferences',
  'x-firestore-path': 'eventSuccessPreferences/{preferenceId}',
  'x-document-id-field': 'id',
  'x-owner': 'attendee direct write while signed up or attended; host read for assignment generation context',
  'x-internal-demo-fields': <Object?>[
    'synthetic',
    'seedPrefix',
    'scenario',
    'demoOps',
    'demoOpsId',
    'demoOpsCommand',
  ],
  'required': <Object?>[
    'eventId',
    'clubId',
    'uid',
    'microPodsOptedOut',
    'guidedRotationsOptedOut',
    'createdAt',
    'updatedAt',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'uid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'microPodsOptedOut': <String, Object?>{
      'type': 'boolean',
    },
    'guidedRotationsOptedOut': <String, Object?>{
      'type': 'boolean',
    },
    'createdAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'updatedAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'synthetic': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo seed marker used for cleanup and diagnostics.',
    },
    'seedPrefix': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed prefix used for cleanup and diagnostics.',
    },
    'scenario': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed scenario name used for cleanup and diagnostics.',
    },
    'demoOps': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo-operations marker used for cleanup and diagnostics.',
    },
    'demoOpsId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'description': 'Internal demo-operations id used for cleanup and diagnostics.',
    },
    'demoOpsCommand': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'description': 'Internal demo-operations command name used for cleanup and diagnostics.',
    },
  },
};

const schemaEventSuccessCompatibilityResponseDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/event_success_compatibility_responses.schema.json',
  'title': 'EventSuccessCompatibilityResponseDocument',
  'description': 'Attendee-owned compatibility questionnaire answers stored at eventSuccessCompatibilityResponses/{eventId_uid}. Hosts cannot read individual answers.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'eventSuccessCompatibilityResponses',
  'x-firestore-path': 'eventSuccessCompatibilityResponses/{responseId}',
  'x-document-id-field': 'id',
  'x-owner': 'attendee direct write while signed up or attended; backend read for opted-in assignment generation',
  'x-internal-demo-fields': <Object?>[
    'synthetic',
    'seedPrefix',
    'scenario',
    'demoOps',
    'demoOpsId',
    'demoOpsCommand',
  ],
  'required': <Object?>[
    'eventId',
    'clubId',
    'uid',
    'answerIds',
    'createdAt',
    'updatedAt',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'uid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'answerIds': <String, Object?>{
      'type': 'array',
      'minItems': 1,
      'maxItems': 8,
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
        'maxLength': 120,
      },
    },
    'createdAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'updatedAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'synthetic': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo seed marker used for cleanup and diagnostics.',
    },
    'seedPrefix': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed prefix used for cleanup and diagnostics.',
    },
    'scenario': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed scenario name used for cleanup and diagnostics.',
    },
    'demoOps': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo-operations marker used for cleanup and diagnostics.',
    },
    'demoOpsId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'description': 'Internal demo-operations id used for cleanup and diagnostics.',
    },
    'demoOpsCommand': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'description': 'Internal demo-operations command name used for cleanup and diagnostics.',
    },
  },
};

const schemaEventSuccessWingmanRequestDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/event_success_wingman_requests.schema.json',
  'title': 'EventSuccessWingmanRequestDocument',
  'description': 'Explicit attendee request for host-visible introduction help stored at eventSuccessWingmanRequests/{eventId_uid}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'eventSuccessWingmanRequests',
  'x-firestore-path': 'eventSuccessWingmanRequests/{requestId}',
  'x-document-id-field': 'id',
  'x-owner': 'attendee direct write after attended event; host read only while active and consented',
  'x-internal-demo-fields': <Object?>[
    'synthetic',
    'seedPrefix',
    'scenario',
    'demoOps',
    'demoOpsId',
    'demoOpsCommand',
  ],
  'required': <Object?>[
    'eventId',
    'clubId',
    'requesterUid',
    'targetUid',
    'status',
    'hostVisibleConsent',
    'createdAt',
    'updatedAt',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'requesterUid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'targetUid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'status': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'active',
        'withdrawn',
      ],
    },
    'hostVisibleConsent': <String, Object?>{
      'type': 'boolean',
      'const': true,
    },
    'note': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 240,
    },
    'createdAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'updatedAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'synthetic': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo seed marker used for cleanup and diagnostics.',
    },
    'seedPrefix': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed prefix used for cleanup and diagnostics.',
    },
    'scenario': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed scenario name used for cleanup and diagnostics.',
    },
    'demoOps': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo-operations marker used for cleanup and diagnostics.',
    },
    'demoOpsId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'description': 'Internal demo-operations id used for cleanup and diagnostics.',
    },
    'demoOpsCommand': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'description': 'Internal demo-operations command name used for cleanup and diagnostics.',
    },
  },
};

const schemaEventSuccessArrivalMissionDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/event_success_arrival_missions.schema.json',
  'title': 'EventSuccessArrivalMissionDocument',
  'description': 'Server-owned First Hello arrival mission stored at eventSuccessArrivalMissions/{eventId_uid}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'eventSuccessArrivalMissions',
  'x-firestore-path': 'eventSuccessArrivalMissions/{missionId}',
  'x-document-id-field': 'id',
  'x-owner': 'server-owned; attendee read only for their own mission',
  'x-internal-demo-fields': <Object?>[
    'synthetic',
    'seedPrefix',
    'scenario',
    'demoOps',
    'demoOpsId',
    'demoOpsCommand',
  ],
  'required': <Object?>[
    'eventId',
    'clubId',
    'observerUid',
    'targetUid',
    'targetDisplayName',
    'targetContext',
    'question',
    'answerOptions',
    'status',
    'createdAt',
    'updatedAt',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'observerUid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'targetUid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'targetDisplayName': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
    },
    'targetContext': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 160,
    },
    'question': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 160,
    },
    'answerOptions': <String, Object?>{
      'type': 'array',
      'minItems': 2,
      'maxItems': 4,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'id',
          'label',
        ],
        'properties': <String, Object?>{
          'id': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 64,
          },
          'label': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 80,
          },
        },
      },
    },
    'status': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'active',
        'completed',
        'skipped',
      ],
    },
    'selectedAnswerId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 64,
    },
    'createdAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'updatedAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'completedAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'synthetic': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo seed marker used for cleanup and diagnostics.',
    },
    'seedPrefix': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed prefix used for cleanup and diagnostics.',
    },
    'scenario': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed scenario name used for cleanup and diagnostics.',
    },
    'demoOps': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo-operations marker used for cleanup and diagnostics.',
    },
    'demoOpsId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'description': 'Internal demo-operations id used for cleanup and diagnostics.',
    },
    'demoOpsCommand': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'description': 'Internal demo-operations command name used for cleanup and diagnostics.',
    },
  },
};

const schemaEventSuccessAssignmentDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/event_success_assignments.schema.json',
  'title': 'EventSuccessAssignmentDocument',
  'description': 'Server-owned live guidance assignment stored at eventSuccessAssignments/{eventId_moduleId_uid}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'eventSuccessAssignments',
  'x-firestore-path': 'eventSuccessAssignments/{assignmentId}',
  'x-document-id-field': 'id',
  'x-owner': 'event-success assignment callables',
  'x-internal-demo-fields': <Object?>[
    'synthetic',
    'seedPrefix',
    'scenario',
    'demoOps',
    'demoOpsId',
    'demoOpsCommand',
  ],
  'required': <Object?>[
    'eventId',
    'clubId',
    'uid',
    'moduleId',
    'label',
    'displayTitle',
    'peerUids',
    'source',
    'createdAt',
    'updatedAt',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'uid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'moduleId': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'micro_pods',
        'guided_rotations',
      ],
    },
    'label': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
    },
    'displayTitle': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
    },
    'displaySubtitle': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 240,
    },
    'peerUids': <String, Object?>{
      'type': 'array',
      'maxItems': 20,
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
        'maxLength': 180,
      },
    },
    'rotationSlots': <String, Object?>{
      'type': 'array',
      'maxItems': 24,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'roundIndex',
          'label',
          'startsAt',
          'endsAt',
          'peerUid',
          'compatibility',
        ],
        'properties': <String, Object?>{
          'roundIndex': <String, Object?>{
            'type': 'integer',
            'minimum': 0,
            'maximum': 100,
          },
          'label': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 80,
          },
          'startsAt': <String, Object?>{
            'type': 'object',
            'description': 'Serialized Firestore Timestamp fixture shape.',
            'x-firestore-type': 'timestamp',
            'additionalProperties': false,
            'required': <Object?>[
              '_seconds',
              '_nanoseconds',
            ],
            'properties': <String, Object?>{
              '_seconds': <String, Object?>{
                'type': 'integer',
              },
              '_nanoseconds': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 999999999,
              },
            },
          },
          'endsAt': <String, Object?>{
            'type': 'object',
            'description': 'Serialized Firestore Timestamp fixture shape.',
            'x-firestore-type': 'timestamp',
            'additionalProperties': false,
            'required': <Object?>[
              '_seconds',
              '_nanoseconds',
            ],
            'properties': <String, Object?>{
              '_seconds': <String, Object?>{
                'type': 'integer',
              },
              '_nanoseconds': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 999999999,
              },
            },
          },
          'peerUid': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 180,
          },
          'compatibility': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'mutual_interest',
              'one_way_interest',
              'questionnaire_match',
              'social',
              'host_override',
            ],
          },
        },
      },
    },
    'source': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'server_v1',
        'host_override_v1',
        'server',
      ],
    },
    'createdAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'updatedAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'synthetic': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo seed marker used for cleanup and diagnostics.',
    },
    'seedPrefix': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed prefix used for cleanup and diagnostics.',
    },
    'scenario': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed scenario name used for cleanup and diagnostics.',
    },
    'demoOps': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo-operations marker used for cleanup and diagnostics.',
    },
    'demoOpsId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'description': 'Internal demo-operations id used for cleanup and diagnostics.',
    },
    'demoOpsCommand': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'description': 'Internal demo-operations command name used for cleanup and diagnostics.',
    },
  },
};

const schemaEventSuccessScorecardDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/event_success_scorecards.schema.json',
  'title': 'EventSuccessScorecardDocument',
  'description': 'Server-owned aggregate event coaching metrics stored at eventSuccessScorecards/{eventId}. Raw attendee feedback remains private.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'eventSuccessScorecards',
  'x-firestore-path': 'eventSuccessScorecards/{eventId}',
  'x-document-id-field': 'id',
  'x-owner': 'onEventSuccessFeedbackWritten trigger',
  'x-internal-demo-fields': <Object?>[
    'synthetic',
    'seedPrefix',
    'scenario',
    'demoOps',
    'demoOpsId',
    'demoOpsCommand',
  ],
  'required': <Object?>[
    'eventId',
    'clubId',
    'bookedCount',
    'checkedInCount',
    'feedbackCount',
    'attendeesWhoMetTwoPlusPeople',
    'mutualMatchCount',
    'chatStartedCount',
    'averageWelcomeRating',
    'averageStructureRating',
    'safetyIncidentCount',
    'updatedAt',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'bookedCount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
    'checkedInCount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
    'feedbackCount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
    'attendeesWhoMetTwoPlusPeople': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
    'mutualMatchCount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
    'chatStartedCount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
    'averageWelcomeRating': <String, Object?>{
      'type': 'number',
      'minimum': 0,
      'maximum': 5,
    },
    'averageStructureRating': <String, Object?>{
      'type': 'number',
      'minimum': 0,
      'maximum': 5,
    },
    'safetyIncidentCount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
    'updatedAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'synthetic': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo seed marker used for cleanup and diagnostics.',
    },
    'seedPrefix': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed prefix used for cleanup and diagnostics.',
    },
    'scenario': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed scenario name used for cleanup and diagnostics.',
    },
    'demoOps': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo-operations marker used for cleanup and diagnostics.',
    },
    'demoOpsId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'description': 'Internal demo-operations id used for cleanup and diagnostics.',
    },
    'demoOpsCommand': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'description': 'Internal demo-operations command name used for cleanup and diagnostics.',
    },
  },
};

const schemaEventSafetyReportDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/event_safety_reports.schema.json',
  'title': 'EventSafetyReportDocument',
  'description': 'Catch-private safety review item materialized from event feedback concerns.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'eventSafetyReports',
  'x-firestore-path': 'eventSafetyReports/{reportId}',
  'x-document-id-field': 'id',
  'x-owner': 'onEventSuccessFeedbackWritten trigger',
  'required': <Object?>[
    'eventId',
    'clubId',
    'reporterUserId',
    'feedbackId',
    'source',
    'status',
    'createdAt',
    'updatedAt',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'reporterUserId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'feedbackId': <String, Object?>{
      'type': 'string',
      'minLength': 3,
      'maxLength': 256,
    },
    'source': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'event_success_feedback',
      ],
    },
    'status': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'open',
        'reviewed',
        'dismissed',
      ],
    },
    'note': <String, Object?>{
      'type': 'string',
      'maxLength': 500,
    },
    'createdAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'updatedAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
  },
};

const schemaClubScheduleLockDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/club_schedule_locks.schema.json',
  'title': 'ClubScheduleLockDocument',
  'description': 'Server-owned time-slot claim stored at clubScheduleLocks/{clubId_slot}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'clubScheduleLocks',
  'x-firestore-path': 'clubScheduleLocks/{lockId}',
  'x-document-id-field': 'lockId',
  'x-owner': 'event schedule conflict callables',
  'x-internal-demo-fields': <Object?>[
    'synthetic',
    'seedPrefix',
    'scenario',
    'demoOps',
    'demoOpsId',
    'demoOpsCommand',
  ],
  'required': <Object?>[
    'ownerType',
    'ownerId',
    'slot',
    'eventId',
    'clubId',
    'startTimeMillis',
    'endTimeMillis',
  ],
  'properties': <String, Object?>{
    'ownerType': <String, Object?>{
      'type': 'string',
      'const': 'club',
    },
    'ownerId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'slot': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'startTimeMillis': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
    'endTimeMillis': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
    'synthetic': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo seed marker used for cleanup and diagnostics.',
    },
    'seedPrefix': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed prefix used for cleanup and diagnostics.',
    },
    'scenario': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed scenario name used for cleanup and diagnostics.',
    },
    'demoOps': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo-operations marker used for cleanup and diagnostics.',
    },
    'demoOpsId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'description': 'Internal demo-operations id used for cleanup and diagnostics.',
    },
    'demoOpsCommand': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'description': 'Internal demo-operations command name used for cleanup and diagnostics.',
    },
  },
};

const schemaUserEventScheduleLockDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/user_event_schedule_locks.schema.json',
  'title': 'UserEventScheduleLockDocument',
  'description': 'Server-owned time-slot claim stored at userEventScheduleLocks/{uid_slot}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'userEventScheduleLocks',
  'x-firestore-path': 'userEventScheduleLocks/{lockId}',
  'x-document-id-field': 'lockId',
  'x-owner': 'event signup and waitlist callables',
  'x-internal-demo-fields': <Object?>[
    'synthetic',
    'seedPrefix',
    'scenario',
    'demoOps',
    'demoOpsId',
    'demoOpsCommand',
  ],
  'required': <Object?>[
    'ownerType',
    'ownerId',
    'slot',
    'eventId',
    'clubId',
    'uid',
    'startTimeMillis',
    'endTimeMillis',
  ],
  'properties': <String, Object?>{
    'ownerType': <String, Object?>{
      'type': 'string',
      'const': 'user',
    },
    'ownerId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'slot': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'uid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'startTimeMillis': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
    'endTimeMillis': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
    'synthetic': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo seed marker used for cleanup and diagnostics.',
    },
    'seedPrefix': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed prefix used for cleanup and diagnostics.',
    },
    'scenario': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed scenario name used for cleanup and diagnostics.',
    },
    'demoOps': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo-operations marker used for cleanup and diagnostics.',
    },
    'demoOpsId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'description': 'Internal demo-operations id used for cleanup and diagnostics.',
    },
    'demoOpsCommand': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'description': 'Internal demo-operations command name used for cleanup and diagnostics.',
    },
  },
};

const schemaSavedEventDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/saved_events.schema.json',
  'title': 'SavedEventDocument',
  'description': 'Canonical saved-event edge stored at savedEvents/{savedEventId}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'savedEvents',
  'x-firestore-path': 'savedEvents/{savedEventId}',
  'x-document-id-field': 'id',
  'x-owner': 'authenticated owner direct create/delete',
  'x-internal-demo-fields': <Object?>[
    'synthetic',
    'seedPrefix',
    'scenario',
    'demoOps',
    'demoOpsId',
    'demoOpsCommand',
  ],
  'required': <Object?>[
    'uid',
    'eventId',
    'savedAt',
  ],
  'properties': <String, Object?>{
    'uid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'savedAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'synthetic': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo seed marker used for cleanup and diagnostics.',
    },
    'seedPrefix': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed prefix used for cleanup and diagnostics.',
    },
    'scenario': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed scenario name used for cleanup and diagnostics.',
    },
    'demoOps': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo-operations marker used for cleanup and diagnostics.',
    },
    'demoOpsId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'description': 'Internal demo-operations id used for cleanup and diagnostics.',
    },
    'demoOpsCommand': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'description': 'Internal demo-operations command name used for cleanup and diagnostics.',
    },
  },
};

const schemaPaymentDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/payments.schema.json',
  'title': 'PaymentDocument',
  'description': 'Canonical payment record stored at payments/{paymentId}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'payments',
  'x-firestore-path': 'payments/{paymentId}',
  'x-document-id-field': 'id',
  'x-owner': 'payments callables',
  'x-internal-demo-fields': <Object?>[
    'synthetic',
    'seedPrefix',
    'scenario',
    'demoOps',
    'demoOpsId',
    'demoOpsCommand',
  ],
  'required': <Object?>[
    'userId',
    'orderId',
    'paymentId',
    'eventId',
    'amount',
    'currency',
    'status',
    'signUpFailed',
    'createdAt',
  ],
  'properties': <String, Object?>{
    'userId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'orderId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 240,
    },
    'paymentId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 240,
    },
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'amount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 100000000,
    },
    'currency': <String, Object?>{
      'type': 'string',
      'minLength': 3,
      'maxLength': 3,
    },
    'status': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'pending',
        'completed',
        'failed',
        'refunded',
      ],
    },
    'signUpFailed': <String, Object?>{
      'type': 'boolean',
    },
    'createdAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'synthetic': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo seed marker used for cleanup and diagnostics.',
    },
    'seedPrefix': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed prefix used for cleanup and diagnostics.',
    },
    'scenario': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed scenario name used for cleanup and diagnostics.',
    },
    'demoOps': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo-operations marker used for cleanup and diagnostics.',
    },
    'demoOpsId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'description': 'Internal demo-operations id used for cleanup and diagnostics.',
    },
    'demoOpsCommand': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'description': 'Internal demo-operations command name used for cleanup and diagnostics.',
    },
  },
};

const schemaSwipeDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/swipes.schema.json',
  'title': 'SwipeDocument',
  'description': 'Current storage contract for contextual profile decisions stored at swipes/{userId}/outgoing/{targetId}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'swipes',
  'x-firestore-path': 'swipes/{userId}/outgoing/{targetId}',
  'x-document-id-field': 'targetId',
  'x-owner': 'authenticated swiper direct create; matching trigger consumes likes',
  'x-logical-name': 'profileDecision',
  'x-migration-phase': 'observe',
  'x-internal-demo-fields': <Object?>[
    'synthetic',
    'seedPrefix',
    'scenario',
    'demoOps',
    'demoOpsId',
    'demoOpsCommand',
  ],
  'required': <Object?>[
    'swiperId',
    'targetId',
    'eventId',
    'direction',
    'createdAt',
  ],
  'properties': <String, Object?>{
    'swiperId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'targetId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'direction': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'like',
        'pass',
      ],
    },
    'reactionTargetId': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'minLength': 1,
      'maxLength': 80,
    },
    'reactionTargetType': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'enum': <Object?>[
        'heroPhoto',
        'photo',
        'profilePrompt',
        'compatibility',
        'running',
        'details',
        'lifestyle',
        null,
      ],
    },
    'reactionTargetLabel': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 80,
    },
    'reactionTargetPreview': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 240,
    },
    'comment': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 240,
    },
    'createdAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'synthetic': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo seed marker used for cleanup and diagnostics.',
    },
    'seedPrefix': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed prefix used for cleanup and diagnostics.',
    },
    'scenario': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed scenario name used for cleanup and diagnostics.',
    },
    'demoOps': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo-operations marker used for cleanup and diagnostics.',
    },
    'demoOpsId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'description': 'Internal demo-operations id used for cleanup and diagnostics.',
    },
    'demoOpsCommand': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'description': 'Internal demo-operations command name used for cleanup and diagnostics.',
    },
  },
};

const schemaMatchDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/matches.schema.json',
  'title': 'MatchDocument',
  'description': 'Canonical match document stored at matches/{matchId}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'matches',
  'x-firestore-path': 'matches/{matchId}',
  'x-document-id-field': 'id',
  'x-owner': 'matching triggers own lifecycle; participants may reset only their unread count',
  'x-internal-demo-fields': <Object?>[
    'synthetic',
    'seedPrefix',
    'scenario',
    'demoOps',
    'demoOpsId',
    'demoOpsCommand',
  ],
  'required': <Object?>[
    'user1Id',
    'user2Id',
    'eventIds',
    'createdAt',
    'lastMessageAt',
    'lastMessagePreview',
    'lastMessageSenderId',
    'unreadCounts',
    'status',
    'blockedBy',
    'blockedAt',
    'participantIds',
  ],
  'properties': <String, Object?>{
    'user1Id': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'user2Id': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'eventIds': <String, Object?>{
      'type': 'array',
      'minItems': 1,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
        'maxLength': 180,
      },
    },
    'createdAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'lastMessageAt': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'description': 'Serialized Firestore Timestamp fixture shape.',
          'x-firestore-type': 'timestamp',
          'additionalProperties': false,
          'required': <Object?>[
            '_seconds',
            '_nanoseconds',
          ],
          'properties': <String, Object?>{
            '_seconds': <String, Object?>{
              'type': 'integer',
            },
            '_nanoseconds': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 999999999,
            },
          },
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'lastMessagePreview': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 300,
    },
    'lastMessageSenderId': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'minLength': 1,
      'maxLength': 180,
    },
    'unreadCounts': <String, Object?>{
      'type': 'object',
      'additionalProperties': <String, Object?>{
        'type': 'integer',
        'minimum': 0,
      },
    },
    'status': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'active',
        'blocked',
      ],
    },
    'blockedBy': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'minLength': 1,
      'maxLength': 180,
    },
    'blockedAt': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'description': 'Serialized Firestore Timestamp fixture shape.',
          'x-firestore-type': 'timestamp',
          'additionalProperties': false,
          'required': <Object?>[
            '_seconds',
            '_nanoseconds',
          ],
          'properties': <String, Object?>{
            '_seconds': <String, Object?>{
              'type': 'integer',
            },
            '_nanoseconds': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 999999999,
            },
          },
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'participantIds': <String, Object?>{
      'type': 'array',
      'minItems': 2,
      'maxItems': 2,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
        'maxLength': 180,
      },
    },
    'synthetic': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo seed marker used for cleanup and diagnostics.',
    },
    'seedPrefix': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed prefix used for cleanup and diagnostics.',
    },
    'scenario': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed scenario name used for cleanup and diagnostics.',
    },
    'demoOps': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo-operations marker used for cleanup and diagnostics.',
    },
    'demoOpsId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'description': 'Internal demo-operations id used for cleanup and diagnostics.',
    },
    'demoOpsCommand': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'description': 'Internal demo-operations command name used for cleanup and diagnostics.',
    },
  },
};

const schemaChatMessageDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/chat_messages.schema.json',
  'title': 'ChatMessageDocument',
  'description': 'Canonical chat message document stored at matches/{matchId}/messages/{messageId}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'chat_messages',
  'x-firestore-path': 'matches/{matchId}/messages/{messageId}',
  'x-document-id-field': 'id',
  'x-owner': 'active match participant creates message; triggers own moderation and match preview projections',
  'x-internal-demo-fields': <Object?>[
    'synthetic',
    'seedPrefix',
    'scenario',
    'demoOps',
    'demoOpsId',
    'demoOpsCommand',
  ],
  'required': <Object?>[
    'senderId',
    'text',
  ],
  'anyOf': <Object?>[
    <String, Object?>{
      'properties': <String, Object?>{
        'text': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 2000,
        },
      },
    },
    <String, Object?>{
      'required': <Object?>[
        'imageUrl',
      ],
      'properties': <String, Object?>{
        'imageUrl': <String, Object?>{
          'type': 'string',
          'format': 'uri',
          'maxLength': 2048,
        },
      },
    },
  ],
  'properties': <String, Object?>{
    'senderId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'text': <String, Object?>{
      'type': 'string',
      'maxLength': 2000,
    },
    'imageUrl': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'string',
          'format': 'uri',
          'maxLength': 2048,
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'sentAt': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'description': 'Serialized Firestore Timestamp fixture shape.',
          'x-firestore-type': 'timestamp',
          'additionalProperties': false,
          'required': <Object?>[
            '_seconds',
            '_nanoseconds',
          ],
          'properties': <String, Object?>{
            '_seconds': <String, Object?>{
              'type': 'integer',
            },
            '_nanoseconds': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 999999999,
            },
          },
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'synthetic': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo seed marker used for cleanup and diagnostics.',
    },
    'seedPrefix': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed prefix used for cleanup and diagnostics.',
    },
    'scenario': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed scenario name used for cleanup and diagnostics.',
    },
    'demoOps': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo-operations marker used for cleanup and diagnostics.',
    },
    'demoOpsId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'description': 'Internal demo-operations id used for cleanup and diagnostics.',
    },
    'demoOpsCommand': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'description': 'Internal demo-operations command name used for cleanup and diagnostics.',
    },
  },
};

const schemaActivityNotificationDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/activity_notifications.schema.json',
  'title': 'ActivityNotificationDocument',
  'description': 'Canonical durable activity notification stored at notifications/{uid}/items/{notificationId}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'activity_notifications',
  'x-firestore-path': 'notifications/{uid}/items/{notificationId}',
  'x-document-id-field': 'id',
  'x-owner': 'notification fan-out functions and booking callables',
  'x-internal-demo-fields': <Object?>[
    'synthetic',
    'seedPrefix',
    'scenario',
    'demoOps',
    'demoOpsId',
    'demoOpsCommand',
  ],
  'required': <Object?>[
    'uid',
    'type',
    'title',
    'body',
    'createdAt',
  ],
  'properties': <String, Object?>{
    'uid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'type': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'message',
        'match',
        'eventReminder',
        'eventSignup',
        'waitlistPromotion',
        'eventCancelled',
        'eventUpdated',
        'clubUpdate',
      ],
    },
    'title': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 160,
    },
    'body': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 500,
    },
    'createdAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'readAt': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'description': 'Serialized Firestore Timestamp fixture shape.',
          'x-firestore-type': 'timestamp',
          'additionalProperties': false,
          'required': <Object?>[
            '_seconds',
            '_nanoseconds',
          ],
          'properties': <String, Object?>{
            '_seconds': <String, Object?>{
              'type': 'integer',
            },
            '_nanoseconds': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 999999999,
            },
          },
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'matchId': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'minLength': 1,
      'maxLength': 240,
    },
    'eventId': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'minLength': 1,
      'maxLength': 180,
    },
    'clubId': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'minLength': 1,
      'maxLength': 180,
    },
    'actorUid': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'minLength': 1,
      'maxLength': 180,
    },
    'actorName': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 120,
    },
    'synthetic': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo seed marker used for cleanup and diagnostics.',
    },
    'seedPrefix': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed prefix used for cleanup and diagnostics.',
    },
    'scenario': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed scenario name used for cleanup and diagnostics.',
    },
    'demoOps': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo-operations marker used for cleanup and diagnostics.',
    },
    'demoOpsId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'description': 'Internal demo-operations id used for cleanup and diagnostics.',
    },
    'demoOpsCommand': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'description': 'Internal demo-operations command name used for cleanup and diagnostics.',
    },
  },
};

const schemaReviewDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/reviews.schema.json',
  'title': 'ReviewDocument',
  'description': 'Canonical attended-event review stored at reviews/{reviewId}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'reviews',
  'x-firestore-path': 'reviews/{reviewId}',
  'x-document-id-field': 'id',
  'x-owner': 'review mutation callables; aggregate stats are trigger-owned',
  'x-internal-demo-fields': <Object?>[
    'synthetic',
    'seedPrefix',
    'scenario',
    'demoOps',
    'demoOpsId',
    'demoOpsCommand',
  ],
  'required': <Object?>[
    'clubId',
    'reviewerUserId',
    'reviewerName',
    'rating',
    'comment',
    'createdAt',
  ],
  'properties': <String, Object?>{
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'eventId': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'minLength': 1,
      'maxLength': 180,
    },
    'reviewerUserId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'reviewerName': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
    },
    'rating': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 5,
    },
    'comment': <String, Object?>{
      'type': 'string',
      'maxLength': 1000,
    },
    'createdAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'updatedAt': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'description': 'Serialized Firestore Timestamp fixture shape.',
          'x-firestore-type': 'timestamp',
          'additionalProperties': false,
          'required': <Object?>[
            '_seconds',
            '_nanoseconds',
          ],
          'properties': <String, Object?>{
            '_seconds': <String, Object?>{
              'type': 'integer',
            },
            '_nanoseconds': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 999999999,
            },
          },
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'synthetic': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo seed marker used for cleanup and diagnostics.',
    },
    'seedPrefix': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed prefix used for cleanup and diagnostics.',
    },
    'scenario': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed scenario name used for cleanup and diagnostics.',
    },
    'demoOps': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo-operations marker used for cleanup and diagnostics.',
    },
    'demoOpsId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'description': 'Internal demo-operations id used for cleanup and diagnostics.',
    },
    'demoOpsCommand': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'description': 'Internal demo-operations command name used for cleanup and diagnostics.',
    },
  },
};

const schemaBlockDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/blocks.schema.json',
  'title': 'BlockDocument',
  'description': 'Canonical safety block edge stored at blocks/{blockId}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'blocks',
  'x-firestore-path': 'blocks/{blockId}',
  'x-document-id-field': 'id',
  'x-owner': 'safety callables and block trigger',
  'required': <Object?>[
    'blockerUserId',
    'blockedUserId',
    'createdAt',
    'source',
  ],
  'properties': <String, Object?>{
    'blockerUserId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'blockedUserId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'createdAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'source': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'profile',
        'chat',
        'match',
        'support',
      ],
    },
    'reasonCode': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
    },
  },
};

const schemaReportDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/reports.schema.json',
  'title': 'ReportDocument',
  'description': 'Canonical safety report stored at reports/{reportId}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'reports',
  'x-firestore-path': 'reports/{reportId}',
  'x-document-id-field': 'id',
  'x-owner': 'reportUser callable',
  'required': <Object?>[
    'reporterUserId',
    'targetUserId',
    'createdAt',
    'source',
    'status',
  ],
  'properties': <String, Object?>{
    'reporterUserId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'targetUserId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'createdAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'source': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'profile',
        'chat',
        'match',
        'support',
      ],
    },
    'status': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'open',
        'reviewed',
        'dismissed',
      ],
    },
    'reasonCode': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
    },
    'contextId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'notes': <String, Object?>{
      'type': 'string',
      'maxLength': 1000,
    },
  },
};

const schemaModerationFlagDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/moderation_flags.schema.json',
  'title': 'ModerationFlagDocument',
  'description': 'Canonical moderation ticket stored at moderationFlags/{flagId}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'moderationFlags',
  'x-firestore-path': 'moderationFlags/{flagId}',
  'x-document-id-field': 'id',
  'x-owner': 'moderation triggers',
  'required': <Object?>[
    'targetUserId',
    'flagType',
    'source',
    'status',
    'createdAt',
  ],
  'properties': <String, Object?>{
    'targetUserId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'flagType': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'explicit_photo',
        'banned_text',
        'underage_content',
      ],
    },
    'source': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'profile_photo',
        'club_image',
        'chat_message',
        'user_bio',
        'club_description',
        'review_comment',
      ],
    },
    'status': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'pending',
        'reviewed',
        'dismissed',
      ],
    },
    'createdAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'reviewedAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'contextId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'context': <String, Object?>{
      'type': 'string',
      'maxLength': 1000,
    },
    'safeSearchResults': <String, Object?>{
      'type': 'object',
      'additionalProperties': <String, Object?>{
        'type': 'string',
      },
    },
  },
};

const schemaDeletedUserTombstoneDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/deleted_users.schema.json',
  'title': 'DeletedUserTombstoneDocument',
  'description': 'Server-owned account-deletion tombstone stored at deletedUsers/{uid}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'deletedUsers',
  'x-firestore-path': 'deletedUsers/{uid}',
  'x-document-id-field': 'uid',
  'x-owner': 'requestAccountDeletion callable',
  'required': <Object?>[
    'uid',
    'deletedAt',
  ],
  'properties': <String, Object?>{
    'uid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'deletedAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'retainedFor': <String, Object?>{
      'type': 'array',
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
        'maxLength': 80,
      },
      'uniqueItems': true,
    },
  },
};

const schemaRateLimitDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/rate_limits.schema.json',
  'title': 'RateLimitDocument',
  'description': 'Server-owned callable rate-limit counter stored at rateLimits/{docId}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'rateLimits',
  'x-firestore-path': 'rateLimits/{docId}',
  'x-document-id-field': 'docId',
  'x-owner': 'shared callable rate-limit middleware',
  'required': <Object?>[
    'uid',
    'action',
    'windowKey',
    'count',
    'expiresAt',
  ],
  'properties': <String, Object?>{
    'uid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'action': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
    },
    'windowKey': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
    'count': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
    },
    'expiresAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
  },
};

const schemaFunctionEventReceiptDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/function_event_receipts.schema.json',
  'title': 'FunctionEventReceiptDocument',
  'description': 'Server-owned idempotency receipt stored at functionEventReceipts/{receiptId}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'functionEventReceipts',
  'x-firestore-path': 'functionEventReceipts/{receiptId}',
  'x-document-id-field': 'receiptId',
  'x-owner': 'idempotent Firestore trigger handlers',
  'required': <Object?>[
    'handler',
    'eventId',
    'matchId',
    'messageId',
    'createdAt',
  ],
  'properties': <String, Object?>{
    'handler': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'onMessageCreated',
      ],
    },
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 240,
    },
    'matchId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'messageId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'createdAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
  },
};

const schemaSeedEventManifestDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/seed_events.schema.json',
  'title': 'SeedEventManifestDocument',
  'description': 'Tool-owned synthetic-data manifest stored at seedEvents/{manifestId}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'seedEvents',
  'x-firestore-path': 'seedEvents/{manifestId}',
  'x-document-id-field': 'manifestId',
  'x-owner': 'demo data seeding tooling',
  'x-internal-demo-fields': <Object?>[
    'synthetic',
    'seedPrefix',
    'scenario',
    'demoOps',
    'demoOpsId',
    'demoOpsCommand',
  ],
  'required': <Object?>[
    'seedId',
    'manifestId',
    'generatedAt',
    'anchorUserIds',
    'counts',
    'paths',
  ],
  'properties': <String, Object?>{
    'seedId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'manifestId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'generatedAt': <String, Object?>{
      'type': 'object',
      'description': 'Serialized Firestore Timestamp fixture shape.',
      'x-firestore-type': 'timestamp',
      'additionalProperties': false,
      'required': <Object?>[
        '_seconds',
        '_nanoseconds',
      ],
      'properties': <String, Object?>{
        '_seconds': <String, Object?>{
          'type': 'integer',
        },
        '_nanoseconds': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 999999999,
        },
      },
    },
    'anchorUserIds': <String, Object?>{
      'type': 'array',
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
        'maxLength': 180,
      },
      'uniqueItems': true,
    },
    'counts': <String, Object?>{
      'type': 'object',
      'additionalProperties': <String, Object?>{
        'type': 'integer',
        'minimum': 0,
      },
    },
    'paths': <String, Object?>{
      'type': 'array',
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
        'maxLength': 512,
      },
      'uniqueItems': true,
    },
    'appendMode': <String, Object?>{
      'type': 'boolean',
    },
    'appendedAnchorUserIds': <String, Object?>{
      'type': 'array',
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
        'maxLength': 180,
      },
      'uniqueItems': true,
    },
    'synthetic': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo seed marker used for cleanup and diagnostics.',
    },
    'seedPrefix': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed prefix used for cleanup and diagnostics.',
    },
    'scenario': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'description': 'Internal demo seed scenario name used for cleanup and diagnostics.',
    },
    'demoOps': <String, Object?>{
      'type': 'boolean',
      'description': 'Internal demo-operations marker used for cleanup and diagnostics.',
    },
    'demoOpsId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'description': 'Internal demo-operations id used for cleanup and diagnostics.',
    },
    'demoOpsCommand': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'description': 'Internal demo-operations command name used for cleanup and diagnostics.',
    },
  },
};

const schemaUpdateUserProfileCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/patches/update_user_profile.schema.json',
  'title': 'UpdateUserProfileCallablePayload',
  'description': 'Callable request body for updateUserProfile. Values are normalized before Firestore writes.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'fields',
  ],
  'properties': <String, Object?>{
    'fields': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'minProperties': 1,
      'properties': <String, Object?>{
        'name': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 120,
        },
        'displayName': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 80,
          'pattern': '.*\\S.*',
        },
        'email': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'const': '',
            },
            <String, Object?>{
              'type': 'string',
              'format': 'email',
              'maxLength': 320,
            },
          ],
        },
        'instagramHandle': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 30,
              'pattern': '^[A-Za-z0-9._]{1,30}\$',
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'profilePrompts': <String, Object?>{
          'type': 'array',
          'maxItems': 3,
          'items': <String, Object?>{
            'title': 'ProfilePromptAnswer',
            'description': 'One structured written profile prompt answer stored on users and publicProfiles.',
            'type': 'object',
            'additionalProperties': false,
            'required': <Object?>[
              'promptId',
              'prompt',
              'answer',
            ],
            'properties': <String, Object?>{
              'promptId': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 80,
              },
              'prompt': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 140,
              },
              'answer': <String, Object?>{
                'type': 'string',
                'maxLength': 300,
              },
            },
            'x-catch-catalog': '../catalogs/profile_prompts.json',
          },
        },
        'phoneNumber': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 32,
        },
        'dateOfBirth': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'description': 'Milliseconds since epoch before conversion to Firestore Timestamp.',
        },
        'gender': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'man',
            'woman',
            'nonBinary',
            'other',
          ],
        },
        'profileComplete': <String, Object?>{
          'type': 'boolean',
        },
        'photoUrls': <String, Object?>{
          'type': 'array',
          'maxItems': 6,
          'items': <String, Object?>{
            'type': 'string',
            'format': 'uri',
            'maxLength': 2048,
          },
        },
        'photoThumbnailUrls': <String, Object?>{
          'type': 'array',
          'maxItems': 6,
          'items': <String, Object?>{
            'type': 'string',
            'format': 'uri',
            'maxLength': 2048,
          },
        },
        'photoPrompts': <String, Object?>{
          'type': 'array',
          'maxItems': 6,
          'items': <String, Object?>{
            'title': 'PhotoPromptAnswer',
            'description': 'One optional display prompt selected for a profile photo slot. The caption field is legacy-only and should no longer be written by clients.',
            'type': 'object',
            'additionalProperties': false,
            'required': <Object?>[
              'photoIndex',
              'promptId',
              'prompt',
            ],
            'properties': <String, Object?>{
              'photoIndex': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 5,
              },
              'promptId': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 80,
              },
              'prompt': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 140,
              },
              'caption': <String, Object?>{
                'type': 'string',
                'maxLength': 140,
                'deprecated': true,
                'description': 'Legacy user-entered caption retained for compatibility with older documents.',
              },
            },
            'x-catch-catalog': '../catalogs/photo_prompts.json',
          },
        },
        'profilePhotos': <String, Object?>{
          'type': 'array',
          'maxItems': 6,
          'items': <String, Object?>{
            'type': 'object',
            'additionalProperties': false,
            'required': <Object?>[
              'id',
              'url',
              'thumbnailUrl',
              'storagePath',
              'thumbnailStoragePath',
              'position',
              'createdAt',
              'updatedAt',
            ],
            'properties': <String, Object?>{
              'id': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 80,
                'pattern': '^[A-Za-z0-9_-]+\$',
              },
              'url': <String, Object?>{
                'type': 'string',
                'format': 'uri',
                'maxLength': 2048,
              },
              'thumbnailUrl': <String, Object?>{
                'type': 'string',
                'format': 'uri',
                'maxLength': 2048,
              },
              'storagePath': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 512,
                'pattern': '^[^/\\u0000][^\\u0000]*\$',
              },
              'thumbnailStoragePath': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 512,
                'pattern': '^[^/\\u0000][^\\u0000]*\$',
              },
              'prompt': <String, Object?>{
                'anyOf': <Object?>[
                  <String, Object?>{
                    'title': 'PhotoPromptAnswer',
                    'description': 'One optional display prompt selected for a profile photo slot. The caption field is legacy-only and should no longer be written by clients.',
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'photoIndex',
                      'promptId',
                      'prompt',
                    ],
                    'properties': <String, Object?>{
                      'photoIndex': <String, Object?>{
                        'type': 'integer',
                        'minimum': 0,
                        'maximum': 5,
                      },
                      'promptId': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 80,
                      },
                      'prompt': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 140,
                      },
                      'caption': <String, Object?>{
                        'type': 'string',
                        'maxLength': 140,
                        'deprecated': true,
                        'description': 'Legacy user-entered caption retained for compatibility with older documents.',
                      },
                    },
                    'x-catch-catalog': '../catalogs/photo_prompts.json',
                  },
                  <String, Object?>{
                    'type': 'null',
                  },
                ],
              },
              'moderation': <String, Object?>{
                'type': <Object?>[
                  'object',
                  'null',
                ],
                'additionalProperties': false,
                'required': <Object?>[
                  'status',
                ],
                'properties': <String, Object?>{
                  'status': <String, Object?>{
                    'type': 'string',
                    'enum': <Object?>[
                      'pending',
                      'approved',
                      'rejected',
                    ],
                  },
                  'reason': <String, Object?>{
                    'type': <Object?>[
                      'string',
                      'null',
                    ],
                    'maxLength': 240,
                  },
                  'reviewedAt': <String, Object?>{
                    'type': <Object?>[
                      'integer',
                      'null',
                    ],
                    'minimum': 0,
                  },
                },
              },
              'position': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 11,
              },
              'createdAt': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
              },
              'updatedAt': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
              },
            },
          },
        },
        'city': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'minLength': 1,
          'maxLength': 80,
          'pattern': '^[a-z0-9-]+\$',
        },
        'latitude': <String, Object?>{
          'type': <Object?>[
            'number',
            'null',
          ],
          'minimum': -90,
          'maximum': 90,
        },
        'longitude': <String, Object?>{
          'type': <Object?>[
            'number',
            'null',
          ],
          'minimum': -180,
          'maximum': 180,
        },
        'interestedInGenders': <String, Object?>{
          'type': 'array',
          'minItems': 1,
          'maxItems': 8,
          'uniqueItems': true,
          'items': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'man',
              'woman',
              'nonBinary',
              'other',
            ],
          },
        },
        'minAgePreference': <String, Object?>{
          'type': 'integer',
          'minimum': 18,
          'maximum': 99,
        },
        'maxAgePreference': <String, Object?>{
          'type': 'integer',
          'minimum': 18,
          'maximum': 99,
        },
        'height': <String, Object?>{
          'type': <Object?>[
            'integer',
            'null',
          ],
          'minimum': 120,
          'maximum': 220,
        },
        'occupation': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
        },
        'company': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
        },
        'education': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'enum': <Object?>[
            'highSchool',
            'someCollege',
            'bachelors',
            'masters',
            'phd',
            'tradeSchool',
            'other',
            null,
          ],
        },
        'religion': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'enum': <Object?>[
            'hindu',
            'muslim',
            'christian',
            'sikh',
            'jain',
            'buddhist',
            'other',
            'nonReligious',
            null,
          ],
        },
        'languages': <String, Object?>{
          'type': 'array',
          'maxItems': 20,
          'uniqueItems': true,
          'items': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'english',
              'hindi',
              'marathi',
              'tamil',
              'telugu',
              'kannada',
              'bengali',
              'gujarati',
              'punjabi',
              'malayalam',
              'odia',
              'other',
            ],
          },
        },
        'relationshipGoal': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'enum': <Object?>[
            'relationship',
            'casual',
            'marriage',
            'friendship',
            'unsure',
            null,
          ],
        },
        'drinking': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'enum': <Object?>[
            'never',
            'socially',
            'often',
            null,
          ],
        },
        'smoking': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'enum': <Object?>[
            'never',
            'occasionally',
            'often',
            null,
          ],
        },
        'workout': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'enum': <Object?>[
            'never',
            'sometimes',
            'often',
            'everyday',
            null,
          ],
        },
        'diet': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'enum': <Object?>[
            'omnivore',
            'vegetarian',
            'vegan',
            'jain',
            'other',
            null,
          ],
        },
        'children': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'enum': <Object?>[
            'dontHave',
            'haveWantMore',
            'haveNoMore',
            'wantSomeday',
            'dontWant',
            null,
          ],
        },
        'paceMinSecsPerKm': <String, Object?>{
          'type': 'integer',
          'minimum': 1,
        },
        'paceMaxSecsPerKm': <String, Object?>{
          'type': 'integer',
          'minimum': 1,
        },
        'preferredDistances': <String, Object?>{
          'type': 'array',
          'maxItems': 12,
          'uniqueItems': true,
          'items': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'fiveK',
              'tenK',
              'halfMarathon',
              'marathon',
            ],
          },
        },
        'runningReasons': <String, Object?>{
          'type': 'array',
          'maxItems': 12,
          'uniqueItems': true,
          'items': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'fitness',
              'community',
              'mindfulness',
              'challenge',
              'weightLoss',
              'raceTraining',
              'social',
            ],
          },
        },
        'preferredRunTimes': <String, Object?>{
          'type': 'array',
          'maxItems': 8,
          'uniqueItems': true,
          'items': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'earlyMorning',
              'morning',
              'afternoon',
              'evening',
              'night',
            ],
          },
        },
        'runPreferencesVersion': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
        },
        'prefsNewCatches': <String, Object?>{
          'type': 'boolean',
        },
        'prefsMessages': <String, Object?>{
          'type': 'boolean',
        },
        'prefsEventReminders': <String, Object?>{
          'type': 'boolean',
        },
        'prefsRunStatusUpdates': <String, Object?>{
          'type': 'boolean',
        },
        'prefsClubUpdates': <String, Object?>{
          'type': 'boolean',
        },
        'prefsWeeklyDigest': <String, Object?>{
          'type': 'boolean',
        },
        'prefsShowOnMap': <String, Object?>{
          'type': 'boolean',
        },
      },
    },
  },
  'x-normalization': <Object?>[
    'trim prompt ids and display prompt titles',
    'collapse stacked blank lines in prompt answers and captions',
    'drop empty prompt answers and empty photo captions',
    'convert dateOfBirth millis to Firestore Timestamp',
  ],
  'x-intentionally-excluded-fields': <Object?>[
    'firstName',
    'lastName',
    'fcmToken',
    'deleted',
    'deletedAt',
    'sexualOrientation',
    'bio',
  ],
};

const schemaCreateClubCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/create_club_payload.schema.json',
  'title': 'CreateClubCallablePayload',
  'description': 'Callable payload accepted by createClub.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'name',
    'description',
    'location',
    'area',
  ],
  'properties': <String, Object?>{
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'name': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
    },
    'description': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 2000,
    },
    'location': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'minLength': 1,
      'maxLength': 80,
      'pattern': '^[a-z0-9-]+\$',
    },
    'area': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
    },
    'imageUrl': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 320,
    },
    'profileImageUrl': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 320,
    },
    'instagramHandle': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 320,
    },
    'phoneNumber': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 320,
    },
    'email': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 320,
    },
    'hostDefaults': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'properties': <String, Object?>{
        'primaryActivityKind': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'socialRun',
            'running',
            'walking',
            'pickleball',
            'padel',
            'tennis',
            'badminton',
            'cycling',
            'spinClass',
            'yoga',
            'strengthTraining',
            'pubQuiz',
            'barCrawl',
            'dinner',
            'singlesMixer',
            'openActivity',
          ],
        },
        'supportedActivityKinds': <String, Object?>{
          'type': 'array',
          'maxItems': 16,
          'uniqueItems': true,
          'items': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'socialRun',
              'running',
              'walking',
              'pickleball',
              'padel',
              'tennis',
              'badminton',
              'cycling',
              'spinClass',
              'yoga',
              'strengthTraining',
              'pubQuiz',
              'barCrawl',
              'dinner',
              'singlesMixer',
              'openActivity',
            ],
          },
        },
        'eventPolicy': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'properties': <String, Object?>{
            'admissionPreset': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'openCapacity',
                'inviteOnly',
                'balancedSingles',
                'fixedCohortCaps',
              ],
            },
            'minAge': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 120,
            },
            'maxAge': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 120,
            },
            'maxMen': <String, Object?>{
              'type': <Object?>[
                'integer',
                'null',
              ],
              'minimum': 0,
            },
            'maxWomen': <String, Object?>{
              'type': <Object?>[
                'integer',
                'null',
              ],
              'minimum': 0,
            },
            'dynamicPricingEnabled': <String, Object?>{
              'type': 'boolean',
            },
            'dynamicPricingStepInPaise': <String, Object?>{
              'type': <Object?>[
                'integer',
                'null',
              ],
              'minimum': 0,
              'maximum': 100000000,
            },
            'dynamicPricingMaxInPaise': <String, Object?>{
              'type': <Object?>[
                'integer',
                'null',
              ],
              'minimum': 0,
              'maximum': 100000000,
            },
            'cancellationPolicyId': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'flexible',
                'standard',
                'strict',
              ],
            },
          },
        },
        'eventSuccess': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'properties': <String, Object?>{
            'enabled': <String, Object?>{
              'type': 'boolean',
            },
            'playbookId': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 120,
            },
            'selectedModuleIds': <String, Object?>{
              'type': 'array',
              'maxItems': 24,
              'items': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 120,
              },
            },
            'structureConfig': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'unitKind',
                'unitSize',
                'revealCountdownSeconds',
              ],
              'properties': <String, Object?>{
                'unitKind': <String, Object?>{
                  'type': 'string',
                  'enum': <Object?>[
                    'wholeGroup',
                    'pods',
                    'pairs',
                    'teams',
                    'tables',
                  ],
                },
                'unitSize': <String, Object?>{
                  'type': 'integer',
                  'minimum': 1,
                  'maximum': 1000,
                },
                'unitCount': <String, Object?>{
                  'type': <Object?>[
                    'integer',
                    'null',
                  ],
                  'minimum': 1,
                  'maximum': 200,
                },
                'rotationIntervalMinutes': <String, Object?>{
                  'type': <Object?>[
                    'integer',
                    'null',
                  ],
                  'minimum': 5,
                  'maximum': 180,
                },
                'revealCountdownSeconds': <String, Object?>{
                  'type': 'integer',
                  'minimum': 0,
                  'maximum': 60,
                },
              },
            },
            'hostGoal': <String, Object?>{
              'type': 'string',
              'maxLength': 300,
            },
            'wingmanRequestsEnabled': <String, Object?>{
              'type': 'boolean',
            },
            'contextualOpenersEnabled': <String, Object?>{
              'type': 'boolean',
            },
            'compatibilityAffectsRanking': <String, Object?>{
              'type': 'boolean',
            },
            'questionnaireConfig': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'templateId',
              ],
              'properties': <String, Object?>{
                'templateId': <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                  'maxLength': 120,
                },
                'customTitle': <String, Object?>{
                  'type': <Object?>[
                    'string',
                    'null',
                  ],
                  'maxLength': 80,
                },
                'customQuestions': <String, Object?>{
                  'type': 'array',
                  'maxItems': 8,
                  'items': <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'id',
                      'prompt',
                      'options',
                    ],
                    'properties': <String, Object?>{
                      'id': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 120,
                      },
                      'prompt': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 140,
                      },
                      'options': <String, Object?>{
                        'type': 'array',
                        'minItems': 2,
                        'maxItems': 5,
                        'items': <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'id',
                            'label',
                          ],
                          'properties': <String, Object?>{
                            'id': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 120,
                            },
                            'label': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 80,
                            },
                          },
                        },
                      },
                    },
                  },
                },
              },
            },
            'attendeePrompt': <String, Object?>{
              'type': <Object?>[
                'string',
                'null',
              ],
              'maxLength': 300,
            },
          },
        },
        'eventSuccessByActivityKind': <String, Object?>{
          'type': 'object',
          'maxProperties': 16,
          'additionalProperties': <String, Object?>{
            'type': 'object',
            'additionalProperties': false,
            'properties': <String, Object?>{
              'enabled': <String, Object?>{
                'type': 'boolean',
              },
              'playbookId': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 120,
              },
              'selectedModuleIds': <String, Object?>{
                'type': 'array',
                'maxItems': 24,
                'items': <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                  'maxLength': 120,
                },
              },
              'structureConfig': <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'unitKind',
                  'unitSize',
                  'revealCountdownSeconds',
                ],
                'properties': <String, Object?>{
                  'unitKind': <String, Object?>{
                    'type': 'string',
                    'enum': <Object?>[
                      'wholeGroup',
                      'pods',
                      'pairs',
                      'teams',
                      'tables',
                    ],
                  },
                  'unitSize': <String, Object?>{
                    'type': 'integer',
                    'minimum': 1,
                    'maximum': 1000,
                  },
                  'unitCount': <String, Object?>{
                    'type': <Object?>[
                      'integer',
                      'null',
                    ],
                    'minimum': 1,
                    'maximum': 200,
                  },
                  'rotationIntervalMinutes': <String, Object?>{
                    'type': <Object?>[
                      'integer',
                      'null',
                    ],
                    'minimum': 5,
                    'maximum': 180,
                  },
                  'revealCountdownSeconds': <String, Object?>{
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 60,
                  },
                },
              },
              'hostGoal': <String, Object?>{
                'type': 'string',
                'maxLength': 300,
              },
              'wingmanRequestsEnabled': <String, Object?>{
                'type': 'boolean',
              },
              'contextualOpenersEnabled': <String, Object?>{
                'type': 'boolean',
              },
              'compatibilityAffectsRanking': <String, Object?>{
                'type': 'boolean',
              },
              'questionnaireConfig': <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'templateId',
                ],
                'properties': <String, Object?>{
                  'templateId': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 120,
                  },
                  'customTitle': <String, Object?>{
                    'type': <Object?>[
                      'string',
                      'null',
                    ],
                    'maxLength': 80,
                  },
                  'customQuestions': <String, Object?>{
                    'type': 'array',
                    'maxItems': 8,
                    'items': <String, Object?>{
                      'type': 'object',
                      'additionalProperties': false,
                      'required': <Object?>[
                        'id',
                        'prompt',
                        'options',
                      ],
                      'properties': <String, Object?>{
                        'id': <String, Object?>{
                          'type': 'string',
                          'minLength': 1,
                          'maxLength': 120,
                        },
                        'prompt': <String, Object?>{
                          'type': 'string',
                          'minLength': 1,
                          'maxLength': 140,
                        },
                        'options': <String, Object?>{
                          'type': 'array',
                          'minItems': 2,
                          'maxItems': 5,
                          'items': <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'id',
                              'label',
                            ],
                            'properties': <String, Object?>{
                              'id': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 120,
                              },
                              'label': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 80,
                              },
                            },
                          },
                        },
                      },
                    },
                  },
                },
              },
              'attendeePrompt': <String, Object?>{
                'type': <Object?>[
                  'string',
                  'null',
                ],
                'maxLength': 300,
              },
            },
          },
        },
      },
    },
  },
};

const schemaCreateClubCallableResponseSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callable_responses/create_club_response.schema.json',
  'title': 'CreateClubCallableResponse',
  'description': 'Callable response returned by createClub.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'clubId',
  ],
  'properties': <String, Object?>{
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
  },
};

const schemaUpdateClubCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/update_club_payload.schema.json',
  'title': 'UpdateClubCallablePayload',
  'description': 'Callable payload accepted by updateClub.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'clubId',
    'fields',
  ],
  'properties': <String, Object?>{
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'fields': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'minProperties': 1,
      'properties': <String, Object?>{
        'name': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 120,
        },
        'description': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 2000,
        },
        'location': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'minLength': 1,
          'maxLength': 80,
          'pattern': '^[a-z0-9-]+\$',
        },
        'area': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 120,
        },
        'hostName': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 120,
        },
        'hostAvatarUrl': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 320,
        },
        'imageUrl': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 320,
        },
        'profileImageUrl': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 320,
        },
        'tags': <String, Object?>{
          'type': 'array',
          'items': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 40,
          },
          'maxItems': 12,
          'uniqueItems': true,
        },
        'instagramHandle': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 320,
        },
        'phoneNumber': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 320,
        },
        'email': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 320,
        },
        'hostDefaults': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'properties': <String, Object?>{
            'primaryActivityKind': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'socialRun',
                'running',
                'walking',
                'pickleball',
                'padel',
                'tennis',
                'badminton',
                'cycling',
                'spinClass',
                'yoga',
                'strengthTraining',
                'pubQuiz',
                'barCrawl',
                'dinner',
                'singlesMixer',
                'openActivity',
              ],
            },
            'supportedActivityKinds': <String, Object?>{
              'type': 'array',
              'maxItems': 16,
              'uniqueItems': true,
              'items': <String, Object?>{
                'type': 'string',
                'enum': <Object?>[
                  'socialRun',
                  'running',
                  'walking',
                  'pickleball',
                  'padel',
                  'tennis',
                  'badminton',
                  'cycling',
                  'spinClass',
                  'yoga',
                  'strengthTraining',
                  'pubQuiz',
                  'barCrawl',
                  'dinner',
                  'singlesMixer',
                  'openActivity',
                ],
              },
            },
            'eventPolicy': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'properties': <String, Object?>{
                'admissionPreset': <String, Object?>{
                  'type': 'string',
                  'enum': <Object?>[
                    'openCapacity',
                    'inviteOnly',
                    'balancedSingles',
                    'fixedCohortCaps',
                  ],
                },
                'minAge': <String, Object?>{
                  'type': 'integer',
                  'minimum': 0,
                  'maximum': 120,
                },
                'maxAge': <String, Object?>{
                  'type': 'integer',
                  'minimum': 0,
                  'maximum': 120,
                },
                'maxMen': <String, Object?>{
                  'type': <Object?>[
                    'integer',
                    'null',
                  ],
                  'minimum': 0,
                },
                'maxWomen': <String, Object?>{
                  'type': <Object?>[
                    'integer',
                    'null',
                  ],
                  'minimum': 0,
                },
                'dynamicPricingEnabled': <String, Object?>{
                  'type': 'boolean',
                },
                'dynamicPricingStepInPaise': <String, Object?>{
                  'type': <Object?>[
                    'integer',
                    'null',
                  ],
                  'minimum': 0,
                  'maximum': 100000000,
                },
                'dynamicPricingMaxInPaise': <String, Object?>{
                  'type': <Object?>[
                    'integer',
                    'null',
                  ],
                  'minimum': 0,
                  'maximum': 100000000,
                },
                'cancellationPolicyId': <String, Object?>{
                  'type': 'string',
                  'enum': <Object?>[
                    'flexible',
                    'standard',
                    'strict',
                  ],
                },
              },
            },
            'eventSuccess': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'properties': <String, Object?>{
                'enabled': <String, Object?>{
                  'type': 'boolean',
                },
                'playbookId': <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                  'maxLength': 120,
                },
                'selectedModuleIds': <String, Object?>{
                  'type': 'array',
                  'maxItems': 24,
                  'items': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 120,
                  },
                },
                'structureConfig': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'unitKind',
                    'unitSize',
                    'revealCountdownSeconds',
                  ],
                  'properties': <String, Object?>{
                    'unitKind': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'wholeGroup',
                        'pods',
                        'pairs',
                        'teams',
                        'tables',
                      ],
                    },
                    'unitSize': <String, Object?>{
                      'type': 'integer',
                      'minimum': 1,
                      'maximum': 1000,
                    },
                    'unitCount': <String, Object?>{
                      'type': <Object?>[
                        'integer',
                        'null',
                      ],
                      'minimum': 1,
                      'maximum': 200,
                    },
                    'rotationIntervalMinutes': <String, Object?>{
                      'type': <Object?>[
                        'integer',
                        'null',
                      ],
                      'minimum': 5,
                      'maximum': 180,
                    },
                    'revealCountdownSeconds': <String, Object?>{
                      'type': 'integer',
                      'minimum': 0,
                      'maximum': 60,
                    },
                  },
                },
                'hostGoal': <String, Object?>{
                  'type': 'string',
                  'maxLength': 300,
                },
                'wingmanRequestsEnabled': <String, Object?>{
                  'type': 'boolean',
                },
                'contextualOpenersEnabled': <String, Object?>{
                  'type': 'boolean',
                },
                'compatibilityAffectsRanking': <String, Object?>{
                  'type': 'boolean',
                },
                'questionnaireConfig': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'templateId',
                  ],
                  'properties': <String, Object?>{
                    'templateId': <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 120,
                    },
                    'customTitle': <String, Object?>{
                      'type': <Object?>[
                        'string',
                        'null',
                      ],
                      'maxLength': 80,
                    },
                    'customQuestions': <String, Object?>{
                      'type': 'array',
                      'maxItems': 8,
                      'items': <String, Object?>{
                        'type': 'object',
                        'additionalProperties': false,
                        'required': <Object?>[
                          'id',
                          'prompt',
                          'options',
                        ],
                        'properties': <String, Object?>{
                          'id': <String, Object?>{
                            'type': 'string',
                            'minLength': 1,
                            'maxLength': 120,
                          },
                          'prompt': <String, Object?>{
                            'type': 'string',
                            'minLength': 1,
                            'maxLength': 140,
                          },
                          'options': <String, Object?>{
                            'type': 'array',
                            'minItems': 2,
                            'maxItems': 5,
                            'items': <String, Object?>{
                              'type': 'object',
                              'additionalProperties': false,
                              'required': <Object?>[
                                'id',
                                'label',
                              ],
                              'properties': <String, Object?>{
                                'id': <String, Object?>{
                                  'type': 'string',
                                  'minLength': 1,
                                  'maxLength': 120,
                                },
                                'label': <String, Object?>{
                                  'type': 'string',
                                  'minLength': 1,
                                  'maxLength': 80,
                                },
                              },
                            },
                          },
                        },
                      },
                    },
                  },
                },
                'attendeePrompt': <String, Object?>{
                  'type': <Object?>[
                    'string',
                    'null',
                  ],
                  'maxLength': 300,
                },
              },
            },
            'eventSuccessByActivityKind': <String, Object?>{
              'type': 'object',
              'maxProperties': 16,
              'additionalProperties': <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'properties': <String, Object?>{
                  'enabled': <String, Object?>{
                    'type': 'boolean',
                  },
                  'playbookId': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 120,
                  },
                  'selectedModuleIds': <String, Object?>{
                    'type': 'array',
                    'maxItems': 24,
                    'items': <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 120,
                    },
                  },
                  'structureConfig': <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'unitKind',
                      'unitSize',
                      'revealCountdownSeconds',
                    ],
                    'properties': <String, Object?>{
                      'unitKind': <String, Object?>{
                        'type': 'string',
                        'enum': <Object?>[
                          'wholeGroup',
                          'pods',
                          'pairs',
                          'teams',
                          'tables',
                        ],
                      },
                      'unitSize': <String, Object?>{
                        'type': 'integer',
                        'minimum': 1,
                        'maximum': 1000,
                      },
                      'unitCount': <String, Object?>{
                        'type': <Object?>[
                          'integer',
                          'null',
                        ],
                        'minimum': 1,
                        'maximum': 200,
                      },
                      'rotationIntervalMinutes': <String, Object?>{
                        'type': <Object?>[
                          'integer',
                          'null',
                        ],
                        'minimum': 5,
                        'maximum': 180,
                      },
                      'revealCountdownSeconds': <String, Object?>{
                        'type': 'integer',
                        'minimum': 0,
                        'maximum': 60,
                      },
                    },
                  },
                  'hostGoal': <String, Object?>{
                    'type': 'string',
                    'maxLength': 300,
                  },
                  'wingmanRequestsEnabled': <String, Object?>{
                    'type': 'boolean',
                  },
                  'contextualOpenersEnabled': <String, Object?>{
                    'type': 'boolean',
                  },
                  'compatibilityAffectsRanking': <String, Object?>{
                    'type': 'boolean',
                  },
                  'questionnaireConfig': <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'templateId',
                    ],
                    'properties': <String, Object?>{
                      'templateId': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 120,
                      },
                      'customTitle': <String, Object?>{
                        'type': <Object?>[
                          'string',
                          'null',
                        ],
                        'maxLength': 80,
                      },
                      'customQuestions': <String, Object?>{
                        'type': 'array',
                        'maxItems': 8,
                        'items': <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'id',
                            'prompt',
                            'options',
                          ],
                          'properties': <String, Object?>{
                            'id': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 120,
                            },
                            'prompt': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 140,
                            },
                            'options': <String, Object?>{
                              'type': 'array',
                              'minItems': 2,
                              'maxItems': 5,
                              'items': <String, Object?>{
                                'type': 'object',
                                'additionalProperties': false,
                                'required': <Object?>[
                                  'id',
                                  'label',
                                ],
                                'properties': <String, Object?>{
                                  'id': <String, Object?>{
                                    'type': 'string',
                                    'minLength': 1,
                                    'maxLength': 120,
                                  },
                                  'label': <String, Object?>{
                                    'type': 'string',
                                    'minLength': 1,
                                    'maxLength': 80,
                                  },
                                },
                              },
                            },
                          },
                        },
                      },
                    },
                  },
                  'attendeePrompt': <String, Object?>{
                    'type': <Object?>[
                      'string',
                      'null',
                    ],
                    'maxLength': 300,
                  },
                },
              },
            },
          },
        },
      },
    },
  },
};

const schemaAddClubHostCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/add_club_host_payload.schema.json',
  'title': 'AddClubHostCallablePayload',
  'description': 'Callable payload accepted by addClubHost.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'clubId',
    'uid',
  ],
  'properties': <String, Object?>{
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'uid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
  },
};

const schemaRemoveClubHostCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/remove_club_host_payload.schema.json',
  'title': 'RemoveClubHostCallablePayload',
  'description': 'Callable payload accepted by removeClubHost.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'clubId',
    'uid',
  ],
  'properties': <String, Object?>{
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'uid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
  },
};

const schemaArchiveClubCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/archive_club_payload.schema.json',
  'title': 'ArchiveClubCallablePayload',
  'description': 'Callable payload accepted by archiveClub.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'clubId',
  ],
  'properties': <String, Object?>{
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'reason': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 500,
    },
  },
};

const schemaDeleteClubCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/delete_club_payload.schema.json',
  'title': 'DeleteClubCallablePayload',
  'description': 'Callable payload accepted by deleteClub.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'clubId',
  ],
  'properties': <String, Object?>{
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
  },
};

const schemaClubMembershipCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/club_membership_payload.schema.json',
  'title': 'ClubMembershipCallablePayload',
  'description': 'Callable payload accepted by joinClub and leaveClub.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'clubId',
  ],
  'properties': <String, Object?>{
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
  },
};

const schemaSetClubNotificationPreferenceCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/set_club_notification_preference_payload.schema.json',
  'title': 'SetClubNotificationPreferenceCallablePayload',
  'description': 'Callable payload accepted by setClubNotificationPreference.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'clubId',
    'enabled',
  ],
  'properties': <String, Object?>{
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'enabled': <String, Object?>{
      'type': 'boolean',
    },
  },
};

const schemaCreateEventCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/create_event_payload.schema.json',
  'title': 'CreateEventCallablePayload',
  'description': 'Callable payload accepted by createEvent.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'clubId',
    'startTimeMillis',
    'endTimeMillis',
    'meetingPoint',
    'startingPointLat',
    'startingPointLng',
    'distanceKm',
    'pace',
    'capacityLimit',
    'description',
    'priceInPaise',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'startTimeMillis': <String, Object?>{
      'type': 'integer',
    },
    'endTimeMillis': <String, Object?>{
      'type': 'integer',
    },
    'meetingPoint': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 240,
    },
    'meetingLocation': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'description': 'Canonical meeting location selected from Google Places or a manually pinned map coordinate.',
      'required': <Object?>[
        'name',
        'latitude',
        'longitude',
      ],
      'properties': <String, Object?>{
        'name': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 240,
        },
        'address': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 500,
        },
        'placeId': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'minLength': 1,
          'maxLength': 256,
        },
        'latitude': <String, Object?>{
          'type': <Object?>[
            'number',
            'null',
          ],
          'minimum': -90,
          'maximum': 90,
        },
        'longitude': <String, Object?>{
          'type': <Object?>[
            'number',
            'null',
          ],
          'minimum': -180,
          'maximum': 180,
        },
        'notes': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 1000,
        },
      },
    },
    'startingPointLat': <String, Object?>{
      'type': 'number',
      'minimum': -90,
      'maximum': 90,
    },
    'startingPointLng': <String, Object?>{
      'type': 'number',
      'minimum': -180,
      'maximum': 180,
    },
    'locationDetails': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 1000,
    },
    'photoUrl': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'string',
          'format': 'uri',
          'maxLength': 2048,
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'distanceKm': <String, Object?>{
      'type': 'number',
      'minimum': 0,
      'maximum': 100,
    },
    'pace': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'easy',
        'moderate',
        'fast',
        'competitive',
      ],
    },
    'capacityLimit': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 1000,
    },
    'description': <String, Object?>{
      'type': 'string',
      'maxLength': 2000,
    },
    'priceInPaise': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 100000000,
    },
    'currency': <String, Object?>{
      'type': 'string',
      'pattern': '^[A-Z]{3}\$',
    },
    'eventPolicy': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'version',
        'admission',
        'pricing',
        'cancellation',
        'settlement',
      ],
      'properties': <String, Object?>{
        'version': <String, Object?>{
          'type': 'integer',
          'const': 1,
        },
        'admission': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'format',
            'capacityLimit',
            'waitlistPolicy',
            'inviteRequired',
            'membershipRequired',
            'manualApprovalRequired',
            'privateAccessPolicy',
            'cohortCapacityLimits',
            'balancedRatioPolicy',
          ],
          'properties': <String, Object?>{
            'format': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'open',
                'inviteOnly',
                'manualApproval',
                'fixedCohortCaps',
                'balancedRatio',
                'membersOnly',
              ],
            },
            'capacityLimit': <String, Object?>{
              'type': 'integer',
              'minimum': 1,
              'maximum': 1000,
            },
            'waitlistPolicy': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'mode',
                'offerWindowMinutes',
              ],
              'properties': <String, Object?>{
                'mode': <String, Object?>{
                  'type': 'string',
                  'enum': <Object?>[
                    'disabled',
                    'rankedOffer',
                    'broadcastFirstComeFirstServed',
                    'manualReview',
                  ],
                },
                'offerWindowMinutes': <String, Object?>{
                  'type': 'integer',
                  'minimum': 0,
                  'maximum': 10080,
                },
              },
            },
            'inviteRequired': <String, Object?>{
              'type': 'boolean',
            },
            'membershipRequired': <String, Object?>{
              'type': 'boolean',
            },
            'manualApprovalRequired': <String, Object?>{
              'type': 'boolean',
            },
            'privateAccessPolicy': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'mode',
                'inviteCodeHint',
                'privateLinkEnabled',
              ],
              'properties': <String, Object?>{
                'mode': <String, Object?>{
                  'type': 'string',
                  'enum': <Object?>[
                    'none',
                    'inviteCode',
                  ],
                },
                'inviteCodeHint': <String, Object?>{
                  'type': <Object?>[
                    'string',
                    'null',
                  ],
                  'maxLength': 64,
                },
                'privateLinkEnabled': <String, Object?>{
                  'type': 'boolean',
                },
              },
            },
            'cohortCapacityLimits': <String, Object?>{
              'type': 'object',
              'additionalProperties': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
              },
            },
            'balancedRatioPolicy': <String, Object?>{
              'type': <Object?>[
                'object',
                'null',
              ],
              'additionalProperties': false,
              'required': <Object?>[
                'leftCohortId',
                'rightCohortId',
                'maxSkew',
                'openingBufferPerCohort',
                'outOfRatioCohortPolicy',
              ],
              'properties': <String, Object?>{
                'leftCohortId': <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                  'maxLength': 120,
                },
                'rightCohortId': <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                  'maxLength': 120,
                },
                'maxSkew': <String, Object?>{
                  'type': 'integer',
                  'minimum': 0,
                  'maximum': 1000,
                },
                'openingBufferPerCohort': <String, Object?>{
                  'type': 'integer',
                  'minimum': 0,
                  'maximum': 1000,
                },
                'outOfRatioCohortPolicy': <String, Object?>{
                  'type': 'string',
                  'enum': <Object?>[
                    'admitWithinGeneralCapacity',
                    'waitlist',
                    'manualReview',
                    'reject',
                  ],
                },
              },
            },
          },
        },
        'pricing': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'basePriceInPaise',
            'cohortAdjustmentsInPaise',
            'demandPricingRules',
          ],
          'properties': <String, Object?>{
            'basePriceInPaise': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 100000000,
            },
            'cohortAdjustmentsInPaise': <String, Object?>{
              'type': 'object',
              'additionalProperties': <String, Object?>{
                'type': 'integer',
                'minimum': -100000000,
                'maximum': 100000000,
              },
            },
            'demandPricingRules': <String, Object?>{
              'type': 'array',
              'maxItems': 20,
              'items': <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'pricedCohortId',
                  'balancingCohortId',
                  'stepAdjustmentInPaise',
                  'maxAdjustmentInPaise',
                  'freeSkew',
                  'demandStep',
                ],
                'properties': <String, Object?>{
                  'pricedCohortId': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 120,
                  },
                  'balancingCohortId': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 120,
                  },
                  'stepAdjustmentInPaise': <String, Object?>{
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 100000000,
                  },
                  'maxAdjustmentInPaise': <String, Object?>{
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 100000000,
                  },
                  'freeSkew': <String, Object?>{
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 1000,
                  },
                  'demandStep': <String, Object?>{
                    'type': 'integer',
                    'minimum': 1,
                    'maximum': 1000,
                  },
                },
              },
            },
          },
        },
        'cancellation': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'policyId',
          ],
          'properties': <String, Object?>{
            'policyId': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'flexible',
                'standard',
                'strict',
              ],
            },
          },
        },
        'settlement': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'hostPayoutTiming',
          ],
          'properties': <String, Object?>{
            'hostPayoutTiming': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'afterEventCompletion',
              ],
            },
          },
        },
      },
    },
    'privateAccess': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'properties': <String, Object?>{
        'inviteCode': <String, Object?>{
          'type': 'string',
          'minLength': 4,
          'maxLength': 64,
          'pattern': '^[A-Za-z0-9_-]+\$',
        },
      },
    },
    'eventFormat': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'version',
        'activityKind',
        'interactionModel',
      ],
      'properties': <String, Object?>{
        'version': <String, Object?>{
          'type': 'integer',
          'const': 1,
        },
        'activityKind': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'socialRun',
            'running',
            'walking',
            'pickleball',
            'padel',
            'tennis',
            'badminton',
            'cycling',
            'spinClass',
            'yoga',
            'strengthTraining',
            'pubQuiz',
            'barCrawl',
            'dinner',
            'singlesMixer',
            'openActivity',
          ],
        },
        'interactionModel': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'pacePods',
            'pairedRotations',
            'teamRotations',
            'seatedTable',
            'freeFormMixer',
            'hostLedProgram',
            'openFormat',
          ],
        },
        'customActivityLabel': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 80,
        },
        'defaultPlaybookId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 120,
        },
        'defaultModuleIds': <String, Object?>{
          'type': 'array',
          'items': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 120,
          },
          'maxItems': 30,
          'uniqueItems': true,
        },
        'activityDetails': <String, Object?>{
          'type': 'object',
          'additionalProperties': true,
        },
      },
    },
    'eventSuccessDefaults': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'properties': <String, Object?>{
        'enabled': <String, Object?>{
          'type': 'boolean',
        },
        'playbookId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 120,
        },
        'selectedModuleIds': <String, Object?>{
          'type': 'array',
          'maxItems': 24,
          'items': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 120,
          },
        },
        'structureConfig': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'unitKind',
            'unitSize',
            'revealCountdownSeconds',
          ],
          'properties': <String, Object?>{
            'unitKind': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'wholeGroup',
                'pods',
                'pairs',
                'teams',
                'tables',
              ],
            },
            'unitSize': <String, Object?>{
              'type': 'integer',
              'minimum': 1,
              'maximum': 1000,
            },
            'unitCount': <String, Object?>{
              'type': <Object?>[
                'integer',
                'null',
              ],
              'minimum': 1,
              'maximum': 200,
            },
            'rotationIntervalMinutes': <String, Object?>{
              'type': <Object?>[
                'integer',
                'null',
              ],
              'minimum': 5,
              'maximum': 180,
            },
            'revealCountdownSeconds': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 60,
            },
          },
        },
        'hostGoal': <String, Object?>{
          'type': 'string',
          'maxLength': 300,
        },
        'wingmanRequestsEnabled': <String, Object?>{
          'type': 'boolean',
        },
        'contextualOpenersEnabled': <String, Object?>{
          'type': 'boolean',
        },
        'compatibilityAffectsRanking': <String, Object?>{
          'type': 'boolean',
        },
        'questionnaireConfig': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'templateId',
          ],
          'properties': <String, Object?>{
            'templateId': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 120,
            },
            'customTitle': <String, Object?>{
              'type': <Object?>[
                'string',
                'null',
              ],
              'maxLength': 80,
            },
            'customQuestions': <String, Object?>{
              'type': 'array',
              'maxItems': 8,
              'items': <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'id',
                  'prompt',
                  'options',
                ],
                'properties': <String, Object?>{
                  'id': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 120,
                  },
                  'prompt': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 140,
                  },
                  'options': <String, Object?>{
                    'type': 'array',
                    'minItems': 2,
                    'maxItems': 5,
                    'items': <String, Object?>{
                      'type': 'object',
                      'additionalProperties': false,
                      'required': <Object?>[
                        'id',
                        'label',
                      ],
                      'properties': <String, Object?>{
                        'id': <String, Object?>{
                          'type': 'string',
                          'minLength': 1,
                          'maxLength': 120,
                        },
                        'label': <String, Object?>{
                          'type': 'string',
                          'minLength': 1,
                          'maxLength': 80,
                        },
                      },
                    },
                  },
                },
              },
            },
          },
        },
        'attendeePrompt': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 300,
        },
      },
    },
    'constraints': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'properties': <String, Object?>{
        'minAge': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 120,
        },
        'maxAge': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 120,
        },
        'maxMen': <String, Object?>{
          'type': <Object?>[
            'integer',
            'null',
          ],
          'minimum': 0,
        },
        'maxWomen': <String, Object?>{
          'type': <Object?>[
            'integer',
            'null',
          ],
          'minimum': 0,
        },
      },
    },
  },
};

const schemaUpdateEventCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/update_event_payload.schema.json',
  'title': 'UpdateEventCallablePayload',
  'description': 'Callable payload accepted by updateEvent.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'eventId',
    'fields',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'fields': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'minProperties': 1,
      'properties': <String, Object?>{
        'startTimeMillis': <String, Object?>{
          'type': 'integer',
        },
        'endTimeMillis': <String, Object?>{
          'type': 'integer',
        },
        'meetingPoint': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 240,
        },
        'meetingLocation': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'description': 'Canonical meeting location selected from Google Places or a manually pinned map coordinate.',
          'required': <Object?>[
            'name',
            'latitude',
            'longitude',
          ],
          'properties': <String, Object?>{
            'name': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 240,
            },
            'address': <String, Object?>{
              'type': <Object?>[
                'string',
                'null',
              ],
              'maxLength': 500,
            },
            'placeId': <String, Object?>{
              'type': <Object?>[
                'string',
                'null',
              ],
              'minLength': 1,
              'maxLength': 256,
            },
            'latitude': <String, Object?>{
              'type': <Object?>[
                'number',
                'null',
              ],
              'minimum': -90,
              'maximum': 90,
            },
            'longitude': <String, Object?>{
              'type': <Object?>[
                'number',
                'null',
              ],
              'minimum': -180,
              'maximum': 180,
            },
            'notes': <String, Object?>{
              'type': <Object?>[
                'string',
                'null',
              ],
              'maxLength': 1000,
            },
          },
        },
        'startingPointLat': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': <Object?>[
                'number',
                'null',
              ],
              'minimum': -90,
              'maximum': 90,
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'startingPointLng': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': <Object?>[
                'number',
                'null',
              ],
              'minimum': -180,
              'maximum': 180,
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'locationDetails': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 1000,
        },
        'photoUrl': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'string',
              'format': 'uri',
              'maxLength': 2048,
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'distanceKm': <String, Object?>{
          'type': 'number',
          'minimum': 0,
          'maximum': 100,
        },
        'pace': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'easy',
            'moderate',
            'fast',
            'competitive',
          ],
        },
        'description': <String, Object?>{
          'type': 'string',
          'maxLength': 2000,
        },
        'capacityLimit': <String, Object?>{
          'type': 'integer',
          'minimum': 1,
          'maximum': 1000,
        },
        'priceInPaise': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 100000000,
        },
        'constraints': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'properties': <String, Object?>{
            'minAge': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 120,
            },
            'maxAge': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 120,
            },
            'maxMen': <String, Object?>{
              'type': <Object?>[
                'integer',
                'null',
              ],
              'minimum': 0,
            },
            'maxWomen': <String, Object?>{
              'type': <Object?>[
                'integer',
                'null',
              ],
              'minimum': 0,
            },
          },
        },
        'eventPolicy': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'version',
            'admission',
            'pricing',
            'cancellation',
            'settlement',
          ],
          'properties': <String, Object?>{
            'version': <String, Object?>{
              'type': 'integer',
              'const': 1,
            },
            'admission': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'format',
                'capacityLimit',
                'waitlistPolicy',
                'inviteRequired',
                'membershipRequired',
                'manualApprovalRequired',
                'privateAccessPolicy',
                'cohortCapacityLimits',
                'balancedRatioPolicy',
              ],
              'properties': <String, Object?>{
                'format': <String, Object?>{
                  'type': 'string',
                  'enum': <Object?>[
                    'open',
                    'inviteOnly',
                    'manualApproval',
                    'fixedCohortCaps',
                    'balancedRatio',
                    'membersOnly',
                  ],
                },
                'capacityLimit': <String, Object?>{
                  'type': 'integer',
                  'minimum': 1,
                  'maximum': 1000,
                },
                'waitlistPolicy': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'mode',
                    'offerWindowMinutes',
                  ],
                  'properties': <String, Object?>{
                    'mode': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'disabled',
                        'rankedOffer',
                        'broadcastFirstComeFirstServed',
                        'manualReview',
                      ],
                    },
                    'offerWindowMinutes': <String, Object?>{
                      'type': 'integer',
                      'minimum': 0,
                      'maximum': 10080,
                    },
                  },
                },
                'inviteRequired': <String, Object?>{
                  'type': 'boolean',
                },
                'membershipRequired': <String, Object?>{
                  'type': 'boolean',
                },
                'manualApprovalRequired': <String, Object?>{
                  'type': 'boolean',
                },
                'privateAccessPolicy': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'mode',
                    'inviteCodeHint',
                    'privateLinkEnabled',
                  ],
                  'properties': <String, Object?>{
                    'mode': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'none',
                        'inviteCode',
                      ],
                    },
                    'inviteCodeHint': <String, Object?>{
                      'type': <Object?>[
                        'string',
                        'null',
                      ],
                      'maxLength': 64,
                    },
                    'privateLinkEnabled': <String, Object?>{
                      'type': 'boolean',
                    },
                  },
                },
                'cohortCapacityLimits': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': <String, Object?>{
                    'type': 'integer',
                    'minimum': 0,
                  },
                },
                'balancedRatioPolicy': <String, Object?>{
                  'type': <Object?>[
                    'object',
                    'null',
                  ],
                  'additionalProperties': false,
                  'required': <Object?>[
                    'leftCohortId',
                    'rightCohortId',
                    'maxSkew',
                    'openingBufferPerCohort',
                    'outOfRatioCohortPolicy',
                  ],
                  'properties': <String, Object?>{
                    'leftCohortId': <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 120,
                    },
                    'rightCohortId': <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 120,
                    },
                    'maxSkew': <String, Object?>{
                      'type': 'integer',
                      'minimum': 0,
                      'maximum': 1000,
                    },
                    'openingBufferPerCohort': <String, Object?>{
                      'type': 'integer',
                      'minimum': 0,
                      'maximum': 1000,
                    },
                    'outOfRatioCohortPolicy': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'admitWithinGeneralCapacity',
                        'waitlist',
                        'manualReview',
                        'reject',
                      ],
                    },
                  },
                },
              },
            },
            'pricing': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'basePriceInPaise',
                'cohortAdjustmentsInPaise',
                'demandPricingRules',
              ],
              'properties': <String, Object?>{
                'basePriceInPaise': <String, Object?>{
                  'type': 'integer',
                  'minimum': 0,
                  'maximum': 100000000,
                },
                'cohortAdjustmentsInPaise': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': <String, Object?>{
                    'type': 'integer',
                    'minimum': -100000000,
                    'maximum': 100000000,
                  },
                },
                'demandPricingRules': <String, Object?>{
                  'type': 'array',
                  'maxItems': 20,
                  'items': <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'pricedCohortId',
                      'balancingCohortId',
                      'stepAdjustmentInPaise',
                      'maxAdjustmentInPaise',
                      'freeSkew',
                      'demandStep',
                    ],
                    'properties': <String, Object?>{
                      'pricedCohortId': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 120,
                      },
                      'balancingCohortId': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 120,
                      },
                      'stepAdjustmentInPaise': <String, Object?>{
                        'type': 'integer',
                        'minimum': 0,
                        'maximum': 100000000,
                      },
                      'maxAdjustmentInPaise': <String, Object?>{
                        'type': 'integer',
                        'minimum': 0,
                        'maximum': 100000000,
                      },
                      'freeSkew': <String, Object?>{
                        'type': 'integer',
                        'minimum': 0,
                        'maximum': 1000,
                      },
                      'demandStep': <String, Object?>{
                        'type': 'integer',
                        'minimum': 1,
                        'maximum': 1000,
                      },
                    },
                  },
                },
              },
            },
            'cancellation': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'policyId',
              ],
              'properties': <String, Object?>{
                'policyId': <String, Object?>{
                  'type': 'string',
                  'enum': <Object?>[
                    'flexible',
                    'standard',
                    'strict',
                  ],
                },
              },
            },
            'settlement': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'hostPayoutTiming',
              ],
              'properties': <String, Object?>{
                'hostPayoutTiming': <String, Object?>{
                  'type': 'string',
                  'enum': <Object?>[
                    'afterEventCompletion',
                  ],
                },
              },
            },
          },
        },
        'privateAccess': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'properties': <String, Object?>{
            'inviteCode': <String, Object?>{
              'type': <Object?>[
                'string',
                'null',
              ],
              'minLength': 4,
              'maxLength': 64,
              'pattern': '^[A-Za-z0-9_-]+\$',
            },
          },
        },
      },
    },
  },
};

const schemaCancelEventCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/cancel_event_payload.schema.json',
  'title': 'CancelEventCallablePayload',
  'description': 'Callable payload accepted by cancelEvent.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'eventId',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'reason': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 500,
    },
  },
};

const schemaDeleteEventCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/delete_event_payload.schema.json',
  'title': 'DeleteEventCallablePayload',
  'description': 'Callable payload accepted by deleteEvent.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'eventId',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
  },
};

const schemaEventIdCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/event_id_payload.schema.json',
  'title': 'EventIdCallablePayload',
  'description': 'Callable payload accepted by simple event actions that need only a eventId.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'eventId',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'inviteCode': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'minLength': 4,
      'maxLength': 64,
      'pattern': '^[A-Za-z0-9_-]+\$',
    },
  },
};

const schemaMarkEventAttendanceCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/mark_event_attendance_payload.schema.json',
  'title': 'MarkEventAttendanceCallablePayload',
  'description': 'Callable payload accepted by markEventAttendance.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'eventId',
    'userId',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'userId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
  },
};

const schemaOverrideEventSuccessRotationsCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/override_event_success_rotations_payload.schema.json',
  'title': 'OverrideEventSuccessRotationsCallablePayload',
  'description': 'Callable payload accepted by overrideEventSuccessRotations.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'eventId',
    'rounds',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'rounds': <String, Object?>{
      'type': 'array',
      'minItems': 1,
      'maxItems': 32,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'roundIndex',
          'pairings',
        ],
        'properties': <String, Object?>{
          'roundIndex': <String, Object?>{
            'type': 'integer',
            'minimum': 0,
            'maximum': 31,
          },
          'pairings': <String, Object?>{
            'type': 'array',
            'minItems': 0,
            'maxItems': 100,
            'items': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'uidA',
                'uidB',
              ],
              'properties': <String, Object?>{
                'uidA': <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                  'maxLength': 180,
                },
                'uidB': <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                  'maxLength': 180,
                },
              },
            },
          },
        },
      },
    },
  },
};

const schemaSubmitEventSuccessWingmanRequestCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/submit_event_success_wingman_request_payload.schema.json',
  'title': 'SubmitEventSuccessWingmanRequestCallablePayload',
  'description': 'Callable payload accepted by submitEventSuccessWingmanRequest.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'eventId',
    'targetUid',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'targetUid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'note': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 240,
    },
  },
};

const schemaStartEventSuccessFirstHelloMissionCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/start_event_success_first_hello_mission_payload.schema.json',
  'title': 'StartEventSuccessFirstHelloMissionCallablePayload',
  'description': 'Callable payload accepted by startEventSuccessFirstHelloMission.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'eventId',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'latitude': <String, Object?>{
      'type': <Object?>[
        'number',
        'null',
      ],
      'minimum': -90,
      'maximum': 90,
    },
    'longitude': <String, Object?>{
      'type': <Object?>[
        'number',
        'null',
      ],
      'minimum': -180,
      'maximum': 180,
    },
  },
};

const schemaCompleteEventSuccessFirstHelloMissionCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/complete_event_success_first_hello_mission_payload.schema.json',
  'title': 'CompleteEventSuccessFirstHelloMissionCallablePayload',
  'description': 'Callable payload accepted by completeEventSuccessFirstHelloMission.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'eventId',
    'answerId',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'answerId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 64,
    },
    'latitude': <String, Object?>{
      'type': <Object?>[
        'number',
        'null',
      ],
      'minimum': -90,
      'maximum': 90,
    },
    'longitude': <String, Object?>{
      'type': <Object?>[
        'number',
        'null',
      ],
      'minimum': -180,
      'maximum': 180,
    },
  },
};

const schemaMarkEventAttendanceCallableResponseSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callable_responses/mark_event_attendance_response.schema.json',
  'title': 'MarkEventAttendanceCallableResponse',
  'description': 'Callable response returned by markEventAttendance.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'attended',
  ],
  'properties': <String, Object?>{
    'attended': <String, Object?>{
      'type': 'boolean',
    },
  },
};

const schemaSelfCheckInAttendanceCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/self_check_in_attendance_payload.schema.json',
  'title': 'SelfCheckInAttendanceCallablePayload',
  'description': 'Callable payload accepted by selfCheckInAttendance.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'eventId',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'latitude': <String, Object?>{
      'type': <Object?>[
        'number',
        'null',
      ],
      'minimum': -90,
      'maximum': 90,
    },
    'longitude': <String, Object?>{
      'type': <Object?>[
        'number',
        'null',
      ],
      'minimum': -180,
      'maximum': 180,
    },
  },
};

const schemaCreateEventReviewCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/create_event_review_payload.schema.json',
  'title': 'CreateEventReviewCallablePayload',
  'description': 'Callable payload accepted by createEventReview.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'clubId',
    'eventId',
    'rating',
    'comment',
  ],
  'properties': <String, Object?>{
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'rating': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 5,
    },
    'comment': <String, Object?>{
      'type': 'string',
      'maxLength': 1000,
    },
  },
};

const schemaUpdateEventReviewCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/update_event_review_payload.schema.json',
  'title': 'UpdateEventReviewCallablePayload',
  'description': 'Callable payload accepted by updateEventReview.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'reviewId',
    'rating',
    'comment',
  ],
  'properties': <String, Object?>{
    'reviewId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'rating': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 5,
    },
    'comment': <String, Object?>{
      'type': 'string',
      'maxLength': 1000,
    },
  },
};

const schemaDeleteEventReviewCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/delete_event_review_payload.schema.json',
  'title': 'DeleteEventReviewCallablePayload',
  'description': 'Callable payload accepted by deleteEventReview.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'reviewId',
  ],
  'properties': <String, Object?>{
    'reviewId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
  },
};

const schemaBlockUserCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/block_user_payload.schema.json',
  'title': 'BlockUserCallablePayload',
  'description': 'Callable payload accepted by blockUser.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'targetUserId',
  ],
  'properties': <String, Object?>{
    'targetUserId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'source': <String, Object?>{
      'type': 'string',
      'maxLength': 80,
    },
    'reasonCode': <String, Object?>{
      'type': 'string',
      'maxLength': 80,
    },
  },
};

const schemaUnblockUserCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/unblock_user_payload.schema.json',
  'title': 'UnblockUserCallablePayload',
  'description': 'Callable payload accepted by unblockUser.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'targetUserId',
  ],
  'properties': <String, Object?>{
    'targetUserId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
  },
};

const schemaReportUserCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/report_user_payload.schema.json',
  'title': 'ReportUserCallablePayload',
  'description': 'Callable payload accepted by reportUser.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'targetUserId',
  ],
  'properties': <String, Object?>{
    'targetUserId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'source': <String, Object?>{
      'type': 'string',
      'maxLength': 64,
    },
    'reasonCode': <String, Object?>{
      'type': 'string',
      'maxLength': 64,
    },
    'contextId': <String, Object?>{
      'type': 'string',
      'maxLength': 128,
    },
    'notes': <String, Object?>{
      'type': 'string',
      'maxLength': 2000,
    },
  },
};

const schemaVerifyRazorpayPaymentCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/verify_razorpay_payment_payload.schema.json',
  'title': 'VerifyRazorpayPaymentCallablePayload',
  'description': 'Callable payload accepted by verifyRazorpayPayment.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'paymentId',
    'orderId',
    'signature',
  ],
  'properties': <String, Object?>{
    'paymentId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'orderId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'signature': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 512,
    },
  },
};

const schemaRazorpayOrderCallableResponseSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callable_responses/razorpay_order_response.schema.json',
  'title': 'RazorpayOrderCallableResponse',
  'description': 'Callable response returned by createRazorpayOrder.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'orderId',
    'amount',
    'currency',
  ],
  'properties': <String, Object?>{
    'orderId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'amount': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 100000000,
    },
    'currency': <String, Object?>{
      'type': 'string',
      'pattern': '^[A-Z]{3}\$',
    },
  },
};

const schemaPlacesAutocompleteCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/places_autocomplete_payload.schema.json',
  'title': 'PlacesAutocompleteCallablePayload',
  'description': 'Callable payload accepted by placesAutocomplete.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'input',
  ],
  'properties': <String, Object?>{
    'input': <String, Object?>{
      'type': 'string',
      'minLength': 2,
      'maxLength': 120,
    },
    'sessionToken': <String, Object?>{
      'type': 'string',
      'minLength': 8,
      'maxLength': 128,
    },
    'countryIsoCode': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'IN',
        'NP',
        'AU',
        'US',
        'in',
        'np',
        'au',
        'us',
      ],
    },
    'latitude': <String, Object?>{
      'type': 'number',
      'minimum': -90,
      'maximum': 90,
    },
    'longitude': <String, Object?>{
      'type': 'number',
      'minimum': -180,
      'maximum': 180,
    },
  },
};

const schemaPlacesAutocompleteCallableResponseSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callable_responses/places_autocomplete_response.schema.json',
  'title': 'PlacesAutocompleteCallableResponse',
  'description': 'Callable response returned by placesAutocomplete.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'predictions',
  ],
  'properties': <String, Object?>{
    'predictions': <String, Object?>{
      'type': 'array',
      'maxItems': 10,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'placeId',
          'description',
          'mainText',
          'secondaryText',
        ],
        'properties': <String, Object?>{
          'placeId': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 256,
          },
          'description': <String, Object?>{
            'type': 'string',
            'maxLength': 1000,
          },
          'mainText': <String, Object?>{
            'type': 'string',
            'maxLength': 240,
          },
          'secondaryText': <String, Object?>{
            'type': 'string',
            'maxLength': 1000,
          },
        },
      },
    },
  },
};

const schemaPlaceDetailsCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/place_details_payload.schema.json',
  'title': 'PlaceDetailsCallablePayload',
  'description': 'Callable payload accepted by placeDetails.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'placeId',
  ],
  'properties': <String, Object?>{
    'placeId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 256,
    },
    'sessionToken': <String, Object?>{
      'type': 'string',
      'minLength': 8,
      'maxLength': 128,
    },
  },
};

const schemaPlaceDetailsCallableResponseSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callable_responses/place_details_response.schema.json',
  'title': 'PlaceDetailsCallableResponse',
  'description': 'Callable response returned by placeDetails.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'place',
  ],
  'properties': <String, Object?>{
    'place': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'placeId',
        'displayName',
        'formattedAddress',
        'latitude',
        'longitude',
      ],
      'properties': <String, Object?>{
        'placeId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 256,
        },
        'displayName': <String, Object?>{
          'type': 'string',
          'maxLength': 240,
        },
        'formattedAddress': <String, Object?>{
          'type': 'string',
          'maxLength': 1000,
        },
        'latitude': <String, Object?>{
          'type': 'number',
          'minimum': -90,
          'maximum': 90,
        },
        'longitude': <String, Object?>{
          'type': 'number',
          'minimum': -180,
          'maximum': 180,
        },
      },
    },
  },
};

const schemaCreateProfileDecisionClientWriteSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/client_writes/create_profile_decision.schema.json',
  'title': 'CreateProfileDecisionClientWrite',
  'description': 'Client-owned Firestore create operation for the current swipes/{userId}/outgoing/{targetId} storage path.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'path',
    'data',
  ],
  'properties': <String, Object?>{
    'path': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'userId',
        'targetId',
      ],
      'properties': <String, Object?>{
        'userId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'targetId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
      },
    },
    'data': <String, Object?>{
      'title': 'SwipeDocument',
      'description': 'Current storage contract for contextual profile decisions stored at swipes/{userId}/outgoing/{targetId}.',
      'type': 'object',
      'additionalProperties': false,
      'x-firestore-collection': 'swipes',
      'x-firestore-path': 'swipes/{userId}/outgoing/{targetId}',
      'x-document-id-field': 'targetId',
      'x-owner': 'authenticated swiper direct create; matching trigger consumes likes',
      'x-logical-name': 'profileDecision',
      'x-migration-phase': 'observe',
      'x-internal-demo-fields': <Object?>[
        'synthetic',
        'seedPrefix',
        'scenario',
        'demoOps',
        'demoOpsId',
        'demoOpsCommand',
      ],
      'required': <Object?>[
        'swiperId',
        'targetId',
        'eventId',
        'direction',
        'createdAt',
      ],
      'properties': <String, Object?>{
        'swiperId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'targetId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'eventId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'direction': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'like',
            'pass',
          ],
        },
        'reactionTargetId': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'minLength': 1,
          'maxLength': 80,
        },
        'reactionTargetType': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'enum': <Object?>[
            'heroPhoto',
            'photo',
            'profilePrompt',
            'compatibility',
            'running',
            'details',
            'lifestyle',
            null,
          ],
        },
        'reactionTargetLabel': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 80,
        },
        'reactionTargetPreview': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 240,
        },
        'comment': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 240,
        },
        'createdAt': <String, Object?>{
          'type': 'object',
          'description': 'Serialized Firestore Timestamp fixture shape.',
          'x-firestore-type': 'timestamp',
          'additionalProperties': false,
          'required': <Object?>[
            '_seconds',
            '_nanoseconds',
          ],
          'properties': <String, Object?>{
            '_seconds': <String, Object?>{
              'type': 'integer',
            },
            '_nanoseconds': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 999999999,
            },
          },
        },
        'synthetic': <String, Object?>{
          'type': 'boolean',
          'description': 'Internal demo seed marker used for cleanup and diagnostics.',
        },
        'seedPrefix': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 120,
          'description': 'Internal demo seed prefix used for cleanup and diagnostics.',
        },
        'scenario': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 120,
          'description': 'Internal demo seed scenario name used for cleanup and diagnostics.',
        },
        'demoOps': <String, Object?>{
          'type': 'boolean',
          'description': 'Internal demo-operations marker used for cleanup and diagnostics.',
        },
        'demoOpsId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
          'description': 'Internal demo-operations id used for cleanup and diagnostics.',
        },
        'demoOpsCommand': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 80,
          'description': 'Internal demo-operations command name used for cleanup and diagnostics.',
        },
      },
    },
  },
  'x-firestore-operation': 'create',
  'x-firestore-path': 'swipes/{userId}/outgoing/{targetId}',
  'x-logical-name': 'profileDecision',
  'x-migration-phase': 'observe',
  'x-owner': 'authenticated profile viewer direct create; matching trigger consumes likes',
};

const schemaCreateChatMessageClientWriteSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/client_writes/create_chat_message.schema.json',
  'title': 'CreateChatMessageClientWrite',
  'description': 'Client-owned Firestore create operation for matches/{matchId}/messages/{messageId}.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'path',
    'data',
  ],
  'properties': <String, Object?>{
    'path': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'matchId',
        'messageId',
      ],
      'properties': <String, Object?>{
        'matchId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'messageId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
      },
    },
    'data': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'senderId',
        'text',
        'sentAt',
      ],
      'properties': <String, Object?>{
        'senderId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'text': <String, Object?>{
          'type': 'string',
          'maxLength': 2000,
        },
        'imageUrl': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'string',
              'format': 'uri',
              'maxLength': 2048,
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'sentAt': <String, Object?>{
          'type': 'object',
          'description': 'Serialized Firestore Timestamp fixture shape.',
          'x-firestore-type': 'timestamp',
          'additionalProperties': false,
          'required': <Object?>[
            '_seconds',
            '_nanoseconds',
          ],
          'properties': <String, Object?>{
            '_seconds': <String, Object?>{
              'type': 'integer',
            },
            '_nanoseconds': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 999999999,
            },
          },
        },
      },
      'anyOf': <Object?>[
        <String, Object?>{
          'properties': <String, Object?>{
            'text': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 2000,
            },
          },
        },
        <String, Object?>{
          'required': <Object?>[
            'imageUrl',
          ],
          'properties': <String, Object?>{
            'imageUrl': <String, Object?>{
              'type': 'string',
              'format': 'uri',
              'maxLength': 2048,
            },
          },
        },
      ],
    },
  },
  'x-firestore-operation': 'create',
  'x-firestore-path': 'matches/{matchId}/messages/{messageId}',
  'x-owner': 'active match participant direct create; moderation and preview fan-out are trigger-owned',
};

const schemaCreateSavedEventClientWriteSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/client_writes/create_saved_event.schema.json',
  'title': 'CreateSavedEventClientWrite',
  'description': 'Client-owned Firestore create operation for savedEvents/{savedEventId}.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'path',
    'data',
  ],
  'properties': <String, Object?>{
    'path': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'savedEventId',
      ],
      'properties': <String, Object?>{
        'savedEventId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
      },
    },
    'data': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'uid',
        'eventId',
        'savedAt',
      ],
      'properties': <String, Object?>{
        'uid': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'eventId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'savedAt': <String, Object?>{
          'type': 'object',
          'description': 'Serialized Firestore Timestamp fixture shape.',
          'x-firestore-type': 'timestamp',
          'additionalProperties': false,
          'required': <Object?>[
            '_seconds',
            '_nanoseconds',
          ],
          'properties': <String, Object?>{
            '_seconds': <String, Object?>{
              'type': 'integer',
            },
            '_nanoseconds': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 999999999,
            },
          },
        },
      },
    },
  },
  'x-firestore-operation': 'create',
  'x-firestore-path': 'savedEvents/{savedEventId}',
  'x-owner': 'authenticated owner direct create',
};

const schemaDeleteSavedEventClientWriteSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/client_writes/delete_saved_event.schema.json',
  'title': 'DeleteSavedEventClientWrite',
  'description': 'Client-owned Firestore delete operation for savedEvents/{savedEventId}.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'path',
  ],
  'properties': <String, Object?>{
    'path': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'savedEventId',
      ],
      'properties': <String, Object?>{
        'savedEventId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
      },
    },
  },
  'x-firestore-operation': 'delete',
  'x-firestore-path': 'savedEvents/{savedEventId}',
  'x-owner': 'authenticated owner direct delete',
};

const schemaMarkNotificationReadClientWriteSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/client_writes/mark_notification_read.schema.json',
  'title': 'MarkNotificationReadClientWrite',
  'description': 'Client-owned Firestore update operation for notifications/{uid}/items/{notificationId}.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'path',
    'data',
  ],
  'properties': <String, Object?>{
    'path': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'uid',
        'notificationId',
      ],
      'properties': <String, Object?>{
        'uid': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'notificationId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
      },
    },
    'data': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'readAt',
      ],
      'properties': <String, Object?>{
        'readAt': <String, Object?>{
          'type': 'object',
          'description': 'Serialized Firestore Timestamp fixture shape.',
          'x-firestore-type': 'timestamp',
          'additionalProperties': false,
          'required': <Object?>[
            '_seconds',
            '_nanoseconds',
          ],
          'properties': <String, Object?>{
            '_seconds': <String, Object?>{
              'type': 'integer',
            },
            '_nanoseconds': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 999999999,
            },
          },
        },
      },
    },
  },
  'x-firestore-operation': 'update',
  'x-firestore-path': 'notifications/{uid}/items/{notificationId}',
  'x-owner': 'notification owner direct read-state update',
};

const schemaResetMatchUnreadCountClientWriteSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/client_writes/reset_match_unread_count.schema.json',
  'title': 'ResetMatchUnreadCountClientWrite',
  'description': 'Client-owned Firestore update operation for a participant resetting only their own unread counter on matches/{matchId}.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'path',
    'data',
  ],
  'properties': <String, Object?>{
    'path': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'matchId',
      ],
      'properties': <String, Object?>{
        'matchId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
      },
    },
    'data': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'unreadCounts',
      ],
      'properties': <String, Object?>{
        'unreadCounts': <String, Object?>{
          'type': 'object',
          'additionalProperties': <String, Object?>{
            'type': 'integer',
            'minimum': 0,
          },
          'minProperties': 1,
          'maxProperties': 1,
        },
      },
    },
  },
  'x-firestore-operation': 'update',
  'x-firestore-path': 'matches/{matchId}',
  'x-owner': 'active match participant direct unread reset',
};

const schemaContractDefinitions = <SchemaContractDefinition>[
  SchemaContractDefinition(
    name: 'ProfilePromptAnswer',
    source: 'embedded/profile_prompt_answer.schema.json',
    schema: schemaProfilePromptAnswerSchema,
  ),
  SchemaContractDefinition(
    name: 'PhotoPromptAnswer',
    source: 'embedded/photo_prompt_answer.schema.json',
    schema: schemaPhotoPromptAnswerSchema,
  ),
  SchemaContractDefinition(
    name: 'ProfilePhoto',
    source: 'embedded/profile_photo.schema.json',
    schema: schemaProfilePhotoSchema,
  ),
  SchemaContractDefinition(
    name: 'ConfigCitiesDocument',
    source: 'firestore/config_cities.schema.json',
    schema: schemaConfigCitiesDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'OnboardingDraftDocument',
    source: 'firestore/onboarding_drafts.schema.json',
    schema: schemaOnboardingDraftDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'UserProfileDocument',
    source: 'firestore/users.schema.json',
    schema: schemaUserProfileDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'PublicProfileDocument',
    source: 'firestore/public_profiles.schema.json',
    schema: schemaPublicProfileDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'ClubDocument',
    source: 'firestore/clubs.schema.json',
    schema: schemaClubDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'ClubMembershipDocument',
    source: 'firestore/club_memberships.schema.json',
    schema: schemaClubMembershipDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'ClubHostClaimDocument',
    source: 'firestore/club_host_claims.schema.json',
    schema: schemaClubHostClaimDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'EventDocument',
    source: 'firestore/events.schema.json',
    schema: schemaEventDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'EventPrivateAccessDocument',
    source: 'firestore/event_private_access.schema.json',
    schema: schemaEventPrivateAccessDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'EventParticipationDocument',
    source: 'firestore/event_participations.schema.json',
    schema: schemaEventParticipationDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'EventSuccessPlanDocument',
    source: 'firestore/event_success_plans.schema.json',
    schema: schemaEventSuccessPlanDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'EventSuccessFeedbackDocument',
    source: 'firestore/event_success_feedback.schema.json',
    schema: schemaEventSuccessFeedbackDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'EventSuccessPreferenceDocument',
    source: 'firestore/event_success_preferences.schema.json',
    schema: schemaEventSuccessPreferenceDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'EventSuccessCompatibilityResponseDocument',
    source: 'firestore/event_success_compatibility_responses.schema.json',
    schema: schemaEventSuccessCompatibilityResponseDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'EventSuccessWingmanRequestDocument',
    source: 'firestore/event_success_wingman_requests.schema.json',
    schema: schemaEventSuccessWingmanRequestDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'EventSuccessArrivalMissionDocument',
    source: 'firestore/event_success_arrival_missions.schema.json',
    schema: schemaEventSuccessArrivalMissionDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'EventSuccessAssignmentDocument',
    source: 'firestore/event_success_assignments.schema.json',
    schema: schemaEventSuccessAssignmentDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'EventSuccessScorecardDocument',
    source: 'firestore/event_success_scorecards.schema.json',
    schema: schemaEventSuccessScorecardDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'EventSafetyReportDocument',
    source: 'firestore/event_safety_reports.schema.json',
    schema: schemaEventSafetyReportDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'ClubScheduleLockDocument',
    source: 'firestore/club_schedule_locks.schema.json',
    schema: schemaClubScheduleLockDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'UserEventScheduleLockDocument',
    source: 'firestore/user_event_schedule_locks.schema.json',
    schema: schemaUserEventScheduleLockDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'SavedEventDocument',
    source: 'firestore/saved_events.schema.json',
    schema: schemaSavedEventDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'PaymentDocument',
    source: 'firestore/payments.schema.json',
    schema: schemaPaymentDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'SwipeDocument',
    source: 'firestore/swipes.schema.json',
    schema: schemaSwipeDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'MatchDocument',
    source: 'firestore/matches.schema.json',
    schema: schemaMatchDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'ChatMessageDocument',
    source: 'firestore/chat_messages.schema.json',
    schema: schemaChatMessageDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'ActivityNotificationDocument',
    source: 'firestore/activity_notifications.schema.json',
    schema: schemaActivityNotificationDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'ReviewDocument',
    source: 'firestore/reviews.schema.json',
    schema: schemaReviewDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'BlockDocument',
    source: 'firestore/blocks.schema.json',
    schema: schemaBlockDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'ReportDocument',
    source: 'firestore/reports.schema.json',
    schema: schemaReportDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'ModerationFlagDocument',
    source: 'firestore/moderation_flags.schema.json',
    schema: schemaModerationFlagDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'DeletedUserTombstoneDocument',
    source: 'firestore/deleted_users.schema.json',
    schema: schemaDeletedUserTombstoneDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'RateLimitDocument',
    source: 'firestore/rate_limits.schema.json',
    schema: schemaRateLimitDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'FunctionEventReceiptDocument',
    source: 'firestore/function_event_receipts.schema.json',
    schema: schemaFunctionEventReceiptDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'SeedEventManifestDocument',
    source: 'firestore/seed_events.schema.json',
    schema: schemaSeedEventManifestDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'UpdateUserProfileCallablePayload',
    source: 'patches/update_user_profile.schema.json',
    schema: schemaUpdateUserProfileCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'CreateClubCallablePayload',
    source: 'callables/create_club_payload.schema.json',
    schema: schemaCreateClubCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'CreateClubCallableResponse',
    source: 'callable_responses/create_club_response.schema.json',
    schema: schemaCreateClubCallableResponseSchema,
  ),
  SchemaContractDefinition(
    name: 'UpdateClubCallablePayload',
    source: 'callables/update_club_payload.schema.json',
    schema: schemaUpdateClubCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'AddClubHostCallablePayload',
    source: 'callables/add_club_host_payload.schema.json',
    schema: schemaAddClubHostCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'RemoveClubHostCallablePayload',
    source: 'callables/remove_club_host_payload.schema.json',
    schema: schemaRemoveClubHostCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'ArchiveClubCallablePayload',
    source: 'callables/archive_club_payload.schema.json',
    schema: schemaArchiveClubCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'DeleteClubCallablePayload',
    source: 'callables/delete_club_payload.schema.json',
    schema: schemaDeleteClubCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'ClubMembershipCallablePayload',
    source: 'callables/club_membership_payload.schema.json',
    schema: schemaClubMembershipCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'SetClubNotificationPreferenceCallablePayload',
    source: 'callables/set_club_notification_preference_payload.schema.json',
    schema: schemaSetClubNotificationPreferenceCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'CreateEventCallablePayload',
    source: 'callables/create_event_payload.schema.json',
    schema: schemaCreateEventCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'UpdateEventCallablePayload',
    source: 'callables/update_event_payload.schema.json',
    schema: schemaUpdateEventCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'CancelEventCallablePayload',
    source: 'callables/cancel_event_payload.schema.json',
    schema: schemaCancelEventCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'DeleteEventCallablePayload',
    source: 'callables/delete_event_payload.schema.json',
    schema: schemaDeleteEventCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'EventIdCallablePayload',
    source: 'callables/event_id_payload.schema.json',
    schema: schemaEventIdCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'MarkEventAttendanceCallablePayload',
    source: 'callables/mark_event_attendance_payload.schema.json',
    schema: schemaMarkEventAttendanceCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'OverrideEventSuccessRotationsCallablePayload',
    source: 'callables/override_event_success_rotations_payload.schema.json',
    schema: schemaOverrideEventSuccessRotationsCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'SubmitEventSuccessWingmanRequestCallablePayload',
    source: 'callables/submit_event_success_wingman_request_payload.schema.json',
    schema: schemaSubmitEventSuccessWingmanRequestCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'StartEventSuccessFirstHelloMissionCallablePayload',
    source: 'callables/start_event_success_first_hello_mission_payload.schema.json',
    schema: schemaStartEventSuccessFirstHelloMissionCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'CompleteEventSuccessFirstHelloMissionCallablePayload',
    source: 'callables/complete_event_success_first_hello_mission_payload.schema.json',
    schema: schemaCompleteEventSuccessFirstHelloMissionCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'MarkEventAttendanceCallableResponse',
    source: 'callable_responses/mark_event_attendance_response.schema.json',
    schema: schemaMarkEventAttendanceCallableResponseSchema,
  ),
  SchemaContractDefinition(
    name: 'SelfCheckInAttendanceCallablePayload',
    source: 'callables/self_check_in_attendance_payload.schema.json',
    schema: schemaSelfCheckInAttendanceCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'CreateEventReviewCallablePayload',
    source: 'callables/create_event_review_payload.schema.json',
    schema: schemaCreateEventReviewCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'UpdateEventReviewCallablePayload',
    source: 'callables/update_event_review_payload.schema.json',
    schema: schemaUpdateEventReviewCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'DeleteEventReviewCallablePayload',
    source: 'callables/delete_event_review_payload.schema.json',
    schema: schemaDeleteEventReviewCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'BlockUserCallablePayload',
    source: 'callables/block_user_payload.schema.json',
    schema: schemaBlockUserCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'UnblockUserCallablePayload',
    source: 'callables/unblock_user_payload.schema.json',
    schema: schemaUnblockUserCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'ReportUserCallablePayload',
    source: 'callables/report_user_payload.schema.json',
    schema: schemaReportUserCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'VerifyRazorpayPaymentCallablePayload',
    source: 'callables/verify_razorpay_payment_payload.schema.json',
    schema: schemaVerifyRazorpayPaymentCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'RazorpayOrderCallableResponse',
    source: 'callable_responses/razorpay_order_response.schema.json',
    schema: schemaRazorpayOrderCallableResponseSchema,
  ),
  SchemaContractDefinition(
    name: 'PlacesAutocompleteCallablePayload',
    source: 'callables/places_autocomplete_payload.schema.json',
    schema: schemaPlacesAutocompleteCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'PlacesAutocompleteCallableResponse',
    source: 'callable_responses/places_autocomplete_response.schema.json',
    schema: schemaPlacesAutocompleteCallableResponseSchema,
  ),
  SchemaContractDefinition(
    name: 'PlaceDetailsCallablePayload',
    source: 'callables/place_details_payload.schema.json',
    schema: schemaPlaceDetailsCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'PlaceDetailsCallableResponse',
    source: 'callable_responses/place_details_response.schema.json',
    schema: schemaPlaceDetailsCallableResponseSchema,
  ),
  SchemaContractDefinition(
    name: 'CreateProfileDecisionClientWrite',
    source: 'client_writes/create_profile_decision.schema.json',
    schema: schemaCreateProfileDecisionClientWriteSchema,
  ),
  SchemaContractDefinition(
    name: 'CreateChatMessageClientWrite',
    source: 'client_writes/create_chat_message.schema.json',
    schema: schemaCreateChatMessageClientWriteSchema,
  ),
  SchemaContractDefinition(
    name: 'CreateSavedEventClientWrite',
    source: 'client_writes/create_saved_event.schema.json',
    schema: schemaCreateSavedEventClientWriteSchema,
  ),
  SchemaContractDefinition(
    name: 'DeleteSavedEventClientWrite',
    source: 'client_writes/delete_saved_event.schema.json',
    schema: schemaDeleteSavedEventClientWriteSchema,
  ),
  SchemaContractDefinition(
    name: 'MarkNotificationReadClientWrite',
    source: 'client_writes/mark_notification_read.schema.json',
    schema: schemaMarkNotificationReadClientWriteSchema,
  ),
  SchemaContractDefinition(
    name: 'ResetMatchUnreadCountClientWrite',
    source: 'client_writes/reset_match_unread_count.schema.json',
    schema: schemaResetMatchUnreadCountClientWriteSchema,
  ),
];

const schemaContractsByName = <String, Map<String, Object?>>{
  'ProfilePromptAnswer': schemaProfilePromptAnswerSchema,
  'PhotoPromptAnswer': schemaPhotoPromptAnswerSchema,
  'ProfilePhoto': schemaProfilePhotoSchema,
  'ConfigCitiesDocument': schemaConfigCitiesDocumentSchema,
  'OnboardingDraftDocument': schemaOnboardingDraftDocumentSchema,
  'UserProfileDocument': schemaUserProfileDocumentSchema,
  'PublicProfileDocument': schemaPublicProfileDocumentSchema,
  'ClubDocument': schemaClubDocumentSchema,
  'ClubMembershipDocument': schemaClubMembershipDocumentSchema,
  'ClubHostClaimDocument': schemaClubHostClaimDocumentSchema,
  'EventDocument': schemaEventDocumentSchema,
  'EventPrivateAccessDocument': schemaEventPrivateAccessDocumentSchema,
  'EventParticipationDocument': schemaEventParticipationDocumentSchema,
  'EventSuccessPlanDocument': schemaEventSuccessPlanDocumentSchema,
  'EventSuccessFeedbackDocument': schemaEventSuccessFeedbackDocumentSchema,
  'EventSuccessPreferenceDocument': schemaEventSuccessPreferenceDocumentSchema,
  'EventSuccessCompatibilityResponseDocument': schemaEventSuccessCompatibilityResponseDocumentSchema,
  'EventSuccessWingmanRequestDocument': schemaEventSuccessWingmanRequestDocumentSchema,
  'EventSuccessArrivalMissionDocument': schemaEventSuccessArrivalMissionDocumentSchema,
  'EventSuccessAssignmentDocument': schemaEventSuccessAssignmentDocumentSchema,
  'EventSuccessScorecardDocument': schemaEventSuccessScorecardDocumentSchema,
  'EventSafetyReportDocument': schemaEventSafetyReportDocumentSchema,
  'ClubScheduleLockDocument': schemaClubScheduleLockDocumentSchema,
  'UserEventScheduleLockDocument': schemaUserEventScheduleLockDocumentSchema,
  'SavedEventDocument': schemaSavedEventDocumentSchema,
  'PaymentDocument': schemaPaymentDocumentSchema,
  'SwipeDocument': schemaSwipeDocumentSchema,
  'MatchDocument': schemaMatchDocumentSchema,
  'ChatMessageDocument': schemaChatMessageDocumentSchema,
  'ActivityNotificationDocument': schemaActivityNotificationDocumentSchema,
  'ReviewDocument': schemaReviewDocumentSchema,
  'BlockDocument': schemaBlockDocumentSchema,
  'ReportDocument': schemaReportDocumentSchema,
  'ModerationFlagDocument': schemaModerationFlagDocumentSchema,
  'DeletedUserTombstoneDocument': schemaDeletedUserTombstoneDocumentSchema,
  'RateLimitDocument': schemaRateLimitDocumentSchema,
  'FunctionEventReceiptDocument': schemaFunctionEventReceiptDocumentSchema,
  'SeedEventManifestDocument': schemaSeedEventManifestDocumentSchema,
  'UpdateUserProfileCallablePayload': schemaUpdateUserProfileCallablePayloadSchema,
  'CreateClubCallablePayload': schemaCreateClubCallablePayloadSchema,
  'CreateClubCallableResponse': schemaCreateClubCallableResponseSchema,
  'UpdateClubCallablePayload': schemaUpdateClubCallablePayloadSchema,
  'AddClubHostCallablePayload': schemaAddClubHostCallablePayloadSchema,
  'RemoveClubHostCallablePayload': schemaRemoveClubHostCallablePayloadSchema,
  'ArchiveClubCallablePayload': schemaArchiveClubCallablePayloadSchema,
  'DeleteClubCallablePayload': schemaDeleteClubCallablePayloadSchema,
  'ClubMembershipCallablePayload': schemaClubMembershipCallablePayloadSchema,
  'SetClubNotificationPreferenceCallablePayload': schemaSetClubNotificationPreferenceCallablePayloadSchema,
  'CreateEventCallablePayload': schemaCreateEventCallablePayloadSchema,
  'UpdateEventCallablePayload': schemaUpdateEventCallablePayloadSchema,
  'CancelEventCallablePayload': schemaCancelEventCallablePayloadSchema,
  'DeleteEventCallablePayload': schemaDeleteEventCallablePayloadSchema,
  'EventIdCallablePayload': schemaEventIdCallablePayloadSchema,
  'MarkEventAttendanceCallablePayload': schemaMarkEventAttendanceCallablePayloadSchema,
  'OverrideEventSuccessRotationsCallablePayload': schemaOverrideEventSuccessRotationsCallablePayloadSchema,
  'SubmitEventSuccessWingmanRequestCallablePayload': schemaSubmitEventSuccessWingmanRequestCallablePayloadSchema,
  'StartEventSuccessFirstHelloMissionCallablePayload': schemaStartEventSuccessFirstHelloMissionCallablePayloadSchema,
  'CompleteEventSuccessFirstHelloMissionCallablePayload': schemaCompleteEventSuccessFirstHelloMissionCallablePayloadSchema,
  'MarkEventAttendanceCallableResponse': schemaMarkEventAttendanceCallableResponseSchema,
  'SelfCheckInAttendanceCallablePayload': schemaSelfCheckInAttendanceCallablePayloadSchema,
  'CreateEventReviewCallablePayload': schemaCreateEventReviewCallablePayloadSchema,
  'UpdateEventReviewCallablePayload': schemaUpdateEventReviewCallablePayloadSchema,
  'DeleteEventReviewCallablePayload': schemaDeleteEventReviewCallablePayloadSchema,
  'BlockUserCallablePayload': schemaBlockUserCallablePayloadSchema,
  'UnblockUserCallablePayload': schemaUnblockUserCallablePayloadSchema,
  'ReportUserCallablePayload': schemaReportUserCallablePayloadSchema,
  'VerifyRazorpayPaymentCallablePayload': schemaVerifyRazorpayPaymentCallablePayloadSchema,
  'RazorpayOrderCallableResponse': schemaRazorpayOrderCallableResponseSchema,
  'PlacesAutocompleteCallablePayload': schemaPlacesAutocompleteCallablePayloadSchema,
  'PlacesAutocompleteCallableResponse': schemaPlacesAutocompleteCallableResponseSchema,
  'PlaceDetailsCallablePayload': schemaPlaceDetailsCallablePayloadSchema,
  'PlaceDetailsCallableResponse': schemaPlaceDetailsCallableResponseSchema,
  'CreateProfileDecisionClientWrite': schemaCreateProfileDecisionClientWriteSchema,
  'CreateChatMessageClientWrite': schemaCreateChatMessageClientWriteSchema,
  'CreateSavedEventClientWrite': schemaCreateSavedEventClientWriteSchema,
  'DeleteSavedEventClientWrite': schemaDeleteSavedEventClientWriteSchema,
  'MarkNotificationReadClientWrite': schemaMarkNotificationReadClientWriteSchema,
  'ResetMatchUnreadCountClientWrite': schemaResetMatchUnreadCountClientWriteSchema,
};

const schemaContractsBySource = <String, Map<String, Object?>>{
  'embedded/profile_prompt_answer.schema.json': schemaProfilePromptAnswerSchema,
  'embedded/photo_prompt_answer.schema.json': schemaPhotoPromptAnswerSchema,
  'embedded/profile_photo.schema.json': schemaProfilePhotoSchema,
  'firestore/config_cities.schema.json': schemaConfigCitiesDocumentSchema,
  'firestore/onboarding_drafts.schema.json': schemaOnboardingDraftDocumentSchema,
  'firestore/users.schema.json': schemaUserProfileDocumentSchema,
  'firestore/public_profiles.schema.json': schemaPublicProfileDocumentSchema,
  'firestore/clubs.schema.json': schemaClubDocumentSchema,
  'firestore/club_memberships.schema.json': schemaClubMembershipDocumentSchema,
  'firestore/club_host_claims.schema.json': schemaClubHostClaimDocumentSchema,
  'firestore/events.schema.json': schemaEventDocumentSchema,
  'firestore/event_private_access.schema.json': schemaEventPrivateAccessDocumentSchema,
  'firestore/event_participations.schema.json': schemaEventParticipationDocumentSchema,
  'firestore/event_success_plans.schema.json': schemaEventSuccessPlanDocumentSchema,
  'firestore/event_success_feedback.schema.json': schemaEventSuccessFeedbackDocumentSchema,
  'firestore/event_success_preferences.schema.json': schemaEventSuccessPreferenceDocumentSchema,
  'firestore/event_success_compatibility_responses.schema.json': schemaEventSuccessCompatibilityResponseDocumentSchema,
  'firestore/event_success_wingman_requests.schema.json': schemaEventSuccessWingmanRequestDocumentSchema,
  'firestore/event_success_arrival_missions.schema.json': schemaEventSuccessArrivalMissionDocumentSchema,
  'firestore/event_success_assignments.schema.json': schemaEventSuccessAssignmentDocumentSchema,
  'firestore/event_success_scorecards.schema.json': schemaEventSuccessScorecardDocumentSchema,
  'firestore/event_safety_reports.schema.json': schemaEventSafetyReportDocumentSchema,
  'firestore/club_schedule_locks.schema.json': schemaClubScheduleLockDocumentSchema,
  'firestore/user_event_schedule_locks.schema.json': schemaUserEventScheduleLockDocumentSchema,
  'firestore/saved_events.schema.json': schemaSavedEventDocumentSchema,
  'firestore/payments.schema.json': schemaPaymentDocumentSchema,
  'firestore/swipes.schema.json': schemaSwipeDocumentSchema,
  'firestore/matches.schema.json': schemaMatchDocumentSchema,
  'firestore/chat_messages.schema.json': schemaChatMessageDocumentSchema,
  'firestore/activity_notifications.schema.json': schemaActivityNotificationDocumentSchema,
  'firestore/reviews.schema.json': schemaReviewDocumentSchema,
  'firestore/blocks.schema.json': schemaBlockDocumentSchema,
  'firestore/reports.schema.json': schemaReportDocumentSchema,
  'firestore/moderation_flags.schema.json': schemaModerationFlagDocumentSchema,
  'firestore/deleted_users.schema.json': schemaDeletedUserTombstoneDocumentSchema,
  'firestore/rate_limits.schema.json': schemaRateLimitDocumentSchema,
  'firestore/function_event_receipts.schema.json': schemaFunctionEventReceiptDocumentSchema,
  'firestore/seed_events.schema.json': schemaSeedEventManifestDocumentSchema,
  'patches/update_user_profile.schema.json': schemaUpdateUserProfileCallablePayloadSchema,
  'callables/create_club_payload.schema.json': schemaCreateClubCallablePayloadSchema,
  'callable_responses/create_club_response.schema.json': schemaCreateClubCallableResponseSchema,
  'callables/update_club_payload.schema.json': schemaUpdateClubCallablePayloadSchema,
  'callables/add_club_host_payload.schema.json': schemaAddClubHostCallablePayloadSchema,
  'callables/remove_club_host_payload.schema.json': schemaRemoveClubHostCallablePayloadSchema,
  'callables/archive_club_payload.schema.json': schemaArchiveClubCallablePayloadSchema,
  'callables/delete_club_payload.schema.json': schemaDeleteClubCallablePayloadSchema,
  'callables/club_membership_payload.schema.json': schemaClubMembershipCallablePayloadSchema,
  'callables/set_club_notification_preference_payload.schema.json': schemaSetClubNotificationPreferenceCallablePayloadSchema,
  'callables/create_event_payload.schema.json': schemaCreateEventCallablePayloadSchema,
  'callables/update_event_payload.schema.json': schemaUpdateEventCallablePayloadSchema,
  'callables/cancel_event_payload.schema.json': schemaCancelEventCallablePayloadSchema,
  'callables/delete_event_payload.schema.json': schemaDeleteEventCallablePayloadSchema,
  'callables/event_id_payload.schema.json': schemaEventIdCallablePayloadSchema,
  'callables/mark_event_attendance_payload.schema.json': schemaMarkEventAttendanceCallablePayloadSchema,
  'callables/override_event_success_rotations_payload.schema.json': schemaOverrideEventSuccessRotationsCallablePayloadSchema,
  'callables/submit_event_success_wingman_request_payload.schema.json': schemaSubmitEventSuccessWingmanRequestCallablePayloadSchema,
  'callables/start_event_success_first_hello_mission_payload.schema.json': schemaStartEventSuccessFirstHelloMissionCallablePayloadSchema,
  'callables/complete_event_success_first_hello_mission_payload.schema.json': schemaCompleteEventSuccessFirstHelloMissionCallablePayloadSchema,
  'callable_responses/mark_event_attendance_response.schema.json': schemaMarkEventAttendanceCallableResponseSchema,
  'callables/self_check_in_attendance_payload.schema.json': schemaSelfCheckInAttendanceCallablePayloadSchema,
  'callables/create_event_review_payload.schema.json': schemaCreateEventReviewCallablePayloadSchema,
  'callables/update_event_review_payload.schema.json': schemaUpdateEventReviewCallablePayloadSchema,
  'callables/delete_event_review_payload.schema.json': schemaDeleteEventReviewCallablePayloadSchema,
  'callables/block_user_payload.schema.json': schemaBlockUserCallablePayloadSchema,
  'callables/unblock_user_payload.schema.json': schemaUnblockUserCallablePayloadSchema,
  'callables/report_user_payload.schema.json': schemaReportUserCallablePayloadSchema,
  'callables/verify_razorpay_payment_payload.schema.json': schemaVerifyRazorpayPaymentCallablePayloadSchema,
  'callable_responses/razorpay_order_response.schema.json': schemaRazorpayOrderCallableResponseSchema,
  'callables/places_autocomplete_payload.schema.json': schemaPlacesAutocompleteCallablePayloadSchema,
  'callable_responses/places_autocomplete_response.schema.json': schemaPlacesAutocompleteCallableResponseSchema,
  'callables/place_details_payload.schema.json': schemaPlaceDetailsCallablePayloadSchema,
  'callable_responses/place_details_response.schema.json': schemaPlaceDetailsCallableResponseSchema,
  'client_writes/create_profile_decision.schema.json': schemaCreateProfileDecisionClientWriteSchema,
  'client_writes/create_chat_message.schema.json': schemaCreateChatMessageClientWriteSchema,
  'client_writes/create_saved_event.schema.json': schemaCreateSavedEventClientWriteSchema,
  'client_writes/delete_saved_event.schema.json': schemaDeleteSavedEventClientWriteSchema,
  'client_writes/mark_notification_read.schema.json': schemaMarkNotificationReadClientWriteSchema,
  'client_writes/reset_match_unread_count.schema.json': schemaResetMatchUnreadCountClientWriteSchema,
};
