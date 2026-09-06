import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_distance_ring.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_range_slider.dart';
import 'package:catch_dating_app/core/widgets/catch_screen_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_search_field.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_rail.dart';
import 'package:catch_dating_app/core/widgets/catch_toggle.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _controlKey = ValueKey('control-under-test');
typedef _ControlBuilder = Widget Function(VoidCallback? activate);

void main() {
  final controls = <String, _ControlBuilder>{
    'toggle': (activate) => CatchToggle(
      key: _controlKey,
      value: false,
      semanticLabel: 'Go',
      onChanged: activate == null ? null : (_) => activate(),
    ),
    'field toggle': (activate) => CatchToggle.field(
      key: _controlKey,
      value: false,
      semanticLabel: 'Go',
      onChanged: activate == null ? null : (_) => activate(),
    ),
    'field choice': (activate) => CatchFieldChoiceChip(
      key: _controlKey,
      label: 'Go',
      selected: false,
      multi: false,
      enabled: activate != null,
      onPressed: () => activate?.call(),
    ),
    'field repeat': (activate) => CatchFieldRepeatButton(
      key: _controlKey,
      icon: Icons.add,
      semanticLabel: 'Go',
      enabled: activate != null,
      onStep: () => activate?.call(),
    ),
    'field commit': (activate) => CatchFieldCommitButton(
      key: _controlKey,
      label: 'Go',
      onPressed: activate,
    ),
    'distance label': (activate) => CatchDistanceRingLabel(
      key: _controlKey,
      label: '3 km',
      onTap: activate,
    ),
    'small row press surface': (activate) => CatchRowPressSurface(
      key: _controlKey,
      onTap: activate,
      expandToMaxWidth: false,
      child: const Text('Go'),
    ),
    'small button': (activate) => CatchButton(
      key: _controlKey,
      label: 'Go',
      size: CatchButtonSize.sm,
      onPressed: activate,
    ),
    'command': (activate) =>
        CatchButton.command(key: _controlKey, label: 'Go', onPressed: activate),
    'selection trigger': (activate) => CatchButton.selection(
      key: _controlKey,
      label: 'Go',
      onPressed: activate,
    ),
    'explicit small icon': (activate) => CatchIconButton(
      key: _controlKey,
      size: 20,
      tooltip: 'Go',
      onTap: activate,
      child: const Icon(Icons.add),
    ),
    'top-bar icon': (activate) => CatchIconAction(
      key: _controlKey,
      icon: Icons.add,
      tooltip: 'Go',
      onPressed: activate,
    ),
    'top-bar primary': (activate) => CatchTopBarPrimaryAction(
      key: _controlKey,
      icon: Icons.add,
      label: 'Go',
      onPressed: activate,
    ),
    'text button with compact overrides': (activate) => CatchTextButton(
      key: _controlKey,
      label: 'Go',
      onPressed: activate,
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
    ),
    'selectable chip': (activate) => CatchChip.selectable(
      key: _controlKey,
      label: 'Go',
      selected: false,
      enabled: activate != null,
      onChanged: (_) => activate?.call(),
    ),
    'removable chip': (activate) => CatchChip.removable(
      key: _controlKey,
      label: 'Go',
      enabled: activate != null,
      onRemove: () => activate?.call(),
    ),
    'compact control shell': (activate) => CatchControlShell(
      key: _controlKey,
      size: CatchControlSize.compact,
      semanticButton: true,
      enabled: activate != null,
      onTap: activate,
      child: const Text('Go'),
    ),
  };

  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    for (final scale in [1.0, 2.0]) {
      for (final entry in controls.entries) {
        testWidgets('${entry.key} reserves a real target at $scale $platform', (
          tester,
        ) async {
          debugDefaultTargetPlatformOverride = platform;
          addTearDown(() => debugDefaultTargetPlatformOverride = null);
          var activations = 0;
          await _pump(tester, entry.value(() => activations++), scale: scale);
          final control = find.byKey(_controlKey);
          final rect = tester.getRect(control);
          final minimum = CatchPlatformTokens.minimumInteractiveExtent;
          expect(rect.width, greaterThanOrEqualTo(minimum));
          expect(rect.height, greaterThanOrEqualTo(minimum));
          final node = tester.getSemantics(control);
          expect(node.rect.width, greaterThanOrEqualTo(minimum));
          expect(node.rect.height, greaterThanOrEqualTo(minimum));
          final tapNodes = _tapNodes(node);
          expect(tapNodes, isNotEmpty);
          for (final tapNode in tapNodes) {
            expect(tapNode.rect.width, greaterThanOrEqualTo(minimum));
            expect(tapNode.rect.height, greaterThanOrEqualTo(minimum));
          }
          // The edge is outside small visual circles/pills. This proves that
          // the layout floor belongs to the gesture owner, not an inert parent.
          await tester.tapAt(Offset(rect.center.dx, rect.top + 2));
          await tester.pump();
          expect(activations, 1);
          expect(tester.takeException(), isNull);
          debugDefaultTargetPlatformOverride = null;
        });
      }

      for (final variant in CatchOptionGroupVariant.values) {
        testWidgets('$variant choices retain targets at $scale $platform', (
          tester,
        ) async {
          debugDefaultTargetPlatformOverride = platform;
          addTearDown(() => debugDefaultTargetPlatformOverride = null);
          var selected = 1;
          await _pump(
            tester,
            SizedBox(
              width: 280,
              child: CatchOptionGroup<int>(
                variant: variant,
                selected: 1,
                options: const [
                  CatchOption(value: 1, label: 'Upcoming'),
                  CatchOption(
                    value: 2,
                    label: 'Historical events',
                    semanticLabel: 'Show historical events',
                  ),
                ],
                onChanged: (value) => selected = value,
              ),
            ),
            scale: scale,
          );
          final items = find.byType(CatchOptionGroupItem<int>);
          for (final item in items.evaluate()) {
            final size = tester.getSize(find.byWidget(item.widget));
            expect(
              size.height,
              greaterThanOrEqualTo(
                CatchPlatformTokens.minimumInteractiveExtent,
              ),
            );
            expect(
              size.width,
              greaterThanOrEqualTo(
                CatchPlatformTokens.minimumInteractiveExtent,
              ),
            );
          }
          _expectReadable(tester);
          final last = items.last;
          await tester.ensureVisible(last);
          final actionNodes = _tapNodes(tester.getSemantics(last));
          expect(actionNodes, isNotEmpty);
          for (final node in actionNodes) {
            expect(
              node.rect.height,
              greaterThanOrEqualTo(
                CatchPlatformTokens.minimumInteractiveExtent,
              ),
            );
          }
          await tester.tap(last);
          expect(selected, 2);
          expect(tester.takeException(), isNull);
          debugDefaultTargetPlatformOverride = null;
        });
      }

      testWidgets('rail target agrees with reserved slot at $scale $platform', (
        tester,
      ) async {
        debugDefaultTargetPlatformOverride = platform;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        for (final variant in [
          CatchOptionGroupVariant.label,
          CatchOptionGroupVariant.operational,
        ]) {
          await _pump(
            tester,
            SizedBox(
              width: 300,
              child: CatchTabRail<int>(
                variant: variant,
                selected: 1,
                options: const [
                  CatchOption(value: 1, label: 'Now'),
                  CatchOption(value: 2, label: 'Guests'),
                ],
                onChanged: (_) {},
              ),
            ),
            scale: scale,
          );
          final rail = find.byType(CatchTabRail<int>);
          final widget = tester.widget<CatchTabRail<int>>(rail);
          expect(
            tester.getSize(rail).height,
            widget.preferredSizeFor(tester.element(rail)).height,
          );
          final bounds = tester.getRect(rail);
          for (final item
              in find.byType(CatchOptionGroupItem<int>).evaluate()) {
            final rect = tester.getRect(find.byWidget(item.widget));
            expect(
              rect.height,
              greaterThanOrEqualTo(
                CatchPlatformTokens.minimumInteractiveExtent,
              ),
            );
            expect(rect.top, greaterThanOrEqualTo(bounds.top));
            expect(rect.bottom, lessThanOrEqualTo(bounds.bottom));
          }
          expect(tester.takeException(), isNull);
        }
        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('buttons and chips reflow meaning at $scale $platform', (
        tester,
      ) async {
        debugDefaultTargetPlatformOverride = platform;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        await _pump(
          tester,
          SizedBox(
            width: 190,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                CatchButton(
                  label: 'Continue with the selected organizer',
                  size: CatchButtonSize.sm,
                  onPressed: () {},
                ),
                CatchTextButton(
                  label: 'Retry saving these changes',
                  onPressed: () {},
                ),
                CatchChip.selectable(
                  label: 'Only people who attended before',
                  selected: true,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
          scale: scale,
        );
        _expectReadable(tester);
        expect(tester.takeException(), isNull);
        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('search open and clear targets at $scale $platform', (
        tester,
      ) async {
        debugDefaultTargetPlatformOverride = platform;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        var opened = false;
        await _pump(
          tester,
          CatchSearchField.expanding(
            key: _controlKey,
            tooltip: 'Search',
            expanded: false,
            collapsedExtent: 20,
            onOpenSearch: () => opened = true,
          ),
          scale: scale,
        );
        final rect = tester.getRect(find.byKey(_controlKey));
        expect(
          rect.width,
          greaterThanOrEqualTo(CatchPlatformTokens.minimumInteractiveExtent),
        );
        expect(
          rect.height,
          greaterThanOrEqualTo(CatchPlatformTokens.minimumInteractiveExtent),
        );
        await tester.tapAt(Offset(rect.left + 2, rect.center.dy));
        expect(opened, isTrue);
        await _pump(
          tester,
          const SizedBox(
            width: 300,
            child: CatchSearchField(value: 'Old query', placeholder: 'Search'),
          ),
          scale: scale,
        );
        final clear = find.byType(CatchIconButton);
        expect(
          tester.getSize(clear).height,
          greaterThanOrEqualTo(CatchPlatformTokens.minimumInteractiveExtent),
        );
        await tester.tap(clear);
        expect(find.text('Old query'), findsNothing);
        expect(tester.takeException(), isNull);
        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets(
        'field clear target is reserved and contained at $scale $platform',
        (tester) async {
          debugDefaultTargetPlatformOverride = platform;
          addTearDown(() => debugDefaultTargetPlatformOverride = null);
          final controller = TextEditingController(
            text:
                'A long public organizer name that fills the available value lane',
          );
          addTearDown(controller.dispose);
          await _pump(
            tester,
            SizedBox(
              width: 280,
              child: CatchField.input(
                key: _controlKey,
                title: 'Public name',
                controller: controller,
                showClearButton: true,
              ),
            ),
            scale: scale,
          );
          final field = tester.getRect(find.byKey(_controlKey));
          final clear = find.byTooltip('Clear Public name');
          final target = tester.getRect(clear);
          final value = tester.getRect(find.byType(EditableText));
          final minimum = CatchPlatformTokens.minimumInteractiveExtent;
          expect(target.size.width, greaterThanOrEqualTo(minimum));
          expect(target.size.height, greaterThanOrEqualTo(minimum));
          expect(target.left, greaterThanOrEqualTo(value.right));
          expect(target.top, greaterThanOrEqualTo(field.top));
          expect(target.bottom, lessThanOrEqualTo(field.bottom));
          final nodes = _tapNodes(tester.getSemantics(clear));
          expect(nodes, isNotEmpty);
          for (final node in nodes) {
            expect(node.rect.height, greaterThanOrEqualTo(minimum));
            expect(node.rect.width, greaterThanOrEqualTo(minimum));
          }
          await tester.tapAt(Offset(target.center.dx, target.bottom - 2));
          await tester.pump();
          expect(controller.text, isEmpty);
          expect(tester.takeException(), isNull);
          debugDefaultTargetPlatformOverride = null;
        },
      );
    }

    testWidgets('small siblings have disjoint touch targets on $platform', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = platform;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      var left = 0;
      var right = 0;
      await _pump(
        tester,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CatchIconButton(
              size: 20,
              tooltip: 'Left',
              onTap: () => left++,
              child: const Icon(Icons.chevron_left),
            ),
            CatchIconButton(
              size: 20,
              tooltip: 'Right',
              onTap: () => right++,
              child: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      );
      final icons = find.byType(CatchIconButton);
      final first = tester.getRect(icons.first);
      final second = tester.getRect(icons.last);
      expect(first.right, lessThanOrEqualTo(second.left));
      await tester.tapAt(Offset(first.right - 2, first.center.dy));
      await tester.tapAt(Offset(second.left + 2, second.center.dy));
      expect(left, 1);
      expect(right, 1);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('range render target is not only semantic on $platform', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = platform;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      await _pump(
        tester,
        SizedBox(
          width: 300,
          child: CatchRangeSlider(
            values: const RangeValues(20, 80),
            onChanged: (_) {},
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(RangeSlider)).height,
        greaterThanOrEqualTo(CatchPlatformTokens.minimumInteractiveExtent),
      );
      expect(tester.takeException(), isNull);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
      'top-bar does not compress multiple action targets on $platform',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(320, 640);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        debugDefaultTargetPlatformOverride = platform;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SizedBox(
              width: 320,
              child: CatchScreenScaffold.workspace(
                appBar: CatchTopBar(
                  title: 'Workspace',
                  leadingType: CatchTopBarLeading.none,
                  actions: [
                    for (var i = 0; i < 3; i++)
                      CatchIconAction(
                        icon: Icons.add,
                        tooltip: 'Action $i',
                        onPressed: () {},
                      ),
                  ],
                ),
                body: const SizedBox.shrink(),
              ),
            ),
          ),
        );
        for (final item in find.byType(CatchIconButton).evaluate()) {
          expect(
            tester.getSize(find.byWidget(item.widget)).width,
            greaterThanOrEqualTo(CatchPlatformTokens.minimumInteractiveExtent),
          );
        }
        expect(tester.takeException(), isNull);
        debugDefaultTargetPlatformOverride = null;
      },
    );
  }

  for (final entry in controls.entries) {
    testWidgets('${entry.key} disables pointer and semantics consistently', (
      tester,
    ) async {
      await _pump(tester, entry.value(null));
      final data = tester
          .getSemantics(find.byKey(_controlKey))
          .getSemanticsData();
      expect(data.hasAction(SemanticsAction.tap), isFalse);
      expect(_tapNodes(tester.getSemantics(find.byKey(_controlKey))), isEmpty);
      expect(data.flagsCollection.isEnabled.toBoolOrNull(), isNot(true));
      expect(tester.takeException(), isNull);
    });
  }

  for (final name in [
    'small button',
    'explicit small icon',
    'selectable chip',
  ]) {
    testWidgets('$name preserves keyboard activation', (tester) async {
      var calls = 0;
      await _pump(tester, controls[name]!(() => calls++));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(calls, 1);
    });
  }

  testWidgets('action menu inherits the canonical trigger target', (
    tester,
  ) async {
    await _pump(
      tester,
      CatchActionMenu<int>(
        tooltip: 'More actions',
        items: const [CatchActionMenuItem(value: 1, label: 'Edit')],
        onSelected: (_) {},
      ),
    );
    final trigger = find.byType(CatchIconButton);
    expect(
      tester.getSize(trigger).height,
      greaterThanOrEqualTo(CatchPlatformTokens.minimumInteractiveExtent),
    );
    await tester.tap(trigger);
    await tester.pump();
    expect(find.text('Edit'), findsOneWidget);
  });

  testWidgets('count pill action keeps a real semantic target', (tester) async {
    var calls = 0;
    await _pump(
      tester,
      CatchCountPill.label(
        key: _controlKey,
        label: 'Filters',
        count: 2,
        semanticLabel: 'Two filters',
        onPressed: () => calls++,
      ),
      scale: 2,
    );
    final nodes = _tapNodes(tester.getSemantics(find.byKey(_controlKey)));
    expect(nodes, isNotEmpty);
    for (final node in nodes) {
      expect(
        node.rect.height,
        greaterThanOrEqualTo(CatchPlatformTokens.minimumInteractiveExtent),
      );
    }
    await tester.tap(find.byKey(_controlKey));
    expect(calls, 1);
    _expectReadable(tester);
  });

  testWidgets('primary options and search respect reduced motion', (
    tester,
  ) async {
    await _pump(
      tester,
      SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CatchOptionGroup<int>(
              selected: 0,
              onChanged: (_) {},
              options: const [
                CatchOption(value: 0, label: 'Now'),
                CatchOption(value: 1, label: 'Later'),
              ],
            ),
            CatchSearchField.expanding(expanded: false, onOpenSearch: () {}),
          ],
        ),
      ),
      disableAnimations: true,
    );
    for (final widget in tester.widgetList<AnimatedContainer>(
      find.byType(AnimatedContainer),
    )) {
      expect(widget.duration, Duration.zero);
    }
    expect(
      tester
          .widget<TweenAnimationBuilder<double>>(
            find.byType(TweenAnimationBuilder<double>),
          )
          .duration,
      Duration.zero,
    );
  });

  testWidgets('icon hover and press paint inside its unchanged visual circle', (
    tester,
  ) async {
    await _pump(
      tester,
      CatchIconButton(
        size: 20,
        tooltip: 'Open',
        onTap: () {},
        child: const Icon(Icons.add),
      ),
    );
    Color? fill() =>
        tester.widget<CatchSurface>(find.byType(CatchSurface)).backgroundColor;
    final resting = fill();
    final visualRect = tester.getRect(find.byType(CatchSurface));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(400, 400));
    await mouse.moveTo(tester.getCenter(find.byType(CatchIconButton)));
    await tester.pump();
    final hovered = fill();
    expect(hovered, isNot(resting));
    expect(tester.getRect(find.byType(CatchSurface)), visualRect);
    await mouse.down(tester.getCenter(find.byType(CatchIconButton)));
    await tester.pump();
    expect(fill(), isNot(hovered));
    await mouse.up();
    await mouse.removePointer();
  });

  testWidgets('chip hover is visible inside opaque chip chrome', (
    tester,
  ) async {
    await _pump(
      tester,
      CatchChip.selectable(label: 'Guests', selected: false, onChanged: (_) {}),
    );
    Color? fill() =>
        (tester
                    .widget<AnimatedContainer>(
                      find.descendant(
                        of: find.byType(CatchChip),
                        matching: find.byType(AnimatedContainer),
                      ),
                    )
                    .decoration
                as BoxDecoration)
            .color;
    final resting = fill();
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(400, 400));
    await mouse.moveTo(tester.getCenter(find.byType(CatchChip)));
    await tester.pump();
    expect(fill(), isNot(resting));
    await mouse.removePointer();
  });
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  double scale = 1,
  bool disableAnimations = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light.copyWith(visualDensity: VisualDensity.compact),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(
            textScaler: TextScaler.linear(scale),
            disableAnimations: disableAnimations,
          ),
          child: SingleChildScrollView(
            child: Align(alignment: Alignment.topLeft, child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void _expectReadable(WidgetTester tester) {
  for (final element in find.byType(RichText).evaluate()) {
    final paragraph = element.renderObject! as RenderParagraph;
    expect(
      paragraph.didExceedMaxLines,
      isFalse,
      reason: (element.widget as RichText).text.toPlainText(),
    );
  }
}

List<SemanticsNode> _tapNodes(SemanticsNode root) {
  final result = <SemanticsNode>[];
  void visit(SemanticsNode node) {
    if (node.getSemanticsData().hasAction(SemanticsAction.tap)) {
      result.add(node);
    }
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(root);
  return result;
}
