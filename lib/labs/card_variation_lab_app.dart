import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_hero_app_bar.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_schedule_section.dart';
import 'package:catch_dating_app/clubs/presentation/list/clubs_list_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/list/explore_feed_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/club_avatar_rail.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/club_list_tile.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/explore_events_section.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/explore_peek_rail.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_event_activity_cards.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/activity_section.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/event_focus_rail.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/recommend_card.dart';
import 'package:catch_dating_app/event_success/domain/event_success_coach.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_feature_blocks.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_constraints.dart';
import 'package:catch_dating_app/events/presentation/event_arrival_action.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/event_map_view_model.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_agenda_list.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_hero_app_bar.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_overview_section.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_photo_header.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_pins_map.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_stats_grid.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tiles.dart';
import 'package:catch_dating_app/events/presentation/widgets/map_pin_tile.dart';
import 'package:catch_dating_app/events/presentation/widgets/requirements_row.dart';
import 'package:catch_dating_app/events/presentation/widgets/when_where_card.dart';
import 'package:catch_dating_app/hosts/domain/host_attendance_window.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_club_tools.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_event_tools.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/notifications/data/activity_notification_repository.dart';
import 'package:catch_dating_app/notifications/domain/activity_notification.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_section.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages, implementation_imports
import 'package:riverpod/src/framework.dart' show Override;

void main() {
  runApp(const ProviderScope(child: CardVariationLabApp()));
}

class CardVariationLabApp extends StatelessWidget {
  const CardVariationLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catch Card Variation Lab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const _CardVariationLabScreen(),
    );
  }
}

class _CardVariationLabScreen extends StatelessWidget {
  const _CardVariationLabScreen();

