import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

import '../../preview_layout_contracts.dart';
import '../../support/widgetbook_harness.dart';

class WidgetbookEventDeviceFrame extends StatelessWidget {
  const WidgetbookEventDeviceFrame({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      WidgetbookViewportFrame.constrainedDevice(
        size: const Size(
          390,
          WidgetbookPreviewLayout.paperScaffoldViewportHeight,
        ),
        child: child,
      );
}

class WidgetbookEventHiddenSectionState extends StatelessWidget {
  const WidgetbookEventHiddenSectionState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return CatchEmptyState(
      title: 'Hidden',
      message: message,
      variant: CatchEmptyStateVariant.inline,
      surface: true,
    );
  }
}
