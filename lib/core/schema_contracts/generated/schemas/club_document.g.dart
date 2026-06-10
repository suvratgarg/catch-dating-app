// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from firestore/clubs.schema.json.

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
      'x-catch-ownership': 'callable-owned',
    },
    'description': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 2000,
      'x-catch-ownership': 'callable-owned',
    },
    'location': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'minLength': 1,
      'maxLength': 80,
      'pattern': '^[a-z0-9-]+\$',
      'x-catch-ownership': 'callable-owned',
    },
    'area': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'x-catch-ownership': 'callable-owned',
    },
    'hostUserId': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
      'description': 'Legacy primary host user id. Null for programmatically generated, unclaimed organizer profiles.',
      'x-catch-ownership': 'callable-owned',
    },
    'hostName': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 120,
      'description': 'Legacy host display projection. Null when the organizer has not been claimed by a Catch user.',
      'x-catch-ownership': 'callable-owned',
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
      'x-catch-ownership': 'callable-owned',
    },
    'ownerUserId': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
      'description': 'Canonical owner user id after claim or user-created setup. Null for unclaimed programmatic profiles.',
      'x-catch-ownership': 'callable-owned',
    },
    'hostUserIds': <String, Object?>{
      'type': 'array',
      'maxItems': 20,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
        'maxLength': 180,
      },
      'x-catch-ownership': 'callable-owned',
    },
    'hostProfiles': <String, Object?>{
      'type': 'array',
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
      'x-catch-ownership': 'callable-owned',
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
      'x-catch-ownership': 'callable-owned',
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
      'x-catch-ownership': 'callable-owned',
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
      'x-catch-ownership': 'callable-owned',
    },
    'clubPhotos': <String, Object?>{
      'type': 'array',
      'maxItems': 12,
      'items': <String, Object?>{
        'title': 'UploadedPhoto',
        'description': 'Canonical uploaded image object for ordered media galleries, logos, and event photos.',
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'id',
          'url',
          'storagePath',
          'thumbnailUrl',
          'thumbnailStoragePath',
          'position',
          'createdAt',
          'updatedAt',
        ],
        'properties': <String, Object?>{
          'id': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 120,
            'pattern': '^[A-Za-z0-9_-]+\$',
          },
          'url': <String, Object?>{
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
          'thumbnailUrl': <String, Object?>{
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
          'thumbnailStoragePath': <String, Object?>{
            'anyOf': <Object?>[
              <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 512,
                'pattern': '^[^/\\u0000][^\\u0000]*\$',
              },
              <String, Object?>{
                'type': 'null',
              },
            ],
          },
          'position': <String, Object?>{
            'type': 'integer',
            'minimum': 0,
            'maximum': 19,
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
      },
      'x-catch-ownership': 'callable-owned',
    },
    'logoPhoto': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'title': 'UploadedPhoto',
          'description': 'Canonical uploaded image object for ordered media galleries, logos, and event photos.',
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'id',
            'url',
            'storagePath',
            'thumbnailUrl',
            'thumbnailStoragePath',
            'position',
            'createdAt',
            'updatedAt',
          ],
          'properties': <String, Object?>{
            'id': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 120,
              'pattern': '^[A-Za-z0-9_-]+\$',
            },
            'url': <String, Object?>{
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
            'thumbnailUrl': <String, Object?>{
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
            'thumbnailStoragePath': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                  'maxLength': 512,
                  'pattern': '^[^/\\u0000][^\\u0000]*\$',
                },
                <String, Object?>{
                  'type': 'null',
                },
              ],
            },
            'position': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 19,
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
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
      'x-catch-ownership': 'callable-owned',
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
      'x-catch-ownership': 'callable-owned',
    },
    'memberCount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'x-catch-ownership': 'trigger-owned',
    },
    'rating': <String, Object?>{
      'type': 'number',
      'minimum': 0,
      'maximum': 5,
      'x-catch-ownership': 'trigger-owned',
    },
    'reviewCount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'x-catch-ownership': 'trigger-owned',
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
      'x-catch-ownership': 'trigger-owned',
    },
    'nextEventLabel': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 240,
      'x-catch-ownership': 'trigger-owned',
    },
    'instagramHandle': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 320,
      'x-catch-ownership': 'callable-owned',
    },
    'phoneNumber': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 320,
      'x-catch-ownership': 'callable-owned',
    },
    'email': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 320,
      'x-catch-ownership': 'callable-owned',
    },
    'status': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'active',
        'archived',
      ],
      'x-catch-ownership': 'callable-owned',
    },
    'archived': <String, Object?>{
      'type': 'boolean',
      'x-catch-ownership': 'callable-owned',
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
      'x-catch-ownership': 'callable-owned',
    },
    'archiveReason': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 500,
      'x-catch-ownership': 'callable-owned',
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
                'rotationRepeatStrategy': <String, Object?>{
                  'type': 'string',
                  'enum': <Object?>[
                    'avoid',
                    'allowWhenExhausted',
                  ],
                },
                'maxPairMeetings': <String, Object?>{
                  'type': 'integer',
                  'minimum': 1,
                  'maximum': 10,
                },
                'balanceActivityAttributes': <String, Object?>{
                  'type': 'array',
                  'maxItems': 8,
                  'uniqueItems': true,
                  'items': <String, Object?>{
                    'type': 'string',
                    'enum': <Object?>[
                      'paceBand',
                      'skillBand',
                      'roleBand',
                    ],
                  },
                },
                'clusterActivityAttributes': <String, Object?>{
                  'type': 'array',
                  'maxItems': 8,
                  'uniqueItems': true,
                  'items': <String, Object?>{
                    'type': 'string',
                    'enum': <Object?>[
                      'paceBand',
                      'skillBand',
                      'roleBand',
                    ],
                  },
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
                  'rotationRepeatStrategy': <String, Object?>{
                    'type': 'string',
                    'enum': <Object?>[
                      'avoid',
                      'allowWhenExhausted',
                    ],
                  },
                  'maxPairMeetings': <String, Object?>{
                    'type': 'integer',
                    'minimum': 1,
                    'maximum': 10,
                  },
                  'balanceActivityAttributes': <String, Object?>{
                    'type': 'array',
                    'maxItems': 8,
                    'uniqueItems': true,
                    'items': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'paceBand',
                        'skillBand',
                        'roleBand',
                      ],
                    },
                  },
                  'clusterActivityAttributes': <String, Object?>{
                    'type': 'array',
                    'maxItems': 8,
                    'uniqueItems': true,
                    'items': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'paceBand',
                        'skillBand',
                        'roleBand',
                      ],
                    },
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
      'x-catch-ownership': 'callable-owned',
    },
    'entityKind': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'club',
        'venue',
        'eventOrganizer',
        'creatorCommunity',
        'brand',
      ],
      'description': 'Broad organizer identity. Keeps clubs as one subtype rather than forcing every host into club nomenclature.',
      'x-catch-ownership': 'callable-owned',
    },
    'entitySubtypes': <String, Object?>{
      'type': 'array',
      'maxItems': 20,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
        'maxLength': 80,
      },
      'x-catch-ownership': 'callable-owned',
    },
    'displayCategory': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 120,
      'description': 'Reader-facing category label for web and discovery surfaces.',
      'x-catch-ownership': 'callable-owned',
    },
    'cityName': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 120,
      'x-catch-ownership': 'callable-owned',
    },
    'regionName': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 120,
      'x-catch-ownership': 'callable-owned',
    },
    'countryCode': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'pattern': '^[A-Z]{2}\$',
      'x-catch-ownership': 'callable-owned',
    },
    'countryName': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 120,
      'x-catch-ownership': 'callable-owned',
    },
    'appVisibility': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'discoverable',
        'hidden',
      ],
      'description': 'Whether the native app should show this organizer in browse surfaces. Scraped unclaimed profiles start hidden.',
      'x-catch-ownership': 'callable-owned',
    },
    'ownership': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'description': 'Claim-aware organizer ownership state. This is the forward-looking owner model; legacy host fields are maintained for app compatibility.',
      'required': <Object?>[
        'state',
        'ownerUserId',
        'primaryHostUserId',
        'hostUserIds',
        'claimedAt',
        'claimedByUid',
      ],
      'properties': <String, Object?>{
        'state': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'programmatic',
            'userCreated',
            'claimed',
            'transferred',
          ],
        },
        'ownerUserId': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'primaryHostUserId': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'hostUserIds': <String, Object?>{
          'type': 'array',
          'maxItems': 20,
          'uniqueItems': true,
          'items': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 180,
          },
        },
        'claimedAt': <String, Object?>{
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
        'claimedByUid': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
      },
      'x-catch-ownership': 'callable-owned',
    },
    'claim': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'state',
        'claimHref',
        'lastClaimRequestId',
      ],
      'properties': <String, Object?>{
        'state': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'unclaimed',
            'claimPending',
            'claimed',
            'verified',
            'suppressed',
          ],
        },
        'claimHref': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 240,
        },
        'lastClaimRequestId': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
      },
      'x-catch-ownership': 'callable-owned',
    },
    'publicPage': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'slug',
        'citySlug',
        'canonicalPath',
        'publishStatus',
        'indexStatus',
        'robots',
        'seoTitle',
        'seoDescription',
        'lastRenderedAt',
      ],
      'properties': <String, Object?>{
        'slug': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 160,
          'pattern': '^[a-z0-9-]+\$',
        },
        'citySlug': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'minLength': 1,
          'maxLength': 80,
          'pattern': '^[a-z0-9-]+\$',
        },
        'canonicalPath': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 240,
        },
        'publishStatus': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'draft',
            'qa',
            'published',
            'suppressed',
            'removed',
          ],
        },
        'indexStatus': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'noindex',
            'indexReady',
            'indexed',
          ],
        },
        'robots': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'noindex, follow',
            'index, follow',
          ],
        },
        'seoTitle': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 120,
        },
        'seoDescription': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 320,
        },
        'lastRenderedAt': <String, Object?>{
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
        'indexReview': <String, Object?>{
          'type': <Object?>[
            'object',
            'null',
          ],
          'additionalProperties': false,
          'required': <Object?>[
            'reviewedAt',
            'reviewedByUid',
            'indexStatus',
            'checklist',
            'reviewNote',
          ],
          'properties': <String, Object?>{
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
            'reviewedByUid': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 180,
            },
            'indexStatus': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'noindex',
                'indexReady',
                'indexed',
              ],
            },
            'checklist': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'sourceEvidenceVerified',
                'mediaRightsVerified',
                'cadenceVerified',
                'ownerContactVerified',
              ],
              'properties': <String, Object?>{
                'sourceEvidenceVerified': <String, Object?>{
                  'type': 'boolean',
                },
                'mediaRightsVerified': <String, Object?>{
                  'type': 'boolean',
                },
                'cadenceVerified': <String, Object?>{
                  'type': 'boolean',
                },
                'ownerContactVerified': <String, Object?>{
                  'type': 'boolean',
                },
              },
            },
            'reviewNote': <String, Object?>{
              'type': <Object?>[
                'string',
                'null',
              ],
              'maxLength': 1000,
            },
          },
        },
      },
      'x-catch-ownership': 'callable-owned',
    },
    'provenance': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'origin',
        'sourceConfidence',
        'verificationStatus',
        'lastVerifiedAt',
      ],
      'properties': <String, Object?>{
        'origin': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'userCreated',
            'scraper',
            'adminSeed',
            'import',
          ],
        },
        'sourceConfidence': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'seedOnly',
            'low',
            'medium',
            'high',
            'ownerVerified',
          ],
        },
        'verificationStatus': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'unverified',
            'sourceBacked',
            'ownerVerified',
          ],
        },
        'lastVerifiedAt': <String, Object?>{
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
      'x-catch-ownership': 'server-only',
    },
    'publicProfile': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'description': 'Public, owner-safe organizer listing content derived from sources or owner edits. Raw scrape snapshots belong in private evidence collections.',
      'properties': <String, Object?>{
        'headline': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 160,
        },
        'summary': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 800,
        },
        'sourceSummary': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 800,
        },
        'formats': <String, Object?>{
          'type': 'array',
          'maxItems': 12,
          'items': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 80,
          },
        },
        'facts': <String, Object?>{
          'type': 'array',
          'maxItems': 20,
          'items': <String, Object?>{
            'type': 'object',
            'additionalProperties': false,
            'required': <Object?>[
              'label',
              'value',
            ],
            'properties': <String, Object?>{
              'label': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 80,
              },
              'value': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 240,
              },
            },
          },
        },
        'fitNotes': <String, Object?>{
          'type': 'array',
          'maxItems': 8,
          'items': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 400,
          },
        },
        'missingEvidence': <String, Object?>{
          'type': 'array',
          'maxItems': 12,
          'items': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 200,
          },
        },
        'eventEvidence': <String, Object?>{
          'type': 'array',
          'maxItems': 12,
          'items': <String, Object?>{
            'type': 'object',
            'additionalProperties': false,
            'required': <Object?>[
              'title',
              'date',
              'location',
              'summary',
              'facts',
              'sourceLabel',
              'sourceHref',
            ],
            'properties': <String, Object?>{
              'title': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 160,
              },
              'date': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 120,
              },
              'location': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 240,
              },
              'summary': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 600,
              },
              'facts': <String, Object?>{
                'type': 'array',
                'maxItems': 12,
                'items': <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                  'maxLength': 240,
                },
              },
              'sourceLabel': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 120,
              },
              'sourceHref': <String, Object?>{
                'type': 'string',
                'format': 'uri',
                'maxLength': 2048,
              },
            },
          },
        },
      },
      'x-catch-ownership': 'callable-owned',
    },
    'publicSources': <String, Object?>{
      'type': 'array',
      'maxItems': 20,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'type',
          'label',
          'detail',
          'href',
          'confidence',
          'lastCheckedAt',
        ],
        'properties': <String, Object?>{
          'type': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 80,
          },
          'label': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 120,
          },
          'detail': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 600,
          },
          'href': <String, Object?>{
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
          'confidence': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'low',
              'medium',
              'high',
            ],
          },
          'lastCheckedAt': <String, Object?>{
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
      'x-catch-ownership': 'server-only',
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
