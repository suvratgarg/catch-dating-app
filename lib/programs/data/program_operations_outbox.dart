import 'dart:convert';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/app_error_context.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/programs/data/program_work_repository.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    required String clientOperationId,
    String? destinationHotelId,
    String? destinationLabel,
    String? vendorId,
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
    required String clientOperationId,
    String? destinationHotelId,
    String? destinationLabel,
    String? vendorId,
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
  );
}

enum ProgramOperationKind { legObservation, dispatch }

enum ProgramOperationOutboxStatus { pending, needsReview }

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
    },
  );

  factory ProgramOperationOutboxEntry.fromJson(Map<String, Object?> json) =>
      ProgramOperationOutboxEntry._(
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

  /// One in-flight observation per leg; a newer observation supersedes.
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

abstract interface class ProgramOperationOutboxStore {
  Future<List<ProgramOperationOutboxEntry>> load(String accountId);
  Future<void> save(
    String accountId,
    List<ProgramOperationOutboxEntry> entries,
  );
}

class SharedPreferencesProgramOperationOutboxStore
    implements ProgramOperationOutboxStore {
  SharedPreferences? _preferences;

  static const _keyPrefix = 'program_operations_outbox_v1_';

  Future<SharedPreferences> get _prefs async {
    final cached = _preferences;
    if (cached != null) return cached;
    final loaded = await withAppErrorContext(
      SharedPreferences.getInstance,
      context: const AppErrorContext(
        operation: AppOperation.localPersistence,
        action: 'open program operations replay queue',
        resource: 'shared_preferences',
      ),
    );
    _preferences = loaded;
    return loaded;
  }

  @override
  Future<List<ProgramOperationOutboxEntry>> load(String accountId) async {
    final raw = (await _prefs).getString('$_keyPrefix$accountId');
    if (raw == null) return const [];
    try {
      final values = jsonDecode(raw) as List<Object?>;
      return values
          .map(
            (value) => ProgramOperationOutboxEntry.fromJson(
              (value! as Map<Object?, Object?>).cast<String, Object?>(),
            ),
          )
          .toList(growable: false);
    } on Object {
      await (await _prefs).remove('$_keyPrefix$accountId');
      return const [];
    }
  }

  @override
  Future<void> save(
    String accountId,
    List<ProgramOperationOutboxEntry> entries,
  ) async {
    final prefs = await _prefs;
    final key = '$_keyPrefix$accountId';
    if (entries.isEmpty) {
      await prefs.remove(key);
      return;
    }
    await prefs.setString(
      key,
      jsonEncode(entries.map((entry) => entry.toJson()).toList()),
    );
  }
}

class ProgramOperationsOutbox {
  const ProgramOperationsOutbox(this._store, this._mutator);

  static const maxEntries = 200;
  static const reviewAfter = Duration(days: 7);
  static const deleteAfter = Duration(days: 30);

  final ProgramOperationOutboxStore _store;
  final ProgramOperationsMutator _mutator;

  Future<ProgramOperationOutboxSummary> loadForProgram({
    required String accountId,
    required String programId,
    DateTime? now,
  }) async {
    final normalized = _normalize(
      await _store.load(accountId),
      now ?? DateTime.now(),
    );
    await _store.save(accountId, normalized);
    return ProgramOperationOutboxSummary(
      normalized
          .where((entry) => entry.programId == programId)
          .toList(growable: false),
    );
  }

  Future<ProgramOperationOutboxSummary> enqueueAndAttempt({
    required String accountId,
    required ProgramOperationOutboxEntry entry,
    required bool offline,
  }) async {
    final entries = _normalize(await _store.load(accountId), DateTime.now());
    if (entry.kind == ProgramOperationKind.legObservation) {
      // A newer observation for the same leg supersedes a queued one.
      entries.removeWhere(
        (item) =>
            item.kind == ProgramOperationKind.legObservation &&
            item.payload['legId'] == entry.payload['legId'] &&
            item.programId == entry.programId,
      );
    } else {
      entries.removeWhere(
        (item) => item.clientOperationId == entry.clientOperationId,
      );
    }
    entries.add(entry);
    _trim(entries);
    await _store.save(accountId, entries);
    if (!offline) await _attempt(accountId, entries, entry);
    return loadForProgram(accountId: accountId, programId: entry.programId);
  }

  Future<ProgramOperationOutboxSummary> flushProgram({
    required String accountId,
    required String programId,
  }) async {
    final entries = _normalize(await _store.load(accountId), DateTime.now());
    for (final entry in List<ProgramOperationOutboxEntry>.of(entries)) {
      if (entry.programId != programId ||
          entry.status != ProgramOperationOutboxStatus.pending) {
        continue;
      }
      final shouldContinue = await _attempt(accountId, entries, entry);
      if (!shouldContinue) break;
    }
    await _store.save(accountId, entries);
    return loadForProgram(accountId: accountId, programId: programId);
  }

  Future<ProgramOperationOutboxSummary> clearNeedsReview({
    required String accountId,
    required String programId,
  }) async {
    final entries = (await _store.load(accountId))
      ..removeWhere(
        (entry) =>
            entry.programId == programId &&
            entry.status == ProgramOperationOutboxStatus.needsReview,
      );
    await _store.save(accountId, entries);
    return ProgramOperationOutboxSummary(
      entries
          .where((entry) => entry.programId == programId)
          .toList(growable: false),
    );
  }

  Future<bool> _attempt(
    String accountId,
    List<ProgramOperationOutboxEntry> entries,
    ProgramOperationOutboxEntry entry,
  ) async {
    try {
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
          );
      }
      entries.removeWhere(
        (item) => item.clientOperationId == entry.clientOperationId,
      );
      await _store.save(accountId, entries);
      return true;
    } on AppException catch (error) {
      if (error.retryable && error.code != 'aborted') return false;
      final index = entries.indexWhere(
        (item) => item.clientOperationId == entry.clientOperationId,
      );
      if (index >= 0) {
        entries[index] = entry.copyWith(
          status: ProgramOperationOutboxStatus.needsReview,
          lastErrorCode: error.code,
        );
      }
      await _store.save(accountId, entries);
      return true;
    }
  }

  List<ProgramOperationOutboxEntry> _normalize(
    List<ProgramOperationOutboxEntry> source,
    DateTime now,
  ) {
    final entries = <ProgramOperationOutboxEntry>[];
    for (final entry in source) {
      final age = now.difference(entry.createdAt);
      if (age > deleteAfter) continue;
      entries.add(
        age > reviewAfter &&
                entry.status == ProgramOperationOutboxStatus.pending
            ? entry.copyWith(status: ProgramOperationOutboxStatus.needsReview)
            : entry,
      );
    }
    _trim(entries);
    return entries;
  }

  void _trim(List<ProgramOperationOutboxEntry> entries) {
    entries.sort((left, right) => left.createdAt.compareTo(right.createdAt));
    if (entries.length > maxEntries) {
      entries.removeRange(0, entries.length - maxEntries);
    }
  }
}

// keepalive: a single local store preserves queued program operations while
// staff move between roster, dispatch and hotel surfaces.
@Riverpod(keepAlive: true)
ProgramOperationOutboxStore programOperationOutboxStore(Ref ref) =>
    SharedPreferencesProgramOperationOutboxStore();

// keepalive: the replay coordinator must retain one serialized queue for the
// lifetime of the Host application process.
@Riverpod(keepAlive: true)
ProgramOperationsOutbox programOperationsOutbox(Ref ref) =>
    ProgramOperationsOutbox(
      ref.watch(programOperationOutboxStoreProvider),
      RepositoryProgramOperationsMutator(
        ref.watch(programWorkRepositoryProvider),
      ),
    );
