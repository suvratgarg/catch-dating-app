import 'package:catch_dating_app/clubs/presentation/detail/club_membership_controller.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_mutation_error_listener.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_body.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreList extends ConsumerWidget {
  const ExploreList({
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
    final viewModelAsync = ref.watch(exploreViewModelProvider);
    final city = ref.watch(selectedExploreCityProvider);
    final query = ref.watch(exploreSearchQueryProvider).trim();
    final filters = ref.watch(exploreFiltersProvider);

    return switch (viewModelAsync) {
      AsyncLoading() => SliverToBoxAdapter(
        child: Padding(
          padding: CatchInsets.pageBody,
          child: _buildClubDirectorySkeletonList(),
        ),
      ),
      AsyncError(:final error) => CatchSliverErrorState.fromError(
        error,
        context: AppErrorContext.explore,
        onRetry: () {
          ref.invalidate(exploreViewModelProvider);
          ref.invalidate(exploreSourceClubsProvider);
        },
      ),
      AsyncData(:final value) =>
        value.isEmpty
            ? SliverFillRemaining(
                child: _buildEmptyState(
                  ref,
                  cityLabel: city.label,
                  hasSearch: query.isNotEmpty,
                  filters: filters,
                ),
              )
            : CatchMutationErrorListener(
                mutation: ClubMembershipController.joinMutation,
                child: ExploreBody(
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
    required bool hasSearch,
    required ExploreFilterSelection filters,
  }) {
    final hasFilters = filters.hasActiveFilters;
    if (hasSearch && hasFilters) {
      return ExploreEmptyState.noFilteredSearchResults(
        action: _clearAction(ref, clearSearch: true, clearFilters: true),
      );
    }
    if (hasSearch) {
      return ExploreEmptyState.noSearchResults(
        hasFilters: false,
        action: _clearAction(ref, clearSearch: true, clearFilters: false),
      );
    }
    if (hasFilters) {
      return ExploreEmptyState.noFilterResults(
        action: _clearAction(ref, clearSearch: false, clearFilters: true),
      );
    }
    return ExploreEmptyState(cityLabel: cityLabel);
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
          ref.read(exploreSearchQueryProvider.notifier).clear();
        }
        if (clearFilters) {
          ref.read(exploreFiltersProvider.notifier).clear();
        }
      },
      variant: CatchButtonVariant.secondary,
      icon: Icon(CatchIcons.closeRounded),
    );
  }
}

Widget _buildClubDirectorySkeletonList() {
  return Column(
    children: [
      _buildClubDirectorySkeletonCard(),
      gapH14,
      _buildClubDirectorySkeletonCard(),
      gapH14,
      _buildClubDirectorySkeletonCard(),
    ],
  );
}

Widget _buildClubDirectorySkeletonCard() {
  return Builder(
    builder: (context) {
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
    },
  );
}
