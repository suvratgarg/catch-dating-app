import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/persistence/command_journal_provider.dart';
import 'package:catch_dating_app/core/persistence/command_journal_storage.dart';
import 'package:catch_dating_app/core/persistence/local_command_journal.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/programs/data/program_work_repository.dart';
import 'package:catch_dating_app/programs/domain/dispatch_manifest.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'program_operations_outbox.g.dart';

/// Signed-in account id for outbox calls made from widgets — the shared
/// `requireSignedInUid` takes `Ref`, which a `WidgetRef` does not satisfy.
String programWorkAccountId(WidgetRef ref, {required String action}) {
  final uid = ref.read(uidProvider).asData?.value;
  if (uid == null || uid.isEmpty) {
    throw SignInRequiredException(action);
  }
  return uid;
}

/// Idempotent writes the arrivals workspace must never lose while the
/// airport concourse is offline: leg observations and vehicle dispatch.
abstract interface class ProgramOperationsMutator {
  Future<ProgramMutationResult> setReadiness({
    required String programId,
    required String legId,
    required String action,
    required String clientOperationId,
    int? expectedRevision,
    int? manualCurbAtMillis,
    String? manualCurbNote,
  });

  Future<DispatchResult> dispatchTrip({
    required String programId,
    required String pickupPointId,
    required String vehicleClassId,
    required String plateDisplay,
    required List<String> legIds,
    required DateTime departedAt,
    required String clientOperationId,
    String? destinationHotelId,
    String? destinationLabel,
    String? vendorId,
    required List<({String legId, int revision})> expectedLegRevisions,
  });
}

class RepositoryProgramOperationsMutator implements ProgramOperationsMutator {
  const RepositoryProgramOperationsMutator(this._repository);

  final ProgramWorkRepository _repository;

  @override
  Future<ProgramMutationResult> setReadiness({
    required String programId,
    required String legId,
    required String action,
    required String clientOperationId,
    int? expectedRevision,
    int? manualCurbAtMillis,
    String? manualCurbNote,
  }) {
    final manualCurbAt = manualCurbAtMillis == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(manualCurbAtMillis);
    return switch (action) {
      'claim' => _repository.claimLeg(
        programId: programId,
        legId: legId,
        clientOperationId: clientOperationId,
        expectedRevision: expectedRevision,
      ),
      'unclaim' => _repository.unclaimLeg(
        programId: programId,
        legId: legId,
        clientOperationId: clientOperationId,
        expectedRevision: expectedRevision,
      ),
      'markReady' => _repository.markLegReady(
        programId: programId,
        legId: legId,
        clientOperationId: clientOperationId,
        expectedRevision: expectedRevision,
        manualCurbAt: manualCurbAt,
        manualCurbNote: manualCurbNote,
      ),
      'markDisrupted' => _repository.markLegDisrupted(
        programId: programId,
        legId: legId,
        clientOperationId: clientOperationId,
        expectedRevision: expectedRevision,
        manualCurbAt: manualCurbAt,
        manualCurbNote: manualCurbNote,
      ),
      _ => throw ArgumentError.value(action, 'action'),
    };
  }

  @override
  Future<DispatchResult> dispatchTrip({
    required String programId,
    required String pickupPointId,
    required String vehicleClassId,
    required String plateDisplay,
    required List<String> legIds,
    required DateTime departedAt,
    required String clientOperationId,
    String? destinationHotelId,
    String? destinationLabel,
    String? vendorId,
    required List<({String legId, int revision})> expectedLegRevisions,
  }) => _repository.dispatchTrip(
    programId: programId,
    pickupPointId: pickupPointId,
    vehicleClassId: vehicleClassId,
    plateDisplay: plateDisplay,
    legIds: legIds,
    clientOperationId: clientOperationId,
    destinationHotelId: destinationHotelId,
    destinationLabel: destinationLabel,
    vendorId: vendorId,
    expectedLegRevisions: expectedLegRevisions,
    departedAt: departedAt,
  );
}

enum ProgramOperationKind { legObservation, dispatch }

