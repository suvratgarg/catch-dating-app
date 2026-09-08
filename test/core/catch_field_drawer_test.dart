import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('drawer preserves content order, gaps and metadata alignment', (
    tester,
  ) async {
    const metaKey = ValueKey('meta');
    const bodyKey = ValueKey('body');
    const actionsKey = ValueKey('actions');
    const footerKey = ValueKey('footer');
    const drawerKey = ValueKey('drawer');
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          key: drawerKey,
          width: 320,
          child: CatchFieldDrawer(
            open: true,
            offstage: false,
            startPadding: 16,
            endPadding: 24,
            bottomPadding: 12,
            revealDuration: Duration.zero,
            opacityDuration: Duration.zero,
            onRevealEnd: _noop,
            meta: SizedBox(key: metaKey, width: 36, height: 14),
            body: SizedBox(key: bodyKey, width: 40, height: 22),
            actions: SizedBox(key: actionsKey, width: 64, height: 32),
            footer: SizedBox(key: footerKey, width: 48, height: 44),
          ),
        ),
      ),
    );
    final drawer = tester.getRect(find.byKey(drawerKey));
    final meta = tester.getRect(find.byKey(metaKey));
    final body = tester.getRect(find.byKey(bodyKey));
    final actions = tester.getRect(find.byKey(actionsKey));
    final footer = tester.getRect(find.byKey(footerKey));
    expect(meta.right, drawer.right - 24);
    expect(meta.top - drawer.top, CatchFieldTokens.controlTopGap);
    expect(body.left, drawer.left + 16);
    expect(actions.left, body.left);
    expect(footer.left, body.left);
    expect(body.top - meta.bottom, CatchSpacing.s2);
    expect(actions.top - body.bottom, CatchSpacing.s2);
    expect(footer.top - actions.bottom, CatchFieldTokens.actionBarTopGap);
    expect(drawer.bottom - footer.bottom, 12);
  });

  testWidgets('closing drawer immediately excludes focus, semantics and taps', (
    tester,
  ) async {
    final focus = FocusNode();
    final semantics = tester.ensureSemantics();
    var activations = 0;
    try {
      Future<void> pumpDrawer(bool open) => tester.pumpWidget(
        _wrap(
          CatchFieldDrawer(
            open: open,
            offstage: false,
            startPadding: 0,
            endPadding: 0,
            bottomPadding: 0,
            revealDuration: CatchMotion.base,
            opacityDuration: CatchMotion.base,
            onRevealEnd: _noop,
            body: TextButton(
              focusNode: focus,
              onPressed: () => activations++,
              child: const Text('Do work'),
            ),
          ),
        ),
      );
      await pumpDrawer(true);
      await tester.pumpAndSettle();
      focus.requestFocus();
      await tester.pump();
      expect(focus.hasFocus, isTrue);
      expect(_accessibilityLabels(tester), contains('Do work'));
      final target = tester.getCenter(find.text('Do work'));

      await pumpDrawer(false);
      await tester.pump();
      expect(focus.hasFocus, isFalse);
      expect(focus.canRequestFocus, isFalse);
      expect(_accessibilityLabels(tester), isNot(contains('Do work')));
      await tester.tapAt(target);
      expect(activations, 0);
      await tester.pumpAndSettle();
      expect(find.text('Do work'), findsNothing);
      expect(tester.takeException(), isNull);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      focus.dispose();
      semantics.dispose();
    }
  });
}

Widget _wrap(Widget child) => MaterialApp(
  theme: CatchTheme.light,
  home: Scaffold(body: Center(child: child)),
);

void _noop() {}

List<String> _accessibilityLabels(WidgetTester tester) {
  final labels = <String>[];
  void visit(SemanticsNode node) {
    labels.add(node.getSemanticsData().label);
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(
    tester.binding.renderViews.single.owner!.semanticsOwner!.rootSemanticsNode!,
  );
  return labels;
}
