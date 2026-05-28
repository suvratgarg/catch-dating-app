import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/explore_concept/explore_concept_activity_theme_board.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/explore_concept/explore_concept_activity_visuals.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/explore_concept/explore_concept_cards.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/explore_concept/explore_concept_category_grid.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/explore_concept/explore_concept_map_pin.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/explore_concept/explore_concept_models.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:flutter/material.dart';

class ExploreConceptPreviewScreen extends StatelessWidget {
  const ExploreConceptPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      appBar: const CatchTopBar(title: 'Explore concept lab', border: true),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            CatchSpacing.s5,
            CatchSpacing.s4,
            CatchSpacing.s5,
            CatchSpacing.s8,
          ),
          children: [
            _LabIntro(),
            gapH20,
            const _Section(
              title: 'Activity color system',
              child: ExploreConceptActivityThemeBoard(),
            ),
            gapH24,
            _Section(
              title: 'Event cards',
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var index = 0; index < _events.length; index += 1)
                      Padding(
                        padding: EdgeInsets.only(
                          right: index == _events.length - 1
                              ? 0
                              : CatchSpacing.s4,
                        ),
                        child: ExploreConceptEventTicketCard(
                          event: _events[index],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            gapH24,
            const _Section(
              title: 'This week',
              child: ExploreConceptThisWeekList(items: _thisWeekItems),
            ),
            gapH24,
            _Section(
              title: 'Spotlight event',
              child: ExploreConceptEventSpotlightCard(event: _events.first),
            ),
            gapH24,
            _Section(
              title: 'Detail header treatment',
              child: ExploreConceptEventDetailHeaderMock(event: _events[1]),
            ),
            gapH24,
            const _Section(
              title: 'Club spotlight',
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExploreConceptClubSpotlightCard(club: _clubWithCover),
                    SizedBox(width: CatchSpacing.s4),
                    ExploreConceptClubSpotlightCard(club: _clubWithoutCover),
                  ],
                ),
              ),
            ),
            gapH24,
            _Section(
              title: 'Map pin treatment',
              child: const ExploreConceptMapPreview(),
            ),
            gapH24,
            _Section(
              title: 'Browse by event type',
              child: ExploreConceptCategoryGrid(categories: _browseCategories),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabIntro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prototype primitives',
          style: CatchTextStyles.displayS(context, color: t.ink),
        ),
        gapH6,
        Text(
          'Static widgets for the new Explore direction. This screen does not '
          'read live clubs, events, memberships, or bookings.',
          style: CatchTextStyles.bodyLead(context, color: t.ink2),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: CatchTextStyles.titleL(context)),
        gapH12,
        child,
      ],
    );
  }
}

const _events = [
  ExploreConceptEventData(
    title: 'Sundowner 5K, then mango sodas',
    clubName: 'Sundowner Run Club',
    venue: 'Cubbon Park',
    timeLabel: '6:30 PM',
    countdownLabel: 'In 1h',
    priceLabel: 'Free',
    capacityLabel: '18 going · 7 left',
    activityLabel: 'Run',
    statusLabel: 'Joined',
    activityKind: ActivityKind.socialRun,
    clockTime: TimeOfDay(hour: 18, minute: 30),
    supportingLabel:
        'Easy evening run, low-pressure hang, and a quick table after.',
  ),
  ExploreConceptEventData(
    title: 'Long table, short questions',
    clubName: 'Slow Tables',
    venue: 'Vasanth Nagar',
    timeLabel: '8:00 PM',
    countdownLabel: 'Tonight',
    priceLabel: 'Rs 1400',
    capacityLabel: '7 of 10 seats',
    activityLabel: 'Dinner',
    statusLabel: 'Open',
    activityKind: ActivityKind.dinner,
    clockTime: TimeOfDay(hour: 20, minute: 0),
  ),
  ExploreConceptEventData(
    title: 'Pub quiz, then table swaps',
    clubName: 'Last Friday Sessions',
    venue: 'Indiranagar',
    timeLabel: '9:00 PM',
    countdownLabel: 'Fri',
    priceLabel: 'Rs 800',
    capacityLabel: '47 going · 13 left',
    activityLabel: 'Quiz',
    statusLabel: 'Few left',
    activityKind: ActivityKind.pubQuiz,
    clockTime: TimeOfDay(hour: 21, minute: 0),
  ),
];

const _clubWithCover = ExploreConceptClubData(
  kicker: 'Club to know',
  name: 'Sundowner Run Club',
  tagline: 'Easy 5Ks, hard conversations.',
  hostLabel: 'Aanya, Aman and Imran',
  memberCountLabel: '248 members',
  tags: ['Beginner-friendly', 'Social run'],
  scheduleLabel: 'Mon - Wed - Fri',
  actionLabel: 'View club',
  accentColor: Color(0xFFE15D39),
  secondaryAccentColor: Color(0xFF41C8BA),
  hasCoverPhoto: true,
  coverCaption: 'Friday evenings in Cubbon',
);

