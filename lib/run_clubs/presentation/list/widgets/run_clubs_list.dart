import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_snackbar_listener.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_controller.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_view_model.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/run_clubs_empty_state.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/widgets/run_clubs_list_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RunClubsList extends ConsumerWidget {
  const RunClubsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelAsync = ref.watch(runClubsListViewModelProvider);
    final city = ref.watch(selectedRunClubCityProvider);
    final query = ref.watch(runClubSearchQueryProvider).trim();
    final sourceClubCount =
        ref
            .watch(watchRunClubsByLocationProvider(city.name))
            .asData
            ?.value
            .length ??
        0;
    final isSearchEmpty = query.isNotEmpty && sourceClubCount > 0;

    return switch (viewModelAsync) {
      AsyncLoading() => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            CatchSpacing.s5,
            CatchSpacing.s4,
            CatchSpacing.s5,
            CatchSpacing.s6,
          ),
          child: CatchSkeletonList(count: 3),
        ),
      ),
      AsyncError(:final error) => CatchSliverErrorState.fromError(
        error,
        context: AppErrorContext.club,
        onRetry: () {
          ref.invalidate(runClubsListViewModelProvider);
          ref.invalidate(watchRunClubsByLocationProvider(city.name));
        },
      ),
      AsyncData(:final value) =>
        value.isEmpty
            ? SliverFillRemaining(
                child: isSearchEmpty
                    ? const RunClubsEmptyState.noSearchResults()
                    : const RunClubsEmptyState(),
              )
            : MutationErrorSnackbarListener(
                mutation: RunClubsListController.joinMutation,
                child: RunClubsListBody(viewModel: value),
              ),
    };
  }
}
