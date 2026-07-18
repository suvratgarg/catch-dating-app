import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/event_visual_atoms.dart';
import 'package:catch_dating_app/events/shared/event_tiles/event_date_rail_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'events_test_helpers.dart';

void main() {
  testWidgets('DateTicket uses activity art and a trailing price decision', (
    tester,
  ) async {
    final event = buildEvent(
      startTime: DateTime(2026, 7, 18, 14, 20),
      bookedCount: 10,
      capacityLimit: 16,
    );

    await pumpEventsTestApp(
      tester,
      Scaffold(
        body: Center(
          child: SizedBox(
            width: 350,
            child: EventDateRailCard(
              event: event,
              kicker: 'Vijay Nagar Event Collective',
              supportingLabel:
                  '5 km · Competitive · Rajwada square · 1.2 km away',
              capacityLabel: '10 going · 6 left',
              statusLabel: "You're in",
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Social run'), findsOneWidget);
    expect(find.text('FREE'), findsOneWidget);
    expect(find.byType(EventActivityStamp), findsNothing);
    expect(find.byType(EventClockMark), findsNothing);
    expect(find.byType(EventStatusPill), findsNothing);

    final glyph = tester.widget<Icon>(
      find.byKey(const ValueKey('event_date_rail_card.activity_glyph')),
    );
    expect(glyph.icon, ActivityPalette.glyphs[event.activityKind]);
    expect(glyph.color?.a, closeTo(CatchOpacity.eventDateRailGlyph, 0.001));

    final cardRect = tester.getRect(find.byType(EventDateRailCard));
    final decisionRect = tester.getRect(
      find.byKey(const ValueKey('event_date_rail_card.decision')),
    );
    final priceRect = tester.getRect(
      find.byKey(const ValueKey('event_date_rail_card.price')),
    );
    expect(priceRect.left, greaterThan(decisionRect.right));
    expect(decisionRect.height, lessThan(20));
    expect(cardRect.right - priceRect.right, lessThanOrEqualTo(24));
    expect(
      find.bySemanticsLabel(
        RegExp('Social run, Vijay Nagar Event Collective, Saturday, 18 Jul'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('DateTicket stacks but preserves paid price at text scale two', (
    tester,
  ) async {
    final event = buildEvent(
      startTime: DateTime(2026, 7, 18, 14, 20),
      priceInPaise: 120000,
      bookedCount: 10,
      capacityLimit: 16,
    );

    await pumpEventsTestApp(
      tester,
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 280,
              child: EventDateRailCard(
                event: event,
                kicker: 'A very long organizer collective name',
                supportingLabel:
                    '5 km · Competitive · A deliberately long meeting point',
                priceLabel: 'From ₹1,200',
                capacityLabel: '10 going · 6 left',
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('FROM ₹1,200'), findsOneWidget);
    final cardRect = tester.getRect(find.byType(EventDateRailCard));
    final priceRect = tester.getRect(
      find.byKey(const ValueKey('event_date_rail_card.price')),
    );
    expect(cardRect.right - priceRect.right, lessThanOrEqualTo(24));
  });

  testWidgets('DateTicket exposes veiled attendee proof without identities', (
    tester,
  ) async {
    final event = buildEvent(
      startTime: DateTime(2026, 7, 18, 14, 20),
      bookedCount: 5,
    );

    await pumpEventsTestApp(
      tester,
      Scaffold(
        body: EventDateRailCard(
          event: event,
          kicker: 'Vijay Nagar Event Collective',
          showAttendeeSignal: true,
        ),
      ),
    );

    final stack = tester.widget<CatchPersonAvatarStack>(
      find.byType(CatchPersonAvatarStack),
    );
    expect(stack.items, isEmpty);
    expect(stack.totalCount, 5);
    expect(stack.veiledCount, 5);
    expect(find.byType(CatchVeiledPersonAvatar), findsNWidgets(4));
  });
}
