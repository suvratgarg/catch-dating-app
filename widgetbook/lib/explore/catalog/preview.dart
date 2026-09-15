import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

import '../../support/widgetbook_harness.dart';

class WidgetbookExploreDeviceFrame extends StatelessWidget {
  const WidgetbookExploreDeviceFrame({
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

class WidgetbookExploreSliverFrame extends StatelessWidget {
  const WidgetbookExploreSliverFrame({
    super.key,
    required this.child,
    this.height = 560,
  });

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 390),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.bg,
          border: Border.all(color: t.line),
          borderRadius: BorderRadius.circular(CatchRadius.lg),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(CatchRadius.lg),
          child: SizedBox(height: height, child: child),
        ),
      ),
    );
  }
}

class WidgetbookExploreMediaOverride extends StatelessWidget {
  const WidgetbookExploreMediaOverride({
    super.key,
    required this.child,
    this.textScaler,
    this.disableAnimations,
  });

  final Widget child;
  final TextScaler? textScaler;
  final bool? disableAnimations;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        textScaler: textScaler ?? media.textScaler,
        disableAnimations: disableAnimations ?? media.disableAnimations,
      ),
      child: child,
    );
  }
}
