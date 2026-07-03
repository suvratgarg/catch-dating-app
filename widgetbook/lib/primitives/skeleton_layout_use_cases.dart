import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Rows',
  type: CatchSkeletonRows,
  path: '[Core catalog]/Loading compositions',
)
Widget catchSkeletonRowsCatalogStates(BuildContext context) {
  return const _SkeletonLayoutCatalog(
    title: 'CatchSkeletonRows',
    children: [
      _StateCard(
        label: 'avatar titled',
        child: CatchSkeletonRows(
          titleWidth: CatchLayout.skeletonTextSectionWideWidth,
        ),
      ),
      _StateCard(
        label: 'media tile',
        child: CatchSkeletonRows(
          leading: CatchSkeletonRowLeading.mediaTile,
          count: 2,
        ),
      ),
      _StateCard(
        label: 'icon',
        child: CatchSkeletonRows(
          leading: CatchSkeletonRowLeading.icon,
          count: 2,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Box row',
  type: CatchSkeletonBoxRow,
  path: '[Core catalog]/Loading compositions',
)
Widget catchSkeletonBoxRowCatalogStates(BuildContext context) {
  return const _SkeletonLayoutCatalog(
    title: 'CatchSkeletonBoxRow',
    children: [
      _StateCard(
        label: 'three controls',
        child: CatchSkeletonBoxRow(
          count: 3,
          height: CatchLayout.controlCompactMinHeight,
          radius: CatchRadius.sm,
          gap: CatchSpacing.s2,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Chips',
  type: CatchSkeletonChips,
  path: '[Core catalog]/Loading compositions',
)
Widget catchSkeletonChipsCatalogStates(BuildContext context) {
  return const _SkeletonLayoutCatalog(
    title: 'CatchSkeletonChips',
    children: [
      _StateCard(label: 'default', child: CatchSkeletonChips()),
      _StateCard(
        label: 'compact',
        child: CatchSkeletonChips(height: CatchSpacing.s8),
      ),
    ],
  );
}

class _SkeletonLayoutCatalog extends StatelessWidget {
  const _SkeletonLayoutCatalog({required this.title, required this.children});

  final String title;
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
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            gapH20,
            for (final child in children) ...[child, gapH16],
          ],
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          gapH12,
          child,
        ],
      ),
    );
  }
}