  @override
  Widget build(BuildContext context) {
    final fixtures = _LabFixtures();
    final t = CatchTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: const CatchTopBar(title: 'Club + event card lab', border: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            CatchSpacing.s5,
            CatchSpacing.s4,
            CatchSpacing.s5,
            CatchSpacing.s8,
          ),
          children: [
            _LabIntro(fixtures: fixtures),
            gapH24,
            _LabSection(
              title: 'Explore Feed And Map',
              description:
                  'These are rendered through the public Explore sliver builders, so the private mixed event and club cards are still the actual production widgets.',
              children: [
                _LabSample(
                  title: 'Explore mixed feed',
                  source:
                      'buildExploreEventsSlivers -> private Explore feed row, event spotlight, club spotlight, club row',
                  height: 720,
                  child: _ExploreFeedFixture(fixtures: fixtures),
                ),
                _LabSample(
                  title: 'Explore selected map lead - ticket',
                  source:
                      'buildExploreMapSheetLeadSlivers -> selected non-spotlight CatchEventTicketCard',
                  height: 430,
                  child: _ExploreMapLeadFixture(
                    fixtures: fixtures,
                    mode: ExploreMapSheetLeadMode.selectedEvent,
                    selectedEventId: fixtures.dinner.id,
                  ),
                ),
                _LabSample(
                  title: 'Explore selected map lead - spotlight',
                  source:
                      'buildExploreMapSheetLeadSlivers -> selected featured CatchEventSpotlightCard',
                  height: 360,
                  child: _ExploreMapLeadFixture(
                    fixtures: fixtures,
                    mode: ExploreMapSheetLeadMode.selectedEvent,
                    selectedEventId: fixtures.socialRun.id,
                  ),
                ),
                _LabSample(
                  title: 'Explore nearby rail',
                  source:
                      'buildExploreMapSheetLeadSlivers -> CatchEventTicketCard rail',
                  height: 440,
                  maxWidth: 620,
                  child: _ExploreMapLeadFixture(
                    fixtures: fixtures,
                    mode: ExploreMapSheetLeadMode.nearbyRail,
                  ),
                ),
                _LabSample(
                  title: 'Map pin placeholder',
                  source: 'EventPinsMap(enableNetworkTiles: false)',
                  height: 260,
                  child: EventPinsMap(
                    items: fixtures.mapItems,
                    initialCenter: fixtures.mapCenter,
                    selectedEventId: fixtures.socialRun.id,
                    selectedEventCenter: fixtures.mapCenter,
                    enableNetworkTiles: false,
                    distanceRingRadiusKm: 5,
                    onEventSelected: (_) {},
                  ),
                ),
              ],
            ),
            _LabSection(
              title: 'Event Discovery Cards',
              description:
                  'Core event cards used by dashboard, Explore, calendar, club detail schedules, and map surfaces.',
              children: [
                _LabSample(
                  title: 'Dashboard recommendation',
                  source: 'RecommendCard.fromEvent -> CatchEventTicketCard',
                  maxWidth: 360,
                  child: RecommendCard.fromEvent(
                    event: fixtures.socialRun,
                    width: 340,
                  ),
                ),
                _LabSample(
                  title: 'Ticket card primitive',
                  source: 'CatchEventTicketCard',
                  maxWidth: 360,
                  child: CatchEventTicketCard(
                    width: 340,
                    title: fixtures.socialRun.title,
                    subtitle:
                        '${fixtures.runClub.name} / ${fixtures.socialRun.locationName}',
                    timeLabel: EventFormatters.time(
                      fixtures.socialRun.startTime,
                    ),
                    countdownLabel: 'Thu',
                    priceLabel: fixtures.socialRun.isFree ? 'Free' : '₹799',
                    capacityLabel:
                        '${fixtures.socialRun.activitySummaryLabel} · ${fixtures.socialRun.signedUpCount} going · ${fixtures.socialRun.spotsRemaining} left',
                    activityKind: fixtures.socialRun.activityKind,
                    statusLabel: 'Matches your 5 km preference',
                    clockTime: TimeOfDay.fromDateTime(
                      fixtures.socialRun.startTime,
                    ),
                  ),
                ),
                _LabSample(
                  title: 'Spotlight event',
                  source: 'CatchEventSpotlightCard',
                  maxWidth: 360,
                  child: CatchEventSpotlightCard(
                    title: fixtures.dinner.title,
                    supportingLabel:
                        '${fixtures.dinnerClub.name} · ${fixtures.dinner.locationName}',
                    timeLabel: EventFormatters.time(fixtures.dinner.startTime),
                    countdownLabel: 'Tonight',
                    priceLabel: '₹1,200',
                    capacityLabel:
                        '${fixtures.dinner.signedUpCount}/${fixtures.dinner.capacityLimit} going',
                    activityKind: fixtures.dinner.activityKind,
                    kicker: "Tonight's table",
                  ),
                ),
                _LabSample(
                  title: 'Date rail event row',
                  source: 'EventDateRailCard',
                  maxWidth: 430,
                  child: EventDateRailCard(
                    event: fixtures.socialRun,
                    kicker: fixtures.runClub.name,
                    supportingLabel:
                        '${fixtures.socialRun.activitySummaryLabel} · ${fixtures.socialRun.locationName}',
                    priceLabel: 'Free',
                    statusLabel: "You're in",
                  ),
                ),
                _LabSample(
                  title: 'Compact event row',
                  source: 'EventCompactRow',
                  maxWidth: 430,
                  child: EventCompactRow(
                    event: fixtures.walk,
                    statusLabel: 'Saved',
                    onTap: () {},
                  ),
                ),
                _LabSample(
                  title: 'Calendar date markers',
                  source: 'EventDateMarker',
                  maxWidth: 430,
                  child: Row(
                    children: [
                      Expanded(
                        child: EventDateMarker(
                          date: fixtures.socialRun.startTime,
                          active: true,
                          hasEvent: true,
                          onTap: () {},
                        ),
                      ),
                      gapW8,
                      Expanded(
                        child: EventDateMarker(
                          date: fixtures.dinner.startTime,
                          layout: EventDateMarkerLayout.monthGrid,
                          active: false,
                          today: true,
                          hasEvent: true,
                          onTap: () {},
                        ),
                      ),
                      gapW8,
                      Expanded(
                        child: EventDateMarker(
                          date: fixtures.walk.startTime,
                          layout: EventDateMarkerLayout.monthGrid,
                          active: false,
                          enabled: false,
                          hasEvent: true,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ),
                _LabSample(
                  title: 'Agenda tile',
                  source: 'EventAgendaTile',
                  maxWidth: 430,
                  child: EventAgendaTile(
                    data: fixtures.joinedTileData,
                    showClubName: true,
                    badgeLabel: 'JOINED',
                  ),
                ),
                _LabSample(
                  title: 'Agenda list',
                  source: 'EventAgendaList / EventAgendaSliverList',
                  height: 430,
                  maxWidth: 500,
                  child: EventAgendaList(
                    events: fixtures.upcomingEvents,
                    showClubName: true,
                    clubNameBuilder: fixtures.clubNameFor,
                    badgeLabelBuilder: (event) =>
                        event.id == fixtures.dinner.id ? 'SAVED' : 'JOINED',
                    statusBuilder: (event) => event.id == fixtures.dinner.id
                        ? EventTileStatus.saved
                        : EventTileStatus.joined,
                    today: fixtures.today,
                    preserveInputOrder: true,
                  ),
                ),
              ],
            ),
            _LabSection(
              title: 'Event Detail',
              description:
                  'Header, overview, location, stats, requirements, and map-location controls used around event detail and creation flows.',
              children: [
                _LabSample(
                  title: 'Event detail hero app bar',
                  source: 'EventDetailHeroAppBar',
                  height: 360,
                  child: _SliverPreview(
                    slivers: [
                      EventDetailHeroAppBar(
                        event: fixtures.heroEvent,
                        isSaved: true,
                        savePending: false,
                        onBack: () {},
                        onShare: (_) {},
                        onToggleSaved: () {},
                        showAddToCalendar: true,
                        onAddToCalendar: (_) {},
                      ),
                    ],
                  ),
                ),
                _LabSample(
                  title: 'Event photo header',
                  source: 'EventPhotoHeader',
                  height: 260,
                  maxWidth: 430,
                  child: EventPhotoHeader(event: fixtures.photoHeaderEvent),
                ),
                _LabSample(
                  title: 'Event overview section',
                  source: 'EventDetailOverviewSection',
                  maxWidth: 500,
                  child: EventDetailOverviewSection(
                    event: fixtures.socialRun,
                    onLocationTap: () {},
                  ),
                ),
                _LabSample(
                  title: 'When and where',
                  source: 'WhenWhereCard',
                  maxWidth: 430,
                  child: WhenWhereCard(
                    event: fixtures.socialRun,
                    onLocationTap: () {},
                  ),
                ),
                _LabSample(
                  title: 'Stats strip',
                  source: 'EventStatsGrid',
                  maxWidth: 430,
                  child: EventStatsGrid(event: fixtures.socialRun),
                ),
                _LabSample(
                  title: 'Requirements',
                  source: 'RequirementsRow',
                  maxWidth: 430,
                  child: RequirementsRow(event: fixtures.socialRun),
                ),
                _LabSample(
                  title: 'Map pin selector',
                  source: 'MapPinTile',
                  maxWidth: 430,
                  child: MapPinTile(
                    startingPoint: fixtures.mapCenter,
                    selectedLabel: fixtures.socialRun.locationName,
                    onTap: () {},
                  ),
                ),
              ],
            ),
            _LabSection(
              title: 'Club Discovery And Detail',
              description:
                  'Club directory, avatar rail, cover fallback, detail hero, schedule, and host club management panels.',
              children: [
                _LabSample(
                  title: 'Club directory photo card',
                  source: 'ClubListTile(directory, imageUrl present)',
                  maxWidth: 380,
                  child: ClubListTile(club: fixtures.photoClub, isJoined: true),
                ),
                _LabSample(
                  title: 'Club directory identity card',
                  source: 'ClubListTile(directory, no imageUrl)',
                  maxWidth: 430,
                  child: ClubListTile(club: fixtures.runClub),
                ),
                _LabSample(
                  title: 'Club avatar chip',
                  source: 'ClubListTile(avatarChip)',
                  maxWidth: 140,
                  child: ClubListTile(
                    club: fixtures.sportClub,
                    variant: ClubListTileVariant.avatarChip,
                    showLiveBadge: true,
                  ),
                ),
                _LabSample(
                  title: 'Club avatar rail',
                  source: 'ClubAvatarRail',
                  maxWidth: 520,
                  child: ClubAvatarRail(
                    clubs: fixtures.clubs,
                    showDivider: false,
                    headerPadding: EdgeInsets.zero,
                    listPadding: EdgeInsets.zero,
                  ),
                ),
                _LabSample(
                  title: 'Club detail hero app bar',
                  source: 'ClubHeroAppBar',
                  height: 280,
                  child: _SliverPreview(
                    slivers: [
                      ClubHeroAppBar(
                        club: fixtures.runClub,
                        isHost: true,
                        onShareClub: (_, _) async {},
                      ),
                    ],
                  ),
                ),
                _LabSample(
                  title: 'Club schedule section',
                  source: 'ClubScheduleSection -> EventAgendaSliverList',
                  height: 430,
                  maxWidth: 500,
                  child: _SliverPreview(
                    slivers: [
                      ClubScheduleSection(
                        events: fixtures.upcomingEvents,
                        isHost: true,
                        onEventSelected: (_) {},
                      ),
                    ],
                  ),
                ),
                _LabSample(
                  title: 'Host club management',
                  source: 'HostClubManagementPanel',
                  maxWidth: 430,
                  child: HostClubManagementPanel(
                    club: fixtures.runClub,
                    events: fixtures.upcomingEvents,
                    onEditClub: () {},
                    onCreateEvent: () {},
                  ),
                ),
              ],
            ),
            _LabSection(
              title: 'Dashboard And Host',
              description:
                  'Cards surfaced after someone has booked, hosted, or attended events. Private dashboard activity tiles are rendered through ActivitySection with provider overrides.',
              children: [
                _LabSample(
                  title: 'Activity upcoming event tile',
                  source: 'ActivitySection -> EventCompactRow',
                  maxWidth: 500,
                  child: _ActivitySectionFixture(fixtures: fixtures),
                ),
                _LabSample(
                  title: 'Event focus rail',
                  source: 'EventFocusRail -> EventActionCard',
                  maxWidth: 500,
                  child: EventFocusRail(
                    upcomingEvents: [fixtures.checkInEvent, fixtures.dinner],
                    reviewer: fixtures.viewer,
                    arrivalAction: EventArrivalAction(
                      kind: EventArrivalActionKind.selfCheckIn,
                      event: fixtures.checkInEvent,
                    ),
                    activeSwipeEvent: fixtures.pastEvent,
                    pendingReviewEvent: fixtures.pastEvent,
                    clubNameBuilder: fixtures.clubNameFor,
                  ),
                ),
                _LabSample(
                  title: 'Host event tool card',
                  source: 'HostEventToolCard -> EventActionCard',
                  maxWidth: 430,
                  child: HostEventToolCard(
                    item: HostEventToolItem(
                      event: fixtures.checkInEvent,
                      attendanceState: HostEventAttendanceState.open,
                    ),
                    cardIndex: 0,
                    cardCount: 3,
                    onManageEvent: (_) {},
                    onTakeAttendance: (_) {},
                    onViewReport: (_) {},
                  ),
                ),
                _LabSample(
                  title: 'Host event tools carousel',
                  source: 'HostEventToolsCarousel',
                  maxWidth: 430,
                  child: HostEventToolsCarousel(
                    tools: [
                      HostEventToolItem(
                        event: fixtures.checkInEvent,
                        attendanceState: HostEventAttendanceState.open,
                      ),
                      HostEventToolItem(
                        event: fixtures.dinner,
                        attendanceState: HostEventAttendanceState.opensLater,
                      ),
                      HostEventToolItem(
                        event: fixtures.pastEvent,
                        attendanceState: HostEventAttendanceState.closed,
                      ),
                    ],
                    onManageEvent: (_) {},
                    onTakeAttendance: (_) {},
                    onViewReport: (_) {},
                  ),
                ),
              ],
            ),
            _LabSection(
              title: 'Social And Event Success',
              description:
                  'Post-event review cards plus the public Event Success WIP blocks that already exist in Flutter.',
              children: [
                _LabSample(
                  title: 'Review card',
                  source: 'ReviewCard',
                  maxWidth: 430,
                  child: ReviewCard(
                    review: fixtures.review,
                    isOwn: false,
                    onEdit: () {},
                  ),
                ),
                const _LabSample(
                  title: 'Event Success setup',
                  source: 'EventSuccessHostSetupFlow',
                  maxWidth: 520,
                  child: EventSuccessHostSetupFlow(),
                ),
                const _LabSample(
                  title: 'Event Success live host',
                  source: 'EventSuccessLiveHostMode',
                  maxWidth: 520,
                  child: EventSuccessLiveHostMode(showStepList: false),
                ),
                const _LabSample(
                  title: 'Event Success attendee',
                  source: 'EventSuccessAttendeeCompanionPreview',
                  maxWidth: 520,
                  child: EventSuccessAttendeeCompanionPreview(),
                ),
                _LabSample(
                  title: 'Event Success post-event',
                  source: 'EventSuccessPostEventReport',
                  maxWidth: 520,
                  child: EventSuccessPostEventReport(
                    brief: sampleEventSuccessBrief(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LabIntro extends StatelessWidget {
  const _LabIntro({required this.fixtures});

  final _LabFixtures fixtures;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              CatchBadge(label: 'Flutter only', tone: CatchBadgeTone.brand),
              CatchBadge(label: 'Synthetic data'),
              CatchBadge(label: 'Not routed', tone: CatchBadgeTone.warning),
            ],
          ),
          gapH12,
          Text(
            'This page imports the app widgets directly. The HTML concept lab stays untouched; this is the new WIP surface for checking real club and event card variants before porting design changes.',
            style: CatchTextStyles.bodyLead(context, color: t.ink2),
          ),
          gapH8,
          Text(
            'Launch with: flutter run -d chrome -t lib/labs/card_variation_lab_app.dart',
            style: CatchTextStyles.mono(context, color: t.ink3),
          ),
        ],
      ),
    );
  }
}

class _LabSection extends StatelessWidget {
  const _LabSection({
    required this.title,
    required this.description,
    required this.children,
  });

  final String title;
  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: CatchSpacing.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: CatchTextStyles.titleL(context)),
          gapH6,
          Text(description, style: CatchTextStyles.supporting(context)),
          gapH16,
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1560
                  ? 3
                  : constraints.maxWidth >= 1040
                  ? 2
                  : 1;
              final gap = CatchSpacing.s4;
              final width =
                  (constraints.maxWidth - (gap * (columns - 1))) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final child in children)
                    SizedBox(width: width, child: child),
                ],
              );
            },
          ),
          gapH12,
          Divider(color: t.line, height: 1),
        ],
      ),
    );
  }
}

