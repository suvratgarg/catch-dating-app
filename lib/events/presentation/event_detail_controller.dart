import 'package:catch_dating_app/events/data/saved_event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_detail_controller.g.dart';

/// **Pattern A: Action controller + static Mutations**
///
/// Owns event-detail side effects that are not booking operations.
@riverpod
class EventDetailController extends _$EventDetailController {
  static final toggleSavedEventMutation = Mutation<bool>();

  @override
  void build() {}

  Future<bool> toggleSavedEvent({
    required Event event,
    required UserProfile userProfile,
    required bool isSaved,
  }) async {
    final repository = ref.read(savedEventRepositoryProvider);
    if (isSaved) {
      await repository.unsaveEvent(uid: userProfile.uid, eventId: event.id);
      return false;
    }

    await repository.saveEvent(uid: userProfile.uid, eventId: event.id);
    return true;
  }
}
