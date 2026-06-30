import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/event_activity_visuals.dart';
import 'package:catch_dating_app/events/presentation/widgets/booking_conflict_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BookingConflictSheet renders clashing events and actions', (
    tester,
  ) async {
    var replaced = 0;
    var keptBoth = 0;
    var keptExisting = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: BookingConflictSheet(
                existing: const BookingConflictEvent(
                  title: 'Morning yoga flow',
                  when: 'Sat · 7:00 AM',
                  activityKind: ActivityKind.yoga,
                ),
                incoming: const BookingConflictEvent(
                  title: 'Sundowner 5K, Bandra',
                  when: 'Sat · 6:30 AM',
                  activityKind: ActivityKind.socialRun,
                ),
                onReplaceExisting: () => replaced++,
                onKeepBoth: () => keptBoth++,
                onKeepExisting: () => keptExisting++,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text("That's the same time slot"), findsOneWidget);
    expect(find.textContaining("You're already booked"), findsOneWidget);
    expect(find.text('ALREADY BOOKED'), findsOneWidget);
    expect(find.text('NEW'), findsOneWidget);
    expect(find.text('Morning yoga flow'), findsOneWidget);
    expect(find.text('Sat · 7:00 AM'), findsOneWidget);
    expect(find.text('Sundowner 5K, Bandra'), findsOneWidget);
    expect(find.text('Sat · 6:30 AM'), findsOneWidget);
    expect(find.byIcon(activityKindGlyph(ActivityKind.yoga)), findsOneWidget);
    expect(
      find.byIcon(activityKindGlyph(ActivityKind.socialRun)),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(BookingConflictSheetKeys.replaceExistingButton),
    );
    await tester.pump();
    await tester.tap(find.byKey(BookingConflictSheetKeys.keepBothButton));
    await tester.pump();
    await tester.tap(find.byKey(BookingConflictSheetKeys.keepExistingButton));
    await tester.pump();

    expect(replaced, 1);
    expect(keptBoth, 1);
    expect(keptExisting, 1);
  });
}
