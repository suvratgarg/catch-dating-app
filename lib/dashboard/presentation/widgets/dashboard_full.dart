import 'package:catch_dating_app/clubs/presentation/club_name_lookup.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/dashboard_sliver_header.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/event_focus_rail.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/quick_actions.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/recommendations.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/stride_card.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_event_tools.dart';
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

enum _HostToolsBucket { active, past }

class HostToolsRail extends StatefulWidget {
  const HostToolsRail({super.key, required this.tools});

  final List<DashboardHostEventTool> tools;

  @override
  State<HostToolsRail> createState() => _HostToolsRailState();
}

class _HostToolsRailState extends State<HostToolsRail> {
  var _selectedBucket = _HostToolsBucket.active;

  @override
  void didUpdateWidget(covariant HostToolsRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    _normalizeSelectedBucket();
  }

  @override
  void initState() {
    super.initState();
    _normalizeSelectedBucket();
  }

  void _normalizeSelectedBucket() {
    final active = widget.tools.where((tool) => !tool.isPast).toList();
    final past = widget.tools.where((tool) => tool.isPast).toList();
    if (_selectedBucket == _HostToolsBucket.active && active.isEmpty) {
      _selectedBucket = _HostToolsBucket.past;
    }
    if (_selectedBucket == _HostToolsBucket.past && past.isEmpty) {
      _selectedBucket = _HostToolsBucket.active;
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.tools.where((tool) => !tool.isPast).toList();
    final past = widget.tools.where((tool) => tool.isPast).toList();
    final hasBothBuckets = active.isNotEmpty && past.isNotEmpty;
    final selectedTools = switch (_selectedBucket) {
      _HostToolsBucket.active => active,
      _HostToolsBucket.past => past,
    };

    if (!hasBothBuckets) {
      return _HostToolsCarouselAdapter(tools: widget.tools);
    }

    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Host operations', style: CatchTextStyles.titleM(context)),
        gapH8,
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          children: [
            CatchChip(
              label: 'Active ${active.length}',
              active: _selectedBucket == _HostToolsBucket.active,
              icon: const Icon(Icons.tune_rounded),
              onTap: () =>
                  setState(() => _selectedBucket = _HostToolsBucket.active),
            ),
            CatchChip(
              label: 'Past ${past.length}',
              active: _selectedBucket == _HostToolsBucket.past,
              icon: const Icon(Icons.history_rounded),
              onTap: () =>
                  setState(() => _selectedBucket = _HostToolsBucket.past),
            ),
          ],
        ),
        gapH8,
        Text(
          _selectedBucket == _HostToolsBucket.active
              ? 'Current host tasks stay first; past events remain available for corrections.'
              : 'Past hosted events stay reachable for missed attendance and follow-up operations.',
          style: CatchTextStyles.bodyS(context, color: t.ink2),
        ),
        gapH12,
        _HostToolsCarouselAdapter(tools: selectedTools),
      ],
    );
  }
}

class _HostToolsCarouselAdapter extends StatelessWidget {
  const _HostToolsCarouselAdapter({required this.tools});

  final List<DashboardHostEventTool> tools;

  @override
  Widget build(BuildContext context) {
    return HostEventToolsCarousel(
      tools: tools
          .map(
            (tool) => HostEventToolItem(
              event: tool.event,
              attendanceState: tool.attendanceState,
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