class _LabSample extends StatelessWidget {
  const _LabSample({
    required this.title,
    required this.source,
    required this.child,
    this.height,
    this.maxWidth = 460,
  });

  final String title;
  final String source;
  final Widget child;
  final double? height;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final preview = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: height == null ? child : SizedBox(height: height, child: child),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface.withValues(alpha: 0.56),
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(CatchRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(CatchSpacing.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: CatchTextStyles.sectionTitle(context)),
            gapH4,
            Text(
              source,
              style: CatchTextStyles.mono(
                context,
                color: t.ink3,
              ).copyWith(fontSize: 11, height: 1.35),
            ),
            gapH14,
            Align(
              alignment: Alignment.topLeft,
              child: IgnorePointer(child: preview),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverPreview extends StatelessWidget {
  const _SliverPreview({required this.slivers});

  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        ...slivers,
        const SliverToBoxAdapter(child: SizedBox(height: CatchSpacing.s5)),
      ],
    );
  }
}

class _ExploreFeedFixture extends StatelessWidget {
  const _ExploreFeedFixture({required this.fixtures});

  final _LabFixtures fixtures;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: fixtures.exploreOverrides,
      child: Consumer(
        builder: (context, ref, _) {
          return CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: buildExploreEventsSlivers(
              ref,
              pinnedDayHeaders: false,
              candidateClubs: fixtures.clubs,
            ),
          );
        },
      ),
    );
  }
}

