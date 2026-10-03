import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations.dart';
import 'package:catch_dating_app/programs/data/program_lodging_providers.dart';
import 'package:catch_dating_app/programs/data/program_read_snapshots.dart';
import 'package:catch_dating_app/programs/presentation/program_lodging_screen.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_pump_helpers.dart';
import 'program_lodging_test_fixtures.dart';
import 'program_operations_fixture.dart';

Future<void> _pump(
  WidgetTester tester,
  FakeLodgingRepository repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        uidProvider.overrideWithValue(const AsyncData('actor')),
        programReadSnapshotStoreProvider.overrideWithValue(
          emptyProgramSnapshots(),
        ),
        programLodgingRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ProgramLodgingScreen(programId: 'program'),
      ),
    ),
  );
  await pumpFeatureUi(tester);
}

void main() {
  testWidgets(
    'route renders current private proposal with explicit publication',
    (tester) async {
      final repository = FakeLodgingRepository();
      await _pump(tester, repository);
      expect(find.text('Stay planner'), findsOneWidget);
      expect(find.text('Publish rooms to guests'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('ROOM-SHARING PARTIES'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('ROOM-SHARING PARTIES'), findsOneWidget);
      expect(repository.commands, isEmpty);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets('missing setup renders an empty state without mutating', (
    tester,
  ) async {
    final repository = FakeLodgingRepository()..hasSetup = false;
    await _pump(tester, repository);
    expect(find.textContaining('Add lodging dates'), findsOneWidget);
    expect(find.text('Publish rooms to guests'), findsNothing);
    expect(repository.commands, isEmpty);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('pending decision disables refresh without losing retry', (
    tester,
  ) async {
    final repository = FakeLodgingRepository()
      ..transitionFailure = TimeoutException('Uncertain transport');
    await _pump(tester, repository);
    await tester.tap(find.text('Publish rooms to guests'));
    await pumpFeatureUi(tester);
    final refresh = tester.widget<CatchButton>(
      find.byWidgetPredicate(
        (widget) => widget is CatchButton && widget.label == 'Refresh rooms',
      ),
    );
    expect(refresh.onPressed, isNull);
    expect(repository.commands, hasLength(1));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
