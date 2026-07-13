import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_count_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_inline_status.dart';
import 'package:catch_dating_app/core/widgets/catch_status_dot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('badge typography keeps metadata case and normalizes status', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const Wrap(
          children: [
            CatchBadge.metadata(label: 'Ready soon'),
            CatchBadge.functional(label: 'Ready soon'),
            CatchBadge.live(label: 'Live now'),
          ],
        ),
      ),
    );

    expect(find.text('Ready soon'), findsOneWidget);
    expect(find.text('READY SOON'), findsOneWidget);
    expect(find.text('LIVE NOW'), findsOneWidget);
    expect(find.byType(CatchStatusDot), findsOneWidget);
  });

  testWidgets('on-dark badge owns the fixed editorial recipe', (tester) async {
    await tester.pumpWidget(
      _wrap(const CatchBadge.onDark(label: 'Preview')),
    );

    final decoration = tester
        .widget<DecoratedBox>(
          find.descendant(
            of: find.byType(CatchBadge),
            matching: find.byType(DecoratedBox),
          ),
        )
        .decoration as BoxDecoration;
    final border = decoration.border! as Border;

    expect(
      decoration.color,
      CatchTokens.editorialWhite.withValues(
        alpha: CatchOpacity.revealSurfaceFill,
      ),
    );
    expect(
      border.top.color,
      CatchTokens.editorialWhite.withValues(
        alpha: CatchOpacity.eventSuccessSubtleBorder,
      ),
    );
    expect(tester.widget<Text>(find.text('Preview')).style?.color,
        CatchTokens.editorialWhite);
  });

  testWidgets('count badge hides zero, clamps 99+, and preserves child size', (
    tester,
  ) async {
    const childKey = ValueKey('count-child');
    await tester.pumpWidget(
      _wrap(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CatchCountBadge(
              count: 0,
              child: Icon(CatchIcons.notificationsOutlined),
            ),
            CatchCountBadge(
              count: 100,
              child: Icon(
                CatchIcons.notificationsOutlined,
                key: childKey,
              ),
            ),
            CatchCountBadge.label(count: 7),
          ],
        ),
      ),
    );

    expect(find.text('0'), findsNothing);
    expect(find.text('99+'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(tester.getSize(find.byKey(childKey)), const Size(24, 24));
  });

  testWidgets('inline status remains unboxed and handles constrained copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 120,
          child: CatchInlineStatus(
            label: 'Unsaved changes with long localized copy',
            tone: CatchInlineStatusTone.warning,
          ),
        ),
        textScale: 2,
      ),
    );

    expect(find.byType(CatchStatusDot), findsOneWidget);
    expect(find.byType(DecoratedBox), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _wrap(Widget child, {double textScale = 1}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(body: Center(child: child)),
    ),
  );
}
