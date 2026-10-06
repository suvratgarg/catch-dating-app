// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/edit_sales_partner_outreach_draft_payload.schema.json.

const schemaEditSalesPartnerOutreachDraftCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/edit_sales_partner_outreach_draft_payload.schema.json',
  'title': 'EditSalesPartnerOutreachDraftCallablePayload',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'requestId',
    'organizerId',
    'expectedAssignmentRevision',
    'draftId',
    'expectedContentHash',
    'expectedCompositionRevision',
    'style',
  ],
  'properties': <String, Object?>{
    'requestId': <String, Object?>{
      'type': 'string',
      'minLength': 8,
      'maxLength': 96,
      'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
    },
    'organizerId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 96,
      'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
    },
    'expectedAssignmentRevision': <String, Object?>{
      'type': 'integer',
      'minimum': 1,
    },
    'draftId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 96,
      'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
    },
    'expectedContentHash': <String, Object?>{
      'type': 'string',
      'pattern': '^[a-f0-9]{64}\$',
    },
    'expectedCompositionRevision': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 999999,
    },
    'style': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'greeting',
        'closing',
        'subjectStyle',
        'paragraphStyle',
      ],
      'properties': <String, Object?>{
        'greeting': <String, Object?>{
          'enum': <Object?>[
            'none',
            'hello',
            'hi',
          ],
        },
        'closing': <String, Object?>{
          'enum': <Object?>[
            'none',
            'thanks',
            'best',
          ],
        },
        'subjectStyle': <String, Object?>{
          'enum': <Object?>[
            'original',
            'question',
            'idea',
          ],
        },
        'paragraphStyle': <String, Object?>{
          'enum': <Object?>[
            'spaced',
            'compact',
          ],
        },
      },
    },
  },
  'x-callable-aliases': <Object?>[
    'editSalesPartnerOutreachDraft',
  ],
};
