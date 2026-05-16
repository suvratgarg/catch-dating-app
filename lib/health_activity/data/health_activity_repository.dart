import 'package:catch_dating_app/health_activity/data/health_activity_client.dart';
import 'package:catch_dating_app/health_activity/data/health_activity_client_factory.dart';
import 'package:catch_dating_app/health_activity/domain/weekly_activity_summary.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'health_activity_repository.g.dart';

class HealthActivityRepository {
  HealthActivityRepository(this._client);

  static const _runningPermissionRequestedKey =
      'health_activity.running_permission_requested';

  final HealthActivityClient _client;
  SharedPreferences? _prefsInstance;

  Future<WeeklyRunningActivitySnapshot> fetchWeeklyRunningActivity({
    DateTime? referenceDate,
  }) async {
    final now = referenceDate ?? DateTime.now();
    final refreshedAt = DateTime.now();
    final capabilities = await _client.capabilities();

    if (!capabilities.isSupported) {
      return WeeklyRunningActivitySnapshot.unsupported(
        referenceDate: now,
        refreshedAt: refreshedAt,
      );
    }

    if (capabilities.healthConnectAvailability !=
        HealthConnectAvailability.notApplicable) {
      if (capabilities.healthConnectAvailability !=
          HealthConnectAvailability.available) {
        return WeeklyRunningActivitySnapshot.needsHealthConnect(
          referenceDate: now,
          refreshedAt: refreshedAt,
        );
      }
    }

    final permission = await _client.hasRunningReadPermission();
    final requestedBefore = await _hasRequestedRunningPermission();
    final shouldFetch =
        permission == true ||
        (capabilities.platform == HealthActivityPlatform.appleHealth &&
            requestedBefore);
    if (!shouldFetch) {
      return WeeklyRunningActivitySnapshot.permissionRequired(
        referenceDate: now,
        platformLabel: capabilities.platformLabel,
        refreshedAt: refreshedAt,
      );
    }

    final weekStart = WeeklyActivitySummary.weekStartFor(now);
    final weekEnd = weekStart.add(const Duration(days: 7));
    try {
      final activities = await _client.fetchRunningActivities(
        startTime: weekStart,
        endTime: weekEnd,
      );
      return WeeklyRunningActivitySnapshot.connected(
        referenceDate: now,
        platformLabel: capabilities.platformLabel,
        activities: activities,
        refreshedAt: refreshedAt,
      );
    } catch (_) {
      return WeeklyRunningActivitySnapshot.permissionRequired(
        referenceDate: now,
        platformLabel: capabilities.platformLabel,
        refreshedAt: refreshedAt,
      );
    }
  }

  Future<bool> requestRunningReadPermission() async {
    final granted = await _client.requestRunningReadPermission();
    if (granted) {
      final prefs = await _prefs;
      await prefs.setBool(_runningPermissionRequestedKey, true);
    }
    return granted;
  }

  Future<void> installHealthConnect() => _client.installHealthConnect();

  Future<bool> _hasRequestedRunningPermission() async {
    final prefs = await _prefs;
    return prefs.getBool(_runningPermissionRequestedKey) ?? false;
  }

  Future<SharedPreferences> get _prefs async {
    _prefsInstance ??= await SharedPreferences.getInstance();
    return _prefsInstance!;
  }
}

@riverpod
HealthActivityRepository healthActivityRepository(Ref ref) {
  return HealthActivityRepository(createHealthActivityClient());
}

@riverpod
Future<WeeklyRunningActivitySnapshot> weeklyRunningActivity(Ref ref) {
  return ref
      .watch(healthActivityRepositoryProvider)
      .fetchWeeklyRunningActivity();
}
