import 'package:flutter/foundation.dart';

enum CatchTopBarNavigationMode { auto, back, close, none }

/// One leading navigation policy, appearance and caller-owned action.
///
/// Automatic mode follows the current Navigator. Explicit back/close modes
/// remain visible even when the caller supplies a non-Navigator destination.
@immutable
class CatchTopBarNavigation {
  const CatchTopBarNavigation({
    this.mode = CatchTopBarNavigationMode.auto,
    this.onPressed,
  });

  final CatchTopBarNavigationMode mode;
  final VoidCallback? onPressed;
}
