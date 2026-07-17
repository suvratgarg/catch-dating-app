// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from firestore/events.schema.json.

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
    'meetingLocation',
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
    'discoveryMarketId',
    'discoveryCityName',
    'discoveryActivityKind',
    'discoveryGeoCell',
    'discoveryHasOpenSpots',
    'discoveryAvailability',
    'discoveryOpenCohorts',
    'discoveryWaitlistCohorts',
    'discoveryInviteRequired',
    'discoveryMembershipRequired',
    'discoveryManualApprovalRequired',
    'discoveryMinAge',
    'discoveryMaxAge',
  ],
  'properties': <String, Object?>{
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'x-catch-ownership': 'callable-owned',
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
      'x-catch-ownership': 'callable-owned',
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
      'x-catch-ownership': 'callable-owned',
    },
    'meetingPoint': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 240,
      'x-catch-ownership': 'callable-owned',
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
          'type': 'number',
          'minimum': -90,
          'maximum': 90,
        },
        'longitude': <String, Object?>{
          'type': 'number',
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
      'x-catch-ownership': 'callable-owned',
    },
    'startingPointLat': <String, Object?>{
      'type': 'number',
      'minimum': -90,
      'maximum': 90,
      'x-catch-ownership': 'callable-owned',
    },
    'startingPointLng': <String, Object?>{
      'type': 'number',
      'minimum': -180,
      'maximum': 180,
      'x-catch-ownership': 'callable-owned',
    },
    'locationDetails': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 1000,
      'x-catch-ownership': 'callable-owned',
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
      'x-catch-ownership': 'callable-owned',
    },
    'eventPhotos': <String, Object?>{
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
    'distanceKm': <String, Object?>{
      'type': 'number',
      'minimum': 0,
      'maximum': 100,
      'x-catch-ownership': 'callable-owned',
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
        'eventSuccessPrimitives': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'description': 'Optional event-success behavior primitives for custom or unsupported activity formats. These fields translate a saved event format into the small set of primitives event success can reason about.',
          'properties': <String, Object?>{
            'phoneAvailability': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'continuous',
                'plannedPauses',
                'arrivalAndPostEventOnly',
                'hostOnlyLive',
                'noneDuringActivity',
              ],
            },
            'rotationSuitability': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'none',
                'plannedBreaks',
                'continuousRounds',
              ],
            },
            'assignmentAlgorithm': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'none',
                'pacePods',
                'socialPods',
                'pairRotations',
                'teamBalancer',
                'tableSeating',
              ],
            },
            'compatibilityPolicy': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'none',
                'socialCohortBalance',
                'mutualInterestOnly',
                'questionnaireClueOnly',
              ],
            },
          },
        },
        'activityDetails': <String, Object?>{
          'type': 'object',
          'additionalProperties': true,
        },
      },
      'x-catch-ownership': 'callable-owned',
    },
    'pace': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'easy',
        'moderate',
        'fast',
        'competitive',
      ],
      'x-catch-ownership': 'callable-owned',
    },
    'capacityLimit': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 1000,
      'x-catch-ownership': 'callable-owned',
    },
    'description': <String, Object?>{
      'type': 'string',
      'maxLength': 2000,
      'x-catch-ownership': 'callable-owned',
    },
    'priceInPaise': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 100000000,
      'x-catch-ownership': 'callable-owned',
    },
    'currency': <String, Object?>{
      'type': 'string',
      'pattern': '^[A-Z]{3}\$',
      'x-catch-ownership': 'callable-owned',
    },
    'bookedCount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'x-catch-ownership': 'callable-owned',
    },
    'checkedInCount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'x-catch-ownership': 'callable-owned',
    },
    'waitlistedCount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'x-catch-ownership': 'callable-owned',
    },
    'status': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'active',
        'cancelled',
      ],
      'x-catch-ownership': 'callable-owned',
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
      'x-catch-ownership': 'callable-owned',
    },
    'cancellationReason': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 500,
      'x-catch-ownership': 'callable-owned',
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
      'x-catch-ownership': 'callable-owned',
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
      'x-catch-ownership': 'callable-owned',
    },
    'genderCounts': <String, Object?>{
      'type': 'object',
      'additionalProperties': <String, Object?>{
        'type': 'integer',
        'minimum': 0,
      },
      'x-catch-ownership': 'callable-owned',
    },
    'cohortCounts': <String, Object?>{
      'type': 'object',
      'additionalProperties': <String, Object?>{
        'type': 'integer',
        'minimum': 0,
      },
      'x-catch-ownership': 'callable-owned',
    },
    'waitlistedCohortCounts': <String, Object?>{
      'type': 'object',
      'additionalProperties': <String, Object?>{
        'type': 'integer',
        'minimum': 0,
      },
      'x-catch-ownership': 'callable-owned',
    },
    'discoveryMarketId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'pattern': '^[a-z]{2}-[a-z0-9]+(?:-[a-z0-9]+)*\$',
      'x-catch-ownership': 'callable-owned',
    },
    'discoveryCityName': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'pattern': '^[a-z0-9-]+\$',
      'x-catch-ownership': 'callable-owned',
    },
    'discoveryActivityKind': <String, Object?>{
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
      'x-catch-ownership': 'callable-owned',
    },
    'discoveryGeoCell': <String, Object?>{
      'type': 'string',
      'pattern': '^-?\\d+:-?\\d+\$',
      'x-catch-ownership': 'callable-owned',
    },
    'discoveryHasOpenSpots': <String, Object?>{
      'type': 'boolean',
      'x-catch-ownership': 'callable-owned',
    },
    'discoveryAvailability': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'open',
        'waitlist',
        'gated',
        'full',
        'cancelled',
      ],
      'x-catch-ownership': 'callable-owned',
    },
    'discoveryOpenCohorts': <String, Object?>{
      'type': 'array',
      'maxItems': 4,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'enum': <Object?>[
          'menInterestedInWomen',
          'womenInterestedInMen',
          'queerOrOpen',
          'nonBinaryOrOther',
        ],
      },
      'x-catch-ownership': 'callable-owned',
    },
    'discoveryWaitlistCohorts': <String, Object?>{
      'type': 'array',
      'maxItems': 4,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'enum': <Object?>[
          'menInterestedInWomen',
          'womenInterestedInMen',
          'queerOrOpen',
          'nonBinaryOrOther',
        ],
      },
      'x-catch-ownership': 'callable-owned',
    },
    'discoveryInviteRequired': <String, Object?>{
      'type': 'boolean',
      'x-catch-ownership': 'callable-owned',
    },
    'discoveryMembershipRequired': <String, Object?>{
      'type': 'boolean',
      'x-catch-ownership': 'callable-owned',
    },
    'discoveryManualApprovalRequired': <String, Object?>{
      'type': 'boolean',
      'x-catch-ownership': 'callable-owned',
    },
    'discoveryMinAge': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 120,
      'x-catch-ownership': 'callable-owned',
    },
    'discoveryMaxAge': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 120,
      'x-catch-ownership': 'callable-owned',
    },
    'adminSearch': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'description': 'Server-owned deterministic search projection used by admin event publishing. Rebuildable from canonical event and organizer fields; not consumed by the app.',
      'required': <Object?>[
        'tokens',
        'sortKey',
        'updatedAt',
        'updatedBySource',
      ],
      'properties': <String, Object?>{
        'tokens': <String, Object?>{
          'type': 'array',
          'maxItems': 120,
          'uniqueItems': true,
          'items': <String, Object?>{
            'type': 'string',
            'minLength': 2,
            'maxLength': 80,
            'pattern': '^[a-z0-9-]+\$',
          },
        },
        'sortKey': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 160,
          'pattern': '^[a-z0-9-]+(?:-[a-z0-9-]+)*\$',
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
        'updatedBySource': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'adminUpdateEventDetails',
            'adminEventSearchBackfill',
          ],
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
