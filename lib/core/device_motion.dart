import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

final deviceMotionSourceProvider = Provider<DeviceMotionSource>(
  (ref) => const SensorDeviceMotionSource(),
);

abstract interface class DeviceMotionSource {
  Stream<DeviceMotionSample> watchMotion();
}

class DeviceMotionSample {
  const DeviceMotionSample({
    required this.timestamp,
    required this.userAccelerationX,
    required this.userAccelerationY,
    required this.userAccelerationZ,
    required this.rotationX,
    required this.rotationY,
    required this.rotationZ,
  });

  final DateTime timestamp;
  final double userAccelerationX;
  final double userAccelerationY;
  final double userAccelerationZ;
  final double rotationX;
  final double rotationY;
  final double rotationZ;
}

class SensorDeviceMotionSource implements DeviceMotionSource {
  const SensorDeviceMotionSource({
    this.samplingPeriod = SensorInterval.uiInterval,
  });

  final Duration samplingPeriod;

  @override
  Stream<DeviceMotionSample> watchMotion() async* {
    UserAccelerometerEvent? latestAcceleration;
    GyroscopeEvent? latestRotation;
    final subscriptions = <StreamSubscription<dynamic>>[];
    final controller = StreamController<DeviceMotionSample>();

    void emitSample() {
      final acceleration = latestAcceleration;
      final rotation = latestRotation;
      if (acceleration == null || rotation == null || controller.isClosed) {
        return;
      }
      controller.add(
        DeviceMotionSample(
          timestamp: DateTime.now(),
          userAccelerationX: acceleration.x,
          userAccelerationY: acceleration.y,
          userAccelerationZ: acceleration.z,
          rotationX: rotation.x,
          rotationY: rotation.y,
          rotationZ: rotation.z,
        ),
      );
    }

    subscriptions
      ..add(
        userAccelerometerEventStream(samplingPeriod: samplingPeriod).listen((
          event,
        ) {
          latestAcceleration = event;
          emitSample();
        }, onError: controller.addError),
      )
      ..add(
        gyroscopeEventStream(samplingPeriod: samplingPeriod).listen((event) {
          latestRotation = event;
          emitSample();
        }, onError: controller.addError),
      );

    try {
      yield* controller.stream;
    } finally {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
      await controller.close();
    }
  }
}
