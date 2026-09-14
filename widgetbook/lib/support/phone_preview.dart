import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

import '../preview_layout_contracts.dart';

class WidgetbookWrapCatalogFrame extends StatelessWidget {
  const WidgetbookWrapCatalogFrame({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(CatchSpacing.s6),
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: CatchSpacing.s4),
        Wrap(
          spacing: CatchSpacing.s4,
          runSpacing: CatchSpacing.s4,
          children: children,
        ),
      ],
    );
  }
}

class WidgetbookPhoneStateCard extends StatelessWidget {
  const WidgetbookPhoneStateCard({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: WidgetbookPreviewLayout.phoneChromeWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: CatchSpacing.s2),
          child,
        ],
      ),
    );
  }
}

class WidgetbookMaterialPhoneFrame extends StatelessWidget {
  const WidgetbookMaterialPhoneFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: WidgetbookPreviewLayout.phoneChromeWidth,
      height: WidgetbookPreviewLayout.profilePhonePreviewHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          WidgetbookPreviewLayout.phonePreviewCornerRadius,
        ),
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          child: child,
        ),
      ),
    );
  }
}

class WidgetbookPhoneMediaOverride extends StatelessWidget {
  const WidgetbookPhoneMediaOverride({
    super.key,
    required this.child,
    this.disableAnimations = false,
    this.textScale,
  });

  final Widget child;
  final bool disableAnimations;
  final double? textScale;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        disableAnimations: disableAnimations,
        textScaler: textScale == null ? null : TextScaler.linear(textScale!),
      ),
      child: child,
    );
  }
}
