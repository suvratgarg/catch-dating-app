import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Derived content',
  type: CatchSkeleton,
  path: '[Core catalog]/Loading compositions',
)
Widget catchSkeletonContentCatalogState(BuildContext context) {
  return Scaffold(
    body: CatchSkeleton.content(
      child: CatchSectionStack(
        children: [
          CatchSection.containedFieldRows(
            title: 'Customer details',
            children: [
              CatchField.read(
                copy: catchFieldCopy(context.l10n),
                title: 'Name',
                body: 'Customer name',
              ),
              CatchField.read(
                copy: catchFieldCopy(context.l10n),
                title: 'Mobile number',
                body: '+919876543210',
              ),
              CatchField.read(
                copy: catchFieldCopy(context.l10n),
                title: 'Email',
                body: 'customer@example.com',
              ),
            ],
          ),
          CatchSection.plain(
            title: 'Attendance',
            child: Text(
              'Two events attended out of three expected.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Rows',
  type: CatchSkeleton,
  path: '[Core catalog]/Loading compositions',
)
Widget catchSkeletonRowsCatalogStates(BuildContext context) {
  return const _SkeletonLayoutCatalog(
    title: 'CatchSkeleton.rows',
    children: [
      _StateCard(
        label: 'avatar titled',
        child: CatchSkeleton.rows(
          titleWidth: CatchLayout.skeletonTextSectionWideWidth,
        ),
      ),
      _StateCard(label: 'media tile', child: CatchSkeleton.mediaRows(count: 2)),
      _StateCard(label: 'icon', child: CatchSkeleton.iconRows(count: 2)),
      _StateCard(
        label: 'divided media tile',
        child: CatchSkeleton.mediaRows(count: 2, divided: true),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Box row',
  type: CatchSkeleton,
  path: '[Core catalog]/Loading compositions',
)
Widget catchSkeletonBoxRowCatalogStates(BuildContext context) {
  return const _SkeletonLayoutCatalog(
    title: 'CatchSkeleton.boxes',
    children: [
      _StateCard(
        label: 'three controls',
        child: CatchSkeleton.boxes(
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
  type: CatchSkeleton,
  path: '[Core catalog]/Loading compositions',
)
Widget catchSkeletonChipsCatalogStates(BuildContext context) {
  return const _SkeletonLayoutCatalog(
    title: 'CatchSkeleton.chips',
    children: [
      _StateCard(label: 'default', child: CatchSkeleton.chips()),
      _StateCard(
        label: 'compact',
        child: CatchSkeleton.chips(height: CatchSpacing.s8),
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
