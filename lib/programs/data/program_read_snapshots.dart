import 'dart:convert';

import 'package:catch_dating_app/core/app_error_context.dart';
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
  Future<void> save(String accountId, String scope, Object? data);
  Future<ProgramReadSnapshot?> load(String accountId, String scope);
}

class SharedPreferencesProgramReadSnapshotStore
    implements ProgramReadSnapshotStore {
  SharedPreferences? _preferences;

  static const _keyPrefix = 'program_read_snapshots_v1_';
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
    _preferences = loaded;
    return loaded;
  }

  @override
  Future<void> save(String accountId, String scope, Object? data) async {
    if (data == null) return;
    final prefs = await _prefs;
    final key = '$_keyPrefix$accountId';
    final entries = _decode(prefs.getString(key));
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
    await prefs.setString(key, jsonEncode(entries));
  }

  @override
  Future<ProgramReadSnapshot?> load(String accountId, String scope) async {
    final prefs = await _prefs;
    final entry = _decode(prefs.getString('$_keyPrefix$accountId'))[scope];
    if (entry == null) return null;
    final savedAtMillis = entry['savedAtMillis'];
    if (!entry.containsKey('data') || savedAtMillis is! int) return null;
    return ProgramReadSnapshot(
      data: entry['data'],
      savedAt: DateTime.fromMillisecondsSinceEpoch(savedAtMillis),
    );
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
ProgramReadSnapshotStore programReadSnapshotStore(Ref ref) =>
    SharedPreferencesProgramReadSnapshotStore();
