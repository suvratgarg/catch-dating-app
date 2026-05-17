import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_hub_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart';

void main() {
  testWidgets('Catches intro CTA uses the light button variant in dark mode', (
    tester,
  ) async {
    final activeRun = buildEvent(
      startTime: DateTime.now().subtract(const Duration(hours: 11)),
      endTime: DateTime.now().subtract(const Duration(hours: 10)),
      checkedInCount: 2,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          watchAttendedEventsProvider(
            'runner-1',
          ).overrideWith((ref) => Stream.value([activeRun])),
        ],
        child: AppShellActiveTab(
          index: appShellCatchesTabIndex,
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const SwipeHubScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    final button = tester.widget<CatchButton>(
      find.widgetWithText(CatchButton, 'Start catching'),
    );
    final label = tester.widget<Text>(find.text('Start catching'));

    expect(button.variant, CatchButtonVariant.light);
    expect(button.isInteractive, isFalse);
    expect(label.style?.color, CatchTokens.sunsetLight.ink);
  });
}
