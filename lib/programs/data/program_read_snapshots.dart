import 'dart:async';
import 'dart:convert';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/app_error_context.dart';
import 'package:catch_dating_app/core/persistence/async_keyed_lock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'program_read_snapshots.g.dart';

/// A callable response cached for offline cold starts. `data` is the raw
/// response payload, reparsed by the same `fromCallableData` readers the
/// live path uses.
class ProgramReadSnapshot {
  const ProgramReadSnapshot({required this.data, required this.savedAt});

  final Object? data;
  final DateTime savedAt;
}

/// Scoped read cache for the airport surface. Snapshots are keyed by
/// account + scope (work access, roster, transport plan per station) so a
/// greeter who loses connectivity mid-shift still sees the last roster —
/// always rendered with its capture timestamp, never presented as live.
abstract interface class ProgramReadSnapshotStore {
  Future<void> save(
    String accountId,
    String scope,
    Object? data, {
    int? expectedGeneration,
  });
  int generation(String accountId, String programId);
  Future<void> clearProgram(String accountId, String programId);
  Future<void> clearAccount(String accountId);
  Future<ProgramReadSnapshot?> load(String accountId, String scope);
}

class SharedPreferencesProgramReadSnapshotStore
    implements ProgramReadSnapshotStore {
  SharedPreferences? _preferences;
  final _lock = AsyncKeyedLock();
  final _generations = <String, int>{};
  final _blockedPrograms = <String>{};
  static const maxAge = Duration(hours: 24);

  @override
  int generation(String accountId, String programId) =>
      _generations.putIfAbsent('$accountId:$programId', () => 0);

  @override
  Future<void> clearAccount(String accountId) {
    for (final key in _generations.keys.toList()) {
      if (key.startsWith('$accountId:')) {
        _generations[key] = _generations[key]! + 1;
        _blockedPrograms.add(key);
      }
    }
    return _lock.run(accountId, () async {
      await (await _prefs).remove('$_keyPrefix$accountId');
    });
  }

  @override
  Future<void> clearProgram(String accountId, String programId) {
    final key = '$accountId:$programId';
    _generations[key] = generation(accountId, programId) + 1;
    _blockedPrograms.add(key);
    return _lock.run(accountId, () async {
      final prefs = await _prefs;
      final entries = _decode(prefs.getString('$_keyPrefix$accountId'));
      entries.removeWhere((scope, _) => _programId(scope) == programId);
      await prefs.setString('$_keyPrefix$accountId', jsonEncode(entries));
    });
  }

  String _programId(String scope) => scope.split(':').elementAtOrNull(1) ?? '';

  static const _keyPrefix = 'program_read_snapshots_v2_';
  static const _maxScopes = 30;

  Future<SharedPreferences> get _prefs async {
    final cached = _preferences;
    if (cached != null) return cached;
    final loaded = await withAppErrorContext(
      SharedPreferences.getInstance,
      context: const AppErrorContext(
        operation: AppOperation.localPersistence,
        action: 'open program read snapshot cache',
        resource: 'shared_preferences',
      ),
    );
    // Old entries did not preserve independent duty deadlines.
    for (final key in loaded.getKeys()) {
      if (key.startsWith('program_read_snapshots_v1_')) {
        await loaded.remove(key);
      }
    }
    _preferences = loaded;
    return loaded;
  }

  @override
  Future<void> save(
    String accountId,
    String scope,
    Object? data, {
    int? expectedGeneration,
  }) => _lock.run(accountId, () async {
    if (data == null) return;
    final prefs = await _prefs;
    final key = '$_keyPrefix$accountId';
    final programId = _programId(scope);
    if (expectedGeneration != null &&
        expectedGeneration != generation(accountId, programId)) {
      return;
    }
    if (_blockedPrograms.contains('$accountId:$programId') &&
        scope != programSnapshotScope('work', programId)) {
      return;
    }
    final entries = _decode(prefs.getString(key));
    if (scope == programSnapshotScope('work', programId) &&
        _authority(entries[scope]?['data']) != _authority(data)) {
      // A fresh narrower bootstrap must never authorize an older broad roster.
      _blockedPrograms.add('$accountId:$programId');
      entries.removeWhere((key, _) => _programId(key) == programId);
      _generations['$accountId:$programId'] =
          generation(accountId, programId) + 1;
    }
    final cutoff = DateTime.now().subtract(maxAge).millisecondsSinceEpoch;
    entries.removeWhere(
      (_, entry) =>
          entry['savedAtMillis'] is! int ||
          (entry['savedAtMillis']! as int) < cutoff,
    );
    entries[scope] = {
      'data': data,
      'savedAtMillis': DateTime.now().millisecondsSinceEpoch,
    };
    if (entries.length > _maxScopes) {
      final ordered = entries.entries.toList()
        ..sort(
          (a, b) => (a.value['savedAtMillis']! as int).compareTo(
            b.value['savedAtMillis']! as int,
          ),
        );
      while (ordered.length > _maxScopes) {
        entries.remove(ordered.removeAt(0).key);
      }
    }
    if (await prefs.setString(key, jsonEncode(entries))) {
      if (scope == programSnapshotScope('work', programId)) {
        _blockedPrograms.remove('$accountId:$programId');
      }
    }
  });

  @override
  Future<ProgramReadSnapshot?> load(String accountId, String scope) async {
    final prefs = await _prefs;
    if (_blockedPrograms.contains('$accountId:${_programId(scope)}')) {
      return null;
    }
    final entry = _decode(prefs.getString('$_keyPrefix$accountId'))[scope];
    if (entry == null) return null;
    final savedAtMillis = entry['savedAtMillis'];
    if (!entry.containsKey('data') || savedAtMillis is! int) return null;
    final savedAt = DateTime.fromMillisecondsSinceEpoch(savedAtMillis);
    final age = DateTime.now().difference(savedAt);
    if (age.isNegative || age > maxAge) return null;
    return ProgramReadSnapshot(data: entry['data'], savedAt: savedAt);
  }

  String? _authority(Object? data) {
    if (data is! Map) return null;
    return jsonEncode([
      data['organizerId'],
      data['actorRole'],
      data['duties'],
      data['grantExpiresAtMillis'],
    ]);
  }

  Map<String, Map<String, Object?>> _decode(String? raw) {
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<Object?, Object?>;
      return decoded.map(
        (scope, entry) => MapEntry(
          scope! as String,
          (entry! as Map<Object?, Object?>).cast<String, Object?>(),
        ),
      );
    } on Object {
      return {};
    }
  }
}

/// The Firestore scope a snapshot covers: work access, a station roster or
/// a station transport plan.
String programSnapshotScope(
  String kind,
  String programId, [
  String? stationId,
]) => stationId == null ? '$kind:$programId' : '$kind:$programId:$stationId';

// keepalive: shares the SharedPreferences instance with the outbox store's
// lifecycle so cold-start reads don't race instance creation.
@Riverpod(keepAlive: true)
ProgramReadSnapshotStore programReadSnapshotStore(Ref ref) {
  final store = SharedPreferencesProgramReadSnapshotStore();
  ref.listen(uidProvider, (previous, next) {
    if (next.isLoading) return;
    final previousId = previous?.asData?.value;
    if (previousId != null && previousId != next.asData?.value) {
      unawaited(store.clearAccount(previousId).onError<Object>((_, _) {}));
    }
  });
  return store;
}
