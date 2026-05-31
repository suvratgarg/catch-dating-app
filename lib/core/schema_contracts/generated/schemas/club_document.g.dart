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
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'x-catch-ownership': 'callable-owned',
    },
    'hostName': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
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
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'x-catch-ownership': 'callable-owned',
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
      'x-catch-ownership': 'callable-owned',
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
      'x-catch-ownership': 'callable-owned',
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
