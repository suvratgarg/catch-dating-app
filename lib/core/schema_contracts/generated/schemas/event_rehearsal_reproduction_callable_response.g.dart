// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callable_responses/event_rehearsal_reproduction_response.schema.json.

const schemaEventRehearsalReproductionCallableResponseSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callable_responses/event_rehearsal_reproduction_response.schema.json',
  'title': 'EventRehearsalReproductionCallableResponse',
  'description': 'Portable deterministic reproduction record for internal QA and product review.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'schemaVersion',
    'sessionId',
    'scenarioId',
    'seed',
    'setup',
    'actions',
  ],
  'properties': <String, Object?>{
    'schemaVersion': <String, Object?>{
      'type': 'integer',
      'const': 1,
    },
    'sessionId': <String, Object?>{
      'type': 'string',
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
    },
    'seed': <String, Object?>{
      'type': 'integer',
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
    },
    'actions': <String, Object?>{
      'type': 'array',
      'maxItems': 500,
      'items': <String, Object?>{
        'type': 'object',
      },
    },
  },
};
