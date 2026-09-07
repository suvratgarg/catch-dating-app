import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/widgetbook_harness.dart';

@widgetbook.UseCase(
  name: 'Label value and supporting states',
  type: CatchFieldValueContent,
  path: '[Core primitives]/Fields',
)
Widget fieldValueContentStates(BuildContext context) {
  final labelCopy = catchFieldCopy(context.l10n).label;
  return WidgetbookCatalogFrame(
    title: 'Field text lanes',
    catalogId: 'catch.field.value_content',
    children: [
      CatchFieldValueContent(
        labelCopy: labelCopy,
        label: 'Location',
        value: 'City centre',
      ),
      CatchFieldValueContent(
        labelCopy: labelCopy,
        label: 'Display name',
        value: 'Add your name',
        mode: CatchFieldValueContentMode.placeholder,
        isOptional: true,
        badgeLabel: 'Private',
      ),
      CatchFieldValueContent(
        labelCopy: labelCopy,
        label: 'Short introduction',
        value: 'Tell us about yourself',
        supportText: 'Use at least 20 characters.',
        counterText: '12 / 140',
        status: CatchFieldValueContentStatus.error,
      ),
      CatchFieldValueContent(
        labelCopy: labelCopy,
        label: 'Availability',
        status: CatchFieldValueContentStatus.active,
        headerTrailingReserve:
            CatchFieldTokens.trailingGap +
            CatchFieldTokens.disclosureGlyphExtent,
        valueWidget: CatchChip.selectable(
          label: 'Evenings',
          selected: true,
          onChanged: (_) {},
        ),
      ),
      CatchFieldValueContent(
        labelCopy: labelCopy,
        label: 'All set',
        emphasis: CatchFieldEmphasis.title,
        supportText: 'Your preferences are saved.',
        helperTone: CatchFieldSupportTone.success,
      ),
      CatchFieldValueContent(labelCopy: labelCopy),
    ],
  );
}
