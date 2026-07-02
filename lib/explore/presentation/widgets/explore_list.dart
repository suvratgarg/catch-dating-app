import 'package:catch_dating_app/clubs/clubs.dart'
    show ClubMembershipController;
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_mutation_error_listener.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/explore/presentation/explore_screen.dart';
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

  final bool includeJoinedClubsRail;
  final bool includeClubDirectory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelAsync = ref.watch(exploreViewModelProvider);
    final city = ref.watch(selectedExploreCityProvider);
    final query = ref.watch(exploreSearchQueryProvider).trim();
    final filters = ref.watch(exploreFiltersProvider);

    return switch (viewModelAsync) {
      AsyncLoading() => const SliverToBoxAdapter(
        child: Padding(
          padding: CatchInsets.pageBody,
          child: ClubDirectorySkeletonList(),
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
                child: ExploreListEmptyState(
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
}

class ExploreListEmptyState extends ConsumerWidget {
  const ExploreListEmptyState({
    super.key,
    required this.cityLabel,
    required this.hasSearch,
    required this.filters,
  });

  final String cityLabel;
  final bool hasSearch;
  final ExploreFilterSelection filters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasFilters = filters.hasActiveFilters;
    if (hasSearch && hasFilters) {
      return ExploreEmptyState.noFilteredSearchResults(
        action: ExploreClearAction(
          clearSearch: true,
          clearFilters: true,
          icon: CatchIcons.closeRounded,
          onClearSearch: () =>
              ref.read(exploreSearchQueryProvider.notifier).clear(),
          onClearFilters: () =>
              ref.read(exploreFiltersProvider.notifier).clear(),
        ),
      );
    }
    if (hasSearch) {
      return ExploreEmptyState.noSearchResults(
        hasFilters: false,
        action: ExploreClearAction(
          clearSearch: true,
          clearFilters: false,
          icon: CatchIcons.closeRounded,
          onClearSearch: () =>
              ref.read(exploreSearchQueryProvider.notifier).clear(),
        ),
      );
    }
    if (hasFilters) {
      return ExploreEmptyState.noFilterResults(
        action: ExploreClearAction(
          clearSearch: false,
          clearFilters: true,
          icon: CatchIcons.closeRounded,
          onClearFilters: () =>
              ref.read(exploreFiltersProvider.notifier).clear(),
        ),
      );
    }
    return ExploreEmptyState(cityLabel: cityLabel);
  }
}

class ClubDirectorySkeletonList extends StatelessWidget {
  const ClubDirectorySkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ClubDirectorySkeletonCard(),
        gapH14,
        ClubDirectorySkeletonCard(),
        gapH14,
        ClubDirectorySkeletonCard(),
      ],
    );
  }
}

class ClubDirectorySkeletonCard extends StatelessWidget {
  const ClubDirectorySkeletonCard({super.key});

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
