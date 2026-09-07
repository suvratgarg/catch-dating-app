import 'package:flutter/widgets.dart';

/// Signals a committed choice from a field's disclosed control.
///
/// The nearest field consumes this notification and owns the close delay,
/// saving-state guard, and caller-controlled expansion. Choice controls dispatch
/// it after the caller's selection callback; they do not close a field directly.
class CatchFieldChoicePickedNotification extends Notification {
  const CatchFieldChoicePickedNotification({required this.autoClose});

  final bool autoClose;
}
