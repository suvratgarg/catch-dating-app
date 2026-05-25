import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_membership_controller.dart';
import 'package:catch_dating_app/clubs/presentation/list/clubs_list_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/clubs_empty_state.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/clubs_list_body.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
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
    final filters = ref.watch(clubBrowseFiltersProvider);
    final sourceClubCount =
        ref
            .watch(watchClubsByLocationProvider(city.name))
            .asData
            ?.value
            .length ??
        0;
    final hasSourceClubs = sourceClubCount > 0;

    return switch (viewModelAsync) {
      AsyncLoading() => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            CatchSpacing.s5,
            CatchSpacing.s4,
            CatchSpacing.s5,
            CatchSpacing.s6,
          ),
          child: _ClubDirectorySkeletonList(),
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
                child: _buildEmptyState(
                  ref,
                  cityLabel: city.label,
                  hasSourceClubs: hasSourceClubs,
                  hasSearch: query.isNotEmpty,
                  filters: filters,
                ),
              )
            : MutationErrorSnackbarListener(
                mutation: ClubMembershipController.joinMutation,
                child: ClubsListBody(viewModel: value),
              ),
    };
  }

  Widget _buildEmptyState(
    WidgetRef ref, {
    required String cityLabel,
    required bool hasSourceClubs,
    required bool hasSearch,
    required ClubBrowseFilterSelection filters,
  }) {
    final hasFilters = filters.hasActiveFilters;
    if (!hasSourceClubs) {
      return ClubsEmptyState(cityLabel: cityLabel);
    }
    if (hasSearch && hasFilters) {
      return ClubsEmptyState.noFilteredSearchResults(
        action: _clearAction(ref, clearSearch: true, clearFilters: true),
      );
    }
    if (hasSearch) {
      return ClubsEmptyState.noSearchResults(
        hasFilters: false,
        action: _clearAction(ref, clearSearch: true, clearFilters: false),
      );
    }
    if (hasFilters) {
      return ClubsEmptyState.noFilterResults(
        action: _clearAction(ref, clearSearch: false, clearFilters: true),
      );
    }
    return ClubsEmptyState(cityLabel: cityLabel);
  }

  Widget _clearAction(
    WidgetRef ref, {
    required bool clearSearch,
    required bool clearFilters,
  }) {
    final label = switch ((clearSearch, clearFilters)) {
      (true, true) => 'Clear search and filters',
      (true, false) => 'Clear search',
      (false, true) => 'Clear filters',
      (false, false) => 'Clear',
    };
    return CatchButton(
      label: label,
      onPressed: () {
        if (clearSearch) {
          ref.read(clubSearchQueryProvider.notifier).clear();
        }
        if (clearFilters) {
          ref.read(clubBrowseFiltersProvider.notifier).clear();
        }
      },
      variant: CatchButtonVariant.secondary,
      icon: const Icon(Icons.close_rounded),
    );
  }
}

class _ClubDirectorySkeletonList extends StatelessWidget {
  const _ClubDirectorySkeletonList();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _ClubDirectorySkeletonCard(),
        SizedBox(height: 14),
        _ClubDirectorySkeletonCard(),
        SizedBox(height: 14),
        _ClubDirectorySkeletonCard(),
      ],
    );
  }
}

class _ClubDirectorySkeletonCard extends StatelessWidget {
  const _ClubDirectorySkeletonCard();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.card(height: 120),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CatchSkeleton.text(width: 180),
                gapH8,
                CatchSkeleton.text(width: 132),
                gapH12,
                Row(
                  children: [
                    CatchSkeleton.card(width: 72, height: 24),
                    gapW8,
                    CatchSkeleton.card(width: 96, height: 24),
                  ],
                ),
                gapH12,
                Container(height: 1, color: t.line),
                gapH12,
                Row(
                  children: [
                    CatchSkeleton.circle(size: 18),
                    gapW8,
                    Expanded(child: CatchSkeleton.text(width: 140)),
                    gapW12,
                    CatchSkeleton.card(width: 70, height: 36),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
