import 'package:catch_ui/src/components/catch_icon_action.dart';
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
    this.variant = CatchIconActionVariant.bordered,
    this.onPressed,
  });

  final CatchTopBarNavigationMode mode;
  final CatchIconActionVariant variant;
  final VoidCallback? onPressed;
}
