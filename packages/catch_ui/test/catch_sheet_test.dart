import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'whole-sheet scrolling exposes a keyboard-safe footer at $scale',
      (tester) async {
        var saved = false;
        const viewportKey = ValueKey('sheet-viewport');
        await tester.pumpWidget(
          MaterialApp(
            theme: CatchTheme.light,
            home: Scaffold(
              body: MediaQuery(
                data: MediaQueryData(
                  textScaler: TextScaler.linear(scale),
                  viewInsets: const EdgeInsets.only(bottom: 180),
                  viewPadding: const EdgeInsets.only(bottom: 24),
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    key: viewportKey,
                    width: 440,
                    height: 500,
                    child: CatchSheet(
                      title: 'Edit details',
                      keyboardSafe: true,
                      mode: CatchSheetMode.scrollable,
                      // Caller padding cannot remove the terminal safe region.
                      padding: const EdgeInsets.all(8),
                      footer: CatchButton(
                        label: 'Save',
                        onPressed: () => saved = true,
                      ),
                      child: const SizedBox(
                        height: 800,
                        child: Text('Long body'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        final footer = find.widgetWithText(CatchButton, 'Save');
        final viewport = tester.getRect(find.byKey(viewportKey));
        expect(tester.getTopLeft(footer).dy, greaterThan(viewport.bottom));
        expect(find.byType(Scrollable), findsOneWidget);
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -1600),
        );
        await tester.pumpAndSettle();
        final footerRect = tester.getRect(footer);
        expect(footerRect.top, greaterThanOrEqualTo(viewport.top));
        expect(
          viewport.bottom - footerRect.bottom,
          closeTo(180 + CatchLayout.sheetBottomSafeAreaGap, 0.01),
        );
        await tester.tap(footer);
        await tester.pumpAndSettle();
        expect(saved, isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('content mode retains body-owned scrolling and a fixed footer', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: CatchTheme.light,
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 440,
              height: 500,
              child: CatchSheet(
                title: 'Choose a city',
                footer: CatchButton(label: 'Done', onPressed: () {}),
                child: SizedBox(
                  height: 240,
                  child: ListView.builder(
                    controller: controller,
                    itemCount: 30,
                    itemExtent: 48,
                    itemBuilder: (_, index) => Text('City $index'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.byType(Scrollable), findsOneWidget);
    final footer = find.widgetWithText(CatchButton, 'Done');
    final footerBefore = tester.getRect(footer);
    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pumpAndSettle();
    expect(controller.offset, greaterThan(0));
    expect(tester.getRect(footer), footerBefore);
    expect(tester.takeException(), isNull);
  });
}
