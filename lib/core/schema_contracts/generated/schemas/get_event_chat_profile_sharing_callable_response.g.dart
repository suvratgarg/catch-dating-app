// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callable_responses/get_event_chat_profile_sharing_response.schema.json.

const schemaGetEventChatProfileSharingCallableResponseSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callable_responses/get_event_chat_profile_sharing_response.schema.json',
  'title': 'GetEventChatProfileSharingCallableResponse',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'eventId',
    'organizerId',
    'revision',
    'selection',
    'canShare',
    'profileRevision',
    'membershipRevision',
    'coreFields',
    'photoIds',
  ],
  'properties': <String, Object?>{
    'eventId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'organizerId': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
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
    'selection': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'profileRevision',
            'membershipRevision',
            'coreFieldIds',
            'photoId',
            'card',
            'termsVersion',
          ],
          'properties': <String, Object?>{
            'profileRevision': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 9007199254740991,
            },
            'membershipRevision': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
              'maximum': 9007199254740991,
            },
            'coreFieldIds': <String, Object?>{
              'type': 'array',
              'maxItems': 14,
              'uniqueItems': true,
              'items': <String, Object?>{
                'type': 'string',
                'enum': <Object?>[
                  'age',
                  'gender',
                  'city',
                  'heightCm',
                  'occupation',
                  'company',
                  'education',
                  'languages',
                  'relationshipGoal',
                  'drinking',
                  'smoking',
                  'workout',
                  'diet',
                  'children',
                ],
              },
            },
            'photoId': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                  'maxLength': 80,
                  'pattern': '^[A-Za-z0-9_-]+\$',
                },
                <String, Object?>{
                  'type': 'null',
                },
              ],
            },
            'card': <String, Object?>{
              'anyOf': <Object?>[
                <String, Object?>{
                  'type': 'object',
                  'additionalProperties': false,
                  'required': <Object?>[
                    'responseId',
                    'revision',
                    'questionIds',
                  ],
                  'properties': <String, Object?>{
                    'responseId': <String, Object?>{
                      'type': 'string',
                      'minLength': 1,
                      'maxLength': 180,
                    },
                    'revision': <String, Object?>{
                      'type': 'integer',
                      'minimum': 0,
                      'maximum': 9007199254740991,
                    },
                    'questionIds': <String, Object?>{
                      'type': 'array',
                      'uniqueItems': true,
                      'maxItems': 20,
                      'items': <String, Object?>{
                        'type': 'string',
                        'minLength': 1,
                        'maxLength': 180,
                      },
                      'minItems': 1,
                    },
                  },
                },
                <String, Object?>{
                  'type': 'null',
                },
              ],
            },
            'termsVersion': <String, Object?>{
              'type': 'string',
              'const': 'event-profile-sharing-v1',
            },
          },
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'canShare': <String, Object?>{
      'type': 'boolean',
    },
    'profileRevision': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 9007199254740991,
    },
    'membershipRevision': <String, Object?>{
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
    'coreFields': <String, Object?>{
      'type': 'array',
      'maxItems': 14,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'fieldId',
          'value',
        ],
        'properties': <String, Object?>{
          'fieldId': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'age',
              'gender',
              'city',
              'heightCm',
              'occupation',
              'company',
              'education',
              'languages',
              'relationshipGoal',
              'drinking',
              'smoking',
              'workout',
              'diet',
              'children',
            ],
          },
          'value': <String, Object?>{
            'anyOf': <Object?>[
              <String, Object?>{
                'type': 'string',
                'maxLength': 10000,
              },
              <String, Object?>{
                'type': 'number',
              },
              <String, Object?>{
                'type': 'boolean',
              },
              <String, Object?>{
                'type': 'array',
                'maxItems': 100,
                'items': <String, Object?>{
                  'type': 'string',
                  'maxLength': 10000,
                },
              },
            ],
          },
        },
      },
    },
    'photoIds': <String, Object?>{
      'type': 'array',
      'maxItems': 12,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
        'maxLength': 80,
      },
    },
  },
};
