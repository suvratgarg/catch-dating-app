import 'package:flutter/widgets.dart';

/// Internal Field-to-Section state handoff; content never paints separators.
class CatchFieldActivityNotification extends Notification {
  const CatchFieldActivityNotification(this.active);
  final bool active;
}