class _ExploreMapLeadFixture extends StatelessWidget {
  const _ExploreMapLeadFixture({
    required this.fixtures,
    required this.mode,
    this.selectedEventId,
  });

  final _LabFixtures fixtures;
  final ExploreMapSheetLeadMode mode;
  final String? selectedEventId;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: fixtures.exploreOverrides,
      child: Consumer(
        builder: (context, ref, _) {
          return CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: buildExploreMapSheetLeadSlivers(
              ref: ref,
              selectedEventId: mode == ExploreMapSheetLeadMode.selectedEvent
                  ? selectedEventId ?? fixtures.dinner.id
                  : null,
              cameraCenter: fixtures.mapCenter,
              filters: const ClubBrowseFilterSelection(),
              scopeLabel: 'Mumbai',
              leadMode: mode,
              onEventTapped: (_) {},
              onSeeAll: () {},
            ),
          );
        },
      ),
    );
  }
}

class _ActivitySectionFixture extends StatelessWidget {
  const _ActivitySectionFixture({required this.fixtures});

  final _LabFixtures fixtures;

  @override
  Widget build(BuildContext context) {
    final uid = fixtures.viewer.uid;
    return ProviderScope(
      overrides: fixtures.activityOverrides(uid),
      child: ActivitySection(
        uid: uid,
        showEmptyState: false,
        showMarkAllReadAction: false,
      ),
    );
  }
}

