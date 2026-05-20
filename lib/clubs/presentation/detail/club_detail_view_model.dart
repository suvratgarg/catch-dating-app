import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_membership.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'club_detail_view_model.freezed.dart';
part 'club_detail_view_model.g.dart';

@freezed
abstract class ClubDetailViewModel with _$ClubDetailViewModel {
  const factory ClubDetailViewModel({
    required Club club,
    required bool isHost,
    required bool isMember,
    required List<Event> upcomingEvents,
    required List<Review> reviews,
    required UserProfile? userProfile,
    required String? uid,
    required bool isAuthenticated,
  }) = _ClubDetailViewModel;
}

/// **Pattern D: View-model provider**
///
/// Watches the club, events, reviews, user profile, and auth streams and
/// combines them into a single [ClubDetailViewModel].
///
/// Club, events, and auth identity are blocking because they control the main
/// route and schedule. Reviews, profile, and membership state are secondary;
/// they hydrate the detail screen when available without hiding newly-created
/// events behind the route's placeholder body.
@riverpod
AsyncValue<ClubDetailViewModel?> clubDetailViewModel(Ref ref, String clubId) {
  final clubAsync = ref.watch(watchClubProvider(clubId));
  final eventsAsync = ref.watch(watchEventsForClubProvider(clubId));
  final reviewsAsync = ref.watch(watchReviewsForClubProvider(clubId));
  final userProfileAsync = ref.watch(watchUserProfileProvider);
  final uidAsync = ref.watch(uidProvider);
  final uid = uidAsync.asData?.value;
  final membershipAsync = uid == null
      ? const AsyncData<ClubMembership?>(null)
      : ref.watch(watchClubMembershipProvider(clubId, uid));

  return buildClubDetailViewModel(
    clubAsync: clubAsync,
    eventsAsync: eventsAsync,
    reviewsAsync: reviewsAsync,
    userProfileAsync: userProfileAsync,
    uidAsync: uidAsync,
    membershipAsync: membershipAsync,
  );
}

AsyncValue<ClubDetailViewModel?> buildClubDetailViewModel({
  required AsyncValue<Club?> clubAsync,
  required AsyncValue<List<Event>> eventsAsync,
  required AsyncValue<List<Review>> reviewsAsync,
  required AsyncValue<UserProfile?> userProfileAsync,
  required AsyncValue<String?> uidAsync,
  required AsyncValue<ClubMembership?> membershipAsync,
  DateTime? now,
}) {
  final uid = uidAsync.asData?.value;
  final isAuthenticated = uid != null;

  // Always block on core data needed for the route and schedule.
  if (clubAsync.isLoading || eventsAsync.isLoading || uidAsync.isLoading) {
    return const AsyncLoading();
  }

  if (clubAsync.hasError) {
    return AsyncError(
      clubAsync.error!,
      clubAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (eventsAsync.hasError) {
    return AsyncError(
      eventsAsync.error!,
      eventsAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (uidAsync.hasError) {
    return AsyncError(
      uidAsync.error!,
      uidAsync.stackTrace ?? StackTrace.current,
    );
  }

  final club = clubAsync.asData?.value;
  if (club == null) return const AsyncData(null);

  final events = eventsAsync.asData?.value ?? const [];
  final effectiveNow = now ?? DateTime.now();
  final upcomingEvents =
      events.where((event) => event.startTime.isAfter(effectiveNow)).toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
  final reviews = isAuthenticated
      ? (reviewsAsync.asData?.value ?? const [])
      : const <Review>[];
  final userProfile = isAuthenticated ? (userProfileAsync.asData?.value) : null;
  final membership = membershipAsync.asData?.value;
  final isActiveMember = membership?.status == ClubMembershipStatus.active;

  return AsyncData(
    ClubDetailViewModel(
      club: club,
      isHost: isAuthenticated && club.isHostedBy(uid),
      isMember: isAuthenticated && isActiveMember,
      upcomingEvents: upcomingEvents,
      reviews: reviews,
      userProfile: userProfile,
      uid: uid,
      isAuthenticated: isAuthenticated,
    ),
  );
}
