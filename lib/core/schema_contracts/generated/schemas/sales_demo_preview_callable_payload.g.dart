// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/sales_demo_preview.schema.json.

const schemaSalesDemoPreviewCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/sales_demo_preview.schema.json',
  'title': 'GetSalesDemoPreviewCallablePayload',
  'description': 'Anonymous read-only preview. Fetching never opens or consumes an invitation.',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'invitationId',
  ],
  'properties': <String, Object?>{
    'invitationId': <String, Object?>{
      'type': 'string',
      'pattern': '^[A-Za-z0-9_-]{3,128}\$',
    },
  },
  'x-callable': 'getSalesDemoPreview',
};
