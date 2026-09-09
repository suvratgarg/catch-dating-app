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
    builder: (context) => CatchSheet(
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

CatchBadgeTone _statusTone(CatchFormStepStatus status) => switch (status) {
  CatchFormStepStatus.complete => CatchBadgeTone.success,
  CatchFormStepStatus.needsInformation => CatchBadgeTone.warning,
  CatchFormStepStatus.optional => CatchBadgeTone.neutral,
};
