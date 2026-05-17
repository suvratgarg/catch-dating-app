// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/generate_schema_contracts.mjs
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
  'description': 'One optional caption prompt for a profile photo slot.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'photoIndex',
    'promptId',
    'prompt',
    'caption',
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
          'description': 'One optional caption prompt for a profile photo slot.',
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'photoIndex',
            'promptId',
            'prompt',
            'caption',
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
    'prefsNewCatches',
    'prefsMessages',
    'prefsRunReminders',
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
        'description': 'One optional caption prompt for a profile photo slot.',
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'photoIndex',
          'promptId',
          'prompt',
          'caption',
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
                'description': 'One optional caption prompt for a profile photo slot.',
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'photoIndex',
                  'promptId',
                  'prompt',
                  'caption',
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
    'prefsNewCatches': <String, Object?>{
      'type': 'boolean',
    },
    'prefsMessages': <String, Object?>{
      'type': 'boolean',
    },
    'prefsRunReminders': <String, Object?>{
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
        'description': 'One optional caption prompt for a profile photo slot.',
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'photoIndex',
          'promptId',
          'prompt',
          'caption',
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
                'description': 'One optional caption prompt for a profile photo slot.',
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'photoIndex',
                  'promptId',
                  'prompt',
                  'caption',
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

const schemaRunClubDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/run_clubs.schema.json',
  'title': 'RunClubDocument',
  'description': 'Canonical run club document stored at runClubs/{clubId}. The club id is the document id and is not stored in document data.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'runClubs',
  'x-firestore-path': 'runClubs/{clubId}',
  'x-document-id-field': 'id',
  'x-owner': 'create/update/archive/delete run-club callables; aggregate projections are trigger-owned',
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
    'createdAt',
    'imageUrl',
    'tags',
    'memberCount',
    'rating',
    'reviewCount',
    'nextRunAt',
    'nextRunLabel',
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
    'nextRunAt': <String, Object?>{
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
    'nextRunLabel': <String, Object?>{
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

const schemaRunClubMembershipDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/run_club_memberships.schema.json',
  'title': 'RunClubMembershipDocument',
  'description': 'Canonical run club membership edge stored at runClubMemberships/{membershipId}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'runClubMemberships',
  'x-firestore-path': 'runClubMemberships/{membershipId}',
  'x-document-id-field': 'id',
  'x-owner': 'run-club membership callables; parent member count is trigger-owned',
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

const schemaRunClubHostClaimDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/run_club_host_claims.schema.json',
  'title': 'RunClubHostClaimDocument',
  'description': 'Server-owned singleton claim stored at runClubHostClaims/{uid} to enforce one hosted club per user.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'runClubHostClaims',
  'x-firestore-path': 'runClubHostClaims/{uid}',
  'x-document-id-field': 'uid',
  'x-owner': 'createRunClub callable',
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

const schemaRunDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/runs.schema.json',
  'title': 'RunDocument',
  'description': 'Canonical run document stored at runs/{runId}. The run id is the document id and is not stored in document data.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'runs',
  'x-firestore-path': 'runs/{runId}',
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
    'runClubId',
    'startTime',
    'endTime',
    'meetingPoint',
    'startingPointLat',
    'startingPointLng',
    'locationDetails',
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
  ],
  'properties': <String, Object?>{
    'runClubId': <String, Object?>{
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
      'exclusiveMinimum': 0,
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

const schemaRunParticipationDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/run_participations.schema.json',
  'title': 'RunParticipationDocument',
  'description': 'Canonical run roster edge stored at runParticipations/{participationId}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'runParticipations',
  'x-firestore-path': 'runParticipations/{participationId}',
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
    'runId',
    'runClubId',
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
    'runId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'runClubId': <String, Object?>{
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

const schemaRunClubScheduleLockDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/run_club_schedule_locks.schema.json',
  'title': 'RunClubScheduleLockDocument',
  'description': 'Server-owned time-slot claim stored at runClubScheduleLocks/{clubId_slot}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'runClubScheduleLocks',
  'x-firestore-path': 'runClubScheduleLocks/{lockId}',
  'x-document-id-field': 'lockId',
  'x-owner': 'run schedule conflict callables',
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
    'runId',
    'runClubId',
    'startTimeMillis',
    'endTimeMillis',
  ],
  'properties': <String, Object?>{
    'ownerType': <String, Object?>{
      'type': 'string',
      'const': 'runClub',
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
    'runId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'runClubId': <String, Object?>{
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

const schemaUserRunScheduleLockDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/user_run_schedule_locks.schema.json',
  'title': 'UserRunScheduleLockDocument',
  'description': 'Server-owned time-slot claim stored at userRunScheduleLocks/{uid_slot}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'userRunScheduleLocks',
  'x-firestore-path': 'userRunScheduleLocks/{lockId}',
  'x-document-id-field': 'lockId',
  'x-owner': 'run signup and waitlist callables',
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
    'runId',
    'runClubId',
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
    'runId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'runClubId': <String, Object?>{
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

const schemaSavedRunDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/saved_runs.schema.json',
  'title': 'SavedRunDocument',
  'description': 'Canonical saved-run edge stored at savedRuns/{savedRunId}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'savedRuns',
  'x-firestore-path': 'savedRuns/{savedRunId}',
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
    'runId',
    'savedAt',
  ],
  'properties': <String, Object?>{
    'uid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'runId': <String, Object?>{
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
    'runId',
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
    'runId': <String, Object?>{
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
    'runId',
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
    'runId': <String, Object?>{
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
    'runIds',
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
    'runIds': <String, Object?>{
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
        'runReminder',
        'runSignup',
        'waitlistPromotion',
        'runCancelled',
        'runUpdated',
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
    'runId': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'minLength': 1,
      'maxLength': 180,
    },
    'runClubId': <String, Object?>{
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
  'description': 'Canonical attended-run review stored at reviews/{reviewId}.',
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
    'runClubId',
    'reviewerUserId',
    'reviewerName',
    'rating',
    'comment',
    'createdAt',
  ],
  'properties': <String, Object?>{
    'runClubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'runId': <String, Object?>{
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

const schemaSeedRunManifestDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/seed_runs.schema.json',
  'title': 'SeedRunManifestDocument',
  'description': 'Tool-owned synthetic-data manifest stored at seedRuns/{manifestId}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'seedRuns',
  'x-firestore-path': 'seedRuns/{manifestId}',
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
            'description': 'One optional caption prompt for a profile photo slot.',
            'type': 'object',
            'additionalProperties': false,
            'required': <Object?>[
              'photoIndex',
              'promptId',
              'prompt',
              'caption',
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
                    'description': 'One optional caption prompt for a profile photo slot.',
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'photoIndex',
                      'promptId',
                      'prompt',
                      'caption',
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
        'prefsNewCatches': <String, Object?>{
          'type': 'boolean',
        },
        'prefsMessages': <String, Object?>{
          'type': 'boolean',
        },
        'prefsRunReminders': <String, Object?>{
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

const schemaCreateRunClubCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/create_run_club_payload.schema.json',
  'title': 'CreateRunClubCallablePayload',
  'description': 'Callable payload accepted by createRunClub.',
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
  },
};

const schemaUpdateRunClubCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/update_run_club_payload.schema.json',
  'title': 'UpdateRunClubCallablePayload',
  'description': 'Callable payload accepted by updateRunClub.',
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
      },
    },
  },
};

const schemaArchiveRunClubCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/archive_run_club_payload.schema.json',
  'title': 'ArchiveRunClubCallablePayload',
  'description': 'Callable payload accepted by archiveRunClub.',
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

const schemaDeleteRunClubCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/delete_run_club_payload.schema.json',
  'title': 'DeleteRunClubCallablePayload',
  'description': 'Callable payload accepted by deleteRunClub.',
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

const schemaRunClubMembershipCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/run_club_membership_payload.schema.json',
  'title': 'RunClubMembershipCallablePayload',
  'description': 'Callable payload accepted by joinRunClub and leaveRunClub.',
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

const schemaSetRunClubNotificationPreferenceCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/set_run_club_notification_preference_payload.schema.json',
  'title': 'SetRunClubNotificationPreferenceCallablePayload',
  'description': 'Callable payload accepted by setRunClubNotificationPreference.',
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

const schemaCreateRunCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/create_run_payload.schema.json',
  'title': 'CreateRunCallablePayload',
  'description': 'Callable payload accepted by createRun.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'runClubId',
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
    'runId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'runClubId': <String, Object?>{
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
      'exclusiveMinimum': 0,
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

const schemaUpdateRunCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/update_run_payload.schema.json',
  'title': 'UpdateRunCallablePayload',
  'description': 'Callable payload accepted by updateRun.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'runId',
    'fields',
  ],
  'properties': <String, Object?>{
    'runId': <String, Object?>{
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
          'exclusiveMinimum': 0,
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
      },
    },
  },
};

const schemaCancelRunCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/cancel_run_payload.schema.json',
  'title': 'CancelRunCallablePayload',
  'description': 'Callable payload accepted by cancelRun.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'runId',
  ],
  'properties': <String, Object?>{
    'runId': <String, Object?>{
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

const schemaDeleteRunCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/delete_run_payload.schema.json',
  'title': 'DeleteRunCallablePayload',
  'description': 'Callable payload accepted by deleteRun.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'runId',
  ],
  'properties': <String, Object?>{
    'runId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
  },
};

const schemaRunIdCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/run_id_payload.schema.json',
  'title': 'RunIdCallablePayload',
  'description': 'Callable payload accepted by simple run actions that need only a runId.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'runId',
  ],
  'properties': <String, Object?>{
    'runId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
  },
};

const schemaMarkRunAttendanceCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/mark_run_attendance_payload.schema.json',
  'title': 'MarkRunAttendanceCallablePayload',
  'description': 'Callable payload accepted by markRunAttendance.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'runId',
    'userId',
  ],
  'properties': <String, Object?>{
    'runId': <String, Object?>{
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

const schemaSelfCheckInAttendanceCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/self_check_in_attendance_payload.schema.json',
  'title': 'SelfCheckInAttendanceCallablePayload',
  'description': 'Callable payload accepted by selfCheckInAttendance.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'runId',
  ],
  'properties': <String, Object?>{
    'runId': <String, Object?>{
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

const schemaCreateRunReviewCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/create_run_review_payload.schema.json',
  'title': 'CreateRunReviewCallablePayload',
  'description': 'Callable payload accepted by createRunReview.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'runClubId',
    'runId',
    'rating',
    'comment',
  ],
  'properties': <String, Object?>{
    'runClubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'runId': <String, Object?>{
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

const schemaUpdateRunReviewCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/update_run_review_payload.schema.json',
  'title': 'UpdateRunReviewCallablePayload',
  'description': 'Callable payload accepted by updateRunReview.',
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

const schemaDeleteRunReviewCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/delete_run_review_payload.schema.json',
  'title': 'DeleteRunReviewCallablePayload',
  'description': 'Callable payload accepted by deleteRunReview.',
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
        'runId',
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
        'runId': <String, Object?>{
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

const schemaCreateSavedRunClientWriteSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/client_writes/create_saved_run.schema.json',
  'title': 'CreateSavedRunClientWrite',
  'description': 'Client-owned Firestore create operation for savedRuns/{savedRunId}.',
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
        'savedRunId',
      ],
      'properties': <String, Object?>{
        'savedRunId': <String, Object?>{
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
        'runId',
        'savedAt',
      ],
      'properties': <String, Object?>{
        'uid': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'runId': <String, Object?>{
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
  'x-firestore-path': 'savedRuns/{savedRunId}',
  'x-owner': 'authenticated owner direct create',
};

const schemaDeleteSavedRunClientWriteSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/client_writes/delete_saved_run.schema.json',
  'title': 'DeleteSavedRunClientWrite',
  'description': 'Client-owned Firestore delete operation for savedRuns/{savedRunId}.',
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
        'savedRunId',
      ],
      'properties': <String, Object?>{
        'savedRunId': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
      },
    },
  },
  'x-firestore-operation': 'delete',
  'x-firestore-path': 'savedRuns/{savedRunId}',
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
    name: 'RunClubDocument',
    source: 'firestore/run_clubs.schema.json',
    schema: schemaRunClubDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'RunClubMembershipDocument',
    source: 'firestore/run_club_memberships.schema.json',
    schema: schemaRunClubMembershipDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'RunClubHostClaimDocument',
    source: 'firestore/run_club_host_claims.schema.json',
    schema: schemaRunClubHostClaimDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'RunDocument',
    source: 'firestore/runs.schema.json',
    schema: schemaRunDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'RunParticipationDocument',
    source: 'firestore/run_participations.schema.json',
    schema: schemaRunParticipationDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'RunClubScheduleLockDocument',
    source: 'firestore/run_club_schedule_locks.schema.json',
    schema: schemaRunClubScheduleLockDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'UserRunScheduleLockDocument',
    source: 'firestore/user_run_schedule_locks.schema.json',
    schema: schemaUserRunScheduleLockDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'SavedRunDocument',
    source: 'firestore/saved_runs.schema.json',
    schema: schemaSavedRunDocumentSchema,
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
    name: 'SeedRunManifestDocument',
    source: 'firestore/seed_runs.schema.json',
    schema: schemaSeedRunManifestDocumentSchema,
  ),
  SchemaContractDefinition(
    name: 'UpdateUserProfileCallablePayload',
    source: 'patches/update_user_profile.schema.json',
    schema: schemaUpdateUserProfileCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'CreateRunClubCallablePayload',
    source: 'callables/create_run_club_payload.schema.json',
    schema: schemaCreateRunClubCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'UpdateRunClubCallablePayload',
    source: 'callables/update_run_club_payload.schema.json',
    schema: schemaUpdateRunClubCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'ArchiveRunClubCallablePayload',
    source: 'callables/archive_run_club_payload.schema.json',
    schema: schemaArchiveRunClubCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'DeleteRunClubCallablePayload',
    source: 'callables/delete_run_club_payload.schema.json',
    schema: schemaDeleteRunClubCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'RunClubMembershipCallablePayload',
    source: 'callables/run_club_membership_payload.schema.json',
    schema: schemaRunClubMembershipCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'SetRunClubNotificationPreferenceCallablePayload',
    source: 'callables/set_run_club_notification_preference_payload.schema.json',
    schema: schemaSetRunClubNotificationPreferenceCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'CreateRunCallablePayload',
    source: 'callables/create_run_payload.schema.json',
    schema: schemaCreateRunCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'UpdateRunCallablePayload',
    source: 'callables/update_run_payload.schema.json',
    schema: schemaUpdateRunCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'CancelRunCallablePayload',
    source: 'callables/cancel_run_payload.schema.json',
    schema: schemaCancelRunCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'DeleteRunCallablePayload',
    source: 'callables/delete_run_payload.schema.json',
    schema: schemaDeleteRunCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'RunIdCallablePayload',
    source: 'callables/run_id_payload.schema.json',
    schema: schemaRunIdCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'MarkRunAttendanceCallablePayload',
    source: 'callables/mark_run_attendance_payload.schema.json',
    schema: schemaMarkRunAttendanceCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'SelfCheckInAttendanceCallablePayload',
    source: 'callables/self_check_in_attendance_payload.schema.json',
    schema: schemaSelfCheckInAttendanceCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'CreateRunReviewCallablePayload',
    source: 'callables/create_run_review_payload.schema.json',
    schema: schemaCreateRunReviewCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'UpdateRunReviewCallablePayload',
    source: 'callables/update_run_review_payload.schema.json',
    schema: schemaUpdateRunReviewCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'DeleteRunReviewCallablePayload',
    source: 'callables/delete_run_review_payload.schema.json',
    schema: schemaDeleteRunReviewCallablePayloadSchema,
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
    name: 'PlacesAutocompleteCallablePayload',
    source: 'callables/places_autocomplete_payload.schema.json',
    schema: schemaPlacesAutocompleteCallablePayloadSchema,
  ),
  SchemaContractDefinition(
    name: 'PlaceDetailsCallablePayload',
    source: 'callables/place_details_payload.schema.json',
    schema: schemaPlaceDetailsCallablePayloadSchema,
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
    name: 'CreateSavedRunClientWrite',
    source: 'client_writes/create_saved_run.schema.json',
    schema: schemaCreateSavedRunClientWriteSchema,
  ),
  SchemaContractDefinition(
    name: 'DeleteSavedRunClientWrite',
    source: 'client_writes/delete_saved_run.schema.json',
    schema: schemaDeleteSavedRunClientWriteSchema,
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
  'RunClubDocument': schemaRunClubDocumentSchema,
  'RunClubMembershipDocument': schemaRunClubMembershipDocumentSchema,
  'RunClubHostClaimDocument': schemaRunClubHostClaimDocumentSchema,
  'RunDocument': schemaRunDocumentSchema,
  'RunParticipationDocument': schemaRunParticipationDocumentSchema,
  'RunClubScheduleLockDocument': schemaRunClubScheduleLockDocumentSchema,
  'UserRunScheduleLockDocument': schemaUserRunScheduleLockDocumentSchema,
  'SavedRunDocument': schemaSavedRunDocumentSchema,
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
  'SeedRunManifestDocument': schemaSeedRunManifestDocumentSchema,
  'UpdateUserProfileCallablePayload': schemaUpdateUserProfileCallablePayloadSchema,
  'CreateRunClubCallablePayload': schemaCreateRunClubCallablePayloadSchema,
  'UpdateRunClubCallablePayload': schemaUpdateRunClubCallablePayloadSchema,
  'ArchiveRunClubCallablePayload': schemaArchiveRunClubCallablePayloadSchema,
  'DeleteRunClubCallablePayload': schemaDeleteRunClubCallablePayloadSchema,
  'RunClubMembershipCallablePayload': schemaRunClubMembershipCallablePayloadSchema,
  'SetRunClubNotificationPreferenceCallablePayload': schemaSetRunClubNotificationPreferenceCallablePayloadSchema,
  'CreateRunCallablePayload': schemaCreateRunCallablePayloadSchema,
  'UpdateRunCallablePayload': schemaUpdateRunCallablePayloadSchema,
  'CancelRunCallablePayload': schemaCancelRunCallablePayloadSchema,
  'DeleteRunCallablePayload': schemaDeleteRunCallablePayloadSchema,
  'RunIdCallablePayload': schemaRunIdCallablePayloadSchema,
  'MarkRunAttendanceCallablePayload': schemaMarkRunAttendanceCallablePayloadSchema,
  'SelfCheckInAttendanceCallablePayload': schemaSelfCheckInAttendanceCallablePayloadSchema,
  'CreateRunReviewCallablePayload': schemaCreateRunReviewCallablePayloadSchema,
  'UpdateRunReviewCallablePayload': schemaUpdateRunReviewCallablePayloadSchema,
  'DeleteRunReviewCallablePayload': schemaDeleteRunReviewCallablePayloadSchema,
  'BlockUserCallablePayload': schemaBlockUserCallablePayloadSchema,
  'UnblockUserCallablePayload': schemaUnblockUserCallablePayloadSchema,
  'ReportUserCallablePayload': schemaReportUserCallablePayloadSchema,
  'VerifyRazorpayPaymentCallablePayload': schemaVerifyRazorpayPaymentCallablePayloadSchema,
  'PlacesAutocompleteCallablePayload': schemaPlacesAutocompleteCallablePayloadSchema,
  'PlaceDetailsCallablePayload': schemaPlaceDetailsCallablePayloadSchema,
  'CreateProfileDecisionClientWrite': schemaCreateProfileDecisionClientWriteSchema,
  'CreateChatMessageClientWrite': schemaCreateChatMessageClientWriteSchema,
  'CreateSavedRunClientWrite': schemaCreateSavedRunClientWriteSchema,
  'DeleteSavedRunClientWrite': schemaDeleteSavedRunClientWriteSchema,
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
  'firestore/run_clubs.schema.json': schemaRunClubDocumentSchema,
  'firestore/run_club_memberships.schema.json': schemaRunClubMembershipDocumentSchema,
  'firestore/run_club_host_claims.schema.json': schemaRunClubHostClaimDocumentSchema,
  'firestore/runs.schema.json': schemaRunDocumentSchema,
  'firestore/run_participations.schema.json': schemaRunParticipationDocumentSchema,
  'firestore/run_club_schedule_locks.schema.json': schemaRunClubScheduleLockDocumentSchema,
  'firestore/user_run_schedule_locks.schema.json': schemaUserRunScheduleLockDocumentSchema,
  'firestore/saved_runs.schema.json': schemaSavedRunDocumentSchema,
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
  'firestore/seed_runs.schema.json': schemaSeedRunManifestDocumentSchema,
  'patches/update_user_profile.schema.json': schemaUpdateUserProfileCallablePayloadSchema,
  'callables/create_run_club_payload.schema.json': schemaCreateRunClubCallablePayloadSchema,
  'callables/update_run_club_payload.schema.json': schemaUpdateRunClubCallablePayloadSchema,
  'callables/archive_run_club_payload.schema.json': schemaArchiveRunClubCallablePayloadSchema,
  'callables/delete_run_club_payload.schema.json': schemaDeleteRunClubCallablePayloadSchema,
  'callables/run_club_membership_payload.schema.json': schemaRunClubMembershipCallablePayloadSchema,
  'callables/set_run_club_notification_preference_payload.schema.json': schemaSetRunClubNotificationPreferenceCallablePayloadSchema,
  'callables/create_run_payload.schema.json': schemaCreateRunCallablePayloadSchema,
  'callables/update_run_payload.schema.json': schemaUpdateRunCallablePayloadSchema,
  'callables/cancel_run_payload.schema.json': schemaCancelRunCallablePayloadSchema,
  'callables/delete_run_payload.schema.json': schemaDeleteRunCallablePayloadSchema,
  'callables/run_id_payload.schema.json': schemaRunIdCallablePayloadSchema,
  'callables/mark_run_attendance_payload.schema.json': schemaMarkRunAttendanceCallablePayloadSchema,
  'callables/self_check_in_attendance_payload.schema.json': schemaSelfCheckInAttendanceCallablePayloadSchema,
  'callables/create_run_review_payload.schema.json': schemaCreateRunReviewCallablePayloadSchema,
  'callables/update_run_review_payload.schema.json': schemaUpdateRunReviewCallablePayloadSchema,
  'callables/delete_run_review_payload.schema.json': schemaDeleteRunReviewCallablePayloadSchema,
  'callables/block_user_payload.schema.json': schemaBlockUserCallablePayloadSchema,
  'callables/unblock_user_payload.schema.json': schemaUnblockUserCallablePayloadSchema,
  'callables/report_user_payload.schema.json': schemaReportUserCallablePayloadSchema,
  'callables/verify_razorpay_payment_payload.schema.json': schemaVerifyRazorpayPaymentCallablePayloadSchema,
  'callables/places_autocomplete_payload.schema.json': schemaPlacesAutocompleteCallablePayloadSchema,
  'callables/place_details_payload.schema.json': schemaPlaceDetailsCallablePayloadSchema,
  'client_writes/create_profile_decision.schema.json': schemaCreateProfileDecisionClientWriteSchema,
  'client_writes/create_chat_message.schema.json': schemaCreateChatMessageClientWriteSchema,
  'client_writes/create_saved_run.schema.json': schemaCreateSavedRunClientWriteSchema,
  'client_writes/delete_saved_run.schema.json': schemaDeleteSavedRunClientWriteSchema,
  'client_writes/mark_notification_read.schema.json': schemaMarkNotificationReadClientWriteSchema,
  'client_writes/reset_match_unread_count.schema.json': schemaResetMatchUnreadCountClientWriteSchema,
};
