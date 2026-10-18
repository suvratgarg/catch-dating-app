import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

Future<int?> showCatchFormStepSheet({
  required CatchFieldCopy fieldCopy,
  required BuildContext context,
  required String title,
  required String subtitle,
  required List<CatchFormStepReviewItem> items,
  required String Function(CatchFormStepListStatus) statusLabelBuilder,
}) {
  return showCatchBottomSheet<int>(
    context: context,
    builder: (context) => CatchSheet.standard(
      title: title,
      subtitle: subtitle,
      child: CatchFormStepList(
        fieldCopy: fieldCopy,
        items: items,
        statusLabelBuilder: statusLabelBuilder,
      ),
    ),
  );
}

/// Navigable form sections with completion status and caller-owned selection.
///
/// Each row reuses CatchField.nav and the shared badge. This list resumes a form
/// section; CatchStepList presents passive instructions, while CatchFormList
/// owns editors and per-field saves. A sheet returns the chosen index when no
/// selection callback is supplied.
class CatchFormStepList extends StatelessWidget {
  const CatchFormStepList({
    required this.fieldCopy,
    super.key,
    required this.items,
    required this.statusLabelBuilder,
    this.onStepSelected,
  });

  final List<CatchFormStepReviewItem> items;
  final String Function(CatchFormStepListStatus) statusLabelBuilder;
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
            actions: CatchBadge.functional(
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

CatchBadgeTone _statusTone(CatchFormStepListStatus status) => switch (status) {
  CatchFormStepListStatus.complete => CatchBadgeTone.success,
  CatchFormStepListStatus.needsInformation => CatchBadgeTone.warning,
  CatchFormStepListStatus.optional => CatchBadgeTone.neutral,
};
