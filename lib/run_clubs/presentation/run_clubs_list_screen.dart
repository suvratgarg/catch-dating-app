import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/run_clubs/presentation/run_clubs_list_controller.dart';
import 'package:catch_dating_app/run_clubs/presentation/run_clubs_list_state.dart';
import 'package:catch_dating_app/run_clubs/presentation/widgets/run_clubs_content.dart';
import 'package:catch_dating_app/run_clubs/presentation/widgets/run_clubs_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RunClubsListScreen extends ConsumerWidget {
  const RunClubsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final viewModelAsync = ref.watch(runClubsListViewModelProvider);
    final followMutation = ref.watch(RunClubsListController.followMutation);

    ref.listen(RunClubsListController.followMutation, (previous, current) {
      if (previous?.isPending == true && current.hasError) {
        final error = current as MutationError;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.error.toString())),
        );
      }
    });

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const RunClubsHeader(),
            Expanded(
              child: viewModelAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    Center(child: Text('Error loading clubs: $error')),
                data: (viewModel) => RunClubsContent(
                  viewModel: viewModel,
                  isFollowPending: followMutation.isPending,
                  onFollow: followMutation.isPending
                      ? null
                      : (club) => _followClub(ref, club.id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _followClub(WidgetRef ref, String clubId) {
    RunClubsListController.followMutation.run(ref, (transaction) async {
      await transaction
          .get(runClubsListControllerProvider.notifier)
          .followClub(clubId);
    });
  }
}
