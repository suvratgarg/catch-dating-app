import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/update_user_profile_patch.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_edit_controller.g.dart';

/// **Pattern A: Action controller + static Mutations**
///
/// Serializes profile-field saves so rapid bottom-sheet edits cannot race.
@riverpod
class ProfileEditController extends _$ProfileEditController {
  static final saveFieldsMutation = Mutation<void>();

  Future<void> _pendingSave = Future.value();

  @override
  void build() {}

  Future<void> saveFields(Map<String, dynamic> fields) {
    final uid = requireSignedInUid(ref, action: 'save profile edits');
    final nextSave = _pendingSave
        .catchError((Object error, StackTrace stack) {
          ref
              .read(errorLoggerProvider)
              .logAppException(
                normalizeBackendError(
                  error,
                  stackTrace: stack,
                  context: const BackendErrorContext(
                    service: BackendService.local,
                    action: 'save queued profile edits',
                    resource: 'profile_edit_controller',
                  ),
                ),
              );
        })
        .then((_) {
          // Inline-edit bottom sheets compute their patch fields dynamically
          // (different sheets touch different schema fields); wrap them in
          // `UpdateUserProfilePatch.raw` so the repository boundary still
          // takes a typed patch. The schema-conformance test in
          // `update_user_profile_patch_test.dart` plus the Functions Ajv
          // validator catch any rogue field names.
          return ref
              .read(userProfileRepositoryProvider)
              .updateUserProfile(
                uid: uid,
                patch: UpdateUserProfilePatch.raw(fields),
              );
        });
    _pendingSave = nextSave.catchError((Object error, StackTrace stack) {
      ref
          .read(errorLoggerProvider)
          .logAppException(
            normalizeBackendError(
              error,
              stackTrace: stack,
              context: const BackendErrorContext(
                service: BackendService.local,
                action: 'save profile edits',
                resource: 'profile_edit_controller',
              ),
            ),
          );
    });
    return nextSave;
  }
}
