// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from firestore/config_cities.schema.json.

const schemaConfigCitiesDocumentSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/firestore/config_cities.schema.json',
  'title': 'ConfigCitiesDocument',
  'description': 'Public city configuration stored at config/cities.',
  'type': 'object',
  'additionalProperties': false,
  'x-firestore-collection': 'config_cities',
  'x-firestore-path': 'config/cities',
  'x-document-id-field': 'cities',
  'x-owner': 'admin city configuration tooling',
  'required': <Object?>[
    'cityNames',
  ],
  'properties': <String, Object?>{
    'cityNames': <String, Object?>{
      'type': 'array',
      'items': <String, Object?>{
        'type': <Object?>[
          'string',
          'null',
        ],
        'minLength': 1,
        'maxLength': 80,
        'pattern': '^[a-z0-9-]+\$',
      },
      'minItems': 1,
      'uniqueItems': true,
      'x-catch-ownership': 'server-only',
    },
    'cities': <String, Object?>{
      'type': 'array',
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'name',
          'label',
          'latitude',
          'longitude',
          'countryIsoCode',
          'currencyCode',
          'dialCode',
          'timeZone',
        ],
        'properties': <String, Object?>{
          'name': <String, Object?>{
            'type': <Object?>[
              'string',
              'null',
            ],
            'minLength': 1,
            'maxLength': 80,
            'pattern': '^[a-z0-9-]+\$',
          },
          'label': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 80,
          },
          'latitude': <String, Object?>{
            'type': <Object?>[
              'number',
              'null',
            ],
            'minimum': -90,
            'maximum': 90,
          },
          'longitude': <String, Object?>{
            'type': <Object?>[
              'number',
              'null',
            ],
            'minimum': -180,
            'maximum': 180,
          },
          'countryIsoCode': <String, Object?>{
            'type': 'string',
            'pattern': '^[A-Z]{2}\$',
          },
          'currencyCode': <String, Object?>{
            'type': 'string',
            'pattern': '^[A-Z]{3}\$',
          },
          'dialCode': <String, Object?>{
            'type': 'string',
            'pattern': '^\\+\\d{1,4}\$',
          },
          'timeZone': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 80,
          },
        },
      },
      'uniqueItems': true,
      'x-catch-ownership': 'server-only',
    },
  },
};
