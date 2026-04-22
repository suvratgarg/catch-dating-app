import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_controller.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_view_model.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/run_clubs_content.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/run_clubs_header.dart';
import 'package:catch_dating_app/run_clubs/presentation/shared/run_clubs_mutation_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RunClubsListScreen extends ConsumerWidget {
  const RunClubsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final viewModelAsync = ref.watch(runClubsListViewModelProvider);
    final joinMutation = ref.watch(RunClubsListController.joinMutation);

    listenForMutationErrorSnackbar(
      context: context,
      ref: ref,
      mutation: RunClubsListController.joinMutation,
    );

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const RunClubsHeader(),
            Expanded(
              child: viewModelAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    Center(child: Text('Error loading clubs: $error')),
                data: (viewModel) => RunClubsContent(
                  viewModel: viewModel,
                  isJoinPending: joinMutation.isPending,
                  onJoin: joinMutation.isPending
                      ? null
                      : (club) => _joinClub(ref, club.id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _joinClub(WidgetRef ref, String clubId) {
    RunClubsListController.joinMutation.run(ref, (transaction) async {
      await transaction
          .get(runClubsListControllerProvider.notifier)
          .joinClub(clubId);
    });
  }
}
