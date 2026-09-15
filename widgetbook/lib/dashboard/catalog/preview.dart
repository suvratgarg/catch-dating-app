import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

import '../../support/widgetbook_harness.dart';

abstract final class WidgetbookDashboardPreviewLayout {
  static const double recommendationCardWidth = 340;
  static const double deviceFrameWidth = 390;
  static const double deviceFrameHeight = 720;
}

class WidgetbookDashboardPrimitiveFrame extends StatelessWidget {
  const WidgetbookDashboardPrimitiveFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: CatchLayout.maxContentWidth,
        ),
        child: child,
      ),
    );
  }
}

class WidgetbookDashboardDeviceFrame extends StatelessWidget {
  const WidgetbookDashboardDeviceFrame({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      WidgetbookViewportFrame.constrainedDevice(
        size: const Size(
          WidgetbookDashboardPreviewLayout.deviceFrameWidth,
          WidgetbookDashboardPreviewLayout.deviceFrameHeight,
        ),
        child: child,
      );
}
