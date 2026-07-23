// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs
// ignore_for_file: constant_identifier_names, use_null_aware_elements

// JSON Schema constant emitted from forms/mobile_form_state.schema.json.

const schemaMobileFormStateSchema = <String, Object?>{
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  '\$id': 'https://catch.app/contracts/forms/mobile_form_state.schema.json',
  'title': 'MobileFormState',
  'description': 'Schema-owned values used by installable-app forms when the editable presentation value is derived into one or more backend payload fields rather than written verbatim.',
  'type': 'object',
  'additionalProperties': false,
  'properties': <String, Object?>{
    'eventDurationMinutes': <String, Object?>{
      'type': 'integer',
      'minimum': 30,
      'maximum': 240,
      'multipleOf': 15,
      'description': 'Create/edit event duration. Save adapters derive endTimeMillis from this value and startTimeMillis.',
    },
    'eventCohortCapsEnabled': <String, Object?>{
      'type': 'boolean',
      'description': 'Whether the event form reveals and emits cohort capacity limits.',
    },
    'eventDynamicPricingEnabled': <String, Object?>{
      'type': 'boolean',
      'description': 'Whether the event form reveals and emits demand-pricing rules.',
    },
    'eventSuccessLiveCardIncluded': <String, Object?>{
      'type': 'boolean',
      'description': 'Whether a host includes an optional live event-success card.',
    },
    'eventSuccessManualQaScenario': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'socialRun',
        'racketPairs',
        'quizTeams',
        'singlesMixer',
      ],
    },
    'exploreActivityTag': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 80,
    },
    'exploreArea': <String, Object?>{
      'type': 'string',
      'minLength': 1,
      'maxLength': 120,
    },
    'exploreDistanceFilter': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'any',
        'oneKm',
        'threeKm',
        'fiveKm',
        'tenKm',
      ],
    },
    'exploreHighRatedOnly': <String, Object?>{
      'type': 'boolean',
    },
    'exploreJoinedOnly': <String, Object?>{
      'type': 'boolean',
    },
    'hostBroadcastTemplate': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'reminder',
        'meetingPoint',
        'change',
      ],
    },
    'hostEventsLifecycleFilter': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'upcoming',
        'live',
        'past',
      ],
    },
    'hostInboxAudienceSegment': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'booked',
        'prospective',
      ],
    },
    'hostRosterFilter': <String, Object?>{
      'type': 'string',
      'enum': <Object?>[
        'all',
        'booked',
        'waitlist',
        'slots',
        'requests',
        'due',
        'checkedIn',
        'attended',
        'noShow',
      ],
    },
    'onboardingDateOfBirthText': <String, Object?>{
      'type': 'string',
      'minLength': 11,
      'maxLength': 11,
      'pattern': '^\\d{2} [A-Z][a-z]{2} \\d{4}\$',
      'description': 'Read-only date text rendered by the onboarding date picker before it is saved as a timestamp.',
    },
    'suvbotTesterPhoneNumber': <String, Object?>{
      'type': 'string',
      'minLength': 6,
      'maxLength': 32,
      'description': 'Phone identifier used by the local Suvbot tester action.',
    },
  },
};
