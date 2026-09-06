import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations_en.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_pump_helpers.dart';

void main() {
  testWidgets(
    'shared avatar stack uses caller colors and translated overflow',
    (tester) async {
      const colors = CatchAvatarColors(
        accent: Colors.purple,
        deep: Colors.deepPurple,
        soft: Colors.purpleAccent,
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: CatchTheme.light,
          home: Scaffold(
            body: CatchPersonAvatarStack(
              items: const [CatchPersonAvatarItem(name: 'Asha Shah')],
              totalCount: 5,
              size: 96,
              limit: 2,
              veiledCount: 1,
              veiledColors: colors,
              countLabelBuilder: catchAvatarCountLabelBuilder(
                _FrenchAvatarCopy(),
              ),
            ),
          ),
        ),
      );
      expect(find.text('AS'), findsOneWidget);
      expect(find.text('3 invités'), findsOneWidget);
      expect(find.text('+3'), findsNothing);
      final veil = tester.widget<CatchVeiledPersonAvatar>(
        find.byType(CatchVeiledPersonAvatar),
      );
      expect(veil.colors, same(colors));
      expect(find.byType(CatchPersonAvatar), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'app activity colors follow theme changes through image fallback',
    (tester) async {
      final content = Builder(
        builder: (context) => CatchPersonAvatar(
          size: 64,
          name: 'Social run',
          imageUrl: 'assets/fixtures/does-not-exist.png',
          colors: ActivityPalette.resolve(
            context,
            ActivityKind.socialRun,
          ).avatarColors,
        ),
      );
      for (final dark in [false, true]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? AppTheme.dark : AppTheme.light,
            themeAnimationDuration: Duration.zero,
            home: Scaffold(body: content),
          ),
        );
        await pumpUntilFound(
          tester,
          find.byType(CatchActivityInitialsPlaceholder),
        );
        final palette = (dark ? ActivityPalette.dark : ActivityPalette.light)
            .getActivity(ActivityKind.socialRun);
        final placeholder = tester.widget<CatchActivityInitialsPlaceholder>(
          find.byType(CatchActivityInitialsPlaceholder),
        );
        expect(placeholder.colors.accent, palette.accent);
        expect(placeholder.colors.deep, palette.deep);
        final gradient = tester
            .widgetList<DecoratedBox>(
              find.descendant(
                of: find.byType(CatchActivityInitialsPlaceholder),
                matching: find.byType(DecoratedBox),
              ),
            )
            .map((box) => box.decoration)
            .whereType<BoxDecoration>()
            .map((box) => box.gradient)
            .whereType<LinearGradient>()
            .single;
        expect(gradient.colors, [palette.accent, palette.deep]);
        expect(find.text('SR'), findsOneWidget);
        expect(find.byType(CatchInitialsAvatarPlaceholder), findsNothing);
        expect(tester.takeException(), isNull);
      }
    },
  );
}

class _FrenchAvatarCopy extends AppLocalizationsEn {
  @override
  String coreCatchPersonAvatarTextCount({required Object count}) =>
      '$count invités';
}
