import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/select_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CatchSelectChip renders selected accent fill and dispatches taps', (
    tester,
  ) async {
    const accent = Color(0xFF7A3B20);
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: CatchSelectChip(
              label: 'Trail run',
              active: true,
              accentColor: accent,
              onTap: () => taps++,
            ),
          ),
        ),
      ),
    );

    final surface = tester.widget<CatchSurface>(find.byType(CatchSurface));
    expect(surface.backgroundColor, accent);
    expect(surface.borderColor, Colors.transparent);
    expect(surface.radius, CatchRadius.pill);
    expect(surface.boxShadow, isNotEmpty);

    final scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
    expect(scale.scale, 1.03);

    final label = tester.widget<Text>(find.text('Trail run'));
    expect(label.overflow, TextOverflow.ellipsis);
    expect(label.style?.color, Colors.white);

    await tester.tap(find.text('Trail run'));
    expect(taps, 1);
  });
}
