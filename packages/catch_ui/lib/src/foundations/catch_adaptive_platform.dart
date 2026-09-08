import 'package:flutter/foundation.dart';

bool prefersCupertinoControls({TargetPlatform? platform}) {
  final effectivePlatform = platform ?? defaultTargetPlatform;
  return effectivePlatform == TargetPlatform.iOS;
}
