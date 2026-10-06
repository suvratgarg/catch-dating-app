// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callable_responses/edit_sales_partner_outreach_draft_response.schema.json.

const schemaEditSalesPartnerOutreachDraftResponseSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callable_responses/edit_sales_partner_outreach_draft_response.schema.json',
  'title': 'EditSalesPartnerOutreachDraftResponse',
  'x-callable-aliases': <Object?>[
    'editSalesPartnerOutreachDraft',
  ],
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'draftId',
    'contentHash',
    'compositionRevision',
    'status',
    'sendAuthority',
  ],
  'properties': <String, Object?>{
    'draftId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 96,
      'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
    },
    'contentHash': <String, Object?>{
      'type': 'string',
      'pattern': '^[a-f0-9]{64}\$',
    },
    'compositionRevision': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
      'maximum': 1000000,
    },
    'status': <String, Object?>{
      'const': 'pending_review',
    },
    'sendAuthority': <String, Object?>{
      'const': false,
    },
  },
};
