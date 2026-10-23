import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/contract_preview.dart';

import '../../preview_layout_contracts.dart';

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchText,
  path: '[Core primitives]/Typography',
)
Widget catchTextContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return WidgetbookContractFrame(
    title: 'CatchText',
    contractId: 'catch.text',
    states: const ['roles', 'recolored', 'clamped', 'aligned'],
    children: [
      WidgetbookContractStateCard(
        label: 'roles',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: CatchGaps.related,
          children: [
            for (final variant in CatchTextVariant.values)
              CatchText(
                variant == CatchTextVariant.metric
                    ? '1,280'
                    : '${variant.name}: Thursday supper club',
                variant: variant,
              ),
          ],
        ),
      ),
      WidgetbookContractStateCard(
        label: 'recolored',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: CatchGaps.inline,
          children: [
            CatchText(
              'Payment failed',
              variant: CatchTextVariant.supporting,
              color: t.danger,
            ),
            CatchText(
              'Spot confirmed',
              variant: CatchTextVariant.supporting,
              color: t.positiveText,
            ),
          ],
        ),
      ),
      const WidgetbookContractStateCard(
        label: 'clamped',
        child: SizedBox(
          width: WidgetbookPreviewLayout.kickerTruncationWidth,
          child: CatchText(
            'A long description of the evening wraps past the line limit',
            variant: CatchTextVariant.bodyL,
            maxLines: 2,
          ),
        ),
      ),
      const WidgetbookContractStateCard(
        label: 'aligned',
        child: SizedBox(
          width: double.infinity,
          child: CatchText(
            'Centred copy',
            variant: CatchTextVariant.bodyM,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ],
  );
}
