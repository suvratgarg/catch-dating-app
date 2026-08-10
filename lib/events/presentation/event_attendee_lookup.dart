import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final eventAttendeeLookupProvider = Provider<EventAttendeeLookup>(
  (ref) => EventAttendeeLookup(ref.watch(publicProfileRepositoryProvider)),
);

/// Batches public attendee-profile reads outside the widget rendering layer.
class EventAttendeeLookup {
  const EventAttendeeLookup(this._publicProfiles);

  final PublicProfileRepository _publicProfiles;

  Future<List<PublicProfile>> fetchProfiles(List<String> uids) =>
      _publicProfiles.fetchPublicProfiles(uids);
}
