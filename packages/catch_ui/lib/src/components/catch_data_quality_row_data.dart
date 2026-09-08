import 'package:catch_ui/src/components/catch_metric_status.dart';

/// Display-ready payload for one analytics data-quality row.
class CatchDataQualityRowData {
  const CatchDataQualityRowData({required this.status, required this.detail});

  final CatchMetricStatus status;
  final String detail;
}
