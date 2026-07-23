// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from public/website_host_listing_projection.schema.json.

const schemaWebsiteHostListingProjectionSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/public/website_host_listing_projection.schema.json',
  'title': 'WebsiteHostListingProjection',
  'description': 'Public organizer listing projection consumed by the marketing website and future shared web/app listing surfaces. It is generated from approved organizer, seed, or demo data and is not the canonical organizer document.',
  'type': 'object',
  'additionalProperties': false,
  'x-owner': 'website/scripts/generateOrganizerListings.mjs',
  'required': <Object?>[
    'id',
    'listingVariant',
    'dataOrigin',
    'name',
    'slug',
    'city',
    'citySlug',
    'region',
    'country',
    'path',
    'category',
    'status',
    'indexing',
    'sourceConfidence',
    'headline',
    'description',
    'sourceSummary',
    'logo',
    'formats',
    'facts',
    'eventEvidence',
    'reviews',
    'fitNotes',
    'missingEvidence',
    'sources',
    'claim',
    'publicApi',
    'authority',
    'capabilities',
    'lastVerifiedAt',
    'searchText',
  ],
  'properties': <String, Object?>{
    'id': <String, Object?>{
      'type': 'string',
      'minLength': 1,
    },
    'listingVariant': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'unclaimedScraped',
        'appCreatedClub',
      ],
    },
    'dataOrigin': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'scrapedSeed',
        'catchDemo',
        'organizerIntake',
      ],
    },
    'name': <String, Object?>{
      'type': 'string',
      'minLength': 1,
    },
    'slug': <String, Object?>{
      'type': 'string',
      'minLength': 1,
    },
    'city': <String, Object?>{
      'type': 'string',
      'minLength': 1,
    },
    'citySlug': <String, Object?>{
      'type': 'string',
      'minLength': 1,
    },
    'region': <String, Object?>{
      'type': 'string',
    },
    'country': <String, Object?>{
      'type': 'string',
    },
    'path': <String, Object?>{
      'type': 'string',
      'pattern': '^/[^?#]*/\$',
    },
    'legacyPaths': <String, Object?>{
      'type': 'array',
      'items': <String, Object?>{
        'type': 'string',
        'pattern': '^/[^?#]*/\$',
      },
      'uniqueItems': true,
    },
    'category': <String, Object?>{
      'type': 'string',
      'minLength': 1,
    },
    'status': <String, Object?>{
      'type': 'string',
      'minLength': 1,
    },
    'indexing': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'index, follow',
        'noindex, follow',
      ],
    },
    'sourceConfidence': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'first_party',
        'seedOnly',
        'high',
        'medium',
        'low',
        'ownerVerified',
      ],
    },
    'headline': <String, Object?>{
      'type': 'string',
      'minLength': 1,
    },
    'description': <String, Object?>{
      'type': 'string',
      'minLength': 1,
    },
    'sourceSummary': <String, Object?>{
      'type': 'string',
      'minLength': 1,
    },
    'logo': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'mode',
        'text',
        'status',
      ],
      'properties': <String, Object?>{
        'mode': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'monogram',
          ],
        },
        'text': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'status': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
      },
    },
    'formats': <String, Object?>{
      'type': 'array',
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
      },
    },
    'facts': <String, Object?>{
      'type': 'array',
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'label',
          'value',
        ],
        'properties': <String, Object?>{
          'label': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'value': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
        },
      },
    },
    'metrics': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'properties': <String, Object?>{
        'memberCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
        },
        'rating': <String, Object?>{
          'type': 'number',
          'minimum': 0,
          'maximum': 5,
        },
        'reviewCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
        },
        'nextEventAt': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
        },
        'nextEventLabel': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
        },
      },
    },
    'host': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'name',
        'role',
        'avatarUrl',
      ],
      'properties': <String, Object?>{
        'name': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'role': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'avatarUrl': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'format': 'uri',
        },
      },
    },
    'catchEvents': <String, Object?>{
      'type': 'array',
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'id',
          'role',
          'title',
          'activityKind',
          'timeline',
          'startTime',
          'endTime',
          'date',
          'location',
          'summary',
          'capacityLimit',
          'bookedCount',
          'checkedInCount',
          'waitlistedCount',
          'priceLabel',
        ],
        'properties': <String, Object?>{
          'id': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'role': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'title': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'activityKind': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'timeline': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'upcoming',
              'past',
            ],
          },
          'startTime': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'endTime': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'timezone': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'date': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'location': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'locationDetails': <String, Object?>{
            'type': 'string',
          },
          'summary': <String, Object?>{
            'type': 'string',
          },
          'requirements': <String, Object?>{
            'type': 'string',
          },
          'accessibility': <String, Object?>{
            'type': 'string',
          },
          'capacityLimit': <String, Object?>{
            'type': 'integer',
            'minimum': 0,
          },
          'bookedCount': <String, Object?>{
            'type': 'integer',
            'minimum': 0,
          },
          'checkedInCount': <String, Object?>{
            'type': 'integer',
            'minimum': 0,
          },
          'waitlistedCount': <String, Object?>{
            'type': 'integer',
            'minimum': 0,
          },
          'priceLabel': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'scorecard': <String, Object?>{
            'anyOf': <Object?>[
              <String, Object?>{
                'type': 'object',
                'additionalProperties': true,
              },
              <String, Object?>{
                'type': 'null',
              },
            ],
          },
        },
      },
    },
    'externalEvents': <String, Object?>{
      'type': 'array',
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'id',
          'title',
          'activityKind',
          'availability',
          'startTime',
          'endTime',
          'date',
          'location',
          'summary',
          'priceLabel',
          'sourceLabel',
          'sourceHref',
          'externalLinkCount',
          'dedupeKey',
        ],
        'properties': <String, Object?>{
          'id': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'title': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'activityKind': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'availability': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'read_only_external',
            ],
          },
          'startTime': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'endTime': <String, Object?>{
            'type': <Object?>[
              'string',
              'null',
            ],
          },
          'timezone': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'date': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'location': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'locationDetails': <String, Object?>{
            'type': 'string',
          },
          'summary': <String, Object?>{
            'type': 'string',
          },
          'requirements': <String, Object?>{
            'type': 'string',
          },
          'accessibility': <String, Object?>{
            'type': 'string',
          },
          'priceLabel': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'sourceLabel': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'sourceHref': <String, Object?>{
            'type': 'string',
            'format': 'uri',
          },
          'externalLinkCount': <String, Object?>{
            'type': 'integer',
            'minimum': 1,
          },
          'dedupeKey': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
        },
      },
    },
    'eventSuccessSummary': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'bookedCount',
            'checkedInCount',
            'mutualMatchCount',
            'chatStartedCount',
            'catchSentCount',
            'safetyIncidentCount',
          ],
          'properties': <String, Object?>{
            'bookedCount': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
            },
            'checkedInCount': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
            },
            'mutualMatchCount': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
            },
            'chatStartedCount': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
            },
            'catchSentCount': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
            },
            'safetyIncidentCount': <String, Object?>{
              'type': 'integer',
              'minimum': 0,
            },
          },
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'eventEvidence': <String, Object?>{
      'type': 'array',
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'title',
          'date',
          'location',
          'summary',
          'facts',
          'sourceLabel',
          'sourceHref',
        ],
        'properties': <String, Object?>{
          'title': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'date': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'location': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'summary': <String, Object?>{
            'type': 'string',
          },
          'facts': <String, Object?>{
            'type': 'array',
            'items': <String, Object?>{
              'type': 'string',
              'minLength': 1,
            },
          },
          'sourceLabel': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'sourceHref': <String, Object?>{
            'type': 'string',
            'format': 'uri',
          },
        },
      },
    },
    'reviews': <String, Object?>{
      'type': 'array',
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'id',
          'eventId',
          'reviewerName',
          'rating',
          'comment',
          'createdAt',
          'verificationStatus',
          'source',
          'isAnonymous',
          'ownerResponse',
        ],
        'properties': <String, Object?>{
          'id': <String, Object?>{
            'type': <Object?>[
              'string',
              'null',
            ],
          },
          'eventId': <String, Object?>{
            'type': <Object?>[
              'string',
              'null',
            ],
          },
          'reviewerName': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'rating': <String, Object?>{
            'type': 'number',
            'minimum': 0,
            'maximum': 5,
          },
          'comment': <String, Object?>{
            'type': 'string',
          },
          'createdAt': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'verificationStatus': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'verified',
              'unverified',
            ],
          },
          'source': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'catchEvent',
              'publicListing',
            ],
          },
          'isAnonymous': <String, Object?>{
            'type': 'boolean',
          },
          'ownerResponse': <String, Object?>{
            'anyOf': <Object?>[
              <String, Object?>{
                'type': 'object',
                'additionalProperties': false,
                'required': <Object?>[
                  'hostName',
                  'hostAvatarUrl',
                  'message',
                  'updatedAt',
                ],
                'properties': <String, Object?>{
                  'hostName': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                  },
                  'hostAvatarUrl': <String, Object?>{
                    'type': <Object?>[
                      'string',
                      'null',
                    ],
                    'format': 'uri',
                  },
                  'message': <String, Object?>{
                    'type': 'string',
                  },
                  'updatedAt': <String, Object?>{
                    'type': 'string',
                    'minLength': 1,
                  },
                },
              },
              <String, Object?>{
                'type': 'null',
              },
            ],
          },
        },
      },
    },
    'fitNotes': <String, Object?>{
      'type': 'array',
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
      },
    },
    'missingEvidence': <String, Object?>{
      'type': 'array',
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
      },
    },
    'sources': <String, Object?>{
      'type': 'array',
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'type',
          'label',
          'detail',
          'confidence',
        ],
        'properties': <String, Object?>{
          'type': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'label': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'detail': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
          'href': <String, Object?>{
            'type': 'string',
            'format': 'uri',
          },
          'confidence': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'high',
              'medium',
              'low',
            ],
          },
        },
      },
    },
    'claim': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'href',
        'label',
      ],
      'properties': <String, Object?>{
        'href': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'label': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
      },
    },
    'publicApi': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'state',
        'reason',
        'claimTargetSyncStatus',
      ],
      'properties': <String, Object?>{
        'state': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'enabled',
            'disabled',
          ],
        },
        'reason': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'claimTargetSyncStatus': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'in_sync',
            'write_needed',
            'static_fixture',
            'unknown',
          ],
        },
      },
    },
    'authority': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'ownershipState',
        'claimState',
        'provenanceOrigin',
        'sourceConfidence',
        'verificationStatus',
        'appVisibility',
        'publishStatus',
        'indexStatus',
      ],
      'properties': <String, Object?>{
        'ownershipState': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'programmatic',
            'userCreated',
            'claimed',
            'transferred',
          ],
        },
        'claimState': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'unclaimed',
            'claimPending',
            'claimed',
            'verified',
            'suppressed',
          ],
        },
        'provenanceOrigin': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'userCreated',
            'scraper',
            'adminSeed',
            'import',
          ],
        },
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
        'appVisibility': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'discoverable',
            'hidden',
          ],
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
        'indexStatus': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'noindex',
            'indexReady',
            'indexed',
          ],
        },
      },
    },
    'capabilities': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'claimRequest',
        'publicReviews',
      ],
      'properties': <String, Object?>{
        'claimRequest': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'state',
            'reason',
          ],
          'properties': <String, Object?>{
            'state': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'enabled',
                'disabled',
              ],
            },
            'reason': <String, Object?>{
              'type': 'string',
              'minLength': 1,
            },
          },
        },
        'publicReviews': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'targetState',
            'readState',
            'writeState',
            'reason',
          ],
          'properties': <String, Object?>{
            'targetState': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'enabled',
                'disabled',
              ],
            },
            'readState': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'enabled',
                'disabled',
              ],
            },
            'writeState': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'enabled',
                'disabled',
              ],
            },
            'reason': <String, Object?>{
              'type': 'string',
              'minLength': 1,
            },
          },
          'not': <String, Object?>{
            'anyOf': <Object?>[
              <String, Object?>{
                'properties': <String, Object?>{
                  'targetState': <String, Object?>{
                    'const': 'disabled',
                  },
                  'readState': <String, Object?>{
                    'const': 'enabled',
                  },
                },
                'required': <Object?>[
                  'targetState',
                  'readState',
                ],
              },
              <String, Object?>{
                'properties': <String, Object?>{
                  'targetState': <String, Object?>{
                    'const': 'disabled',
                  },
                  'writeState': <String, Object?>{
                    'const': 'enabled',
                  },
                },
                'required': <Object?>[
                  'targetState',
                  'writeState',
                ],
              },
              <String, Object?>{
                'properties': <String, Object?>{
                  'readState': <String, Object?>{
                    'const': 'disabled',
                  },
                  'writeState': <String, Object?>{
                    'const': 'enabled',
                  },
                },
                'required': <Object?>[
                  'readState',
                  'writeState',
                ],
              },
            ],
          },
        },
      },
    },
    'lastVerifiedAt': <String, Object?>{
      'type': 'string',
      'minLength': 1,
    },
    'searchText': <String, Object?>{
      'type': 'string',
      'minLength': 1,
    },
  },
  'not': <String, Object?>{
    'properties': <String, Object?>{
      'authority': <String, Object?>{
        'properties': <String, Object?>{
          'claimState': <String, Object?>{
            'const': 'suppressed',
          },
          'publishStatus': <String, Object?>{
            'const': 'published',
          },
        },
        'required': <Object?>[
          'claimState',
          'publishStatus',
        ],
      },
    },
    'required': <Object?>[
      'authority',
    ],
  },
  'definitions': <String, Object?>{
    'nonEmptyString': <String, Object?>{
      'type': 'string',
      'minLength': 1,
    },
    'routePath': <String, Object?>{
      'type': 'string',
      'pattern': '^/[^?#]*/\$',
    },
    'urlOrNull': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'format': 'uri',
    },
    'labelValue': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'label',
        'value',
      ],
      'properties': <String, Object?>{
        'label': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'value': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
      },
    },
    'logo': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'mode',
        'text',
        'status',
      ],
      'properties': <String, Object?>{
        'mode': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'monogram',
          ],
        },
        'text': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'status': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
      },
    },
    'metrics': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'properties': <String, Object?>{
        'memberCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
        },
        'rating': <String, Object?>{
          'type': 'number',
          'minimum': 0,
          'maximum': 5,
        },
        'reviewCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
        },
        'nextEventAt': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
        },
        'nextEventLabel': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
        },
      },
    },
    'host': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'name',
        'role',
        'avatarUrl',
      ],
      'properties': <String, Object?>{
        'name': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'role': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'avatarUrl': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'format': 'uri',
        },
      },
    },
    'catchEvent': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'id',
        'role',
        'title',
        'activityKind',
        'timeline',
        'startTime',
        'endTime',
        'date',
        'location',
        'summary',
        'capacityLimit',
        'bookedCount',
        'checkedInCount',
        'waitlistedCount',
        'priceLabel',
      ],
      'properties': <String, Object?>{
        'id': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'role': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'title': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'activityKind': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'timeline': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'upcoming',
            'past',
          ],
        },
        'startTime': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'endTime': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'timezone': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'date': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'location': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'locationDetails': <String, Object?>{
          'type': 'string',
        },
        'summary': <String, Object?>{
          'type': 'string',
        },
        'requirements': <String, Object?>{
          'type': 'string',
        },
        'accessibility': <String, Object?>{
          'type': 'string',
        },
        'capacityLimit': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
        },
        'bookedCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
        },
        'checkedInCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
        },
        'waitlistedCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
        },
        'priceLabel': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'scorecard': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'object',
              'additionalProperties': true,
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
      },
    },
    'externalEvent': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'id',
        'title',
        'activityKind',
        'availability',
        'startTime',
        'endTime',
        'date',
        'location',
        'summary',
        'priceLabel',
        'sourceLabel',
        'sourceHref',
        'externalLinkCount',
        'dedupeKey',
      ],
      'properties': <String, Object?>{
        'id': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'title': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'activityKind': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'availability': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'read_only_external',
          ],
        },
        'startTime': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'endTime': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
        },
        'timezone': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'date': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'location': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'locationDetails': <String, Object?>{
          'type': 'string',
        },
        'summary': <String, Object?>{
          'type': 'string',
        },
        'requirements': <String, Object?>{
          'type': 'string',
        },
        'accessibility': <String, Object?>{
          'type': 'string',
        },
        'priceLabel': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'sourceLabel': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'sourceHref': <String, Object?>{
          'type': 'string',
          'format': 'uri',
        },
        'externalLinkCount': <String, Object?>{
          'type': 'integer',
          'minimum': 1,
        },
        'dedupeKey': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
      },
    },
    'eventSuccessSummary': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'bookedCount',
        'checkedInCount',
        'mutualMatchCount',
        'chatStartedCount',
        'catchSentCount',
        'safetyIncidentCount',
      ],
      'properties': <String, Object?>{
        'bookedCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
        },
        'checkedInCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
        },
        'mutualMatchCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
        },
        'chatStartedCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
        },
        'catchSentCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
        },
        'safetyIncidentCount': <String, Object?>{
          'type': 'integer',
          'minimum': 0,
        },
      },
    },
    'eventEvidence': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'title',
        'date',
        'location',
        'summary',
        'facts',
        'sourceLabel',
        'sourceHref',
      ],
      'properties': <String, Object?>{
        'title': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'date': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'location': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'summary': <String, Object?>{
          'type': 'string',
        },
        'facts': <String, Object?>{
          'type': 'array',
          'items': <String, Object?>{
            'type': 'string',
            'minLength': 1,
          },
        },
        'sourceLabel': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'sourceHref': <String, Object?>{
          'type': 'string',
          'format': 'uri',
        },
      },
    },
    'publicReview': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'id',
        'eventId',
        'reviewerName',
        'rating',
        'comment',
        'createdAt',
        'verificationStatus',
        'source',
        'isAnonymous',
        'ownerResponse',
      ],
      'properties': <String, Object?>{
        'id': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
        },
        'eventId': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
        },
        'reviewerName': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'rating': <String, Object?>{
          'type': 'number',
          'minimum': 0,
          'maximum': 5,
        },
        'comment': <String, Object?>{
          'type': 'string',
        },
        'createdAt': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'verificationStatus': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'verified',
            'unverified',
          ],
        },
        'source': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'catchEvent',
            'publicListing',
          ],
        },
        'isAnonymous': <String, Object?>{
          'type': 'boolean',
        },
        'ownerResponse': <String, Object?>{
          'anyOf': <Object?>[
            <String, Object?>{
              'type': 'object',
              'additionalProperties': false,
              'required': <Object?>[
                'hostName',
                'hostAvatarUrl',
                'message',
                'updatedAt',
              ],
              'properties': <String, Object?>{
                'hostName': <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                },
                'hostAvatarUrl': <String, Object?>{
                  'type': <Object?>[
                    'string',
                    'null',
                  ],
                  'format': 'uri',
                },
                'message': <String, Object?>{
                  'type': 'string',
                },
                'updatedAt': <String, Object?>{
                  'type': 'string',
                  'minLength': 1,
                },
              },
            },
            <String, Object?>{
              'type': 'null',
            },
          ],
        },
      },
    },
    'ownerResponse': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'hostName',
        'hostAvatarUrl',
        'message',
        'updatedAt',
      ],
      'properties': <String, Object?>{
        'hostName': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'hostAvatarUrl': <String, Object?>{
          'type': <Object?>[
            'string',
            'null',
          ],
          'format': 'uri',
        },
        'message': <String, Object?>{
          'type': 'string',
        },
        'updatedAt': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
      },
    },
    'publicApi': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'state',
        'reason',
        'claimTargetSyncStatus',
      ],
      'properties': <String, Object?>{
        'state': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'enabled',
            'disabled',
          ],
        },
        'reason': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'claimTargetSyncStatus': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'in_sync',
            'write_needed',
            'static_fixture',
            'unknown',
          ],
        },
      },
    },
    'authority': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'ownershipState',
        'claimState',
        'provenanceOrigin',
        'sourceConfidence',
        'verificationStatus',
        'appVisibility',
        'publishStatus',
        'indexStatus',
      ],
      'properties': <String, Object?>{
        'ownershipState': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'programmatic',
            'userCreated',
            'claimed',
            'transferred',
          ],
        },
        'claimState': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'unclaimed',
            'claimPending',
            'claimed',
            'verified',
            'suppressed',
          ],
        },
        'provenanceOrigin': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'userCreated',
            'scraper',
            'adminSeed',
            'import',
          ],
        },
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
        'appVisibility': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'discoverable',
            'hidden',
          ],
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
        'indexStatus': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'noindex',
            'indexReady',
            'indexed',
          ],
        },
      },
    },
    'capability': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'state',
        'reason',
      ],
      'properties': <String, Object?>{
        'state': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'enabled',
            'disabled',
          ],
        },
        'reason': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
      },
    },
    'publicReviewCapability': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'targetState',
        'readState',
        'writeState',
        'reason',
      ],
      'properties': <String, Object?>{
        'targetState': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'enabled',
            'disabled',
          ],
        },
        'readState': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'enabled',
            'disabled',
          ],
        },
        'writeState': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'enabled',
            'disabled',
          ],
        },
        'reason': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
      },
      'not': <String, Object?>{
        'anyOf': <Object?>[
          <String, Object?>{
            'properties': <String, Object?>{
              'targetState': <String, Object?>{
                'const': 'disabled',
              },
              'readState': <String, Object?>{
                'const': 'enabled',
              },
            },
            'required': <Object?>[
              'targetState',
              'readState',
            ],
          },
          <String, Object?>{
            'properties': <String, Object?>{
              'targetState': <String, Object?>{
                'const': 'disabled',
              },
              'writeState': <String, Object?>{
                'const': 'enabled',
              },
            },
            'required': <Object?>[
              'targetState',
              'writeState',
            ],
          },
          <String, Object?>{
            'properties': <String, Object?>{
              'readState': <String, Object?>{
                'const': 'disabled',
              },
              'writeState': <String, Object?>{
                'const': 'enabled',
              },
            },
            'required': <Object?>[
              'readState',
              'writeState',
            ],
          },
        ],
      },
    },
    'capabilities': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'claimRequest',
        'publicReviews',
      ],
      'properties': <String, Object?>{
        'claimRequest': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'state',
            'reason',
          ],
          'properties': <String, Object?>{
            'state': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'enabled',
                'disabled',
              ],
            },
            'reason': <String, Object?>{
              'type': 'string',
              'minLength': 1,
            },
          },
        },
        'publicReviews': <String, Object?>{
          'type': 'object',
          'additionalProperties': false,
          'required': <Object?>[
            'targetState',
            'readState',
            'writeState',
            'reason',
          ],
          'properties': <String, Object?>{
            'targetState': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'enabled',
                'disabled',
              ],
            },
            'readState': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'enabled',
                'disabled',
              ],
            },
            'writeState': <String, Object?>{
              'type': 'string',
              'enum': <Object?>[
                'enabled',
                'disabled',
              ],
            },
            'reason': <String, Object?>{
              'type': 'string',
              'minLength': 1,
            },
          },
          'not': <String, Object?>{
            'anyOf': <Object?>[
              <String, Object?>{
                'properties': <String, Object?>{
                  'targetState': <String, Object?>{
                    'const': 'disabled',
                  },
                  'readState': <String, Object?>{
                    'const': 'enabled',
                  },
                },
                'required': <Object?>[
                  'targetState',
                  'readState',
                ],
              },
              <String, Object?>{
                'properties': <String, Object?>{
                  'targetState': <String, Object?>{
                    'const': 'disabled',
                  },
                  'writeState': <String, Object?>{
                    'const': 'enabled',
                  },
                },
                'required': <Object?>[
                  'targetState',
                  'writeState',
                ],
              },
              <String, Object?>{
                'properties': <String, Object?>{
                  'readState': <String, Object?>{
                    'const': 'disabled',
                  },
                  'writeState': <String, Object?>{
                    'const': 'enabled',
                  },
                },
                'required': <Object?>[
                  'readState',
                  'writeState',
                ],
              },
            ],
          },
        },
      },
    },
    'source': <String, Object?>{
      'type': 'object',
      'additionalProperties': false,
      'required': <Object?>[
        'type',
        'label',
        'detail',
        'confidence',
      ],
      'properties': <String, Object?>{
        'type': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'label': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'detail': <String, Object?>{
          'type': 'string',
          'minLength': 1,
        },
        'href': <String, Object?>{
          'type': 'string',
          'format': 'uri',
        },
        'confidence': <String, Object?>{
          'type': 'string',
          'enum': <Object?>[
            'high',
            'medium',
            'low',
          ],
        },
      },
    },
  },
};
