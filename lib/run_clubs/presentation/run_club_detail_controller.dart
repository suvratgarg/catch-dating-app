import 'package:catch_dating_app/app_user/data/app_user_repository.dart';
import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/presentation/run_clubs_controller_utils.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_club_detail_controller.g.dart';

class RunClubDetailViewModel {
  const RunClubDetailViewModel({
    required this.runClub,
    required this.isHost,
    required this.isMember,
    required this.upcomingRuns,
    required this.allRuns,
    required this.reviews,
    required this.appUser,
    required this.uid,
  });

  final RunClub runClub;
  final bool isHost;
  final bool isMember;
  final List<Run> upcomingRuns;
  final List<Run> allRuns;
  final List<Review> reviews;
  final AppUser? appUser;
  final String? uid;
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

  if (clubAsync.isLoading || runsAsync.isLoading) return const AsyncLoading();
  if (clubAsync.hasError) {
    return AsyncError(
        clubAsync.error!, clubAsync.stackTrace ?? StackTrace.current);
  }
  if (runsAsync.hasError) {
    return AsyncError(
        runsAsync.error!, runsAsync.stackTrace ?? StackTrace.current);
  }

  final runClub = clubAsync.asData?.value;
  if (runClub == null) return const AsyncData(null);

  final runs = runsAsync.asData?.value ?? const [];
  final reviews = reviewsAsync.asData?.value ?? const [];
  final appUser = appUserAsync.asData?.value;
  final uid = uidAsync.asData?.value;
  final now = DateTime.now();

  return AsyncData(RunClubDetailViewModel(
    runClub: runClub,
    isHost: uid != null && uid == runClub.hostUserId,
    isMember: uid != null && runClub.memberUserIds.contains(uid),
    upcomingRuns: runs.where((r) => r.startTime.isAfter(now)).toList(),
    allRuns: runs,
    reviews: reviews,
    appUser: appUser,
    uid: uid,
  ));
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