class _LabFixtures {
  _LabFixtures();

  final DateTime today = DateTime(2026, 5, 27);
  final LocationCoordinate mapCenter = const LocationCoordinate(
    19.0760,
    72.8777,
  );

  late final Club runClub = _club(
    id: 'club-sundowner',
    name: 'Sundowner Run Club',
    description:
        'Easy social runs, post-run coffee, and routes that keep the group together.',
    location: 'mumbai',
    area: 'Juhu Sea Face',
    hostName: 'Aarav Mehta',
    tags: const ['5K', 'Social', 'Coffee'],
    memberCount: 128,
    rating: 4.8,
    reviewCount: 42,
    nextEventAt: DateTime(2026, 5, 28, 7, 30),
    nextEventLabel: 'Thursday morning run',
  );

  late final Club photoClub = _club(
    id: 'club-race-course',
    name: 'Race Course Road Event Collective',
    description:
        'Curated outdoor mornings, beginner-friendly drills, and weekend mixers.',
    location: 'mumbai',
    area: 'Mahalaxmi',
    hostName: 'Naina Shah',
    imageUrl: 'https://example.invalid/catch/club-cover.jpg',
    tags: const ['Outdoors', 'Beginner friendly', 'Weekend'],
    memberCount: 312,
    rating: 4.9,
    reviewCount: 77,
    nextEventAt: DateTime(2026, 5, 29, 6, 45),
    nextEventLabel: 'Sunrise walk',
  );

