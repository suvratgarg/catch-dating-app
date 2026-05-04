import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'filters_controller.g.dart';

/// **Pattern B: Stateless controller + static Mutations**
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
    required int paceMinSecsPerKm,
    required int paceMaxSecsPerKm,
    required List<String> interestedInGenders,
    required List<String> preferredDistances,
  }) async {
    await ref.read(userProfileRepositoryProvider).updateUserProfile(
      uid: uid,
      fields: {
        'minAgePreference': minAgePreference,
        'maxAgePreference': maxAgePreference,
        'paceMinSecsPerKm': paceMinSecsPerKm,
        'paceMaxSecsPerKm': paceMaxSecsPerKm,
        'interestedInGenders': interestedInGenders,
        'preferredDistances': preferredDistances,
      },
    );
  }
}
