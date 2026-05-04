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
    required UserProfile userProfile,
    required List<Review> reviews,
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
  return buildRunDetailViewModel(
    runAsync: ref.watch(watchRunProvider(runId)),
    userProfileAsync: ref.watch(watchUserProfileProvider),
    reviewsAsync: ref.watch(watchReviewsForRunProvider(runId)),
  );
}

AsyncValue<RunDetailViewModel?> buildRunDetailViewModel({
  required AsyncValue<Run?> runAsync,
  required AsyncValue<UserProfile?> userProfileAsync,
  required AsyncValue<List<Review>> reviewsAsync,
}) {
  if (runAsync.isLoading ||
      userProfileAsync.isLoading ||
      reviewsAsync.isLoading) {
    return const AsyncLoading();
  }
  if (runAsync.hasError) {
    return AsyncError(
      runAsync.error!,
      runAsync.stackTrace ?? StackTrace.current,
    );
  }
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

  final run = runAsync.asData?.value;
  if (run == null) return const AsyncData(null);

  final userProfile = userProfileAsync.asData?.value;
  if (userProfile == null) return const AsyncLoading();

  final reviews = reviewsAsync.asData?.value ?? const [];

  return AsyncData(
    RunDetailViewModel(run: run, userProfile: userProfile, reviews: reviews),
  );
}
