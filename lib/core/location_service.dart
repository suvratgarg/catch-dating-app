import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_service.g.dart';

@Riverpod(keepAlive: true)
class LocationInitializer extends _$LocationInitializer {
  bool _collected = false;

  @override
  Future<void> build() async {
    // watch (not read) so we rebuild when the stream emits a profile
    final userProfile = ref.watch(userProfileStreamProvider).asData?.value;
    if (userProfile == null || _collected) return;

    // Only collect if the user doesn't already have coordinates.
    if (userProfile.latitude != null && userProfile.longitude != null) {
      _collected = true;
      return;
    }

    _collected = true; // guard against re-entry before the first await

    final location = await ref.read(deviceLocationProvider.future);
    if (location == null) return;

    final nearest = IndianCity.nearestCity(location);
    final fields = <String, dynamic>{
      'latitude': location.latitude,
      'longitude': location.longitude,
    };
    if (nearest != null && userProfile.city == null) {
      fields['city'] = nearest.name;
    }

    await ref.read(userProfileRepositoryProvider).updateUserProfile(
      uid: userProfile.uid,
      fields: fields,
    );
  }
}
