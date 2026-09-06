import 'package:catch_dating_app/hosts/presentation/widgets/host_club_tools.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../clubs/clubs_test_helpers.dart' as club_test;
import '../events/events_test_helpers.dart' as event_test;

void main() {
  testWidgets('Host club metrics include the live post action', (tester) async {
    await club_test.pumpTestApp(
      tester,
      Column(
        children: [
          HostClubManagementPanel(
            club: club_test.buildClub(name: 'Host Club'),
            events: [
              event_test.buildEvent(
                priceInPaise: 1500,
                bookedCount: 2,
                waitlistedCount: 1,
              ),
              event_test.buildEvent(bookedCount: 1),
            ],
            onEditClub: () {},
            onCreateEvent: () {},
          ),
          const CatchMetricStrip(
            items: [
              CatchMetricStripItem(value: '24', label: 'followers'),
              CatchMetricStripItem(value: '4.7', label: 'rating'),
              CatchMetricStripItem(value: '12', label: 'reviews'),
              CatchMetricStripItem(value: 'JAN 2025', label: 'est.'),
            ],
          ),
        ],
      ),
    );

    expect(find.text('Booked'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('₹30'), findsOneWidget);
    expect(find.text('Post update'), findsOneWidget);
    expect(find.byType(CatchMetricStrip), findsOneWidget);
    expect(find.text('followers'), findsOneWidget);
    expect(find.text('reviews'), findsOneWidget);
    expect(find.text('est.'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('JAN 2025'), findsOneWidget);
    expect(find.text('4.7'), findsOneWidget);
  });
}
