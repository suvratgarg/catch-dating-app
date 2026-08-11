// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callable_responses/get_event_runtime_bootstrap_response.schema.json.

const schemaGetEventRuntimeBootstrapCallableResponseSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callable_responses/get_event_runtime_bootstrap_response.schema.json',
  'title': 'GetEventRuntimeBootstrapCallableResponse',
  'description': 'Sanitized event and caller state for the no-download runtime.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'event',
    'participant',
  ],
  'properties': <String, Object?>{
    'event': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'publicRuntimeId',
        'title',
        'startTimeMillis',
        'endTimeMillis',
        'locationName',
      ],
      'properties': <String, Object?>{
        'publicRuntimeId': <String, Object?>{
          'type': 'string',
          'pattern': '^[A-Za-z0-9_-]{20,80}\$',
        },
        'title': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 240,
        },
        'startTimeMillis': <String, Object?>{
          'type': 'integer',
        },
        'endTimeMillis': <String, Object?>{
          'type': 'integer',
        },
        'locationName': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 240,
        },
      },
    },
    'participant': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'null',
        },
        <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'accessStatus',
            'attendanceStatus',
            'requiredFieldIds',
            'completedFieldIds',
            'runtimeProfile',
          ],
          'properties': <String, Object?>{
            'accessStatus': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'needsClaim',
                'pendingApproval',
                'needsInput',
                'ready',
                'optedOut',
                'revoked',
              ],
            },
            'attendanceStatus': <String, Object?>{
              'type': <Object?>[
                'string',
                'null',
              ],
              'enum': <Object?>[
                'invited',
                'registered',
                'waitlisted',
                'checkedIn',
                'cancelled',
                null,
              ],
            },
            'requiredFieldIds': <String, Object?>{
              'type': 'array',
              'items': <String, Object?>{
                'type': 'string',
              },
              'maxItems': 5,
            },
            'completedFieldIds': <String, Object?>{
              'type': 'array',
              'items': <String, Object?>{
                'type': 'string',
              },
              'maxItems': 5,
            },
            'runtimeProfile': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'displayName',
                'gender',
                'interestedInGenders',
                'relationshipGoal',
                'dateOfBirthMillis',
              ],
              'properties': <String, Object?>{
                'displayName': <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                  'maxLength': 120,
                },
                'gender': <String, Object?>{
                  'type': <Object?>[
                    'string',
                    'null',
                  ],
                  'enum': <Object?>[
                    'man',
                    'woman',
                    'nonBinary',
                    'other',
                    null,
                  ],
                },
                'interestedInGenders': <String, Object?>{
                  'type': 'array',
                  'uniqueItems': true,
                  'items': <String, Object?>{
                    'type': 'string',
                    'enum': <Object?>[
                      'man',
                      'woman',
                      'nonBinary',
                      'other',
                    ],
                  },
                },
                'relationshipGoal': <String, Object?>{
                  'type': <Object?>[
                    'string',
                    'null',
                  ],
                  'enum': <Object?>[
                    'relationship',
                    'casual',
                    'marriage',
                    'friendship',
                    'unsure',
                    null,
                  ],
                },
                'dateOfBirthMillis': <String, Object?>{
                  'type': <Object?>[
                    'integer',
                    'null',
                  ],
                },
              },
            },
          },
        },
      ],
    },
  },
};
