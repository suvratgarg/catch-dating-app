import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/chats/presentation/widgets/chat_event_context_header.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders an activity-aware dinner context stamp', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ChatEventContextHeader(
            event: _event(activityKind: ActivityKind.dinner),
          ),
        ),
      ),
    );

    expect(find.text('MATCHED AFTER DINNER'), findsOneWidget);
    expect(find.text('Friday Evening Dinner · Fri 29 May'), findsOneWidget);
  });

  testWidgets('renders a neutral fallback stamp while event context loads', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: ChatEventContextHeader(event: null)),
      ),
    );

    expect(find.text('MATCHED THROUGH CATCH'), findsOneWidget);
    expect(find.text('the same event'), findsOneWidget);
  });
}

Event _event({required ActivityKind activityKind}) {
  return Event(
    id: 'event-1',
    clubId: 'club-1',
    startTime: DateTime(2026, 5, 29, 19),
    endTime: DateTime(2026, 5, 29, 21),
    meetingPoint: 'Gallery',
    eventFormat: EventFormatSnapshot.fromActivityKind(activityKind),
    distanceKm: 0,
    pace: PaceLevel.easy,
    capacityLimit: 12,
    description: 'A small singles event.',
    priceInPaise: 0,
  );
}
