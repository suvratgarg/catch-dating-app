import 'package:flutter/material.dart';

import '../../preview_layout_contracts.dart';
import '../../support/widgetbook_harness.dart';

class WidgetbookCompanionDeviceFrame extends StatelessWidget {
  const WidgetbookCompanionDeviceFrame({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      WidgetbookViewportFrame.constrainedDevice(
        size: const Size(
          390,
          WidgetbookPreviewLayout.profilePhonePreviewHeight,
        ),
        child: child,
      );
}
