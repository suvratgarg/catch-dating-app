import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_membership_controller.dart';
import 'package:catch_dating_app/clubs/presentation/list/clubs_list_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/clubs_empty_state.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/clubs_list_body.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_snackbar_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClubsList extends ConsumerWidget {
  const ClubsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelAsync = ref.watch(clubsListViewModelProvider);
    final city = ref.watch(selectedClubCityProvider);
    final query = ref.watch(clubSearchQueryProvider).trim();
    final sourceClubCount =
        ref
            .watch(watchClubsByLocationProvider(city.name))
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
          ref.invalidate(clubsListViewModelProvider);
          ref.invalidate(watchClubsByLocationProvider(city.name));
        },
      ),
      AsyncData(:final value) =>
        value.isEmpty
            ? SliverFillRemaining(
                child: isSearchEmpty
                    ? const ClubsEmptyState.noSearchResults()
                    : const ClubsEmptyState(),
              )
            : MutationErrorSnackbarListener(
                mutation: ClubMembershipController.joinMutation,
                child: ClubsListBody(viewModel: value),
              ),
    };
  }
}
