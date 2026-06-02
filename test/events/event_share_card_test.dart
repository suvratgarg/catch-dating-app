import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_share_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';

import 'events_test_helpers.dart';

void main() {
  testWidgets('exports an event invite as a png with the event link', (
    tester,
  ) async {
    ShareParams? sharedParams;
    final event = buildEvent(
      meetingPoint: 'Bandra',
      startTime: DateTime(2026, 6, 1, 18),
      endTime: DateTime(2026, 6, 1, 20),
      bookedCount: 12,
    );
    final share = ExternalShareController((params) async {
      sharedParams = params;
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => showEventShareCardSheet(
                  context,
                  event: event,
                  share: share,
                  inviteCode: 'VIP42',
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(EventShareCard), findsOneWidget);
    expect(find.text('CATCH INVITE'), findsOneWidget);
    expect(find.text(event.title), findsOneWidget);
    expect(find.text('Bandra'), findsOneWidget);

    await tester.tap(find.byType(CatchButton).last);
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      for (var i = 0; i < 20 && sharedParams == null; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });

    expect(sharedParams?.subject, 'Join me at ${event.title}');
    expect(sharedParams?.text, contains('invite=VIP42'));
    expect(sharedParams?.files, hasLength(1));
    expect(sharedParams?.fileNameOverrides, ['catch-event-invite.png']);
  });
}
