// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callable_responses/admin_preview_sales_partner_marketing_grant_response.schema.json.

const schemaAdminPreviewSalesPartnerMarketingGrantCallableResponseSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callable_responses/admin_preview_sales_partner_marketing_grant_response.schema.json',
  'title': 'AdminPreviewSalesPartnerMarketingGrantCallableResponse',
  'x-callable-aliases': <Object?>[
    'adminPreviewSalesPartnerMarketingGrant',
  ],
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'partnerUid',
    'organizerId',
    'campaignId',
    'channel',
    'assetIds',
    'grantId',
    'expectedMembershipRevision',
    'expectedGrantRevision',
    'sourceHash',
    'expiresBefore',
    'assets',
    'sendAuthority',
    'publicationAuthority',
  ],
  'properties': <String, Object?>{
    'partnerUid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 96,
      'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
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
    'assetIds': <String, Object?>{
      'type': 'array',
      'minItems': 1,
      'maxItems': 12,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
        'maxLength': 96,
        'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
      },
    },
    'grantId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 96,
      'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
    },
    'expectedMembershipRevision': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 1000000,
    },
    'expectedGrantRevision': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 1000000,
    },
    'sourceHash': <String, Object?>{
      'type': 'string',
      'pattern': '^[a-f0-9]{64}\$',
    },
    'expiresBefore': <String, Object?>{
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
  },
};
