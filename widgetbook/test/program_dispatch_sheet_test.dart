import 'package:catch_dating_app/programs/data/program_projection_lifetime.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/persistence/memory_command_journal_storage.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/programs/data/program_operations_outbox.dart';
import 'package:catch_dating_app/programs/data/program_work_repository.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';
import 'package:catch_dating_app/programs/presentation/program_dispatch_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/programs/program_operations_fixture.dart';

void main() {
  testWidgets('a rejected departure keeps the sheet and plate for review', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(460, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final storage = MemoryCommandJournalStorage();
    final journal = createProgramOperationJournal(
      storage: () async => storage,
      currentAccountId: () => 'acct',
    );
    final mutator = FakeProgramMutator()
      ..error = const ValidationException('conflict');
    var accepted = false;
    var now = DateTime.now();
    final expiry = now.add(const Duration(seconds: 10));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          programProjectionClockProvider.overrideWithValue(() => now),
          uidProvider.overrideWithValue(const AsyncData('acct')),
          isObviouslyOfflineProvider.overrideWithValue(false),
          programOperationsOutboxProvider.overrideWithValue(
            ProgramOperationsOutbox(journal, mutator),
          ),
          programTransportVendorsProvider(
            'org-1',
            'program-1',
          ).overrideWithValue(const AsyncData([])),
          programArrivalsRosterViewProvider(
            'program-1',
            'pickup-1',
          ).overrideWithValue(
            AsyncData((
              value: ProgramArrivalsRoster(
                accessExpiresAt: null,
                programId: 'program-1',
                pickupPointId: 'pickup-1',
                generatedAt: now,
                rows: [arrivalRow(readiness: TravelLegReadiness.ready)],
                vehicleClasses: const [],
              ),
              snapshotAt: null,
              snapshotExpiresAt: null,
            )),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ProgramDispatchSheet(
              accessExpiresAt: expiry,
              programId: 'program-1',
              pickupPointId: 'pickup-1',
              organizerId: 'org-1',
              accountId: 'acct',
              group: TransportGroupSuggestion(
                legIds: const ['leg-1'],
                partyIds: const [],
                destinationHotelId: 'hotel-1',
                destinationLabel: 'Demo Hotel',
                readiness: TransportGroupReadiness.ready,
                vehicleClassId: 'sedan',
                vehicleClassLabel: 'Sedan',
                passengers: 1,
                luggageUnits: 1,
                earliestCurbAt: now,
                latestCurbAt: now,
                dispatchBy: null,
                waitOverdue: false,
              ),
              holdCandidates: const [],
              vehicleClasses: const [],
              onDispatched: (_, _) => accepted = true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'DL 1 A 1234');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dispatch now'));
    await tester.pumpAndSettle();
    expect(accepted, isFalse);
    expect(find.byType(ProgramDispatchSheet), findsOneWidget);
    expect(find.text('DL 1 A 1234'), findsOneWidget);
    expect(
      find.text(
        'This saved change needs review. Check the current journey and trip records before recording more work.',
      ),
      findsOneWidget,
    );
    expect(
      (await journal.load('acct')).single.status,
      ProgramOperationOutboxStatus.needsReview,
    );
    final calls = mutator.calls.length;
    now = expiry;
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();
    expect(find.text('DL 1 A 1234'), findsNothing);
    expect(find.textContaining('Demo Hotel'), findsNothing);
    expect(find.text('Dispatch now'), findsNothing);
    expect(mutator.calls.length, calls);
    expect(tester.takeException(), isNull);
  });
}
