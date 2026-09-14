import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// Final review page with summary fields and one resumable form-step list.
///
/// Owns review copy, grouping, scrolling and clearance for the page's bottom
/// actions. CatchFormStepRowList owns each navigable status row; the caller owns
/// step selection and submission.
class CatchFormReviewPageBody extends StatelessWidget {
  const CatchFormReviewPageBody({
    required this.fieldCopy,
    super.key,
    required this.message,
    required this.items,
    required this.statusLabelBuilder,
    required this.onStepSelected,
    this.summaryItems = const [],
  });

  final String message;
  final List<CatchFormStepReviewItem> items;
  final String Function(CatchFormStepRowListStatus) statusLabelBuilder;
  final ValueChanged<int> onStepSelected;
  final List<CatchFormReviewSummaryItem> summaryItems;

  final CatchFieldCopy fieldCopy;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return SingleChildScrollView(
      padding: CatchInsets.formStepBodyWithBottomActions,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          if (summaryItems.isNotEmpty) ...[
            gapH16,
            CatchFieldLanes.divided(
              children: [
                for (final item in summaryItems)
                  CatchField.read(
                    copy: fieldCopy,
                    title: item.label,
                    body: item.value,
                    bodyMaxLines: 5,
                    icon: item.icon,
                  ),
              ],
            ),
          ],
          gapH16,
          CatchFormStepRowList(
            fieldCopy: fieldCopy,
            items: items,
            statusLabelBuilder: statusLabelBuilder,
            onStepSelected: onStepSelected,
          ),
        ],
      ),
    );
  }
}
