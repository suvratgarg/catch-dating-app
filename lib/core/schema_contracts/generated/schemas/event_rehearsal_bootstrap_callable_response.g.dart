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
