import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

Future<int?> showCatchFormStepOverview({
  required CatchFieldCopy fieldCopy,
  required BuildContext context,
  required String title,
  required String subtitle,
  required List<CatchFormStepReviewItem> items,
  required String Function(CatchFormStepStatus) statusLabelBuilder,
}) {
  return showCatchBottomSheet<int>(
    context: context,
    builder: (context) => CatchBottomSheetScaffold(
      title: title,
      subtitle: subtitle,
      child: CatchFormStepOverview(
        fieldCopy: fieldCopy,
        items: items,
        statusLabelBuilder: statusLabelBuilder,
      ),
    ),
  );
}

class CatchFormStepOverview extends StatelessWidget {
  const CatchFormStepOverview({
    required this.fieldCopy,
    super.key,
    required this.items,
    required this.statusLabelBuilder,
    this.onStepSelected,
  });

  final List<CatchFormStepReviewItem> items;
  final String Function(CatchFormStepStatus) statusLabelBuilder;
  final ValueChanged<int>? onStepSelected;

  final CatchFieldCopy fieldCopy;

  @override
  Widget build(BuildContext context) {
    return CatchFieldLanes.divided(
      children: [
        for (final item in items)
          CatchField.nav(
            copy: fieldCopy,
            key: ValueKey('catch-form-step-overview-${item.index}'),
            title: item.title,
            action: CatchBadge.functional(
              label: statusLabelBuilder(item.status),
              tone: _statusTone(item.status),
            ),
            onTap: () {
              final callback = onStepSelected;
              if (callback != null) {
                callback(item.index);
              } else {
                Navigator.of(context).pop(item.index);
              }
            },
          ),
      ],
    );
  }
}

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

class CatchFormReviewSummaryItem {
  const CatchFormReviewSummaryItem({
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;
}

CatchBadgeTone _statusTone(CatchFormStepStatus status) => switch (status) {
  CatchFormStepStatus.complete => CatchBadgeTone.success,
  CatchFormStepStatus.needsInformation => CatchBadgeTone.warning,
  CatchFormStepStatus.optional => CatchBadgeTone.neutral,
};
