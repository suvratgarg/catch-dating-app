import 'package:flutter/widgets.dart';

class CaptureDevice {
  const CaptureDevice({
    required this.id,
    required this.size,
    this.devicePixelRatio = 1.0,
    this.safeArea = EdgeInsets.zero,
  });

  final String id;
  final Size size;
  final double devicePixelRatio;
  final EdgeInsets safeArea;

  static const reviewTall = CaptureDevice(
    id: 'review-tall',
    size: Size(440, 1820),
  );

  static const reviewPhone = CaptureDevice(
    id: 'review-phone',
    size: Size(440, 1220),
  );

  static const designPhone = CaptureDevice(
    id: 'design-phone',
    size: Size(390, 812),
  );

  static const claudePhone390 = CaptureDevice(
    id: 'claude-phone-390x812',
    size: Size(390, 812),
    safeArea: EdgeInsets.only(top: 44, bottom: 32),
  );

  static const iphone15 = CaptureDevice(id: 'iphone-15', size: Size(393, 852));

  static const iphone17Pro = CaptureDevice(
    id: 'iphone-17-pro',
    size: Size(402, 874),
    safeArea: EdgeInsets.only(top: 59, bottom: 34),
  );

  static const all = <CaptureDevice>[
    reviewTall,
    reviewPhone,
    designPhone,
    claudePhone390,
    iphone15,
    iphone17Pro,
  ];

  static CaptureDevice fromId(String id) {
    for (final device in all) {
      if (device.id == id) return device;
    }
    throw ArgumentError.value(id, 'id', 'Unknown capture device id.');
  }
}
