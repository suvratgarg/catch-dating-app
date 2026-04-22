import 'package:catch_dating_app/app_user/data/app_user_repository.dart';
import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_detail_controller.g.dart';

class RunDetailViewModel {
  const RunDetailViewModel({
    required this.run,
    required this.appUser,
    required this.reviews,
  });

  final Run run;
  final AppUser appUser;
  final List<Review> reviews;
}

@riverpod
AsyncValue<RunDetailViewModel?> runDetailViewModel(Ref ref, String runId) {
  final runAsync = ref.watch(watchRunProvider(runId));
  final appUserAsync = ref.watch(appUserStreamProvider);
  final reviewsAsync = ref.watch(watchReviewsForRunProvider(runId));

  if (runAsync.isLoading || appUserAsync.isLoading) return const AsyncLoading();
  if (runAsync.hasError) {
    return AsyncError(
        runAsync.error!, runAsync.stackTrace ?? StackTrace.current);
  }
  if (appUserAsync.hasError) {
    return AsyncError(
        appUserAsync.error!, appUserAsync.stackTrace ?? StackTrace.current);
  }

  final run = runAsync.asData?.value;
  if (run == null) return const AsyncData(null);

  final appUser = appUserAsync.asData?.value;
  // appUser briefly null while stream initialises — treat as loading.
  if (appUser == null) return const AsyncLoading();

  final reviews = reviewsAsync.asData?.value ?? const [];

  return AsyncData(RunDetailViewModel(
    run: run,
    appUser: appUser,
    reviews: reviews,
  ));
}
