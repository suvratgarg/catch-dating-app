import 'package:catch_dating_app/app_user/data/app_user_repository.dart';
import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/presentation/run_club_detail_controller.dart';
import 'package:catch_dating_app/run_clubs/presentation/widgets/club_detail_body.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RunClubDetailScreen extends ConsumerWidget {
  const RunClubDetailScreen({
    super.key,
    required this.runClubId,
    this.initialRunClub,
  });

  final String runClubId;
  final RunClub? initialRunClub;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vmAsync = ref.watch(runClubDetailViewModelProvider(runClubId));
    final joinMutation = ref.watch(RunClubDetailController.joinMutation);
    final leaveMutation = ref.watch(RunClubDetailController.leaveMutation);
    final currentUid = ref.watch(uidProvider).asData?.value;
    final currentAppUser = ref.watch(appUserStreamProvider).asData?.value;

    _listenForMutationErrors(context, ref);

    final vm = vmAsync.asData?.value;

    if (vm != null) {
      return Scaffold(
        body: _buildBody(
          runClub: vm.runClub,
          runs: vm.allRuns,
          upcomingRuns: vm.upcomingRuns,
          reviews: vm.reviews,
          appUser: vm.appUser,
          uid: vm.uid,
          isHost: vm.isHost,
          isMember: vm.isMember,
          isMutating: joinMutation.isPending || leaveMutation.isPending,
        ),
      );
    }

    if (vmAsync.isLoading && initialRunClub != null) {
      return Scaffold(
        body: _buildBody(
          runClub: initialRunClub!,
          runs: const [],
          upcomingRuns: const [],
          reviews: const [],
          appUser: currentAppUser,
          uid: currentUid,
          isHost:
              currentUid != null && currentUid == initialRunClub!.hostUserId,
          isMember: currentUid != null && initialRunClub!.hasMember(currentUid),
          isMutating: joinMutation.isPending || leaveMutation.isPending,
        ),
      );
    }

    return Scaffold(
      body: vmAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (_) => const Center(child: Text('Run club not found.')),
      ),
    );
  }

  void _listenForMutationErrors(BuildContext context, WidgetRef ref) {
    ref.listen(RunClubDetailController.joinMutation, (previous, current) {
      if (previous?.isPending == true && current.hasError) {
        final error = current as MutationError;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.error.toString())));
      }
    });
    ref.listen(RunClubDetailController.leaveMutation, (previous, current) {
      if (previous?.isPending == true && current.hasError) {
        final error = current as MutationError;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.error.toString())));
      }
    });
  }

  Widget _buildBody({
    required RunClub runClub,
    required List<Run> runs,
    required List<Run> upcomingRuns,
    required List<Review> reviews,
    required AppUser? appUser,
    required String? uid,
    required bool isHost,
    required bool isMember,
    required bool isMutating,
  }) {
    return ClubDetailBody(
      runClub: runClub,
      runs: runs,
      upcoming: upcomingRuns,
      reviews: reviews,
      appUser: appUser,
      uid: uid,
      isHost: isHost,
      isMember: isMember,
      isMutating: isMutating,
    );
  }
}
