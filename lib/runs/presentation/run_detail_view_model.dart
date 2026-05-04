import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_detail_view_model.freezed.dart';
part 'run_detail_view_model.g.dart';

@freezed
abstract class RunDetailViewModel with _$RunDetailViewModel {
  const factory RunDetailViewModel({
    required Run run,
    required UserProfile? userProfile,
    required List<Review> reviews,
    required bool isAuthenticated,
  }) = _RunDetailViewModel;
}

/// **Pattern D: Pure computed provider combining multiple async streams**
///
/// Watches several stream/future providers and combines them into one
/// [AsyncValue] via [buildRunDetailViewModel]. Each input is individually
/// checked for loading/error so the combined result is [AsyncError] if any
/// input fails or [AsyncLoading] if any input is still loading.
///
/// **When to use this pattern:** Screens that need data from multiple
/// independent sources and want a single `.when(loading:error:data:)` call
/// instead of managing multiple async states.
@riverpod
AsyncValue<RunDetailViewModel?> runDetailViewModel(Ref ref, String runId) {
  final uidAsync = ref.watch(uidProvider);
  final isAuthenticated = uidAsync.asData?.value != null;

  return buildRunDetailViewModel(
    runAsync: ref.watch(watchRunProvider(runId)),
    userProfileAsync: ref.watch(watchUserProfileProvider),
    reviewsAsync: ref.watch(watchReviewsForRunProvider(runId)),
    isAuthenticated: isAuthenticated,
  );
}

AsyncValue<RunDetailViewModel?> buildRunDetailViewModel({
  required AsyncValue<Run?> runAsync,
  required AsyncValue<UserProfile?> userProfileAsync,
  required AsyncValue<List<Review>> reviewsAsync,
  required bool isAuthenticated,
}) {
  // Always block on run data (needed for all users).
  if (runAsync.isLoading) return const AsyncLoading();
  // For authenticated users, also block on reviews + user profile.
  if (isAuthenticated) {
    if (userProfileAsync.isLoading || reviewsAsync.isLoading) {
      return const AsyncLoading();
    }
  }

  // Run error is always fatal.
  if (runAsync.hasError) {
    return AsyncError(
      runAsync.error!,
      runAsync.stackTrace ?? StackTrace.current,
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

  final run = runAsync.asData?.value;
  if (run == null) return const AsyncData(null);

  final userProfile =
      isAuthenticated ? (userProfileAsync.asData?.value) : null;
  final reviews = isAuthenticated
      ? (reviewsAsync.asData?.value ?? const [])
      : const <Review>[];

  return AsyncData(
    RunDetailViewModel(
      run: run,
      userProfile: userProfile,
      reviews: reviews,
      isAuthenticated: isAuthenticated,
    ),
  );
}
