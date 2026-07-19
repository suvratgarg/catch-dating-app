import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'CatchField centers disclosure status affordances on the value line',
    (tester) async {
      Future<void> pumpStatus(CatchFieldStatus status) => tester.pumpWidget(
        _wrap(
          CatchField.control(
            title: 'Religion',
            body: 'Christian',
            status: status,
            control: const Text('Religion choices'),
          ),
        ),
      );

      await pumpStatus(CatchFieldStatus.saving);
      expect(find.byKey(const ValueKey('catch-field-spinner')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('catch-field-action-bar')),
        findsNothing,
      );
      expect(
        tester.getCenter(find.byType(CatchFieldSpinner)).dy,
        closeTo(tester.getCenter(find.text('Christian')).dy, 0.1),
      );

      await pumpStatus(CatchFieldStatus.saved);
      expect(
        tester.getCenter(find.byIcon(CatchIcons.checkCircleFilled)).dy,
        closeTo(tester.getCenter(find.text('Christian')).dy, 0.1),
      );
    },
  );

  testWidgets('CatchField gives the visible commit bar sole saving progress', (
    tester,
  ) async {
    Future<void> pumpField({
      bool open = true,
      bool isLoading = false,
      CatchFieldStatus status = CatchFieldStatus.idle,
    }) => tester.pumpWidget(
      _wrap(
        CatchField.control(
          title: 'Height',
          body: '168 cm',
          open: open,
          isLoading: isLoading,
          status: status,
          control: const Text('Height control'),
          onCancel: _noop,
          onSubmit: _noop,
        ),
      ),
    );

    await pumpField(status: CatchFieldStatus.saved);
    expect(find.byKey(const ValueKey('catch-field-saved')), findsOneWidget);
    expect(
      tester.widget<Icon>(find.byKey(const ValueKey('catch-field-saved'))).icon,
      CatchIcons.checkCircleFilled,
    );

    await pumpField(isLoading: true);
    expect(find.byKey(const ValueKey('catch-field-spinner')), findsOneWidget);
    expect(find.byType(CatchFieldSpinner), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('catch-field-done')),
        matching: find.byType(CatchFieldSpinner),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(CatchFieldTrailing),
        matching: find.byType(CatchFieldSpinner),
      ),
      findsNothing,
    );
    expect(find.byIcon(CatchIcons.expandMoreRounded), findsOneWidget);
    expect(
      tester.widget<Icon>(find.byIcon(CatchIcons.fieldSpinner)).size,
      CatchFieldTokens.actionSpinnerExtent,
    );
    final spinnerRotation = tester.widget<RotationTransition>(
      find.byKey(const ValueKey('catch-field-spinner')),
    );
    expect(
      (spinnerRotation.turns as AnimationController).duration,
      CatchFieldTokens.spinnerPeriod,
    );
    expect(find.text('Saving…'), findsOneWidget);
    final cancelOpacity = tester.widget<AnimatedOpacity>(
      find.descendant(
        of: find.byKey(const ValueKey('catch-field-cancel')),
        matching: find.byType(AnimatedOpacity),
      ),
    );
    expect(cancelOpacity.opacity, CatchFieldTokens.savingCancelOpacity);
    expect(cancelOpacity.duration, CatchFieldTokens.fast);
    final doneSpinnerRect = tester.getRect(
      find.descendant(
        of: find.byKey(const ValueKey('catch-field-done')),
        matching: find.byIcon(CatchIcons.fieldSpinner),
      ),
    );
    final savingLabelRect = tester.getRect(find.text('Saving…'));
    expect(
      savingLabelRect.left - doneSpinnerRect.right,
      closeTo(CatchFieldTokens.actionButtonSpinnerGap, 0.1),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('catch-field-done'))).height,
      34,
    );

    // The legacy aggregate status input coalesces into the same visible owner.
    await pumpField(status: CatchFieldStatus.saving);
    expect(find.byType(CatchFieldSpinner), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('catch-field-done')),
        matching: find.byType(CatchFieldSpinner),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(CatchFieldTrailing),
        matching: find.byType(CatchFieldSpinner),
      ),
      findsNothing,
    );

    // If the commit bar is not visible, the trailing lane remains the only
    // place where saving progress can be communicated.
    await tester.pumpWidget(const SizedBox.shrink());
    await pumpField(open: false, isLoading: true);
    expect(find.byType(CatchFieldSpinner), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(CatchFieldTrailing),
        matching: find.byType(CatchFieldSpinner),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('catch-field-action-bar')), findsNothing);
  });

  testWidgets('CatchField toggle stays visible and disabled while saving', (
    tester,
  ) async {
    var changes = 0;
    await tester.pumpWidget(
      _wrap(
        CatchField.toggle(
          title: 'Show my pace',
          value: true,
          status: CatchFieldStatus.saving,
          onChanged: (_) => changes++,
        ),
      ),
    );

    expect(find.byKey(const ValueKey('catch-field-toggle')), findsOneWidget);
    expect(find.byType(CatchToggle), findsOneWidget);
    expect(find.byKey(const ValueKey('catch-field-spinner')), findsOneWidget);
    final opacity = tester.widget<AnimatedOpacity>(
      find.descendant(
        of: find.byType(CatchToggle),
        matching: find.byType(AnimatedOpacity),
      ),
    );
    expect(opacity.opacity, CatchFieldTokens.savingToggleOpacity);
    expect(opacity.duration, CatchFieldTokens.standard);
    expect(
      tester
          .widget<AnimatedContainer>(
            find.byKey(const ValueKey('catch-field-toggle-track')),
          )
          .duration,
      CatchFieldTokens.standard,
    );

    await tester.tap(find.byKey(const ValueKey('catch-field-toggle')));
    await tester.tap(find.text('Show my pace'));
    expect(changes, 0);
  });

  testWidgets('CatchField saving Done cannot submit or close local control', (
    tester,
  ) async {
    var submitCount = 0;

    await tester.pumpWidget(
      _wrap(
        CatchField.control(
          title: 'Height',
          initiallyOpen: true,
          isLoading: true,
          control: const Text('Height control'),
          onCancel: () {},
          onSubmit: () => submitCount++,
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('catch-field-done')),
      warnIfMissed: false,
    );
    await _pumpCatchFieldMotion(tester);

    expect(submitCount, 0);
    expect(find.text('Height control'), findsOneWidget);
  });

  testWidgets(
    'CatchField status lane cross-fades saving, scales saved, and drains motion',
    (tester) async {
      var status = CatchFieldStatus.idle;
      late StateSetter update;
      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return CatchField.read(title: 'Club name', status: status);
            },
          ),
        ),
      );

      expect(find.byKey(const ValueKey('catch-field-spinner')), findsNothing);
      expect(find.byKey(const ValueKey('catch-field-saved')), findsNothing);

      update(() => status = CatchFieldStatus.saving);
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const ValueKey('catch-field-spinner')), findsOneWidget);
      expect(
        tester
            .widget<AnimatedSwitcher>(
              find.byKey(const ValueKey('catch-field-status-switcher')),
            )
            .duration,
        CatchMotion.base,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('catch-field-status-switcher')),
          matching: find.byType(FadeTransition),
        ),
        findsWidgets,
      );

      update(() => status = CatchFieldStatus.saved);
      await tester.pump();
      expect(find.byKey(const ValueKey('catch-field-saved')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('catch-field-status-switcher')),
          matching: find.byType(ScaleTransition),
        ),
        findsWidgets,
      );
      await tester.pump(CatchMotion.base);
      await tester.pump(CatchMotion.base);
      expect(find.byKey(const ValueKey('catch-field-spinner')), findsNothing);

      update(() => status = CatchFieldStatus.idle);
      await tester.pump();
      expect(find.byKey(const ValueKey('catch-field-saved')), findsOneWidget);
      await tester.pump(CatchMotion.base);
      await tester.pump(CatchMotion.base);
      await tester.pump(CatchMotion.base);
      await tester.pump();
      expect(find.byKey(const ValueKey('catch-field-saved')), findsNothing);
      expect(find.byKey(const ValueKey('catch-field-spinner')), findsNothing);
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('CatchField status motion becomes a plain reduced-motion swap', (
    tester,
  ) async {
    var status = CatchFieldStatus.idle;
    late StateSetter update;
    await tester.pumpWidget(
      _wrap(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return CatchField.read(title: 'Club name', status: status);
            },
          ),
        ),
      ),
    );

    update(() => status = CatchFieldStatus.saving);
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const ValueKey('catch-field-spinner')), findsOneWidget);
    expect(
      tester
          .widget<AnimatedSwitcher>(
            find.byKey(const ValueKey('catch-field-status-switcher')),
          )
          .duration,
      Duration.zero,
    );
    update(() => status = CatchFieldStatus.saved);
    await tester.pump();
    expect(find.byKey(const ValueKey('catch-field-spinner')), findsNothing);
    expect(find.byKey(const ValueKey('catch-field-saved')), findsOneWidget);

    update(() => status = CatchFieldStatus.idle);
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const ValueKey('catch-field-saved')), findsNothing);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('CatchField cancels a pending status dismissal on dispose', (
    tester,
  ) async {
    var status = CatchFieldStatus.saved;
    late StateSetter update;
    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return CatchField.read(title: 'Club name', status: status);
          },
        ),
      ),
    );

    update(() => status = CatchFieldStatus.idle);
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(CatchMotion.base);

    expect(tester.takeException(), isNull);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('CatchField announces each save transition exactly once', (
    tester,
  ) async {
    final messages = <Map<dynamic, dynamic>>[];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockDecodedMessageHandler<dynamic>(
      SystemChannels.accessibility,
      (message) async {
        messages.add(message as Map<dynamic, dynamic>);
        return null;
      },
    );
    addTearDown(
      () => messenger.setMockDecodedMessageHandler<dynamic>(
        SystemChannels.accessibility,
        null,
      ),
    );

    var status = CatchFieldStatus.idle;
    late StateSetter update;
    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return CatchField.read(title: 'Club name', status: status);
          },
        ),
      ),
    );

    update(() => status = CatchFieldStatus.saving);
    await tester.pump();
    await tester.pump();
    update(() {});
    await tester.pump();
    update(() => status = CatchFieldStatus.saved);
    await tester.pump();
    await tester.pump();

    final announcements = messages
        .where((message) => message['type'] == 'announce')
        .map((message) => (message['data'] as Map<dynamic, dynamic>)['message'])
        .toList();
    expect(announcements, ['Saving', 'Saved']);
  });

  testWidgets('CatchField error takes precedence over saved status', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const CatchField.nav(
          title: 'Club name',
          error: 'Could not save',
          status: CatchFieldStatus.saved,
        ),
      ),
    );

    expect(find.text('Could not save'), findsOneWidget);
    expect(find.byIcon(CatchIcons.fieldWarning), findsOneWidget);
    expect(find.byKey(const ValueKey('catch-field-saved')), findsNothing);
    expect(
      tester.widget<Text>(find.text('Club name')).style?.color,
      CatchTokens.editorialLight.danger,
    );
  });
}

Widget _wrap(Widget child, {ThemeData? theme, double textScale = 1}) {
  return MaterialApp(
    theme: theme ?? AppTheme.light,
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(body: Center(child: child)),
    ),
  );
}

Future<void> _pumpCatchFieldMotion(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(CatchMotion.base);
  await tester.pump();
}

void _noop() {}
