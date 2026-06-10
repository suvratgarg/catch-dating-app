// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from callables/admin_update_club_details_payload.schema.json.

const schemaAdminUpdateClubDetailsCallablePayloadSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/callables/admin_update_club_details_payload.schema.json',
  'title': 'AdminUpdateClubDetailsCallablePayload',
  'description': 'Callable payload accepted by adminUpdateClubDetails. This edits owner-safe organizer listing fields through an audited admin callable.',
  'x-callable-shape': 'patch',
  'type': 'object',
  'additionalProperties': false,
  'required': <Object?>[
    'clubId',
    'fields',
  ],
  'properties': <String, Object?>{
    'clubId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
    },
    'fields': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'minProperties': 1,
      'properties': <String, Object?>{
        'name': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 120,
        },
        'description': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 2000,
        },
        'location': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'minLength': 1,
          'maxLength': 80,
          'pattern': '^[a-z0-9-]+\$',
        },
        'area': <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 120,
        },
        'tags': <String, Object?>{
          'type': 'array',
          'maxItems': 20,
          'uniqueItems': true,
          'items': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 80,
          },
        },
        'instagramHandle': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 320,
        },
        'phoneNumber': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 320,
        },
        'email': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 320,
        },
        'imageUrl': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'string',
              'format': 'uri',
              'maxLength': 2048,
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'profileImageUrl': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'string',
              'format': 'uri',
              'maxLength': 2048,
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
        'entityKind': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'club',
            'venue',
            'eventOrganizer',
            'creatorCommunity',
            'brand',
          ],
        },
        'entitySubtypes': <String, Object?>{
          'type': 'array',
          'maxItems': 20,
          'uniqueItems': true,
          'items': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 80,
          },
        },
        'displayCategory': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 120,
        },
        'cityName': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 120,
        },
        'regionName': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 120,
        },
        'countryCode': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'pattern': '^[A-Z]{2}\$',
        },
        'countryName': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'maxLength': 120,
        },
        'appVisibility': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'discoverable',
            'hidden',
          ],
        },
        'publicPage': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'minProperties': 1,
          'properties': <String, Object?>{
            'slug': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 160,
              'pattern': '^[a-z0-9-]+\$',
            },
            'citySlug': <String, Object?>{
              'type': <Object?>[
                'string',
                'null',
              ],
              'minLength': 1,
              'maxLength': 80,
              'pattern': '^[a-z0-9-]+\$',
            },
            'canonicalPath': <String, Object?>{
              'type': 'string',
              'minLength': 1,
              'maxLength': 240,
            },
            'publishStatus': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'draft',
                'qa',
                'published',
                'suppressed',
                'removed',
              ],
            },
            'seoTitle': <String, Object?>{
              'type': <Object?>[
                'string',
                'null',
              ],
              'maxLength': 120,
            },
            'seoDescription': <String, Object?>{
              'type': <Object?>[
                'string',
                'null',
              ],
              'maxLength': 320,
            },
          },
        },
        'provenance': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'minProperties': 1,
          'properties': <String, Object?>{
            'sourceConfidence': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'seedOnly',
                'low',
                'medium',
                'high',
                'ownerVerified',
              ],
            },
            'verificationStatus': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'unverified',
                'sourceBacked',
                'ownerVerified',
              ],
            },
          },
        },
        'publicProfile': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'minProperties': 1,
          'properties': <String, Object?>{
            'headline': <String, Object?>{
              'type': <Object?>[
                'string',
                'null',
              ],
              'maxLength': 160,
            },
            'summary': <String, Object?>{
              'type': <Object?>[
                'string',
                'null',
              ],
              'maxLength': 800,
            },
            'sourceSummary': <String, Object?>{
              'type': <Object?>[
                'string',
                'null',
              ],
              'maxLength': 800,
            },
            'formats': <String, Object?>{
              'type': 'array',
              'maxItems': 12,
              'items': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 80,
              },
            },
            'fitNotes': <String, Object?>{
              'type': 'array',
              'maxItems': 8,
              'items': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 400,
              },
            },
            'missingEvidence': <String, Object?>{
              'type': 'array',
              'maxItems': 12,
              'items': <String, Object?>{
                'type': 'string',
                'minLength': 1,
                'maxLength': 200,
              },
            },
          },
        },
      },
    },
    'reviewNote': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 1000,
    },
  },
};
