import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/contract_preview.dart';

import '../../preview_layout_contracts.dart';

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchKickerText,
  path: '[Core primitives]/Typography',
)
Widget catchTypographyContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return WidgetbookContractFrame(
    title: 'CatchTypography',
    contractId: 'catch.typography',
    states: const [
      'kicker-md',
      'kicker-lg',
      'kicker-field-section',
      'tinted',
      'truncated',
      'mono-label',
    ],
    children: [
      const WidgetbookContractStateCard(
        label: 'kicker-md',
        child: CatchKickerText(label: 'Today'),
      ),
      WidgetbookContractStateCard(
        label: 'kicker-lg',
        child: CatchKickerText(
          label: 'Featured format',
          variant: CatchKickerTextVariant.lg,
        ),
      ),
      const WidgetbookContractStateCard(
        label: 'kicker-field-section',
        child: CatchKickerText(
          label: 'About you',
          variant: CatchKickerTextVariant.fieldSection,
        ),
      ),
      WidgetbookContractStateCard(
        label: 'tinted',
        child: CatchKickerText(label: 'Social run format', color: t.primary),
      ),
      const WidgetbookContractStateCard(
        label: 'truncated',
        child: SizedBox(
          width: WidgetbookPreviewLayout.kickerTruncationWidth,
          child: CatchKickerText(label: 'Very long metadata label'),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'mono-label',
        child: WidgetbookContractWrap(
          children: [
            CatchMetadataText('6 going', color: t.ink2),
            CatchMetadataText('2.4 km away', color: t.primary),
            SizedBox(
              width: WidgetbookPreviewLayout.monoLabelTruncationWidth,
              child: CatchMetadataText(
                'A very long metadata label',
                color: t.ink3,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchIndexRow,
  path: '[Core primitives]/Lists',
)
Widget catchIndexRowContractStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return WidgetbookContractFrame(
    title: 'CatchIndexRow',
    contractId: 'catch.index_row',
    states: const ['default', 'selected', 'leading', 'trailing', 'disabled'],
    children: [
      WidgetbookContractStateCard(
        label: 'default',
        child: CatchIndexRow(title: 'Dinner', onTap: widgetbookNoop),
      ),
      WidgetbookContractStateCard(
        label: 'selected with leading and trailing',
        child: CatchIndexRow(
          title: 'Social run',
          selected: true,
          leading: CatchStatusIndicator(color: t.accent),
          trailing: const Text('12'),
          onTap: widgetbookNoop,
        ),
      ),
      const WidgetbookContractStateCard(
        label: 'disabled',
        child: CatchIndexRow(title: 'Coming soon', onTap: null),
      ),
    ],
  );
}
