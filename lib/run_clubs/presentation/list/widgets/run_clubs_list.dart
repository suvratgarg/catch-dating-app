import 'package:catch_dating_app/core/widgets/catch_error_text.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_controller.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_view_model.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/run_clubs_empty_state.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/run_clubs_list_body.dart';
import 'package:catch_dating_app/run_clubs/presentation/shared/run_clubs_mutation_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RunClubsList extends ConsumerWidget {
  const RunClubsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelAsync = ref.watch(runClubsListViewModelProvider);

    return switch (viewModelAsync) {
      AsyncLoading() => const SliverFillRemaining(
          child: CatchSkeletonList(count: 4),
        ),
      AsyncError(:final error) => SliverFillRemaining(
          child: CatchErrorText(error),
        ),
      AsyncData(:final value) => value.isEmpty
          ? const SliverFillRemaining(child: RunClubsEmptyState())
          : SliverToBoxAdapter(
              child: MutationErrorSnackbarListener(
                mutation: RunClubsListController.joinMutation,
                child: RunClubsListBody(viewModel: value),
              ),
            ),
    };
  }
}
