import 'package:catch_ui/src/components/catch_status_strip_action.dart';
import 'package:flutter/material.dart';

/// Durable context, not a queued notification or a mutation failure.
/// Callers supply truthful state and actions; screen owners choose placement.
@immutable
class CatchStatusStripData {
  const CatchStatusStripData({
    required this.id,
    required this.label,
    required this.message,
    required this.icon,
    required this.color,
    this.actions = const [],
  });

  final String id;
  final String label;
  final String message;
  final IconData icon;
  final Color color;
  final List<CatchStatusStripAction> actions;
}
