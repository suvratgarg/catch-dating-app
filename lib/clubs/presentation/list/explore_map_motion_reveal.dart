import 'dart:math' as math;

import 'package:catch_dating_app/core/device_motion.dart';

class ExploreMapMotionRevealRecognizer {
  ExploreMapMotionRevealRecognizer({
    this.cooldown = const Duration(milliseconds: 1800),
    this.gestureWindow = const Duration(milliseconds: 240),
    this.minPitchRotation = 2.35,
    this.strongPitchRotation = 3.6,
    this.minPitchShare = 0.55,
    this.minAcceleration = 0.75,
    this.maxAcceleration = 7.5,
  });

  final Duration cooldown;
  final Duration gestureWindow;
  final double minPitchRotation;
  final double strongPitchRotation;
  final double minPitchShare;
  final double minAcceleration;
  final double maxAcceleration;

  DateTime? _candidateStartedAt;
  DateTime? _lastTriggerAt;
  int _candidateScore = 0;

  bool handle(DeviceMotionSample sample) {
    final lastTriggerAt = _lastTriggerAt;
    if (lastTriggerAt != null &&
        sample.timestamp.difference(lastTriggerAt) < cooldown) {
      return false;
    }

    final pitchRotation = sample.rotationX.abs();
    final rotationMagnitude = _magnitude(
      sample.rotationX,
      sample.rotationY,
      sample.rotationZ,
    );
    final pitchShare = rotationMagnitude == 0
        ? 0.0
        : pitchRotation / rotationMagnitude;
    final acceleration = _magnitude(
      sample.userAccelerationX,
      sample.userAccelerationY,
      sample.userAccelerationZ,
    );

    final accelerationInRange =
        acceleration >= minAcceleration && acceleration <= maxAcceleration;
    final pitchDominant = pitchShare >= minPitchShare;
    final candidate =
        accelerationInRange &&
        pitchDominant &&
        pitchRotation >= minPitchRotation;
    final strongCandidate =
        accelerationInRange &&
        pitchShare >= minPitchShare - 0.05 &&
        pitchRotation >= strongPitchRotation;

    if (!candidate && !strongCandidate) {
      _resetCandidateIfStale(sample.timestamp);
      return false;
    }

    final candidateStartedAt = _candidateStartedAt;
    if (candidateStartedAt == null ||
        sample.timestamp.difference(candidateStartedAt) > gestureWindow) {
      _candidateStartedAt = sample.timestamp;
      _candidateScore = 0;
    }

    _candidateScore += strongCandidate ? 2 : 1;
    if (_candidateScore < 2) return false;

    _lastTriggerAt = sample.timestamp;
    _candidateStartedAt = null;
    _candidateScore = 0;
    return true;
  }

  void reset() {
    _candidateStartedAt = null;
    _candidateScore = 0;
  }

  void _resetCandidateIfStale(DateTime timestamp) {
    final candidateStartedAt = _candidateStartedAt;
    if (candidateStartedAt != null &&
        timestamp.difference(candidateStartedAt) > gestureWindow) {
      reset();
    }
  }
}

double _magnitude(double x, double y, double z) {
  return math.sqrt((x * x) + (y * y) + (z * z));
}
