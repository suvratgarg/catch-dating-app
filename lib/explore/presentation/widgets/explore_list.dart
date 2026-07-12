import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_screen.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_body.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
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
    final viewModelAsync = ref.watch(exploreClubsViewModelProvider);
    final city = ref.watch(selectedExploreCityProvider);
    final query = ref.watch(exploreSearchQueryProvider).trim();
    final filters = ref.watch(exploreFiltersProvider);
    final feedAsync = ref.watch(exploreFeedViewModelProvider);

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
          ref.invalidate(exploreClubsViewModelProvider);
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
            : Builder(
                builder: (context) => SliverMainAxisGroup(
                  slivers: buildExploreBodySlivers(
                    context: context,
                    feedAsync: feedAsync,
                    clubsViewModel: value,
                    filters: filters,
                    searchQuery: query,
                    onRetryFeed: () =>
                        ref.invalidate(exploreFeedViewModelProvider),
                    onRetryClubs: () {
                      ref.invalidate(exploreClubsViewModelProvider);
                      ref.invalidate(exploreSourceClubsProvider);
                    },
                    onClearSearch: () =>
                        ref.read(exploreSearchQueryProvider.notifier).clear(),
                    onClearFilters: () =>
                        ref.read(exploreFiltersProvider.notifier).clear(),
                    onSetTimeFilter: (filter) => ref
                        .read(exploreFiltersProvider.notifier)
                        .setTimeFilter(filter),
                    onActivitySelected: (activityKind) => ref
                        .read(exploreFiltersProvider.notifier)
                        .toggleActivityTag(activityKind.name),
                    onEventSelected: (_, _) {},
                    onExternalEventOpened: (_) {},
                    includeJoinedClubsRail: includeJoinedClubsRail,
                    includeClubDirectory: includeClubDirectory,
                    pinnedExploreDayHeaders: false,
                  ),
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
      return Center(
        child: Padding(
          padding: CatchInsets.contentRelaxed,
          child: CatchEmptyState(
            icon: CatchIcons.groupsOutlined,
            title: context.l10n.exploreExploreListTitleNoClubsMatchThis,
            message: context.l10n.exploreExploreListMessageClearTheSearchOr,
            action: ExploreClearAction(
              clearSearch: true,
              clearFilters: true,
              icon: CatchIcons.closeRounded,
              onClearSearch: () =>
                  ref.read(exploreSearchQueryProvider.notifier).clear(),
              onClearFilters: () =>
                  ref.read(exploreFiltersProvider.notifier).clear(),
            ),
          ),
        ),
      );
    }
    if (hasSearch) {
      return Center(
        child: Padding(
          padding: CatchInsets.contentRelaxed,
          child: CatchEmptyState(
            icon: CatchIcons.groupsOutlined,
            title: context.l10n.exploreExploreListTitleNoClubsMatchThis,
            message: context
                .l10n
                .exploreExploreListMessageTryAnotherClubNeighborhood,
            action: ExploreClearAction(
              clearSearch: true,
              clearFilters: false,
              icon: CatchIcons.closeRounded,
              onClearSearch: () =>
                  ref.read(exploreSearchQueryProvider.notifier).clear(),
            ),
          ),
        ),
      );
    }
    if (hasFilters) {
      return Center(
        child: Padding(
          padding: CatchInsets.contentRelaxed,
          child: CatchEmptyState(
            icon: CatchIcons.groupsOutlined,
            title: context.l10n.exploreExploreListTitleNoClubsMatchThese,
            message: context.l10n.exploreExploreListMessageClearOneOrMore,
            action: ExploreClearAction(
              clearSearch: false,
              clearFilters: true,
              icon: CatchIcons.closeRounded,
              onClearFilters: () =>
                  ref.read(exploreFiltersProvider.notifier).clear(),
            ),
          ),
        ),
      );
    }
    return Center(
      child: Padding(
        padding: CatchInsets.contentRelaxed,
        child: CatchEmptyState(
          icon: CatchIcons.groupsOutlined,
          title: context.l10n.exploreExploreListTitleNoClubsInCitylabel(
            cityLabel: cityLabel,
          ),
          message: context.l10n.exploreExploreListMessageTryAnotherCityFrom,
        ),
      ),
    );
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
      elevation: CatchSurfaceElevation.card,
      radius: CatchRadius.md,
      padding: CatchInsets.tileContentCompact,
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(
                CatchLayout.clubPolaroidRadius,
              ),
              border: Border.all(color: t.line),
            ),
            child: Padding(
              padding: const EdgeInsets.all(CatchSpacing.micro3),
              child: CatchSkeleton.card(
                width: CatchSpacing.s16,
                height: CatchSpacing.s16,
              ),
            ),
          ),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CatchSkeleton.text(
                  width: CatchLayout.clubDirectorySkeletonTitleWidth,
                ),
                gapH8,
                CatchSkeleton.card(
                  width: CatchLayout.clubDirectorySkeletonShortChipWidth,
                  height: CatchSpacing.s6,
                ),
                gapH6,
                CatchSkeleton.text(
                  width: CatchLayout.clubDirectorySkeletonSubtitleWidth,
                ),
              ],
            ),
          ),
          gapW12,
          CatchSkeleton.card(
            width: CatchLayout.clubDirectorySkeletonActionWidth,
            height: CatchSpacing.s9,
          ),
        ],
      ),
    );
  }
}
