import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

import '../../preview_layout_contracts.dart';
import '../../support/widgetbook_harness.dart';

class WidgetbookEventCatalogFrame extends StatelessWidget {
  const WidgetbookEventCatalogFrame({
    super.key,
    required this.title,
    required this.catalogId,
    required this.children,
  });

  final String title;
  final String catalogId;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: CatchInsets.content,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: CatchTextStyles.titleL(context)),
              gapH4,
              Text(
                catalogId,
                style: CatchTextStyles.monoLabel(context, color: t.ink2),
              ),
              gapH24,
              for (final child in children) ...[child, gapH20],
            ],
          ),
        ),
      ),
    );
  }
}

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

class WidgetbookEventDockFrame extends StatelessWidget {
  const WidgetbookEventDockFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 390),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.surface,
          border: Border.all(color: t.line),
          borderRadius: BorderRadius.circular(CatchRadius.lg),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(CatchRadius.lg),
          child: child,
        ),
      ),
    );
  }
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
