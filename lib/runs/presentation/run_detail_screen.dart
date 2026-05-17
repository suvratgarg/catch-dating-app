import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/runs/data/run_participation_repository.dart';
import 'package:catch_dating_app/runs/data/saved_run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_detail_view_model.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_detail_body.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RunDetailScreen extends ConsumerWidget {
  const RunDetailScreen({
    super.key,
    required this.runClubId,
    required this.runId,
    this.initialRun,
  });

  final String runClubId;
  final String runId;
  final Run? initialRun;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vmAsync = ref.watch(runDetailViewModelProvider(runId));
    final vm = vmAsync.asData?.value;

    if (vm != null) {
      return _buildBody(vm);
    }

    if (vmAsync.isLoading && _initialRunMatchesRoute) {
      return _buildInitialRunBody(ref, initialRun!);
    }

    if (vmAsync.isLoading) {
      return const Scaffold(body: CatchLoadingIndicator());
    }

    if (vmAsync.hasError) {
      return CatchErrorScaffold.fromError(
        vmAsync.error!,
        context: AppErrorContext.run,
        onRetry: () => ref.invalidate(runDetailViewModelProvider(runId)),
      );
    }

    return const CatchErrorScaffold(
      title: 'Run not found',
      message: 'This run is no longer available.',
    );
  }

  bool get _initialRunMatchesRoute =>
      initialRun != null &&
      initialRun!.id == runId &&
      initialRun!.runClubId == runClubId;

  Widget _buildBody(RunDetailViewModel vm) {
    return RunDetailBody(
      run: vm.run,
      userProfile: vm.userProfile,
      runClubId: runClubId,
      reviews: vm.reviews,
      isAuthenticated: vm.isAuthenticated,
      isHost: vm.isHost,
      isSaved: vm.isSaved,
      participation: vm.participation,
    );
  }

  Widget _buildInitialRunBody(WidgetRef ref, Run run) {
    final currentUid = ref.watch(uidProvider).asData?.value;
    final isAuthenticated = currentUid != null;
    final userProfile = isAuthenticated
        ? ref.watch(watchUserProfileProvider).asData?.value
        : null;
    final reviews = isAuthenticated
        ? ref.watch(watchReviewsForRunProvider(run.id)).asData?.value ??
              const <Review>[]
        : const <Review>[];
    final runClub = isAuthenticated
        ? ref.watch(fetchRunClubProvider(run.runClubId)).asData?.value
        : null;
    final savedRun = currentUid == null
        ? null
        : ref.watch(watchSavedRunProvider(currentUid, run.id)).asData?.value;
    final participation = currentUid == null
        ? null
        : ref
              .watch(watchRunParticipationProvider(run.id, currentUid))
              .asData
              ?.value;

    return RunDetailBody(
      run: run,
      userProfile: userProfile,
      runClubId: runClubId,
      reviews: reviews,
      isAuthenticated: isAuthenticated,
      isHost: currentUid != null && runClub?.hostUserId == currentUid,
      isSaved: savedRun != null,
      participation: participation,
    );
  }
}
