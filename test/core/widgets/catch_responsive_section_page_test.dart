import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'adaptive section layout uses compact order below its local width',
    (tester) async {
      await tester.pumpWidget(
        _layoutSubject(
          width: 659,
          composition: CatchResponsiveSectionComposition.adaptiveTwoColumn,
        ),
      );

      final primaryA = tester.getRect(find.byKey(const Key('primary-a')));
      final secondary = tester.getRect(find.byKey(const Key('secondary')));
      final primaryB = tester.getRect(find.byKey(const Key('primary-b')));

      expect(primaryA.width, CatchLayout.maxContentWidth);
      expect(
        primaryA.left,
        closeTo((659 - CatchLayout.maxContentWidth) / 2, 0.1),
      );
      expect(secondary.left, primaryA.left);
      expect(primaryB.left, primaryA.left);
      expect(primaryA.top, lessThan(secondary.top));
      expect(secondary.top, lessThan(primaryB.top));
    },
  );

  testWidgets(
    'adaptive section layout moves complete sections into two lanes',
    (tester) async {
      await tester.pumpWidget(
        _layoutSubject(
          width: 660,
          composition: CatchResponsiveSectionComposition.adaptiveTwoColumn,
        ),
      );

      final primaryA = tester.getRect(find.byKey(const Key('primary-a')));
      final secondary = tester.getRect(find.byKey(const Key('secondary')));
      final primaryB = tester.getRect(find.byKey(const Key('primary-b')));

      expect(primaryA.width, closeTo((660 - CatchGaps.section) / 2, 0.1));
      expect(primaryB.left, primaryA.left);
      expect(primaryB.top, greaterThan(primaryA.bottom));
      expect(secondary.left, closeTo(primaryA.right + CatchGaps.section, 0.1));
      expect(secondary.top, primaryA.top);
    },
  );

  testWidgets('responsive layout selects interaction policy by composition', (
    tester,
  ) async {
    Widget subject(double width) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            child: CatchResponsiveSectionLayout(
              composition: CatchResponsiveSectionComposition.adaptiveTwoColumn,
              sections: [
                CatchResponsiveSectionItem(
                  child: Builder(
                    builder: (context) => Text(
                      'primary:${CatchDividedFieldInteractionScope.interactionOf(context).name}',
                    ),
                  ),
                ),
                CatchResponsiveSectionItem(
                  lane: CatchResponsiveSectionLane.secondary,
                  child: Builder(
                    builder: (context) => Text(
                      'secondary:${CatchDividedFieldInteractionScope.interactionOf(context).name}',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(subject(659));
    expect(find.text('primary:fullBleed'), findsOneWidget);
    expect(find.text('secondary:fullBleed'), findsOneWidget);

    await tester.pumpWidget(subject(660));
    expect(find.text('primary:roundedTile'), findsOneWidget);
    expect(find.text('secondary:roundedTile'), findsOneWidget);
  });

  testWidgets('centered composition remains one capped lane on wide pages', (
    tester,
  ) async {
    await tester.pumpWidget(
      _layoutSubject(
        width: 780,
        composition: CatchResponsiveSectionComposition.centered,
      ),
    );

    final primary = tester.getRect(find.byKey(const Key('primary-a')));
    final secondary = tester.getRect(find.byKey(const Key('secondary')));

    expect(primary.width, CatchLayout.maxContentWidth);
    expect(primary.left, 90);
    expect(secondary.left, primary.left);
    expect(secondary.top, greaterThan(primary.bottom));
  });

  testWidgets(
    'centered full-bleed fields reach the viewport beyond the capped lane',
    (tester) async {
      final previousHighlightStrategy = FocusManager.instance.highlightStrategy;
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () =>
            FocusManager.instance.highlightStrategy = previousHighlightStrategy,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: SizedBox(
              width: 780,
              height: 640,
              child: CatchResponsiveSectionPage(
                sections: [
                  CatchResponsiveSectionItem(
                    child: CatchSection.fieldRows(
                      first: true,
                      children: [
                        CatchField.nav(title: 'Reminder timing', onTap: _noop),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final scope = FocusScope.of(tester.element(find.byType(Scaffold)));
      expect(scope.nextFocus(), isTrue);
      await tester.pump();

      final overlay = tester.getRect(
        find.byKey(const ValueKey<String>('catch-field-active-overlay')),
      );
      expect(overlay.left, 0);
      expect(overlay.right, 780);
    },
  );

  testWidgets('split-pane full bleed is bounded by its owning lane', (
    tester,
  ) async {
    final previousHighlightStrategy = FocusManager.instance.highlightStrategy;
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy = previousHighlightStrategy,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: SizedBox(
            width: 780,
            height: 640,
            child: CatchResponsiveSectionPage(
              composition: CatchResponsiveSectionComposition.adaptiveTwoColumn,
              fieldInteractionPolicy: CatchResponsiveFieldInteractionPolicy(
                splitPane: CatchDividedFieldInteraction.fullBleed,
              ),
              sections: [
                CatchResponsiveSectionItem(
                  child: CatchSection.fieldRows(
                    first: true,
                    children: [CatchField.nav(title: 'Primary', onTap: _noop)],
                  ),
                ),
                CatchResponsiveSectionItem(
                  lane: CatchResponsiveSectionLane.secondary,
                  child: CatchSection.fieldRows(
                    first: true,
                    children: [
                      CatchField.nav(title: 'Secondary', onTap: _noop),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final scope = FocusScope.of(tester.element(find.byType(Scaffold)));
    expect(scope.nextFocus(), isTrue);
    await tester.pump();

    final overlay = tester.getRect(
      find.byKey(const ValueKey<String>('catch-field-active-overlay')).first,
    );
    expect(overlay.left, CatchSpacing.screenPx);
    expect(
      overlay.right,
      closeTo(
        CatchSpacing.screenPx +
            (780 - (2 * CatchSpacing.screenPx) - CatchGaps.section) / 2,
        0.1,
      ),
    );
  });

  testWidgets('responsive page publishes and clears floating shell geometry', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(size: Size(390, 640)),
          child: CatchTabViewportScope(
            index: 0,
            bottomOverlayInset: 88,
            bottomBarPlacement: CatchTabViewportScopePlacement.floating,
            child: Scaffold(
              body: SizedBox(
                width: 390,
                height: 640,
                child: CatchResponsiveSectionPage(
                  sections: [
                    CatchResponsiveSectionItem(
                      child: Builder(
                        builder: (context) {
                          final obstruction = CatchFieldVisibilityScope.maybeOf(
                            context,
                          )?.bottomObstruction;
                          return Text('obstruction:$obstruction');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('obstruction:88.0'), findsOneWidget);
    expect(
      tester.getSize(find.byType(CatchScrollTerminalPadding)).height,
      88 + CatchSpacing.screenPb,
    );

    final bodyPadding = tester.widget<Padding>(
      find
          .descendant(
            of: find.byType(CatchScreenBody),
            matching: find.byType(Padding),
          )
          .first,
    );
    expect(
      bodyPadding.padding,
      const EdgeInsets.fromLTRB(
        CatchSpacing.screenPx,
        CatchSpacing.screenPt,
        CatchSpacing.screenPx,
        0,
      ),
    );
  });
}

void _noop() {}

Widget _layoutSubject({
  required double width,
  required CatchResponsiveSectionComposition composition,
}) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: width,
          child: CatchResponsiveSectionLayout(
            composition: composition,
            sections: const [
              CatchResponsiveSectionItem(
                child: SizedBox(key: Key('primary-a'), height: 80),
              ),
              CatchResponsiveSectionItem(
                lane: CatchResponsiveSectionLane.secondary,
                child: SizedBox(key: Key('secondary'), height: 60),
              ),
              CatchResponsiveSectionItem(
                child: SizedBox(key: Key('primary-b'), height: 40),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
