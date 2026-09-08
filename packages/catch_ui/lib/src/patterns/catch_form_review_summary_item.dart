import 'package:flutter/widgets.dart';

class CatchFormReviewSummaryItem {
  const CatchFormReviewSummaryItem({
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;
}
