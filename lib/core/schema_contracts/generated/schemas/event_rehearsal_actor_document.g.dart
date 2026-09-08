// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from firestore/event_rehearsal_actors.schema.json.

const schemaEventRehearsalActorDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/event_rehearsal_actors.schema.json',
  'title': 'EventRehearsalActorDocument',
  'description': 'Synthetic participant state stored only for an isolated rehearsal.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'eventRehearsalActors',
  'x-firestore-path': 'eventRehearsalActors/{actorDocumentId}',
  'x-document-id-field': 'id',
  'x-owner': 'event rehearsal callables',
  'required': <Object?>[
    'sessionId',
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
    'lastActionAt',
    'createdAt',
    'updatedAt',
  ],
  'properties': <String, Object?>{
    'sessionId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'x-catch-ownership': 'callable-owned',
    },
    'actorId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'x-catch-ownership': 'callable-owned',
    },
    'displayName': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'x-catch-ownership': 'callable-owned',
    },
    'persona': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'firstTimer',
        'regular',
        'quiet',
        'connector',
        'external',
        'sparseProfile',
        'accessibilityNeeds',
        'walkIn',
      ],
      'x-catch-ownership': 'callable-owned',
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
      'x-catch-ownership': 'callable-owned',
    },
    'connectionState': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'connected',
        'disconnected',
      ],
      'x-catch-ownership': 'callable-owned',
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
      'x-catch-ownership': 'callable-owned',
    },
    'optedOut': <String, Object?>{
      'type': 'boolean',
      'x-catch-ownership': 'callable-owned',
    },
    'keepApartActorIds': <String, Object?>{
      'type': 'array',
      'maxItems': 10,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
        'maxLength': 180,
      },
      'x-catch-ownership': 'callable-owned',
    },
    'helpRequested': <String, Object?>{
      'type': 'boolean',
      'x-catch-ownership': 'callable-owned',
    },
    'promptCompleted': <String, Object?>{
      'type': 'boolean',
      'x-catch-ownership': 'callable-owned',
    },
    'layoutUnitId': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'string',
          'pattern': '^table-[1-9][0-9]*\$',
          'maxLength': 40,
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
      'x-catch-ownership': 'callable-owned',
    },
    'confirmedLayoutUnitId': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'string',
          'pattern': '^table-[1-9][0-9]*\$',
          'maxLength': 40,
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
      'x-catch-ownership': 'callable-owned',
    },
    'lastActionAt': <String, Object?>{
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
      'x-catch-ownership': 'callable-owned',
    },
  },
};