  late final Club sportClub = _club(
    id: 'club-court-social',
    name: 'Court Social',
    description:
        'Racket sports with mixed doubles rotations and host-led intros.',
    location: 'mumbai',
    area: 'Bandra West',
    hostName: 'Kabir Rao',
    tags: const ['Pickleball', 'Rotations', 'Skill matched'],
    memberCount: 94,
    rating: 4.7,
    reviewCount: 29,
    nextEventAt: DateTime(2026, 5, 30, 17, 30),
    nextEventLabel: 'Pickleball ladder',
  );

  late final Club dinnerClub = _club(
    id: 'club-table-six',
    name: 'Table Six',
    description:
        'Small-table dinners for people who prefer structured conversation over loud rooms.',
    location: 'mumbai',
    area: 'Bandra Kurla Complex',
    hostName: 'Mira Kapoor',
    tags: const ['Dinner', 'Conversation', 'Curated'],
    memberCount: 58,
    rating: 4.6,
    reviewCount: 18,
    nextEventAt: DateTime(2026, 5, 28, 20),
    nextEventLabel: 'Thursday supper club',
  );

  late final List<Club> clubs = [runClub, photoClub, sportClub, dinnerClub];

  late final Event socialRun = _event(
    id: 'event-social-run',
    club: runClub,
    startTime: DateTime(2026, 5, 28, 7, 30),
    duration: const Duration(minutes: 75),
    meetingPoint: 'Race Course Road Event Collective',
    notes: 'Gate 2, near the fountain',
    kind: ActivityKind.socialRun,
    distanceKm: 5,
    pace: PaceLevel.competitive,
    capacityLimit: 16,
    bookedCount: 9,
    waitlistedCount: 2,
    priceInPaise: 0,
    constraints: const EventConstraints(
      minAge: 24,
      maxAge: 39,
      maxMen: 8,
      maxWomen: 8,
    ),
  );

