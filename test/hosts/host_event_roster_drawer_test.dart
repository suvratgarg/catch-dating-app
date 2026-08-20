import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_event_roster_drawer.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_pump_helpers.dart';

void main() {
  testWidgets(
    'roster drawer lazily opens without rebuilding the event workspace',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      var open = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 844),
              textScaler: TextScaler.linear(2),
            ),
            child: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) => HostEventRosterDrawer(
                  open: open,
                  bookedCount: 3,
                  onOpenChanged: (next) => setState(() => open = next),
                  body: const SizedBox.expand(
                    key: ValueKey<String>('event-workspace'),
                    child: Text('Live controls'),
                  ),
                  roster: const Text('Roster content'),
                ),
              ),
            ),
          ),
        ),
      );

      final workspaceElement = tester.element(
        find.byKey(const ValueKey<String>('event-workspace')),
      );
      expect(find.text('Roster content'), findsNothing);
      expect(
        find.bySemanticsLabel('Open guest roster, 3 booked guests'),
        findsOneWidget,
      );

      await tester.tap(
        find.bySemanticsLabel('Open guest roster, 3 booked guests'),
      );
      await pumpFeatureUi(tester);

      expect(find.text('Roster content'), findsOneWidget);
      expect(
        identical(
          workspaceElement,
          tester.element(find.byKey(const ValueKey<String>('event-workspace'))),
        ),
        isTrue,
      );
      expect(tester.takeException(), isNull);
      final panelRect = tester.getRect(
        find.byKey(const ValueKey<String>('host_event_roster_drawer.panel')),
      );
      expect(panelRect.right, closeTo(390, 0.5));
      expect(panelRect.width, lessThanOrEqualTo(390));

      await tester.tap(
        find.descendant(
          of: find.byKey(
            const ValueKey<String>('host_event_roster_drawer.handle'),
          ),
          matching: find.bySemanticsLabel('Close guest roster'),
        ),
      );
      await pumpFeatureUi(tester);
      expect(
        find.bySemanticsLabel('Open guest roster, 3 booked guests'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('contextual roster entry can hide the legacy edge handle', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    bool? nextOpen;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: HostEventRosterDrawer(
            open: true,
            bookedCount: 3,
            showHandle: false,
            onOpenChanged: (next) => nextOpen = next,
            body: const Text('Live controls'),
            roster: const Text('Roster content'),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('host_event_roster_drawer.handle')),
      findsNothing,
    );
    expect(find.text('Roster content'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Close guest roster'));
    await tester.pump();
    expect(nextOpen, isFalse);
  });
}
