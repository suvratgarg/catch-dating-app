// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/admin_update_event_details_payload.schema.json.

const schemaAdminUpdateEventDetailsCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/admin_update_event_details_payload.schema.json',
  'title': 'AdminUpdateEventDetailsCallablePayload',
  'description': 'Callable payload accepted by adminUpdateEventDetails. This edits low-risk app-facing canonical event fields through an audited admin callable.',
  'x-callable-shape': 'patch',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'eventId',
    'fields',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'reviewNote': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 1000,
    },
    'fields': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'minProperties': 1,
      'properties': <String, Object?>{
        'description': <String, Object?>{
          'type': 'string',
          'maxLength': 2000,
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
      },
    },
  },
};
