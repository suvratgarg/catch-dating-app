import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/explore_concept/explore_concept_widgets.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Explore concept widgets render the prototype feed primitives', (
    tester,
  ) async {
    const event = ExploreConceptEventData(
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
    );
    const club = ExploreConceptClubData(
      kicker: 'Club to know',
      name: 'Sundowner Run Club',
      tagline: 'Easy 5Ks, hard conversations.',
      hostLabel: 'Aanya M. and Imran',
      memberCountLabel: '248 members',
      tags: ['Beginner-friendly', 'Social run'],
      scheduleLabel: 'Mon - Wed - Fri',
      actionLabel: 'View club',
      accentColor: Color(0xFFE15D39),
      secondaryAccentColor: Color(0xFF41C8BA),
    );

    await tester.pumpWidget(
      _wrap(
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ExploreConceptEventTicketCard(event: event),
              ExploreConceptThisWeekList(
                items: [
                  const ExploreConceptThisWeekEventData(
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
                  ),
                  const ExploreConceptThisWeekClubData(
                    club: club,
                    kicker: 'Worth following',
                    supportingLabel: 'New club - 416 already follow',
                    activityKind: ActivityKind.singlesMixer,
                  ),
                ],
              ),
              const ExploreConceptEventSpotlightCard(event: event),
              const ExploreConceptEventDetailHeaderMock(event: event),
              const ExploreConceptActivityThemeBoard(
                kinds: [ActivityKind.socialRun, ActivityKind.dinner],
              ),
              const ExploreConceptClubSpotlightCard(club: club),
              const ExploreConceptMapPreview(),
              ExploreConceptCategoryGrid(
                categories: [
                  ExploreConceptCategoryData(
                    label: 'Runs',
                    countLabel: '14 this week',
                    activityKind: ActivityKind.socialRun,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Sundowner 5K, then mango sodas'), findsNWidgets(3));
    expect(find.text('Easy 5Ks, hard conversations.'), findsOneWidget);
    expect(find.text('Slow Tables'), findsOneWidget);
    expect(find.text('Long table, short questions'), findsOneWidget);
    expect(find.text('WORTH FOLLOWING'), findsOneWidget);
    expect(find.text('Social run'), findsWidgets);
    expect(find.text('Runs'), findsOneWidget);
  });

  testWidgets('Explore concept preview fits a narrow viewport', (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const ExploreConceptPreviewScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('Prototype primitives'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: SafeArea(child: child)),
  );
}
