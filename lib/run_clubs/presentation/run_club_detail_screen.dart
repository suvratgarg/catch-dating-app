import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/presentation/run_club_detail_controller.dart';
import 'package:catch_dating_app/run_clubs/presentation/widgets/club_detail_body.dart';
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

    ref.listen(RunClubDetailController.joinMutation, (previous, current) {
      if (previous?.isPending == true && current.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text((current as MutationError).error.toString())),
        );
      }
    });
    ref.listen(RunClubDetailController.leaveMutation, (previous, current) {
      if (previous?.isPending == true && current.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text((current as MutationError).error.toString())),
        );
      }
    });

    // Use initialRunClub for optimistic first-paint while stream settles.
    final vm = vmAsync.asData?.value;
    final runClub = vm?.runClub ?? initialRunClub;

    if (runClub == null) {
      return Scaffold(
        body: vmAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (_) => const Center(child: Text('Run club not found.')),
        ),
      );
    }

    if (vm == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: ClubDetailBody(
        runClub: vm.runClub,
        runs: vm.allRuns,
        upcoming: vm.upcomingRuns,
        reviews: vm.reviews,
        appUser: vm.appUser,
        uid: vm.uid,
        isHost: vm.isHost,
        isMember: vm.isMember,
        isMutating: joinMutation.isPending || leaveMutation.isPending,
      ),
    );
  }
}
