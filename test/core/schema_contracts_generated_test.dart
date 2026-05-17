import 'dart:convert';
import 'dart:io';

import 'package:catch_dating_app/core/schema_contracts/generated/profile_schema_contracts.g.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/schema_contracts.g.dart'
    as schema_contracts;
import 'package:flutter_test/flutter_test.dart';
import 'package:json_schema/json_schema.dart';

void main() {
  test('generated profile prompt constants match contract limits', () {
    expect(schemaProfilePromptPerfectRunId, 'perfectRun');
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
      'afterRun',
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
        'prompt': 'A perfect run with me looks like...',
        'answer': 'Coffee after an easy 5K.',
      }).isValid,
      isTrue,
    );
    expect(
      profilePromptSchema.validate({
        'promptId': 'perfectRun',
        'prompt': 'A perfect run with me looks like...',
        'answer': 'x' * (schemaMaximumProfilePromptAnswerLength + 1),
      }).isValid,
      isFalse,
    );
    expect(
      photoPromptSchema.validate({
        'photoIndex': 0,
        'promptId': 'proofIRun',
        'prompt': 'Proof I actually run',
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
        'RunDocument',
        'SavedRunDocument',
        'SwipeDocument',
        'CreateRunCallablePayload',
        'CreateProfileDecisionClientWrite',
        'CreateSavedRunClientWrite',
      ]),
    );
    expect(
      schema_contracts.schemaContractsBySource.keys,
      containsAll(<String>[
        'firestore/users.schema.json',
        'firestore/runs.schema.json',
        'firestore/swipes.schema.json',
        'client_writes/create_profile_decision.schema.json',
        'client_writes/create_saved_run.schema.json',
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
      _SchemaFixtureCase.valid('RunDocument', 'valid/run_doc.json'),
      _SchemaFixtureCase.invalid(
        'RunDocument',
        'invalid/run_doc_invalid_pace.json',
      ),
      _SchemaFixtureCase.valid('SavedRunDocument', 'valid/saved_run_doc.json'),
      _SchemaFixtureCase.valid('SwipeDocument', 'valid/swipe_doc.json'),
      _SchemaFixtureCase.invalid(
        'SwipeDocument',
        'invalid/swipe_doc_invalid_reaction_target.json',
      ),
      _SchemaFixtureCase.valid(
        'CreateProfileDecisionClientWrite',
        'valid/create_profile_decision_client_write.json',
      ),
      _SchemaFixtureCase.valid(
        'CreateSavedRunClientWrite',
        'valid/create_saved_run_client_write.json',
      ),
      _SchemaFixtureCase.invalid(
        'CreateRunReviewCallablePayload',
        'invalid/create_run_review_invalid_rating.json',
      ),
      _SchemaFixtureCase.invalid(
        'UpdateRunCallablePayload',
        'invalid/update_run_empty_fields.json',
      ),
      _SchemaFixtureCase.invalid(
        'UpdateRunClubCallablePayload',
        'invalid/update_run_club_empty_fields.json',
      ),
    ];

    for (final fixtureCase in cases) {
      final schema = schema_contracts
          .schemaContractsByName[fixtureCase.schemaName];
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
        reason: '${fixtureCase.schemaName} should validate '
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
