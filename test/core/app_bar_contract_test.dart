import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_pump_helpers.dart';

void main() {
  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        'task and context share the platform family at $platform $scale',
        (tester) async {
          debugDefaultTargetPlatformOverride = platform;
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = const Size(390, 844);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.light,
              home: MediaQuery(
                data: MediaQueryData(
                  size: const Size(390, 844),
                  textScaler: TextScaler.linear(scale),
                ),
                child: const CatchScaffold.workspace(
                  title: CatchTopBar.route(
                    title: 'Event recap',
                    subtitle: 'Wednesday Evening Run',
                    navigation: CatchTopBarNavigation(
                      mode: CatchTopBarNavigationMode.back,
                    ),
                  ),
                  body: SizedBox.shrink(),
                ),
              ),
            ),
          );
          final title = tester.widget<Text>(find.text('Event recap'));
          final contextText = tester.widget<Text>(
            find.text('Wednesday Evening Run'),
          );
          for (final text in [title, contextText]) {
            expect(
              CatchFonts.platformFunctionFamilies,
              contains(text.style!.fontFamily),
            );
          }
          expect(
            title.style!.fontSize,
            greaterThan(contextText.style!.fontSize!),
          );
          expect(
            tester.getBottomLeft(find.text('Event recap')).dy,
            lessThan(tester.getTopLeft(find.text('Wednesday Evening Run')).dy),
          );
          final barRect = tester.getRect(find.byType(CatchTopBar));
          final titleRect = tester.getRect(find.text('Event recap'));
          // Single-line titles don't reserve an empty second line at large text.
          expect(titleRect.top - barRect.top, lessThan(20));
          expect(
            tester.getBottomLeft(find.text('Wednesday Evening Run')).dy,
            lessThanOrEqualTo(barRect.bottom),
          );
          expect(tester.takeException(), isNull);
          debugDefaultTargetPlatformOverride = null;
        },
      );
    }
  }

  testWidgets(
    'expanded search removes covered action and title semantics at 2x',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 844),
              textScaler: TextScaler.linear(2),
            ),
            child: CatchScaffold.workspace(
              title: CatchTopBar.screen(
                title: 'Customer communications',
                search: CatchTopBarSearch(
                  expanded: true,
                  placeholder: 'Search customers',
                  tooltip: 'Search customers',
                  copy: CatchSearchFieldCopy(
                    searchLabel: 'Search',
                    closeSearchLabel: 'Close search',
                    clearTooltip: (value) => 'Clear $value',
                  ),
                ),
                actions: [
                  CatchButton.text(
                    label: 'Mark every conversation as read',
                    onPressed: () {},
                  ),
                ],
              ),
              body: const SizedBox.shrink(),
            ),
          ),
        ),
      );
      await pumpFeatureUi(tester);
      expect(find.bySemanticsLabel('Customer communications'), findsNothing);
      expect(
        find.bySemanticsLabel('Mark every conversation as read'),
        findsNothing,
      );
      expect(find.bySemanticsLabel('Close search'), findsWidgets);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );
}
