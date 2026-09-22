import 'package:catch_dating_app/core/persistence/local_command_journal.dart';
import 'package:catch_dating_app/core/persistence/memory_command_journal_storage.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/programs/data/program_operations_outbox.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryOutboxStore
    extends LocalCommandJournal<ProgramOperationOutboxEntry> {
  MemoryOutboxStore() : this._(MemoryCommandJournalStorage());
  MemoryOutboxStore._(MemoryCommandJournalStorage memory)
    : super(
        storage: () async => memory,
        namespace: 'test',
        currentAccountId: () => accountId,
        codec: createProgramOperationJournal(
          storage: () async => memory,
          currentAccountId: () => accountId,
        ).codec,
      );
  static String accountId = 'acct';
  Future<void> save(
    String accountId,
    List<ProgramOperationOutboxEntry> entries,
  ) async {
    for (final entry in entries) {
      await append(accountId, entry);
    }
  }
}

class FakeProgramMutator implements ProgramOperationsMutator {
  final List<String> calls = [];
  Object? error;
  bool failOnce = false;

  Object? _maybeError() {
    if (failOnce) {
      final failure = error;
      error = null;
      return failure;
    }
    return error;
  }

  @override
  Future<ProgramMutationResult> setReadiness({
    required String programId,
    required String legId,
    required String action,
    required String clientOperationId,
    int? expectedRevision,
    int? manualCurbAtMillis,
    String? manualCurbNote,
  }) async {
    calls.add('obs:$legId:$action:$clientOperationId');
    if (_maybeError() case final failure?) throw failure;
    return const ProgramMutationResult(
      entityId: 'leg',
      revision: 2,
      alreadyApplied: false,
    );
  }

  @override
  Future<DispatchResult> dispatchTrip({
    required String programId,
    required String pickupPointId,
    required String vehicleClassId,
    required String plateDisplay,
    required List<String> legIds,
    required String clientOperationId,
    String? destinationHotelId,
    String? destinationLabel,
    String? vendorId,
    List<({String legId, int revision})>? expectedLegRevisions,
  }) async {
    calls.add('dispatch:$plateDisplay:$clientOperationId');
    if (_maybeError() case final failure?) throw failure;
    return const DispatchResult(
      tripId: 'trip_1',
      revision: 1,
      alreadyApplied: false,
      passengerCount: 3,
    );
  }
}

ProgramOperationOutboxEntry legObservation({
  required String legId,
  String operationId = 'op_leg',
  DateTime? createdAt,
}) => ProgramOperationOutboxEntry.legObservation(
  programId: 'program-1',
  legId: legId,
  action: 'markReady',
  clientOperationId: operationId,
  createdAt: createdAt ?? DateTime.now(),
);

void main() {
  group('ProgramOperationsOutbox', () {
    late MemoryOutboxStore store;
    late FakeProgramMutator mutator;
    late ProgramOperationsOutbox outbox;

    setUp(() {
      store = MemoryOutboxStore();
      mutator = FakeProgramMutator();
      outbox = ProgramOperationsOutbox(store, mutator);
    });

    test('each leg observation retains its own immutable command', () async {
      await outbox.enqueueAndAttempt(
        accountId: 'acct',
        entry: legObservation(legId: 'leg-1', operationId: 'op_old'),
        offline: true,
      );
      await outbox.enqueueAndAttempt(
        accountId: 'acct',
        entry: legObservation(legId: 'leg-1', operationId: 'op_new'),
        offline: true,
      );

      final summary = await outbox.loadForProgram(
        accountId: 'acct',
        programId: 'program-1',
      );
      expect(summary.entries.map((e) => e.clientOperationId), [
        'op_old',
        'op_new',
      ]);
      expect(mutator.calls, isEmpty);
    });

    test(
      'flush replays pending operations and removes delivered ones',
      () async {
        await outbox.enqueueAndAttempt(
          accountId: 'acct',
          entry: legObservation(legId: 'leg-1', operationId: 'op_1'),
          offline: true,
        );
        await outbox.enqueueAndAttempt(
          accountId: 'acct',
          entry: ProgramOperationOutboxEntry.dispatch(
            programId: 'program-1',
            pickupPointId: 'del_t3',
            vehicleClassId: 'innova',
            plateDisplay: 'DL-1T-4421',
            legIds: const ['leg-1'],
            clientOperationId: 'op_dispatch',
            createdAt: DateTime.now().add(const Duration(seconds: 1)),
          ),
          offline: true,
        );

        final summary = await outbox.flushProgram(
          accountId: 'acct',
          programId: 'program-1',
        );
        expect(summary.entries, isEmpty);
        expect(mutator.calls, [
          'obs:leg-1:markReady:op_1',
          'dispatch:DL-1T-4421:op_dispatch',
        ]);
      },
    );

    test(
      'non-retryable failures mark the entry needsReview and stop nothing',
      () async {
        await outbox.enqueueAndAttempt(
          accountId: 'acct',
          entry: legObservation(legId: 'leg-1', operationId: 'op_1'),
          offline: true,
        );
        await outbox.enqueueAndAttempt(
          accountId: 'acct',
          entry: legObservation(legId: 'leg-2', operationId: 'op_2'),
          offline: true,
        );

        mutator
          ..error = const ValidationException('stale revision')
          ..failOnce = true;

        final summary = await outbox.flushProgram(
          accountId: 'acct',
          programId: 'program-1',
        );
        expect(
          summary.entries.map((entry) => entry.status),
          contains(ProgramOperationOutboxStatus.needsReview),
        );
        expect(summary.needsReviewCount, 1);
      },
    );

    test(
      'retryable failures keep the entry pending and halt the flush',
      () async {
        await outbox.enqueueAndAttempt(
          accountId: 'acct',
          entry: legObservation(legId: 'leg-1', operationId: 'op_1'),
          offline: true,
        );
        await outbox.enqueueAndAttempt(
          accountId: 'acct',
          entry: legObservation(legId: 'leg-2', operationId: 'op_2'),
          offline: true,
        );

        mutator.error = const NetworkException('offline', 'Offline');
        final summary = await outbox.flushProgram(
          accountId: 'acct',
          programId: 'program-1',
        );
        expect(summary.pendingCount, 2);
        expect(mutator.calls, hasLength(1));
      },
    );

    test('old entries remain available for explicit review', () async {
      final stale = DateTime(2026, 2);
      final ancient = DateTime(2026);
      await store.save('acct', [
        legObservation(
          legId: 'leg-stale',
          operationId: 'op_stale',
          createdAt: stale,
        ),
        legObservation(
          legId: 'leg-old',
          operationId: 'op_old',
          createdAt: ancient,
        ),
      ]);

      final summary = await outbox.loadForProgram(
        accountId: 'acct',
        programId: 'program-1',
        now: DateTime(2026, 2, 20),
      );
      expect(summary.entries, hasLength(2));
      expect(
        summary.entries.map((entry) => entry.status),
        everyElement(ProgramOperationOutboxStatus.needsReview),
      );
    });
  });
}
