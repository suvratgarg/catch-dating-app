import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

import '../../preview_layout_contracts.dart';
import '../../support/widgetbook_harness.dart';

class WidgetbookCatchesSectionFrame extends StatelessWidget {
  const WidgetbookCatchesSectionFrame({
    super.key,
    required this.child,
    this.height = 360,
  });
  final Widget child;
  final double height;
  @override
  Widget build(BuildContext context) =>
      WidgetbookViewportFrame.constrainedDevice(
        size: Size(390, height),
        child: child,
      );
}

class WidgetbookCatchesDeckChromeFrame extends StatelessWidget {
  const WidgetbookCatchesDeckChromeFrame({
    super.key,
    required this.child,
    this.height = 180,
  });

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return WidgetbookCatchesSectionFrame(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: t.heroGrad),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class WidgetbookCatchesDeviceFrame extends StatelessWidget {
  const WidgetbookCatchesDeviceFrame({super.key, required this.child});
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
