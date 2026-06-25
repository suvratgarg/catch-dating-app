import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

class CatchStatStripItem {
  const CatchStatStripItem({required this.value, required this.label});

  final String value;
  final String label;
}

/// Handoff `CatchStatStrip`: flat hairline-bordered row of labeled data pairs.
class CatchStatStrip extends StatelessWidget {
  const CatchStatStrip({super.key, required this.items});

  final List<CatchStatStripItem> items;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      radius: CatchRadius.md,
      backgroundColor: t.surface,
      borderColor: t.line,
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < items.length; index++) ...[
              Expanded(child: _StatStripCell(item: items[index])),
              if (index < items.length - 1)
                VerticalDivider(
                  width: CatchStroke.hairline,
                  thickness: CatchStroke.hairline,
                  color: t.line,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatStripCell extends StatelessWidget {
  const _StatStripCell({required this.item});

  final CatchStatStripItem item;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s3,
        vertical: CatchLayout.statStripVerticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                item.value,
                maxLines: 1,
                softWrap: false,
                style: CatchTextStyles.numericLarge(context, color: t.ink),
              ),
            ),
          ),
          const SizedBox(height: CatchSpacing.s1),
          Text(
            item.label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.monoLabelS(
              context,
              color: t.ink3,
            ).copyWith(fontSize: CatchLayout.statStripLabelFontSize),
          ),
        ],
      ),
    );
  }
}
