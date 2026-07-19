import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_keys.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/catches_pass_button.dart';
import 'package:catch_dating_app/swipes/shared/profile_surface/profile_reaction_controls.dart';
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
    final renderer = tester.widget<CatchIconButton>(
      find.byType(CatchIconButton),
    );
    expect(renderer.variant, CatchIconButtonVariant.float);
    expect(renderer.size, CatchLayout.passButtonExtent);
  });

  testWidgets('pass and reaction adapters share CatchIconButton rendering', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Column(
            children: [
              const CatchesPassButton(onPressed: null, isPending: true),
              ReactionControlButton(
                tooltip: 'Like profile',
                icon: CatchIcons.favoriteBorderRounded,
                onPressed: null,
                style: ProfileReactionControlsStyle.surface,
                isPending: true,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(CatchIconButton), findsNWidgets(2));
    expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
    final renderers = tester.widgetList<CatchIconButton>(
      find.byType(CatchIconButton),
    );
    expect(renderers.map((button) => button.size), [
      CatchLayout.passButtonExtent,
      CatchLayout.reactionControlExtent,
    ]);
    expect(renderers.every((button) => button.onTap == null), isTrue);
  });
}
