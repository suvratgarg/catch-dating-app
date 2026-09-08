import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_form_step_overview.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// Final form review with summary rows and resumable step navigation.
class CatchFormReviewBody extends StatelessWidget {
  const CatchFormReviewBody({
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
  final String Function(CatchFormStepStatus) statusLabelBuilder;
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
          CatchFormStepOverview(
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
