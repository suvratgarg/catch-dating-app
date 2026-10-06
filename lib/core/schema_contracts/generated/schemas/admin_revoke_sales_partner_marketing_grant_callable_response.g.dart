// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callable_responses/admin_revoke_sales_partner_marketing_grant_response.schema.json.

const schemaAdminRevokeSalesPartnerMarketingGrantCallableResponseSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callable_responses/admin_revoke_sales_partner_marketing_grant_response.schema.json',
  'title': 'AdminRevokeSalesPartnerMarketingGrantCallableResponse',
  'x-callable-aliases': <Object?>[
    'adminRevokeSalesPartnerMarketingGrant',
  ],
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'partnerUid',
    'grantId',
    'revision',
    'membershipRevision',
    'status',
  ],
  'properties': <String, Object?>{
    'partnerUid': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 96,
      'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
    },
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
    'membershipRevision': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 1000000,
    },
    'status': <String, Object?>{
      'const': 'revoked',
    },
  },
};
