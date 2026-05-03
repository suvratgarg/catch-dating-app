import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'filters_controller.g.dart';

@riverpod
class FiltersController extends _$FiltersController {
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
