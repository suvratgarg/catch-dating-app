// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/admin_review_sales_partner_marketing_grant_payload.schema.json.

const schemaAdminReviewSalesPartnerMarketingGrantCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/admin_review_sales_partner_marketing_grant_payload.schema.json',
  'title': 'AdminReviewSalesPartnerMarketingGrantCallablePayload',
  'x-callable-aliases': <Object?>[
    'adminReviewSalesPartnerMarketingGrant',
  ],
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'partnerUid',
    'organizerId',
    'campaignId',
    'channel',
    'assetIds',
    'requestId',
    'expectedMembershipRevision',
    'expectedGrantRevision',
    'sourceHash',
    'expiresAt',
    'reason',
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
    'requestId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
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
    'expiresAt': <String, Object?>{
      'type': 'string',
      'format': 'date-time',
      'maxLength': 48,
    },
    'reason': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 1000,
    },
  },
};
