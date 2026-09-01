import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
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
    var messageGuests = false;
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
            onMessageGuests: () => messageGuests = true,
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

    await tester.tap(find.bySemanticsLabel('Message guests'));
    await tester.pump();
    expect(messageGuests, isTrue);

    await tester.tap(find.bySemanticsLabel('Close guest roster'));
    await tester.pump();
    expect(nextOpen, isFalse);
  });

  testWidgets('wide drawer uses the viewport edge and keeps its body capped', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 1000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    var open = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => HostEventRosterDrawer(
              open: open,
              bookedCount: 3,
              onOpenChanged: (next) => setState(() => open = next),
              body: const SizedBox.expand(
                key: ValueKey<String>('event-workspace'),
                child: Text('Event workspace'),
              ),
              roster: const Text('Roster content'),
            ),
          ),
        ),
      ),
    );

    final workspace = find.byKey(const ValueKey<String>('event-workspace'));
    final workspaceElement = tester.element(workspace);
    final workspaceRect = tester.getRect(workspace);
    final closedPanelRect = tester.getRect(
      find.byKey(const ValueKey<String>('host_event_roster_drawer.panel')),
    );
    expect(workspaceRect.width, CatchLayout.maxContentWidth);
    expect(workspaceRect.center.dx, 720);
    expect(closedPanelRect.left, 1440);
    expect(find.text('Roster content'), findsNothing);

    await tester.tap(
      find.bySemanticsLabel('Open guest roster, 3 booked guests'),
    );
    await pumpFeatureUi(tester);

    final openPanelRect = tester.getRect(
      find.byKey(const ValueKey<String>('host_event_roster_drawer.panel')),
    );
    expect(openPanelRect.right, 1440);
    expect(openPanelRect.width, CatchLayout.hostRosterDrawerMaxWidth);
    expect(find.text('Roster content'), findsOneWidget);
    expect(identical(workspaceElement, tester.element(workspace)), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('live workspace can opt into the wider bounded body lane', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 1000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: HostEventRosterDrawer(
            open: false,
            bookedCount: 3,
            bodyMaxWidth: CatchLayout.hostEventLiveWorkspaceMaxContentWidth,
            onOpenChanged: (_) {},
            body: const SizedBox.expand(
              key: ValueKey<String>('live-workspace'),
            ),
            roster: const SizedBox.shrink(),
          ),
        ),
      ),
    );

    final workspaceRect = tester.getRect(
      find.byKey(const ValueKey<String>('live-workspace')),
    );
    expect(
      workspaceRect.width,
      CatchLayout.hostEventLiveWorkspaceMaxContentWidth,
    );
    expect(workspaceRect.center.dx, 720);
    expect(tester.takeException(), isNull);
  });
}
