import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final direction in TextDirection.values) {
    testWidgets('deep paths retain all columns and resize in $direction', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1000, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          theme: CatchTheme.dark,
          home: Directionality(
            textDirection: direction,
            child: CatchScaffold.standalone(
              body: CatchNavigationViewport(
                resizeLabel: 'Resize column',
                panes: [
                  for (var i = 0; i < 5; i++)
                    CatchWorkspacePane(
                      id: '$i',
                      child: SizedBox.expand(
                        key: ValueKey('content-$i'),
                        child: Text('Level $i'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Level 0'), findsOneWidget);
      expect(find.text('Level 4'), findsOneWidget);
      final strip = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(strip.controller!.position.maxScrollExtent, greaterThan(0));
      expect(
        strip.controller!.offset,
        strip.controller!.position.maxScrollExtent,
      );
      final last = find.byKey(const ValueKey(('catch-workspace-divider', '4')));
      final before = tester
          .getSize(find.byKey(const ValueKey('content-4')))
          .width;
      await tester.drag(
        last,
        Offset(direction == TextDirection.rtl ? -100 : 100, 0),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byKey(const ValueKey('content-4'))).width,
        greaterThan(before),
      );
      Focus.of(tester.element(last)).requestFocus();
      await tester.pump();
      final width = tester
          .getSize(find.byKey(const ValueKey('content-4')))
          .width;
      await tester.sendKeyEvent(
        direction == TextDirection.rtl
            ? LogicalKeyboardKey.arrowLeft
            : LogicalKeyboardKey.arrowRight,
      );
      await tester.pump();
      expect(
        tester.getSize(find.byKey(const ValueKey('content-4'))).width,
        width + CatchSpacing.s4,
      );
      expect(tester.takeException(), isNull);
      semantics.dispose();
    });
  }
  testWidgets(
    'compact presentation preserves the same ancestor draft and widths',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1000, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: CatchTheme.light,
          home: CatchScaffold.standalone(
            body: CatchNavigationViewport(
              panes: [
                CatchWorkspacePane(
                  id: 'list',
                  child: Material(
                    child: TextField(
                      key: const ValueKey('draft'),
                      controller: controller,
                    ),
                  ),
                ),
                const CatchWorkspacePane(
                  id: 'record',
                  child: Text('Selected record'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('draft')), 'Retain me');
      final element = tester.element(find.byKey(const ValueKey('draft')));
      await tester.drag(
        find.byKey(const ValueKey(('catch-workspace-divider', 'list'))),
        const Offset(100, 0),
      );
      await tester.pump();
      final width = tester.getSize(find.byKey(const ValueKey('draft'))).width;
      tester.view.physicalSize = const Size(390, 800);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('draft')), findsNothing);
      expect(find.text('Selected record'), findsOneWidget);
      expect(
        find.byKey(const ValueKey(('catch-workspace-divider', 'list'))),
        findsNothing,
      );
      tester.view.physicalSize = const Size(1000, 800);
      await tester.pumpAndSettle();
      expect(
        tester.element(find.byKey(const ValueKey('draft'))),
        same(element),
      );
      expect(controller.text, 'Retain me');
      expect(tester.getSize(find.byKey(const ValueKey('draft'))).width, width);
      expect(tester.takeException(), isNull);
    },
  );
}
