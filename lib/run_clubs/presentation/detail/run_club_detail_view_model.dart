import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/run_clubs/data/run_club_membership_repository.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club_membership.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_club_detail_view_model.freezed.dart';
part 'run_club_detail_view_model.g.dart';

@freezed
abstract class RunClubDetailViewModel with _$RunClubDetailViewModel {
  const factory RunClubDetailViewModel({
    required RunClub runClub,
    required bool isHost,
    required bool isMember,
    required List<Run> upcomingRuns,
    required List<Run> allRuns,
    required List<Review> reviews,
    required UserProfile? userProfile,
    required String? uid,
    required bool isAuthenticated,
  }) = _RunClubDetailViewModel;
}

/// **Pattern D: View-model provider**
///
/// Watches the club, runs, reviews, user profile, and auth streams and
/// combines them into a single [RunClubDetailViewModel]. Each input is
/// individually checked so the combined result is [AsyncError] if any input
/// fails or [AsyncLoading] if any input is still loading.
@riverpod
AsyncValue<RunClubDetailViewModel?> runClubDetailViewModel(
  Ref ref,
  String clubId,
) {
  final clubAsync = ref.watch(watchRunClubProvider(clubId));
  final runsAsync = ref.watch(watchRunsForClubProvider(clubId));
  final reviewsAsync = ref.watch(watchReviewsForClubProvider(clubId));
  final userProfileAsync = ref.watch(watchUserProfileProvider);
  final uidAsync = ref.watch(uidProvider);
  final uid = uidAsync.asData?.value;
  final membershipAsync = uid == null
      ? const AsyncData<RunClubMembership?>(null)
      : ref.watch(watchRunClubMembershipProvider(clubId, uid));

  return buildRunClubDetailViewModel(
    clubAsync: clubAsync,
    runsAsync: runsAsync,
    reviewsAsync: reviewsAsync,
    userProfileAsync: userProfileAsync,
    uidAsync: uidAsync,
    membershipAsync: membershipAsync,
  );
}

AsyncValue<RunClubDetailViewModel?> buildRunClubDetailViewModel({
  required AsyncValue<RunClub?> clubAsync,
  required AsyncValue<List<Run>> runsAsync,
  required AsyncValue<List<Review>> reviewsAsync,
  required AsyncValue<UserProfile?> userProfileAsync,
  required AsyncValue<String?> uidAsync,
  required AsyncValue<RunClubMembership?> membershipAsync,
  DateTime? now,
}) {
  final uid = uidAsync.asData?.value;
  final isAuthenticated = uid != null;

  // Always block on core data needed for all users.
  if (clubAsync.isLoading || runsAsync.isLoading || uidAsync.isLoading) {
    return const AsyncLoading();
  }
  // For authenticated users, also block on reviews + user profile.
  if (isAuthenticated) {
    if (reviewsAsync.isLoading ||
        userProfileAsync.isLoading ||
        membershipAsync.isLoading) {
      return const AsyncLoading();
    }
  }

  // Club, runs, and uid errors are always fatal.
  if (clubAsync.hasError) {
    return AsyncError(
      clubAsync.error!,
      clubAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (runsAsync.hasError) {
    return AsyncError(
      runsAsync.error!,
      runsAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (uidAsync.hasError) {
    return AsyncError(
      uidAsync.error!,
      uidAsync.stackTrace ?? StackTrace.current,
    );
  }

  // Reviews and userProfile errors only fatal for authenticated users.
  if (isAuthenticated) {
    if (reviewsAsync.hasError) {
      return AsyncError(
        reviewsAsync.error!,
        reviewsAsync.stackTrace ?? StackTrace.current,
      );
    }
    if (userProfileAsync.hasError) {
      return AsyncError(
        userProfileAsync.error!,
        userProfileAsync.stackTrace ?? StackTrace.current,
      );
    }
    if (membershipAsync.hasError) {
      return AsyncError(
        membershipAsync.error!,
        membershipAsync.stackTrace ?? StackTrace.current,
      );
    }
  }

  final runClub = clubAsync.asData?.value;
  if (runClub == null) return const AsyncData(null);

  final runs = runsAsync.asData?.value ?? const [];
  final effectiveNow = now ?? DateTime.now();
  final upcomingRuns =
      runs.where((run) => run.startTime.isAfter(effectiveNow)).toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
  final reviews = isAuthenticated
      ? (reviewsAsync.asData?.value ?? const [])
      : const <Review>[];
  final userProfile = isAuthenticated ? (userProfileAsync.asData?.value) : null;
  final membership = membershipAsync.asData?.value;
  final isActiveMember = membership?.status == RunClubMembershipStatus.active;

  return AsyncData(
    RunClubDetailViewModel(
      runClub: runClub,
      isHost: isAuthenticated && uid == runClub.hostUserId,
      isMember: isAuthenticated && isActiveMember,
      upcomingRuns: upcomingRuns,
      allRuns: runs,
      reviews: reviews,
      userProfile: userProfile,
      uid: uid,
      isAuthenticated: isAuthenticated,
    ),
  );
}
