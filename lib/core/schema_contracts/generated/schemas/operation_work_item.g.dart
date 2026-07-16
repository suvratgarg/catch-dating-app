// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from operations/work_item.schema.json.

const schemaOperationWorkItemSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/operations/work_item.schema.json',
  'title': 'OperationWorkItem',
  'description': 'One exclusively staged unit of work. Task flags are orthogonal and may overlap.',
  'type': 'object',
  'additionalProperties': false,
  'allOf': <Object?>[
    <String, Object?>{
      'if': <String, Object?>{
        'properties': <String, Object?>{
          'lifecycleStatus': <String, Object?>{
            'const': 'terminal',
          },
        },
      },
      'then': <String, Object?>{
        'properties': <String, Object?>{
          'outcome': <String, Object?>{
            'type': 'string',
            'not': <String, Object?>{
              'const': 'published',
            },
          },
        },
      },
    },
    <String, Object?>{
      'if': <String, Object?>{
        'properties': <String, Object?>{
          'lifecycleStatus': <String, Object?>{
            'const': 'published',
          },
        },
      },
      'then': <String, Object?>{
        'properties': <String, Object?>{
          'outcome': <String, Object?>{
            'const': 'published',
          },
        },
      },
    },
    <String, Object?>{
      'if': <String, Object?>{
        'properties': <String, Object?>{
          'lifecycleStatus': <String, Object?>{
            'enum': <Object?>[
              'queued',
              'in_progress',
              'waiting',
              'ready',
            ],
          },
        },
      },
      'then': <String, Object?>{
        'properties': <String, Object?>{
          'outcome': <String, Object?>{
            'type': 'null',
          },
        },
      },
    },
    <String, Object?>{
      'if': <String, Object?>{
        'anyOf': <Object?>[
          <String, Object?>{
            'required': <Object?>[
              'blockerCodes',
            ],
            'properties': <String, Object?>{
              'blockerCodes': <String, Object?>{
                'contains': <String, Object?>{
                  'const': 'human_review_required',
                },
              },
            },
          },
          <String, Object?>{
            'required': <Object?>[
              'normalizedPayload',
            ],
            'properties': <String, Object?>{
              'normalizedPayload': <String, Object?>{
                'type': 'object',
                'required': <Object?>[
                  'owner',
                ],
                'properties': <String, Object?>{
                  'owner': <String, Object?>{
                    'const': 'human',
                  },
                },
              },
            },
          },
        ],
      },
      'then': <String, Object?>{
        'properties': <String, Object?>{
          'taskFlags': <String, Object?>{
            'contains': <String, Object?>{
              'const': 'human_review_required',
            },
          },
        },
      },
    },
    <String, Object?>{
      'if': <String, Object?>{
        'required': <Object?>[
          'lifecycleStatus',
        ],
        'properties': <String, Object?>{
          'lifecycleStatus': <String, Object?>{
            'enum': <Object?>[
              'published',
              'terminal',
            ],
          },
        },
      },
      'then': <String, Object?>{
        'properties': <String, Object?>{
          'taskFlags': <String, Object?>{
            'not': <String, Object?>{
              'contains': <String, Object?>{
                'const': 'human_review_required',
              },
            },
          },
          'blockerCodes': <String, Object?>{
            'not': <String, Object?>{
              'contains': <String, Object?>{
                'const': 'human_review_required',
              },
            },
          },
          'normalizedPayload': <String, Object?>{
            'not': <String, Object?>{
              'required': <Object?>[
                'owner',
              ],
              'properties': <String, Object?>{
                'owner': <String, Object?>{
                  'const': 'human',
                },
              },
            },
          },
        },
      },
    },
  ],
  'required': <Object?>[
    'schemaVersion',
    'workItemId',
    'workflowId',
    'runId',
    'entityKind',
    'externalKey',
    'revision',
    'candidateHash',
    'primaryStage',
    'lifecycleStatus',
    'outcome',
    'taskFlags',
    'blockerCodes',
    'warningCodes',
    'priority',
    'attemptCount',
    'evidenceRefs',
    'fieldProvenance',
    'normalizedPayload',
    'decisionId',
    'publicationPlanId',
    'createdAt',
    'updatedAt',
    'staleAt',
    'expiresAt',
  ],
  'properties': <String, Object?>{
    'schemaVersion': <String, Object?>{
      'type': 'integer',
      'const': 1,
    },
    'workItemId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
    },
    'workflowId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
      'pattern': '^[a-z][a-z0-9_-]*\$',
    },
    'runId': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 180,
      'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
    },
    'entityKind': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'pattern': '^[a-z][a-z0-9_]*\$',
    },
    'externalKey': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 500,
    },
    'revision': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
    'candidateHash': <String, Object?>{
      'type': 'string',
      'pattern': '^[a-f0-9]{64}\$',
    },
    'primaryStage': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
      'pattern': '^[a-z][a-z0-9_]*\$',
    },
    'lifecycleStatus': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'queued',
        'in_progress',
        'waiting',
        'ready',
        'published',
        'terminal',
      ],
    },
    'outcome': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'maxLength': 120,
      'pattern': '^[a-z][a-z0-9_]*\$',
    },
    'taskFlags': <String, Object?>{
      'type': 'array',
      'maxItems': 40,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
        'maxLength': 120,
        'pattern': '^[a-z][a-z0-9_.:-]*\$',
      },
    },
    'blockerCodes': <String, Object?>{
      'type': 'array',
      'maxItems': 40,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
        'maxLength': 120,
        'pattern': '^[a-z][a-z0-9_.:-]*\$',
      },
    },
    'warningCodes': <String, Object?>{
      'type': 'array',
      'maxItems': 40,
      'uniqueItems': true,
      'items': <String, Object?>{
        'type': 'string',
        'minLength': 1,
        'maxLength': 120,
        'pattern': '^[a-z][a-z0-9_.:-]*\$',
      },
    },
    'priority': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
      'maximum': 1000000,
    },
    'attemptCount': <String, Object?>{
      'type': 'integer',
      'minimum': 0,
    },
    'evidenceRefs': <String, Object?>{
      'type': 'array',
      'maxItems': 100,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'artifactId',
          'contentHash',
          'observedAt',
          'locator',
        ],
        'properties': <String, Object?>{
          'artifactId': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 180,
            'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
          },
          'contentHash': <String, Object?>{
            'type': 'string',
            'pattern': '^[a-f0-9]{64}\$',
          },
          'observedAt': <String, Object?>{
            'type': 'string',
            'format': 'date-time',
          },
          'locator': <String, Object?>{
            'type': <Object?>[
              'string',
              'null',
            ],
            'maxLength': 1000,
          },
        },
      },
    },
    'fieldProvenance': <String, Object?>{
      'type': 'array',
      'maxItems': 200,
      'items': <String, Object?>{
        'type': 'object',
        'additionalProperties': false,
        'required': <Object?>[
          'field',
          'artifactId',
          'contentHash',
          'locator',
          'extractedBy',
          'extractorVersion',
          'confidence',
        ],
        'properties': <String, Object?>{
          'field': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 160,
          },
          'artifactId': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 180,
            'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
          },
          'contentHash': <String, Object?>{
            'type': 'string',
            'pattern': '^[a-f0-9]{64}\$',
          },
          'locator': <String, Object?>{
            'type': <Object?>[
              'string',
              'null',
            ],
            'maxLength': 1000,
          },
          'extractedBy': <String, Object?>{
            'type': 'string',
            'enum': <Object?>[
              'deterministic',
              'model',
              'human',
            ],
          },
          'extractorVersion': <String, Object?>{
            'type': 'string',
            'minLength': 1,
            'maxLength': 160,
          },
          'confidence': <String, Object?>{
            'type': <Object?>[
              'number',
              'null',
            ],
            'minimum': 0,
            'maximum': 1,
          },
        },
      },
    },
    'normalizedPayload': <String, Object?>{
      'type': 'object',
      'additionalProperties': true,
    },
    'decisionId': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
          'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'publicationPlanId': <String, Object?>{
      'anyOf': <Object?>[
        <String, Object?>{
          'type': 'string',
          'minLength': 1,
          'maxLength': 180,
          'pattern': '^[A-Za-z0-9][A-Za-z0-9._:-]*\$',
        },
        <String, Object?>{
          'type': 'null',
        },
      ],
    },
    'createdAt': <String, Object?>{
      'type': 'string',
      'format': 'date-time',
    },
    'updatedAt': <String, Object?>{
      'type': 'string',
      'format': 'date-time',
    },
    'staleAt': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'format': 'date-time',
    },
    'expiresAt': <String, Object?>{
      'type': <Object?>[
        'string',
        'null',
      ],
      'format': 'date-time',
    },
  },
};
