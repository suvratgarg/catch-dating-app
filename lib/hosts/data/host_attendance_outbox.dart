import 'dart:convert';

import 'package:catch_dating_app/core/app_error_context.dart';
import 'package:catch_dating_app/events/data/event_attendee_repository.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'host_attendance_outbox.g.dart';

abstract interface class HostAttendanceMutator {
  Future<EventAttendeeAttendanceResult> setAttendance({
    required String eventId,
    required String attendeeId,
    required bool desiredCheckedIn,
    required int expectedRevision,
    required String clientOperationId,
  });
}

class RepositoryHostAttendanceMutator implements HostAttendanceMutator {
  const RepositoryHostAttendanceMutator(this._repository);

  final EventAttendeeRepository _repository;

  @override
  Future<EventAttendeeAttendanceResult> setAttendance({
    required String eventId,
    required String attendeeId,
    required bool desiredCheckedIn,
    required int expectedRevision,
    required String clientOperationId,
  }) => _repository.setAttendance(
    eventId: eventId,
    attendeeId: attendeeId,
    desiredCheckedIn: desiredCheckedIn,
    expectedRevision: expectedRevision,
    clientOperationId: clientOperationId,
  );
}

enum HostAttendanceOutboxStatus { pending, needsReview }

class HostAttendanceOutboxEntry {
  const HostAttendanceOutboxEntry({
    required this.eventId,
    required this.attendeeId,
    required this.desiredCheckedIn,
    required this.expectedRevision,
    required this.clientOperationId,
    required this.createdAt,
    required this.status,
    this.lastErrorCode,
  });

  factory HostAttendanceOutboxEntry.fromJson(Map<String, Object?> json) =>
      HostAttendanceOutboxEntry(
        eventId: json['eventId']! as String,
        attendeeId: json['attendeeId']! as String,
        desiredCheckedIn: json['desiredCheckedIn']! as bool,
        expectedRevision: json['expectedRevision']! as int,
        clientOperationId: json['clientOperationId']! as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          json['createdAtMillis']! as int,
        ),
        status: HostAttendanceOutboxStatus.values.byName(
          json['status']! as String,
        ),
        lastErrorCode: json['lastErrorCode'] as String?,
      );

  final String eventId;
  final String attendeeId;
  final bool desiredCheckedIn;
  final int expectedRevision;
  final String clientOperationId;
  final DateTime createdAt;
  final HostAttendanceOutboxStatus status;
  final String? lastErrorCode;

  HostAttendanceOutboxEntry copyWith({
    HostAttendanceOutboxStatus? status,
    String? lastErrorCode,
  }) => HostAttendanceOutboxEntry(
    eventId: eventId,
    attendeeId: attendeeId,
    desiredCheckedIn: desiredCheckedIn,
    expectedRevision: expectedRevision,
    clientOperationId: clientOperationId,
    createdAt: createdAt,
    status: status ?? this.status,
    lastErrorCode: lastErrorCode ?? this.lastErrorCode,
  );

  Map<String, Object?> toJson() => {
    'eventId': eventId,
    'attendeeId': attendeeId,
    'desiredCheckedIn': desiredCheckedIn,
    'expectedRevision': expectedRevision,
    'clientOperationId': clientOperationId,
    'createdAtMillis': createdAt.millisecondsSinceEpoch,
    'status': status.name,
    'lastErrorCode': lastErrorCode,
  };
}

class HostAttendanceOutboxSummary {
  const HostAttendanceOutboxSummary(this.entries);

  final List<HostAttendanceOutboxEntry> entries;

  int get pendingCount => entries
      .where((entry) => entry.status == HostAttendanceOutboxStatus.pending)
      .length;
  int get needsReviewCount => entries
      .where((entry) => entry.status == HostAttendanceOutboxStatus.needsReview)
      .length;

  HostAttendanceOutboxEntry? forAttendee(String attendeeId) {
    for (final entry in entries) {
      if (entry.attendeeId == attendeeId) return entry;
    }
    return null;
  }
}

abstract interface class HostAttendanceOutboxStore {
  Future<List<HostAttendanceOutboxEntry>> load(String accountId);
  Future<void> save(String accountId, List<HostAttendanceOutboxEntry> entries);
}

