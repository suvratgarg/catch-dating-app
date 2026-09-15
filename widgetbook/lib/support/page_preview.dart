import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// A catalog page whose lazy list stretches each preview to the available width.
class WidgetbookPageCatalogFrame extends StatelessWidget {
  const WidgetbookPageCatalogFrame({
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

class WidgetbookPageStateCard extends StatelessWidget {
  const WidgetbookPageStateCard({
    super.key,
    required this.label,
    required this.child,
    this.description,
  });

  final String label;
  final Widget child;
  final String? description;

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
            if (description != null) ...[
              gapH6,
              Text(
                description!,
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
            ],
            gapH12,
            child,
          ],
        ),
      ),
    );
  }
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

/// A catalog page that preserves each preview's natural width and lays out all
/// states together for review.
class WidgetbookScrollCatalogFrame extends StatelessWidget {
  const WidgetbookScrollCatalogFrame({
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

/// Clips content to its natural height with the standard phone-width limit.
class WidgetbookContentFrame extends StatelessWidget {
  const WidgetbookContentFrame({super.key, required this.child});

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
