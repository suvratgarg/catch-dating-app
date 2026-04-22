import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/presentation/detail/run_club_detail_view_model.dart';
import 'package:catch_dating_app/run_clubs/presentation/detail/run_club_membership_controller.dart';
import 'package:catch_dating_app/run_clubs/presentation/detail/widgets/club_detail_body.dart';
import 'package:catch_dating_app/run_clubs/presentation/shared/run_clubs_mutation_feedback.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
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
    final joinMutation = ref.watch(RunClubMembershipController.joinMutation);
    final leaveMutation = ref.watch(RunClubMembershipController.leaveMutation);
    final currentUid = ref.watch(uidProvider).asData?.value;
    final currentUserProfile = ref
        .watch(userProfileStreamProvider)
        .asData
        ?.value;

    listenForMutationErrorSnackbar(
      context: context,
      ref: ref,
      mutation: RunClubMembershipController.joinMutation,
    );
    listenForMutationErrorSnackbar(
      context: context,
      ref: ref,
      mutation: RunClubMembershipController.leaveMutation,
    );

    final vm = vmAsync.asData?.value;

    if (vm != null) {
      return Scaffold(
        body: _buildBody(
          runClub: vm.runClub,
          runs: vm.allRuns,
          upcomingRuns: vm.upcomingRuns,
          reviews: vm.reviews,
          userProfile: vm.userProfile,
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
          userProfile: currentUserProfile,
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

  Widget _buildBody({
    required RunClub runClub,
    required List<Run> runs,
    required List<Run> upcomingRuns,
    required List<Review> reviews,
    required UserProfile? userProfile,
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
      userProfile: userProfile,
      uid: uid,
      isHost: isHost,
      isMember: isMember,
      isMutating: isMutating,
    );
  }
}
