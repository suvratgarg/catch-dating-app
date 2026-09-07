class CatchMetricStripItem {
  const CatchMetricStripItem({
    required this.value,
    required this.label,
    this.unit = '',
  });

  final String value;
  final String unit;
  final String label;
}