  late final Event walk = _event(
    id: 'event-sunrise-walk',
    club: photoClub,
    startTime: DateTime(2026, 5, 29, 6, 45),
    duration: const Duration(minutes: 60),
    meetingPoint: 'Marine Drive Promenade',
    notes: 'Start by the sea-facing steps',
    kind: ActivityKind.walking,
    distanceKm: 3,
    pace: PaceLevel.easy,
    capacityLimit: 20,
    bookedCount: 14,
    waitlistedCount: 0,
    priceInPaise: 0,
  );

  late final Event pickleball = _event(
    id: 'event-pickleball',
    club: sportClub,
    startTime: DateTime(2026, 5, 30, 17, 30),
    duration: const Duration(minutes: 90),
    meetingPoint: 'Bandra Court 3',
    notes: 'Shoes required. Paddles available.',
    kind: ActivityKind.pickleball,
    distanceKm: 0,
    pace: PaceLevel.moderate,
    capacityLimit: 12,
    bookedCount: 10,
    waitlistedCount: 1,
    priceInPaise: 49900,
  );

  late final Event dinner = _event(
    id: 'event-dinner',
    club: dinnerClub,
    startTime: DateTime(2026, 5, 28, 20),
    duration: const Duration(hours: 2),
    meetingPoint: 'The Pantry, BKC',
    notes: 'Ask for the Catch table.',
    kind: ActivityKind.dinner,
    distanceKm: 0,
    pace: PaceLevel.easy,
    capacityLimit: 10,
    bookedCount: 7,
    waitlistedCount: 3,
    priceInPaise: 120000,
  );

  late final Event heroEvent = socialRun.copyWith(id: 'event-detail-hero');
  late final Event photoHeaderEvent = socialRun.copyWith(
    id: 'event-photo-header',
  );
  late final Event checkInEvent = socialRun.copyWith(
    id: 'event-check-in-open',
    startTime: DateTime.now().add(const Duration(minutes: 20)),
    endTime: DateTime.now().add(const Duration(hours: 1, minutes: 20)),
  );
  late final Event pastEvent = socialRun.copyWith(
    id: 'event-past-social-run',
    startTime: DateTime.now().subtract(const Duration(hours: 6)),
    endTime: DateTime.now().subtract(const Duration(hours: 4)),
  );

  late final List<Event> upcomingEvents = [socialRun, dinner, walk, pickleball];

  late final EventTileData joinedTileData = EventTileData.fromEvent(
    event: socialRun.copyWith(bookedCount: 0),
    status: EventTileStatus.joined,
    clubName: runClub.name,
    positionLabel: "You're in",
  );

  late final List<EventMapItem> mapItems = [
    EventMapItem(
      event: socialRun,
      status: EventTileStatus.recommended,
      clubName: runClub.name,
    ),
    EventMapItem(
      event: walk,
      status: EventTileStatus.open,
      clubName: photoClub.name,
    ),
    EventMapItem(
      event: pickleball,
      status: EventTileStatus.saved,
      clubName: sportClub.name,
    ),
  ];

  late final exploreOverrides = [
    exploreFeedViewModelProvider.overrideWithValue(
      AsyncData<EventDiscoveryViewModel>(
        EventDiscoveryViewModel(items: exploreItems),
      ),
    ),
    clubBrowseFiltersProvider.overrideWithValue(
      const ClubBrowseFilterSelection(),
    ),
    clubSearchQueryProvider.overrideWithValue(''),
  ];

  List<Override> activityOverrides(String uid) => [
    watchSignedUpEventsProvider(
      uid,
    ).overrideWithValue(AsyncData<List<Event>>([checkInEvent])),
    watchActivityNotificationsProvider(uid).overrideWithValue(
      AsyncData<List<ActivityNotification>>([activityNotification]),
    ),
  ];

  late final List<ExploreEventItem> exploreItems = [
    ExploreEventItem(
      event: socialRun,
      club: runClub,
      status: EventTileStatus.recommended,
      distanceFromUserKm: 1.8,
      isJoinedClubMember: true,
    ),
    ExploreEventItem(
      event: dinner,
      club: dinnerClub,
      status: EventTileStatus.open,
      distanceFromUserKm: 4.3,
    ),
    ExploreEventItem(
      event: walk,
      club: photoClub,
      status: EventTileStatus.joined,
      distanceFromUserKm: 0.7,
    ),
    ExploreEventItem(
      event: pickleball,
      club: sportClub,
      status: EventTileStatus.saved,
      distanceFromUserKm: 2.1,
    ),
  ];

