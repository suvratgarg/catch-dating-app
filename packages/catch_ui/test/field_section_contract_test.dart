import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('section names wrap above the content-width rule at large text', (
    tester,
  ) async {
    const title = 'Available ways to message this person';
    await tester.pumpWidget(
      MaterialApp(
        theme: CatchTheme.dark,
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: SizedBox(
              width: 390,
              child: CatchSection.rows(
                title: title,
                children: const [
                  CatchField.read(content: CatchPersonLayout(name: 'Riya')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    final header = find.text(title.toUpperCase());
    final paragraph = tester.renderObject<RenderParagraph>(header);
    expect(paragraph.didExceedMaxLines, isFalse);
    expect(
      tester.getRect(header).bottom,
      lessThan(tester.getRect(find.byType(CatchField)).top),
    );
    expect(tester.takeException(), isNull);
  });

  Widget host(Widget child, {TextDirection direction = TextDirection.ltr}) =>
      MaterialApp(
        theme: CatchTheme.dark,
        home: Scaffold(
          body: Directionality(
            textDirection: direction,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(width: 390, child: child),
            ),
          ),
        ),
      );

  CatchField record(String id, VoidCallback onActivate) => CatchField.navigate(
    key: ValueKey(id),
    onActivate: onActivate,
    content: CatchRecordLayout(
      title: id,
      icon: CatchIcons.eventOutlined,
      facts: const ['Sunday · Saket Garden', '2 attended'],
    ),
  );

  testWidgets('full-bleed paint, semantics and both gutters share a target', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var calls = 0;
    await tester.pumpWidget(
      host(
        CatchSection.rows(
          title: 'May 2026',
          children: [record('one', () => calls++), record('two', () {})],
        ),
      ),
    );
    await tester.pumpAndSettle();
    final row = find.byWidgetPredicate(
      (widget) => widget is CatchField && widget.key == const ValueKey('one'),
    );
    final bounds = tester.getRect(row);
    expect(bounds.left, 0);
    expect(bounds.right, 390);
    final semanticBounds = tester
        .getSemantics(
          find.descendant(
            of: row,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Semantics && widget.properties.button == true,
            ),
          ),
        )
        .rect;
    expect(semanticBounds.width, bounds.width);
    expect(semanticBounds.height, bounds.height);
    await tester.tapAt(Offset(1, bounds.center.dy));
    await tester.pumpAndSettle();
    await tester.tapAt(Offset(389, bounds.center.dy));
    await tester.pumpAndSettle();
    expect(calls, 2);

    final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await pointer.addPointer(location: Offset(1, bounds.center.dy));
    await tester.pumpAndSettle();
    final paint = find.descendant(
      of: row,
      matching: find.byKey(CatchField.pressOverlayKey),
    );
    expect(tester.getRect(paint), bounds);
    final decoration =
        tester.widget<AnimatedContainer>(paint).decoration! as BoxDecoration;
    expect(decoration.borderRadius, BorderRadius.zero);
    expect(decoration.color!.a, greaterThan(0));
    await pointer.removePointer();
    semantics.dispose();
  });

  for (final direction in TextDirection.values) {
    testWidgets('header and sibling rules use their own lanes in $direction', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          CatchSection.rows(
            title: 'May 2026',
            children: [record('one', () {}), record('two', () {})],
          ),
          direction: direction,
        ),
      );
      await tester.pumpAndSettle();
      final rules = find.byType(CatchDivider);
      expect(rules, findsNWidgets(2));
      final header = tester.getRect(rules.at(0));
      final sibling = tester.getRect(rules.at(1));
      final title = tester.getRect(find.text('one'));
      expect(header.left, 20);
      expect(header.right, 370);
      if (direction == TextDirection.ltr) {
        expect(sibling.left, title.left);
        expect(sibling.right, header.right);
      } else {
        expect(sibling.right, title.right);
        expect(sibling.left, header.left);
      }
    });
  }

  testWidgets(
    'active neighbors suppress only the sibling rule without movement',
    (tester) async {
      await tester.pumpWidget(
        host(
          CatchSection.rows(
            title: 'May 2026',
            children: [record('one', () {}), record('two', () {})],
          ),
        ),
      );
      await tester.pumpAndSettle();
      final before = tester.getRect(find.text('two'));
      final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await pointer.addPointer(location: tester.getCenter(find.text('two')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
        0,
      );
      expect(find.byType(CatchDivider), findsNWidgets(2));
      expect(tester.getRect(find.text('two')), before);
      await pointer.removePointer();
      await tester.pumpAndSettle();
      expect(
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
        1,
      );
    },
  );

  testWidgets('contained rows have one rounded exterior', (tester) async {
    await tester.pumpWidget(
      host(
        CatchSection.containedRows(
          children: [record('one', () {}), record('two', () {})],
        ),
      ),
    );
    await tester.pumpAndSettle();
    final clip = find.byKey(CatchSectionSurface.rowGroupClipKey);
    expect(clip, findsOneWidget);
    expect(tester.getRect(clip).left, 20);
    expect(tester.getRect(clip).right, 370);
    expect(
      tester.widget<ClipRRect>(clip).borderRadius,
      isNot(BorderRadius.zero),
    );
  });

  testWidgets('Field keeps secondary targets separate and disables both', (
    tester,
  ) async {
    var opened = 0;
    var details = 0;
    Widget screen({bool disabled = false}) => host(
      CatchSection.rows(
        children: [
          CatchField.navigate(
            content: CatchRecordLayout(
              title: 'One event',
              icon: CatchIcons.eventOutlined,
            ),
            onActivate: () => opened++,
            states: {if (disabled) WidgetState.disabled},
            secondaryAction: CatchFieldSecondaryAction.command(
              label: 'Event details',
              icon: CatchIcons.infoOutlineRounded,
              onActivate: () => details++,
            ),
          ),
        ],
      ),
    );
    await tester.pumpWidget(screen());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Event details'));
    await tester.pumpAndSettle();
    expect(details, 1);
    expect(opened, 0);
    final bounds = tester.getRect(find.byType(CatchField));
    await tester.tapAt(Offset(1, bounds.center.dy));
    await tester.pumpAndSettle();
    expect(opened, 1);
    await tester.pumpWidget(screen(disabled: true));
    await tester.pumpAndSettle();
    await tester.tapAt(Offset(1, bounds.center.dy));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(opened, 1);
    expect(details, 1);
  });

  testWidgets('sliver rows build only the visible collection window', (
    tester,
  ) async {
    final built = <int>{};
    await tester.pumpWidget(
      host(
        CustomScrollView(
          slivers: [
            CatchSection.sliverRows(
              title: 'May 2026',
              itemCount: 1000,
              itemBuilder: (context, index) {
                built.add(index);
                return record('event-$index', () {});
              },
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(built.length, lessThan(30));
    expect(built, contains(0));
    expect(built, isNot(contains(999)));
  });

  testWidgets('record and person text stays readable at 2x', (tester) async {
    await tester.pumpWidget(
      host(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: SingleChildScrollView(
            child: CatchSection.rows(
              children: [
                record(
                  'A complete event title that wraps across several lines',
                  () {},
                ),
                const CatchField.read(
                  content: CatchPersonLayout(
                    name: 'A person whose complete name must remain readable',
                    supportingText:
                        'A complete relationship summary and last seen date',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final element in find.byType(RichText).evaluate()) {
      expect(
        (element.renderObject! as RenderParagraph).didExceedMaxLines,
        isFalse,
      );
    }
    expect(tester.takeException(), isNull);
  });
  testWidgets('outer padding cannot silently shrink a full-bleed section', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: CatchTheme.dark,
        home: CatchScaffold.standalone(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CatchSection.rows(children: [record('inset', () {})]),
          ),
        ),
      ),
    );
    expect(
      tester.takeException().toString(),
      contains('must fill its page or pane'),
    );
  });

  testWidgets(
    'master and detail rows fill their own pane, including hit gutters',
    (tester) async {
      var leftTaps = 0;
      var rightTaps = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: CatchTheme.dark,
          home: CatchScaffold.standalone(
            body: CatchMasterDetailViewport(
              expanded: true,
              indexPaneWidth: 320,
              leading: CatchSection.rows(
                children: [record('left', () => leftTaps++)],
              ),
              body: CatchSection.rows(
                children: [record('right', () => rightTaps++)],
              ),
            ),
          ),
        ),
      );
      final left = tester.getRect(find.byKey(const ValueKey('left')));
      final right = tester.getRect(find.byKey(const ValueKey('right')));
      expect(left.left, 0);
      expect(left.right, 320);
      expect(
        right.right,
        tester.view.physicalSize.width / tester.view.devicePixelRatio,
      );
      await tester.tapAt(Offset(left.left + 1, left.center.dy));
      await tester.tapAt(Offset(right.right - 1, right.center.dy));
      expect(leftTaps, 1);
      expect(rightTaps, 1);
      expect(tester.takeException(), isNull);
    },
  );

  test('typed read layout rejects mixed legacy slots', () {
    expect(
      () => CatchField.read(
        content: const CatchPersonLayout(name: 'Person'),
        title: 'Duplicate',
      ),
      throwsAssertionError,
    );
  });
}
