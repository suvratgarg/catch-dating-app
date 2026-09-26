import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/hosts/work/data/host_work_repository.dart';
import 'package:catch_dating_app/hosts/work/domain/host_work_assignment.dart';
import 'package:catch_dating_app/hosts/work/presentation/host_work_screen.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations.dart';
import 'package:catch_dating_app/routing/route_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../test_pump_helpers.dart';

class _Repository extends Fake implements HostWorkRepository {
  _Repository(this.response);

  final Map<String, Object?> response;

  @override
  Future<HostWorkAssignments> listAssignments({bool includeExpired = false}) =>
      Future.value(HostWorkAssignments.fromCallableData(response));
}

Map<String, Object?> _programAssignment({String scopeId = 'program-1'}) => {
  'kind': 'program',
  'scopeId': scopeId,
  'organizerId': 'org-1',
  'title': 'Kapoor–Mehta wedding',
  'subtitle': 'Three days · Jaipur',
  'organizerName': 'Kapoor family',
  'duties': const [
    {
      'duty': 'airportGreeter',
      'pickupPointIds': ['jp-terminal-2'],
    },
  ],
  'destinations': const ['arrivals'],
  'overflowDestinations': const [],
  'shellMode': 'task',
  'grantExpiresAtMillis': null,
};

Map<String, Object?> _eventAssignment({String scopeId = 'event-9'}) => {
  'kind': 'event',
  'scopeId': scopeId,
  'organizerId': 'org-2',
  'title': 'Friday mixer',
  'organizerName': 'Catch events',
  'duties': const [
    {'duty': 'eventLead'},
  ],
  'destinations': const ['nowNext', 'door', 'attention'],
  'overflowDestinations': const [],
  'shellMode': 'tabs',
  'grantExpiresAtMillis': null,
};

Widget _stub(String label) => Scaffold(body: Text(label));

Future<GoRouter> _pumpShell(WidgetTester tester, _Repository repository) async {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: Routes.hostWorkScreen.path,
        name: Routes.hostWorkScreen.name,
        builder: (_, _) => const HostWorkScreen(),
      ),
      GoRoute(
        path: Routes.hostWorkProgramScreen.path,
        name: Routes.hostWorkProgramScreen.name,
        builder: (_, state) =>
            _stub('program ${state.pathParameters['programId']}'),
      ),
      GoRoute(
        path: Routes.hostOperatorEventScreen.path,
        name: Routes.hostOperatorEventScreen.name,
        builder: (_, state) =>
            _stub('event ${state.pathParameters['eventId']}'),
      ),
    ],
    initialLocation: Routes.hostWorkScreen.path,
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        uidProvider.overrideWithValue(const AsyncData('account')),
        hostWorkRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await pumpFeatureUi(tester);
  return router;
}

void main() {
  testWidgets('renders the picker grouped by organizer', (tester) async {
    await _pumpShell(
      tester,
      _Repository({
        'assignments': [_programAssignment(), _eventAssignment()],
        'shellEntry': 'workShell',
      }),
    );

    expect(find.text('Kapoor–Mehta wedding'), findsOneWidget);
    expect(find.text('Friday mixer'), findsOneWidget);
    expect(find.text('Kapoor family'), findsOneWidget);
    expect(find.text('Catch events'), findsOneWidget);
    // Both assignments render on the picker — nothing forwarded.
    expect(find.text('program program-1'), findsNothing);
    expect(find.text('event event-9'), findsNothing);
  });

  testWidgets('forwards a lone program assignment into its scope', (
    tester,
  ) async {
    final router = await _pumpShell(
      tester,
      _Repository({
        'assignments': [_programAssignment()],
        'shellEntry': 'workShell',
      }),
    );
    await pumpUntilFound(tester, find.text('program program-1'));
    expect(
      router.routeInformationProvider.value.uri.path,
      '/host/work/program-1',
    );
  });

  testWidgets('forwards a lone event assignment into the operator surface', (
    tester,
  ) async {
    final router = await _pumpShell(
      tester,
      _Repository({
        'assignments': [_eventAssignment()],
        'shellEntry': 'workShell',
      }),
    );
    await pumpUntilFound(tester, find.text('event event-9'));
    expect(
      router.routeInformationProvider.value.uri.path,
      '/host/operator/event-9',
    );
  });

  testWidgets('shows the empty state when no assignments are live', (
    tester,
  ) async {
    await _pumpShell(
      tester,
      _Repository({'assignments': const [], 'shellEntry': 'none'}),
    );

    expect(find.text('No assignments yet'), findsOneWidget);
  });

  testWidgets('manager shell keeps the picker instead of forwarding', (
    tester,
  ) async {
    await _pumpShell(
      tester,
      _Repository({
        'assignments': [_programAssignment()],
        'shellEntry': 'managerShell',
      }),
    );
    await pumpFeatureUi(tester);

    expect(find.text('Kapoor–Mehta wedding'), findsOneWidget);
    expect(find.text('program program-1'), findsNothing);
  });
}