const _clubWithoutCover = ExploreConceptClubData(
  kicker: 'Club to know',
  name: 'Sundowner Run Club',
  tagline: 'Easy 5Ks, hard conversations.',
  hostLabel: 'Aanya, Aman and Imran',
  memberCountLabel: '248 members',
  tags: ['Beginner-friendly', 'Social run'],
  scheduleLabel: 'Mon - Wed - Fri',
  actionLabel: 'View club',
  accentColor: Color(0xFFE15D39),
  secondaryAccentColor: Color(0xFF41C8BA),
);

const _musicClub = ExploreConceptClubData(
  kicker: 'Worth following',
  name: 'Last Friday Sessions',
  tagline: 'New club for small-room sets.',
  hostLabel: 'Rohan K.',
  memberCountLabel: '416 following',
  tags: ['Live music', 'Indie nights'],
  scheduleLabel: 'Last Friday',
  actionLabel: 'Follow',
  accentColor: Color(0xFF8D3FE0),
  secondaryAccentColor: Color(0xFFDB3D98),
);

const _thisWeekItems = <ExploreConceptThisWeekItemData>[
  ExploreConceptThisWeekEventData(
    weekdayLabel: 'Wed',
    dayLabel: '28',
    title: 'Long table, short questions',
    clubName: 'Slow Tables',
    timeLabel: '8:00 PM',
    priceLabel: 'Rs 1400',
    goingLabel: '7 going',
    leftLabel: '3 left',
    progress: 0.7,
    activityKind: ActivityKind.dinner,
    clockTime: TimeOfDay(hour: 20, minute: 0),
    leftIsUrgent: true,
  ),
  ExploreConceptThisWeekEventData(
    weekdayLabel: 'Thu',
    dayLabel: '29',
    title: 'Sundowner 5K, then mango sodas',
    clubName: 'Sundowner Run Club',
    timeLabel: '6:30 PM',
    priceLabel: 'Free',
    goingLabel: '18 going',
    leftLabel: '7 left',
    progress: 0.72,
    activityKind: ActivityKind.socialRun,
    clockTime: TimeOfDay(hour: 18, minute: 30),
  ),
  ExploreConceptThisWeekClubData(
    club: _musicClub,
    kicker: 'Worth following',
    supportingLabel: 'New club - 416 already follow - Rohan K.',
    activityKind: ActivityKind.barCrawl,
  ),
  ExploreConceptThisWeekEventData(
    weekdayLabel: 'Fri',
    dayLabel: '30',
    title: 'Indie gig, then strangers',
    clubName: 'Last Friday Sessions',
    timeLabel: '9:00 PM',
    priceLabel: 'Rs 800',
    goingLabel: '47 going',
    leftLabel: '13 left',
    progress: 0.78,
    activityKind: ActivityKind.barCrawl,
    clockTime: TimeOfDay(hour: 21, minute: 0),
  ),
  ExploreConceptThisWeekEventData(
    weekdayLabel: 'Sat',
    dayLabel: '31',
    title: 'Saturday singles mixer, art-house',
    clubName: 'Clay & Cabernet',
    timeLabel: '7:30 PM',
    priceLabel: 'Rs 900',
    goingLabel: '22 going',
    leftLabel: '8 left',
    progress: 0.74,
    activityKind: ActivityKind.singlesMixer,
    clockTime: TimeOfDay(hour: 19, minute: 30),
  ),
];

final _browseCategories = [
  for (final kind in exploreConceptPrimaryBrowseKinds)
    ExploreConceptCategoryData(
      label: exploreConceptActivityVisual(kind).label,
      countLabel: _countLabelFor(kind),
      activityKind: kind,
    ),
];

String _countLabelFor(ActivityKind kind) {
  return switch (kind) {
    ActivityKind.socialRun => '14 this week',
    ActivityKind.walking => '8 walks',
    ActivityKind.pickleball => '10 games',
    ActivityKind.padel => '7 matches',
    ActivityKind.tennis => '6 courts',
    ActivityKind.badminton => '5 courts',
    ActivityKind.cycling => '4 rides',
    ActivityKind.spinClass => '3 classes',
    ActivityKind.yoga => '9 sessions',
    ActivityKind.dinner => '12 tables',
    ActivityKind.pubQuiz => '6 quizzes',
    ActivityKind.barCrawl => '5 nights',
    ActivityKind.singlesMixer => '7 mixers',
    ActivityKind.openActivity => 'Host picks',
    ActivityKind.running || ActivityKind.strengthTraining => 'Roadmap',
  };
}
