import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_keys.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/swipe_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('exposes semantic like and pass actions', (tester) async {
    var passCount = 0;
    var likeCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SwipeActionButtons(
            onPass: () => passCount += 1,
            onLike: () => likeCount += 1,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(SwipeKeys.passButton));
    await tester.tap(find.byKey(SwipeKeys.likeButton));
    await tester.pump();

    expect(passCount, 1);
    expect(likeCount, 1);
    expect(find.byTooltip('Pass'), findsOneWidget);
    expect(find.byTooltip('Like'), findsOneWidget);
  });
}
