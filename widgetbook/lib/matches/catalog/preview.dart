import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

import '../../support/widgetbook_harness.dart';

class WidgetbookMatchesChatSliverFrame extends StatelessWidget {
  const WidgetbookMatchesChatSliverFrame({
    super.key,
    required this.slivers,
    this.height = 420,
  });

  final List<Widget> slivers;
  final double height;

  @override
  Widget build(BuildContext context) {
    return WidgetbookMatchesDeviceFrame(
      height: height,
      child: Builder(
        builder: (context) {
          final t = CatchTokens.of(context);
          return Scaffold(
            backgroundColor: t.bg,
            body: SafeArea(child: CustomScrollView(slivers: slivers)),
          );
        },
      ),
    );
  }
}

class WidgetbookMatchesPrimitiveReviewFrame extends StatelessWidget {
  const WidgetbookMatchesPrimitiveReviewFrame({
    super.key,
    required this.child,
    this.height = 180,
  });

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return WidgetbookMatchesDeviceFrame(
      height: height,
      child: Builder(
        builder: (context) {
          final t = CatchTokens.of(context);
          return Scaffold(
            backgroundColor: t.bg,
            body: SafeArea(
              child: Align(alignment: Alignment.topCenter, child: child),
            ),
          );
        },
      ),
    );
  }
}

class WidgetbookMatchesDeviceFrame extends StatelessWidget {
  const WidgetbookMatchesDeviceFrame({
    super.key,
    required this.child,
    this.height = 720,
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
