import 'package:catch_dating_app/health_activity/data/health_activity_client.dart';
import 'package:catch_dating_app/health_activity/domain/runner_activity.dart';

HealthActivityClient createHealthActivityClient() {
  return const UnsupportedHealthActivityClient();
}

class UnsupportedHealthActivityClient implements HealthActivityClient {
  const UnsupportedHealthActivityClient();

  @override
  Future<HealthActivityCapabilities> capabilities() async {
    return const HealthActivityCapabilities(
      platform: HealthActivityPlatform.unsupported,
    );
  }

  @override
  Future<List<RunnerActivity>> fetchEventningActivities({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    return const [];
  }

  @override
  Future<bool?> hasRunningReadPermission() async {
    return false;
  }

  @override
  Future<void> installHealthConnect() async {}

  @override
  Future<bool> requestRunningReadPermission() async {
    return false;
  }
}
