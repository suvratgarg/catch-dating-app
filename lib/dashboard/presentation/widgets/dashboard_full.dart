import 'package:catch_dating_app/clubs/presentation/club_name_lookup.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_clubs_rail.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_sliver_header.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/event_focus_rail.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/quick_actions.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/recommendations.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/stride_card.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardFull extends ConsumerWidget {
  const DashboardFull({
    super.key,
    required this.user,
    required this.signedUpEvents,
    required this.followedClubIds,
  });

  static const scrollViewKey = ValueKey('dashboard-full-scroll-view');

  final UserProfile user;
  final List<Event> signedUpEvents;
  final List<String> followedClubIds;

  static String greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }

  static String dayCity(String? cityLabel) {
    final day = AppTimeFormatters.longWeekday(DateTime.now());
    return '$day · ${cityLabel ?? defaultCityDataForMarket().label}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final firstName = user.greetingDisplayName;
    final viewModel = ref.watch(
      dashboardFullViewModelProvider(
        signedUpEvents: signedUpEvents,
        user: user,
        uid: user.uid,
        followedClubIds: followedClubIds,
      ),
    );

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: CustomScrollView(
          key: scrollViewKey,
          slivers: [
            ...DashboardSliverHeader(
              eyebrow: dayCity(cityLabel(user.city)).toUpperCase(),
              title: '${greeting()}, $firstName',
            ).buildSlivers(context),
            DashboardFullSliverBody(
              viewModel: viewModel,
              user: user,
              followedClubIds: followedClubIds,
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardFullSliverBody extends ConsumerWidget {
  const DashboardFullSliverBody({
    super.key,
    required this.viewModel,
    required this.user,
    this.followedClubIds = const <String>[],
  });

  final DashboardFullViewModel viewModel;
  final UserProfile user;
  final List<String> followedClubIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusEvents = [
      ...viewModel.upcomingEvents,
      if (viewModel.activeSwipeEvent != null) viewModel.activeSwipeEvent!,
      if (viewModel.pendingReviewEvent != null) viewModel.pendingReviewEvent!,
    ];
    final clubNamesAsync = ref.watch(
      clubNameLookupProvider(
        ClubNameLookupQuery(focusEvents.map((event) => event.clubId)),
      ),
    );
    final clubNames = clubNamesAsync.asData?.value;

    return SliverToBoxAdapter(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: CatchLayout.maxContentWidth,
          ),
          child: CatchSectionStack(
            padding: CatchInsets.pageBodyUnderHeader,
            gap: CatchSpacing.micro18,
            children: [
              if (focusEvents.isNotEmpty)
                EventFocusRail(
                  upcomingEvents: viewModel.upcomingEvents,
                  arrivalAction: viewModel.arrivalAction,
                  activeSwipeEvent: viewModel.activeSwipeEvent,
                  pendingReviewEvent: viewModel.pendingReviewEvent,
                  reviewer: user,
                  clubNameBuilder: (event) => clubNames?[event.clubId],
                ),
              DashboardStrideSection(section: viewModel.weeklyActivitySection),
              const QuickActions(),
              if (followedClubIds.isNotEmpty)
                DashboardClubsRail(clubIds: followedClubIds),
              ..._buildRecommendedEventsSection(
                recommendationsSection: viewModel.recommendationsSection,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRecommendedEventsSection({
    required DashboardSectionModel<List<DashboardEventRecommendation>>
    recommendationsSection,
  }) {
    if (recommendationsSection.isLoading) {
      return const [
        _DashboardSectionStateCard(
          message: 'Loading recommended events...',
          isLoading: true,
        ),
      ];
    }

    if (recommendationsSection.hasError) {
      return const [
        _DashboardSectionStateCard(
          message: 'Unable to load recommended events.',
        ),
      ];
    }

    final recommendations =
        recommendationsSection.data ?? const <DashboardEventRecommendation>[];
    return recommendations.isEmpty
        ? const []
        : [Recommendations(recommendations: recommendations)];
  }
}

class _DashboardSectionStateCard extends StatelessWidget {
  const _DashboardSectionStateCard({
    required this.message,
    this.isLoading = false,
  });

  final String message;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      padding: CatchInsets.content,
      borderColor: t.line,
      child: Row(
        children: [
          if (isLoading) ...[
            const SizedBox.square(
              dimension: CatchIcon.md,
              child: CatchLoadingIndicator(strokeWidth: 2),
            ),
          ] else ...[
            Icon(
              CatchIcons.errorOutlineRounded,
              color: t.primary,
              size: CatchIcon.md,
            ),
          ],
          gapW10,
          Expanded(
            child: Text(
              message,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
          ),
        ],
      ),
    );
  }
}
