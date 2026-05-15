import 'dart:convert';
import 'dart:io';

import 'package:catch_dating_app/core/schema_contracts/generated/profile_schema_contracts.g.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_schema/json_schema.dart';

void main() {
  test('generated profile prompt constants match contract limits', () {
    expect(schemaProfilePromptPerfectRunId, 'perfectRun');
    expect(schemaMaxProfilePromptAnswers, 3);
    expect(schemaMaxPhotoPromptCaptions, 6);
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
}

Object? _readFixture(String path) {
  return jsonDecode(File('contracts/fixtures/$path').readAsStringSync());
}
