import 'dart:async';

import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show UpdateUserProfilePatch;
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

/// A [UserProfileRepository] fake that tracks every update and can simulate
/// delayed saves, errors, and in-memory profile state for tests that chain
/// multiple saves.
class FakeProfileRepository extends Fake implements UserProfileRepository {
  FakeProfileRepository({this.latestProfile});

  Completer<void>? updateCompleter;
  Object? updateError;
  UserProfile? latestProfile;
  final updatedUids = <String>[];
  final updatedPatches = <UpdateUserProfilePatch>[];
  int fetchCount = 0;

  @override
  Future<UserProfile?> fetchUserProfile({required String? uid}) async {
    fetchCount += 1;
    return latestProfile;
  }

  @override
  Future<void> updateUserProfile({
    required String uid,
    required UpdateUserProfilePatch patch,
    String action = 'update profile',
  }) async {
    updatedUids.add(uid);
    updatedPatches.add(patch);
    _applyPatch(patch);
    final error = updateError;
    if (error != null) throw error;
    final completer = updateCompleter;
    if (completer != null) await completer.future;
  }

  void _applyPatch(UpdateUserProfilePatch patch) {
    final profile = latestProfile;
    if (profile == null) return;
    final fields = patch.toFieldsJson();
    var updatedProfile = profile;
    final activityPreferences = fields['activityPreferences'];
    if (activityPreferences is Map) {
      updatedProfile = updatedProfile.copyWith(
        activityPreferences: ActivityPreferences.fromJson(
          Map<String, dynamic>.from(activityPreferences),
        ),
      );
    }
    final profilePrompts = fields['profilePrompts'];
    if (profilePrompts is List) {
      updatedProfile = updatedProfile.copyWith(
        profilePrompts: [
          for (final prompt in profilePrompts)
            ProfilePromptAnswer.fromJson(Map<String, dynamic>.from(prompt)),
        ],
      );
    }
    latestProfile = updatedProfile;
  }
}

/// A [UserProfileRepository] fake for widget tests that use
/// [FakeProfileEditUserProfileRepository]-style field tracking.
class FakeProfileEditRepository extends Fake implements UserProfileRepository {
  Completer<void>? updateCompleter;
  Object? updateError;
  UserProfile? latestProfile;
  String? updatedUid;
  Map<String, dynamic>? updatedFields;

  @override
  Future<UserProfile?> fetchUserProfile({required String? uid}) async {
    return latestProfile;
  }

  @override
  Future<void> updateUserProfile({
    required String uid,
    required UpdateUserProfilePatch patch,
    String action = 'update_profile',
  }) async {
    updatedUid = uid;
    updatedFields = Map<String, dynamic>.from(patch.toFieldsJson());
    final error = updateError;
    if (error != null) throw error;
    final completer = updateCompleter;
    if (completer != null) await completer.future;
  }
}

/// An [ErrorLogger] that swallows all log calls, suitable for tests that
/// exercise error paths without polluting the test runner output.
class SilentErrorLogger extends ErrorLogger {
  SilentErrorLogger() : super(crashReporter: null, shouldReportErrors: false);

  @override
  void log({
    required LogLevel level,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, String>? context,
  }) {}
}

/// Polls [repository] until [count] patches have been recorded, or fails
/// after 20 microtask iterations.
Future<void> waitForRepositoryUpdates(
  FakeProfileRepository repository,
  int count,
) async {
  for (var attempt = 0; attempt < 20; attempt += 1) {
    await Future<void>.delayed(Duration.zero);
    if (repository.updatedPatches.length >= count) return;
  }
  fail('Timed out waiting for $count profile update(s).');
}
