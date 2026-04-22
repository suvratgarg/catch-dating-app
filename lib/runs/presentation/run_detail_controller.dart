import 'package:catch_dating_app/app_user/data/app_user_repository.dart';
import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_detail_controller.freezed.dart';
part 'run_detail_controller.g.dart';

@freezed
abstract class RunDetailViewModel with _$RunDetailViewModel {
  const factory RunDetailViewModel({
    required Run run,
    required AppUser appUser,
    required List<Review> reviews,
  }) = _RunDetailViewModel;
}

AsyncValue<RunDetailViewModel?> buildRunDetailViewModel({
  required AsyncValue<Run?> runAsync,
  required AsyncValue<AppUser?> appUserAsync,
  required AsyncValue<List<Review>> reviewsAsync,
}) {
  if (runAsync.isLoading || appUserAsync.isLoading || reviewsAsync.isLoading) {
    return const AsyncLoading();
  }
  if (runAsync.hasError) {
    return AsyncError(
      runAsync.error!,
      runAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (appUserAsync.hasError) {
    return AsyncError(
      appUserAsync.error!,
      appUserAsync.stackTrace ?? StackTrace.current,
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

  final appUser = appUserAsync.asData?.value;
  // appUser briefly null while stream initialises — treat as loading.
  if (appUser == null) return const AsyncLoading();

  final reviews = reviewsAsync.asData?.value ?? const [];

  return AsyncData(
    RunDetailViewModel(run: run, appUser: appUser, reviews: reviews),
  );
}

@riverpod
AsyncValue<RunDetailViewModel?> runDetailViewModel(Ref ref, String runId) {
  return buildRunDetailViewModel(
    runAsync: ref.watch(watchRunProvider(runId)),
    appUserAsync: ref.watch(appUserStreamProvider),
    reviewsAsync: ref.watch(watchReviewsForRunProvider(runId)),
  );
}