typedef ProgramOperationOutboxStatus = LocalCommandStatus;

class ProgramOperationOutboxEntry {
  const ProgramOperationOutboxEntry._({
    required this.kind,
    required this.programId,
    required this.clientOperationId,
    required this.createdAt,
    required this.status,
    required this.payload,
    this.lastErrorCode,
  });

  factory ProgramOperationOutboxEntry.legObservation({
    required String programId,
    required String legId,
    required String action,
    required String clientOperationId,
    required DateTime createdAt,
    int? expectedRevision,
    int? manualCurbAtMillis,
    String? manualCurbNote,
  }) => ProgramOperationOutboxEntry._(
    kind: ProgramOperationKind.legObservation,
    programId: programId,
    clientOperationId: clientOperationId,
    createdAt: createdAt,
    status: ProgramOperationOutboxStatus.pending,
    payload: {
      'legId': legId,
      'action': action,
      'expectedRevision': expectedRevision,
      'manualCurbAtMillis': manualCurbAtMillis,
      'manualCurbNote': manualCurbNote,
    },
  );

  factory ProgramOperationOutboxEntry.dispatch({
    required String programId,
    required String pickupPointId,
    required String vehicleClassId,
    required String plateDisplay,
    required List<String> legIds,
    required String clientOperationId,
    required DateTime createdAt,
    String? destinationHotelId,
    String? destinationLabel,
    String? vendorId,
    required List<({String legId, int revision})> expectedLegRevisions,
  }) => ProgramOperationOutboxEntry._(
    kind: ProgramOperationKind.dispatch,
    programId: programId,
    clientOperationId: clientOperationId,
    createdAt: createdAt,
    status: ProgramOperationOutboxStatus.pending,
    payload: {
      'pickupPointId': pickupPointId,
      'vehicleClassId': vehicleClassId,
      'plateDisplay': plateDisplay,
      'legIds': legIds,
      'destinationHotelId': destinationHotelId,
      'destinationLabel': destinationLabel,
      'vendorId': vendorId,
      'expectedLegRevisions': expectedLegRevisions
          .map(
            (fence) => <String, Object?>{
              'legId': fence.legId,
              'revision': fence.revision,
            },
          )
          .toList(growable: false),
    },
  );

  factory ProgramOperationOutboxEntry.fromJson(Map<String, Object?> json) {
    final entry = ProgramOperationOutboxEntry._(
      kind: ProgramOperationKind.values.byName(json['kind']! as String),
      programId: json['programId']! as String,
      clientOperationId: json['clientOperationId']! as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['createdAtMillis']! as int,
      ),
      status: ProgramOperationOutboxStatus.values.byName(
        json['status']! as String,
      ),
      payload: (json['payload']! as Map<Object?, Object?>)
          .cast<String, Object?>(),
      lastErrorCode: json['lastErrorCode'] as String?,
    );

