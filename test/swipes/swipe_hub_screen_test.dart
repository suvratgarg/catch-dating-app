import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_hub_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'SwipeHubScreen does not subscribe to catches streams while inactive',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uidProvider.overrideWith((ref) => throw StateError('watched uid')),
            watchAttendedRunsProvider(
              'runner-1',
            ).overrideWith((ref) => throw StateError('watched attended runs')),
          ],
          child: AppShellActiveTab(
            index: appShellHomeTabIndex,
            child: MaterialApp(
              theme: AppTheme.light,
              home: const SwipeHubScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Catches'), findsNothing);
    },
  );
}
