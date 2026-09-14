import 'package:flutter/material.dart';

import '../support/widgetbook_harness.dart';
import 'fixtures.dart';

const double _utilityDeviceFrameMaxWidth = 390;

const double _utilityDeviceFrameHeight = 720;

class WidgetbookUtilityDeviceFrame extends StatelessWidget {
  const WidgetbookUtilityDeviceFrame({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      WidgetbookViewportFrame.constrainedDevice(
        size: const Size(
          _utilityDeviceFrameMaxWidth,
          _utilityDeviceFrameHeight,
        ),
        child: child,
      );
}

class WidgetbookUtilitySheetFrame extends StatelessWidget {
  const WidgetbookUtilitySheetFrame({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      WidgetbookViewportFrame.constrainedSheet(
        size: const Size(
          _utilityDeviceFrameMaxWidth,
          widgetbookUtilitySheetFrameHeight,
        ),
        child: child,
      );
}
