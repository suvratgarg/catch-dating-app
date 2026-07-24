import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_membership.dart';
import 'package:catch_dating_app/core/app_config.dart';
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
    @Default(false) bool isClubMember,
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
  final membershipAsync = uid == null || event == null
      ? const AsyncData<ClubMembership?>(null)
      : ref.watch(watchClubMembershipProvider(event.clubId, uid));

  return buildEventDetailViewModel(
    eventAsync: eventAsync,
    userProfileAsync: ref.watch(watchUserProfileProvider),
    reviewsAsync: ref.watch(watchReviewsForEventProvider(eventId)),
    clubAsync: clubAsync,
    savedEventAsync: savedEventAsync,
    participationAsync: participationAsync,
    membershipAsync: membershipAsync,
    currentUid: uid,
    isAuthenticated: isAuthenticated,
    appRole: AppConfig.appRole,
    authResolved: uidAsync.hasValue || uidAsync.hasError,
    authError: uidAsync.hasError ? uidAsync.error : null,
    authStackTrace: uidAsync.hasError ? uidAsync.stackTrace : null,
  );
}

AsyncValue<EventDetailViewModel?> buildEventDetailViewModel({
  required AsyncValue<Event?> eventAsync,
  required AsyncValue<UserProfile?> userProfileAsync,
  required AsyncValue<List<Review>> reviewsAsync,
  required AsyncValue<Club?> clubAsync,
  required AsyncValue<SavedEvent?> savedEventAsync,
  required AsyncValue<EventParticipation?> participationAsync,
  AsyncValue<ClubMembership?> membershipAsync =
      const AsyncData<ClubMembership?>(null),
  required String? currentUid,
  required bool isAuthenticated,
  AppRole appRole = AppRole.consumer,
  bool authResolved = true,
  Object? authError,
  StackTrace? authStackTrace,
}) {
  // Do not transiently derive guest actions while Firebase auth is resolving.
  // This is especially important for route-extra fallbacks and save/review
  // controls whose policy differs for a signed-in viewer.
  if (!authResolved) return const AsyncLoading();

  if (authError != null) {
    return AsyncError(authError, authStackTrace ?? StackTrace.current);
  }

  // Event and organizer authority are blocking for every viewer. Rendering a
  // public event before its organizer resolves can leak a hidden listing and
  // transiently show the wrong guest actions.
  if (eventAsync.isLoading || clubAsync.isLoading) {
    return const AsyncLoading();
  }
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
  if (clubAsync.hasError) {
    return AsyncError(
      clubAsync.error!,
      clubAsync.stackTrace ?? StackTrace.current,
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
    if (savedEventAsync.hasError) {
      return AsyncError(
        savedEventAsync.error!,
        savedEventAsync.stackTrace ?? StackTrace.current,
      );
    }
    if (participationAsync.hasError) {
      return AsyncError(
        participationAsync.error!,
        participationAsync.stackTrace ?? StackTrace.current,
      );
    }
  }

  final event = eventAsync.asData?.value;
  if (event == null) return const AsyncData(null);
  final club = clubAsync.asData?.value;
  if (club == null) return const AsyncData(null);
  final isOwnedHostRoute =
      isAuthenticated && currentUid != null && club.isHostedBy(currentUid);
  if (appRole.isHost && !isOwnedHostRoute) {
    return const AsyncData(null);
  }
  if (!appRole.isHost && !club.isPubliclyBrowseable) {
    return const AsyncData(null);
  }
  if (isAuthenticated && !isOwnedHostRoute && membershipAsync.isLoading) {
    return const AsyncLoading();
  }
  if (isAuthenticated && !isOwnedHostRoute && membershipAsync.hasError) {
    return AsyncError(
      membershipAsync.error!,
      membershipAsync.stackTrace ?? StackTrace.current,
    );
  }

  final userProfile = isAuthenticated ? (userProfileAsync.asData?.value) : null;
  final reviews = isAuthenticated
      ? (reviewsAsync.asData?.value ?? const [])
      : const <Review>[];
  final participation = isAuthenticated
      ? participationAsync.asData?.value
      : null;
  final isHost =
      isAuthenticated && currentUid != null && club.isHostedBy(currentUid);
  final isSaved = isAuthenticated && savedEventAsync.requireValue != null;
  final isClubMember =
      isAuthenticated &&
      membershipAsync.asData?.value?.status == ClubMembershipStatus.active;

  return AsyncData(
    EventDetailViewModel(
      event: event,
      userProfile: userProfile,
      reviews: reviews,
      isAuthenticated: isAuthenticated,
      isHost: isHost,
      isSaved: isSaved,
      isClubMember: isClubMember,
      participation: participation,
    ),
  );
}