  late final UserProfile viewer = UserProfile(
    uid: 'viewer-1',
    name: 'Riya Sharma',
    firstName: 'Riya',
    lastName: 'Sharma',
    displayName: 'Riya',
    dateOfBirth: DateTime(1998, 3, 14),
    gender: Gender.woman,
    phoneNumber: '+919999999999',
    profileComplete: true,
    city: 'mumbai',
    interestedInGenders: const [Gender.man],
  );

  late final Review review = Review(
    id: 'review-1',
    clubId: runClub.id,
    eventId: socialRun.id,
    reviewerUserId: 'reviewer-1',
    reviewerName: 'Isha',
    rating: 5,
    comment:
        'The host kept everyone together and the post-run coffee made it easy to talk.',
    createdAt: today.subtract(const Duration(days: 3)),
  );

  late final ActivityNotification activityNotification = ActivityNotification(
    id: 'notification-event-reminder',
    uid: viewer.uid,
    type: ActivityNotificationType.eventReminder,
    title: 'Your run starts soon',
    body: '${checkInEvent.title} at ${checkInEvent.locationName}',
    createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
    eventId: checkInEvent.id,
    clubId: checkInEvent.clubId,
  );

  String? clubNameFor(Event event) {
    return switch (event.clubId) {
      'club-sundowner' => runClub.name,
      'club-race-course' => photoClub.name,
      'club-court-social' => sportClub.name,
      'club-table-six' => dinnerClub.name,
      _ => null,
    };
  }

  Club _club({
    required String id,
    required String name,
    required String description,
    required String location,
    required String area,
    required String hostName,
    List<String> tags = const [],
    int memberCount = 0,
    double rating = 0,
    int reviewCount = 0,
    DateTime? nextEventAt,
    String? nextEventLabel,
    String? imageUrl,
  }) {
    return Club(
      id: id,
      name: name,
      description: description,
      location: location,
      area: area,
      hostUserId: 'host-$id',
      hostName: hostName,
      createdAt: DateTime(2026),
      imageUrl: imageUrl,
      profileImageUrl: imageUrl,
      tags: tags,
      memberCount: memberCount,
      rating: rating,
      reviewCount: reviewCount,
      nextEventAt: nextEventAt,
      nextEventLabel: nextEventLabel,
      instagramHandle: '@${name.toLowerCase().replaceAll(' ', '')}',
    );
  }

  Event _event({
    required String id,
    required Club club,
    required DateTime startTime,
    required Duration duration,
    required String meetingPoint,
    required String notes,
    required ActivityKind kind,
    required double distanceKm,
    required PaceLevel pace,
    required int capacityLimit,
    required int bookedCount,
    required int waitlistedCount,
    required int priceInPaise,
    EventConstraints constraints = const EventConstraints(),
  }) {
    final centerOffset = id.hashCode.abs() % 16;
    final lat = mapCenter.latitude + (centerOffset * 0.002);
    final lng = mapCenter.longitude - (centerOffset * 0.0014);
    return Event(
      id: id,
      clubId: club.id,
      startTime: startTime,
      endTime: startTime.add(duration),
      meetingPoint: meetingPoint,
      meetingLocation: EventMeetingLocation(
        name: meetingPoint,
        latitude: lat,
        longitude: lng,
        notes: notes,
      ),
      startingPointLat: lat,
      startingPointLng: lng,
      locationDetails: notes,
      eventFormat: EventFormatSnapshot.fromActivityKind(kind),
      distanceKm: distanceKm,
      pace: pace,
      capacityLimit: capacityLimit,
      description:
          'A structured ${kind.label.toLowerCase()} with host-led intros, a clear meeting point, and enough rhythm that people can participate without guessing what to do next.',
      priceInPaise: priceInPaise,
      bookedCount: bookedCount,
      checkedInCount: bookedCount > 2 ? bookedCount - 2 : bookedCount,
      waitlistedCount: waitlistedCount,
      constraints: constraints,
      genderCounts: const {'man': 4, 'woman': 5},
    );
  }
}
