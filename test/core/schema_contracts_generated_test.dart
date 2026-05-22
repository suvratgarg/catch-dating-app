import 'dart:convert';
import 'dart:io';

import 'package:catch_dating_app/core/schema_contracts/generated/profile_schema_contracts.g.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/schema_contracts.g.dart'
    as schema_contracts;
import 'package:flutter_test/flutter_test.dart';
import 'package:json_schema/json_schema.dart';

void main() {
  test('generated profile prompt constants match contract limits', () {
    expect(schemaProfilePromptPerfectEventId, 'perfectRun');
    expect(schemaMaxProfilePromptAnswers, 3);
    expect(schemaMaxPhotoPromptCaptions, 6);
    expect(schemaMinimumProfilePhotos, 2);
    expect(schemaMaximumProfilePhotos, 6);
    expect(schemaProfilePhotoAspectRatioWidth, 3);
    expect(schemaProfilePhotoAspectRatioHeight, 4);
    expect(schemaProfilePhotoThumbnailSize, 160);
    expect(schemaProfilePhotoMaxUploadBytes, 8388608);
    expect(schemaMaximumProfilePromptAnswerLength, 300);
    expect(schemaMaximumPhotoPromptCaptionLength, 140);
    expect(schemaMinimumHeightCm, 120);
    expect(schemaMaximumHeightCm, 220);
    expect(schemaDefaultProfilePromptIds, [
      'perfectRun',
      'afterEvent',
      'greenFlag',
    ]);
  });

  test('generated Dart schemas validate prompt payloads', () {
    final profilePromptSchema = JsonSchema.create(
      schemaProfilePromptAnswerSchema,
    );
    final photoPromptSchema = JsonSchema.create(schemaPhotoPromptAnswerSchema);
    final profilePhotoSchema = JsonSchema.create(schemaProfilePhotoSchema);

    expect(
      profilePromptSchema.validate({
        'promptId': 'perfectRun',
        'prompt': 'A perfect event with me looks like...',
        'answer': 'Coffee after an easy 5K.',
      }).isValid,
      isTrue,
    );
    expect(
      profilePromptSchema.validate({
        'promptId': 'perfectRun',
        'prompt': 'A perfect event with me looks like...',
        'answer': 'x' * (schemaMaximumProfilePromptAnswerLength + 1),
      }).isValid,
      isFalse,
    );
    expect(
      photoPromptSchema.validate({
        'photoIndex': 0,
        'promptId': 'proofIRun',
        'prompt': 'Proof I actually event',
        'caption': 'Finish line.',
      }).isValid,
      isTrue,
    );
    expect(
      profilePhotoSchema
          .validate(_readFixture('valid/profile_photo.json'))
          .isValid,
      isTrue,
    );
    expect(
      profilePhotoSchema
          .validate(
            _readFixture('invalid/profile_photo_invalid_storage_path.json'),
          )
          .isValid,
      isFalse,
    );
  });

  test('generated Dart schemas validate shared contract fixtures', () {
    final profilePromptSchema = JsonSchema.create(
      schemaProfilePromptAnswerSchema,
    );
    final updateProfileSchema = JsonSchema.create(
      schemaUpdateUserProfileCallablePayloadSchema,
    );

    expect(
      profilePromptSchema
          .validate(_readFixture('valid/profile_prompt_answer.json'))
          .isValid,
      isTrue,
    );
    expect(
      profilePromptSchema
          .validate(_readFixture('invalid/profile_prompt_answer_overlong.json'))
          .isValid,
      isFalse,
    );
    expect(
      updateProfileSchema
          .validate(_readFixture('valid/update_user_profile_patch.json'))
          .isValid,
      isTrue,
    );
    expect(
      updateProfileSchema
          .validate(
            _readFixture(
              'invalid/update_user_profile_height_out_of_range.json',
            ),
          )
          .isValid,
      isFalse,
    );
    expect(
      updateProfileSchema
          .validate(
            _readFixture('invalid/update_user_profile_invalid_email.json'),
          )
          .isValid,
      isFalse,
    );
    expect(
      updateProfileSchema
          .validate(
            _readFixture('invalid/update_user_profile_empty_patch.json'),
          )
          .isValid,
      isFalse,
    );
  });

  test('generated Dart registry covers the schema contract surface', () {
    expect(schema_contracts.schemaContractDefinitions.length, greaterThan(50));
    expect(
      schema_contracts.schemaContractsByName.keys,
      containsAll(<String>[
        'UserProfileDocument',
        'PublicProfileDocument',
        'EventDocument',
        'EventSuccessPlanDocument',
        'EventSuccessFeedbackDocument',
        'EventSuccessPreferenceDocument',
        'EventSuccessCompatibilityResponseDocument',
        'EventSuccessWingmanRequestDocument',
        'EventSuccessAssignmentDocument',
        'EventSuccessScorecardDocument',
        'EventSafetyReportDocument',
        'SavedEventDocument',
        'SwipeDocument',
        'CreateEventCallablePayload',
        'SubmitEventSuccessWingmanRequestCallablePayload',
        'CreateProfileDecisionClientWrite',
        'CreateSavedEventClientWrite',
      ]),
    );
    expect(
      schema_contracts.schemaContractsBySource.keys,
      containsAll(<String>[
        'firestore/users.schema.json',
        'firestore/events.schema.json',
        'firestore/event_success_plans.schema.json',
        'firestore/event_success_feedback.schema.json',
        'firestore/event_success_preferences.schema.json',
        'firestore/event_success_compatibility_responses.schema.json',
        'firestore/event_success_wingman_requests.schema.json',
        'firestore/event_success_assignments.schema.json',
        'firestore/event_success_scorecards.schema.json',
        'firestore/event_safety_reports.schema.json',
        'callables/submit_event_success_wingman_request_payload.schema.json',
        'firestore/swipes.schema.json',
        'client_writes/create_profile_decision.schema.json',
        'client_writes/create_saved_event.schema.json',
      ]),
    );
  });

  test('generated Dart registry validates representative shared fixtures', () {
    final cases = <_SchemaFixtureCase>[
      _SchemaFixtureCase.valid(
        'UserProfileDocument',
        'valid/user_profile_doc.json',
      ),
      _SchemaFixtureCase.invalid(
        'UserProfileDocument',
        'invalid/user_profile_legacy_bio.json',
      ),
      _SchemaFixtureCase.valid(
        'PublicProfileDocument',
        'valid/public_profile_doc.json',
      ),
      _SchemaFixtureCase.valid('EventDocument', 'valid/event_doc.json'),
      _SchemaFixtureCase.invalid(
        'EventDocument',
        'invalid/event_doc_invalid_pace.json',
      ),
      _SchemaFixtureCase.valid(
        'EventSuccessPlanDocument',
        'valid/event_success_plan_doc.json',
      ),
      _SchemaFixtureCase.valid(
        'EventSuccessFeedbackDocument',
        'valid/event_success_feedback_doc.json',
      ),
      _SchemaFixtureCase.valid(
        'EventSuccessPreferenceDocument',
        'valid/event_success_preference_doc.json',
      ),
      _SchemaFixtureCase.valid(
        'EventSuccessCompatibilityResponseDocument',
        'valid/event_success_compatibility_response_doc.json',
      ),
      _SchemaFixtureCase.valid(
        'EventSuccessWingmanRequestDocument',
        'valid/event_success_wingman_request_doc.json',
      ),
      _SchemaFixtureCase.valid(
        'EventSuccessAssignmentDocument',
        'valid/event_success_assignment_doc.json',
      ),
      _SchemaFixtureCase.valid(
        'EventSuccessScorecardDocument',
        'valid/event_success_scorecard_doc.json',
      ),
      _SchemaFixtureCase.valid(
        'EventSafetyReportDocument',
        'valid/event_safety_report_doc.json',
      ),
      _SchemaFixtureCase.valid(
        'SavedEventDocument',
        'valid/saved_event_doc.json',
      ),
      _SchemaFixtureCase.valid('SwipeDocument', 'valid/swipe_doc.json'),
      _SchemaFixtureCase.valid(
        'SubmitEventSuccessWingmanRequestCallablePayload',
        'valid/submit_event_success_wingman_request_payload.json',
      ),
      _SchemaFixtureCase.invalid(
        'SwipeDocument',
        'invalid/swipe_doc_invalid_reaction_target.json',
      ),
      _SchemaFixtureCase.valid(
        'CreateProfileDecisionClientWrite',
        'valid/create_profile_decision_client_write.json',
      ),
      _SchemaFixtureCase.valid(
        'CreateSavedEventClientWrite',
        'valid/create_saved_event_client_write.json',
      ),
      _SchemaFixtureCase.invalid(
        'CreateEventReviewCallablePayload',
        'invalid/create_event_review_invalid_rating.json',
      ),
      _SchemaFixtureCase.invalid(
        'UpdateEventCallablePayload',
        'invalid/update_event_empty_fields.json',
      ),
      _SchemaFixtureCase.invalid(
        'UpdateClubCallablePayload',
        'invalid/update_club_empty_fields.json',
      ),
    ];

    for (final fixtureCase in cases) {
      final schema =
          schema_contracts.schemaContractsByName[fixtureCase.schemaName];
      expect(
        schema,
        isNotNull,
        reason: 'Missing generated schema ${fixtureCase.schemaName}',
      );
      final result = JsonSchema.create(
        schema!,
      ).validate(_readFixture(fixtureCase.fixturePath));
      expect(
        result.isValid,
        fixtureCase.isValid,
        reason:
            '${fixtureCase.schemaName} should validate '
            '${fixtureCase.fixturePath}: ${result.errors}',
      );
    }
  });
}

Object? _readFixture(String path) {
  return jsonDecode(File('contracts/fixtures/$path').readAsStringSync());
}

class _SchemaFixtureCase {
  const _SchemaFixtureCase._({
    required this.schemaName,
    required this.fixturePath,
    required this.isValid,
  });

  factory _SchemaFixtureCase.valid(String schemaName, String fixturePath) {
    return _SchemaFixtureCase._(
      schemaName: schemaName,
      fixturePath: fixturePath,
      isValid: true,
    );
  }

  factory _SchemaFixtureCase.invalid(String schemaName, String fixturePath) {
    return _SchemaFixtureCase._(
      schemaName: schemaName,
      fixturePath: fixturePath,
      isValid: false,
    );
  }

  final String schemaName;
  final String fixturePath;
  final bool isValid;
}
