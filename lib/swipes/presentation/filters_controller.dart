import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/update_user_profile_patch.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'filters_controller.g.dart';

/// **Pattern A: Action controller + static Mutations**
///
/// Saves swipe filter preferences to the user profile document.
/// [saveFiltersMutation] tracks the async lifecycle so the UI can
/// show a loading spinner during the save.
@riverpod
class FiltersController extends _$FiltersController {
  static final saveFiltersMutation = Mutation<void>();

  @override
  void build() {}

  Future<void> saveFilters({
    required String uid,
    required int minAgePreference,
    required int maxAgePreference,
    required List<String> interestedInGenders,
  }) async {
    await ref
        .read(userProfileRepositoryProvider)
        .updateUserProfile(
          uid: uid,
          patch: UpdateUserProfilePatch(
            minAgePreference: minAgePreference,
            maxAgePreference: maxAgePreference,
            interestedInGenders: interestedInGenders
                .map(Gender.values.byName)
                .toList(growable: false),
          ),
        );
  }
}
