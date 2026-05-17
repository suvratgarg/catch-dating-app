import 'package:catch_dating_app/clubs/presentation/club_name_lookup.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_sliver_header.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/event_focus_rail.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/quick_actions.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/recommendations.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/stride_card.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/host_tools/presentation/host_event_tools.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
    final day = DateFormat('EEEE').format(DateTime.now());
    return '$day · ${cityLabel ?? 'Mumbai'}';
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
            DashboardFullSliverBody(viewModel: viewModel, user: user),
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
  });

  final DashboardFullViewModel viewModel;
  final UserProfile user;

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

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        CatchSpacing.s1,
        CatchSpacing.s5,
        CatchSpacing.s6,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          if (focusEvents.isNotEmpty) ...[
            EventFocusRail(
              upcomingEvents: viewModel.upcomingEvents,
              arrivalAction: viewModel.arrivalAction,
              activeSwipeEvent: viewModel.activeSwipeEvent,
              pendingReviewEvent: viewModel.pendingReviewEvent,
              reviewer: user,
              clubNameBuilder: (event) => clubNames?[event.clubId],
            ),
            gapH18,
          ],
          if (viewModel.hostEventTools.isNotEmpty) ...[
            HostToolsRail(tools: viewModel.hostEventTools),
            gapH18,
          ],
          DashboardStrideSection(section: viewModel.weeklyActivitySection),
          gapH18,
          const QuickActions(),
          ..._buildRecommendedEventsSection(
            recommendationsSection: viewModel.recommendationsSection,
          ),
        ]),
      ),
    );
  }

  List<Widget> _buildRecommendedEventsSection({
    required DashboardSectionModel<List<DashboardEventRecommendation>>
    recommendationsSection,
  }) {
    if (recommendationsSection.isLoading) {
      return const [
        gapH18,
        _DashboardSectionStateCard(
          message: 'Loading recommended events...',
          isLoading: true,
        ),
      ];
    }

    if (recommendationsSection.hasError) {
      return const [
        gapH18,
        _DashboardSectionStateCard(
          message: 'Unable to load recommended events.',
        ),
      ];
    }

    final recommendations =
        recommendationsSection.data ?? const <DashboardEventRecommendation>[];
    return recommendations.isEmpty
        ? const []
        : [gapH18, Recommendations(recommendations: recommendations)];
  }
}

class HostToolsRail extends StatelessWidget {
  const HostToolsRail({super.key, required this.tools});

  final List<DashboardHostEventTool> tools;

  @override
  Widget build(BuildContext context) {
    return HostEventToolsCarousel(
      tools: tools
          .map(
            (tool) => HostEventToolItem(
              event: tool.event,
              attendanceState: _hostAttendanceState(tool.attendanceState),
            ),
          )
          .toList(growable: false),
      onManageEvent: (event) => context.pushNamed(
        Routes.hostEventManageScreen.name,
        pathParameters: {'clubId': event.clubId, 'eventId': event.id},
      ),
      onTakeAttendance: (event) => context.pushNamed(
        Routes.attendanceSheet.name,
        pathParameters: {'clubId': event.clubId, 'eventId': event.id},
      ),
    );
  }
}

HostEventAttendanceState _hostAttendanceState(
  DashboardHostAttendanceState state,
) {
  return switch (state) {
    DashboardHostAttendanceState.open => HostEventAttendanceState.open,
    DashboardHostAttendanceState.opensLater =>
      HostEventAttendanceState.opensLater,
    DashboardHostAttendanceState.closed => HostEventAttendanceState.closed,
  };
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
      padding: const EdgeInsets.all(CatchSpacing.s4),
      borderColor: t.line,
      child: Row(
        children: [
          if (isLoading) ...[
            const SizedBox(
              width: 18,
              height: 18,
              child: CatchLoadingIndicator(strokeWidth: 2),
            ),
          ] else ...[
            Icon(Icons.error_outline_rounded, color: t.primary, size: 18),
          ],
          gapW10,
          Expanded(
            child: Text(
              message,
              style: CatchTextStyles.bodyS(context, color: t.ink2),
            ),
          ),
        ],
      ),
    );
  }
}
