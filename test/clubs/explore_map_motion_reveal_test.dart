import 'package:catch_dating_app/core/device_motion.dart';
import 'package:catch_dating_app/explore/presentation/explore_map_motion_reveal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExploreMapMotionRevealRecognizer', () {
    test('triggers on a quick pitch-dominant wrist lift', () {
      final recognizer = ExploreMapMotionRevealRecognizer();

      expect(
        recognizer.handle(
          _sample(
            0,
            userAccelerationY: 1.1,
            rotationX: 2.7,
            rotationY: 0.5,
            rotationZ: 0.2,
          ),
        ),
        isFalse,
      );
      expect(
        recognizer.handle(
          _sample(
            80,
            userAccelerationY: 1.3,
            rotationX: 2.9,
            rotationY: 0.4,
            rotationZ: 0.2,
          ),
        ),
        isTrue,
      );
    });

    test('does not trigger from linear shake without pitch rotation', () {
      final recognizer = ExploreMapMotionRevealRecognizer();

      expect(
        recognizer.handle(
          _sample(
            0,
            userAccelerationX: 3.2,
            userAccelerationY: 2.0,
            rotationX: 0.4,
            rotationY: 0.2,
            rotationZ: 0.1,
          ),
        ),
        isFalse,
      );
      expect(
        recognizer.handle(
          _sample(
            90,
            userAccelerationX: -3.1,
            userAccelerationY: -1.8,
            rotationX: 0.5,
            rotationY: 0.3,
            rotationZ: 0.1,
          ),
        ),
        isFalse,
      );
    });

    test('does not trigger from a sideways twist', () {
      final recognizer = ExploreMapMotionRevealRecognizer();

      expect(
        recognizer.handle(
          _sample(
            0,
            userAccelerationY: 1.4,
            rotationX: 0.6,
            rotationY: 0.3,
            rotationZ: 3.4,
          ),
        ),
        isFalse,
      );
      expect(
        recognizer.handle(
          _sample(
            80,
            userAccelerationY: 1.2,
            rotationX: 0.7,
            rotationY: 0.4,
            rotationZ: 3.6,
          ),
        ),
        isFalse,
      );
    });

    test('debounces after a reveal', () {
      final recognizer = ExploreMapMotionRevealRecognizer();

      expect(
        recognizer.handle(_sample(0, userAccelerationY: 1.2, rotationX: 3.9)),
        isTrue,
      );
      expect(
        recognizer.handle(_sample(200, userAccelerationY: 1.2, rotationX: 3.9)),
        isFalse,
      );
      expect(
        recognizer.handle(
          _sample(2100, userAccelerationY: 1.2, rotationX: 3.9),
        ),
        isTrue,
      );
    });
  });
}

DeviceMotionSample _sample(
  int milliseconds, {
  double userAccelerationX = 0,
  double userAccelerationY = 0,
  double userAccelerationZ = 0,
  double rotationX = 0,
  double rotationY = 0,
  double rotationZ = 0,
}) {
  return DeviceMotionSample(
    timestamp: DateTime(2026).add(Duration(milliseconds: milliseconds)),
    userAccelerationX: userAccelerationX,
    userAccelerationY: userAccelerationY,
    userAccelerationZ: userAccelerationZ,
    rotationX: rotationX,
    rotationY: rotationY,
    rotationZ: rotationZ,
  );
}
