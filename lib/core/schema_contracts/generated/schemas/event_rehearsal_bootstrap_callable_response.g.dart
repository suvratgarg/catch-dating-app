// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callable_responses/event_rehearsal_bootstrap_response.schema.json.

const schemaEventRehearsalBootstrapCallableResponseSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callable_responses/event_rehearsal_bootstrap_response.schema.json',
  'title': 'EventRehearsalBootstrapCallableResponse',
  'description': 'Host projection of a rehearsal session, synthetic actors, and bounded action history.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'session',
    'actors',
    'actions',
    'guestUrl',
    'canUseInternalFaults',
  ],
  'properties': <String, Object?>{
    'session': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'id',
        'organizerId',
        'sourceEventId',
        'scenarioId',
        'seed',
        'actorCount',
        'actionCount',
        'status',
        'setup',
        'setupRevision',
        'runtimeRevision',
        'activeStepIndex',
        'virtualNowMillis',
        'faultId',
        'expiresAtMillis',
        'virtualStartedAtMillis',
      ],
      'properties': <String, Object?>{
        'id': <String, Object?>{
          'type': 'string',
        },
        'organizerId': <String, Object?>{
          'type': 'string',
        },
        'sourceEventId': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
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
        'actorCount': <String, Object?>{
          'type': 'integer',
        },
        'actionCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 500,
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
        'setupRevision': <String, Object?>{
          'type': 'integer',
        },
        'runtimeRevision': <String, Object?>{
          'type': 'integer',
        },
        'activeStepIndex': <String, Object?>{
          'type': 'integer',
        },
        'virtualNowMillis': <String, Object?>{
          'type': 'integer',
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
        },
        'expiresAtMillis': <String, Object?>{
          'type': 'integer',
        },
        'virtualStartedAtMillis': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 9007199254740991,
        },
      },
    },
    'actors': <String, Object?>{
      'type': 'array',
      'maxItems': 50,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'actorId',
          'displayName',
          'persona',
          'status',
          'guestMoment',
          'optedOut',
          'keepApartActorIds',
          'helpRequested',
          'promptCompleted',
          'layoutUnitId',
          'confirmedLayoutUnitId',
        ],
        'properties': <String, Object?>{
          'actorId': <String, Object?>{
            'type': 'string',
          },
          'displayName': <String, Object?>{
            'type': 'string',
          },
          'persona': <String, Object?>{
            'type': 'string',
          },
          'status': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'expected',
              'present',
              'late',
              'noShow',
              'departed',
              'returned',
              'disconnected',
              'walkIn',
              'ambiguousClaim',
            ],
          },
          'connectionState': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'connected',
              'disconnected',
            ],
          },
          'guestMoment': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'welcome',
              'checkIn',
              'firstHello',
              'assignment',
              'rotation',
              'pause',
              'reveal',
              'afterglow',
              'complete',
            ],
          },
          'optedOut': <String, Object?>{
            'type': 'boolean',
          },
          'keepApartActorIds': <String, Object?>{
            'type': 'array',
            'items': <String, Object?>{
              'type': 'string',
            },
          },
          'helpRequested': <String, Object?>{
            'type': 'boolean',
          },
          'promptCompleted': <String, Object?>{
            'type': 'boolean',
          },
          'layoutUnitId': <String, Object?>{
            'type': <Object?>[
              'string',
              'null',
            ],
          },
          'confirmedLayoutUnitId': <String, Object?>{
            'type': <Object?>[
              'string',
              'null',
            ],
          },
          'assistance': <String, Object?>{
            'type': 'object',
            'additionalProperties': false,
            'required': <Object?>[
              'intention',
              'latestMessageId',
            ],
            'properties': <String, Object?>{
              'intention': <String, Object?>{
                'anyOf': <Object?>[
                  <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'kind',
                    ],
                    'properties': <String, Object?>{
                      'kind': <String, Object?>{
                        'type': 'string',
                        'const': 'unknown',
                      },
                    },
                  },
                  <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'kind',
                      'claimedEta',
                    ],
                    'properties': <String, Object?>{
                      'kind': <String, Object?>{
                        'type': 'string',
                        'const': 'onMyWay',
                      },
                      'claimedEta': <String, Object?>{
                        'anyOf': <Object?>[
                          <String, Object?>{
                            'type': 'integer',
                            'minimum': 0,
                            'maximum': 9007199254740991,
                            'description': 'UTC milliseconds.',
                          },
                          <String, Object?>{
                            'type': 'null',
                            'const': null,
                          },
                        ],
                      },
                    },
                  },
                  <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'kind',
                      'target',
                    ],
                    'properties': <String, Object?>{
                      'kind': <String, Object?>{
                        'type': 'string',
                        'const': 'joinLater',
                      },
                      'target': <String, Object?>{
                        'anyOf': <Object?>[
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                              'placeId',
                              'lateEntry',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'type': 'string',
                                'const': 'fixedPlace',
                              },
                              'placeId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 160,
                                'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                              },
                              'lateEntry': <String, Object?>{
                                'type': 'string',
                                'enum': <Object?>[
                                  'allowed',
                                  'hostDecision',
                                  'closed',
                                ],
                              },
                            },
                          },
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                              'itineraryId',
                              'stopId',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'type': 'string',
                                'const': 'itineraryStop',
                              },
                              'itineraryId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 2000,
                              },
                              'stopId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 2000,
                              },
                            },
                          },
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                              'routeId',
                              'groupId',
                              'checkpointId',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'type': 'string',
                                'const': 'groupCheckpoint',
                              },
                              'routeId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 2000,
                              },
                              'groupId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 160,
                                'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                              },
                              'checkpointId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 2000,
                              },
                            },
                          },
                        ],
                      },
                    },
                  },
                  <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'kind',
                    ],
                    'properties': <String, Object?>{
                      'kind': <String, Object?>{
                        'type': 'string',
                        'const': 'notComing',
                      },
                    },
                  },
                ],
              },
              'latestMessageId': <String, Object?>{
                'anyOf': <Object?>[
                  <String, Object?>{
                    'type': 'string',
                    'pattern': '^outbox:[a-f0-9]{64}\$',
                  },
                  <String, Object?>{
                    'type': 'null',
                  },
                ],
              },
            },
          },
          'assistanceMessage': <String, Object?>{
            'anyOf': <Object?>[
              <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'messageId',
                  'intentId',
                  'intentRevision',
                  'text',
                  'choices',
                  'lifecycle',
                  'expiresAt',
                  'canRespond',
                  'responseChoiceId',
                ],
                'properties': <String, Object?>{
                  'messageId': <String, Object?>{
                    'type': 'string',
                    'pattern': '^outbox:[a-f0-9]{64}\$',
                  },
                  'intentId': <String, Object?>{
                    'type': 'string',
                  },
                  'intentRevision': <String, Object?>{
                    'type': 'integer',
                    'minimum': 1,
                    'maximum': 9007199254740991,
                  },
                  'text': <String, Object?>{
                    'type': 'string',
                    'maxLength': 2000,
                  },
                  'choices': <String, Object?>{
                    'type': 'array',
                    'maxItems': 20,
                    'items': <String, Object?>{
                      'type': 'object',
                      'additionalProperties': false,
                      'required': <Object?>[
                        'choiceId',
                        'label',
                      ],
                      'properties': <String, Object?>{
                        'choiceId': <String, Object?>{
                          'type': 'string',
                        },
                        'label': <String, Object?>{
                          'type': 'string',
                          'maxLength': 80,
                        },
                      },
                    },
                  },
                  'lifecycle': <String, Object?>{
                    'type': 'string',
                    'enum': <Object?>[
                      'active',
                      'cancelled',
                      'superseded',
                      'responded',
                    ],
                  },
                  'expiresAt': <String, Object?>{
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 9007199254740991,
                  },
                  'canRespond': <String, Object?>{
                    'type': 'boolean',
                  },
                  'responseChoiceId': <String, Object?>{
                    'anyOf': <Object?>[
                      <String, Object?>{
                        'type': 'string',
                      },
                      <String, Object?>{
                        'type': 'null',
                      },
                    ],
                  },
                },
              },
              <String, Object?>{
                'type': 'null',
              },
            ],
          },
          'assistanceDelivery': <String, Object?>{
            'anyOf': <Object?>[
              <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'conflictingEvidence',
                  'attempts',
                ],
                'properties': <String, Object?>{
                  'conflictingEvidence': <String, Object?>{
                    'type': 'boolean',
                  },
                  'attempts': <String, Object?>{
                    'type': 'array',
                    'maxItems': 6,
                    'items': <String, Object?>{
                      'type': 'object',
                      'additionalProperties': false,
                      'required': <Object?>[
                        'attemptId',
                        'routeId',
                        'status',
                      ],
                      'properties': <String, Object?>{
                        'attemptId': <String, Object?>{
                          'type': 'string',
                        },
                        'routeId': <String, Object?>{
                          'type': 'string',
                          'enum': <Object?>[
                            'catchEventSms',
                            'catchEventRcs',
                            'organizerEventWhatsapp',
                          ],
                        },
                        'status': <String, Object?>{
                          'type': 'string',
                          'enum': <Object?>[
                            'notDispatched',
                            'reserved',
                            'unknown',
                            'accepted',
                            'delivered',
                            'read',
                            'failed',
                            'revoked',
                          ],
                        },
                      },
                    },
                  },
                },
              },
              <String, Object?>{
                'type': 'null',
              },
            ],
          },
          'assistanceAutomation': <String, Object?>{
            'type': 'object',
            'additionalProperties': false,
            'required': <Object?>[
              'clockId',
              'status',
              'plan',
              'outcomes',
              'nextOutcomeIndex',
              'evaluation',
            ],
            'properties': <String, Object?>{
              'clockId': <String, Object?>{
                'type': 'string',
                'pattern': '^clock:[a-f0-9]{64}\$',
              },
              'status': <String, Object?>{
                'type': 'string',
                'enum': <Object?>[
                  'enabled',
                  'paused',
                ],
              },
              'plan': <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'policy',
                  'guidance',
                  'departureConfirmed',
                  'responseDeadline',
                  'routes',
                  'deliveryPolicy',
                ],
                'properties': <String, Object?>{
                  'policy': <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'destination',
                      'cutoff',
                      'maxMessagesPerEpisode',
                      'minimumMinutesBetweenMessages',
                      'updateOn',
                      'unanswered',
                    ],
                    'properties': <String, Object?>{
                      'destination': <String, Object?>{
                        'anyOf': <Object?>[
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                              'placeId',
                              'lateEntry',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'type': 'string',
                                'const': 'fixedPlace',
                              },
                              'placeId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 160,
                                'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                              },
                              'lateEntry': <String, Object?>{
                                'type': 'string',
                                'enum': <Object?>[
                                  'allowed',
                                  'hostDecision',
                                  'closed',
                                ],
                              },
                            },
                          },
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                              'itineraryId',
                              'permittedStopIds',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'type': 'string',
                                'const': 'itineraryStop',
                              },
                              'itineraryId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 2000,
                              },
                              'permittedStopIds': <String, Object?>{
                                'type': 'array',
                                'minItems': 1,
                                'maxItems': 1000,
                                'items': <String, Object?>{
                                  'type': 'string',
                                  'minLength': 1,
                                  'maxLength': 2000,
                                },
                                'uniqueItems': true,
                              },
                            },
                          },
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                              'routeId',
                              'groupId',
                              'permittedCheckpointIds',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'type': 'string',
                                'const': 'groupCheckpoint',
                              },
                              'routeId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 2000,
                              },
                              'groupId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 160,
                                'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                              },
                              'permittedCheckpointIds': <String, Object?>{
                                'type': 'array',
                                'minItems': 1,
                                'maxItems': 1000,
                                'items': <String, Object?>{
                                  'type': 'string',
                                  'minLength': 1,
                                  'maxLength': 2000,
                                },
                                'uniqueItems': true,
                              },
                            },
                          },
                        ],
                      },
                      'cutoff': <String, Object?>{
                        'anyOf': <Object?>[
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'type': 'string',
                                'const': 'eventEnd',
                              },
                            },
                          },
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                              'at',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'type': 'string',
                                'const': 'time',
                              },
                              'at': <String, Object?>{
                                'type': 'integer',
                                'minimum': 0,
                                'maximum': 9007199254740991,
                                'description': 'UTC milliseconds.',
                              },
                            },
                          },
                        ],
                      },
                      'maxMessagesPerEpisode': <String, Object?>{
                        'type': 'integer',
                        'minimum': 0,
                        'maximum': 100,
                      },
                      'minimumMinutesBetweenMessages': <String, Object?>{
                        'type': 'integer',
                        'minimum': 0,
                        'maximum': 1440,
                      },
                      'updateOn': <String, Object?>{
                        'type': 'string',
                        'const': 'materialGuidanceChange',
                      },
                      'unanswered': <String, Object?>{
                        'type': 'string',
                        'enum': <Object?>[
                          'keepUnknownUntilCutoff',
                          'hostReviewAtDeadline',
                        ],
                      },
                    },
                  },
                  'guidance': <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'revision',
                      'destination',
                      'materialKey',
                      'text',
                      'validUntil',
                    ],
                    'properties': <String, Object?>{
                      'revision': <String, Object?>{
                        'type': 'integer',
                        'minimum': 0,
                        'maximum': 9007199254740991,
                        'description': 'Nonnegative safe integer revision.',
                      },
                      'destination': <String, Object?>{
                        'anyOf': <Object?>[
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                              'placeId',
                              'lateEntry',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'type': 'string',
                                'const': 'fixedPlace',
                              },
                              'placeId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 160,
                                'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                              },
                              'lateEntry': <String, Object?>{
                                'type': 'string',
                                'enum': <Object?>[
                                  'allowed',
                                  'hostDecision',
                                  'closed',
                                ],
                              },
                            },
                          },
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                              'itineraryId',
                              'stopId',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'type': 'string',
                                'const': 'itineraryStop',
                              },
                              'itineraryId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 2000,
                              },
                              'stopId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 2000,
                              },
                            },
                          },
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                              'routeId',
                              'groupId',
                              'checkpointId',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'type': 'string',
                                'const': 'groupCheckpoint',
                              },
                              'routeId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 2000,
                              },
                              'groupId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 160,
                                'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                              },
                              'checkpointId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 2000,
                              },
                            },
                          },
                        ],
                      },
                      'materialKey': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 2000,
                      },
                      'text': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 2000,
                      },
                      'validUntil': <String, Object?>{
                        'type': 'integer',
                        'minimum': 0,
                        'maximum': 9007199254740991,
                        'description': 'UTC milliseconds.',
                      },
                    },
                  },
                  'departureConfirmed': <String, Object?>{
                    'type': 'boolean',
                  },
                  'responseDeadline': <String, Object?>{
                    'anyOf': <Object?>[
                      <String, Object?>{
                        'type': 'integer',
                        'minimum': 0,
                        'maximum': 9007199254740991,
                      },
                      <String, Object?>{
                        'type': 'null',
                      },
                    ],
                  },
                  'routes': <String, Object?>{
                    'type': 'array',
                    'minItems': 1,
                    'maxItems': 3,
                    'uniqueItems': true,
                    'items': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'catchEventSms',
                        'catchEventRcs',
                        'organizerEventWhatsapp',
                      ],
                    },
                  },
                  'deliveryPolicy': <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'maxAttempts',
                      'maxAttemptsPerRoute',
                      'minimumRetrySeconds',
                    ],
                    'properties': <String, Object?>{
                      'maxAttempts': <String, Object?>{
                        'type': 'integer',
                        'minimum': 1,
                        'maximum': 6,
                      },
                      'maxAttemptsPerRoute': <String, Object?>{
                        'type': 'integer',
                        'minimum': 1,
                        'maximum': 3,
                      },
                      'minimumRetrySeconds': <String, Object?>{
                        'type': 'integer',
                        'minimum': 1,
                        'maximum': 3600,
                      },
                    },
                  },
                  'laterChoices': <String, Object?>{
                    'type': 'array',
                    'maxItems': 17,
                    'items': <String, Object?>{
                      'type': 'object',
                      'additionalProperties': false,
                      'required': <Object?>[
                        'label',
                        'target',
                      ],
                      'properties': <String, Object?>{
                        'label': <String, Object?>{
                          'type': 'string',
                          'minLength': 1,
                          'maxLength': 80,
                        },
                        'target': <String, Object?>{
                          'anyOf': <Object?>[
                            <String, Object?>{
                              'type': 'object',
                              'additionalProperties': false,
                              'required': <Object?>[
                                'kind',
                                'placeId',
                                'lateEntry',
                              ],
                              'properties': <String, Object?>{
                                'kind': <String, Object?>{
                                  'type': 'string',
                                  'const': 'fixedPlace',
                                },
                                'placeId': <String, Object?>{
                                  'type': 'string',
                                  'minLength': 1,
                                  'maxLength': 160,
                                  'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                                },
                                'lateEntry': <String, Object?>{
                                  'type': 'string',
                                  'enum': <Object?>[
                                    'allowed',
                                    'hostDecision',
                                    'closed',
                                  ],
                                },
                              },
                            },
                            <String, Object?>{
                              'type': 'object',
                              'additionalProperties': false,
                              'required': <Object?>[
                                'kind',
                                'itineraryId',
                                'stopId',
                              ],
                              'properties': <String, Object?>{
                                'kind': <String, Object?>{
                                  'type': 'string',
                                  'const': 'itineraryStop',
                                },
                                'itineraryId': <String, Object?>{
                                  'type': 'string',
                                  'minLength': 1,
                                  'maxLength': 2000,
                                },
                                'stopId': <String, Object?>{
                                  'type': 'string',
                                  'minLength': 1,
                                  'maxLength': 2000,
                                },
                              },
                            },
                            <String, Object?>{
                              'type': 'object',
                              'additionalProperties': false,
                              'required': <Object?>[
                                'kind',
                                'routeId',
                                'groupId',
                                'checkpointId',
                              ],
                              'properties': <String, Object?>{
                                'kind': <String, Object?>{
                                  'type': 'string',
                                  'const': 'groupCheckpoint',
                                },
                                'routeId': <String, Object?>{
                                  'type': 'string',
                                  'minLength': 1,
                                  'maxLength': 2000,
                                },
                                'groupId': <String, Object?>{
                                  'type': 'string',
                                  'minLength': 1,
                                  'maxLength': 160,
                                  'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                                },
                                'checkpointId': <String, Object?>{
                                  'type': 'string',
                                  'minLength': 1,
                                  'maxLength': 2000,
                                },
                              },
                            },
                          ],
                        },
                      },
                    },
                  },
                },
                'if': <String, Object?>{
                  'properties': <String, Object?>{
                    'policy': <String, Object?>{
                      'properties': <String, Object?>{
                        'unanswered': <String, Object?>{
                          'const': 'hostReviewAtDeadline',
                        },
                      },
                    },
                  },
                },
                'then': <String, Object?>{
                  'properties': <String, Object?>{
                    'responseDeadline': <String, Object?>{
                      'type': 'integer',
                    },
                  },
                },
              },
              'outcomes': <String, Object?>{
                'type': 'array',
                'minItems': 1,
                'maxItems': 6,
                'items': <String, Object?>{
                  'oneOf': <Object?>[
                    <String, Object?>{
                      'type': 'object',
                      'additionalProperties': false,
                      'required': <Object?>[
                        'kind',
                      ],
                      'properties': <String, Object?>{
                        'kind': <String, Object?>{
                          'type': 'string',
                          'enum': <Object?>[
                            'accepted',
                            'delivered',
                            'read',
                            'revoked',
                          ],
                        },
                      },
                    },
                    <String, Object?>{
                      'type': 'object',
                      'additionalProperties': false,
                      'required': <Object?>[
                        'kind',
                        'classification',
                      ],
                      'properties': <String, Object?>{
                        'kind': <String, Object?>{
                          'const': 'failed',
                        },
                        'classification': <String, Object?>{
                          'type': 'string',
                          'enum': <Object?>[
                            'technical',
                            'policy',
                            'suppressed',
                            'invalidRecipient',
                          ],
                        },
                      },
                    },
                    <String, Object?>{
                      'type': 'object',
                      'additionalProperties': false,
                      'required': <Object?>[
                        'kind',
                        'reason',
                      ],
                      'properties': <String, Object?>{
                        'kind': <String, Object?>{
                          'const': 'unknown',
                        },
                        'reason': <String, Object?>{
                          'type': 'string',
                          'enum': <Object?>[
                            'timeout',
                            'connectionLost',
                            'workerInterrupted',
                          ],
                        },
                      },
                    },
                  ],
                },
              },
              'nextOutcomeIndex': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 6,
              },
              'evaluation': <String, Object?>{
                'anyOf': <Object?>[
                  <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'at',
                      'policy',
                      'delivery',
                    ],
                    'properties': <String, Object?>{
                      'at': <String, Object?>{
                        'type': 'integer',
                        'minimum': 0,
                        'maximum': 9007199254740991,
                      },
                      'policy': <String, Object?>{
                        'anyOf': <Object?>[
                          <String, Object?>{
                            'anyOf': <Object?>[
                              <String, Object?>{
                                'type': 'object',
                                'additionalProperties': false,
                                'required': <Object?>[
                                  'kind',
                                  'reason',
                                ],
                                'properties': <String, Object?>{
                                  'kind': <String, Object?>{
                                    'type': 'string',
                                    'const': 'resolved',
                                  },
                                  'reason': <String, Object?>{
                                    'type': 'string',
                                    'enum': <Object?>[
                                      'joined',
                                      'declined',
                                    ],
                                  },
                                },
                              },
                              <String, Object?>{
                                'type': 'object',
                                'additionalProperties': false,
                                'required': <Object?>[
                                  'kind',
                                  'reason',
                                ],
                                'properties': <String, Object?>{
                                  'kind': <String, Object?>{
                                    'type': 'string',
                                    'const': 'cancelled',
                                  },
                                  'reason': <String, Object?>{
                                    'type': 'string',
                                    'enum': <Object?>[
                                      'eventClosed',
                                      'notAdmitted',
                                      'policyDisabled',
                                      'participationInactive',
                                    ],
                                  },
                                },
                              },
                              <String, Object?>{
                                'type': 'object',
                                'additionalProperties': false,
                                'required': <Object?>[
                                  'kind',
                                  'reason',
                                ],
                                'properties': <String, Object?>{
                                  'kind': <String, Object?>{
                                    'type': 'string',
                                    'const': 'expired',
                                  },
                                  'reason': <String, Object?>{
                                    'type': 'string',
                                    'enum': <Object?>[
                                      'cutoff',
                                      'lateEntryClosed',
                                    ],
                                  },
                                },
                              },
                              <String, Object?>{
                                'type': 'object',
                                'additionalProperties': false,
                                'required': <Object?>[
                                  'kind',
                                  'reason',
                                ],
                                'properties': <String, Object?>{
                                  'kind': <String, Object?>{
                                    'type': 'string',
                                    'const': 'wait',
                                  },
                                  'reason': <String, Object?>{
                                    'type': 'string',
                                    'enum': <Object?>[
                                      'departureUnconfirmed',
                                      'attendanceUnknown',
                                      'guidanceUnavailable',
                                      'throttled',
                                      'unchanged',
                                      'participationUnknown',
                                    ],
                                  },
                                },
                              },
                              <String, Object?>{
                                'type': 'object',
                                'additionalProperties': false,
                                'required': <Object?>[
                                  'kind',
                                  'reason',
                                  'guidance',
                                ],
                                'properties': <String, Object?>{
                                  'kind': <String, Object?>{
                                    'type': 'string',
                                    'const': 'hostDecision',
                                  },
                                  'reason': <String, Object?>{
                                    'type': 'string',
                                    'enum': <Object?>[
                                      'unreachable',
                                      'entryDecision',
                                      'missingInformation',
                                    ],
                                  },
                                  'guidance': <String, Object?>{
                                    'anyOf': <Object?>[
                                      <String, Object?>{
                                        'type': 'object',
                                        'additionalProperties': false,
                                        'required': <Object?>[
                                          'revision',
                                          'destination',
                                          'materialKey',
                                          'text',
                                          'validUntil',
                                        ],
                                        'properties': <String, Object?>{
                                          'revision': <String, Object?>{
                                            'type': 'integer',
                                            'minimum': 0,
                                            'maximum': 9007199254740991,
                                            'description': 'Nonnegative safe integer revision.',
                                          },
                                          'destination': <String, Object?>{
                                            'anyOf': <Object?>[
                                              <String, Object?>{
                                                'type': 'object',
                                                'additionalProperties': false,
                                                'required': <Object?>[
                                                  'kind',
                                                  'placeId',
                                                  'lateEntry',
                                                ],
                                                'properties': <String, Object?>{
                                                  'kind': <String, Object?>{
                                                    'type': 'string',
                                                    'const': 'fixedPlace',
                                                  },
                                                  'placeId': <String, Object?>{
                                                    'type': 'string',
                                                    'minLength': 1,
                                                    'maxLength': 160,
                                                    'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                                                  },
                                                  'lateEntry': <String, Object?>{
                                                    'type': 'string',
                                                    'enum': <Object?>[
                                                      'allowed',
                                                      'hostDecision',
                                                      'closed',
                                                    ],
                                                  },
                                                },
                                              },
                                              <String, Object?>{
                                                'type': 'object',
                                                'additionalProperties': false,
                                                'required': <Object?>[
                                                  'kind',
                                                  'itineraryId',
                                                  'stopId',
                                                ],
                                                'properties': <String, Object?>{
                                                  'kind': <String, Object?>{
                                                    'type': 'string',
                                                    'const': 'itineraryStop',
                                                  },
                                                  'itineraryId': <String, Object?>{
                                                    'type': 'string',
                                                    'minLength': 1,
                                                    'maxLength': 2000,
                                                  },
                                                  'stopId': <String, Object?>{
                                                    'type': 'string',
                                                    'minLength': 1,
                                                    'maxLength': 2000,
                                                  },
                                                },
                                              },
                                              <String, Object?>{
                                                'type': 'object',
                                                'additionalProperties': false,
                                                'required': <Object?>[
                                                  'kind',
                                                  'routeId',
                                                  'groupId',
                                                  'checkpointId',
                                                ],
                                                'properties': <String, Object?>{
                                                  'kind': <String, Object?>{
                                                    'type': 'string',
                                                    'const': 'groupCheckpoint',
                                                  },
                                                  'routeId': <String, Object?>{
                                                    'type': 'string',
                                                    'minLength': 1,
                                                    'maxLength': 2000,
                                                  },
                                                  'groupId': <String, Object?>{
                                                    'type': 'string',
                                                    'minLength': 1,
                                                    'maxLength': 160,
                                                    'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                                                  },
                                                  'checkpointId': <String, Object?>{
                                                    'type': 'string',
                                                    'minLength': 1,
                                                    'maxLength': 2000,
                                                  },
                                                },
                                              },
                                            ],
                                          },
                                          'materialKey': <String, Object?>{
                                            'type': 'string',
                                            'minLength': 1,
                                            'maxLength': 2000,
                                          },
                                          'text': <String, Object?>{
                                            'type': 'string',
                                            'minLength': 1,
                                            'maxLength': 2000,
                                          },
                                          'validUntil': <String, Object?>{
                                            'type': 'integer',
                                            'minimum': 0,
                                            'maximum': 9007199254740991,
                                            'description': 'UTC milliseconds.',
                                          },
                                        },
                                      },
                                      <String, Object?>{
                                        'type': 'null',
                                        'const': null,
                                      },
                                    ],
                                  },
                                },
                              },
                              <String, Object?>{
                                'type': 'object',
                                'additionalProperties': false,
                                'required': <Object?>[
                                  'kind',
                                  'guidance',
                                  'messageKey',
                                  'shouldSend',
                                  'nextEvaluationAt',
                                ],
                                'properties': <String, Object?>{
                                  'kind': <String, Object?>{
                                    'type': 'string',
                                    'const': 'update',
                                  },
                                  'guidance': <String, Object?>{
                                    'type': 'object',
                                    'additionalProperties': false,
                                    'required': <Object?>[
                                      'revision',
                                      'destination',
                                      'materialKey',
                                      'text',
                                      'validUntil',
                                    ],
                                    'properties': <String, Object?>{
                                      'revision': <String, Object?>{
                                        'type': 'integer',
                                        'minimum': 0,
                                        'maximum': 9007199254740991,
                                        'description': 'Nonnegative safe integer revision.',
                                      },
                                      'destination': <String, Object?>{
                                        'anyOf': <Object?>[
                                          <String, Object?>{
                                            'type': 'object',
                                            'additionalProperties': false,
                                            'required': <Object?>[
                                              'kind',
                                              'placeId',
                                              'lateEntry',
                                            ],
                                            'properties': <String, Object?>{
                                              'kind': <String, Object?>{
                                                'type': 'string',
                                                'const': 'fixedPlace',
                                              },
                                              'placeId': <String, Object?>{
                                                'type': 'string',
                                                'minLength': 1,
                                                'maxLength': 160,
                                                'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                                              },
                                              'lateEntry': <String, Object?>{
                                                'type': 'string',
                                                'enum': <Object?>[
                                                  'allowed',
                                                  'hostDecision',
                                                  'closed',
                                                ],
                                              },
                                            },
                                          },
                                          <String, Object?>{
                                            'type': 'object',
                                            'additionalProperties': false,
                                            'required': <Object?>[
                                              'kind',
                                              'itineraryId',
                                              'stopId',
                                            ],
                                            'properties': <String, Object?>{
                                              'kind': <String, Object?>{
                                                'type': 'string',
                                                'const': 'itineraryStop',
                                              },
                                              'itineraryId': <String, Object?>{
                                                'type': 'string',
                                                'minLength': 1,
                                                'maxLength': 2000,
                                              },
                                              'stopId': <String, Object?>{
                                                'type': 'string',
                                                'minLength': 1,
                                                'maxLength': 2000,
                                              },
                                            },
                                          },
                                          <String, Object?>{
                                            'type': 'object',
                                            'additionalProperties': false,
                                            'required': <Object?>[
                                              'kind',
                                              'routeId',
                                              'groupId',
                                              'checkpointId',
                                            ],
                                            'properties': <String, Object?>{
                                              'kind': <String, Object?>{
                                                'type': 'string',
                                                'const': 'groupCheckpoint',
                                              },
                                              'routeId': <String, Object?>{
                                                'type': 'string',
                                                'minLength': 1,
                                                'maxLength': 2000,
                                              },
                                              'groupId': <String, Object?>{
                                                'type': 'string',
                                                'minLength': 1,
                                                'maxLength': 160,
                                                'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                                              },
                                              'checkpointId': <String, Object?>{
                                                'type': 'string',
                                                'minLength': 1,
                                                'maxLength': 2000,
                                              },
                                            },
                                          },
                                        ],
                                      },
                                      'materialKey': <String, Object?>{
                                        'type': 'string',
                                        'minLength': 1,
                                        'maxLength': 2000,
                                      },
                                      'text': <String, Object?>{
                                        'type': 'string',
                                        'minLength': 1,
                                        'maxLength': 2000,
                                      },
                                      'validUntil': <String, Object?>{
                                        'type': 'integer',
                                        'minimum': 0,
                                        'maximum': 9007199254740991,
                                        'description': 'UTC milliseconds.',
                                      },
                                    },
                                  },
                                  'messageKey': <String, Object?>{
                                    'type': 'string',
                                    'minLength': 1,
                                    'maxLength': 2000,
                                  },
                                  'shouldSend': <String, Object?>{
                                    'type': 'boolean',
                                  },
                                  'nextEvaluationAt': <String, Object?>{
                                    'anyOf': <Object?>[
                                      <String, Object?>{
                                        'type': 'integer',
                                        'minimum': 0,
                                        'maximum': 9007199254740991,
                                      },
                                      <String, Object?>{
                                        'type': 'null',
                                      },
                                    ],
                                  },
                                },
                              },
                            ],
                          },
                          <String, Object?>{
                            'type': 'null',
                          },
                        ],
                      },
                      'delivery': <String, Object?>{
                        'oneOf': <Object?>[
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'const': 'paused',
                              },
                            },
                          },
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'const': 'notApplicable',
                              },
                            },
                          },
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'const': 'scriptExhausted',
                              },
                            },
                          },
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                              'reason',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'const': 'stop',
                              },
                              'reason': <String, Object?>{
                                'type': 'string',
                                'enum': <Object?>[
                                  'responded',
                                  'cancelled',
                                  'superseded',
                                  'expired',
                                  'eventClosed',
                                  'permissionRevoked',
                                  'guestPresent',
                                  'guestDeclined',
                                  'notAdmitted',
                                  'hostStopped',
                                  'participationInactive',
                                ],
                              },
                            },
                          },
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                              'attemptIds',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'const': 'delivered',
                              },
                              'attemptIds': <String, Object?>{
                                'type': 'array',
                                'maxItems': 6,
                                'items': <String, Object?>{
                                  'type': 'string',
                                },
                              },
                            },
                          },
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                              'attemptIds',
                              'notBefore',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'const': 'reconcile',
                              },
                              'attemptIds': <String, Object?>{
                                'type': 'array',
                                'maxItems': 6,
                                'items': <String, Object?>{
                                  'type': 'string',
                                },
                              },
                              'notBefore': <String, Object?>{
                                'type': 'integer',
                                'minimum': 0,
                                'maximum': 9007199254740991,
                              },
                            },
                          },
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                              'reason',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'const': 'refreshFacts',
                              },
                              'reason': <String, Object?>{
                                'type': 'string',
                                'enum': <Object?>[
                                  'eventFactsStale',
                                  'routeFactsStale',
                                ],
                              },
                            },
                          },
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                              'notBefore',
                              'reason',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'const': 'wait',
                              },
                              'notBefore': <String, Object?>{
                                'type': 'integer',
                                'minimum': 0,
                                'maximum': 9007199254740991,
                              },
                              'reason': <String, Object?>{
                                'const': 'retryBackoff',
                              },
                            },
                          },
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                              'reason',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'const': 'hostDecision',
                              },
                              'reason': <String, Object?>{
                                'type': 'string',
                                'enum': <Object?>[
                                  'noEligibleRoute',
                                  'attemptLimit',
                                  'policyRejected',
                                  'recipientNeedsReview',
                                  'providerOwnsFallback',
                                  'conflictingDeliveryEvidence',
                                  'historyUnavailable',
                                ],
                              },
                            },
                          },
                        ],
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
        },
      },
    },
    'actions': <String, Object?>{
      'type': 'array',
      'maxItems': 500,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'clientActionId',
          'actorId',
          'kind',
          'name',
          'runtimeRevision',
          'virtualNowMillis',
        ],
        'properties': <String, Object?>{
          'clientActionId': <String, Object?>{
            'type': 'string',
          },
          'actorId': <String, Object?>{
            'type': <Object?>[
              'string',
              'null',
            ],
          },
          'kind': <String, Object?>{
            'type': 'string',
          },
          'name': <String, Object?>{
            'type': 'string',
          },
          'runtimeRevision': <String, Object?>{
            'type': 'integer',
          },
          'virtualNowMillis': <String, Object?>{
            'type': 'integer',
          },
        },
      },
    },
    'guestUrl': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 500,
    },
    'canUseInternalFaults': <String, Object?>{
      'type': 'boolean',
    },
    'helpRequests': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'clockId',
        'coverage',
        'cases',
        'untrackedActorIds',
      ],
      'properties': <String, Object?>{
        'clockId': <String, Object?>{
          'type': 'string',
          'pattern': '^clock:[a-f0-9]{64}\$',
        },
        'coverage': <String, Object?>{
          'const': 'boundedSession',
        },
        'cases': <String, Object?>{
          'type': 'array',
          'maxItems': 500,
          'items': <String, Object?>{
            'oneOf': <Object?>[
              <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'caseId',
                  'revision',
                  'sourceHash',
                  'availability',
                  'attendeeId',
                  'category',
                  'receivedAt',
                  'status',
                  'resolution',
                  'canChange',
                  'assignment',
                ],
                'properties': <String, Object?>{
                  'caseId': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 160,
                    'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                  },
                  'revision': <String, Object?>{
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 9007199254740991,
                  },
                  'sourceHash': <String, Object?>{
                    'type': 'string',
                    'pattern': '^[a-f0-9]{64}\$',
                  },
                  'availability': <String, Object?>{
                    'const': 'current',
                  },
                  'attendeeId': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 160,
                    'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                  },
                  'category': <String, Object?>{
                    'enum': <Object?>[
                      'eventLogistics',
                      'accessibility',
                      'other',
                    ],
                  },
                  'receivedAt': <String, Object?>{
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 9007199254740991,
                  },
                  'status': <String, Object?>{
                    'const': 'open',
                  },
                  'resolution': <String, Object?>{
                    'type': 'null',
                  },
                  'canChange': <String, Object?>{
                    'const': true,
                  },
                  'assignment': <String, Object?>{
                    'oneOf': <Object?>[
                      <String, Object?>{
                        'type': 'object',
                        'additionalProperties': false,
                        'required': <Object?>[
                          'kind',
                        ],
                        'properties': <String, Object?>{
                          'kind': <String, Object?>{
                            'const': 'unassigned',
                          },
                        },
                      },
                      <String, Object?>{
                        'type': 'object',
                        'additionalProperties': false,
                        'required': <Object?>[
                          'kind',
                          'uid',
                          'authority',
                        ],
                        'properties': <String, Object?>{
                          'kind': <String, Object?>{
                            'const': 'assigned',
                          },
                          'uid': <String, Object?>{
                            'type': 'string',
                            'minLength': 1,
                            'maxLength': 160,
                            'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                          },
                          'authority': <String, Object?>{
                            'enum': <Object?>[
                              'current',
                              'revoked',
                            ],
                          },
                        },
                      },
                    ],
                  },
                },
              },
              <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'caseId',
                  'revision',
                  'sourceHash',
                  'availability',
                  'attendeeId',
                  'category',
                  'receivedAt',
                  'status',
                  'resolution',
                  'canChange',
                  'assignment',
                ],
                'properties': <String, Object?>{
                  'caseId': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 160,
                    'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                  },
                  'revision': <String, Object?>{
                    'type': 'integer',
                    'minimum': 1,
                    'maximum': 9007199254740991,
                  },
                  'sourceHash': <String, Object?>{
                    'type': 'string',
                    'pattern': '^[a-f0-9]{64}\$',
                  },
                  'availability': <String, Object?>{
                    'const': 'current',
                  },
                  'attendeeId': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 160,
                    'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                  },
                  'category': <String, Object?>{
                    'enum': <Object?>[
                      'eventLogistics',
                      'accessibility',
                      'other',
                    ],
                  },
                  'receivedAt': <String, Object?>{
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 9007199254740991,
                  },
                  'status': <String, Object?>{
                    'const': 'resolved',
                  },
                  'resolution': <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'outcome',
                      'actorUid',
                      'at',
                    ],
                    'properties': <String, Object?>{
                      'outcome': <String, Object?>{
                        'enum': <Object?>[
                          'resolved',
                          'declined',
                        ],
                      },
                      'actorUid': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 160,
                        'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                      },
                      'at': <String, Object?>{
                        'type': 'integer',
                        'minimum': 0,
                        'maximum': 9007199254740991,
                      },
                    },
                  },
                  'canChange': <String, Object?>{
                    'const': false,
                  },
                  'assignment': <String, Object?>{
                    'oneOf': <Object?>[
                      <String, Object?>{
                        'type': 'object',
                        'additionalProperties': false,
                        'required': <Object?>[
                          'kind',
                        ],
                        'properties': <String, Object?>{
                          'kind': <String, Object?>{
                            'const': 'unassigned',
                          },
                        },
                      },
                      <String, Object?>{
                        'type': 'object',
                        'additionalProperties': false,
                        'required': <Object?>[
                          'kind',
                          'uid',
                          'authority',
                        ],
                        'properties': <String, Object?>{
                          'kind': <String, Object?>{
                            'const': 'assigned',
                          },
                          'uid': <String, Object?>{
                            'type': 'string',
                            'minLength': 1,
                            'maxLength': 160,
                            'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                          },
                          'authority': <String, Object?>{
                            'enum': <Object?>[
                              'current',
                              'revoked',
                            ],
                          },
                        },
                      },
                    ],
                  },
                },
              },
              <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'caseId',
                  'revision',
                  'sourceHash',
                  'availability',
                  'attendeeId',
                  'category',
                  'receivedAt',
                  'status',
                  'resolution',
                  'canChange',
                  'assignment',
                ],
                'properties': <String, Object?>{
                  'caseId': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 160,
                    'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                  },
                  'revision': <String, Object?>{
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 9007199254740991,
                  },
                  'sourceHash': <String, Object?>{
                    'type': 'string',
                    'pattern': '^[a-f0-9]{64}\$',
                  },
                  'availability': <String, Object?>{
                    'const': 'sourceChanged',
                  },
                  'attendeeId': <String, Object?>{
                    'type': 'null',
                  },
                  'category': <String, Object?>{
                    'enum': <Object?>[
                      'eventLogistics',
                      'accessibility',
                      'other',
                    ],
                  },
                  'receivedAt': <String, Object?>{
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 9007199254740991,
                  },
                  'status': <String, Object?>{
                    'enum': <Object?>[
                      'open',
                      'resolved',
                    ],
                  },
                  'resolution': <String, Object?>{
                    'type': 'null',
                  },
                  'canChange': <String, Object?>{
                    'const': false,
                  },
                  'assignment': <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'kind',
                    ],
                    'properties': <String, Object?>{
                      'kind': <String, Object?>{
                        'const': 'unavailable',
                      },
                    },
                  },
                },
              },
              <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'caseId',
                  'revision',
                  'sourceHash',
                  'availability',
                  'attendeeId',
                  'category',
                  'receivedAt',
                  'status',
                  'resolution',
                  'canChange',
                  'assignment',
                ],
                'properties': <String, Object?>{
                  'caseId': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 160,
                    'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                  },
                  'revision': <String, Object?>{
                    'type': 'null',
                  },
                  'sourceHash': <String, Object?>{
                    'type': 'string',
                    'pattern': '^[a-f0-9]{64}\$',
                  },
                  'availability': <String, Object?>{
                    'const': 'legacy',
                  },
                  'attendeeId': <String, Object?>{
                    'type': 'null',
                  },
                  'category': <String, Object?>{
                    'enum': <Object?>[
                      'eventLogistics',
                      'accessibility',
                      'other',
                    ],
                  },
                  'receivedAt': <String, Object?>{
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 9007199254740991,
                  },
                  'status': <String, Object?>{
                    'enum': <Object?>[
                      'open',
                      'resolved',
                    ],
                  },
                  'resolution': <String, Object?>{
                    'type': 'null',
                  },
                  'canChange': <String, Object?>{
                    'const': false,
                  },
                  'assignment': <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'kind',
                    ],
                    'properties': <String, Object?>{
                      'kind': <String, Object?>{
                        'const': 'unavailable',
                      },
                    },
                  },
                },
              },
            ],
          },
        },
        'untrackedActorIds': <String, Object?>{
          'type': 'array',
          'maxItems': 50,
          'uniqueItems': true,
          'items': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 180,
          },
        },
      },
    },
    'deliveryReviews': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'context',
        'coverage',
        'deliveries',
      ],
      'properties': <String, Object?>{
        'context': <String, Object?>{
          'allOf': <Object?>[
            <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'mode',
                    'eventId',
                    'organizerId',
                  ],
                  'properties': <String, Object?>{
                    'mode': <String, Object?>{
                      'type': 'string',
                      'const': 'live',
                    },
                    'eventId': <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 160,
                      'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                    },
                    'organizerId': <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 2000,
                    },
                  },
                },
                <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'mode',
                    'rehearsalId',
                    'virtualEventId',
                    'clockId',
                  ],
                  'properties': <String, Object?>{
                    'mode': <String, Object?>{
                      'type': 'string',
                      'const': 'rehearsal',
                    },
                    'rehearsalId': <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 2000,
                    },
                    'virtualEventId': <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 160,
                      'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                    },
                    'clockId': <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 2000,
                    },
                  },
                },
              ],
            },
            <String, Object?>{
              'properties': <String, Object?>{
                'mode': <String, Object?>{
                  'const': 'rehearsal',
                },
              },
            },
          ],
        },
        'coverage': <String, Object?>{
          'const': 'currentActorMessages',
        },
        'deliveries': <String, Object?>{
          'type': 'array',
          'maxItems': 50,
          'items': <String, Object?>{
            'allOf': <Object?>[
              <String, Object?>{
                'oneOf': <Object?>[
                  <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'messageId',
                      'revision',
                      'reviewHash',
                      'createdAt',
                      'expiresAt',
                      'lifecycle',
                      'deliveryStatus',
                      'attempts',
                      'coordination',
                      'handling',
                      'availability',
                      'attendeeId',
                      'actions',
                      'purpose',
                    ],
                    'properties': <String, Object?>{
                      'messageId': <String, Object?>{
                        'type': 'string',
                        'pattern': '^outbox:[a-f0-9]{64}\$',
                      },
                      'revision': <String, Object?>{
                        'type': 'integer',
                        'minimum': 0,
                        'maximum': 9007199254740991,
                      },
                      'reviewHash': <String, Object?>{
                        'type': 'string',
                        'pattern': '^[a-f0-9]{64}\$',
                      },
                      'createdAt': <String, Object?>{
                        'type': 'integer',
                        'minimum': 0,
                        'maximum': 9007199254740991,
                      },
                      'expiresAt': <String, Object?>{
                        'type': 'integer',
                        'minimum': 0,
                        'maximum': 9007199254740991,
                      },
                      'lifecycle': <String, Object?>{
                        'enum': <Object?>[
                          'active',
                          'cancelled',
                          'superseded',
                          'responded',
                        ],
                      },
                      'deliveryStatus': <String, Object?>{
                        'enum': <Object?>[
                          'notSubmitted',
                          'reserved',
                          'unknown',
                          'accepted',
                          'delivered',
                          'read',
                          'failed',
                          'notDispatched',
                          'conflictingEvidence',
                          'revoked',
                        ],
                      },
                      'attempts': <String, Object?>{
                        'type': 'array',
                        'maxItems': 6,
                        'items': <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'channel',
                            'state',
                            'at',
                          ],
                          'properties': <String, Object?>{
                            'channel': <String, Object?>{
                              'enum': <Object?>[
                                'sms',
                                'whatsapp',
                                'rcs',
                              ],
                            },
                            'state': <String, Object?>{
                              'enum': <Object?>[
                                'reserved',
                                'unknown',
                                'accepted',
                                'delivered',
                                'read',
                                'failed',
                                'notDispatched',
                                'revoked',
                              ],
                            },
                            'at': <String, Object?>{
                              'type': 'integer',
                              'minimum': 0,
                              'maximum': 9007199254740991,
                            },
                          },
                        },
                      },
                      'coordination': <String, Object?>{
                        'oneOf': <Object?>[
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'const': 'untracked',
                              },
                            },
                          },
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                              'phase',
                              'reason',
                              'dueAt',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'const': 'tracked',
                              },
                              'phase': <String, Object?>{
                                'enum': <Object?>[
                                  'queued',
                                  'retry',
                                  'receipt',
                                  'review',
                                  'complete',
                                ],
                              },
                              'reason': <String, Object?>{
                                'anyOf': <Object?>[
                                  <String, Object?>{
                                    'type': 'string',
                                    'minLength': 1,
                                    'maxLength': 80,
                                  },
                                  <String, Object?>{
                                    'type': 'null',
                                  },
                                ],
                              },
                              'dueAt': <String, Object?>{
                                'anyOf': <Object?>[
                                  <String, Object?>{
                                    'type': 'integer',
                                    'minimum': 0,
                                    'maximum': 9007199254740991,
                                  },
                                  <String, Object?>{
                                    'type': 'null',
                                  },
                                ],
                              },
                            },
                          },
                        ],
                      },
                      'handling': <String, Object?>{
                        'oneOf': <Object?>[
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'const': 'automatic',
                              },
                            },
                          },
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                              'actorUid',
                              'at',
                              'authority',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'const': 'manual',
                              },
                              'actorUid': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 160,
                                'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                              },
                              'at': <String, Object?>{
                                'type': 'integer',
                                'minimum': 0,
                                'maximum': 9007199254740991,
                              },
                              'authority': <String, Object?>{
                                'enum': <Object?>[
                                  'current',
                                  'revoked',
                                ],
                              },
                            },
                          },
                        ],
                      },
                      'availability': <String, Object?>{
                        'const': 'current',
                      },
                      'attendeeId': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 160,
                        'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                      },
                      'actions': <String, Object?>{
                        'type': 'array',
                        'maxItems': 1,
                        'uniqueItems': true,
                        'items': <String, Object?>{
                          'const': 'manualHandoff',
                        },
                      },
                      'purpose': <String, Object?>{
                        'enum': <Object?>[
                          'joiningUpdate',
                          'joiningInstructions',
                          'planChanged',
                          'guestRequirement',
                          'assignmentChanged',
                          'participationCheck',
                          'eventCancelled',
                          'eventFinished',
                          'followUp',
                        ],
                      },
                    },
                  },
                  <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'messageId',
                      'revision',
                      'reviewHash',
                      'createdAt',
                      'expiresAt',
                      'lifecycle',
                      'deliveryStatus',
                      'attempts',
                      'coordination',
                      'handling',
                      'availability',
                      'attendeeId',
                      'actions',
                      'purpose',
                    ],
                    'properties': <String, Object?>{
                      'messageId': <String, Object?>{
                        'type': 'string',
                        'pattern': '^outbox:[a-f0-9]{64}\$',
                      },
                      'revision': <String, Object?>{
                        'type': 'integer',
                        'minimum': 0,
                        'maximum': 9007199254740991,
                      },
                      'reviewHash': <String, Object?>{
                        'type': 'string',
                        'pattern': '^[a-f0-9]{64}\$',
                      },
                      'createdAt': <String, Object?>{
                        'type': 'integer',
                        'minimum': 0,
                        'maximum': 9007199254740991,
                      },
                      'expiresAt': <String, Object?>{
                        'type': 'integer',
                        'minimum': 0,
                        'maximum': 9007199254740991,
                      },
                      'lifecycle': <String, Object?>{
                        'enum': <Object?>[
                          'active',
                          'cancelled',
                          'superseded',
                          'responded',
                        ],
                      },
                      'deliveryStatus': <String, Object?>{
                        'enum': <Object?>[
                          'notSubmitted',
                          'reserved',
                          'unknown',
                          'accepted',
                          'delivered',
                          'read',
                          'failed',
                          'notDispatched',
                          'conflictingEvidence',
                          'revoked',
                        ],
                      },
                      'attempts': <String, Object?>{
                        'type': 'array',
                        'maxItems': 6,
                        'items': <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'channel',
                            'state',
                            'at',
                          ],
                          'properties': <String, Object?>{
                            'channel': <String, Object?>{
                              'enum': <Object?>[
                                'sms',
                                'whatsapp',
                                'rcs',
                              ],
                            },
                            'state': <String, Object?>{
                              'enum': <Object?>[
                                'reserved',
                                'unknown',
                                'accepted',
                                'delivered',
                                'read',
                                'failed',
                                'notDispatched',
                                'revoked',
                              ],
                            },
                            'at': <String, Object?>{
                              'type': 'integer',
                              'minimum': 0,
                              'maximum': 9007199254740991,
                            },
                          },
                        },
                      },
                      'coordination': <String, Object?>{
                        'oneOf': <Object?>[
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'const': 'untracked',
                              },
                            },
                          },
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                              'phase',
                              'reason',
                              'dueAt',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'const': 'tracked',
                              },
                              'phase': <String, Object?>{
                                'enum': <Object?>[
                                  'queued',
                                  'retry',
                                  'receipt',
                                  'review',
                                  'complete',
                                ],
                              },
                              'reason': <String, Object?>{
                                'anyOf': <Object?>[
                                  <String, Object?>{
                                    'type': 'string',
                                    'minLength': 1,
                                    'maxLength': 80,
                                  },
                                  <String, Object?>{
                                    'type': 'null',
                                  },
                                ],
                              },
                              'dueAt': <String, Object?>{
                                'anyOf': <Object?>[
                                  <String, Object?>{
                                    'type': 'integer',
                                    'minimum': 0,
                                    'maximum': 9007199254740991,
                                  },
                                  <String, Object?>{
                                    'type': 'null',
                                  },
                                ],
                              },
                            },
                          },
                        ],
                      },
                      'handling': <String, Object?>{
                        'oneOf': <Object?>[
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'const': 'automatic',
                              },
                            },
                          },
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                              'actorUid',
                              'at',
                              'authority',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'const': 'manual',
                              },
                              'actorUid': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 160,
                                'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                              },
                              'at': <String, Object?>{
                                'type': 'integer',
                                'minimum': 0,
                                'maximum': 9007199254740991,
                              },
                              'authority': <String, Object?>{
                                'enum': <Object?>[
                                  'current',
                                  'revoked',
                                ],
                              },
                            },
                          },
                        ],
                      },
                      'availability': <String, Object?>{
                        'const': 'sourceChanged',
                      },
                      'attendeeId': <String, Object?>{
                        'type': 'null',
                      },
                      'actions': <String, Object?>{
                        'type': 'array',
                        'maxItems': 0,
                        'items': <String, Object?>{
                          'const': 'manualHandoff',
                        },
                      },
                      'purpose': <String, Object?>{
                        'enum': <Object?>[
                          'joiningUpdate',
                          'joiningInstructions',
                          'planChanged',
                          'guestRequirement',
                          'assignmentChanged',
                          'participationCheck',
                          'eventCancelled',
                          'eventFinished',
                          'followUp',
                        ],
                      },
                    },
                  },
                ],
              },
              <String, Object?>{
                'properties': <String, Object?>{
                  'availability': <String, Object?>{
                    'const': 'current',
                  },
                  'purpose': <String, Object?>{
                    'const': 'joiningUpdate',
                  },
                  'coordination': <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'kind',
                    ],
                    'properties': <String, Object?>{
                      'kind': <String, Object?>{
                        'const': 'untracked',
                      },
                    },
                  },
                },
              },
            ],
          },
        },
      },
    },
    'accountabilityReviews': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'clockId',
        'coverage',
        'rows',
      ],
      'properties': <String, Object?>{
        'clockId': <String, Object?>{
          'type': 'string',
          'pattern': '^clock:[a-f0-9]{64}\$',
        },
        'coverage': <String, Object?>{
          'const': 'boundedSession',
        },
        'rows': <String, Object?>{
          'type': 'array',
          'maxItems': 50,
          'items': <String, Object?>{
            'type': 'object',
            'additionalProperties': false,
            'required': <Object?>[
              'attendeeId',
              'episodeId',
              'sourceHash',
              'visitRevision',
              'checkedInAtMillis',
              'revision',
              'disposition',
              'availability',
              'canResolve',
            ],
            'properties': <String, Object?>{
              'attendeeId': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 180,
              },
              'episodeId': <String, Object?>{
                'type': 'string',
                'pattern': '^episode:[a-f0-9]{64}\$',
              },
              'sourceHash': <String, Object?>{
                'type': 'string',
                'pattern': '^[a-f0-9]{64}\$',
              },
              'visitRevision': <String, Object?>{
                'anyOf': <Object?>[
                  <String, Object?>{
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 9007199254740991,
                  },
                  <String, Object?>{
                    'type': 'null',
                  },
                ],
              },
              'checkedInAtMillis': <String, Object?>{
                'anyOf': <Object?>[
                  <String, Object?>{
                    'type': 'integer',
                    'minimum': 0,
                    'maximum': 9007199254740991,
                  },
                  <String, Object?>{
                    'type': 'null',
                  },
                ],
              },
              'revision': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 9007199254740991,
              },
              'disposition': <String, Object?>{
                'enum': <Object?>[
                  'returned',
                  'departed',
                  'unresolved',
                ],
              },
              'availability': <String, Object?>{
                'oneOf': <Object?>[
                  <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'kind',
                    ],
                    'properties': <String, Object?>{
                      'kind': <String, Object?>{
                        'const': 'ready',
                      },
                    },
                  },
                  <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'kind',
                      'reason',
                    ],
                    'properties': <String, Object?>{
                      'kind': <String, Object?>{
                        'const': 'unavailable',
                      },
                      'reason': <String, Object?>{
                        'enum': <Object?>[
                          'notApplicable',
                          'notCheckedIn',
                          'visitNotRecorded',
                          'invalidSource',
                        ],
                      },
                    },
                  },
                ],
              },
              'canResolve': <String, Object?>{
                'type': 'boolean',
              },
            },
          },
        },
      },
    },
    'membershipReviews': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'clockId',
        'actorUid',
        'coverage',
        'receivingOperatorIds',
        'rows',
      ],
      'properties': <String, Object?>{
        'clockId': <String, Object?>{
          'type': 'string',
          'pattern': '^clock:[a-f0-9]{64}\$',
        },
        'actorUid': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
        },
        'coverage': <String, Object?>{
          'const': 'boundedSession',
        },
        'receivingOperatorIds': <String, Object?>{
          'type': 'array',
          'uniqueItems': true,
          'items': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 180,
          },
          'maxItems': 42,
        },
        'rows': <String, Object?>{
          'type': 'array',
          'maxItems': 50,
          'items': <String, Object?>{
            'type': 'object',
            'additionalProperties': false,
            'required': <Object?>[
              'attendeeId',
              'sourceHash',
              'serverTime',
              'revision',
              'episodeId',
              'participationRevision',
              'freshness',
              'ready',
              'accepted',
              'transfer',
              'transferState',
              'groups',
              'actions',
              'availability',
            ],
            'properties': <String, Object?>{
              'attendeeId': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 160,
                'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
              },
              'sourceHash': <String, Object?>{
                'type': 'string',
                'pattern': '^[a-f0-9]{64}\$',
              },
              'serverTime': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 9007199254740991,
              },
              'revision': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 9007199254740991,
              },
              'episodeId': <String, Object?>{
                'anyOf': <Object?>[
                  <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                    'maxLength': 160,
                    'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                  },
                  <String, Object?>{
                    'type': 'null',
                  },
                ],
              },
              'participationRevision': <String, Object?>{
                'type': 'integer',
                'minimum': 0,
                'maximum': 9007199254740991,
              },
              'freshness': <String, Object?>{
                'enum': <Object?>[
                  'uninitialized',
                  'current',
                  'sourceChanged',
                ],
              },
              'ready': <String, Object?>{
                'type': 'boolean',
              },
              'accepted': <String, Object?>{
                'anyOf': <Object?>[
                  <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'groupId',
                      'groupSourceHash',
                      'responsibleOperatorId',
                      'acceptedAt',
                    ],
                    'properties': <String, Object?>{
                      'groupId': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 160,
                        'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                      },
                      'groupSourceHash': <String, Object?>{
                        'type': 'string',
                        'pattern': '^[a-f0-9]{64}\$',
                      },
                      'responsibleOperatorId': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 180,
                      },
                      'acceptedAt': <String, Object?>{
                        'type': 'integer',
                        'minimum': 0,
                        'maximum': 9007199254740991,
                      },
                    },
                  },
                  <String, Object?>{
                    'type': 'null',
                  },
                ],
              },
              'transfer': <String, Object?>{
                'anyOf': <Object?>[
                  <String, Object?>{
                    'oneOf': <Object?>[
                      <String, Object?>{
                        'type': 'object',
                        'additionalProperties': false,
                        'required': <Object?>[
                          'transferId',
                          'from',
                          'to',
                          'targetSourceHash',
                          'receivingOperatorId',
                          'requestedBy',
                          'requestedAt',
                          'expiresAt',
                          'status',
                          'resolvedAt',
                          'resolvedBy',
                        ],
                        'properties': <String, Object?>{
                          'transferId': <String, Object?>{
                            'type': 'string',
                            'minLength': 1,
                            'maxLength': 160,
                            'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                          },
                          'from': <String, Object?>{
                            'anyOf': <Object?>[
                              <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 160,
                                'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                              },
                              <String, Object?>{
                                'type': 'null',
                              },
                            ],
                          },
                          'to': <String, Object?>{
                            'type': 'string',
                            'minLength': 1,
                            'maxLength': 160,
                            'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                          },
                          'targetSourceHash': <String, Object?>{
                            'type': 'string',
                            'pattern': '^[a-f0-9]{64}\$',
                          },
                          'receivingOperatorId': <String, Object?>{
                            'type': 'string',
                            'minLength': 1,
                            'maxLength': 180,
                          },
                          'requestedBy': <String, Object?>{
                            'type': 'string',
                            'minLength': 1,
                            'maxLength': 180,
                          },
                          'requestedAt': <String, Object?>{
                            'type': 'integer',
                            'minimum': 0,
                            'maximum': 9007199254740991,
                          },
                          'expiresAt': <String, Object?>{
                            'type': 'integer',
                            'minimum': 0,
                            'maximum': 9007199254740991,
                          },
                          'status': <String, Object?>{
                            'const': 'pending',
                          },
                          'resolvedAt': <String, Object?>{
                            'type': 'null',
                          },
                          'resolvedBy': <String, Object?>{
                            'type': 'null',
                          },
                        },
                      },
                      <String, Object?>{
                        'type': 'object',
                        'additionalProperties': false,
                        'required': <Object?>[
                          'transferId',
                          'from',
                          'to',
                          'targetSourceHash',
                          'receivingOperatorId',
                          'requestedBy',
                          'requestedAt',
                          'expiresAt',
                          'status',
                          'resolvedAt',
                          'resolvedBy',
                        ],
                        'properties': <String, Object?>{
                          'transferId': <String, Object?>{
                            'type': 'string',
                            'minLength': 1,
                            'maxLength': 160,
                            'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                          },
                          'from': <String, Object?>{
                            'anyOf': <Object?>[
                              <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 160,
                                'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                              },
                              <String, Object?>{
                                'type': 'null',
                              },
                            ],
                          },
                          'to': <String, Object?>{
                            'type': 'string',
                            'minLength': 1,
                            'maxLength': 160,
                            'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                          },
                          'targetSourceHash': <String, Object?>{
                            'type': 'string',
                            'pattern': '^[a-f0-9]{64}\$',
                          },
                          'receivingOperatorId': <String, Object?>{
                            'type': 'string',
                            'minLength': 1,
                            'maxLength': 180,
                          },
                          'requestedBy': <String, Object?>{
                            'type': 'string',
                            'minLength': 1,
                            'maxLength': 180,
                          },
                          'requestedAt': <String, Object?>{
                            'type': 'integer',
                            'minimum': 0,
                            'maximum': 9007199254740991,
                          },
                          'expiresAt': <String, Object?>{
                            'type': 'integer',
                            'minimum': 0,
                            'maximum': 9007199254740991,
                          },
                          'status': <String, Object?>{
                            'enum': <Object?>[
                              'accepted',
                              'rejected',
                              'cancelled',
                            ],
                          },
                          'resolvedAt': <String, Object?>{
                            'type': 'integer',
                            'minimum': 0,
                            'maximum': 9007199254740991,
                          },
                          'resolvedBy': <String, Object?>{
                            'type': 'string',
                            'minLength': 1,
                            'maxLength': 180,
                          },
                        },
                      },
                    ],
                  },
                  <String, Object?>{
                    'type': 'null',
                  },
                ],
              },
              'transferState': <String, Object?>{
                'enum': <Object?>[
                  'none',
                  'pending',
                  'expired',
                  'sourceChanged',
                  'accepted',
                  'rejected',
                  'cancelled',
                ],
              },
              'groups': <String, Object?>{
                'type': 'array',
                'maxItems': 40,
                'items': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'groupId',
                    'label',
                  ],
                  'properties': <String, Object?>{
                    'groupId': <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 160,
                      'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                    },
                    'label': <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 240,
                    },
                  },
                },
              },
              'actions': <String, Object?>{
                'type': 'array',
                'uniqueItems': true,
                'maxItems': 6,
                'items': <String, Object?>{
                  'enum': <Object?>[
                    'place',
                    'propose',
                    'accept',
                    'reject',
                    'cancel',
                    'leave',
                  ],
                },
              },
              'availability': <String, Object?>{
                'enum': <Object?>[
                  'ready',
                  'notApplicable',
                  'participationNotRecorded',
                  'invalidSource',
                ],
              },
            },
          },
        },
      },
    },
  },
  'definitions': <String, Object?>{
    'session': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'id',
        'organizerId',
        'sourceEventId',
        'scenarioId',
        'seed',
        'actorCount',
        'actionCount',
        'status',
        'setup',
        'setupRevision',
        'runtimeRevision',
        'activeStepIndex',
        'virtualNowMillis',
        'faultId',
        'expiresAtMillis',
        'virtualStartedAtMillis',
      ],
      'properties': <String, Object?>{
        'id': <String, Object?>{
          'type': 'string',
        },
        'organizerId': <String, Object?>{
          'type': 'string',
        },
        'sourceEventId': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
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
        'actorCount': <String, Object?>{
          'type': 'integer',
        },
        'actionCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 500,
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
        'setupRevision': <String, Object?>{
          'type': 'integer',
        },
        'runtimeRevision': <String, Object?>{
          'type': 'integer',
        },
        'activeStepIndex': <String, Object?>{
          'type': 'integer',
        },
        'virtualNowMillis': <String, Object?>{
          'type': 'integer',
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
        },
        'expiresAtMillis': <String, Object?>{
          'type': 'integer',
        },
        'virtualStartedAtMillis': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
          'maximum': 9007199254740991,
        },
      },
    },
    'actor': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'actorId',
        'displayName',
        'persona',
        'status',
        'guestMoment',
        'optedOut',
        'keepApartActorIds',
        'helpRequested',
        'promptCompleted',
        'layoutUnitId',
        'confirmedLayoutUnitId',
      ],
      'properties': <String, Object?>{
        'actorId': <String, Object?>{
          'type': 'string',
        },
        'displayName': <String, Object?>{
          'type': 'string',
        },
        'persona': <String, Object?>{
          'type': 'string',
        },
        'status': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'expected',
            'present',
            'late',
            'noShow',
            'departed',
            'returned',
            'disconnected',
            'walkIn',
            'ambiguousClaim',
          ],
        },
        'connectionState': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'connected',
            'disconnected',
          ],
        },
        'guestMoment': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'welcome',
            'checkIn',
            'firstHello',
            'assignment',
            'rotation',
            'pause',
            'reveal',
            'afterglow',
            'complete',
          ],
        },
        'optedOut': <String, Object?>{
          'type': 'boolean',
        },
        'keepApartActorIds': <String, Object?>{
          'type': 'array',
          'items': <String, Object?>{
            'type': 'string',
          },
        },
        'helpRequested': <String, Object?>{
          'type': 'boolean',
        },
        'promptCompleted': <String, Object?>{
          'type': 'boolean',
        },
        'layoutUnitId': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
        },
        'confirmedLayoutUnitId': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
        },
        'assistance': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'intention',
            'latestMessageId',
          ],
          'properties': <String, Object?>{
            'intention': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'kind',
                  ],
                  'properties': <String, Object?>{
                    'kind': <String, Object?>{
                      'type': 'string',
                      'const': 'unknown',
                    },
                  },
                },
                <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'kind',
                    'claimedEta',
                  ],
                  'properties': <String, Object?>{
                    'kind': <String, Object?>{
                      'type': 'string',
                      'const': 'onMyWay',
                    },
                    'claimedEta': <String, Object?>{
                      'anyOf': <Object?>[
                        <String, Object?>{
                          'type': 'integer',
                          'minimum': 0,
                          'maximum': 9007199254740991,
                          'description': 'UTC milliseconds.',
                        },
                        <String, Object?>{
                          'type': 'null',
                          'const': null,
                        },
                      ],
                    },
                  },
                },
                <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'kind',
                    'target',
                  ],
                  'properties': <String, Object?>{
                    'kind': <String, Object?>{
                      'type': 'string',
                      'const': 'joinLater',
                    },
                    'target': <String, Object?>{
                      'anyOf': <Object?>[
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'kind',
                            'placeId',
                            'lateEntry',
                          ],
                          'properties': <String, Object?>{
                            'kind': <String, Object?>{
                              'type': 'string',
                              'const': 'fixedPlace',
                            },
                            'placeId': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 160,
                              'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                            },
                            'lateEntry': <String, Object?>{
                              'type': 'string',
                              'enum': <Object?>[
                                'allowed',
                                'hostDecision',
                                'closed',
                              ],
                            },
                          },
                        },
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'kind',
                            'itineraryId',
                            'stopId',
                          ],
                          'properties': <String, Object?>{
                            'kind': <String, Object?>{
                              'type': 'string',
                              'const': 'itineraryStop',
                            },
                            'itineraryId': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 2000,
                            },
                            'stopId': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 2000,
                            },
                          },
                        },
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'kind',
                            'routeId',
                            'groupId',
                            'checkpointId',
                          ],
                          'properties': <String, Object?>{
                            'kind': <String, Object?>{
                              'type': 'string',
                              'const': 'groupCheckpoint',
                            },
                            'routeId': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 2000,
                            },
                            'groupId': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 160,
                              'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                            },
                            'checkpointId': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 2000,
                            },
                          },
                        },
                      ],
                    },
                  },
                },
                <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'kind',
                  ],
                  'properties': <String, Object?>{
                    'kind': <String, Object?>{
                      'type': 'string',
                      'const': 'notComing',
                    },
                  },
                },
              ],
            },
            'latestMessageId': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'string',
                  'pattern': '^outbox:[a-f0-9]{64}\$',
                },
                <String, Object?>{
                  'type': 'null',
                },
              ],
            },
          },
        },
        'assistanceMessage': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'messageId',
                'intentId',
                'intentRevision',
                'text',
                'choices',
                'lifecycle',
                'expiresAt',
                'canRespond',
                'responseChoiceId',
              ],
              'properties': <String, Object?>{
                'messageId': <String, Object?>{
                  'type': 'string',
                  'pattern': '^outbox:[a-f0-9]{64}\$',
                },
                'intentId': <String, Object?>{
                  'type': 'string',
                },
                'intentRevision': <String, Object?>{
                  'type': 'integer',
                  'minimum': 1,
                  'maximum': 9007199254740991,
                },
                'text': <String, Object?>{
                  'type': 'string',
                  'maxLength': 2000,
                },
                'choices': <String, Object?>{
                  'type': 'array',
                  'maxItems': 20,
                  'items': <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'choiceId',
                      'label',
                    ],
                    'properties': <String, Object?>{
                      'choiceId': <String, Object?>{
                        'type': 'string',
                      },
                      'label': <String, Object?>{
                        'type': 'string',
                        'maxLength': 80,
                      },
                    },
                  },
                },
                'lifecycle': <String, Object?>{
                  'type': 'string',
                  'enum': <Object?>[
                    'active',
                    'cancelled',
                    'superseded',
                    'responded',
                  ],
                },
                'expiresAt': <String, Object?>{
                  'type': 'integer',
                  'minimum': 0,
                  'maximum': 9007199254740991,
                },
                'canRespond': <String, Object?>{
                  'type': 'boolean',
                },
                'responseChoiceId': <String, Object?>{
                  'anyOf': <Object?>[
                    <String, Object?>{
                      'type': 'string',
                    },
                    <String, Object?>{
                      'type': 'null',
                    },
                  ],
                },
              },
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'assistanceDelivery': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'conflictingEvidence',
                'attempts',
              ],
              'properties': <String, Object?>{
                'conflictingEvidence': <String, Object?>{
                  'type': 'boolean',
                },
                'attempts': <String, Object?>{
                  'type': 'array',
                  'maxItems': 6,
                  'items': <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'attemptId',
                      'routeId',
                      'status',
                    ],
                    'properties': <String, Object?>{
                      'attemptId': <String, Object?>{
                        'type': 'string',
                      },
                      'routeId': <String, Object?>{
                        'type': 'string',
                        'enum': <Object?>[
                          'catchEventSms',
                          'catchEventRcs',
                          'organizerEventWhatsapp',
                        ],
                      },
                      'status': <String, Object?>{
                        'type': 'string',
                        'enum': <Object?>[
                          'notDispatched',
                          'reserved',
                          'unknown',
                          'accepted',
                          'delivered',
                          'read',
                          'failed',
                          'revoked',
                        ],
                      },
                    },
                  },
                },
              },
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'assistanceAutomation': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'clockId',
            'status',
            'plan',
            'outcomes',
            'nextOutcomeIndex',
            'evaluation',
          ],
          'properties': <String, Object?>{
            'clockId': <String, Object?>{
              'type': 'string',
              'pattern': '^clock:[a-f0-9]{64}\$',
            },
            'status': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'enabled',
                'paused',
              ],
            },
            'plan': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'policy',
                'guidance',
                'departureConfirmed',
                'responseDeadline',
                'routes',
                'deliveryPolicy',
              ],
              'properties': <String, Object?>{
                'policy': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'destination',
                    'cutoff',
                    'maxMessagesPerEpisode',
                    'minimumMinutesBetweenMessages',
                    'updateOn',
                    'unanswered',
                  ],
                  'properties': <String, Object?>{
                    'destination': <String, Object?>{
                      'anyOf': <Object?>[
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'kind',
                            'placeId',
                            'lateEntry',
                          ],
                          'properties': <String, Object?>{
                            'kind': <String, Object?>{
                              'type': 'string',
                              'const': 'fixedPlace',
                            },
                            'placeId': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 160,
                              'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                            },
                            'lateEntry': <String, Object?>{
                              'type': 'string',
                              'enum': <Object?>[
                                'allowed',
                                'hostDecision',
                                'closed',
                              ],
                            },
                          },
                        },
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'kind',
                            'itineraryId',
                            'permittedStopIds',
                          ],
                          'properties': <String, Object?>{
                            'kind': <String, Object?>{
                              'type': 'string',
                              'const': 'itineraryStop',
                            },
                            'itineraryId': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 2000,
                            },
                            'permittedStopIds': <String, Object?>{
                              'type': 'array',
                              'minItems': 1,
                              'maxItems': 1000,
                              'items': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 2000,
                              },
                              'uniqueItems': true,
                            },
                          },
                        },
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'kind',
                            'routeId',
                            'groupId',
                            'permittedCheckpointIds',
                          ],
                          'properties': <String, Object?>{
                            'kind': <String, Object?>{
                              'type': 'string',
                              'const': 'groupCheckpoint',
                            },
                            'routeId': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 2000,
                            },
                            'groupId': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 160,
                              'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                            },
                            'permittedCheckpointIds': <String, Object?>{
                              'type': 'array',
                              'minItems': 1,
                              'maxItems': 1000,
                              'items': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 2000,
                              },
                              'uniqueItems': true,
                            },
                          },
                        },
                      ],
                    },
                    'cutoff': <String, Object?>{
                      'anyOf': <Object?>[
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'kind',
                          ],
                          'properties': <String, Object?>{
                            'kind': <String, Object?>{
                              'type': 'string',
                              'const': 'eventEnd',
                            },
                          },
                        },
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'kind',
                            'at',
                          ],
                          'properties': <String, Object?>{
                            'kind': <String, Object?>{
                              'type': 'string',
                              'const': 'time',
                            },
                            'at': <String, Object?>{
                              'type': 'integer',
                              'minimum': 0,
                              'maximum': 9007199254740991,
                              'description': 'UTC milliseconds.',
                            },
                          },
                        },
                      ],
                    },
                    'maxMessagesPerEpisode': <String, Object?>{
                      'type': 'integer',
                      'minimum': 0,
                      'maximum': 100,
                    },
                    'minimumMinutesBetweenMessages': <String, Object?>{
                      'type': 'integer',
                      'minimum': 0,
                      'maximum': 1440,
                    },
                    'updateOn': <String, Object?>{
                      'type': 'string',
                      'const': 'materialGuidanceChange',
                    },
                    'unanswered': <String, Object?>{
                      'type': 'string',
                      'enum': <Object?>[
                        'keepUnknownUntilCutoff',
                        'hostReviewAtDeadline',
                      ],
                    },
                  },
                },
                'guidance': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'revision',
                    'destination',
                    'materialKey',
                    'text',
                    'validUntil',
                  ],
                  'properties': <String, Object?>{
                    'revision': <String, Object?>{
                      'type': 'integer',
                      'minimum': 0,
                      'maximum': 9007199254740991,
                      'description': 'Nonnegative safe integer revision.',
                    },
                    'destination': <String, Object?>{
                      'anyOf': <Object?>[
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'kind',
                            'placeId',
                            'lateEntry',
                          ],
                          'properties': <String, Object?>{
                            'kind': <String, Object?>{
                              'type': 'string',
                              'const': 'fixedPlace',
                            },
                            'placeId': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 160,
                              'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                            },
                            'lateEntry': <String, Object?>{
                              'type': 'string',
                              'enum': <Object?>[
                                'allowed',
                                'hostDecision',
                                'closed',
                              ],
                            },
                          },
                        },
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'kind',
                            'itineraryId',
                            'stopId',
                          ],
                          'properties': <String, Object?>{
                            'kind': <String, Object?>{
                              'type': 'string',
                              'const': 'itineraryStop',
                            },
                            'itineraryId': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 2000,
                            },
                            'stopId': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 2000,
                            },
                          },
                        },
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'kind',
                            'routeId',
                            'groupId',
                            'checkpointId',
                          ],
                          'properties': <String, Object?>{
                            'kind': <String, Object?>{
                              'type': 'string',
                              'const': 'groupCheckpoint',
                            },
                            'routeId': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 2000,
                            },
                            'groupId': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 160,
                              'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                            },
                            'checkpointId': <String, Object?>{
                              'type': 'string',
                              'minLength': 1,
                              'maxLength': 2000,
                            },
                          },
                        },
                      ],
                    },
                    'materialKey': <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 2000,
                    },
                    'text': <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 2000,
                    },
                    'validUntil': <String, Object?>{
                      'type': 'integer',
                      'minimum': 0,
                      'maximum': 9007199254740991,
                      'description': 'UTC milliseconds.',
                    },
                  },
                },
                'departureConfirmed': <String, Object?>{
                  'type': 'boolean',
                },
                'responseDeadline': <String, Object?>{
                  'anyOf': <Object?>[
                    <String, Object?>{
                      'type': 'integer',
                      'minimum': 0,
                      'maximum': 9007199254740991,
                    },
                    <String, Object?>{
                      'type': 'null',
                    },
                  ],
                },
                'routes': <String, Object?>{
                  'type': 'array',
                  'minItems': 1,
                  'maxItems': 3,
                  'uniqueItems': true,
                  'items': <String, Object?>{
                    'type': 'string',
                    'enum': <Object?>[
                      'catchEventSms',
                      'catchEventRcs',
                      'organizerEventWhatsapp',
                    ],
                  },
                },
                'deliveryPolicy': <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'maxAttempts',
                    'maxAttemptsPerRoute',
                    'minimumRetrySeconds',
                  ],
                  'properties': <String, Object?>{
                    'maxAttempts': <String, Object?>{
                      'type': 'integer',
                      'minimum': 1,
                      'maximum': 6,
                    },
                    'maxAttemptsPerRoute': <String, Object?>{
                      'type': 'integer',
                      'minimum': 1,
                      'maximum': 3,
                    },
                    'minimumRetrySeconds': <String, Object?>{
                      'type': 'integer',
                      'minimum': 1,
                      'maximum': 3600,
                    },
                  },
                },
                'laterChoices': <String, Object?>{
                  'type': 'array',
                  'maxItems': 17,
                  'items': <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'label',
                      'target',
                    ],
                    'properties': <String, Object?>{
                      'label': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 80,
                      },
                      'target': <String, Object?>{
                        'anyOf': <Object?>[
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                              'placeId',
                              'lateEntry',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'type': 'string',
                                'const': 'fixedPlace',
                              },
                              'placeId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 160,
                                'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                              },
                              'lateEntry': <String, Object?>{
                                'type': 'string',
                                'enum': <Object?>[
                                  'allowed',
                                  'hostDecision',
                                  'closed',
                                ],
                              },
                            },
                          },
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                              'itineraryId',
                              'stopId',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'type': 'string',
                                'const': 'itineraryStop',
                              },
                              'itineraryId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 2000,
                              },
                              'stopId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 2000,
                              },
                            },
                          },
                          <String, Object?>{
                            'type': 'object',
                            'additionalProperties': false,
                            'required': <Object?>[
                              'kind',
                              'routeId',
                              'groupId',
                              'checkpointId',
                            ],
                            'properties': <String, Object?>{
                              'kind': <String, Object?>{
                                'type': 'string',
                                'const': 'groupCheckpoint',
                              },
                              'routeId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 2000,
                              },
                              'groupId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 160,
                                'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                              },
                              'checkpointId': <String, Object?>{
                                'type': 'string',
                                'minLength': 1,
                                'maxLength': 2000,
                              },
                            },
                          },
                        ],
                      },
                    },
                  },
                },
              },
              'if': <String, Object?>{
                'properties': <String, Object?>{
                  'policy': <String, Object?>{
                    'properties': <String, Object?>{
                      'unanswered': <String, Object?>{
                        'const': 'hostReviewAtDeadline',
                      },
                    },
                  },
                },
              },
              'then': <String, Object?>{
                'properties': <String, Object?>{
                  'responseDeadline': <String, Object?>{
                    'type': 'integer',
                  },
                },
              },
            },
            'outcomes': <String, Object?>{
              'type': 'array',
              'minItems': 1,
              'maxItems': 6,
              'items': <String, Object?>{
                'oneOf': <Object?>[
                  <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'kind',
                    ],
                    'properties': <String, Object?>{
                      'kind': <String, Object?>{
                        'type': 'string',
                        'enum': <Object?>[
                          'accepted',
                          'delivered',
                          'read',
                          'revoked',
                        ],
                      },
                    },
                  },
                  <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'kind',
                      'classification',
                    ],
                    'properties': <String, Object?>{
                      'kind': <String, Object?>{
                        'const': 'failed',
                      },
                      'classification': <String, Object?>{
                        'type': 'string',
                        'enum': <Object?>[
                          'technical',
                          'policy',
                          'suppressed',
                          'invalidRecipient',
                        ],
                      },
                    },
                  },
                  <String, Object?>{
                    'type': 'object',
                    'additionalProperties': false,
                    'required': <Object?>[
                      'kind',
                      'reason',
                    ],
                    'properties': <String, Object?>{
                      'kind': <String, Object?>{
                        'const': 'unknown',
                      },
                      'reason': <String, Object?>{
                        'type': 'string',
                        'enum': <Object?>[
                          'timeout',
                          'connectionLost',
                          'workerInterrupted',
                        ],
                      },
                    },
                  },
                ],
              },
            },
            'nextOutcomeIndex': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 6,
            },
            'evaluation': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'at',
                    'policy',
                    'delivery',
                  ],
                  'properties': <String, Object?>{
                    'at': <String, Object?>{
                      'type': 'integer',
                      'minimum': 0,
                      'maximum': 9007199254740991,
                    },
                    'policy': <String, Object?>{
                      'anyOf': <Object?>[
                        <String, Object?>{
                          'anyOf': <Object?>[
                            <String, Object?>{
                              'type': 'object',
                              'additionalProperties': false,
                              'required': <Object?>[
                                'kind',
                                'reason',
                              ],
                              'properties': <String, Object?>{
                                'kind': <String, Object?>{
                                  'type': 'string',
                                  'const': 'resolved',
                                },
                                'reason': <String, Object?>{
                                  'type': 'string',
                                  'enum': <Object?>[
                                    'joined',
                                    'declined',
                                  ],
                                },
                              },
                            },
                            <String, Object?>{
                              'type': 'object',
                              'additionalProperties': false,
                              'required': <Object?>[
                                'kind',
                                'reason',
                              ],
                              'properties': <String, Object?>{
                                'kind': <String, Object?>{
                                  'type': 'string',
                                  'const': 'cancelled',
                                },
                                'reason': <String, Object?>{
                                  'type': 'string',
                                  'enum': <Object?>[
                                    'eventClosed',
                                    'notAdmitted',
                                    'policyDisabled',
                                    'participationInactive',
                                  ],
                                },
                              },
                            },
                            <String, Object?>{
                              'type': 'object',
                              'additionalProperties': false,
                              'required': <Object?>[
                                'kind',
                                'reason',
                              ],
                              'properties': <String, Object?>{
                                'kind': <String, Object?>{
                                  'type': 'string',
                                  'const': 'expired',
                                },
                                'reason': <String, Object?>{
                                  'type': 'string',
                                  'enum': <Object?>[
                                    'cutoff',
                                    'lateEntryClosed',
                                  ],
                                },
                              },
                            },
                            <String, Object?>{
                              'type': 'object',
                              'additionalProperties': false,
                              'required': <Object?>[
                                'kind',
                                'reason',
                              ],
                              'properties': <String, Object?>{
                                'kind': <String, Object?>{
                                  'type': 'string',
                                  'const': 'wait',
                                },
                                'reason': <String, Object?>{
                                  'type': 'string',
                                  'enum': <Object?>[
                                    'departureUnconfirmed',
                                    'attendanceUnknown',
                                    'guidanceUnavailable',
                                    'throttled',
                                    'unchanged',
                                    'participationUnknown',
                                  ],
                                },
                              },
                            },
                            <String, Object?>{
                              'type': 'object',
                              'additionalProperties': false,
                              'required': <Object?>[
                                'kind',
                                'reason',
                                'guidance',
                              ],
                              'properties': <String, Object?>{
                                'kind': <String, Object?>{
                                  'type': 'string',
                                  'const': 'hostDecision',
                                },
                                'reason': <String, Object?>{
                                  'type': 'string',
                                  'enum': <Object?>[
                                    'unreachable',
                                    'entryDecision',
                                    'missingInformation',
                                  ],
                                },
                                'guidance': <String, Object?>{
                                  'anyOf': <Object?>[
                                    <String, Object?>{
                                      'type': 'object',
                                      'additionalProperties': false,
                                      'required': <Object?>[
                                        'revision',
                                        'destination',
                                        'materialKey',
                                        'text',
                                        'validUntil',
                                      ],
                                      'properties': <String, Object?>{
                                        'revision': <String, Object?>{
                                          'type': 'integer',
                                          'minimum': 0,
                                          'maximum': 9007199254740991,
                                          'description': 'Nonnegative safe integer revision.',
                                        },
                                        'destination': <String, Object?>{
                                          'anyOf': <Object?>[
                                            <String, Object?>{
                                              'type': 'object',
                                              'additionalProperties': false,
                                              'required': <Object?>[
                                                'kind',
                                                'placeId',
                                                'lateEntry',
                                              ],
                                              'properties': <String, Object?>{
                                                'kind': <String, Object?>{
                                                  'type': 'string',
                                                  'const': 'fixedPlace',
                                                },
                                                'placeId': <String, Object?>{
                                                  'type': 'string',
                                                  'minLength': 1,
                                                  'maxLength': 160,
                                                  'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                                                },
                                                'lateEntry': <String, Object?>{
                                                  'type': 'string',
                                                  'enum': <Object?>[
                                                    'allowed',
                                                    'hostDecision',
                                                    'closed',
                                                  ],
                                                },
                                              },
                                            },
                                            <String, Object?>{
                                              'type': 'object',
                                              'additionalProperties': false,
                                              'required': <Object?>[
                                                'kind',
                                                'itineraryId',
                                                'stopId',
                                              ],
                                              'properties': <String, Object?>{
                                                'kind': <String, Object?>{
                                                  'type': 'string',
                                                  'const': 'itineraryStop',
                                                },
                                                'itineraryId': <String, Object?>{
                                                  'type': 'string',
                                                  'minLength': 1,
                                                  'maxLength': 2000,
                                                },
                                                'stopId': <String, Object?>{
                                                  'type': 'string',
                                                  'minLength': 1,
                                                  'maxLength': 2000,
                                                },
                                              },
                                            },
                                            <String, Object?>{
                                              'type': 'object',
                                              'additionalProperties': false,
                                              'required': <Object?>[
                                                'kind',
                                                'routeId',
                                                'groupId',
                                                'checkpointId',
                                              ],
                                              'properties': <String, Object?>{
                                                'kind': <String, Object?>{
                                                  'type': 'string',
                                                  'const': 'groupCheckpoint',
                                                },
                                                'routeId': <String, Object?>{
                                                  'type': 'string',
                                                  'minLength': 1,
                                                  'maxLength': 2000,
                                                },
                                                'groupId': <String, Object?>{
                                                  'type': 'string',
                                                  'minLength': 1,
                                                  'maxLength': 160,
                                                  'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                                                },
                                                'checkpointId': <String, Object?>{
                                                  'type': 'string',
                                                  'minLength': 1,
                                                  'maxLength': 2000,
                                                },
                                              },
                                            },
                                          ],
                                        },
                                        'materialKey': <String, Object?>{
                                          'type': 'string',
                                          'minLength': 1,
                                          'maxLength': 2000,
                                        },
                                        'text': <String, Object?>{
                                          'type': 'string',
                                          'minLength': 1,
                                          'maxLength': 2000,
                                        },
                                        'validUntil': <String, Object?>{
                                          'type': 'integer',
                                          'minimum': 0,
                                          'maximum': 9007199254740991,
                                          'description': 'UTC milliseconds.',
                                        },
                                      },
                                    },
                                    <String, Object?>{
                                      'type': 'null',
                                      'const': null,
                                    },
                                  ],
                                },
                              },
                            },
                            <String, Object?>{
                              'type': 'object',
                              'additionalProperties': false,
                              'required': <Object?>[
                                'kind',
                                'guidance',
                                'messageKey',
                                'shouldSend',
                                'nextEvaluationAt',
                              ],
                              'properties': <String, Object?>{
                                'kind': <String, Object?>{
                                  'type': 'string',
                                  'const': 'update',
                                },
                                'guidance': <String, Object?>{
                                  'type': 'object',
                                  'additionalProperties': false,
                                  'required': <Object?>[
                                    'revision',
                                    'destination',
                                    'materialKey',
                                    'text',
                                    'validUntil',
                                  ],
                                  'properties': <String, Object?>{
                                    'revision': <String, Object?>{
                                      'type': 'integer',
                                      'minimum': 0,
                                      'maximum': 9007199254740991,
                                      'description': 'Nonnegative safe integer revision.',
                                    },
                                    'destination': <String, Object?>{
                                      'anyOf': <Object?>[
                                        <String, Object?>{
                                          'type': 'object',
                                          'additionalProperties': false,
                                          'required': <Object?>[
                                            'kind',
                                            'placeId',
                                            'lateEntry',
                                          ],
                                          'properties': <String, Object?>{
                                            'kind': <String, Object?>{
                                              'type': 'string',
                                              'const': 'fixedPlace',
                                            },
                                            'placeId': <String, Object?>{
                                              'type': 'string',
                                              'minLength': 1,
                                              'maxLength': 160,
                                              'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                                            },
                                            'lateEntry': <String, Object?>{
                                              'type': 'string',
                                              'enum': <Object?>[
                                                'allowed',
                                                'hostDecision',
                                                'closed',
                                              ],
                                            },
                                          },
                                        },
                                        <String, Object?>{
                                          'type': 'object',
                                          'additionalProperties': false,
                                          'required': <Object?>[
                                            'kind',
                                            'itineraryId',
                                            'stopId',
                                          ],
                                          'properties': <String, Object?>{
                                            'kind': <String, Object?>{
                                              'type': 'string',
                                              'const': 'itineraryStop',
                                            },
                                            'itineraryId': <String, Object?>{
                                              'type': 'string',
                                              'minLength': 1,
                                              'maxLength': 2000,
                                            },
                                            'stopId': <String, Object?>{
                                              'type': 'string',
                                              'minLength': 1,
                                              'maxLength': 2000,
                                            },
                                          },
                                        },
                                        <String, Object?>{
                                          'type': 'object',
                                          'additionalProperties': false,
                                          'required': <Object?>[
                                            'kind',
                                            'routeId',
                                            'groupId',
                                            'checkpointId',
                                          ],
                                          'properties': <String, Object?>{
                                            'kind': <String, Object?>{
                                              'type': 'string',
                                              'const': 'groupCheckpoint',
                                            },
                                            'routeId': <String, Object?>{
                                              'type': 'string',
                                              'minLength': 1,
                                              'maxLength': 2000,
                                            },
                                            'groupId': <String, Object?>{
                                              'type': 'string',
                                              'minLength': 1,
                                              'maxLength': 160,
                                              'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
                                            },
                                            'checkpointId': <String, Object?>{
                                              'type': 'string',
                                              'minLength': 1,
                                              'maxLength': 2000,
                                            },
                                          },
                                        },
                                      ],
                                    },
                                    'materialKey': <String, Object?>{
                                      'type': 'string',
                                      'minLength': 1,
                                      'maxLength': 2000,
                                    },
                                    'text': <String, Object?>{
                                      'type': 'string',
                                      'minLength': 1,
                                      'maxLength': 2000,
                                    },
                                    'validUntil': <String, Object?>{
                                      'type': 'integer',
                                      'minimum': 0,
                                      'maximum': 9007199254740991,
                                      'description': 'UTC milliseconds.',
                                    },
                                  },
                                },
                                'messageKey': <String, Object?>{
                                  'type': 'string',
                                  'minLength': 1,
                                  'maxLength': 2000,
                                },
                                'shouldSend': <String, Object?>{
                                  'type': 'boolean',
                                },
                                'nextEvaluationAt': <String, Object?>{
                                  'anyOf': <Object?>[
                                    <String, Object?>{
                                      'type': 'integer',
                                      'minimum': 0,
                                      'maximum': 9007199254740991,
                                    },
                                    <String, Object?>{
                                      'type': 'null',
                                    },
                                  ],
                                },
                              },
                            },
                          ],
                        },
                        <String, Object?>{
                          'type': 'null',
                        },
                      ],
                    },
                    'delivery': <String, Object?>{
                      'oneOf': <Object?>[
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'kind',
                          ],
                          'properties': <String, Object?>{
                            'kind': <String, Object?>{
                              'const': 'paused',
                            },
                          },
                        },
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'kind',
                          ],
                          'properties': <String, Object?>{
                            'kind': <String, Object?>{
                              'const': 'notApplicable',
                            },
                          },
                        },
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'kind',
                          ],
                          'properties': <String, Object?>{
                            'kind': <String, Object?>{
                              'const': 'scriptExhausted',
                            },
                          },
                        },
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'kind',
                            'reason',
                          ],
                          'properties': <String, Object?>{
                            'kind': <String, Object?>{
                              'const': 'stop',
                            },
                            'reason': <String, Object?>{
                              'type': 'string',
                              'enum': <Object?>[
                                'responded',
                                'cancelled',
                                'superseded',
                                'expired',
                                'eventClosed',
                                'permissionRevoked',
                                'guestPresent',
                                'guestDeclined',
                                'notAdmitted',
                                'hostStopped',
                                'participationInactive',
                              ],
                            },
                          },
                        },
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'kind',
                            'attemptIds',
                          ],
                          'properties': <String, Object?>{
                            'kind': <String, Object?>{
                              'const': 'delivered',
                            },
                            'attemptIds': <String, Object?>{
                              'type': 'array',
                              'maxItems': 6,
                              'items': <String, Object?>{
                                'type': 'string',
                              },
                            },
                          },
                        },
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'kind',
                            'attemptIds',
                            'notBefore',
                          ],
                          'properties': <String, Object?>{
                            'kind': <String, Object?>{
                              'const': 'reconcile',
                            },
                            'attemptIds': <String, Object?>{
                              'type': 'array',
                              'maxItems': 6,
                              'items': <String, Object?>{
                                'type': 'string',
                              },
                            },
                            'notBefore': <String, Object?>{
                              'type': 'integer',
                              'minimum': 0,
                              'maximum': 9007199254740991,
                            },
                          },
                        },
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'kind',
                            'reason',
                          ],
                          'properties': <String, Object?>{
                            'kind': <String, Object?>{
                              'const': 'refreshFacts',
                            },
                            'reason': <String, Object?>{
                              'type': 'string',
                              'enum': <Object?>[
                                'eventFactsStale',
                                'routeFactsStale',
                              ],
                            },
                          },
                        },
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'kind',
                            'notBefore',
                            'reason',
                          ],
                          'properties': <String, Object?>{
                            'kind': <String, Object?>{
                              'const': 'wait',
                            },
                            'notBefore': <String, Object?>{
                              'type': 'integer',
                              'minimum': 0,
                              'maximum': 9007199254740991,
                            },
                            'reason': <String, Object?>{
                              'const': 'retryBackoff',
                            },
                          },
                        },
                        <String, Object?>{
                          'type': 'object',
                          'additionalProperties': false,
                          'required': <Object?>[
                            'kind',
                            'reason',
                          ],
                          'properties': <String, Object?>{
                            'kind': <String, Object?>{
                              'const': 'hostDecision',
                            },
                            'reason': <String, Object?>{
                              'type': 'string',
                              'enum': <Object?>[
                                'noEligibleRoute',
                                'attemptLimit',
                                'policyRejected',
                                'recipientNeedsReview',
                                'providerOwnsFallback',
                                'conflictingDeliveryEvidence',
                                'historyUnavailable',
                              ],
                            },
                          },
                        },
                      ],
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
      },
    },
    'action': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'clientActionId',
        'actorId',
        'kind',
        'name',
        'runtimeRevision',
        'virtualNowMillis',
      ],
      'properties': <String, Object?>{
        'clientActionId': <String, Object?>{
          'type': 'string',
        },
        'actorId': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
        },
        'kind': <String, Object?>{
          'type': 'string',
        },
        'name': <String, Object?>{
          'type': 'string',
        },
        'runtimeRevision': <String, Object?>{
          'type': 'integer',
        },
        'virtualNowMillis': <String, Object?>{
          'type': 'integer',
        },
      },
    },
  },
};
