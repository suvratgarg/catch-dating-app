import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_metric_strip.dart';
import 'package:catch_dating_app/core/widgets/catch_stat_column.dart';
import 'package:catch_dating_app/swipes/shared/profile_surface/catch_profile_view.dart';
import 'package:catch_dating_app/swipes/shared/profile_surface/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'hero formats profile identity and keeps no-activity kicker ink',
    (tester) async {
      await _setProfileViewport(tester);
      await tester.pumpWidget(
        _profileHarness(
          const ProfileView(
            name: 'Maya',
            age: 29,
            kicker: 'was at · sundowner 5k',
            metaLine: 'designer · bandra',
          ),
        ),
      );

      expect(find.text('Maya, 29'), findsOneWidget);
      expect(find.text('DESIGNER · BANDRA'), findsOneWidget);

      final kicker = tester.widget<Text>(find.text('WAS AT · SUNDOWNER 5K'));
      expect(kicker.style?.color, CatchTokens.editorialDark.ink);
    },
  );

  testWidgets('profile body uses DS metric strip, hint rows, and chips', (
    tester,
  ) async {
    await _setProfileViewport(tester);
    await tester.pumpWidget(
      _profileHarness(
        const ProfileView(
          name: 'Maya',
          age: 29,
          kickerActivity: ActivityKind.socialRun,
          sections: [
            ProfileCompatibilitySection(
              title: 'Why you might click',
              reasons: [
                'Shared run context from the same event.',
                'Both profiles mention dawn miles.',
              ],
              confidence: ['Verified photos', 'Active this week'],
            ),
            ProfileRunningSection(
              pace: '5:20-6:00 /km',
              distance: '5K · 10K',
              reasons: ['Headspace miles'],
              times: ['Dawn'],
              tags: ['Morning regular', 'Social miles'],
            ),
          ],
        ),
      ),
    );

    expect(find.byType(CatchMetricStrip), findsOneWidget);
    expect(find.byType(CatchStatColumn), findsNothing);
    expect(find.text('PACE'), findsOneWidget);
    expect(find.text('DISTANCE'), findsOneWidget);
    expect(
      find.text('Shared run context from the same event.'),
      findsOneWidget,
    );
    expect(find.text('Both profiles mention dawn miles.'), findsOneWidget);
    expect(find.byType(CatchChip), findsNWidgets(4));
    expect(find.byType(CatchBadge), findsNothing);
  });
}

Widget _profileHarness(ProfileView view) {
  return MaterialApp(
    theme: AppTheme.light,
    home: CatchProfileView(data: view),
  );
}

Future<void> _setProfileViewport(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(440, 1600);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