class SharedPreferencesHostAttendanceOutboxStore
    implements HostAttendanceOutboxStore {
  SharedPreferences? _preferences;

  static const _keyPrefix = 'host_attendance_outbox_v1_';

  Future<SharedPreferences> get _prefs async {
    final cached = _preferences;
    if (cached != null) return cached;
    final loaded = await withAppErrorContext(
      SharedPreferences.getInstance,
      context: const AppErrorContext(
        operation: AppOperation.localPersistence,
        action: 'open attendance replay queue',
        resource: 'shared_preferences',
      ),
    );
    _preferences = loaded;
    return loaded;
  }

  @override
  Future<List<HostAttendanceOutboxEntry>> load(String accountId) async {
    final raw = (await _prefs).getString('$_keyPrefix$accountId');
    if (raw == null) return const [];
    try {
      final values = jsonDecode(raw) as List<Object?>;
      return values
          .map(
            (value) => HostAttendanceOutboxEntry.fromJson(
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
    List<HostAttendanceOutboxEntry> entries,
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

class HostAttendanceOutbox {
  const HostAttendanceOutbox(this._store, this._attendees);

  static const maxEntries = 200;
  static const reviewAfter = Duration(days: 7);
  static const deleteAfter = Duration(days: 30);

  final HostAttendanceOutboxStore _store;
  final HostAttendanceMutator _attendees;

  Future<HostAttendanceOutboxSummary> loadForEvent({
    required String accountId,
    required String eventId,
    DateTime? now,
  }) async {
    final normalized = _normalize(
      await _store.load(accountId),
      now ?? DateTime.now(),
    );
    await _store.save(accountId, normalized);
    return HostAttendanceOutboxSummary(
      normalized
          .where((entry) => entry.eventId == eventId)
          .toList(growable: false),
    );
  }

  Future<HostAttendanceOutboxSummary> enqueueAndAttempt({
    required String accountId,
    required HostAttendanceOutboxEntry entry,
    required bool offline,
  }) async {
    final entries = _normalize(await _store.load(accountId), DateTime.now())
      ..removeWhere(
        (item) =>
            item.eventId == entry.eventId &&
            item.attendeeId == entry.attendeeId,
      )
      ..add(entry);
    _trim(entries);
    await _store.save(accountId, entries);
    if (!offline) await _attempt(accountId, entries, entry);
    return loadForEvent(accountId: accountId, eventId: entry.eventId);
  }

  Future<HostAttendanceOutboxSummary> flushEvent({
    required String accountId,
    required String eventId,
  }) async {
    final entries = _normalize(await _store.load(accountId), DateTime.now());
    for (final entry in List<HostAttendanceOutboxEntry>.of(entries)) {
      if (entry.eventId != eventId ||
          entry.status != HostAttendanceOutboxStatus.pending) {
        continue;
      }
      final shouldContinue = await _attempt(accountId, entries, entry);
      if (!shouldContinue) break;
    }
    await _store.save(accountId, entries);
    return HostAttendanceOutboxSummary(
      entries
          .where((entry) => entry.eventId == eventId)
          .toList(growable: false),
    );
  }

  Future<HostAttendanceOutboxSummary> clearNeedsReview({
    required String accountId,
    required String eventId,
  }) async {
    final entries = await _store.load(accountId)
      ..removeWhere(
        (entry) =>
            entry.eventId == eventId &&
            entry.status == HostAttendanceOutboxStatus.needsReview,
      );
    await _store.save(accountId, entries);
    return HostAttendanceOutboxSummary(
      entries
          .where((entry) => entry.eventId == eventId)
          .toList(growable: false),
    );
  }

  Future<bool> _attempt(
    String accountId,
    List<HostAttendanceOutboxEntry> entries,
    HostAttendanceOutboxEntry entry,
  ) async {
    try {
      await _attendees.setAttendance(
        eventId: entry.eventId,
        attendeeId: entry.attendeeId,
        desiredCheckedIn: entry.desiredCheckedIn,
        expectedRevision: entry.expectedRevision,
        clientOperationId: entry.clientOperationId,
      );
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
          status: HostAttendanceOutboxStatus.needsReview,
          lastErrorCode: error.code,
        );
      }
      await _store.save(accountId, entries);
      return true;
    }
  }

  List<HostAttendanceOutboxEntry> _normalize(
    List<HostAttendanceOutboxEntry> source,
    DateTime now,
  ) {
    final entries = <HostAttendanceOutboxEntry>[];
    for (final entry in source) {
      final age = now.difference(entry.createdAt);
      if (age > deleteAfter) continue;
      entries.add(
        age > reviewAfter && entry.status == HostAttendanceOutboxStatus.pending
            ? entry.copyWith(status: HostAttendanceOutboxStatus.needsReview)
            : entry,
      );
    }
    _trim(entries);
    return entries;
  }

  void _trim(List<HostAttendanceOutboxEntry> entries) {
    entries.sort((left, right) => left.createdAt.compareTo(right.createdAt));
    if (entries.length > maxEntries) {
      entries.removeRange(0, entries.length - maxEntries);
    }
  }
}

// keepalive: a single local store preserves queued attendance mutations while
// the operator moves between roster surfaces.
@Riverpod(keepAlive: true)
HostAttendanceOutboxStore hostAttendanceOutboxStore(Ref ref) =>
    SharedPreferencesHostAttendanceOutboxStore();

// keepalive: the replay coordinator must retain one serialized queue for the
// lifetime of the Host application process.
@Riverpod(keepAlive: true)
HostAttendanceOutbox hostAttendanceOutbox(Ref ref) => HostAttendanceOutbox(
  ref.watch(hostAttendanceOutboxStoreProvider),
  RepositoryHostAttendanceMutator(ref.watch(eventAttendeeRepositoryProvider)),
);
