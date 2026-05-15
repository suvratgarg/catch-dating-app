import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_keys.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/catches_pass_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CatchesPassButton exposes the floating pass action', (
    tester,
  ) async {
    var passCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: CatchesPassButton(onPressed: () => passCount += 1),
        ),
      ),
    );

    await tester.tap(find.byKey(SwipeKeys.passButton));
    await tester.pump();

    expect(passCount, 1);
    expect(find.byTooltip('Pass'), findsOneWidget);
  });
}
