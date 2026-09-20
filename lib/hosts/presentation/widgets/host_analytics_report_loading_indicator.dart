import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// Analytics recommendations, events, and quality panels depend on the report.
class HostAnalyticsReportLoadingIndicator extends StatelessWidget {
  const HostAnalyticsReportLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: CatchInsets.pageBodyRelaxed,
    child: CatchLoadingIndicator(),
  );
}
