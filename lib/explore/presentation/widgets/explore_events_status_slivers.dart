import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/explore/presentation/explore_screen_state.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:flutter/material.dart';

const EdgeInsets exploreEventsLoadingPadding = EdgeInsets.fromLTRB(
  CatchSpacing.s5,
  CatchSpacing.s3,
  CatchSpacing.s5,
  CatchSpacing.s3,
);

class ExploreEventsLoadingSliver extends StatelessWidget {
  const ExploreEventsLoadingSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: exploreEventsLoadingPadding,
        child: CatchSurface(
          clipBehavior: Clip.antiAlias,
          borderColor: t.line,
          elevation: CatchSurfaceElevation.card,
          child: CatchSkeleton.card(
            height: CatchLayout.exploreEventsSkeletonHeight,
          ),
        ),
      ),
    );
  }
}

class ExploreEventsEmptySliver extends StatelessWidget {
  const ExploreEventsEmptySliver({
    super.key,
    required this.state,
    this.onClearSearch,
    this.onClearFilters,
    this.onSetTimeFilter,
  });

  final ExploreEventsEmptyState state;
  final VoidCallback? onClearSearch;
  final VoidCallback? onClearFilters;
  final ValueChanged<ExploreTimeFilter>? onSetTimeFilter;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: CatchInsets.pageHeaderBody,
        child: CatchEmptyState(
          icon: CatchIcons.eventAvailable,
          title: state.title,
          message: state.message,
          action: CatchButton(
            label: state.actionLabel,
            icon: Icon(state.actionIcon),
            variant: CatchButtonVariant.secondary,
            onPressed: _handleAction,
          ),
          layout: CatchEmptyStateLayout.inline,
        ),
      ),
    );
  }

  void _handleAction() {
    if (state.clearSearch) onClearSearch?.call();
    final nextFilter = state.nextFilter;
    if (nextFilter != null) {
      onSetTimeFilter?.call(nextFilter);
      return;
    }
    if (state.clearFilters) onClearFilters?.call();
  }
}
