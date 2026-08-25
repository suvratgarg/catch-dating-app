// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from firestore/event_rehearsals.schema.json.

const schemaEventRehearsalDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/event_rehearsals.schema.json',
  'title': 'EventRehearsalDocument',
  'description': 'Server-owned isolated Host rehearsal session stored at eventRehearsals/{sessionId}.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'eventRehearsals',
  'x-firestore-path': 'eventRehearsals/{sessionId}',
  'x-document-id-field': 'id',
  'x-owner': 'event rehearsal callables',
  'required': <Object?>[
    'organizerId',
    'clubId',
    'ownerUid',
    'sourceEventId',
    'sourceEventRevision',
    'publicRehearsalId',
    'viewerTokenHash',
    'scenarioId',
    'seed',
    'actorCount',
    'actionCount',
    'status',
    'setup',
    'setupRevision',
    'runtimeRevision',
    'activeStepIndex',
    'virtualStartedAt',
    'virtualNow',
    'faultId',
    'faultConsumed',
    'createdAt',
    'updatedAt',
    'expiresAt',
    'completedAt',
  ],
  'properties': <String, Object?>{
    'organizerId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'x-catch-ownership': 'callable-owned',
    },
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'x-catch-ownership': 'callable-owned',
    },
    'ownerUid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'x-catch-ownership': 'callable-owned',
    },
    'sourceEventId': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 180,
      'x-catch-ownership': 'callable-owned',
    },
    'sourceEventRevision': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 180,
      'x-catch-ownership': 'callable-owned',
    },
    'publicRehearsalId': <String, Object?>{
      'type': 'string',
      'pattern': '^[A-Za-z0-9_-]{20,80}\$',
      'x-catch-ownership': 'callable-owned',
    },
    'viewerTokenHash': <String, Object?>{
      'type': 'string',
      'pattern': '^[a-f0-9]{64}\$',
      'x-catch-ownership': 'callable-owned',
    },
    'scenarioId': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'smoothRun',
        'lateAndNoShow',
        'earlyExitAndReturn',
        'rosterAndCapacity',
        'walkInAndAmbiguousClaim',
        'privacyAndKeepApart',
        'lowConnectivity',
        'concurrentHosts',
        'revealInterrupted',
        'externalProfiles',
        'accountabilitySweep',
      ],
      'x-catch-ownership': 'callable-owned',
    },
    'seed': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 2147483647,
      'x-catch-ownership': 'callable-owned',
    },
    'actorCount': <String, Object?>{
      'type': 'integer',
      'minimum': 2,
      'maximum': 50,
      'x-catch-ownership': 'callable-owned',
    },
    'actionCount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 500,
      'x-catch-ownership': 'callable-owned',
    },
    'status': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'draft',
        'ready',
        'running',
        'paused',
        'complete',
        'expired',
      ],
      'x-catch-ownership': 'callable-owned',
    },
    'setup': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'title',
        'locationName',
        'durationMinutes',
        'hostGoal',
        'attendeePrompt',
        'moduleIds',
      ],
      'properties': <String, Object?>{
        'title': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 120,
        },
        'locationName': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'durationMinutes': <String, Object?>{
          'type': 'integer',
          'minimum': 30,
          'maximum': 360,
        },
        'hostGoal': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 240,
        },
        'attendeePrompt': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 320,
        },
        'moduleIds': <String, Object?>{
          'type': 'array',
          'minItems': 1,
          'maxItems': 8,
          'uniqueItems': true,
          'items': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'arrival',
              'firstHello',
              'pods',
              'rotations',
              'conversationCues',
              'reveal',
              'afterglow',
              'accountability',
            ],
          },
        },
        'movementSimulation': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'description': 'Frozen, synthetic-only movement truth used by dress rehearsal. It never reads or writes a real person\'s live position.',
          'required': <Object?>[
            'itinerary',
            'routePlan',
            'livePositions',
            'lateArrivalGuidance',
          ],
          'properties': <String, Object?>{
            'itinerary': <String, Object?>{
              'type': 'array',
              'maxItems': 40,
              'items': <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'description': 'One public, event-local run-of-show entry. Offset is measured from the event start so rescheduling does not rewrite the itinerary.',
                'required': <Object?>[
                  'id',
                  'kind',
                  'offsetMinutes',
                  'title',
                ],
                'properties': <String, Object?>{
                  'id': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 80,
                    'pattern': '^[A-Za-z0-9_-]+\$',
                  },
                  'kind': <String, Object?>{
                    'type': 'string',
                    'enum': <Object?>[
                      'gather',
                      'activity',
                      'stop',
                      'break',
                      'transition',
                      'finish',
                    ],
                  },
                  'offsetMinutes': <String, Object?>{
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 1440,
                  },
                  'durationMinutes': <String, Object?>{
                    'type': <Object?>[
                      'integer',
                      'null',
                    ],
                    'minimum': 1,
                    'maximum': 1440,
                  },
                  'title': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 120,
                  },
                  'description': <String, Object?>{
                    'type': <Object?>[
                      'string',
                      'null',
                    ],
                    'maxLength': 500,
                  },
                  'location': <String, Object?>{
                    'anyOf': <Object?>[
                      <String, Object?>{
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
                      },
                      <String, Object?>{
                        'type': 'null',
                      },
                    ],
                  },
                  'routeDistanceMeters': <String, Object?>{
                    'type': <Object?>[
                      'integer',
                      'null',
                    ],
                    'minimum': 0,
                    'maximum': 1000000,
                  },
                },
              },
            },
            'routePlan': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'null',
                },
                <String, Object?>{
                  'type': 'object',
                  'description': 'Composable operations for an event that moves through a route. Activity kind remains the broader format authority.',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'version',
                    'movementMode',
                    'routeShape',
                    'groupStrategy',
                    'stopCadence',
                    'stopKinds',
                    'roleKinds',
                  ],
                  'properties': <String, Object?>{
                    'version': <String, Object?>{
                      'type': 'integer',
                      'enum': <Object?>[
                        1,
                        2,
                      ],
                    },
                    'movementMode': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'run',
                        'walk',
                        'ride',
                        'mixed',
                      ],
                    },
                    'routeShape': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'loop',
                        'outAndBack',
                        'pointToPoint',
                      ],
                    },
                    'groupStrategy': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'together',
                        'paceGroups',
                        'selfDirected',
                      ],
                    },
                    'stopCadence': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'continuous',
                        'flexibleStops',
                        'hostedStops',
                      ],
                    },
                    'stopKinds': <String, Object?>{
                      'type': 'array',
                      'minItems': 1,
                      'maxItems': 7,
                      'uniqueItems': true,
                      'items': <String, Object?>{
                        'type': 'string',
                        'enum': <Object?>[
                          'water',
                          'regroup',
                          'venue',
                          'photoSpot',
                          'viewpoint',
                          'hazard',
                          'turnaround',
                        ],
                      },
                    },
                    'roleKinds': <String, Object?>{
                      'type': 'array',
                      'minItems': 1,
                      'maxItems': 6,
                      'uniqueItems': true,
                      'items': <String, Object?>{
                        'type': 'string',
                        'enum': <Object?>[
                          'routeLead',
                          'sweep',
                          'pacer',
                          'stopHost',
                          'marshal',
                          'photographer',
                        ],
                      },
                    },
                    'path': <String, Object?>{
                      'type': 'array',
                      'minItems': 2,
                      'maxItems': 500,
                      'items': <String, Object?>{
                        'type': 'object',
                        'additionalProperties': false,
                        'required': <Object?>[
                          'latitude',
                          'longitude',
                        ],
                        'properties': <String, Object?>{
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
                    'paceGroups': <String, Object?>{
                      'type': 'array',
                      'maxItems': 12,
                      'items': <String, Object?>{
                        'type': 'object',
                        'additionalProperties': false,
                        'required': <Object?>[
                          'id',
                          'label',
                          'sortOrder',
                        ],
                        'properties': <String, Object?>{
                          'id': <String, Object?>{
                            'type': 'string',
                            'minLength': 1,
                            'maxLength': 80,
                            'pattern': '^[A-Za-z0-9_-]+\$',
                          },
                          'label': <String, Object?>{
                            'type': 'string',
                            'minLength': 1,
                            'maxLength': 80,
                          },
                          'targetPaceSecondsPerKm': <String, Object?>{
                            'type': <Object?>[
                              'integer',
                              'null',
                            ],
                            'minimum': 120,
                            'maximum': 1800,
                          },
                          'sortOrder': <String, Object?>{
                            'type': 'integer',
                            'minimum': 0,
                            'maximum': 1000,
                          },
                        },
                      },
                    },
                    'liveTrackingPolicy': <String, Object?>{
                      'type': 'object',
                      'additionalProperties': false,
                      'required': <Object?>[
                        'mode',
                        'staleAfterSeconds',
                        'retentionMinutes',
                      ],
                      'properties': <String, Object?>{
                        'mode': <String, Object?>{
                          'type': 'string',
                          'enum': <Object?>[
                            'disabled',
                            'hostOnly',
                            'authorizedOperators',
                          ],
                        },
                        'staleAfterSeconds': <String, Object?>{
                          'type': 'integer',
                          'minimum': 30,
                          'maximum': 600,
                        },
                        'retentionMinutes': <String, Object?>{
                          'type': 'integer',
                          'minimum': 5,
                          'maximum': 1440,
                        },
                      },
                    },
                  },
                },
              ],
            },
            'livePositions': <String, Object?>{
              'type': 'array',
              'maxItems': 2,
              'items': <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'role',
                  'latitude',
                  'longitude',
                  'recordedOffsetMinutes',
                ],
                'properties': <String, Object?>{
                  'role': <String, Object?>{
                    'type': 'string',
                    'enum': <Object?>[
                      'host',
                      'operator',
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
                  'recordedOffsetMinutes': <String, Object?>{
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 360,
                  },
                },
              },
            },
            'lateArrivalGuidance': <String, Object?>{
              'type': <Object?>[
                'string',
                'null',
              ],
              'maxLength': 320,
            },
          },
        },
      },
      'x-catch-ownership': 'callable-owned',
    },
    'setupRevision': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 2147483647,
      'x-catch-ownership': 'callable-owned',
    },
    'runtimeRevision': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 2147483647,
      'x-catch-ownership': 'callable-owned',
    },
    'activeStepIndex': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 8,
      'x-catch-ownership': 'callable-owned',
    },
    'virtualStartedAt': <String, Object?>{
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
    'virtualNow': <String, Object?>{
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
    'faultId': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'none',
        'latency',
        'oneShotFailure',
        'listenerDisconnect',
        'staleRevision',
        'duplicateDelivery',
        'legacyFixture',
        'reducedMotion',
        'lowBandwidth',
      ],
      'x-catch-ownership': 'callable-owned',
    },
    'faultConsumed': <String, Object?>{
      'type': 'boolean',
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
      'x-catch-ownership': 'callable-owned',
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
      'x-catch-ownership': 'callable-owned',
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
      'x-catch-ownership': 'callable-owned',
    },
  },
};
