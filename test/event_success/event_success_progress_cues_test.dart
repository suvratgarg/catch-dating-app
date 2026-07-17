import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_progress_cue.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_feature_blocks.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_live_reveal_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'progress cue state resolves complete, current, and future positions',
    () {
      expect(
        CatchProgressCueState.fromPosition(index: 0, currentIndex: 1),
        CatchProgressCueState.complete,
      );
      expect(
        CatchProgressCueState.fromPosition(index: 1, currentIndex: 1),
        CatchProgressCueState.current,
      );
      expect(
        CatchProgressCueState.fromPosition(index: 2, currentIndex: 1),
        CatchProgressCueState.future,
      );
    },
  );

  testWidgets('countdown rail owns rendering for ordered progress items', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: CountdownBeatRail(
            items: [
              (label: 'Hold', icon: Icons.pan_tool_alt_outlined),
              (label: 'Watch', icon: Icons.visibility_outlined),
              (label: 'Move', icon: Icons.bolt_rounded),
            ],
            currentIndex: 1,
          ),
        ),
      ),
    );

    expect(find.text('Hold'), findsOneWidget);
    expect(find.text('Watch'), findsOneWidget);
    expect(find.text('Move'), findsOneWidget);
    expect(find.byIcon(CatchIcons.checkCircleRounded), findsOneWidget);
    expect(find.byIcon(Icons.pan_tool_alt_outlined), findsNothing);

    final icons = tester.widgetList<Icon>(find.byType(Icon)).toList();
    expect(icons.map((icon) => icon.color), [
      CatchTokens.light.success,
      CatchTokens.light.gold,
      CatchTokens.light.ink3,
    ]);
  });

  testWidgets('expanded steps consume the shared typed progress state', (
    tester,
  ) async {
    final steps = EventSuccessPlaybookLibrary.socialRun.runOfShow
        .take(3)
        .toList();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Column(
            children: [
              for (final entry in steps.indexed)
                LiveStepRow(
                  step: entry.$2,
                  state: CatchProgressCueState.fromPosition(
                    index: entry.$1,
                    currentIndex: 1,
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    expect(find.byIcon(CatchIcons.checkCircleRounded), findsOneWidget);
    expect(find.byIcon(CatchIcons.radioButtonCheckedRounded), findsOneWidget);
    expect(find.byIcon(CatchIcons.radioButtonUncheckedRounded), findsOneWidget);

    final icons = tester.widgetList<Icon>(find.byType(Icon)).toList();
    expect(icons.map((icon) => icon.color), [
      CatchTokens.light.success,
      CatchTokens.light.gold,
      CatchTokens.light.ink3,
    ]);
  });

  testWidgets('metric adapter formats its value and delegates to CatchBadge', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: EventSuccessMetricPill(label: 'Pacing', value: 0.78),
        ),
      ),
    );

    final badge = tester.widget<CatchBadge>(find.byType(CatchBadge));
    expect(badge.label, contains('Pacing'));
    expect(badge.label, contains('78'));
    expect(badge.size, CatchBadgeSize.md);
  });
}
