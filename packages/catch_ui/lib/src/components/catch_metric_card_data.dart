import 'package:catch_ui/src/components/catch_metric_status.dart';
import 'package:flutter/material.dart';

/// Display-ready payload for one analytics metric tile.
class CatchMetricCardData {
  const CatchMetricCardData({
    required this.icon,
    required this.value,
    required this.label,
    required this.partialBadgeLabel,
    required this.missingBadgeLabel,
    this.caption,
    this.status = CatchMetricStatus.ready,
  });

  final IconData icon;
  final String value;
  final String label;
  final String? caption;
  final CatchMetricStatus status;
  final String partialBadgeLabel;
  final String missingBadgeLabel;
}
