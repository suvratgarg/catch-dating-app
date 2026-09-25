// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/update_private_event_details_payload.schema.json.

const schemaUpdatePrivateEventDetailsCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/update_private_event_details_payload.schema.json',
  'title': 'UpdatePrivateEventDetailsCallablePayload',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'organizerId',
    'eventId',
    'requestId',
    'expectedSetupRevision',
    'reviewedDefaultsHash',
    'details',
  ],
  'properties': <String, Object?>{
    'organizerId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'requestId': <String, Object?>{
      'type': 'string',
      'pattern': '^[A-Za-z0-9][A-Za-z0-9_-]{7,127}\$',
    },
    'expectedSetupRevision': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 999999999,
    },
    'reviewedDefaultsHash': <String, Object?>{
      'type': 'string',
      'pattern': '^[a-f0-9]{64}\$',
    },
    'details': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[],
      'properties': <String, Object?>{
        'durationMinutes': <String, Object?>{
          'oneOf': <Object?>[
            <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'mode',
                'value',
              ],
              'properties': <String, Object?>{
                'mode': <String, Object?>{
                  'const': 'set',
                  'type': 'string',
                },
                'value': <String, Object?>{
                  'type': 'integer',
                  'minimum': 15,
                  'maximum': 240,
                },
              },
            },
            <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'mode',
              ],
              'properties': <String, Object?>{
                'mode': <String, Object?>{
                  'const': 'clear',
                  'type': 'string',
                },
              },
            },
            <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'mode',
              ],
              'properties': <String, Object?>{
                'mode': <String, Object?>{
                  'const': 'inherit',
                  'type': 'string',
                },
              },
            },
          ],
        },
        'venue': <String, Object?>{
          'oneOf': <Object?>[
            <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'mode',
                'value',
              ],
              'properties': <String, Object?>{
                'mode': <String, Object?>{
                  'const': 'set',
                  'type': 'string',
                },
                'value': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'name',
                  ],
                  'properties': <String, Object?>{
                    'name': <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 240,
                    },
                  },
                },
              },
            },
            <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'mode',
              ],
              'properties': <String, Object?>{
                'mode': <String, Object?>{
                  'const': 'clear',
                  'type': 'string',
                },
              },
            },
            <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'mode',
              ],
              'properties': <String, Object?>{
                'mode': <String, Object?>{
                  'const': 'inherit',
                  'type': 'string',
                },
              },
            },
          ],
        },
        'eventFormat': <String, Object?>{
          'oneOf': <Object?>[
            <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'mode',
                'value',
              ],
              'properties': <String, Object?>{
                'mode': <String, Object?>{
                  'const': 'set',
                  'type': 'string',
                },
                'value': <String, Object?>{
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
                        'matchingObjective': <String, Object?>{
                          'type': 'string',
                          'enum': <Object?>[
                            'coverage',
                            'romantic',
                            'affinity',
                            'novelty',
                            'balance',
                            'spread',
                          ],
                        },
                        'unitOutcome': <String, Object?>{
                          'type': 'string',
                          'enum': <Object?>[
                            'none',
                            'completion',
                            'score',
                            'rank',
                          ],
                        },
                        'accountability': <String, Object?>{
                          'type': 'string',
                          'enum': <Object?>[
                            'none',
                            'rollCall',
                            'sweep',
                          ],
                        },
                        'durationShape': <String, Object?>{
                          'type': 'string',
                          'enum': <Object?>[
                            'continuous',
                            'rounds',
                            'courses',
                            'segments',
                          ],
                        },
                      },
                    },
                    'activityDetails': <String, Object?>{
                      'type': 'object',
                      'additionalProperties': true,
                      'properties': <String, Object?>{
                        'routePlan': <String, Object?>{
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
                      },
                    },
                  },
                },
              },
            },
            <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'mode',
              ],
              'properties': <String, Object?>{
                'mode': <String, Object?>{
                  'const': 'clear',
                  'type': 'string',
                },
              },
            },
          ],
        },
      },
      'minProperties': 1,
    },
  },
};
