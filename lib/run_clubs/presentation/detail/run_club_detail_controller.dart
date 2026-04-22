import 'package:catch_dating_app/app_user/data/app_user_repository.dart';
import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/presentation/shared/run_clubs_controller_utils.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_club_detail_controller.freezed.dart';
part 'run_club_detail_controller.g.dart';

@freezed
abstract class RunClubDetailViewModel with _$RunClubDetailViewModel {
  const factory RunClubDetailViewModel({
    required RunClub runClub,
    required bool isHost,
    required bool isMember,
    required List<Run> upcomingRuns,
    required List<Run> allRuns,
    required List<Review> reviews,
    required AppUser? appUser,
    required String? uid,
  }) = _RunClubDetailViewModel;
}

@riverpod
AsyncValue<RunClubDetailViewModel?> runClubDetailViewModel(
  Ref ref,
  String clubId,
) {
  final clubAsync = ref.watch(watchRunClubProvider(clubId));
  final runsAsync = ref.watch(runsForClubProvider(clubId));
  final reviewsAsync = ref.watch(watchReviewsForClubProvider(clubId));
  final appUserAsync = ref.watch(appUserStreamProvider);
  final uidAsync = ref.watch(uidProvider);

  return buildRunClubDetailViewModel(
    clubAsync: clubAsync,
    runsAsync: runsAsync,
    reviewsAsync: reviewsAsync,
    appUserAsync: appUserAsync,
    uidAsync: uidAsync,
  );
}

AsyncValue<RunClubDetailViewModel?> buildRunClubDetailViewModel({
  required AsyncValue<RunClub?> clubAsync,
  required AsyncValue<List<Run>> runsAsync,
  required AsyncValue<List<Review>> reviewsAsync,
  required AsyncValue<AppUser?> appUserAsync,
  required AsyncValue<String?> uidAsync,
  DateTime? now,
}) {
  if (clubAsync.isLoading ||
      runsAsync.isLoading ||
      reviewsAsync.isLoading ||
      appUserAsync.isLoading ||
      uidAsync.isLoading) {
    return const AsyncLoading();
  }
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
  if (reviewsAsync.hasError) {
    return AsyncError(
      reviewsAsync.error!,
      reviewsAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (appUserAsync.hasError) {
    return AsyncError(
      appUserAsync.error!,
      appUserAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (uidAsync.hasError) {
    return AsyncError(
      uidAsync.error!,
      uidAsync.stackTrace ?? StackTrace.current,
    );
  }

  final runClub = clubAsync.asData?.value;
  if (runClub == null) return const AsyncData(null);

  final runs = runsAsync.asData?.value ?? const [];
  final reviews = reviewsAsync.asData?.value ?? const [];
  final appUser = appUserAsync.asData?.value;
  final uid = uidAsync.asData?.value;
  final effectiveNow = now ?? DateTime.now();

  return AsyncData(
    RunClubDetailViewModel(
      runClub: runClub,
      isHost: uid != null && uid == runClub.hostUserId,
      isMember: uid != null && runClub.hasMember(uid),
      upcomingRuns: runs
          .where((run) => run.startTime.isAfter(effectiveNow))
          .toList(),
      allRuns: runs,
      reviews: reviews,
      appUser: appUser,
      uid: uid,
    ),
  );
}

@riverpod
class RunClubDetailController extends _$RunClubDetailController {
  static final joinMutation = Mutation<void>();
  static final leaveMutation = Mutation<void>();

  @override
  void build() {}

  Future<void> join(String clubId) async {
    final uid = requireSignedInUid(ref, action: 'join a club');
    await ref.read(runClubsRepositoryProvider).joinClub(clubId, uid);
  }

  Future<void> leave(String clubId) async {
    final uid = requireSignedInUid(ref, action: 'leave a club');
    await ref.read(runClubsRepositoryProvider).leaveClub(clubId, uid);
  }
}
