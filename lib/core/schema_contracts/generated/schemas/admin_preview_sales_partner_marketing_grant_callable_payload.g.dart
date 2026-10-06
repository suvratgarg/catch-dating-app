// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/admin_preview_sales_partner_marketing_grant_payload.schema.json.

const schemaAdminPreviewSalesPartnerMarketingGrantCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/admin_preview_sales_partner_marketing_grant_payload.schema.json',
  'title': 'AdminPreviewSalesPartnerMarketingGrantCallablePayload',
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
      'type': 'string',
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
  },
};
