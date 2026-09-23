// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callable_responses/get_participant_form_profile_response.schema.json.

const schemaGetParticipantFormProfileCallableResponseSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callable_responses/get_participant_form_profile_response.schema.json',
  'title': 'GetParticipantFormProfileCallableResponse',
  'description': 'Participant-only form review, with an optimistic profile revision and no unrelated CRM data.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'responseId',
    'organizerId',
    'formId',
    'formTitle',
    'submittedAtMillis',
    'fields',
    'profileRevision',
    'termsVersion',
    'intakeRevision',
  ],
  'properties': <String, Object?>{
    'responseId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'organizerId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'formId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'formTitle': <String, Object?>{
      'type': 'string',
      'maxLength': 160,
    },
    'submittedAtMillis': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 9007199254740991,
    },
    'fields': <String, Object?>{
      'type': 'array',
      'maxItems': 100,
      'items': <String, Object?>{
        'description': 'Only explicitly designated applicant-submitted answers.',
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'questionId',
          'destination',
          'canonicalFieldId',
          'label',
          'kind',
          'value',
          'options',
        ],
        'properties': <String, Object?>{
          'questionId': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 180,
          },
          'destination': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'catchProfile',
              'organizerCard',
            ],
          },
          'canonicalFieldId': <String, Object?>{
            'anyOf': <Object?>[
              <String, Object?>{
                'type': 'string',
                'x-catch-catalog': '../catalogs/person_fields.json',
                'enum': <Object?>[
                  'givenName',
                  'familyName',
                  'displayName',
                  'dateOfBirth',
                  'age',
                  'gender',
                  'phoneNumber',
                  'email',
                  'instagramHandle',
                  'linkedinUrl',
                  'profilePhoto',
                  'city',
                  'heightCm',
                  'occupation',
                  'company',
                  'education',
                  'languages',
                  'relationshipGoal',
                  'interestedInGenders',
                  'drinking',
                  'smoking',
                  'religion',
                  'workout',
                  'diet',
                  'children',
                ],
              },
              <String, Object?>{
                'type': 'null',
              },
            ],
          },
          'label': <String, Object?>{
            'type': 'string',
            'maxLength': 240,
          },
          'kind': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'shortText',
              'longText',
              'singleChoice',
              'multiChoice',
              'date',
              'phone',
              'email',
              'url',
              'number',
              'boolean',
              'file',
              'acknowledgement',
              'signature',
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
                'minimum': -1000000000,
                'maximum': 1000000000,
              },
              <String, Object?>{
                'type': 'boolean',
              },
              <String, Object?>{
                'type': 'null',
              },
              <String, Object?>{
                'type': 'array',
                'maxItems': 100,
                'uniqueItems': true,
                'items': <String, Object?>{
                  'type': 'string',
                  'maxLength': 500,
                },
              },
            ],
          },
          'options': <String, Object?>{
            'type': 'array',
            'maxItems': 100,
            'items': <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'optionId',
                'label',
                'value',
              ],
              'properties': <String, Object?>{
                'optionId': <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                  'maxLength': 180,
                },
                'label': <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                  'maxLength': 160,
                },
                'value': <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                  'maxLength': 160,
                },
              },
            },
          },
        },
      },
    },
    'profileRevision': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 9007199254740991,
    },
    'termsVersion': <String, Object?>{
      'type': 'string',
      'const': 'form-profile-claim-v1',
    },
    'intakeRevision': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 9007199254740991,
    },
  },
};
