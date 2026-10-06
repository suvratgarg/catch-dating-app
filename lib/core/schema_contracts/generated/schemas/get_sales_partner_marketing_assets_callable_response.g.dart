// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callable_responses/get_sales_partner_marketing_assets_response.schema.json.

const schemaGetSalesPartnerMarketingAssetsCallableResponseSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callable_responses/get_sales_partner_marketing_assets_response.schema.json',
  'title': 'GetSalesPartnerMarketingAssetsCallableResponse',
  'x-callable-aliases': <Object?>[
    'getSalesPartnerMarketingAssets',
  ],
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'grantId',
    'revision',
    'organizerId',
    'campaignId',
    'channel',
    'expiresAt',
    'assets',
    'sendAuthority',
    'publicationAuthority',
    'guestAuthority',
    'providerAuthority',
  ],
  'properties': <String, Object?>{
    'grantId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 96,
      'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
    },
    'revision': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 1000000,
    },
    'organizerId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 96,
      'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
    },
    'campaignId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 96,
      'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
    },
    'channel': <String, Object?>{
      'enum': <Object?>[
        'email',
        'whatsapp',
        'other',
      ],
    },
    'expiresAt': <String, Object?>{
      'type': 'string',
      'format': 'date-time',
      'maxLength': 48,
    },
    'assets': <String, Object?>{
      'type': 'array',
      'minItems': 1,
      'maxItems': 12,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'assetId',
          'kind',
          'text',
          'validUntil',
        ],
        'properties': <String, Object?>{
          'assetId': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 96,
            'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
          },
          'kind': <String, Object?>{
            'enum': <Object?>[
              'capability',
              'reference',
              'cta',
            ],
          },
          'text': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 2000,
          },
          'validUntil': <String, Object?>{
            'type': 'string',
            'format': 'date-time',
            'maxLength': 48,
          },
        },
      },
    },
    'sendAuthority': <String, Object?>{
      'const': false,
    },
    'publicationAuthority': <String, Object?>{
      'const': false,
    },
    'guestAuthority': <String, Object?>{
      'const': false,
    },
    'providerAuthority': <String, Object?>{
      'const': false,
    },
  },
};