    final payload = entry.payload;
    switch (entry.kind) {
      case ProgramOperationKind.legObservation:
        requiredString(payload, 'legId');
        if (!{
          'claim',
          'unclaim',
          'markReady',
          'markDisrupted',
        }.contains(payload['action'])) {
          throw const FormatException('Invalid leg action');
        }
        for (final key in ['expectedRevision', 'manualCurbAtMillis']) {
          if (payload[key] != null &&
              (payload[key] is! int || (payload[key]! as int) < 0)) {
            throw const FormatException('Invalid observation revision or time');
          }
        }
        if (payload['manualCurbNote'] != null &&
            payload['manualCurbNote'] is! String) {
          throw const FormatException('Invalid observation note');
        }
      case ProgramOperationKind.dispatch:
        for (final key in ['pickupPointId', 'vehicleClassId', 'plateDisplay']) {
          requiredString(payload, key);
        }
        final legs = stringList(payload['legIds']);
        if (legs.isEmpty ||
            legs.any((id) => id.isEmpty) ||
            legs.toSet().length != legs.length) {
          throw const FormatException('Invalid dispatch legs');
        }
        for (final key in [
          'destinationHotelId',
          'destinationLabel',
          'vendorId',
        ]) {
          if (payload[key] != null && payload[key] is! String) {
            throw const FormatException(
              'Invalid dispatch destination or vendor',
            );
          }
        }
        if (payload['expectedLegRevisions'] != null) {
          for (final fence in mapList(
            payload['expectedLegRevisions'],
            'revision fences',
          )) {
            requiredString(fence, 'legId');
            if (fence['revision'] is! int || (fence['revision']! as int) < 0) {
              throw const FormatException('Invalid dispatch revision');
            }
          }
        }
    }
    return entry;
  }

  final ProgramOperationKind kind;
  final String programId;
  final String clientOperationId;
  final DateTime createdAt;
  final ProgramOperationOutboxStatus status;
  final Map<String, Object?> payload;
  final String? lastErrorCode;

  /// Human-readable label for the queued-operations banner.
  String get summary {
    return switch (kind) {
      ProgramOperationKind.legObservation =>
        '${payload['action']} · leg ${payload['legId']}',
      ProgramOperationKind.dispatch =>
        'dispatch ${payload['plateDisplay']} · '
            '${(payload['legIds']! as List<Object?>).length} legs',
    };
  }

  ProgramOperationOutboxEntry copyWith({
    ProgramOperationOutboxStatus? status,
    String? lastErrorCode,
  }) => ProgramOperationOutboxEntry._(
    kind: kind,
    programId: programId,
    clientOperationId: clientOperationId,
    createdAt: createdAt,
    status: status ?? this.status,
    payload: payload,
    lastErrorCode: lastErrorCode ?? this.lastErrorCode,
  );

  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'programId': programId,
    'clientOperationId': clientOperationId,
    'createdAtMillis': createdAt.millisecondsSinceEpoch,
    'status': status.name,
    'payload': payload,
    'lastErrorCode': lastErrorCode,
  };
}

class ProgramOperationOutboxSummary {
  const ProgramOperationOutboxSummary(this.entries);

  final List<ProgramOperationOutboxEntry> entries;

  int get pendingCount => entries
      .where((entry) => entry.status == ProgramOperationOutboxStatus.pending)
      .length;
  int get needsReviewCount => entries
      .where(
        (entry) => entry.status == ProgramOperationOutboxStatus.needsReview,
      )
      .length;

  /// Most recent local observation; earlier commands remain in the journal.
  ProgramOperationOutboxEntry? forLeg(String legId) {
    for (final entry in entries.reversed) {
      if (entry.kind == ProgramOperationKind.legObservation &&
          entry.payload['legId'] == legId) {
        return entry;
      }
    }
    return null;
  }

  bool hasPendingDispatch(String plateNormalized) => entries.any(
    (entry) =>
        entry.kind == ProgramOperationKind.dispatch &&
        entry.status == ProgramOperationOutboxStatus.pending &&
        entry.payload['plateDisplay'] == plateNormalized,
  );
}

typedef ProgramOperationOutboxStore =
    LocalCommandJournal<ProgramOperationOutboxEntry>;

ProgramOperationOutboxStore createProgramOperationJournal({
  required Future<CommandJournalStorage> Function() storage,
  required String? Function() currentAccountId,
  Future<String?> Function(String)? loadLegacy,
  Future<void> Function(String)? clearLegacy,
}) => LocalCommandJournal(
  storage: storage,
  namespace: 'program_operations',
  currentAccountId: currentAccountId,
  loadLegacy: loadLegacy,
  clearLegacy: clearLegacy,
  codec: LocalCommandCodec(
    encode: (entry) => entry.toJson(),
    decode: ProgramOperationOutboxEntry.fromJson,
    scope: (entry) => entry.programId,
    resources: (entry) => {
      if (entry.kind == ProgramOperationKind.legObservation)
        'leg:${entry.payload['legId']}'
      else ...[
        for (final legId in (entry.payload['legIds']! as List)) 'leg:$legId',
        'vehicle:${(entry.payload['plateDisplay']! as String).toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '')}',
      ],
    },
  ),
);

