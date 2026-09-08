import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_metric_strip_item.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:flutter/material.dart';

class CatchMetricStripCell extends StatelessWidget {
  const CatchMetricStripCell({
    super.key,
    required this.item,
    this.valueColor,
    this.unitColor,
    this.labelColor,
    this.expanded = false,
  });

  final CatchMetricStripItem item;
  final Color? valueColor;
  final Color? unitColor;
  final Color? labelColor;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final reflow = MediaQuery.textScalerOf(context).scale(1) >= 1.4;
    final cell = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                item.value,
                style: CatchTextStyles.mono(context, color: valueColor),
              ),
              if (item.unit.isNotEmpty) ...[
                gapW2,
                Text(
                  item.unit,
                  style: CatchTextStyles.mono(
                    context,
                    color: unitColor ?? t.ink2,
                  ),
                ),
              ],
            ],
          ),
        ),
        gapH2,
        Text(
          item.label,
          style: CatchTextStyles.supporting(
            context,
            color: labelColor ?? t.ink3,
          ),
          textAlign: TextAlign.center,
          maxLines: reflow ? 2 : 1,
          overflow: reflow ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
      ],
    );

    if (!expanded) return cell;
    return Expanded(child: cell);
  }
}
