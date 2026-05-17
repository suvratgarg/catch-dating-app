import 'dart:io';

import 'package:catch_dating_app/health_activity/data/health_activity_client.dart';
import 'package:catch_dating_app/health_activity/domain/runner_activity.dart';
import 'package:health/health.dart' as health;

HealthActivityClient createHealthActivityClient() {
  return MobileHealthActivityClient();
}

class MobileHealthActivityClient implements HealthActivityClient {
  MobileHealthActivityClient({health.Health? healthClient})
    : _health = healthClient ?? health.Health();

  final health.Health _health;
  bool _configured = false;

  bool get _isSupportedDevice => Platform.isIOS || Platform.isAndroid;

  @override
  Future<HealthActivityCapabilities> capabilities() async {
    if (!_isSupportedDevice) {
      return const HealthActivityCapabilities(
        platform: HealthActivityPlatform.unsupported,
      );
    }

    await _configure();
    if (Platform.isIOS) {
      return const HealthActivityCapabilities(
        platform: HealthActivityPlatform.appleHealth,
      );
    }

    final status = await _health.getHealthConnectSdkStatus();
    return HealthActivityCapabilities(
      platform: HealthActivityPlatform.healthConnect,
      healthConnectAvailability: switch (status) {
        health.HealthConnectSdkStatus.sdkAvailable =>
          HealthConnectAvailability.available,
        health.HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired =>
          HealthConnectAvailability.updateRequired,
        _ => HealthConnectAvailability.unavailable,
      },
    );
  }

  @override
  Future<List<RunnerActivity>> fetchRunningActivities({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    if (!_isSupportedDevice) return const [];
    await _configure();

    final points = await _health.getHealthDataFromTypes(
      types: const [health.HealthDataType.WORKOUT],
      startTime: startTime,
      endTime: endTime,
    );

    final activities = <RunnerActivity>[];
    for (final point in points) {
      final activity = _activityFromWorkoutPoint(point);
      if (activity != null) {
        activities.add(activity);
      }
    }
    activities.sort((a, b) => a.startTime.compareTo(b.startTime));
    return activities;
  }

  @override
  Future<bool?> hasRunningReadPermission() async {
    if (!_isSupportedDevice) return false;
    await _configure();
    return _health.hasPermissions(
      _runningReadTypes,
      permissions: _runningReadPermissions,
    );
  }

  @override
  Future<void> installHealthConnect() async {
    if (!Platform.isAndroid) return;
    await _health.installHealthConnect();
  }

  @override
  Future<bool> requestRunningReadPermission() async {
    if (!_isSupportedDevice) return false;
    await _configure();
    return _health.requestAuthorization(
      _runningReadTypes,
      permissions: _runningReadPermissions,
    );
  }

  Future<void> _configure() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  List<health.HealthDataType> get _runningReadTypes {
    final types = <health.HealthDataType>[health.HealthDataType.WORKOUT];
    if (Platform.isIOS &&
        _health.isDataTypeAvailable(
          health.HealthDataType.DISTANCE_WALKING_RUNNING,
        )) {
      types.add(health.HealthDataType.DISTANCE_WALKING_RUNNING);
    } else if (Platform.isAndroid &&
        _health.isDataTypeAvailable(health.HealthDataType.DISTANCE_DELTA)) {
      types.add(health.HealthDataType.DISTANCE_DELTA);
    }
    return types;
  }

  List<health.HealthDataAccess> get _runningReadPermissions {
    return List<health.HealthDataAccess>.filled(
      _runningReadTypes.length,
      health.HealthDataAccess.READ,
      growable: false,
    );
  }

  RunnerActivity? _activityFromWorkoutPoint(health.HealthDataPoint point) {
    final value = point.value;
    if (value is! health.WorkoutHealthValue) {
      return null;
    }
    final type = _activityType(value.workoutActivityType);
    if (type == null) {
      return null;
    }
    final distanceMeters = _distanceMeters(value);
    if (distanceMeters == null || distanceMeters <= 0) {
      return null;
    }

    return RunnerActivity(
      stableId: 'health:${point.sourcePlatform.name}:${point.uuid}',
      provider: _providerFor(point.sourcePlatform),
      type: type,
      startTime: point.dateFrom,
      endTime: point.dateTo,
      distanceMeters: distanceMeters,
      isManualEntry: point.recordingMethod == health.RecordingMethod.manual,
      sourceName: point.sourceName,
    );
  }

  RunnerActivityProvider _providerFor(health.HealthPlatformType platform) {
    return switch (platform) {
      health.HealthPlatformType.appleHealth =>
        RunnerActivityProvider.appleHealth,
      health.HealthPlatformType.googleHealthConnect =>
        RunnerActivityProvider.healthConnect,
    };
  }

  RunnerActivityType? _activityType(
    health.HealthWorkoutActivityType workoutType,
  ) {
    return switch (workoutType) {
      health.HealthWorkoutActivityType.RUNNING => RunnerActivityType.running,
      health.HealthWorkoutActivityType.RUNNING_TREADMILL =>
        RunnerActivityType.treadmillRunning,
      _ => null,
    };
  }

  double? _distanceMeters(health.WorkoutHealthValue value) {
    final distance = value.totalDistance?.toDouble();
    if (distance == null) return null;

    return switch (value.totalDistanceUnit) {
      health.HealthDataUnit.METER || null => distance,
      health.HealthDataUnit.CENTIMETER => distance / 100,
      health.HealthDataUnit.INCH => distance * 0.0254,
      health.HealthDataUnit.FOOT => distance * 0.3048,
      health.HealthDataUnit.YARD => distance * 0.9144,
      health.HealthDataUnit.MILE => distance * 1609.344,
      _ => distance,
    };
  }
}
