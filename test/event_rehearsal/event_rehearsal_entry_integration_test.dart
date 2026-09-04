import 'dart:async';

import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal_configuration.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/event_rehearsal_controller.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/event_rehearsal_entry_view_model.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/host_event_rehearsal_start_screen.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/route_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../test_pump_helpers.dart';
import 'event_rehearsal_configuration_test.dart' show rehearsalSourceEvent;

void main() {
  testWidgets(
    'Start submits the source configuration once and opens its runtime',
    (tester) async {
      final controller = _Controller();
      final completion = Completer<EventRehearsalCreated>();
      controller.completion = completion;
      final router = _router();
      addTearDown(router.dispose);
      await tester.pumpWidget(_app(router, controller));
      await pumpFeatureUi(tester);
      expect(find.textContaining('18 attendees'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      await tester.tap(find.text('Start rehearsal'));
      await tester.pump();
      expect(controller.calls, 1);
      expect(controller.guestSource, 'event');
      expect(controller.sourceEventId, 'event-1');
      expect(controller.actorCount, 18);
      expect(controller.startImmediately, isTrue);
      expect(controller.setup?.title, 'Saturday singles mixer');
      expect(controller.setup?.successDefaults, isNotNull);
      final button = tester.widget<CatchButton>(
        find.byWidgetPredicate(
          (widget) =>
              widget is CatchButton && widget.label == 'Start rehearsal',
        ),
      );
      expect(button.onPressed, isNull);
      completion.complete(_created);
      await pumpFeatureUi(tester);
      expect(find.text('runtime: session-new'), findsOneWidget);
    },
  );

  testWidgets(
    'custom guest count and event details reach creation and survive a failure',
    (tester) async {
      final controller = _Controller()..failFirst = true;
      final router = _router();
      addTearDown(router.dispose);
      await tester.pumpWidget(_app(router, controller));
      await pumpFeatureUi(tester);
      await tester.ensureVisible(find.text('Customise rehearsal'));
      await tester.tap(find.text('Customise rehearsal'));
      await pumpFeatureUi(tester);
      await tester.tap(find.text('Use simulated guests'));
      await pumpFeatureUi(tester);
      final count = find.descendant(
        of: find.widgetWithText(CatchField, 'Number of simulated guests'),
        matching: find.byType(TextField),
      );
      await tester.ensureVisible(count);
      await tester.enterText(count, '31');
      await tester.ensureVisible(find.text('Event details'));
      await tester.tap(find.text('Event details'));
      await pumpFeatureUi(tester);
      final title = find.descendant(
        of: find.widgetWithText(CatchField, 'Event title'),
        matching: find.byType(TextField),
      );
      await tester.ensureVisible(title);
      await tester.enterText(title, 'Only this practice copy');
      await tester.tap(find.text('Done'));
      await pumpFeatureUi(tester);
      await tester.tap(find.text('Start rehearsal'));
      await pumpFeatureUi(tester);
      expect(controller.guestSource, 'simulated');
      expect(controller.actorCount, 31);
      expect(controller.setup?.title, 'Only this practice copy');
      expect(find.text('Custom settings · Edit or reset'), findsOneWidget);
      ScaffoldMessenger.of(
        tester.element(find.byType(HostEventRehearsalStartScreen)),
      ).removeCurrentSnackBar();
      await pumpFeatureUi(tester);
      expect(
        tester
            .widget<CatchButton>(
              find.byWidgetPredicate(
                (widget) =>
                    widget is CatchButton && widget.label == 'Start rehearsal',
              ),
            )
            .onPressed,
        isNotNull,
      );
      await tester.tap(find.text('Start rehearsal'));
      await pumpFeatureUi(tester);
      expect(controller.calls, 2);
      expect(controller.setup?.title, 'Only this practice copy');
      expect(find.text('runtime: session-new'), findsOneWidget);
    },
  );
}

GoRouter _router() => GoRouter(
  initialLocation: '/start',
  routes: [
    GoRoute(
      path: '/start',
      builder: (_, state) =>
          const HostEventRehearsalStartScreen(clubId: 'club-1'),
    ),
    GoRoute(
      path: '/runtime/:clubId/:sessionId',
      name: Routes.hostEventRehearsalScreen.name,
      builder: (_, state) =>
          Scaffold(body: Text('runtime: ${state.pathParameters['sessionId']}')),
    ),
  ],
);

Widget _app(GoRouter router, _Controller controller) => ProviderScope(
  overrides: [
    eventRehearsalControllerProvider.overrideWith(() => controller),
    eventRehearsalEntryProvider('club-1', null).overrideWith(
      (ref) async => EventRehearsalEntryData(
        organizerDefaults: const ClubHostDefaults(),
        events: [rehearsalSourceEvent()],
        initialConfiguration: EventRehearsalConfiguration.defaults(
          organizerDefaults: const ClubHostDefaults(),
          event: rehearsalSourceEvent(),
          sourceGuestCount: 18,
        ),
      ),
    ),
  ],
  child: MaterialApp.router(
    theme: AppTheme.light,
    routerConfig: router,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  ),
);

const _created = EventRehearsalCreated(
  sessionId: 'session-new',
  guestUrl: 'https://example.test/practice',
  setupRevision: 0,
  runtimeRevision: 0,
);

class _Controller extends EventRehearsalController {
  @override
  void build() {
    ref.keepAlive();
  }

  int calls = 0;
  bool failFirst = false;
  Completer<EventRehearsalCreated>? completion;
  EventRehearsalSetup? setup;
  String? guestSource;
  String? sourceEventId;
  int? actorCount;
  bool? startImmediately;
  @override
  Future<EventRehearsalCreated> create({
    required String organizerId,
    required String? sourceEventId,
    required EventRehearsalScenario scenario,
    required int actorCount,
    EventRehearsalSetup? setup,
    String guestSource = 'simulated',
    bool startImmediately = false,
  }) async {
    calls++;
    this.setup = setup;
    this.guestSource = guestSource;
    this.sourceEventId = sourceEventId;
    this.actorCount = actorCount;
    this.startImmediately = startImmediately;
    if (failFirst && calls == 1) throw StateError('Try again');
    return completion?.future ?? Future.value(_created);
  }
}
