import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/data/saved_event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/domain/saved_event.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_detail_view_model.freezed.dart';
part 'event_detail_view_model.g.dart';

@freezed
abstract class EventDetailViewModel with _$EventDetailViewModel {
  const factory EventDetailViewModel({
    required Event event,
    required UserProfile? userProfile,
    required List<Review> reviews,
    required bool isAuthenticated,
    required bool isHost,
    required bool isSaved,
    required EventParticipation? participation,
  }) = _EventDetailViewModel;
}

/// **Pattern D: View-model provider**
///
/// Watches several stream/future providers and combines them into one
/// [AsyncValue] via [buildEventDetailViewModel]. Each input is individually
/// checked for loading/error so the combined result is [AsyncError] if any
/// input fails or [AsyncLoading] if any input is still loading.
///
/// **When to use this pattern:** Screens that need data from multiple
/// independent sources and want a single `.when(loading:error:data:)` call
/// instead of managing multiple async states.
@riverpod
AsyncValue<EventDetailViewModel?> eventDetailViewModel(
  Ref ref,
  String eventId,
) {
  final uidAsync = ref.watch(uidProvider);
  final uid = uidAsync.asData?.value;
  final isAuthenticated = uid != null;
  final eventAsync = ref.watch(watchEventProvider(eventId));
  final event = eventAsync.asData?.value;
  final clubAsync = event == null
      ? const AsyncData<Club?>(null)
      : ref.watch(fetchClubProvider(event.clubId));
  final savedEventAsync = uid == null
      ? const AsyncData<SavedEvent?>(null)
      : ref.watch(watchSavedEventProvider(uid, eventId));
  final participationAsync = uid == null
      ? const AsyncData<EventParticipation?>(null)
      : ref.watch(watchEventParticipationProvider(eventId, uid));

  return buildEventDetailViewModel(
    eventAsync: eventAsync,
    userProfileAsync: ref.watch(watchUserProfileProvider),
    reviewsAsync: ref.watch(watchReviewsForEventProvider(eventId)),
    clubAsync: clubAsync,
    savedEventAsync: savedEventAsync,
    participationAsync: participationAsync,
    currentUid: uid,
    isAuthenticated: isAuthenticated,
  );
}

AsyncValue<EventDetailViewModel?> buildEventDetailViewModel({
  required AsyncValue<Event?> eventAsync,
  required AsyncValue<UserProfile?> userProfileAsync,
  required AsyncValue<List<Review>> reviewsAsync,
  required AsyncValue<Club?> clubAsync,
  required AsyncValue<SavedEvent?> savedEventAsync,
  required AsyncValue<EventParticipation?> participationAsync,
  required String? currentUid,
  required bool isAuthenticated,
}) {
  // Always block on event data (needed for all users).
  if (eventAsync.isLoading) return const AsyncLoading();
  // For authenticated users, also block on reviews + user profile.
  if (isAuthenticated) {
    if (userProfileAsync.isLoading ||
        reviewsAsync.isLoading ||
        savedEventAsync.isLoading ||
        participationAsync.isLoading) {
      return const AsyncLoading();
    }
  }

  // Event error is always fatal.
  if (eventAsync.hasError) {
    return AsyncError(
      eventAsync.error!,
      eventAsync.stackTrace ?? StackTrace.current,
    );
  }

  // Reviews and userProfile errors only fatal for authenticated users.
  if (isAuthenticated) {
    if (userProfileAsync.hasError) {
      return AsyncError(
        userProfileAsync.error!,
        userProfileAsync.stackTrace ?? StackTrace.current,
      );
    }
    if (reviewsAsync.hasError) {
      return AsyncError(
        reviewsAsync.error!,
        reviewsAsync.stackTrace ?? StackTrace.current,
      );
    }
  }

  final event = eventAsync.asData?.value;
  if (event == null) return const AsyncData(null);

  final userProfile = isAuthenticated ? (userProfileAsync.asData?.value) : null;
  final reviews = isAuthenticated
      ? (reviewsAsync.asData?.value ?? const [])
      : const <Review>[];
  final club = clubAsync.asData?.value;
  final participation = isAuthenticated
      ? participationAsync.asData?.value
      : null;
  final isHost =
      isAuthenticated && currentUid != null && club?.hostUserId == currentUid;
  final isSaved = isAuthenticated && savedEventAsync.asData?.value != null;

  return AsyncData(
    EventDetailViewModel(
      event: event,
      userProfile: userProfile,
      reviews: reviews,
      isAuthenticated: isAuthenticated,
      isHost: isHost,
      isSaved: isSaved,
      participation: participation,
    ),
  );
}
