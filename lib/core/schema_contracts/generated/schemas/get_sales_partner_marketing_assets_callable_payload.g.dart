// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/get_sales_partner_marketing_assets_payload.schema.json.

const schemaGetSalesPartnerMarketingAssetsCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/get_sales_partner_marketing_assets_payload.schema.json',
  'title': 'GetSalesPartnerMarketingAssetsCallablePayload',
  'x-callable-aliases': <Object?>[
    'getSalesPartnerMarketingAssets',
  ],
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'grantId',
    'expectedGrantRevision',
  ],
  'properties': <String, Object?>{
    'grantId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 96,
      'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
    },
    'expectedGrantRevision': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 1000000,
    },
  },
};