class ProgramOperationsOutbox {
  const ProgramOperationsOutbox(this._journal, this._mutator);
  final ProgramOperationOutboxStore _journal;
  final ProgramOperationsMutator _mutator;

  Future<ProgramOperationOutboxSummary> loadForProgram({
    required String accountId,
    required String programId,
    DateTime? now,
  }) async => ProgramOperationOutboxSummary(
    await _journal.load(accountId, scope: programId, now: now),
  );

  Future<ProgramOperationOutboxSummary> enqueueAndAttempt({
    required String accountId,
    required ProgramOperationOutboxEntry entry,
    required bool offline,
  }) async {
    await _journal.append(accountId, entry);
    if (!offline) await _journal.flush(accountId, entry.programId, _execute);
    return loadForProgram(accountId: accountId, programId: entry.programId);
  }

  Future<ProgramOperationOutboxSummary> flushProgram({
    required String accountId,
    required String programId,
  }) async {
    await _journal.flush(accountId, programId, _execute);
    return loadForProgram(accountId: accountId, programId: programId);
  }

  Future<ProgramOperationOutboxSummary> clearNeedsReview({
    required String accountId,
    required String programId,
  }) async {
    await _journal.dismissReview(accountId, programId);
    return loadForProgram(accountId: accountId, programId: programId);
  }

  Future<void> _execute(ProgramOperationOutboxEntry entry) async {
    switch (entry.kind) {
      case ProgramOperationKind.legObservation:
        await _mutator.setReadiness(
          programId: entry.programId,
          legId: entry.payload['legId']! as String,
          action: entry.payload['action']! as String,
          clientOperationId: entry.clientOperationId,
          expectedRevision: entry.payload['expectedRevision'] as int?,
          manualCurbAtMillis: entry.payload['manualCurbAtMillis'] as int?,
          manualCurbNote: entry.payload['manualCurbNote'] as String?,
        );
      case ProgramOperationKind.dispatch:
        final legs = (entry.payload['legIds']! as List<Object?>).cast<String>();
        final fences =
            (entry.payload['expectedLegRevisions'] as List<Object?>? ?? [])
                .map((fence) {
                  final map = fence! as Map<Object?, Object?>;
                  return (
                    legId: map['legId']! as String,
                    revision: map['revision']! as int,
                  );
                })
                .toList(growable: false);
        validateDispatchRevisionFences(legs, fences);
        await _mutator.dispatchTrip(
          programId: entry.programId,
          pickupPointId: entry.payload['pickupPointId']! as String,
          vehicleClassId: entry.payload['vehicleClassId']! as String,
          plateDisplay: entry.payload['plateDisplay']! as String,
          legIds: (entry.payload['legIds']! as List<Object?>).cast<String>(),
          clientOperationId: entry.clientOperationId,
          destinationHotelId: entry.payload['destinationHotelId'] as String?,
          destinationLabel: entry.payload['destinationLabel'] as String?,
          vendorId: entry.payload['vendorId'] as String?,
          expectedLegRevisions: fences,
          departedAt: entry.createdAt,
        );
    }
  }
}

// keepalive: one journal shared by arrivals, dispatch, and hotel operations.
@Riverpod(keepAlive: true)
ProgramOperationOutboxStore programOperationOutboxStore(Ref ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return createProgramOperationJournal(
    storage: ref.watch(commandJournalStorageProvider),
    currentAccountId: () => auth.currentUser?.uid,
    loadLegacy: (accountId) =>
        loadLegacyCommandJournal('program_operations_outbox_v1_', accountId),
    clearLegacy: (accountId) =>
        clearLegacyCommandJournal('program_operations_outbox_v1_', accountId),
  );
}

// keepalive: commands survive navigation between program work surfaces.
@Riverpod(keepAlive: true)
ProgramOperationsOutbox programOperationsOutbox(Ref ref) =>
    ProgramOperationsOutbox(
      ref.watch(programOperationOutboxStoreProvider),
      RepositoryProgramOperationsMutator(
        ref.watch(programWorkRepositoryProvider),
      ),
    );
