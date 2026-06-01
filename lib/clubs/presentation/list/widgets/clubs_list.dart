import 'package:catch_dating_app/clubs/presentation/detail/club_membership_controller.dart';
import 'package:catch_dating_app/clubs/presentation/list/clubs_list_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/clubs_empty_state.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/clubs_list_body.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
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
  const ClubsList({
    super.key,
    this.includeJoinedClubsRail = true,
    this.includeClubDirectory = true,
  });

  /// Whether to render the "Your clubs" avatar rail at the top of the body.
  /// Suppressed when the sheet is at HALF / PEEK so the map-mode list is just
  /// events.
  final bool includeJoinedClubsRail;

  /// Whether to render the club directory section below the events. Hidden
  /// in map snap states for the same reason as [includeJoinedClubsRail].
  final bool includeClubDirectory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelAsync = ref.watch(clubsListViewModelProvider);
    final city = ref.watch(selectedClubCityProvider);
    final query = ref.watch(clubSearchQueryProvider).trim();
    final filters = ref.watch(clubBrowseFiltersProvider);
    final sourceClubCount =
        ref.watch(exploreSourceClubsProvider).asData?.value.length ?? 0;
    final hasSourceClubs = sourceClubCount > 0;

    return switch (viewModelAsync) {
      AsyncLoading() => const SliverToBoxAdapter(
        child: Padding(
          padding: CatchInsets.pageBody,
          child: _ClubDirectorySkeletonList(),
        ),
      ),
      AsyncError(:final error) => CatchSliverErrorState.fromError(
        error,
        context: AppErrorContext.club,
        onRetry: () {
          ref.invalidate(clubsListViewModelProvider);
          ref.invalidate(exploreSourceClubsProvider);
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
                child: ClubsListBody(
                  viewModel: value,
                  includeJoinedClubsRail: includeJoinedClubsRail,
                  includeClubDirectory: includeClubDirectory,
                ),
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
      icon: Icon(CatchIcons.closeRounded),
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
        gapH14,
        _ClubDirectorySkeletonCard(),
        gapH14,
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
          CatchSkeleton.card(),
          Padding(
            padding: CatchInsets.tileContentCompact,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CatchSkeleton.text(
                  width: CatchLayout.clubDirectorySkeletonTitleWidth,
                ),
                gapH8,
                CatchSkeleton.text(
                  width: CatchLayout.clubDirectorySkeletonSubtitleWidth,
                ),
                gapH12,
                Row(
                  children: [
                    CatchSkeleton.card(
                      width: CatchLayout.clubDirectorySkeletonShortChipWidth,
                      height: CatchSpacing.s6,
                    ),
                    gapW8,
                    CatchSkeleton.card(
                      width: CatchLayout.clubDirectorySkeletonLongChipWidth,
                      height: CatchSpacing.s6,
                    ),
                  ],
                ),
                gapH12,
                SizedBox(
                  height: CatchStroke.hairline,
                  child: ColoredBox(color: t.line),
                ),
                gapH12,
                Row(
                  children: [
                    CatchSkeleton.circle(size: CatchIcon.md),
                    gapW8,
                    Expanded(
                      child: CatchSkeleton.text(
                        width: CatchLayout.clubDirectorySkeletonFooterWidth,
                      ),
                    ),
                    gapW12,
                    CatchSkeleton.card(
                      width: CatchLayout.clubDirectorySkeletonActionWidth,
                      height: CatchSpacing.s9,
                    ),
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
