import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

import '../../preview_layout_contracts.dart';
import '../../support/widgetbook_harness.dart';
import 'shell_fixture.dart';

String widgetbookHostComponentSlug(String name) {
  return name
      .replaceAllMapped(
        RegExp(r'([a-z0-9])([A-Z])'),
        (match) => '${match.group(1)}_${match.group(2)}',
      )
      .toLowerCase();
}

class WidgetbookHostComponentFrame extends StatelessWidget {
  const WidgetbookHostComponentFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return WidgetbookHostDeviceFrame(
      child: WidgetbookHostShellScope(
        child: WidgetbookHostComponentScaffold(child: child),
      ),
    );
  }
}

class WidgetbookHostComponentScaffold extends StatelessWidget {
  const WidgetbookHostComponentScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: ListView(
        padding: CatchInsets.pageBodyUnderHeader,
        children: [child],
      ),
    );
  }
}

class WidgetbookHostHomeSectionFrame extends StatelessWidget {
  const WidgetbookHostHomeSectionFrame({
    super.key,
    required this.child,
    this.clubEventStreams = const {},
  });

  final Widget child;
  final Map<String, Stream<List<Event>>> clubEventStreams;

  @override
  Widget build(BuildContext context) {
    final framedChild = Builder(
      builder: (context) {
        final t = CatchTokens.of(context);
        return Scaffold(
          backgroundColor: t.bg,
          body: ListView(
            padding: CatchInsets.pageBodyUnderHeader,
            children: [child],
          ),
        );
      },
    );

    return WidgetbookHostDeviceFrame(
      child: WidgetbookHostShellScope(
        clubEventStreams: clubEventStreams,
        child: framedChild,
      ),
    );
  }
}

class WidgetbookHostCatalog extends StatelessWidget {
  const WidgetbookHostCatalog({
    super.key,
    required this.title,
    required this.contractId,
    required this.children,
  });

  final String title;
  final String contractId;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: ListView(
          padding: CatchInsets.content,
          children: [
            Text(title, style: CatchTextStyles.titleL(context)),
            gapH4,
            Text(
              contractId,
              style: CatchTextStyles.monoLabel(context, color: t.ink2),
            ),
            gapH24,
            for (final child in children) ...[child, gapH20],
          ],
        ),
      ),
    );
  }
}

class WidgetbookHostStateCard extends StatelessWidget {
  const WidgetbookHostStateCard({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(CatchRadius.lg),
      ),
      child: Padding(
        padding: CatchInsets.content,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: CatchTextStyles.sectionTitle(context)),
            gapH12,
            child,
          ],
        ),
      ),
    );
  }
}

class WidgetbookHostDeviceFrame extends StatelessWidget {
  const WidgetbookHostDeviceFrame({
    super.key,
    required this.child,
    this.height,
  });
  final Widget child;
  final double? height;
  @override
  Widget build(BuildContext context) =>
      WidgetbookViewportFrame.constrainedDevice(
        size: Size(
          390,
          height ?? WidgetbookPreviewLayout.paperScaffoldViewportHeight,
        ),
        child: child,
      );
}

class WidgetbookMediaOverride extends StatelessWidget {
  const WidgetbookMediaOverride({
    super.key,
    required this.child,
    this.textScaler,
    this.disableAnimations = false,
  });

  final Widget child;
  final TextScaler? textScaler;
  final bool disableAnimations;

  @override
  Widget build(BuildContext context) {
    final base = MediaQuery.of(context);
    return MediaQuery(
      data: base.copyWith(
        textScaler: textScaler ?? base.textScaler,
        disableAnimations: disableAnimations || base.disableAnimations,
      ),
      child: child,
    );
  }
}
