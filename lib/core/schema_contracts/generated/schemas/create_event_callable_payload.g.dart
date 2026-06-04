// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/create_event_payload.schema.json.

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
